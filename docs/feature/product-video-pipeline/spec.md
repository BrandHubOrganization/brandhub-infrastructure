# Product Video Pipeline — đặc tả luồng

Ngày: 30/10/2026. Trạng thái: đã triển khai code và kiểm chứng local bằng provider/API fixture, clip tổng hợp cùng bộ dựng/editor thật; chưa gọi Veo có tính phí hoặc áp dụng migration vào database đang dùng. User đã chọn ba mẫu review/unboxing/giới thiệu sản phẩm, duyệt kịch bản/chi phí trước khi tạo, dùng credit BrandHub; phí Google chỉ theo dõi nội bộ.

## Mục tiêu

User mô tả video bằng một form. Hệ thống tìm mẫu phù hợp trong kho của dự án, điền thông tin và lập kịch bản 2–3 cảnh. User xem, sửa và duyệt chi phí trước khi tạo. Veo sinh clip cho từng cảnh; bộ dựng dựa trên công nghệ DemoVideo ghép/chỉnh sửa và giao một video hoàn chỉnh.

Hai hoặc ba clip là các cảnh nguồn của một thành phẩm. Không tự tạo thêm nhiều phương án cho mỗi cảnh. Số cảnh là thông tin có trong kịch bản user duyệt.

## Luồng đã chốt

1. **Nhập form:** ảnh và thông tin sản phẩm; nội dung/yêu cầu; mục đích như review, unboxing hoặc quảng cáo; thời lượng và tỷ lệ khung hình; thông tin chữ/logo/CTA; yêu cầu âm thanh nếu có.
2. **Tìm mẫu:** bản đầu dùng ba recipe `review`, `unboxing`, `product_showcase`; lọc theo mục đích, ngành, ảnh/tài nguyên hiện có và điều kiện đầu vào. Chọn mẫu có lý do phù hợp; không ghép toàn bộ kho vào prompt hoặc tự viết lại mọi thứ từ đầu. Các tên mẫu là mã của BrandHub, không phải lệnh Google. Kho 50 mục còn lại chỉ là nguồn nghiên cứu cho các đợt sau.
3. **Lập kịch bản:** 2–3 cảnh có vai trò, nội dung, ảnh tham chiếu, prompt riêng và chỉ dẫn dựng. Dùng chung thông tin nhận dạng sản phẩm, màu sắc, tỷ lệ, phong cách để hạn chế lệch giữa các cảnh. Không hứa loại bỏ hoàn toàn sai lệch của model.
4. **User duyệt:** hiển thị kịch bản, prompt có thể chỉnh, model/cấu hình, số clip, thời lượng nguồn, thời lượng thành phẩm dự kiến và tổng chi phí dự kiến. Chỉ bấm **Tạo video** mới khởi chạy generation có tính phí. Thay đổi làm tăng chi phí sau bước này phải được user duyệt lại.
5. **Tạo clip:** lưu và theo dõi từng cảnh; cảnh đã thành công được giữ nguyên. Không tạo lại cả bộ khi chỉ một cảnh lỗi. Không có vòng tự sinh lại vô hạn hoặc âm thầm vượt chi phí đã duyệt.
6. **Dựng tự động:** dùng kế hoạch dựng để cắt/ghép đúng thứ tự, chỉnh nhịp, chuyển cảnh, chèn chữ/logo/CTA và xử lý âm thanh theo form. Giữ lớp chữ và logo ở hậu kỳ thay vì yêu cầu Veo vẽ chữ chính xác.
7. **Kiểm tra:** kiểm khả năng giải mã, thời lượng, số frame, âm thanh, vị trí chữ và các điểm nối. Chỉ báo hoàn thành khi có file kết quả hợp lệ. Các kiểm tra tự động không được tuyên bố bảo đảm tuyệt đối hình dáng sản phẩm hoặc chất lượng thẩm mỹ.
8. **Giao kết quả:** MP4 xem/tải được, kèm bản dựng trong Video Space để tiếp tục chỉnh sửa ở những lớp hỗ trợ. Giữ clip nguồn, kế hoạch và revision; không ghi đè chỉnh sửa tay khi chạy lại.

## Ví dụ: review/unboxing chai nước hoa

| Cảnh | Vai trò | Veo tạo | Bộ dựng bổ sung |
|---|---|---|---|
| 1 | Mở đầu | Mở hộp và lấy chai ra | Nhịp mở đầu, tiếng giấy nếu cần |
| 2 | Chi tiết | Cận nắp, cạnh thủy tinh và dung dịch | Tên/đặc điểm thiết kế do user cung cấp |
| 3 | Kết | Toàn cảnh sản phẩm, ánh sáng ổn định | Logo, CTA và màn kết |

