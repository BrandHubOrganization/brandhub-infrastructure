import{_ as a,o as i,c as n,a5 as e}from"./chunks/framework.CsGesDJn.js";const c=JSON.parse('{"title":"Sequence Diagrams — 4 Core Flows (V2)","description":"","frontmatter":{},"headers":[],"relativePath":"architecture/sequence-diagrams.md","filePath":"architecture/sequence-diagrams.md"}'),t={name:"architecture/sequence-diagrams.md"};function l(p,s,r,h,E,k){return i(),n("div",null,[...s[0]||(s[0]=[e(`<h1 id="sequence-diagrams-—-4-core-flows-v2" tabindex="-1">Sequence Diagrams — 4 Core Flows (V2) <a class="header-anchor" href="#sequence-diagrams-—-4-core-flows-v2" aria-label="Permalink to &quot;Sequence Diagrams — 4 Core Flows (V2)&quot;">​</a></h1><p>&gt; DA-1157 (DA-E05-06). Mermaid, text-based, committable. Cập nhật theo model V2: Agency→Workspace, Task 3 loại nội dung (Post/Livestream/Survey), Approval Sequence 4 bước (Creator → [QC] → Manager → Client, reject → restart from Creator).</p><h2 id="_1-content-creation-task-→-write-content-→-ai-generate" tabindex="-1">1. Content Creation (Task → Write Content → AI Generate) <a class="header-anchor" href="#_1-content-creation-task-→-write-content-→-ai-generate" aria-label="Permalink to &quot;1. Content Creation (Task → Write Content → AI Generate)&quot;">​</a></h2><div class="language-mermaid vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">mermaid</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">sequenceDiagram</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    actor Creator</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant WD as Web Dashboard</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant GW as api-gateway</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant BIZ as business-service</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant AI as ai-service</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant S3 as AWS S3</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Creator-&gt;&gt;WD: Open assigned Task (Post-type)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    WD-&gt;&gt;GW: GET /api/v1/tasks/{taskId}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW-&gt;&gt;BIZ: forward (JWT verified)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: RequireRoleAspect: MemberRole=CREATOR in this Workspace</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ--&gt;&gt;WD: Task detail (backlog → assigned, from Campaign or Content Request)</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Creator-&gt;&gt;WD: Write content (vector-text editor)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    WD-&gt;&gt;GW: PUT /api/v1/tasks/{taskId}/content</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW-&gt;&gt;BIZ: forward</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: save content_versions (MongoDB), auto font-convert</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Creator-&gt;&gt;WD: Request AI-generated image</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    WD-&gt;&gt;GW: POST /api/v1/tasks/{taskId}/ai/image</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW-&gt;&gt;BIZ: forward</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: check ai_credit_creator_limits (PostgreSQL) — block if exceeded</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;AI: POST /internal/ai/image (X-Internal-Api-Key)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    AI-&gt;&gt;AI: build prompt (form + ambassador + materials)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    AI-&gt;&gt;S3: store generated image</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    AI--&gt;&gt;BIZ: { generatedUrl, creditCost }</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: deduct ai_credit_ledgers, write ai_usage_logs (via ai-service)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ--&gt;&gt;WD: draft saved with AI image attached</span></span></code></pre></div><h2 id="_2-approval-workflow-4-step-task-approval-sequence" tabindex="-1">2. Approval Workflow (4-step Task Approval Sequence) <a class="header-anchor" href="#_2-approval-workflow-4-step-task-approval-sequence" aria-label="Permalink to &quot;2. Approval Workflow (4-step Task Approval Sequence)&quot;">​</a></h2><div class="language-mermaid vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">mermaid</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">sequenceDiagram</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    actor Creator</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    actor QC as QC Creator (optional)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    actor Manager</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    actor Client</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant BIZ as business-service</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Creator-&gt;&gt;BIZ: Submit Task for review</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: task_approvals: step=CREATOR, status=SUBMITTED</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    alt QC assigned at Assign Task step</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        BIZ-&gt;&gt;QC: notify review pending</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        QC-&gt;&gt;BIZ: Approve / Reject</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        alt QC rejects</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            BIZ-&gt;&gt;BIZ: task_approvals: reset to CREATOR step</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            BIZ-&gt;&gt;Creator: notify — restart from Creator (not from QC step)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        end</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    end</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;Manager: notify review pending</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Manager-&gt;&gt;BIZ: Approve / Reject</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    alt Manager rejects</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        BIZ-&gt;&gt;BIZ: task_approvals: reset to CREATOR step</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        BIZ-&gt;&gt;Creator: notify — restart from Creator</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    end</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    opt Task requires Client approval</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        BIZ-&gt;&gt;Client: notify review pending</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        Client-&gt;&gt;BIZ: Approve / Reject</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        alt Client rejects</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            BIZ-&gt;&gt;BIZ: task_approvals: reset to CREATOR step</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            BIZ-&gt;&gt;Creator: notify — restart from Creator</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        end</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    end</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: all steps passed → Task status = DONE</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;Creator: notify Task complete</span></span></code></pre></div><h2 id="_3-auto-publishing-scheduled-post-→-social-platform" tabindex="-1">3. Auto-Publishing (scheduled Post → Social Platform) <a class="header-anchor" href="#_3-auto-publishing-scheduled-post-→-social-platform" aria-label="Permalink to &quot;3. Auto-Publishing (scheduled Post → Social Platform)&quot;">​</a></h2><div class="language-mermaid vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">mermaid</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">sequenceDiagram</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant SCHED as Scheduler (business-service)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant BIZ as business-service</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant MQ as RabbitMQ (brandhub.publishing)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant PUB as publisher-service</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant FB as Facebook Graph API</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    SCHED-&gt;&gt;BIZ: scheduledAt reached for Post (status=DONE, approved)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: build publish job payload (content, mediaUrls, encrypted OAuth token)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;MQ: publish &quot;publish.job&quot; (exchange=brandhub.publishing, routing=publish.job)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: Post status = IN_PROGRESS</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    MQ-&gt;&gt;PUB: deliver publisher.job.queue</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    PUB-&gt;&gt;PUB: decrypt OAuth token (AES-256)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    PUB-&gt;&gt;FB: POST /graph/{page}/feed (or /stories, /reels per content type)</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    alt Success</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        FB--&gt;&gt;PUB: 200 { post_id }</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        PUB-&gt;&gt;MQ: publish &quot;publish.callback&quot; { status: SUCCESS, platformPostId }</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    else Failure</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        FB--&gt;&gt;PUB: 4xx/5xx error</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        PUB-&gt;&gt;PUB: retry 30s → 60s → 120s → DLQ if all fail</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        PUB-&gt;&gt;MQ: publish &quot;publish.callback&quot; { status: FAILED, error }</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    end</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    MQ-&gt;&gt;BIZ: deliver business.publish_callback.queue</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: update Post status (DONE/FAIL), notify Manager/Client</span></span></code></pre></div><h2 id="_4-oauth-token-refresh" tabindex="-1">4. OAuth Token Refresh <a class="header-anchor" href="#_4-oauth-token-refresh" aria-label="Permalink to &quot;4. OAuth Token Refresh&quot;">​</a></h2><div class="language-mermaid vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">mermaid</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">sequenceDiagram</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    actor User</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant WD as Web Dashboard</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant GW as api-gateway</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant BIZ as business-service</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant Redis</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    User-&gt;&gt;WD: API call with expired access token</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    WD-&gt;&gt;GW: request + Authorization: Bearer {expired}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW-&gt;&gt;GW: verify signature — expired, return 401</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW--&gt;&gt;WD: 401 Unauthorized</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    WD-&gt;&gt;GW: POST /api/v1/auth/refresh (refresh token cookie)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW-&gt;&gt;BIZ: forward (auth-public route, no JWT filter)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: validate refresh token (user_refresh_tokens, PostgreSQL)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;Redis: check jwt:blacklist:{old_jti} — must NOT be blacklisted yet</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;Redis: SET jwt:blacklist:{old_jti} (invalidate old access token FIRST)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: issue new access token (new jti)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ--&gt;&gt;WD: { accessToken, expiresIn }</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    WD-&gt;&gt;GW: retry original request with new token</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW-&gt;&gt;GW: verify new signature — valid</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW-&gt;&gt;BIZ: forward (X-User-Id, X-User-Role, X-Workspace-Id injected — log only)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: JwtAuthenticationFilter re-parses JWT independently</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ--&gt;&gt;WD: original response</span></span></code></pre></div><h2 id="ghi-chu-ky-thuat" tabindex="-1">Ghi chú kỹ thuật <a class="header-anchor" href="#ghi-chu-ky-thuat" aria-label="Permalink to &quot;Ghi chú kỹ thuật&quot;">​</a></h2><ul><li><strong>Content creation &amp; AI generate:</strong> credit check xảy ra ở business-service TRƯỚC khi gọi ai-service — tránh gọi AI tốn tiền rồi mới phát hiện vượt hạn mức.</li><li><strong>Approval Sequence:</strong> reject ở BẤT KỲ bước nào (QC/Manager/Client) đều quay về bước Creator đầu tiên, không quay lại bước ngay trước đó — đã confirm trong <code>docs/ba/05-content-task-workflow.md</code> §4.</li><li><strong>Auto-publishing:</strong> publisher-service không bao giờ có DB access — toàn bộ payload đóng gói sẵn trong RabbitMQ message bởi business-service.</li><li><strong>OAuth refresh:</strong> old <code>jti</code> phải bị blacklist TRƯỚC khi issue token mới (không phải sau) — tránh race condition dùng cả 2 token cùng lúc.</li></ul>`,12)])])}const o=a(t,[["render",l]]);export{c as __pageData,o as default};
