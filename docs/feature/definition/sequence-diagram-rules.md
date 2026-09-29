# Sequence Diagram Rules — BrandHub

> Chuẩn vẽ `report4_sequence.drawio` cho mọi FR. Áp dụng khi tạo mới hoặc sửa lại sequence diagram. Tham chiếu mẫu chuẩn: `profile/3-3-1-view-user-profile/report4_sequence.drawio`.

---

## 1. Lifeline bắt buộc

Mỗi diagram phải có đủ các tầng sau, theo đúng thứ tự trái → phải:

1. **«Actor»** — người dùng (User, Agency member, ...).
2. **«Boundary» — UI screen** — trang/màn hình frontend thực tế (ví dụ `ProfilePage (UI)`, `AgenciesPage (UI)`). Actor **không bao giờ** gọi thẳng Controller — luôn phải qua 1 UI lifeline trung gian, vì thực tế người dùng tương tác với màn hình, màn hình mới gọi API.
3. **«Boundary» — Controller** — class `*Controller` thật trong code.
4. **«Control» — ServiceImpl** — class `*ServiceImpl` thật xử lý business logic.
5. **«Entity» — Repository** — mỗi repository thật được gọi (`*Repository`).
6. **«Entity» — Model object** — đối tượng domain model mà repository trả về/mà Service dựng lên (ví dụ `User`, `ClientProfile`, `Agency`, `UserSystemRole`). **Bắt buộc lifeline riêng, không gộp vào Repository.**
7. **«Entity» — Response object** — DTO trả về cuối cùng (`UserProfileResponse`, `ClientProfileResponse`, ...). **Bắt buộc lifeline riêng**, Service phải gửi message `new XxxResponse(...)` hoặc `toResponse(...)` tới lifeline này rồi nhận lại object, không trả thẳng từ Service ra Controller.
8. **«External Service»** (nếu có) — dịch vụ ngoài (FileStorageService, MailService, Redis, JwtUtil, ...).

Không được thiếu bất kỳ tầng nào ở trên nếu code thật có gọi tới nó.

---

## 2. Repository call → Model object (bắt buộc 2 bước)

Không vẽ tắt `Repository -> trả thẳng entity đã map`. Phải vẽ đủ 2 bước:

```
Service -> Repository: findById(...)
Repository -> Service: Optional<Row>          (hoặc "Optional.empty()" nhánh lỗi)
Service -> ModelObject: map row -> User        (chỉ khi có dữ liệu)
ModelObject -> Service: User
```

Áp dụng cho **mọi** repository call có trả dữ liệu — không chỉ call đầu tiên trong flow.

---

## 3. Response object dựng ở cuối (bắt buộc)

Trước khi trả kết quả về Controller, Service phải gửi message tới lifeline Response object:

```
Service -> ResponseObject: new UserProfileResponse(user, role, workspaceId, ...)
ResponseObject -> Service: UserProfileResponse
Service -> Controller: UserProfileResponse
```

Không trả thẳng "UserProfileResponse" từ Service mà không qua lifeline Response.

---

## 4. Không request/response mồ côi trong ALT/OPT

Mỗi nhánh của khối ALT hoặc OPT phải có **request + response độc lập của riêng nó** — không dùng chung 1 request vẽ từ ngoài khối rồi để nhánh sau chỉ hiện response mà không có request tương ứng.

Sai:
```
Service -> Repo: findByUserId(...)     (vẽ 1 lần, ngoài ALT)
ALT [no record]
  Repo -> Service: Optional.empty()
ELSE [record exists]
  Repo -> Service: UserSystemRole      (mồ côi — không có request riêng)
```

Đúng: mỗi nhánh gọi lại `findByUserId(...)` độc lập, có cặp request/response riêng.

---

## 5. Activation bar tách theo nhánh

Khi 1 khối ALT có các nhánh với độ dài xử lý khác nhau (ví dụ nhánh throw kết thúc sớm, nhánh còn lại tiếp tục xử lý dài), activation bar của lifeline Service/Control **phải tách riêng theo từng nhánh** — không vẽ 1 activation bar duy nhất bao trùm cả khối ALT.