Nếu không có ảnh hộp, form/kịch bản phải làm rõ đó là bao bì giả định và được user chấp nhận, hoặc dùng cảnh khác đủ đầu vào. Không tự khẳng định mùi hương, thành phần, hiệu quả hoặc độ lưu hương từ một ảnh chai.

### Điều chỉnh sau khi user xem bản minh hoạ

User yêu cầu video có hành động mở hộp, lấy sản phẩm ra và review mùi hương. Clip pan/zoom từ một ảnh chỉ kiểm tra bộ dựng, không phải video unboxing/review đã hoàn thành. Không dùng trạng thái “đã tạo video” của fixture làm bằng chứng đã sinh các cảnh Veo thật.

- Kịch bản unboxing20giây gồm3cảnh: mở hộp/lấy chai → trải nghiệm và giới thiệu các nốt hương đã cung cấp → đặt chai vào bố cục kết với CTA. Bản15giây dùng2cảnh, giữ phần trải nghiệm/review trong cảnh2 thay vì bỏ nó để chỉ quay hero.
- Mỗi cảnh phải có hành động cụ thể, góc/chuyển động camera và âm thanh; giữ nhận dạng chai và bao bì đúng tham chiếu. Không yêu cầu tạo phần cứng chai không nhìn thấy trong ảnh. Với nước hoa, có thể dùng giấy thử hương và phản ứng reviewer, không tự suy đoán đầu xịt dưới nắp.
- Thêm `reviewScript` tuỳ chọn vào form: mỗi dòng là lời review cho một cảnh, đúng2/3dòng theo thời lượng; tối đa18từ/dòng. Lời đọc được user duyệt và đưa vào native audio của Veo, không gọi thêm một dịch vụ TTS trả phí. Có lời đọc thì phải giữ source audio. Không tự bịa lời review từ hình chai.
- User cho phép dùng thông tin **giả lập để test**, ghi rõ là mẫu: AMBER Demo, hương đầu cam bergamot, hương giữa hoa nhài, hương cuối gỗ đàn hương. Không trình bày các nốt hương này như đặc tính suy ra từ ảnh hoặc thuộc sản phẩm thật.
- User xác nhận có credit Google Flow/Google AI Pro hoặc Ultra. Lượt thử có thể tạo cảnh trong Flow theo số dư/quyền tài khoản, sau đó nhập clip thật để dựng. Credit Flow không phải credit BrandHub hoặc số dư API. Kiểm tra model/số output/chi phí thực tế và duyệt trước khi gửi3lượt sinh; không dùng API không chính thức hay vượt hạn mức.
- Việc dùng Flow cho lượt thử không tự chứng minh pipeline API đã hoạt động. Hiện cấu hình mới còn disabled, chưa có Cloud Project và Mongo journal. Không hứa video chuyển động thật đã có khi chỉ có kịch bản hoặc clip dựng từ ảnh.

## Mặc định đề xuất để giữ phạm vi gọn

- Thời lượng bản đầu đề xuất cho user chọn 15 hoặc 20 giây: tương ứng lập kế hoạch hai hoặc ba clip nguồn 8 giây theo API hiện tại, rồi cắt/dựng về độ dài đã duyệt. Không cho nhập thời lượng vượt khả năng nguồn và không tự kéo chậm/lặp cảnh để bù. Mở rộng video dài hơn cần thay đổi số cảnh/cách tạo và báo giá trước.
- Một thành phẩm, 2–3 cảnh, một lượt sinh cho mỗi cảnh. Số cảnh phụ thuộc thời lượng và mẫu; không mặc định mọi yêu cầu đều phải sinh ba clip.
- Một form chung, hiện thêm trường đầu vào cần thiết theo mẫu; thông tin thương hiệu đã có thì dùng lại theo quyền của workspace.
- Kết quả có hai thao tác chính: tải MP4 và mở trong Video Space.
- Chỉ chèn thông tin sản phẩm/giá/CTA được cung cấp hoặc đã duyệt; thiếu thì bỏ trống hoặc hỏi bổ sung.
- Âm thanh bám yêu cầu: giữ tiếng Veo phù hợp; nhạc/SFX/giọng đọc là các lớp riêng. Bản đầu không tự gọi dịch vụ giọng đọc trả phí chưa được cấu hình và chọn rõ.
- Nguồn nhạc/SFX đề xuất: kho tài nguyên gốc đã duyệt của Video Space hoặc tệp user cung cấp, kèm điều kiện sử dụng. Không mở thêm dịch vụ tìm nhạc hoặc sinh nhạc trả phí. Nếu cần một giọng đọc xuyên suốt mà chưa có nguồn đã chọn, báo thiếu đầu vào thay vì tự coi là đã hỗ trợ.
- Khi cảnh hỏng, giữ các cảnh thành công và hiển thị lựa chọn thử lại cảnh đó kèm chi phí tăng thêm. Lỗi dựng dùng lại nguồn để dựng lại, không tự gọi Veo lần nữa.
- Nếu hiệu ứng DemoVideo không ánh xạ thành lớp chỉnh được trong Video Space, lưu nguồn/kế hoạch và đánh dấu phần đã render thành media; không giả vờ đó là đối tượng 3D hoặc lớp gốc có thể sửa trực tiếp.

