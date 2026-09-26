# FR 3.10.3 — BrandHub System Health Monitoring

> Đặc tả mục tiêu theo mẫu `to-spec`, tổng hợp từ yêu cầu đã trao đổi và mã nguồn đã đọc. Người dùng đã xác nhận phạm vi kiểm thử và chọn chỉ lưu tài liệu local. Chưa triển khai hoặc kiểm thử chức năng này trong BrandHub; không đăng issue.

## Problem Statement

ADMIN của BrandHub cần biết các máy đang chạy hệ thống tiêu tốn bao nhiêu tài nguyên, còn liên lạc được không, và từng microservice, container, database hay endpoint nghiệp vụ có đáp ứng đúng hay không. Hiện các repo và cấu hình deployment chưa cung cấp một màn hình giám sát hợp nhất đáp ứng đầy đủ yêu cầu này.

Một repo không tương ứng với một server: nhiều service có thể chạy cùng EC2, một service có thể có nhiều replica trên các máy khác nhau. Server còn gửi heartbeat không chứng minh mọi ứng dụng trên đó khỏe; container Running không chứng minh ứng dụng sẵn sàng phục vụ. Thiếu dữ liệu hoặc lỗi chính hệ thống giám sát cũng không đủ để kết luận đối tượng đã ngừng hoạt động.

VPS Monitor hiện tại là nguồn tham khảo cho collector tài nguyên và dashboard, không phải tính năng đã tích hợp BrandHub. Cần tận dụng mô hình tài khoản và quyền system ADMIN của BrandHub, đồng thời phân biệt rõ dữ liệu hiện tại, dữ liệu cũ và chưa có dữ liệu.

## Solution

Cung cấp một trang **Admin → System Health** tại route `/admin/system-health`, gồm hai tab:

- **Servers:** tên/IP, môi trường, service được triển khai, CPU, RAM, Disk, uptime, Online/Offline/Chưa có dữ liệu và lần nhận heartbeat cuối.
- **Services & Dependencies:** health từng instance microservice, container, database và endpoint; trạng thái UP/DOWN/UNKNOWN, phạm vi kiểm tra, runtime state nếu có, độ trễ, thời điểm probe và lý do lỗi.

Có bộ lọc môi trường và server; tab health bổ sung loại đối tượng và trạng thái. Thông tin chi tiết nguồn kiểm tra và kết quả gần nhất có thể mở trong panel tại cùng trang, không cần route chi tiết riêng.

Agent tài nguyên và collector health chạy nền ngay cả khi không có người mở trang. Trang admin chỉ đọc kết quả qua API được bảo vệ, không truy cập Docker/database trực tiếp và không khởi chạy probe. Chỉ giữ mẫu mới nhất, chưa cần lịch sử, biểu đồ hoặc hệ thống cảnh báo.

## User Stories

