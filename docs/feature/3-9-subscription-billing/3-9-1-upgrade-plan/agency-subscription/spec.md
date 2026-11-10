# Agency Subscription — Spec entrypoint

## Quyết định storage đã chốt — BR17–BR22 Repository

BASIC miễn phí **20 GiB/Agency = 21,474,836,480 bytes**, dùng chung mọi workspace.
Gói trả phí ACTIVE dùng tổng `plan.storageQuotaBytes` từ catalog, không cộng thêm 20 GiB.
Khi hết hạn, quota về BASIC; giữ quyền read/preview/download và restore theo ACL.
Trash đã tính usedBytes nên restore không tăng usage và không bị chặn vì quota.
Chỉ chặn tạo upload/derivative/watermark khi không còn chỗ; soft delete chưa giải phóng
dung lượng, purge binary thành công mới giảm. Upload đồng thời phải giữ chỗ nguyên tử
theo Agency; release reservation khi fail/expire phải idempotent, không dùng Redis làm ledger.
OWNER được xem aggregate usedBytes/quotaBytes và breakdown workspace của Agency mình;
không có quyền đọc nội dung file ngầm nếu thiếu membership vận hành.
Xem [BR01–BR25 Repository](../../../../tuan-research/REPOSITORY_SPEC.md).
Đây là sửa đặc tả; chưa thay catalog/migration/dữ liệu production.

## Nguồn và phạm vi hiện hữu

Nguồn nghiệp vụ duy nhất: [agency-subscription-spec.md v2](../../../../tuan-research/spec/agency-subscription-spec.md), ngày 20/10/2026. Người dùng chọn vị trí này cho spec; file entrypoint giúp bộ spec → plan → task → test tuân layout project mà không sao chép nghiệp vụ.

Phạm vi: FR 3.9.1, 3.9.3–3.9.7; FR 3.9.2 Downgrade/Cancel hoãn. Giữ expiry/renewal/recovery. Đọc spec đầy đủ trước thực thi, cùng [ACID rules](../../../../tuan-research/subscription_acid_implementation_rules.md).

UI bổ sung theo yêu cầu feature workflow: toàn bộ text mới đi qua namespace subscription. Key groups: agency.label, agency.select, plans.basic/plus/enterprise, plans.current, plans.upgrade, checkout.amount/period/credits/expiry/submit, payment.pending/fulfilled/reviewRequired/failed/expired/retry, history.title/empty/receipt/invoiceUnavailable, credits.available/reserved/purchased/expiring/usage, budget.cap/unlimited/blocked/save/conflict, recovery.title/workspaces/members/storage/clientLimit, errors.insufficientCredits/workspaceCap/creatorCap/quota/notConfigured/forbidden.
Thêm exact leaf keys phát sinh đồng thời VI/EN; không hardcode JSX. Reuse existing equivalent keys nếu có, test key parity. Light/dark dùng theme tokens hiện có; không tạo palette mới. Tất cả keyboard focus, contrast và mobile layout được nghiệm thu tại task 10.