## Hiện trạng đã đối chiếu

- Xác minh tài liệu Google ngày 30/10/2026: các model Veo 3.1 Preview trên Gemini API đã ngừng ngày 22/10/2026. Bản triển khai này giữ Veo bằng GA trên Google Cloud (model `veo-3.1-generate-001`, có thể cấu hình Fast GA), dùng project/location/ADC riêng; không tự đổi sang Gemini Omni. Nguồn: https://ai.google.dev/gemini-api/docs/video và https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/veo/3-1-generate . Cấu hình/quota/billing thật phải sẵn sàng trước lượt tính phí; không coi API key Gemini hiện có là đủ cho đường GA.
- BrandHub AI có Veo provider và job cho một clip; đầu vào có prompt, tỷ lệ, ảnh tham chiếu và template. Có mẫu ba phần tại `app/utils/video_templates.py`, nhưng chưa có điều phối đầy đủ cho luồng thành phẩm này.
- Kho nghiên cứu có 50 mục/10 nhóm tại `video-editor-lab/docs/veo-product-video/catalog.json`. Đây mới là mô tả/nguồn tham khảo, chưa phải 50 prompt runtime đã kiểm chứng. Cần chuyển các mẫu phù hợp thành template có biến và điều kiện đầu vào; giữ ID/nguồn.
- Editor Video Space đã được tích hợp ở web. AI dựng tự động bằng DemoVideo chưa được nối vào luồng sản xuất này.
- Nguồn DemoVideo: `F:/self/DemoVideo`, quy trình chính `docs/video-edit/SKILL.md`, sổ lỗi `tools/edit/LOI_DA_GAP.md`. Tái sử dụng phần cần của FFmpeg/HyperFrames và kế hoạch dựng; không sửa dự án DemoVideo gốc, không sao chép credential, profile trình duyệt, dữ liệu phim hoặc môi trường cục bộ.
- Skill là hướng dẫn và bộ công cụ, không tự trở thành một API chạy nền. Cần lớp điều phối, thực thi và theo dõi tiến độ trong hệ thống.
- Dùng các thành phần có điều kiện phù hợp với sản phẩm thương mại; không mang workflow SeeCut-VN PolyForm Noncommercial vào runtime thương mại. Giữ giấy phép của thành phần/tài nguyên thực dùng.

## Chi phí, lỗi và quyền truy cập

- Phân biệt credit nội bộ BrandHub với phí Google. Báo chi phí dự kiến cho toàn bộ cảnh và các dịch vụ đã chọn trước generation; không quy đổi tùy tiện credit Flow thành số dư API.
- Với bản mẫu thử qua tài khoản Google Flow của user, credit Pro/Ultra chỉ dùng trong Flow; đây không phải bằng chứng đường API BrandHub đã được cấu hình hoặc chạy thật. Kiểm tra model, số output và tổng credit thực tế rồi xin duyệt lượt sinh. Nếu công cụ chưa kết nối được phiên trình duyệt đã đăng nhập, nói rõ giới hạn và hướng dẫn thao tác trực tiếp; không vượt chặn đăng nhập hoặc sao chép cookie.
- User xem và sử dụng credit BrandHub theo cấu hình giá hiện có. Phí Google/API được ghi nhận nội bộ, không hiển thị như khoản thu USD bổ sung cho user và không đưa giá vốn vào payload frontend. Không tự đặt tỷ lệ quy đổi hoặc một cơ chế thanh toán USD mới.
- Việc Google đã tính phí một clip thành công không được diễn đạt như khoản có thể tự hoàn từ Google khi bước dựng phía sau lỗi. Chính sách credit nội bộ phải tách riêng và được ghi rõ.
- Mỗi sản xuất/cảnh có ID và trạng thái lưu được; bấm lặp hoặc tải lại trang không được tạo lại lượt Veo ngoài ý muốn. Lưu tiến độ để tiếp tục từ phần đã có.
- Ảnh tham chiếu cần cho job chưa gửi được lưu riêng tư theo từng lượt với giới hạn kích thước; khởi động lại phải tiếp tục được cả job đang chờ gửi và job đã có operation. Dữ liệu render có logo cũng phải khôi phục được, không chỉ render không logo.
- Chỉ owner đúng workspace được mở/tiếp tục sản xuất và bản dựng, dùng lại quyền và storage/quota hiện có. Không đưa API key ra trình duyệt.
- Kế hoạch do AI đề xuất phải có cấu trúc và được kiểm tra; không chạy Python, JavaScript, shell hoặc tham số lệnh tùy ý do model trả về. Media và đường dẫn được phân giải từ ID đã kiểm quyền.
- Không commit/push hoặc thay đổi DB/cloud trong giai đoạn đặc tả này.

