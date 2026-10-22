# BrandHub - Bộ Báo Cáo Nghiệm Thu Đồ Án Tốt Nghiệp (Final Reports - SEP490)

Thư mục này lưu trữ toàn bộ các tài liệu báo cáo nghiệm thu chính thức của Đồ án Tốt nghiệp **BrandHub – AI-Powered Multi-Channel Content Platform (Release 1)** theo tiêu chuẩn SEP490 (Fall 2023 / 2026).

---

## 1. Cấu Trúc Thư Mục

| Tệp / Thư mục | Định dạng | Mô tả nội dung |
| :--- | :---: | :--- |
| **`Report1_Project Introduction.docx`** | Word | Giới thiệu bối cảnh, mục tiêu, bài toán và phạm vi của hệ thống BrandHub. |
| **`Report2_Project Management Plan.docx`** | Word | Kế hoạch quản lý dự án, phân bổ nguồn lực, timeline và ma trận rủi ro. |
| **`Report2_Sample Project Schedule.pdf`** | PDF / POD | Lịch trình dự án chi tiết (Gantt chart, milestones). |
| **`Report3_Software Requirement Specification.docx`** | Word | Đặc tả yêu cầu phần mềm chi tiết cho toàn bộ 126 Functional Requirements (FR). |
| **`Report3_Project Tracking.xlsx`** | Excel | Bảng theo dõi tiến độ thực hiện các tính năng và nhiệm vụ của từng thành viên. |
| **`Report4_Software Design Document.docx`** | Word | Tài liệu thiết kế kiến trúc phần mềm, cơ sở dữ liệu, Class Diagram, Sequence Diagram. |
| **`Report5_Test Documentation.docx`** | Word | Báo cáo kiểm thử tổng hợp (Chiến lược, công cụ, môi trường, số liệu kiểm thử). |
| **`Report5_Test Report.xlsx`** | Excel | Ma trận chi tiết 2,287 System / Integration Test Cases và thống kê kết quả kiểm thử. |
| **`Report5_Unit Test.xls`** | Excel | Ma trận chi tiết 2,287 Unit Test Cases (Normal / Abnormal / Boundary cases) cho từng FR. |
| **`Report6_Software User Guides.docx`** | Word | Hướng dẫn sử dụng phần mềm dành cho người dùng cuối và quản trị viên. |
| **`Report7_Final Project Report.docx`** | Word | Báo cáo tổng kết đồ án, đánh giá kết quả, bài học kinh nghiệm và định hướng phát triển. |
| **`TESTING_WORKFLOW_AND_SYNC_GUIDE.md`** | Markdown | Hướng dẫn quy trình 4 bước kiểm thử và tự động đồng bộ kết quả kiểm thử. |
| **`scripts/`** | Python | Thư mục chứa công cụ tự động hóa kiểm thử và đồng bộ báo cáo: `sync_test_reports.py`. |
| **`reports/`** | Folder | Báo cáo tiến độ tuần và các tài liệu phụ trợ. |
| **`Sample_Report/`** | Folder | Tài liệu mẫu tham khảo định dạng đồ án chuẩn FPT University. |

---

## 2. Thông Tin Trọng Tâm Bộ Báo Cáo Kiểm Thử (Report 5)

Bộ báo cáo kiểm thử được đồng bộ và cập nhật theo tiến độ Release 1:

- **Tổng số ca kiểm thử toàn hệ thống:** **2,287 Test Cases** (phủ khắp 9 phân hệ chức năng: *Authentication, Profile, Agency & Workspace, Media Package, Content & Task, AI Features, Publishing, Billing, Admin*).
- **Phạm vi hoàn thiện 100% của Test Lead (Trung):**
  - **751 / 751 Test Cases Passed** trong `Report5_Unit Test.xls` (bao gồm 160 ca Authentication, 71 ca Profile, 394 ca Agency & Workspace, 126 ca Content & Task).
  - Tỷ lệ Unit Test Passed hiện tại đạt **32.84%** toàn dự án.
- **Tiến độ System Test toàn dự án (`Report5_Test Report.xlsx`):**
  - **1,117 / 2,287 Test Cases Passed (48.84%)**, 0 Failed, 1,170 Pending (dành cho các sprint tiếp theo của các thành viên khác).

---

## 3. Công Cụ Tự Động Hóa Đồng Bộ Báo Cáo (`scripts/sync_test_reports.py`)

Thư mục `scripts/` cung cấp công cụ tự động hóa độc quyền giúp đồng bộ kết quả kiểm thử từ code vào bộ 3 tài liệu Report 5:

```bash
# 1. Chạy đồng bộ toàn bộ kết quả kiểm thử của tác giả Trung:
python brandhub-infrastructure/final_report/scripts/sync_test_reports.py --author Trung

# 2. Cập nhật cho các FR mới khi các thành viên khác hoàn thiện:
python brandhub-infrastructure/final_report/scripts/sync_test_reports.py --frs 3.5.1,3.5.2 --tester Loc

# 3. Làm mới và tính toán lại công thức/bảng tổng hợp:
python brandhub-infrastructure/final_report/scripts/sync_test_reports.py --sync-all
```

Chi tiết xem tại tài liệu: [TESTING_WORKFLOW_AND_SYNC_GUIDE.md](./TESTING_WORKFLOW_AND_SYNC_GUIDE.md).
