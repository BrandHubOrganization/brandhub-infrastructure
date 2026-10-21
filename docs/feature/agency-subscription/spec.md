# Agency Subscription — Spec entrypoint

Nguồn nghiệp vụ duy nhất: [agency-subscription-spec.md v2](../../../../tuan-research/spec/agency-subscription-spec.md), ngày 20/10/2026. Người dùng chọn vị trí này cho spec; file entrypoint giúp bộ spec → plan → task → test tuân layout project mà không sao chép nghiệp vụ.

Phạm vi: FR 3.9.1, 3.9.3–3.9.7; FR 3.9.2 Downgrade/Cancel hoãn. Giữ expiry/renewal/recovery. Đọc spec đầy đủ trước thực thi, cùng [ACID rules](../../../../tuan-research/subscription_acid_implementation_rules.md).

UI bổ sung theo yêu cầu feature workflow: toàn bộ text mới đi qua namespace subscription. Key groups: agency.label, agency.select, plans.basic/plus/enterprise, plans.current, plans.upgrade, checkout.amount/period/credits/expiry/submit, payment.pending/fulfilled/reviewRequired/failed/expired/retry, history.title/empty/receipt/invoiceUnavailable, credits.available/reserved/purchased/expiring/usage, budget.cap/unlimited/blocked/save/conflict, recovery.title/workspaces/members/storage/clientLimit, errors.insufficientCredits/workspaceCap/creatorCap/quota/notConfigured/forbidden.
Thêm exact leaf keys phát sinh đồng thời VI/EN; không hardcode JSX. Reuse existing equivalent keys nếu có, test key parity. Light/dark dùng theme tokens hiện có; không tạo palette mới. Tất cả keyboard focus, contrast và mobile layout được nghiệm thu tại task 10.