## UI và trạng thái

- Các trạng thái cần thể hiện: nhập form; đang tìm mẫu/lập kịch bản; cần bổ sung đầu vào; sẵn sàng duyệt; đang tạo từng cảnh; cần thử lại một cảnh; đang dựng/kiểm tra; hoàn thành; lỗi giữ nguyên nguồn.
- Namespace i18n đề xuất `productVideo`: `title`, `brief`, `assets`, `goal`, `style`, `duration`, `aspectRatio`, `audio`, `storyboard`, `scene`, `prompt`, `missingInputs`, `estimatedCost`, `generate`, `retryScene`, `additionalCost`, `generating`, `editing`, `validating`, `download`, `openEditor`, `failed`, `sourcesRetained`. Thêm song song vi/en khi làm UI.
- Dùng UI/theme tokens hiện có, kiểm tra light/dark và hiển thị tiến độ từng bước. Không để nguyên tên key hoặc thuật ngữ backend trong giao diện.

## Hợp đồng dữ liệu nghiệp vụ để bước lập kế hoạch kỹ thuật sử dụng

- **Brief:** mục đích, yêu cầu gốc, thông tin sản phẩm đã xác nhận, các asset ID, thời lượng/tỷ lệ, yêu cầu chữ và âm thanh.
- **Kịch bản có phiên bản:** mã mẫu và lý do chọn, số cảnh, vai trò/prompt/ảnh tham chiếu của từng cảnh, thời lượng/cấu hình, kế hoạch dựng và báo giá dự kiến.
- **Lượt sản xuất:** tham chiếu đúng phiên bản kịch bản/chi phí user đã duyệt, ID từng job Veo và media kết quả, trạng thái dựng/QC, MP4 cuối và ID bản dựng Video Space.
- Routes, lưu trữ, adapter DemoVideo và cách chạy job sẽ được quyết định trong `plan.md` theo code thực tế. Các mục trên không phải endpoint đã tồn tại.

## Điều kiện hoàn thành và kiểm chứng cần có

Quan sát bản mẫu Flow thật ngày 30/10: clip giao diện ghi 8 giây nhưng file tải xuống có 190 khung hình ở24fps (~7,92 giây). Bước dựng phải kiểm tra đủ khung hình thực sự được kịch bản sử dụng; bản20giây dùng168khung/cảnh vẫn hợp lệ. Không lặp/đóng băng để giả đủ nguồn; cảnh dùng192khung vẫn phải bị từ chối nếu nguồn chỉ có190.

Chưa coi luồng này là đã chạy chỉ vì có template hoặc script dựng. Cần chứng minh form → chọn mẫu → user duyệt → các clip → dựng → MP4 và mở lại bản dựng. Kiểm tra thêm việc bấm lặp, cảnh lỗi, chỉ dựng lại, thiếu ảnh hộp, thông tin sản phẩm không đủ, lệch quyền workspace, chi phí tăng khi thử lại, i18n/theme và bảo toàn sửa tay. Dùng fixture trước; lượt Veo trả phí chỉ thực hiện theo cấu hình/ngân sách được giao.

## Ngoài phạm vi bản đầu

Tự động đăng mạng xã hội, sinh hàng loạt phương án quảng cáo, thay người/khẩu hình, khôi phục các lớp/đối tượng đã dính trong MP4, tự thử lại generation vô hạn, hoặc tuyên bố mọi kỹ thuật trong catalog đã được kiểm chứng bằng video thật.

## Rà soát để lập kế hoạch

Đã có lượt rà soát độc lập đặc tả và user đã trả lời hai điểm còn mở:

1. Chỉ ba mẫu review/unboxing/giới thiệu sản phẩm cho bản đầu.
2. User dùng credit BrandHub; phí Google theo dõi nội bộ.

Giới hạn thời lượng 15/20 giây và dùng kho âm thanh hiện có là lựa chọn triển khai được đề xuất để bám 2–3 clip nguồn 8 giây và giữ phạm vi gọn. Hợp đồng giữ/trừ/hoàn credit sẽ dùng cơ chế tài chính hiện có và được ghi cụ thể trong kế hoạch trước khi viết code.
