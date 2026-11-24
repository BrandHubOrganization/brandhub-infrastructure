# Sequence Diagrams — 4 Core Flows

> Navigation: [← Knowledge Base Hub](../index.md) · [← Architecture Index](./README.md) · [Service Boundaries](./service-boundaries.md) · [RS256 JWT Flow](../api/rs256-jwt-flow.md)
>
> Sơ đồ trình tự chuẩn cho 4 luồng cốt lõi của hệ thống BrandHub theo mô hình `Agency → Workspace → Media Package → Media Campaign → Task → Post` và quy trình phê duyệt 3 tầng (`Creator -> Manager -> Client`).

---

## 1. Content Creation & Atomic AI Credit Reservation (`FR 3.6.10`, `FR 3.7.9`, `FR 3.9.4`)

```mermaid
sequenceDiagram
    actor Creator
    participant Web as brandhub-web
    participant GW as api-gateway
    participant BIZ as business-service
    participant AI as ai-service
    participant S3 as AWS S3

    Creator->>Web: Open assigned Task (Post / Short Video / Survey)
    Web->>GW: GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}
    GW->>BIZ: forward (RS256 JWT verified)
    BIZ->>BIZ: Verify Workspace MemberRole = CREATOR
    BIZ-->>Web: Task detail & brief

    Creator->>Web: Author content with Unicode font styler (FR 3.6.10)
    Web->>GW: PUT /api/v1/workspaces/{workspaceId}/tasks/{taskId}/content
    GW->>BIZ: forward
    BIZ->>BIZ: Save version snapshot in MongoDB, return updated draft

    Creator->>Web: Request AI Image Generation (FR 3.7.9)
    Web->>GW: POST /api/v1/workspaces/{workspaceId}/ai/image
    GW->>BIZ: forward
    BIZ->>BIZ: Check workspace_credit_limits & reserve in ai_credit_reservations (PostgreSQL ACID)
    BIZ->>AI: POST /api/v1/ai/image/generate (X-Internal-Key)
    AI->>AI: Assemble prompt (Brief + Style Preset + Virtual Ambassador + Material refs)
    AI->>S3: Upload generated image asset
    AI-->>BIZ: ApiResponse { generatedUrl, creditCost }
    BIZ->>BIZ: Commit credit_operations & credit_entries against agency_credit_wallets
    BIZ-->>Web: Return generated asset URL & updated credit balance
```

---

## 2. Three-Tier Approval Sequence (`Creator -> Manager -> Client`, `FR 3.6.9`)

```mermaid
sequenceDiagram
    actor Creator
    actor QC as QC Creator (optional)
    actor Manager
    actor Client
    participant BIZ as business-service

    Creator->>BIZ: Submit Task deliverable for review
    BIZ->>BIZ: Record task_approvals (step=CREATOR, status=SUBMITTED)

    opt Internal QC Creator assigned on Task (FR 3.6.2)
        BIZ->>QC: Notify internal QC review pending
        QC->>BIZ: Approve / Reject (reason required on reject)
        alt QC rejects
            BIZ->>BIZ: Reset current workflow step to CREATOR (preserve prior approval history)
            BIZ->>Creator: Notify revision requested
        end
    end

    BIZ->>Manager: Notify Manager review pending
    Manager->>BIZ: Approve / Reject
    alt Manager rejects
        BIZ->>BIZ: Reset workflow to CREATOR step (keep append-only round history)
        BIZ->>Creator: Notify revision requested
    end

    opt Task requires Client sign-off
        BIZ->>Client: Notify Client review pending
        Client->>BIZ: Approve / Reject
        alt Client rejects
            BIZ->>BIZ: Reset workflow to CREATOR step (keep append-only round history)
            BIZ->>Creator: Notify revision requested
        end
    end

    BIZ->>BIZ: All required tiers passed -> Task status = APPROVED
    BIZ->>Creator: Notify Task approved & ready for scheduling/publishing
```

---

## 3. Asynchronous Auto-Publishing via RabbitMQ (`FR 3.8.6`–`FR 3.8.15`)