1. As an ADMIN, I want mở System Health trong phần quản trị, so that tôi theo dõi hạ tầng BrandHub tại một nơi.
2. As an ADMIN, I want chỉ system ADMIN được truy cập dữ liệu giám sát, so that thông tin vận hành không bị lộ cho người dùng thông thường hoặc quản trị workspace.
3. As an ADMIN, I want xem tất cả server đã khai báo kể cả chưa có mẫu, so that tôi phát hiện máy chưa được kết nối giám sát.
4. As an ADMIN, I want xem tên, IP, môi trường và service chạy trên từng host, so that tôi nhận diện đúng máy cần xử lý.
5. As an ADMIN, I want một host chỉ xuất hiện một lần dù chạy nhiều repo, so that tôi không hiểu nhầm hoặc đếm trùng tài nguyên.
6. As an ADMIN, I want xem CPU, RAM và Disk theo phần trăm cùng uptime host, so that tôi đánh giá mức sử dụng tài nguyên gần nhất.
7. As an ADMIN, I want chỉ số không đọc được hiển thị dấu “—”, so that tôi không nhầm thiếu dữ liệu với mức sử dụng bằng 0.
8. As an ADMIN, I want biết thời điểm nhận heartbeat gần nhất, so that tôi đánh giá độ mới của trạng thái host.
9. As an ADMIN, I want phân biệt Online, Offline và Chưa có dữ liệu, so that tôi biết host còn liên lạc hay chưa từng báo cáo.
10. As an ADMIN, I want giữ mẫu cuối với nhãn Dữ liệu cũ khi host Offline, so that tôi có ngữ cảnh mà không nhầm đó là số liệu hiện tại.
11. As an ADMIN, I want host tự trở lại Online khi nhận heartbeat hợp lệ, so that tôi nhận biết kết nối đã phục hồi.
12. As an ADMIN, I want lọc theo môi trường và host, so that tôi tập trung vào deployment cần theo dõi.
13. As an ADMIN, I want xem health riêng từng instance service, so that tôi biết replica nào lỗi dù host vẫn Online.
14. As an ADMIN, I want phân biệt probe readiness và liveness, so that tôi hiểu chính xác kết quả đã chứng minh điều gì.
15. As an ADMIN, I want xem runtime state và Docker health riêng biệt, so that tôi không coi container Running là ứng dụng khỏe.
16. As an ADMIN, I want container đã khai báo nhưng bị dừng hoặc xóa vẫn xuất hiện, so that lỗi deployment không biến mất khỏi dashboard.
17. As an ADMIN, I want container chưa có healthcheck hiển thị UNKNOWN, so that hệ thống không tự tạo kết luận khỏe.
18. As an ADMIN, I want database được kiểm tra bằng kết nối xác thực và thao tác nhẹ, so that cổng mở không bị hiểu nhầm là database dùng được.
19. As an ADMIN, I want xem health dịch vụ managed mà không có CPU/RAM host giả, so that số liệu phản ánh đúng phạm vi quan sát.
20. As an ADMIN, I want kiểm tra một số endpoint nghiệp vụ đọc dữ liệu qua Gateway, so that tôi biết các luồng đọc được chọn có đáp ứng đúng hợp đồng.
21. As an ADMIN, I want kết quả HTTP được kiểm tra cả status lẫn nội dung mong đợi, so that trang lỗi trả 200 không bị báo UP.
22. As an ADMIN, I want xem thời điểm, độ trễ, collector và lý do lỗi của từng phép kiểm tra, so that tôi có thông tin để điều tra.
23. As an ADMIN, I want phân biệt target DOWN với collector lỗi hoặc mẫu stale, so that tôi không xử lý nhầm nguyên nhân.
24. As an ADMIN, I want một probe lỗi không làm mất kết quả các đối tượng khác, so that tôi vẫn quan sát được phần hệ thống còn lại.
25. As an ADMIN, I want xem từng replica kể cả khi có trạng thái tổng hợp, so that một instance khỏe không che khuất instance lỗi.
26. As an ADMIN, I want trạng thái health tự phục hồi sau probe thành công, so that dashboard phản ánh kết quả mới nhất.
27. As an ADMIN, I want dữ liệu tự làm mới khi trang đang hoạt động, so that tôi không phải tải lại thủ công.
28. As an ADMIN, I want bảng host và bảng health báo lỗi tải độc lập, so that một API lỗi không làm mất bảng còn cập nhật được.
29. As an ADMIN, I want ngừng nhận và hiển thị dữ liệu bảo vệ khi phiên hết hạn hoặc quyền bị thu hồi, so that quyền truy cập được thực thi đúng.
30. As an operator, I want khai báo host, target, collector và môi trường trước khi chạy, so that chỉ đối tượng được phép mới xuất hiện trong hệ thống.
31. As an operator, I want ID host ổn định qua lần redeploy container, so that triển khai lại ứng dụng không tạo server trùng.
32. As an operator, I want cấp ID mới khi thay máy và cập nhật ánh xạ service, so that dữ liệu máy cũ không bị gắn nhầm cho máy mới.
33. As an operator, I want mỗi agent/collector có credential riêng và phạm vi ghi riêng, so that một collector không thể sửa kết quả của đối tượng khác.
34. As an operator, I want agent và worker tự khởi động, chạy định kỳ và không chờ UI, so that việc giám sát không phụ thuộc ADMIN mở trang.
35. As an operator, I want lỗi hoặc timeout một probe không chặn các probe khác và heartbeat, so that collector vẫn hoạt động khi một thành phần lỗi.
36. As an operator, I want request lặp hoặc kết quả đến trễ không làm mới dữ liệu cũ, so that trạng thái dựa trên phép đo thực tế gần nhất.
37. As an operator, I want probe chỉ đọc và không gây publish, gửi email hoặc phát sinh chi phí AI, so that giám sát không làm thay đổi nghiệp vụ.
38. As an operator, I want secret, response nghiệp vụ và thông tin kết nối không xuất hiện trên dashboard/log, so that công cụ giám sát không làm lộ dữ liệu.
39. As an operator, I want kiểm tra nội bộ không yêu cầu public port từng service/database, so that triển khai monitoring phù hợp mạng hiện có.
40. As an ADMIN, I want thông báo rõ khi chính backend giám sát không truy cập được, so that tôi không hiểu nhầm tất cả server/service đều Offline hoặc DOWN.

