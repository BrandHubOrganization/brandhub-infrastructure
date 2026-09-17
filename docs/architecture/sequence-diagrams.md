# Sequence Diagrams — 4 Core Flows (V2)

> DA-1157 (DA-E05-06). Mermaid, text-based, committable. Cập nhật theo model V2: Agency→Workspace, Task 3 loại nội dung (Post/Livestream/Survey), Approval Sequence 4 bước (Creator → [QC] → Manager → Client, reject → restart from Creator).

## 1. Content Creation (Task → Write Content → AI Generate)

```mermaid
sequenceDiagram
    actor Creator
    participant WD as Web Dashboard
    participant GW as api-gateway
    participant BIZ as business-service
    participant AI as ai-service
    participant S3 as AWS S3

    Creator->>WD: Open assigned Task (Post-type)
    WD->>GW: GET /api/v1/tasks/{taskId}
    GW->>BIZ: forward (JWT verified)
    BIZ->>BIZ: RequireRoleAspect: MemberRole=CREATOR in this Workspace
    BIZ-->>WD: Task detail (backlog → assigned, from Campaign or Content Request)

    Creator->>WD: Write content (vector-text editor)
    WD->>GW: PUT /api/v1/tasks/{taskId}/content
    GW->>BIZ: forward
    BIZ->>BIZ: save content_versions (MongoDB), auto font-convert

    Creator->>WD: Request AI-generated image
    WD->>GW: POST /api/v1/tasks/{taskId}/ai/image
    GW->>BIZ: forward
    BIZ->>BIZ: check ai_credit_creator_limits (PostgreSQL) — block if exceeded
    BIZ->>AI: POST /internal/ai/image (X-Internal-Api-Key)
    AI->>AI: build prompt (form + ambassador + materials)
    AI->>S3: store generated image
    AI-->>BIZ: { generatedUrl, creditCost }
    BIZ->>BIZ: deduct ai_credit_ledgers, write ai_usage_logs (via ai-service)
    BIZ-->>WD: draft saved with AI image attached
```

## 2. Approval Workflow (4-step Task Approval Sequence)

```mermaid
sequenceDiagram
    actor Creator
    actor QC as QC Creator (optional)
    actor Manager
    actor Client
    participant BIZ as business-service

    Creator->>BIZ: Submit Task for review
    BIZ->>BIZ: task_approvals: step=CREATOR, status=SUBMITTED

    alt QC assigned at Assign Task step
        BIZ->>QC: notify review pending
        QC->>BIZ: Approve / Reject
        alt QC rejects
            BIZ->>BIZ: task_approvals: reset to CREATOR step
            BIZ->>Creator: notify — restart from Creator (not from QC step)
        end
    end

    BIZ->>Manager: notify review pending
    Manager->>BIZ: Approve / Reject
    alt Manager rejects
        BIZ->>BIZ: task_approvals: reset to CREATOR step
        BIZ->>Creator: notify — restart from Creator
    end

    opt Task requires Client approval
        BIZ->>Client: notify review pending
        Client->>BIZ: Approve / Reject
        alt Client rejects
            BIZ->>BIZ: task_approvals: reset to CREATOR step
            BIZ->>Creator: notify — restart from Creator
        end
    end

    BIZ->>BIZ: all steps passed → Task status = DONE
    BIZ->>Creator: notify Task complete
```

## 3. Auto-Publishing (scheduled Post → Social Platform)

```mermaid
sequenceDiagram
    participant SCHED as Scheduler (business-service)
    participant BIZ as business-service
    participant MQ as RabbitMQ (brandhub.publishing)
    participant PUB as publisher-service
    participant FB as Facebook Graph API

    SCHED->>BIZ: scheduledAt reached for Post (status=DONE, approved)
    BIZ->>BIZ: build publish job payload (content, mediaUrls, encrypted OAuth token)
    BIZ->>MQ: publish "publish.job" (exchange=brandhub.publishing, routing=publish.job)
    BIZ->>BIZ: Post status = IN_PROGRESS

    MQ->>PUB: deliver publisher.job.queue
    PUB->>PUB: decrypt OAuth token (AES-256)
    PUB->>FB: POST /graph/{page}/feed (or /stories, /reels per content type)

    alt Success
        FB-->>PUB: 200 { post_id }
        PUB->>MQ: publish "publish.callback" { status: SUCCESS, platformPostId }
    else Failure
        FB-->>PUB: 4xx/5xx error
        PUB->>PUB: retry 30s → 60s → 120s → DLQ if all fail
        PUB->>MQ: publish "publish.callback" { status: FAILED, error }
    end

    MQ->>BIZ: deliver business.publish_callback.queue
    BIZ->>BIZ: update Post status (DONE/FAIL), notify Manager/Client
```

## 4. OAuth Token Refresh

```mermaid
sequenceDiagram
    actor User
    participant WD as Web Dashboard
    participant GW as api-gateway
    participant BIZ as business-service
    participant Redis

    User->>WD: API call with expired access token
    WD->>GW: request + Authorization: Bearer {expired}
    GW->>GW: verify signature — expired, return 401
    GW-->>WD: 401 Unauthorized

    WD->>GW: POST /api/v1/auth/refresh (refresh token cookie)
    GW->>BIZ: forward (auth-public route, no JWT filter)
    BIZ->>BIZ: validate refresh token (user_refresh_tokens, PostgreSQL)
    BIZ->>Redis: check jwt:blacklist:{old_jti} — must NOT be blacklisted yet
    BIZ->>Redis: SET jwt:blacklist:{old_jti} (invalidate old access token FIRST)
    BIZ->>BIZ: issue new access token (new jti)
    BIZ-->>WD: { accessToken, expiresIn }

    WD->>GW: retry original request with new token
    GW->>GW: verify new signature — valid
    GW->>BIZ: forward (X-User-Id, X-User-Role, X-Workspace-Id injected — log only)
    BIZ->>BIZ: JwtAuthenticationFilter re-parses JWT independently
    BIZ-->>WD: original response
```

## Ghi chú kỹ thuật

- **Content creation & AI generate:** credit check xảy ra ở business-service TRƯỚC khi gọi ai-service — tránh gọi AI tốn tiền rồi mới phát hiện vượt hạn mức.
- **Approval Sequence:** reject ở BẤT KỲ bước nào (QC/Manager/Client) đều quay về bước Creator đầu tiên, không quay lại bước ngay trước đó — đã confirm trong `docs/ba/05-content-task-workflow.md` §4.
- **Auto-publishing:** publisher-service không bao giờ có DB access — toàn bộ payload đóng gói sẵn trong RabbitMQ message bởi business-service.
- **OAuth refresh:** old `jti` phải bị blacklist TRƯỚC khi issue token mới (không phải sau) — tránh race condition dùng cả 2 token cùng lúc.