Sai: 1 activation bar cao bằng cả khối ALT (throw-branch + success-branch).
Đúng: activation bar riêng cho throw-branch (ngắn, dừng đúng lúc throw), activation bar riêng cho success-branch (dài hơn, hết block).

---

## 6. Condition label phải có nền đục

Label điều kiện `[...]` trong ALT/OPT (tab label và divider label) phải có `fillColor` đục để không bị lifeline dashed cắt ngang qua chữ:

- Tab ALT/OPT: `fillColor=#f5f5f5` (khớp màu tab).
- Divider (nhánh else/nhánh tiếp theo): `fillColor=#ffffff`, `strokeColor=none`.

Không để condition label với `fillColor` trong suốt.

---

## 7. Lifeline phải dài đúng bằng flow thực tế

Vẽ theo 2 pass:
1. Tính toàn bộ y-coordinate của message/frame trước (không vẽ lifeline ngay).
2. Sau khi có `used_bottom` (y cuối cùng thực tế), mới vẽ lifeline dài từ `y=82` tới `used_bottom`.

Không dùng hằng số cố định đoán trước — lifeline ngắn hơn nội dung thực tế là lỗi.

---

## 8. Một FR = một flow liên tục (không chia đoạn "Flow A/Flow B")

Nếu tài liệu `sequence-flow.md` mô tả nhiều "Flow" chỉ để chia đoạn diễn giải (không phải nhiều route/endpoint khác nhau), **không** vẽ thành các đoạn tách biệt có ghi chú "Flow A"/"Flow B" trên diagram — vẽ liền mạch thành 1 sequence duy nhất.

### 8a. Khi FR có nhiều route/endpoint con thật khác nhau (ví dụ `PUT /users/me` và `POST /users/me/avatar`)

Gộp thành **1 request tượng trưng duy nhất** từ Actor → UI → Controller, rồi dùng khối **ALT ngay sau khi vào Controller** để rẽ nhánh gọi đúng Service method thật của từng action con:

```
User -> UI: (hành động chung)
UI -> Controller: (1 request tượng trưng)
ALT [action con 1]
  Controller -> Service: updateUserProfile(...)
  ... (toàn bộ logic thật của action 1, giữ đúng method/entity)
ELSE [action con 2]
  Controller -> Service: updateAvatar(...)
  ... (toàn bộ logic thật của action 2, giữ đúng method/entity)
```

Quy tắc này ưu tiên gọn hình, **được phép không khớp 100% với route/HTTP method thật** (khác path, khác verb) — nhưng **toàn bộ logic bên trong mỗi nhánh** (tên method Service, Repository, Model, Response, error code) vẫn phải đúng 100% với code thật, không được bịa.

### 8b. Khi các "Flow" trong tài liệu chỉ là các nhánh business logic thật nằm trong CÙNG 1 method Service (ví dụ nhánh tìm thấy/không tìm thấy)

Không cần gộp gì thêm — đây vốn đã là 1 flow, chỉ cần áp khối ALT/OPT theo mục 4 và 5.

---

## 9. Đối chiếu code thật là bắt buộc

Trước khi vẽ, luôn phải:
1. Đọc `sequence-flow.md` cùng thư mục FR.
2. Grep/Read code thật (`*Controller`, `*ServiceImpl`, `*Repository`, model, response DTO) để xác nhận: tên method đúng, thứ tự gọi đúng, entity nào thật sự tồn tại, field nào thật sự trả về.
3. Không bịa method/entity không có trong code — nếu tài liệu và code lệch nhau, ưu tiên code thật, có thể ghi chú khác biệt nhưng không tự sửa business logic.

---

## 10. Validate trước khi coi là xong

Sau khi vẽ (hoặc sinh bằng script), luôn chạy:

```bash
python3 -c "import xml.etree.ElementTree as ET; ET.parse('<path>.drawio')"
```

XML phải parse sạch không lỗi. Ký tự đặc biệt (`<`, `>`, `"`, `&`, `<br>`) trong `value="..."` phải được escape (`&lt;`, `&gt;`, `&quot;`, `&amp;`, `&lt;br&gt;`).

---

## 11. Không tự commit

Không tự `git add`/commit các file `.drawio` — người dùng tự commit.