## Implementation Decisions

### Phạm vi đo và thuật ngữ

- **Server/host:** máy EC2/VPS thực tế; một agent tài nguyên trên mỗi host. CPU/RAM toàn host không được sao chép thành tài nguyên riêng từng repo/container.
- **Health target:** đối tượng được khai báo thuộc một trong bốn loại SERVICE, CONTAINER, DATABASE, ENDPOINT. Mỗi instance có target riêng; endpoint qua load balancer không đại diện health từng replica.
- **Collector:** nguồn thực hiện probe, được phân công target cụ thể. Một target có một collector chủ động; probe nội bộ và probe qua Gateway là hai target khác nhau.
- **System ADMIN:** quyền toàn hệ thống BrandHub, khác OWNER/MANAGER/MEMBER tại workspace. Kiểm tra ở backend, không chỉ ẩn menu.
- **Online/Offline:** trạng thái liên lạc heartbeat host. **UP/DOWN/UNKNOWN:** kết quả health của target. Hai lớp không suy ra lẫn nhau.

### Các module và trách nhiệm

| Thành phần | Quyết định |
| --- | --- |
| BrandHub Web | Một trang admin, hai tab, bộ lọc, panel thông tin và polling |
| API Gateway | Route monitoring, phân biệt xác thực JWT người dùng với agent/collector token |
| Business Service | Module monitoring xác thực, nhận heartbeat/kết quả, lưu dữ liệu và cung cấp API đọc |
| DB của Business | Đề xuất PostgreSQL qua JPA; không cần thêm DB chuyên dụng cho phạm vi hiện tại |
| Host agent | Đọc tài nguyên toàn máy, chạy bằng trình quản lý tiến trình như systemd |
| Probe worker | Scheduler nền trên mạng truy cập được target, không chạy trong request GET của ADMIN |
| Container collector | Đọc runtime và health metadata trên đúng host, giới hạn quyền đọc cần thiết |
| Infrastructure/deployment | Khai báo danh mục, cấu hình network/secret, cài agent/worker và cấp credential |
| Các service ứng dụng | Cung cấp hoặc xác minh health/readiness và assertion tương ứng; không nhúng collector tài nguyên host vào từng repo |

Tái sử dụng ý tưởng collector tài nguyên và UI từ VPS Monitor; không mang sang cơ chế đăng ký agent công khai, quản lý tài khoản riêng, lưu toàn bộ Metric hoặc Telegram. Các endpoint/schema trong đặc tả là hợp đồng mục tiêu, chưa phải chức năng có sẵn của BrandHub.

### Host metrics và heartbeat

- Agent gửi theo chu kỳ mục tiêu 15 giây; chu kỳ thực tế có thể cộng thời gian xử lý/mạng. Không gửi chồng heartbeat hoặc replay backlog.
- CPU tính từ chênh lệch bộ đếm CPU toàn host giữa hai lần đo, phần idle gồm iowait. RAM bằng phần MemTotal trừ MemAvailable chia MemTotal. Disk đo used/total tại filesystem gắn ở `/`. Uptime tính từ lúc host khởi động, không phải uptime container.
- Phần trăm hữu hạn trong khoảng 0–100; uptime nguyên không âm. Trường chỉ số phải có mặt nhưng cho phép null khi không đọc được; UI hiển thị “—”, không giả lập 0.
- Backend gán lastSeenAt khi nhận heartbeat hợp lệ và cập nhật nguyên tử với mẫu mới nhất. Token/payload sai không thay đổi thời điểm này.
- Chưa có heartbeat: NO_DATA. Tuổi heartbeat không quá 60 giây: ONLINE. Quá 60 giây: OFFLINE. Đúng 60 giây vẫn ONLINE; tính theo đồng hồ backend tại lúc đọc API.
- Offline giữ mẫu cuối có nhãn cũ; heartbeat hợp lệ mới đưa host về Online. Không lưu status host thành giá trị cố định trong DB.

### Probe và hợp đồng kiểm tra

