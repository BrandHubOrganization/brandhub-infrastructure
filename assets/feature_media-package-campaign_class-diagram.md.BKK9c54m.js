import{_ as a,o as n,c as i,a5 as e}from"./chunks/framework.CsGesDJn.js";const r=JSON.parse('{"title":"Class diagram — FR 3.5 Media Package & Campaign","description":"","frontmatter":{},"headers":[],"relativePath":"feature/media-package-campaign/class-diagram.md","filePath":"feature/media-package-campaign/class-diagram.md"}'),t={name:"feature/media-package-campaign/class-diagram.md"};function p(l,s,E,h,k,c){return n(),i("div",null,[...s[0]||(s[0]=[e(`<h1 id="class-diagram-—-fr-3-5-media-package-campaign" tabindex="-1">Class diagram — FR 3.5 Media Package &amp; Campaign <a class="header-anchor" href="#class-diagram-—-fr-3-5-media-package-campaign" aria-label="Permalink to &quot;Class diagram — FR 3.5 Media Package &amp; Campaign&quot;">​</a></h1><p>Sơ đồ lớp miền nghiệp vụ cho FR 3.5.1–3.5.10, theo baseline và quyết định ngày 2026-10-08. Các phương thức biểu diễn hành vi nghiệp vụ, không khẳng định tên method đã tồn tại trong code. Các lớp <code>ValueObject</code> biểu diễn dữ liệu nhúng; không phải bảng riêng. Quan hệ tới MongoDB là tham chiếu logic, không phải SQL FK.</p><p>Nguồn: <a href="./README.html">baseline</a>, <a href="./offering-models/spec.html">Package offering</a>, <a href="./phase-1-design/plan.html">Campaign contract</a> và spec/plan của từng FR trong thư mục này. Campaign version, feedback, deployment và Task Mongo bên dưới là thiết kế mục tiêu; giai đoạn 1 mới hoàn thành thiết kế, chưa đồng nghĩa đã triển khai.</p><h2 id="_1-tong-quan-fr-3-5" tabindex="-1">1. Tổng quan FR 3.5 <a class="header-anchor" href="#_1-tong-quan-fr-3-5" aria-label="Permalink to &quot;1. Tổng quan FR 3.5&quot;">​</a></h2><div class="language-mermaid vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">mermaid</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">classDiagram</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">direction LR</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class Agency</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class Workspace</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class MediaPackage</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class WorkspaceMediaPackage</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class MediaCampaign</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class CampaignWorkItem</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class ContentRequest</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class Task</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Agency &quot;1&quot; --&gt; &quot;0..*&quot; Workspace : quản lý</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Agency &quot;0..1&quot; --&gt; &quot;0..*&quot; MediaPackage : sở hữu catalogue</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Workspace &quot;1&quot; --&gt; &quot;0..1&quot; WorkspaceMediaPackage : chọn và thương lượng</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MediaPackage &quot;1&quot; &lt;-- &quot;0..*&quot; WorkspaceMediaPackage : packageId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">WorkspaceMediaPackage &quot;1&quot; --&gt; &quot;0..1&quot; MediaCampaign : nguồn đã APPROVED</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MediaCampaign &quot;1&quot; *-- &quot;0..*&quot; CampaignWorkItem : workItems</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">CampaignWorkItem &quot;0..1&quot; --&gt; &quot;0..1&quot; Task : sinh khi deploy</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Workspace &quot;1&quot; --&gt; &quot;0..*&quot; ContentRequest : yêu cầu độc lập</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">ContentRequest &quot;0..1&quot; --&gt; &quot;0..1&quot; Task : sinh khi ACCEPTED</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Workspace &quot;1&quot; --&gt; &quot;0..*&quot; Task : chứa</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">note for MediaPackage &quot;Global template: isTemplate=true, agencyId=null.\\nAgency package: isTemplate=false, agencyId bắt buộc.&quot;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">note for MediaCampaign &quot;Tối đa một Campaign/Workspace, kể cả COMPLETED.\\nKhông dùng mô hình nhiều Campaign theo tháng của prototype cũ.&quot;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">note for Task &quot;Task từ Campaign hoặc Content Request có nguồn loại trừ nhau.\\nTask từ Content Request có campaignId=null.&quot;</span></span></code></pre></div><h2 id="_2-package-catalogue-thuong-luong-va-duyet-—-fr-3-5-1–3-5-4" tabindex="-1">2. Package catalogue, thương lượng và duyệt — FR 3.5.1–3.5.4 <a class="header-anchor" href="#_2-package-catalogue-thuong-luong-va-duyet-—-fr-3-5-1–3-5-4" aria-label="Permalink to &quot;2. Package catalogue, thương lượng và duyệt — FR 3.5.1–3.5.4&quot;">​</a></h2><div class="language-mermaid vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">mermaid</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">classDiagram</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">direction LR</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class MediaPackage {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;PostgreSQL&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID id</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID agencyId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Boolean isTemplate</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID sourceTemplateId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String name</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String type</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Boolean isAvailableToWorkspaces</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +create()</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +cloneFrom(source)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +setAvailability(available)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class PackageTerms {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;ValueObject&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Integer durationWeeks</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Decimal budgetAmount</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String scopeDescription</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String quantityBasis</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String offeringModel</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Integer maxChanges</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class PackageDeliverable {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;ValueObject&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID id</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +ServiceType serviceType</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String name</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Integer quantity</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String unit</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String description</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String acceptanceCriteria</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class ServiceType {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;enumeration&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  SOCIAL_POST</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  EVENT_PLANNING</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  LIVESTREAM_PREPARATION</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  PRESS_RECOMMENDATION</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  WORKSHOP_SUPPORT</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class WorkspaceMediaPackage {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;PostgreSQL&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID id</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID workspaceId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID packageId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String status</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Integer termsVersion</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Integer clientProposalCount</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +select(package)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +replaceBeforeNegotiation(package)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +requestChange(terms, expectedVersion)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +counterOffer(terms, expectedVersion)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +approve(actor, expectedVersion)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class PackageNegotiationEvent {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;PostgreSQL&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID id</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID workspaceMediaPackageId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Integer termsVersion</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID actorId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String action</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String note</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +DateTime createdAt</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class PackageApproval {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;LogicalValueObject&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String side</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID actorId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Integer termsVersion</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +DateTime approvedAt</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MediaPackage &quot;1&quot; *-- &quot;1&quot; PackageTerms : catalogue terms</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MediaPackage &quot;0..*&quot; --&gt; &quot;0..1&quot; MediaPackage : sourceTemplateId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">WorkspaceMediaPackage &quot;0..*&quot; --&gt; &quot;1&quot; MediaPackage : packageId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">WorkspaceMediaPackage &quot;1&quot; *-- &quot;1&quot; PackageTerms : finalTerms snapshot</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">PackageTerms &quot;1&quot; *-- &quot;0..*&quot; PackageDeliverable : deliverables</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">PackageDeliverable --&gt; ServiceType</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">WorkspaceMediaPackage &quot;1&quot; *-- &quot;0..*&quot; PackageNegotiationEvent : append-only history</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">PackageNegotiationEvent &quot;1&quot; *-- &quot;1&quot; PackageTerms : terms snapshot</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">WorkspaceMediaPackage &quot;1&quot; *-- &quot;0..2&quot; PackageApproval : Agency và Client</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">note for PackageTerms &quot;quantityBasis=TOTAL cho gói mới.\\nofferingModel giữ để đọc legacy, không quyết định luồng Campaign mới.\\nKhông tự chuyển đổi snapshot RETAINER đã chốt.&quot;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">note for WorkspaceMediaPackage &quot;workspaceId UNIQUE. Chỉ chọn gói khả dụng của cùng Agency.\\nĐổi terms tăng termsVersion và vô hiệu cả hai approval.\\nAPPROVED khi hai phía duyệt cùng phiên bản hiện tại.&quot;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">note for PackageApproval &quot;Nhóm dữ liệu duyệt logic trên agreement; không đề xuất bảng mới.&quot;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">note for PackageNegotiationEvent &quot;action: REQUEST_CHANGE hoặc COUNTER_OFFER.\\nLưu terms trước và sau thay đổi để so sánh; lịch sử bất biến.&quot;</span></span></code></pre></div><p><code>maxChanges</code> giới hạn số đề xuất hợp lệ của Client cho toàn gói; counter-offer của Agency không tiêu hao hạn mức. Client không được đổi offering model, service type, unit hoặc maxChanges. Snapshot tách biệt catalogue nên sửa catalogue không sửa agreement.</p><h2 id="_3-campaign-phien-ban-va-trien-khai-—-fr-3-5-5–3-5-6" tabindex="-1">3. Campaign, phiên bản và triển khai — FR 3.5.5–3.5.6 <a class="header-anchor" href="#_3-campaign-phien-ban-va-trien-khai-—-fr-3-5-5–3-5-6" aria-label="Permalink to &quot;3. Campaign, phiên bản và triển khai — FR 3.5.5–3.5.6&quot;">​</a></h2><div class="language-mermaid vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">mermaid</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">classDiagram</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">direction LR</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class WorkspaceMediaPackage</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class PackageTerms</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class MediaCampaign {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;PostgreSQL_Target&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID id</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID workspaceMediaPackageId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String name</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String strategyDetail</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String brandGuideline</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Integer packageTermsVersion</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Integer contentVersion</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Integer rowVersion</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +CampaignStatus status</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +DateTime completedAt</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID completedBy</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String completionReason</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +JSON completionTaskSummary</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +createFromApprovedPackage()</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +updatePlan(expectedVersion)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +approve(actor, expectedVersion)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +deploy(expectedVersion, idempotencyKey)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +complete(reason)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class CampaignStatus {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;enumeration&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  DRAFT</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  APPROVED</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  IN_PROGRESS</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  COMPLETED</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class CampaignTimeline {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;ValueObject&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Date startDate</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Date endDate</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +JSON milestones</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class CampaignDeliverable {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;ValueObject&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID id</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Integer quantity</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class CampaignWorkItem {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;ValueObject&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID id</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID deliverableId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String name</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +TaskType type</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +DateTime dueDate</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class CampaignVersion {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;ProposedAudit&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID campaignId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Integer contentVersion</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +JSON contentSnapshot</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class CampaignApproval {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;ProposedAudit&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID campaignId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String side</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID actorId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Integer contentVersion</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +DateTime approvedAt</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class CampaignFeedback {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;PostgreSQL_Target&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID id</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID campaignId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Integer contentVersion</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID actorId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String comment</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +DateTime createdAt</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class CampaignDeployment {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;ProposedOutbox&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID id</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID campaignId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Integer contentVersion</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String retryState</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +deployInsertOnly()</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +retry()</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class Task {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;MongoDB_Target&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID id</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID workspaceId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID campaignId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID campaignWorkItemId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String status</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">WorkspaceMediaPackage &quot;1&quot; --&gt; &quot;0..1&quot; MediaCampaign : approved source</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MediaCampaign --&gt; CampaignStatus</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MediaCampaign &quot;1&quot; *-- &quot;1&quot; PackageTerms : immutable packageTermsSnapshot</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MediaCampaign &quot;1&quot; *-- &quot;0..1&quot; CampaignTimeline : timeline</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MediaCampaign &quot;1&quot; *-- &quot;0..*&quot; CampaignDeliverable : deliverablePlan</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MediaCampaign &quot;1&quot; *-- &quot;0..*&quot; CampaignWorkItem : workItems</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">CampaignWorkItem &quot;0..*&quot; --&gt; &quot;1&quot; CampaignDeliverable : deliverableId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MediaCampaign &quot;1&quot; *-- &quot;1..*&quot; CampaignVersion : immutable versions</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MediaCampaign &quot;1&quot; *-- &quot;0..*&quot; CampaignApproval : approval audit</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MediaCampaign &quot;1&quot; *-- &quot;0..*&quot; CampaignFeedback : append-only</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">MediaCampaign &quot;1&quot; --&gt; &quot;0..*&quot; CampaignDeployment : durable deployment history</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">CampaignDeployment ..&gt; CampaignWorkItem : approved snapshot</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">CampaignDeployment ..&gt; Task : insert-only upsert</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">CampaignWorkItem &quot;0..1&quot; --&gt; &quot;0..1&quot; Task : unique generation source</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">note for MediaCampaign &quot;workspaceMediaPackageId UNIQUE và immutable.\\nSửa nội dung tăng contentVersion, reset cả hai approval.\\nDuyệt một phía vẫn DRAFT; hai phía cùng version mới APPROVED.&quot;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">note for CampaignDeliverable &quot;Tổng sản lượng cả gói; không đếm work item để tính sản lượng.\\nMột deliverable có thể cần nhiều bước thực hiện.&quot;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">note for CampaignDeployment &quot;Schema chi tiết còn ở mức đề xuất của phase 1.\\nChỉ đổi Campaign thành IN_PROGRESS sau khi đủ Task được ghi bền vững.&quot;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">note for Task &quot;UNIQUE logic (campaignId, campaignWorkItemId).\\nTask mới: backlog, chưa có assignee/QC; retry không reset Task.&quot;</span></span></code></pre></div><p>Khi đã duyệt đủ hai phía, nội dung Campaign bất biến. Feedback không tăng <code>contentVersion</code>; <code>rowVersion</code> phục vụ optimistic locking, tách khỏi phiên bản nội dung. Manager có thể complete khi còn Task chưa hoàn thành nhưng phải ghi lý do; lưu thống kê tại thời điểm complete và giữ nguyên workflow của các Task con.</p><h2 id="_4-content-request-va-task-—-fr-3-5-7–3-5-10" tabindex="-1">4. Content Request và Task — FR 3.5.7–3.5.10 <a class="header-anchor" href="#_4-content-request-va-task-—-fr-3-5-7–3-5-10" aria-label="Permalink to &quot;4. Content Request và Task — FR 3.5.7–3.5.10&quot;">​</a></h2><div class="language-mermaid vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">mermaid</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">classDiagram</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">direction LR</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class Workspace</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class ContentRequest {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;MongoDB&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID id</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID workspaceId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID createdBy</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String title</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String description</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +TaskType type</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +DateTime dueDate</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +ContentRequestStatus status</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +DateTime createdAt</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +DateTime updatedAt</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +create()</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +updateWhilePending(actor)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +startProcessing(manager)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +accept(manager)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +deny(manager)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +cancelWhilePending(actor)</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class ContentRequestStatus {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;enumeration&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  PENDING</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  IN_PROGRESS</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  ACCEPTED</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  DENIED</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  CANCELLED</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class Task {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;MongoDB_Target&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID id</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID workspaceId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID campaignId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID campaignWorkItemId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +TaskType type</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String name</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String description</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +DateTime dueDate</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String status</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID assigneeId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID qcAssigneeId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +Boolean requiresClientApproval</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +String sourceType</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +UUID sourceRefId</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  +JSON typeMetadata</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">class TaskType {</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  &lt;&lt;enumeration&gt;&gt;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  POST</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  LIVESTREAM</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  SURVEY</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  EVENT_PLAN</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">  PRESS_RECOMMENDATION</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">}</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Workspace &quot;1&quot; --&gt; &quot;0..*&quot; ContentRequest</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Workspace &quot;1&quot; --&gt; &quot;0..*&quot; Task</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">ContentRequest --&gt; ContentRequestStatus</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">ContentRequest --&gt; TaskType : chỉ POST, LIVESTREAM, SURVEY</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">Task --&gt; TaskType</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">ContentRequest &quot;0..1&quot; --&gt; &quot;0..1&quot; Task : accept sinh một Task</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">note for ContentRequest &quot;Client tạo; chỉ người tạo sửa/hủy khi PENDING.\\nManager: PENDING sang IN_PROGRESS; PENDING/IN_PROGRESS sang ACCEPTED hoặc DENIED.\\nACCEPTED, DENIED, CANCELLED là trạng thái cuối.&quot;</span></span>
<span class="line"><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">note for Task &quot;Request được accept: copy type/dueDate, status=backlog, campaignId=null.\\nsourceType=CONTENT_REQUEST; sourceRefId=request.id.\\nUnique (sourceType, sourceRefId) cho nguồn Content Request.&quot;</span></span></code></pre></div><p>Accept thành công phải bảo đảm đúng một Task, kể cả gọi lặp hoặc đồng thời. Cancel lưu trạng thái <code>CANCELLED</code> thay vì xóa cứng theo baseline V2 (thay thế mô tả xóa ở BA cũ). Hai loại Task mới <code>EVENT_PLAN</code> và <code>PRESS_RECOMMENDATION</code> thuộc thiết kế Campaign/E51; không tự mở rộng loại được chọn trong Content Request.</p><h2 id="_5-đoi-chieu-yeu-cau" tabindex="-1">5. Đối chiếu yêu cầu <a class="header-anchor" href="#_5-đoi-chieu-yeu-cau" aria-label="Permalink to &quot;5. Đối chiếu yêu cầu&quot;">​</a></h2><table tabindex="0"><thead><tr><th>FR</th><th>Lớp/hành vi chính</th></tr></thead><tbody><tr><td>3.5.1 Create Media Package</td><td>MediaPackage, PackageTerms, PackageDeliverable; create/clone/availability và selection</td></tr><tr><td>3.5.2 View Media Package</td><td>Đọc catalogue và WorkspaceMediaPackage với snapshot hiện tại</td></tr><tr><td>3.5.3 Request Media Package</td><td>requestChange/counterOffer, PackageNegotiationEvent</td></tr><tr><td>3.5.4 Approve Media Package</td><td>PackageApproval gắn termsVersion</td></tr><tr><td>3.5.5 Create Media Campaign</td><td>MediaCampaign, timeline, deliverablePlan, workItems</td></tr><tr><td>3.5.6 Approve Media Campaign</td><td>CampaignVersion/Approval/Feedback/Deployment và complete</td></tr><tr><td>3.5.7 Create Content Request</td><td>ContentRequest.create, trạng thái PENDING</td></tr><tr><td>3.5.8 Track Request Status</td><td>Đọc trạng thái; Manager xử lý; accept tạo Task một lần</td></tr><tr><td>3.5.9 Update Request</td><td>updateWhilePending, kiểm tra người tạo và trạng thái atomically</td></tr><tr><td>3.5.10 Cancel Request</td><td>cancelWhilePending, giữ audit với CANCELLED</td></tr></tbody></table><p>Mọi hành vi phải kiểm tra Agency/Workspace và vai trò hiện tại. Sơ đồ lược bỏ controller, DTO, repository và các module ngoài FR 3.5 để tập trung mô hình nghiệp vụ. Các chuyên biệt E51 (editor, event plan, press recommendation, livestream, survey) không được triển khai hoặc mô tả đầy đủ trong tài liệu này.</p>`,17)])])}const d=a(t,[["render",p]]);export{r as __pageData,d as default};
