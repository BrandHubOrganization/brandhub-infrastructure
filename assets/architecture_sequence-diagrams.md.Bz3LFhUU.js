import{_ as a,o as i,c as n,a5 as e}from"./chunks/framework.BfQ7H7Qx.js";const o=JSON.parse('{"title":"Sequence Diagrams — 4 Core Flows","description":"","frontmatter":{},"headers":[],"relativePath":"architecture/sequence-diagrams.md","filePath":"architecture/sequence-diagrams.md"}'),t={name:"architecture/sequence-diagrams.md"};function l(p,s,r,h,c,E){return i(),n("div",null,[...s[0]||(s[0]=[e(`<h1 id="sequence-diagrams-—-4-core-flows" tabindex="-1">Sequence Diagrams — 4 Core Flows <a class="header-anchor" href="#sequence-diagrams-—-4-core-flows" aria-label="Permalink to &quot;Sequence Diagrams — 4 Core Flows&quot;">​</a></h1><p>&gt; Navigation: <a href="./../">← Knowledge Base Hub</a> · <a href="./README.html">← Architecture Index</a> · <a href="./service-boundaries.html">Service Boundaries</a> · <a href="./../api/rs256-jwt-flow.html">RS256 JWT Flow</a> &gt; &gt; Sơ đồ trình tự chuẩn cho 4 luồng cốt lõi của hệ thống BrandHub theo mô hình <code>Agency → Workspace → Media Package → Media Campaign → Task → Post</code> và quy trình phê duyệt 3 tầng (<code>Creator -&gt; Manager -&gt; Client</code>).</p><hr><h2 id="_1-content-creation-atomic-ai-credit-reservation-fr-3-6-10-fr-3-7-9-fr-3-9-4" tabindex="-1">1. Content Creation &amp; Atomic AI Credit Reservation (<code>FR 3.6.10</code>, <code>FR 3.7.9</code>, <code>FR 3.9.4</code>) <a class="header-anchor" href="#_1-content-creation-atomic-ai-credit-reservation-fr-3-6-10-fr-3-7-9-fr-3-9-4" aria-label="Permalink to &quot;1. Content Creation &amp; Atomic AI Credit Reservation (\`FR 3.6.10\`, \`FR 3.7.9\`, \`FR 3.9.4\`)&quot;">​</a></h2><div class="language-mermaid vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">mermaid</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">sequenceDiagram</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    actor Creator</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant Web as brandhub-web</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant GW as api-gateway</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant BIZ as business-service</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant AI as ai-service</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant S3 as AWS S3</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Creator-&gt;&gt;Web: Open assigned Task (Post / Short Video / Survey)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Web-&gt;&gt;GW: GET /api/v1/workspaces/{workspaceId}/tasks/{taskId}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW-&gt;&gt;BIZ: forward (RS256 JWT verified)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: Verify Workspace MemberRole = CREATOR</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ--&gt;&gt;Web: Task detail &amp; brief</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Creator-&gt;&gt;Web: Author content with Unicode font styler (FR 3.6.10)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Web-&gt;&gt;GW: PUT /api/v1/workspaces/{workspaceId}/tasks/{taskId}/content</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW-&gt;&gt;BIZ: forward</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: Save version snapshot in MongoDB, return updated draft</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Creator-&gt;&gt;Web: Request AI Image Generation (FR 3.7.9)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Web-&gt;&gt;GW: POST /api/v1/workspaces/{workspaceId}/ai/image</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW-&gt;&gt;BIZ: forward</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: Check workspace_credit_limits &amp; reserve in ai_credit_reservations (PostgreSQL ACID)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;AI: POST /api/v1/ai/image/generate (X-Internal-Key)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    AI-&gt;&gt;AI: Assemble prompt (Brief + Style Preset + Virtual Ambassador + Material refs)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    AI-&gt;&gt;S3: Upload generated image asset</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    AI--&gt;&gt;BIZ: ApiResponse { generatedUrl, creditCost }</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: Commit credit_operations &amp; credit_entries against agency_credit_wallets</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ--&gt;&gt;Web: Return generated asset URL &amp; updated credit balance</span></span></code></pre></div><hr><h2 id="_2-three-tier-approval-sequence-creator-manager-client-fr-3-6-9" tabindex="-1">2. Three-Tier Approval Sequence (<code>Creator -&gt; Manager -&gt; Client</code>, <code>FR 3.6.9</code>) <a class="header-anchor" href="#_2-three-tier-approval-sequence-creator-manager-client-fr-3-6-9" aria-label="Permalink to &quot;2. Three-Tier Approval Sequence (\`Creator -&gt; Manager -&gt; Client\`, \`FR 3.6.9\`)&quot;">​</a></h2><div class="language-mermaid vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">mermaid</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">sequenceDiagram</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    actor Creator</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    actor QC as QC Creator (optional)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    actor Manager</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    actor Client</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant BIZ as business-service</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Creator-&gt;&gt;BIZ: Submit Task deliverable for review</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: Record task_approvals (step=CREATOR, status=SUBMITTED)</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    opt Internal QC Creator assigned on Task (FR 3.6.2)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        BIZ-&gt;&gt;QC: Notify internal QC review pending</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        QC-&gt;&gt;BIZ: Approve / Reject (reason required on reject)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        alt QC rejects</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            BIZ-&gt;&gt;BIZ: Reset current workflow step to CREATOR (preserve prior approval history)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            BIZ-&gt;&gt;Creator: Notify revision requested</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        end</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    end</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;Manager: Notify Manager review pending</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Manager-&gt;&gt;BIZ: Approve / Reject</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    alt Manager rejects</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        BIZ-&gt;&gt;BIZ: Reset workflow to CREATOR step (keep append-only round history)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        BIZ-&gt;&gt;Creator: Notify revision requested</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    end</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    opt Task requires Client sign-off</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        BIZ-&gt;&gt;Client: Notify Client review pending</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        Client-&gt;&gt;BIZ: Approve / Reject</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        alt Client rejects</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            BIZ-&gt;&gt;BIZ: Reset workflow to CREATOR step (keep append-only round history)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">            BIZ-&gt;&gt;Creator: Notify revision requested</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        end</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    end</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: All required tiers passed -&gt; Task status = APPROVED</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;Creator: Notify Task approved &amp; ready for scheduling/publishing</span></span></code></pre></div><hr><h2 id="_3-asynchronous-auto-publishing-via-rabbitmq-fr-3-8-6–fr-3-8-15" tabindex="-1">3. Asynchronous Auto-Publishing via RabbitMQ (<code>FR 3.8.6</code>–<code>FR 3.8.15</code>) <a class="header-anchor" href="#_3-asynchronous-auto-publishing-via-rabbitmq-fr-3-8-6–fr-3-8-15" aria-label="Permalink to &quot;3. Asynchronous Auto-Publishing via RabbitMQ (\`FR 3.8.6\`–\`FR 3.8.15\`)&quot;">​</a></h2><div class="language-mermaid vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">mermaid</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">sequenceDiagram</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant SCHED as Scheduler (business-service)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant BIZ as business-service</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant MQ as RabbitMQ (brandhub.publishing)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant PUB as publisher-service</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant SOC as Social Platform API (FB / IG / TikTok / Threads)</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    SCHED-&gt;&gt;BIZ: scheduledAt reached for APPROVED Post (Workspace Timezone normalized)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: Build publish payload (caption, S3 media URLs, AES-256 encrypted OAuth token)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;MQ: Publish routingKey=&quot;publish.job&quot; -&gt; publisher.job.queue</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: Update Post status = IN_PROGRESS</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    MQ-&gt;&gt;PUB: Deliver job from publisher.job.queue</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    PUB-&gt;&gt;PUB: Decrypt OAuth token (AES-256) in memory</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    PUB-&gt;&gt;SOC: Execute platform publish (Feed / Story / Reels / TikTok Chunked / Threads)</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    alt Publish Success</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        SOC--&gt;&gt;PUB: 200 OK { platformPostId, permalink }</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        PUB-&gt;&gt;MQ: Publish routingKey=&quot;publish.callback&quot; { status: DONE, platformPostId, permalink }</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    else Transient / Permanent Failure</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        SOC--&gt;&gt;PUB: 4xx / 5xx error</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        PUB-&gt;&gt;PUB: Exponential backoff retry (30s -&gt; 60s -&gt; 120s -&gt; DLQ)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">        PUB-&gt;&gt;MQ: Publish routingKey=&quot;publish.callback&quot; { status: FAIL, errorCode, message }</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    end</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    MQ-&gt;&gt;BIZ: Deliver callback via business.publish_callback.queue</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: Update Post status (DONE / FAIL) &amp; notify Manager / Creator</span></span></code></pre></div><hr><h2 id="_4-rs256-access-token-refresh-blacklist-rotation-fr-3-2-2-fr-3-2-8" tabindex="-1">4. RS256 Access Token Refresh &amp; Blacklist Rotation (<code>FR 3.2.2</code>, <code>FR 3.2.8</code>) <a class="header-anchor" href="#_4-rs256-access-token-refresh-blacklist-rotation-fr-3-2-2-fr-3-2-8" aria-label="Permalink to &quot;4. RS256 Access Token Refresh &amp; Blacklist Rotation (\`FR 3.2.2\`, \`FR 3.2.8\`)&quot;">​</a></h2><div class="language-mermaid vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">mermaid</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">sequenceDiagram</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    actor User as Authenticated Actor (Owner / Manager / Creator / Client / Admin)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant Web as brandhub-web</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant GW as api-gateway</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant BIZ as business-service</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    participant Redis</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    User-&gt;&gt;Web: Trigger API request with expired Access Token (15m TTL)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Web-&gt;&gt;GW: Request + Authorization: Bearer {expiredAccessToken}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW-&gt;&gt;GW: Verify RS256 signature -&gt; ExpiredJwtException</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW--&gt;&gt;Web: 401 Unauthorized (JWT_EXPIRED)</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Web-&gt;&gt;GW: POST /api/v1/auth/refresh (HttpOnly refreshToken cookie)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW-&gt;&gt;BIZ: Forward (public auth route, no JwtAuthFilter)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: Verify RS256 Refresh Token &amp; check user_refresh_tokens (PostgreSQL)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;Redis: Check jwt:blacklist:{old_jti} (must not be revoked)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;Redis: SETEX jwt:blacklist:{old_jti} (revoke old token BEFORE issuing new pair)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: Sign new RS256 Access Token + Refresh Token</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ--&gt;&gt;Web: { accessToken, expiresIn } + rotated HttpOnly cookie</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    Web-&gt;&gt;GW: Retry original request with new Access Token</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW-&gt;&gt;GW: Verify RS256 signature + Redis blacklist check -&gt; valid</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    GW-&gt;&gt;BIZ: Forward request with X-Request-Id &amp; trace headers</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ-&gt;&gt;BIZ: JwtAuthenticationFilter independently verifies JWT &amp; loads current role</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">    BIZ--&gt;&gt;Web: 200 OK ApiResponse&lt;T&gt;</span></span></code></pre></div><hr><h2 id="ghi-chu-ky-thuat-quan-trong" tabindex="-1">Ghi chú kỹ thuật quan trọng <a class="header-anchor" href="#ghi-chu-ky-thuat-quan-trong" aria-label="Permalink to &quot;Ghi chú kỹ thuật quan trọng&quot;">​</a></h2><ul><li><strong>Đặt chỗ AI Credit nguyên tử (Atomic Credit Reservation):</strong> <code>business-service</code> kiểm tra <code>workspace_credit_limits</code> và khóa tạm số dư trong <code>ai_credit_reservations</code> <strong>trước</strong> khi gọi <code>ai-service</code>; nếu tiến trình AI báo lỗi hoặc timeout, hệ thống tự động giải phóng/hoàn trả credit mà không làm thất thoát quỹ của <code>Owner</code> (<code>BR-48</code>, <code>BR-60</code>).</li><li><strong>Quy tắc trả bài khi Reject (<code>FR 3.6.9</code>):</strong> Bất kỳ cấp duyệt nào (<code>QC Creator</code>, <code>Manager</code>, hoặc <code>Client</code>) nhấn Reject kèm lý do bắt buộc đều đưa tiến trình về bước đầu tiên cho <code>Creator</code> chỉnh sửa, đồng thời giữ nguyên toàn bộ lịch sử nhận xét và các vòng duyệt trước trong <code>task_approvals</code> (xem <a href="./../ba/05-content-task-workflow.html">BA Content &amp; Workflow</a>).</li><li><strong>Giao tiếp xuất bản hai chiều qua RabbitMQ:</strong> Cả chiều giao việc (<code>publisher.job.queue</code>) và chiều nhận kết quả (<code>business.publish_callback.queue</code>) đều đi qua RabbitMQ durable queues (xem <a href="/brandhub-infrastructure/view.html?file=architecture/rabbitmq-publisher-contract.html">RabbitMQ Publisher Contract</a>).</li><li><strong>Chống Race Condition khi Refresh Token:</strong> <code>jti</code> cũ bắt buộc được đưa vào Redis blacklist <strong>trước</strong> khi ký cặp token mới (xem <a href="./../api/rs256-jwt-flow.html">RS256 JWT Flow</a>).</li></ul>`,17)])])}const g=a(t,[["render",l]]);export{o as __pageData,g as default};