| Loại | Thành công | Giới hạn ý nghĩa |
| --- | --- | --- |
| SERVICE | HTTP status và JSON khớp hợp đồng của đúng instance | Ghi checkScope là READINESS hoặc LIVENESS theo thực tế; không gọi liveness là readiness |
| CONTAINER | Runtime running và Docker health healthy | Running không có healthcheck là UNKNOWN về health ứng dụng |
| DATABASE | Kết nối xác thực và ping/truy vấn nhẹ thành công trong timeout | Cổng TCP mở không đủ chứng minh database hoạt động |
| ENDPOINT | GET được cho phép, status và assertion nội dung đúng | Chỉ chứng minh luồng đọc đã chọn, không chứng minh toàn bộ nghiệp vụ |

- Probe mặc định mỗi 30 giây, timeout tổng kết nối/đọc 5 giây, tối đa 5 probe đồng thời, không chồng lần chạy cùng target. Tham số cấu hình được theo target; vòng quét phải phù hợp ngưỡng stale.
- Kết quả thất bại hợp lệ đầu tiên đổi DOWN ngay; lần PASS tiếp theo đổi UP. Không có debounce hay đếm nhiều lần lỗi trong bản này.
- Host/collector heartbeat độc lập với scheduler probe. Worker vẫn chạy khi UI đóng; một target timeout không chặn các target khác.
- Truy vấn DB dùng thao tác nhẹ: PostgreSQL chọn hằng số, MongoDB ping, Redis PING, Neo4j trả hằng số. ChromaDB và RabbitMQ dùng endpoint/health API phù hợp phiên bản deploy, phải xác minh trước khi cấu hình.
- Gateway, Business và Publisher tham chiếu Actuator health hiện có; AI tham chiếu health endpoint hiện có. Phải xác minh payload, auth, dependency và checkScope trước khi bật target.
- CloudFront/frontend có thể là ENDPOINT, không có metrics host giả. MongoDB Atlas có thể là DATABASE, không cài Bash agent lên hạ tầng managed. Mobile app không phải host giám sát.
- Endpoint nghiệp vụ là các API GET thật được người vận hành chọn, dùng tài khoản đọc riêng và assertion tối thiểu. Không tự phát minh route hoặc chạy tác vụ publish/gửi email/thanh toán/AI có phí.

### Quy tắc trạng thái health

| Tình huống | Trạng thái |
| --- | --- |
| Mẫu còn mới, collector còn liên lạc và phép kiểm tra thành công | UP |
| Mẫu còn mới, kiểm tra đã thực hiện nhưng target timeout/từ chối kết nối/status hoặc body sai/truy vấn lỗi | DOWN |
| Chưa có mẫu, mẫu stale, collector mất liên lạc, không thực hiện được phép kiểm tra hoặc thiếu cấu hình | UNKNOWN |
| HTTP 401/403 hoặc DB từ chối credential probe | UNKNOWN với PROBE_AUTH_FAILED |
| Container running nhưng unhealthy | DOWN |
| Container restarting, exited, dead hoặc paused | DOWN |
| Container starting hoặc running chưa có healthcheck | UNKNOWN với STARTING hoặc NO_HEALTHCHECK |
| Runtime truy cập được nhưng không thấy container khớp selector đã khai báo | DOWN với CONTAINER_NOT_FOUND; không tự xóa target |
| Không đọc được runtime hoặc selector khớp nhiều container ngoài thiết kế | UNKNOWN với lỗi collector/cấu hình |

- Collector heartbeat mỗi 15 giây; quá 60 giây không nhận hoặc chưa từng nhận thì target của collector là UNKNOWN. Heartbeat collector không cập nhật checkedAt của probe.
- Mẫu health quá 90 giây từ checkedAt là UNKNOWN/STALE dù collector vẫn heartbeat. Đúng 90 giây chưa stale. Không gán stale chỉ theo receivedAt.
- Giữ lastKnownStatus và thời điểm để hiển thị kết quả cũ; không gọi kết quả cũ là trạng thái hiện tại. Collector lỗi chỉ ảnh hưởng target thuộc collector đó.
- Host Offline không tự đổi mọi target DOWN. Probe độc lập từ nguồn còn hoạt động vẫn được đánh giá theo bằng chứng riêng. CPU/RAM cao không tự đổi health.
- DOWN là lỗi từ góc nhìn probe và phạm vi đã cấu hình; không chứng minh máy vật lý tắt hoặc xác định nguyên nhân gốc.
- Nếu hiển thị tổng hợp service: tất cả UP → UP; tất cả DOWN → DOWN; có UP và DOWN → DEGRADED; có bất kỳ UNKNOWN → UNKNOWN kèm số lượng từng trạng thái. Luôn giữ khả năng xem từng instance; nhóm chưa có instance là UNKNOWN.

