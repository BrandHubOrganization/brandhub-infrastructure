Chart và doanh thu theo gói lấy billing SePay thực, không cộng bảng legacy PayOS. Chỉ VERIFIED + order FULFILLED; REVIEW/pending không tính. Khoảng ngày/timezone/plan áp dụng đồng nhất. Personal/Basic/Plus/Enterprise từ catalog; gói chưa thu tiền hiển thị 0. MRR/ARR riêng theo kỳ trả phí hiện tại. Refund chưa có nghiệp vụ không suy đoán từ updated_at. Giữ API admin và invoice.

Sửa lỗi 500 daily receipts: alias ngày phải là identifier SQL rõ ràng, không đổi contract JSON DailyReceipts.date.