```mermaid
sequenceDiagram
    participant SCHED as Scheduler (business-service)
    participant BIZ as business-service
    participant MQ as RabbitMQ (brandhub.publishing)
    participant PUB as publisher-service
    participant SOC as Social Platform API (FB / IG / TikTok / Threads)

    SCHED->>BIZ: scheduledAt reached for APPROVED Post (Workspace Timezone normalized)
    BIZ->>BIZ: Build publish payload (caption, S3 media URLs, AES-256 encrypted OAuth token)
    BIZ->>MQ: Publish routingKey="publish.job" -> publisher.job.queue
    BIZ->>BIZ: Update Post status = IN_PROGRESS

    MQ->>PUB: Deliver job from publisher.job.queue
    PUB->>PUB: Decrypt OAuth token (AES-256) in memory
    PUB->>SOC: Execute platform publish (Feed / Story / Reels / TikTok Chunked / Threads)

    alt Publish Success
        SOC-->>PUB: 200 OK { platformPostId, permalink }
        PUB->>MQ: Publish routingKey="publish.callback" { status: DONE, platformPostId, permalink }
    else Transient / Permanent Failure
        SOC-->>PUB: 4xx / 5xx error
        PUB->>PUB: Exponential backoff retry (30s -> 60s -> 120s -> DLQ)
        PUB->>MQ: Publish routingKey="publish.callback" { status: FAIL, errorCode, message }
    end

    MQ->>BIZ: Deliver callback via business.publish_callback.queue
    BIZ->>BIZ: Update Post status (DONE / FAIL) & notify Manager / Creator
```

---

## 4. RS256 Access Token Refresh & Blacklist Rotation (`FR 3.2.2`, `FR 3.2.8`)

```mermaid
sequenceDiagram
    actor User as Authenticated Actor (Owner / Manager / Creator / Client / Admin)
    participant Web as brandhub-web
    participant GW as api-gateway
    participant BIZ as business-service
    participant Redis

    User->>Web: Trigger API request with expired Access Token (15m TTL)
    Web->>GW: Request + Authorization: Bearer {expiredAccessToken}
    GW->>GW: Verify RS256 signature -> ExpiredJwtException
    GW-->>Web: 401 Unauthorized (JWT_EXPIRED)

    Web->>GW: POST /api/v1/auth/refresh (HttpOnly refreshToken cookie)
    GW->>BIZ: Forward (public auth route, no JwtAuthFilter)
    BIZ->>BIZ: Verify RS256 Refresh Token & check user_refresh_tokens (PostgreSQL)
    BIZ->>Redis: Check jwt:blacklist:{old_jti} (must not be revoked)
    BIZ->>Redis: SETEX jwt:blacklist:{old_jti} (revoke old token BEFORE issuing new pair)
    BIZ->>BIZ: Sign new RS256 Access Token + Refresh Token
    BIZ-->>Web: { accessToken, expiresIn } + rotated HttpOnly cookie

    Web->>GW: Retry original request with new Access Token
    GW->>GW: Verify RS256 signature + Redis blacklist check -> valid
    GW->>BIZ: Forward request with X-Request-Id & trace headers
    BIZ->>BIZ: JwtAuthenticationFilter independently verifies JWT & loads current role
    BIZ-->>Web: 200 OK ApiResponse<T>
```

---

## Ghi chú kỹ thuật quan trọng

- **Đặt chỗ AI Credit nguyên tử (Atomic Credit Reservation):** `business-service` kiểm tra `workspace_credit_limits` và khóa tạm số dư trong `ai_credit_reservations` **trước** khi gọi `ai-service`; nếu tiến trình AI báo lỗi hoặc timeout, hệ thống tự động giải phóng/hoàn trả credit mà không làm thất thoát quỹ của `Owner` (`BR-48`, `BR-60`).
- **Quy tắc trả bài khi Reject (`FR 3.6.9`):** Bất kỳ cấp duyệt nào (`QC Creator`, `Manager`, hoặc `Client`) nhấn Reject kèm lý do bắt buộc đều đưa tiến trình về bước đầu tiên cho `Creator` chỉnh sửa, đồng thời giữ nguyên toàn bộ lịch sử nhận xét và các vòng duyệt trước trong `task_approvals` (xem [BA Content & Workflow](../ba/05-content-task-workflow.md)).
- **Giao tiếp xuất bản hai chiều qua RabbitMQ:** Cả chiều giao việc (`publisher.job.queue`) và chiều nhận kết quả (`business.publish_callback.queue`) đều đi qua RabbitMQ durable queues (xem [RabbitMQ Publisher Contract](/view?file=architecture/rabbitmq-publisher-contract.html)).
- **Chống Race Condition khi Refresh Token:** `jti` cũ bắt buộc được đưa vào Redis blacklist **trước** khi ký cặp token mới (xem [RS256 JWT Flow](../api/rs256-jwt-flow.md)).