### Mô hình dữ liệu

| Thực thể | Dữ liệu và ràng buộc |
| --- | --- |
| Server | serverId unique, name, ipAddress, environment, deployedServices, agentTokenHash, cpuPercent/ramPercent/diskPercent/uptimeSeconds nullable, lastSeenAt nullable |
| Collector | collectorId unique, serverId nullable, tokenHash, lastSeenAt, danh sách target được phép báo cáo |
| HealthTarget | targetId unique, name, kind, environment, serverId nullable, serviceName/instanceId tùy chọn, collectorId, checkScope, probeType, địa chỉ/selector, assertion, credentialRef và các ngưỡng |
| HealthResult | Một mẫu mới nhất mỗi target: checkId, outcome PASS/FAIL/ERROR, checkedAt, receivedAt, latencyMs, reasonCode, httpStatus, runtimeState/runtimeHealth nếu áp dụng |

- ID host không dùng repo/container ID/IP làm định danh. Redeploy cùng host giữ ID; thay máy cấp ID mới. Metadata và ánh xạ service do người vận hành cập nhật, không bị heartbeat ghi đè.
- Danh mục host/target luôn tồn tại độc lập với dữ liệu đo để thấy đối tượng chưa có mẫu hoặc container đã mất.
- HealthResult và timestamp cập nhật nguyên tử; chỉ nhận từ collector được phân công. PASS tương ứng kiểm tra thành công, FAIL tương ứng lỗi target, ERROR tương ứng không đánh giá được target; backend kiểm tra tính nhất quán với reasonCode/type rồi tính status.
- Lưu UTC. checkedAt do collector ghi nhận lúc hoàn tất probe; receivedAt do backend gán. Đồng bộ đồng hồ collector. Mặc định từ chối phép đo quá 10 giây trong tương lai hoặc quá 90 giây trong quá khứ; khi cấu hình ngưỡng phải đồng bộ cửa sổ tiếp nhận với staleAfterSeconds. Tuổi mẫu tương lai trong dung sai được chặn tối thiểu 0.
- Request lặp đúng checkId của mẫu hiện tại không thay đổi dữ liệu/thời gian. Kết quả checkedAt cũ hơn mẫu đã lưu bị từ chối; cùng thời điểm nhưng checkId khác bị coi xung đột thay vì ghi đè tùy ý. Không cần lưu lịch sử checkId vô hạn: replay mẫu trước phải bị loại theo thứ tự thời gian.
- Chỉ lưu metadata kết quả chuẩn hóa; không lưu raw response body hoặc credential vào mẫu. credentialRef trỏ tới secret được quản lý, không trả ra UI.

### Hợp đồng API mục tiêu

Giữ convention prefix/response của BrandHub khi triển khai; nếu thay đường dẫn đề xuất phải cập nhật đồng bộ frontend và collector.

| Method và endpoint | Xác thực | Đầu vào / đầu ra |
| --- | --- | --- |
| POST `/api/monitoring/heartbeat` | Bearer token của đúng server | serverId và các chỉ số bắt buộc, cho phép null; lưu mẫu host mới nhất |
| GET `/api/monitoring/servers` | System ADMIN | serverTime và servers, gồm metadata, status, chỉ số, lastSeenAt; sắp xếp tên rồi ID |
| POST `/api/monitoring/collectors/heartbeat` | Bearer token của đúng collector | collectorId; chỉ cập nhật lastSeenAt collector |
| POST `/api/monitoring/health-results` | Bearer collector token | targetId, checkId, checkedAt, outcome; reasonCode bắt buộc với FAIL/ERROR; metadata kết quả tùy loại |
| GET `/api/monitoring/health-targets` | System ADMIN | serverTime và targets; lọc environment/serverId/kind/status; gồm scope, instance, collector, trạng thái và kết quả gần nhất |

- Danh sách trả cả đối tượng chưa có dữ liệu; danh mục rỗng trả 200 với mảng rỗng. Trường không có/không áp dụng là null.
- API ghi chỉ cập nhật danh mục có sẵn, không tự tạo host/target hoặc nhận URL/credential tùy ý từ kết quả collector.
- API ghi trả 200 khi lưu thành công; retry mẫu hiện tại trả 200 với dấu duplicate và không làm mới timestamp.
- 400: payload/filter/timestamp sai. 401: thiếu/sai credential hoặc JWT không hợp lệ. 403: user không phải system ADMIN hoặc collector ghi target ngoài quyền. 404: target không tồn tại. 409: mẫu cũ hoặc xung đột thứ tự. 503: không đọc/ghi được dữ liệu monitoring. Heartbeat host không khớp token/server trả 401.
- Tỷ lệ chỉ số hữu hạn 0–100, uptime nguyên không âm, latency hữu hạn không âm, HTTP status hợp lệ; runtime metadata chỉ áp dụng CONTAINER. Backend kiểm tra outcome và reasonCode phù hợp probe, không chấp nhận status hiển thị tùy ý từ client.
- Không trả token/tokenHash, URL chứa bí mật, cấu hình truy cập DB hoặc raw response qua API ADMIN.

### Giao diện và lỗi nguồn dữ liệu

- Tải dữ liệu khi mở trang, polling 5 giây khi trang hoạt động; dừng polling khi rời trang. Chu kỳ polling không biến mẫu probe thành dữ liệu tức thời.
- Hiển thị phần trăm một chữ số thập phân, uptime ngày/giờ/phút; timestamp theo múi giờ trình duyệt, phép tính freshness vẫn ở backend.
- Trạng thái có cả chữ và màu. Có loading, danh mục rỗng, chưa có mẫu, stale và lỗi tải riêng cho từng tab/bảng.
- Khi API lỗi, giữ kết quả trước nếu còn quyền, kèm cảnh báo Không thể cập nhật và thời điểm tải thành công cuối; không đổi toàn bộ host thành Offline hoặc target thành DOWN.
- Khi nhận 401/403, dừng tải, xóa dữ liệu bảo vệ khỏi màn hình và dùng luồng đăng nhập/thiếu quyền hiện có; không giữ cache nhạy cảm như một lỗi mạng thông thường.

### Quyền truy cập và vận hành

- Dùng HTTPS cho heartbeat/kết quả và đường truy cập ADMIN. Token ngẫu nhiên riêng từng agent/collector, backend lưu hash; không dùng JWT ADMIN hoặc internal service key chung làm credential collector.
- Gateway cần tách đường xác thực machine credential khỏi JWT người dùng; backend vẫn kiểm tra credential và quyền sở hữu target trước khi lưu.
- Chỉ probe danh mục được cấu hình trước, giới hạn host/port/path; không tự theo redirect ra ngoài danh mục. Không public port nội bộ chỉ để monitoring truy cập.
- HTTP probe dùng GET, response tối đa 64 KiB, không lưu body; vượt giới hạn không được PASS. Tài khoản DB/endpoint có quyền tối thiểu cho kiểm tra đọc.
- Không cấp Docker socket cho Business/Web. Container collector dùng quyền đọc giới hạn; mount socket với cờ chỉ đọc không tự hạn chế quyền Docker API. Nếu dùng proxy runtime phải giới hạn API được gọi, chặn thao tác ghi.
- Log và UI dùng reasonCode/thông báo chuẩn hóa, không đưa token, mật khẩu, connection string, response nghiệp vụ hoặc stack trace nhạy cảm ra ngoài.

## Testing Decisions

Người dùng đã xác nhận phạm vi kiểm thử: API monitoring là ranh giới chính, bổ sung adapter probe và một luồng UI ADMIN. Đây là kế hoạch đã chốt, chưa phải các test đã viết hoặc đã chạy.

### Ranh giới kiểm thử

1. **Ranh giới chính — API monitoring:** gửi heartbeat/kết quả với credential thực của môi trường test, rồi đọc qua API ADMIN và quan sát response. Kiểm tra authorization, validation, lưu mẫu, thứ tự, freshness và trạng thái qua hành vi công khai; ưu tiên integration test với persistence thật được cô lập và đồng hồ điều khiển được. Không assert thứ tự gọi repository, tên private method hoặc chi tiết framework.
2. **Ranh giới phụ — adapter probe:** chạy probe với HTTP/DB/runtime fixture được kiểm soát, xác minh kết quả chuẩn hóa và timeout. Cần ranh giới này vì chỉ POST kết quả giả vào API không chứng minh collector đo đúng. Dùng DB test tạm thời cho kết nối/truy vấn, fixture cho runtime; smoke test có Docker trên môi trường phù hợp để kiểm chứng adapter runtime.
3. **Luồng UI ADMIN:** một kịch bản end-to-end chính cho đăng nhập, hai tab, lọc, cập nhật dữ liệu, lỗi một nguồn và mất quyền. Không dùng snapshot toàn trang hoặc assert cấu trúc component để thay thế hành vi người dùng.

### Nền tảng kiểm thử đã thấy

- BrandHub Gateway có integration test Spring Boot trên cổng ngẫu nhiên bằng WebTestClient, kiểm tra HTTP và body Actuator. Đây là tiền lệ cho API test; chưa phải test monitoring và có dependency health được tắt trong cấu hình test hiện có.
- BrandHub Business có JUnit/Mockito/AssertJ test cho RequireRoleAspect, phân biệt system ADMIN và workspace role. Tái sử dụng vocabulary và fixtures xác thực khi phù hợp; kiểm tra API mới vẫn phải chứng minh từ chối OWNER/MANAGER.
- VPS Monitor hiện có script lint/build nhưng chưa có test script trong manifest đã đọc. Không coi nó là bộ kiểm thử sẵn cho collector/monitoring mới.
- Chưa xác minh framework E2E của BrandHub Web; chọn theo công cụ thực tế của repo khi triển khai, không mặc định đã có một bộ test.

### Ma trận nghiệm thu

| Nhóm | Hành vi bắt buộc kiểm chứng |
| --- | --- |
| Quyền người dùng | 401 khi thiếu/hết hạn phiên; 403 khi không phải system ADMIN, kể cả OWNER/MANAGER; ADMIN đọc thành công; thu hồi quyền dừng hiển thị dữ liệu |
| Quyền machine | Token sai không ghi dữ liệu; collector không ghi target người khác; không tự đăng ký host/target; response/log không chứa secret |
| Host metrics | Null không bị đổi thành 0; tỷ lệ ngoài 0–100, thiếu trường, uptime âm bị từ chối và không cập nhật lastSeenAt |
| Host freshness | Chưa có heartbeat là NO_DATA; đúng 60 giây ONLINE, lớn hơn 60 OFFLINE; giữ mẫu cũ có nhãn; heartbeat mới phục hồi |
| Deployment | Nhiều repo cùng host có một bộ metrics; nhiều host có ID riêng; redeploy container không sinh host mới; managed target không có CPU/RAM giả |
| Service probe | Status/body đúng là PASS; 200 với body sai thất bại; timeout một target không chặn heartbeat hoặc target khác; probe thành công sau lỗi phục hồi UP |
| Container | Running/healthy UP; running/unhealthy DOWN; thiếu healthcheck hoặc starting UNKNOWN; stopped/mất container DOWN; runtime không đọc được UNKNOWN |
| Database | Thực hiện kết nối và query thật; không chấp nhận TCP mở là đủ; sai credential UNKNOWN; query lỗi phân loại theo reasonCode |
| Freshness health | Collector quá 60 giây hoặc chưa có heartbeat → UNKNOWN; mẫu đúng 90 giây còn mới, quá 90 → STALE; heartbeat collector không làm mới mẫu |
| Thứ tự mẫu | Retry cùng mẫu không đổi timestamp; mẫu cũ hoặc xung đột không ghi đè; quá dung sai đồng hồ bị từ chối; không replay backlog |
| Replica | Kiểm tra từng instance; UP + DOWN thành DEGRADED nếu tổng hợp; bất kỳ UNKNOWN làm tổng UNKNOWN; host Online không che service DOWN |
| UI và nguồn lỗi | Polling và filter đúng; host API/health API lỗi độc lập; báo không thể cập nhật thay vì suy mọi đối tượng hỏng; bảng rỗng/loading/stale rõ ràng |
| Vận hành probe | Chạy khi UI đóng; không probe chồng cùng target; concurrency/timeout hoạt động; URL/redirect ngoài cấu hình bị chặn; response quá lớn không PASS |
| An toàn nghiệp vụ | Chỉ GET đã khai báo, xác thực body; không publish/gửi email/thanh toán/call AI tính phí; không lộ dữ liệu thật trong test |

Không dùng sleep dài để kiểm tra mốc 60/90 giây; điều khiển đồng hồ tại ranh giới phù hợp. Test trên fixture hoặc môi trường cô lập, không tắt service production để thử. Đây là kế hoạch nghiệm thu, không phải báo cáo test đã pass.

## Out of Scope

- CPU/RAM từng container/service, distributed tracing, tổng hợp log và xác định nguyên nhân gốc tự động.
- Lưu toàn bộ mẫu, biểu đồ lịch sử, báo cáo, dự báo, cảnh báo Telegram/email và thông báo phục hồi.
- SSH, terminal, reboot, restart container, điều khiển server hoặc thay đổi nghiệp vụ từ dashboard.
- Đăng ký agent công khai; UI thêm/xóa host, nhập URL tùy ý, quản lý tags hoặc installer tự động.
- Xây dựng lại đăng nhập/đăng ký/phân quyền; monitoring sử dụng cơ chế BrandHub hiện có.
- Probe nghiệp vụ có tác dụng ghi, kiểm tra toàn bộ giao dịch đầu-cuối hoặc tác vụ phát sinh chi phí.
- Đo tài nguyên hạ tầng S3/CloudFront/Atlas bằng Bash agent; thiết bị chạy mobile app.
- Cam kết dashboard tiếp tục hoạt động khi chính Gateway/Business/DB phục vụ monitoring sập. Khả năng đó cần kiến trúc độc lập bổ sung.

## Further Notes

### Giới hạn deployment

Cấu hình production đã đọc mô tả một Compose stack gồm Nginx, Gateway, Business, AI, Publisher và dịch vụ dữ liệu; frontend được mô tả trên S3/CloudFront, MongoDB Atlas bên ngoài. Bộ công cụ deployment khác có chuẩn bị EC2 Amazon Linux nhưng chưa chứng minh topology thực tế. Chưa kết nối máy triển khai để xác nhận số host, số replica hoặc endpoint hoạt động.

Nếu monitoring cùng host với backend, khi host đó tắt thì API giám sát cũng mất. UI chỉ báo không thể cập nhật; muốn ADMIN vẫn quan sát được sự cố đó phải có backend lưu/đọc, đường truy cập và xác thực độc lập. Chỉ tách collector hoặc DB ra ngoài không đủ nếu API đọc vẫn đi qua Gateway/Business đã ngừng hoạt động.

### Chuẩn bị khi triển khai

Người vận hành phải cung cấp danh mục host/môi trường, ánh xạ instance, container selector, hợp đồng health thực tế, credential đọc và endpoint nghiệp vụ GET được chọn. Đây là cấu hình môi trường cần điền, không phải lý do tự thêm endpoint hoặc giả dữ liệu. Không bật target chưa xác minh contract/credential.

Phải kiểm tra glossary và ADR áp dụng của từng repo khi bắt đầu code. Glossary BrandHub đã đọc phân biệt workspace role và thực thể nghiệp vụ nhưng chưa định nghĩa đầy đủ mô hình monitoring; các tên Server, Collector, HealthTarget, HealthResult ở trên là mô hình đề xuất. Không có ADR monitoring được xác nhận trong lượt rà soát này.

### Trạng thái tài liệu và phát hành

Bản này đã bao gồm host monitoring và health từng thành phần, thay thế cấu trúc đặc tả tích lũy trước đó bằng mẫu to-spec. Vẫn chưa gồm lịch sử và tài nguyên riêng từng service như các ý tưởng mở rộng trong draft BrandHub. DA-1013 đã có implementation tại Business, Gateway, Web và Infrastructure; trạng thái kiểm chứng được ghi riêng trong evidence.md. Chưa nghiệm thu deployment thực tế.

Theo lựa chọn rõ ràng của người dùng, chỉ lưu bản spec local; không tạo issue, cấu hình tracker hoặc áp dụng nhãn triage. Bước publish mặc định của skill to-spec không áp dụng cho yêu cầu này. Phạm vi tính năng hướng tới BrandHub; repository VPS Monitor là nguồn tham khảo implementation.

### Hợp đồng implementation DA-1013

Hai API đọc dùng phân trang page/size (tối đa 200), trả totalPages và serverTime. Frontend đọc đủ các trang trước khi thay snapshot. Bộ lọc status được tính sau freshness trên từng trang; totalPages phản ánh danh mục, không phải tổng kết quả sau lọc status. Không dùng số phần tử trang để quyết định đã hết danh mục.

Worker dùng cấu hình operator để giới hạn chính xác URL/selector, không nhận URL từ người dùng dashboard. Không tự đăng ký host hoặc tạo target production. Target chưa xác minh endpoint/credential không được bật chỉ để làm dashboard có dữ liệu.
