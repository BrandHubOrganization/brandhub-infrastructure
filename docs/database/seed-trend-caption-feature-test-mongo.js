// Dedicated Idempotent MongoDB Seed Script for Testing:
//   - Editable POST tasks linked to all 4 Postgres campaigns (empty draft vs existing draft cases)
//   - PUBLISHED example posts per workspace for CaptionContextService.examples(workspaceId)
//
// Run against brandhub-mongodb:
//   Get-Content -Raw -Encoding UTF8 "brandhub-infrastructure\docs\database\seed-trend-caption-feature-test-mongo.js" | docker exec -i brandhub-mongodb mongosh --quiet brandhub

const managerId = "48a55552-71bd-468c-ba02-fa849eeb7682";
const creatorId = "56034372-e963-4717-8dfa-e68e34d34c7a";
const clientId = "38fcc012-0aff-426f-8466-05de1109ee13";

const wsEdu = "b47477c4-13ad-44ff-8c49-f73f1837461b";
const wsFnb1 = "d7e00000-0000-4000-8000-000000000092";
const wsTech = "d7e00000-0000-4000-8000-000000000091";
const wsFnb2 = "4934f53b-7b6b-481f-86f8-949bbb9ade28";

const campEdu = "d7e00000-0000-4000-8000-000000000301";
const campFnb1 = "d7e00000-0000-4000-8000-000000000302";
const campTech = "019de51f-a4c4-4dbd-9094-369b9a7fefad";
const campFnb2 = "d7e00000-0000-4000-8000-000000000304";

const now = new Date("2026-11-24T06:00:00.000Z");

const tasks = [
  {
    _id: "d7e00000-0000-4000-8000-000000000801",
    workspaceId: wsEdu,
    campaignId: campEdu,
    campaignWorkItemId: "d7e00000-0000-4000-8000-000000000791",
    name: "[POV Trend] Một ngày học thực tế tại khuôn viên xanh & sân Pickleball Đại học FPT",
    description:
      "Soạn caption bài đăng TikTok/Facebook bắt nhịp trend POV & khuôn viên đại học dành cho 2k9: lồng ghép trải nghiệm Lab Vi mạch, võ Vovinam, sân Pickleball và lời mời đăng ký Học bổng Nguyễn Văn Đạo 2027.",
    type: "POST",
    status: "IN_PROGRESS",
    priority: "HIGH",
    assigneeId: creatorId,
    assignedAt: now,
    assignedBy: managerId,
    supervisorId: managerId,
    initialManager: managerId,
    requiresClientApproval: true,
    approvalRound: 1,
    workflowRevision: 1,
    plannedStartDate: new Date("2026-11-23T02:00:00.000Z"),
    dueDate: new Date("2026-11-28T09:00:00.000Z"),
    publishDate: new Date("2026-11-29T09:00:00.000Z"),
    sourceType: "CAMPAIGN",
    sourceRefId: "d7e00000-0000-4000-8000-000000000791",
    createdBy: managerId,
    createdAt: now,
    updatedAt: now,
    firstStartedAt: now,
    firstStartedBy: creatorId,
    inputReferences: [
      { label: "Cổng Tuyển sinh ĐH FPT", url: "https://tuyensinh.fpt.edu.vn" },
    ],
    typeMetadata: {
      targetPlatforms: ["TIKTOK", "FACEBOOK", "INSTAGRAM"],
      acceptanceCriteria:
        "Bắt được format POV hoặc chủ đề khuôn viên đại học, xưng hô FPTU - Các bạn 2k9, có link https://tuyensinh.fpt.edu.vn và không phóng đại cam kết việc làm.",
    },
  },
  {
    _id: "d7e00000-0000-4000-8000-000000000802",
    workspaceId: wsEdu,
    campaignId: campEdu,
    campaignWorkItemId: "d7e00000-0000-4000-8000-000000000792",
    name: "[Bản nháp sẵn] Thông báo điều kiện xét Học bổng Nguyễn Văn Đạo 2027 (50%-100%)",
    description:
      "Case test giữ nguyên bản nháp có sẵn khi mở Editor: task đã có bài DRAFT trong posts, đồng thời vẫn hiển thị Context Chips và gợi ý trend theo Chiến dịch FPTU 2027.",
    type: "POST",
    status: "IN_PROGRESS",
    priority: "MEDIUM",
    assigneeId: creatorId,
    assignedAt: now,
    assignedBy: managerId,
    supervisorId: managerId,
    initialManager: managerId,
    requiresClientApproval: true,
    approvalRound: 1,
    workflowRevision: 1,
    plannedStartDate: new Date("2026-11-23T02:00:00.000Z"),
    dueDate: new Date("2026-11-30T09:00:00.000Z"),
    publishDate: new Date("2026-12-01T09:00:00.000Z"),
    sourceType: "CAMPAIGN",
    sourceRefId: "d7e00000-0000-4000-8000-000000000792",
    createdBy: managerId,
    createdAt: now,
    updatedAt: now,
    firstStartedAt: now,
    firstStartedBy: creatorId,
    typeMetadata: {
      targetPlatforms: ["FACEBOOK", "INSTAGRAM"],
      acceptanceCriteria:
        "Nêu rõ 3 mức học bổng 50%, 70%, 100% và không thay đổi tone chuyên nghiệp kết hợp gần gũi.",
    },
  },
  {
    _id: "d7e00000-0000-4000-8000-000000000803",
    workspaceId: wsFnb1,
    campaignId: campFnb1,
    campaignWorkItemId: "d7e00000-0000-4000-8000-000000000721",
    name: "[Black Friday F&B] Săn Combo Trà Ấm Bánh Ngọt giảm 30% đón gió mùa đông",
    description:
      "Bài bán hàng chủ lực cho tuần lễ Black Friday & đợt gió mùa đông đầu mùa: mời Hội mê trà bánh ghé Tiệm thưởng thức Ô Long Cầu Đất ấm nóng cùng bánh sừng bò bơ Pháp.",
    type: "POST",
    status: "IN_PROGRESS",
    priority: "HIGH",
    assigneeId: creatorId,
    assignedAt: now,
    assignedBy: managerId,
    supervisorId: managerId,
    initialManager: managerId,
    requiresClientApproval: true,
    approvalRound: 1,
    workflowRevision: 1,
    plannedStartDate: new Date("2026-11-23T02:00:00.000Z"),
    dueDate: new Date("2026-11-27T09:00:00.000Z"),
    publishDate: new Date("2026-11-28T09:00:00.000Z"),
    sourceType: "CAMPAIGN",
    sourceRefId: "d7e00000-0000-4000-8000-000000000721",
    createdBy: managerId,
    createdAt: now,
    updatedAt: now,
    firstStartedAt: now,
    firstStartedBy: creatorId,
    typeMetadata: {
      targetPlatforms: ["FACEBOOK", "INSTAGRAM", "TIKTOK"],
      acceptanceCriteria:
        "Tông thân thiện nhiều emoji theo Brand DNA (Tiệm - Bạn), nêu ưu đãi giảm 30% Black Friday và tránh các từ giảm cân thần tốc / hóa chất.",
    },
  },
  {
    _id: "d7e00000-0000-4000-8000-000000000804",
    workspaceId: wsFnb1,
    campaignId: campFnb1,
    campaignWorkItemId: "d7e00000-0000-4000-8000-000000000722",
    name: "[TikTok POV] Ngày gió lạnh ghé Tiệm thưởng thức bánh sừng bò nóng giòn cùng hội bạn",
    description:
      "Kịch bản caption ngắn cho video 9:16 bắt trend Gió mùa đông & format POV: nhóm 3 bạn trở lên được miễn phí nâng size trà Ô Long.",
    type: "POST",
    status: "TODO",
    priority: "MEDIUM",
    assigneeId: creatorId,
    assignedAt: now,
    assignedBy: managerId,
    supervisorId: managerId,
    initialManager: managerId,
    requiresClientApproval: true,
    approvalRound: 1,
    workflowRevision: 1,
    plannedStartDate: new Date("2026-11-24T02:00:00.000Z"),
    dueDate: new Date("2026-11-29T09:00:00.000Z"),
    publishDate: new Date("2026-11-30T09:00:00.000Z"),
    sourceType: "CAMPAIGN",
    sourceRefId: "d7e00000-0000-4000-8000-000000000722",
    createdBy: managerId,
    createdAt: now,
    updatedAt: now,
    typeMetadata: {
      targetPlatforms: ["TIKTOK", "INSTAGRAM"],
      acceptanceCriteria: "Hook 3 giây đầu chạm đúng cảm giác gió mùa đông thèm bánh nóng.",
    },
  },
  {
    _id: "d7e00000-0000-4000-8000-000000000805",
    workspaceId: wsTech,
    campaignId: campTech,
    campaignWorkItemId: "d7e00000-0000-4000-8000-000000000731",
    name: "[B2B Thought Leadership] Tự động hóa báo cáo cuối năm với CloudWork AI Agent & Ưu đãi Black Friday Enterprise",
    description:
      "Bài viết B2B dành cho CEO/COO doanh nghiệp SME: nhấn mạnh ROI tiết kiệm 42% thời gian họp, chuẩn bảo mật ISO/IEC 27001 và tặng 3 tháng Enterprise dịp Black Friday.",
    type: "POST",
    status: "IN_PROGRESS",
    priority: "HIGH",
    assigneeId: creatorId,
    assignedAt: now,
    assignedBy: managerId,
    supervisorId: managerId,
    initialManager: managerId,
    requiresClientApproval: true,
    approvalRound: 1,
    workflowRevision: 1,
    plannedStartDate: new Date("2026-11-23T02:00:00.000Z"),
    dueDate: new Date("2026-11-29T09:00:00.000Z"),
    publishDate: new Date("2026-11-30T09:00:00.000Z"),
    sourceType: "CAMPAIGN",
    sourceRefId: "d7e00000-0000-4000-8000-000000000731",
    createdBy: managerId,
    createdAt: now,
    updatedAt: now,
    firstStartedAt: now,
    firstStartedBy: creatorId,
    typeMetadata: {
      targetPlatforms: ["FACEBOOK", "LINKEDIN"],
      acceptanceCriteria:
        "Chuẩn Brand DNA voiceLevel=0: KHÔNG dùng emoji, KHÔNG dùng tiếng lóng giải trí, xưng hô CloudWork - Quý doanh nghiệp, CTA đặt lịch Demo 1-1.",
    },
  },
  {
    _id: "d7e00000-0000-4000-8000-000000000806",
    workspaceId: wsFnb2,
    campaignId: campFnb2,
    campaignWorkItemId: "d7e00000-0000-4000-8000-000000000741",
    name: "[Storytelling Mùa Cưới] Buổi hẹn hò đầu đông ở Nhà và hộp quà thiệp viết tay dành cho cặp đôi",
    description:
      "Bài kể chuyện giàu cảm xúc cho The Coffee House Signature trên Instagram/Facebook: lồng ghép mùa cưới cuối năm, không gian đèn vàng ấm và hộp quà trà bánh viết tay.",
    type: "POST",
    status: "IN_PROGRESS",
    priority: "HIGH",
    assigneeId: creatorId,
    assignedAt: now,
    assignedBy: managerId,
    supervisorId: managerId,
    initialManager: managerId,
    requiresClientApproval: true,
    approvalRound: 1,
    workflowRevision: 1,
    plannedStartDate: new Date("2026-11-23T02:00:00.000Z"),
    dueDate: new Date("2026-12-01T09:00:00.000Z"),
    publishDate: new Date("2026-12-02T09:00:00.000Z"),
    sourceType: "CAMPAIGN",
    sourceRefId: "d7e00000-0000-4000-8000-000000000741",
    createdBy: managerId,
    createdAt: now,
    updatedAt: now,
    firstStartedAt: now,
    firstStartedBy: creatorId,
    typeMetadata: {
      targetPlatforms: ["INSTAGRAM", "FACEBOOK", "THREADS"],
      acceptanceCriteria:
        "Tông PREMIUM + FRIENDLY (Nhà - Bạn), emoji tiết chế (few), nhấn mạnh giá trị cảm xúc mùa cưới và thiệp viết tay thay vì khuyến mãi giảm giá.",
    },
  },
];

for (const task of tasks) {
  db.tasks.replaceOne({ _id: task._id }, task, { upsert: true });
}

const posts = [
  // Existing DRAFT post for Task 0802 (tests non-overwrite when draft caption exists)
  {
    _id: "d7e00000-0000-4000-8000-000000000902",
    workspace_id: wsEdu,
    task_id: "d7e00000-0000-4000-8000-000000000802",
    created_by: creatorId,
    content_text:
      "[BẢN NHÁP HIỆN CÓ] FPTU gửi các bạn 2k9 bảng tổng hợp điều kiện xét tuyển Học bổng Nguyễn Văn Đạo 2027 (50%, 70%, 100% học phí toàn khóa). Bạn nào cần giữ nguyên đoạn mở bài này khi thử tab Editor thì hệ thống sẽ không ghi đè mất nội dung!",
    hashtags: ["#FPTUniversity", "#HocBongNguyenVanDao", "#TuyenSinh2027"],
    media: [],
    target_platforms: ["FACEBOOK", "INSTAGRAM"],
    platform: "FACEBOOK",
    ai_generated: false,
    status: "DRAFT",
    content_version: NumberLong("1"),
    created_at: now,
    updated_at: now,
  },

  // PUBLISHED voice examples for FNB1 (Tiệm Trà & Bánh Mùa Thu)
  {
    _id: "d7e00000-0000-4000-8000-000000000911",
    workspace_id: wsFnb1,
    task_id: null,
    created_by: creatorId,
    content_text:
      "Gió đầu mùa se lạnh ghé ngang phố, Tiệm vừa kịp ra lò mẻ bánh sừng bò bơ Pháp thơm nức nở cùng bình trà Ô Long nướng Cầu Đất ấm sực đôi tay 🥐🍵 Bạn tan làm sớm hay đang chạy deadline cùng Hội mê trà bánh, ghé Tiệm nạp chút ngọt ngào nhé!",
    hashtags: ["#TiemTraVaBanhMuaThu", "#TraAmBanhNgon", "#GioMuaDong"],
    media: [],
    target_platforms: ["FACEBOOK", "INSTAGRAM"],
    platform: "FACEBOOK",
    ai_generated: false,
    status: "PUBLISHED",
    content_version: NumberLong("1"),
    created_at: new Date("2026-11-18T03:00:00.000Z"),
    updated_at: new Date("2026-11-18T08:00:00.000Z"),
    published_at: new Date("2026-11-18T08:00:00.000Z"),
  },
  {
    _id: "d7e00000-0000-4000-8000-000000000912",
    workspace_id: wsFnb1,
    task_id: null,
    created_by: creatorId,
    content_text:
      "POV: Chiều thứ Sáu trốn khỏi đống email để tụ tập 3 đứa bạn thân tại góc bàn quen thuộc của Tiệm ✨ Chỉ cần gọi chung combo trà hoa quả ấm nóng + bánh tart phô mai nướng là được Tiệm miễn phí nâng size ngay nha!",
    hashtags: ["#HoiMeTraBanh", "#POVGioLanh", "#TiemTraVaBanh"],
    media: [],
    target_platforms: ["TIKTOK", "INSTAGRAM"],
    platform: "INSTAGRAM",
    ai_generated: false,
    status: "PUBLISHED",
    content_version: NumberLong("1"),
    created_at: new Date("2026-11-20T03:00:00.000Z"),
    updated_at: new Date("2026-11-20T08:00:00.000Z"),
    published_at: new Date("2026-11-20T08:00:00.000Z"),
  },

  // PUBLISHED voice examples for TECHNOLOGY (CloudWork SaaS Vietnam - formal B2B, 0 emoji)
  {
    _id: "d7e00000-0000-4000-8000-000000000921",
    workspace_id: wsTech,
    task_id: null,
    created_by: creatorId,
    content_text:
      "Trong giai đoạn tổng kết quý IV, việc thu thập số liệu tiến độ từ 5-7 phòng ban thường tiêu tốn tới 6 giờ họp mỗi tuần. Với CloudWork AI Workspace, Quý doanh nghiệp tự động hóa toàn bộ báo cáo OKR theo thời gian thực trên nền tảng đạt chuẩn bảo mật ISO/IEC 27001.",
    hashtags: ["#CloudWorkVietnam", "#QuanTriDoanhNghiep", "#AIAgent", "#B2BSaaS"],
    media: [],
    target_platforms: ["FACEBOOK", "LINKEDIN"],
    platform: "FACEBOOK",
    ai_generated: false,
    status: "PUBLISHED",
    content_version: NumberLong("1"),
    created_at: new Date("2026-11-17T03:00:00.000Z"),
    updated_at: new Date("2026-11-17T09:00:00.000Z"),
    published_at: new Date("2026-11-17T09:00:00.000Z"),
  },
  {
    _id: "d7e00000-0000-4000-8000-000000000922",
    workspace_id: wsTech,
    task_id: null,
    created_by: creatorId,
    content_text:
      "CloudWork đồng hành cùng Cộng đồng Lãnh đạo Số SME tối ưu hiệu suất vận hành trước thềm năm tài chính 2027: triển khai hệ thống hoàn chỉnh trong 48 giờ, giảm 42% thời gian tổng hợp báo cáo thủ công và kiểm soát phân quyền dữ liệu theo chuẩn Tier III Việt Nam.",
    hashtags: ["#CloudWork", "#ChuyenDoiSoSME", "#ISO27001"],
    media: [],
    target_platforms: ["LINKEDIN", "FACEBOOK"],
    platform: "LINKEDIN",
    ai_generated: false,
    status: "PUBLISHED",
    content_version: NumberLong("1"),
    created_at: new Date("2026-11-21T03:00:00.000Z"),
    updated_at: new Date("2026-11-21T09:00:00.000Z"),
    published_at: new Date("2026-11-21T09:00:00.000Z"),
  },

  // PUBLISHED voice examples for FNB2 (The Coffee House Signature - storytelling / premium)
  {
    _id: "d7e00000-0000-4000-8000-000000000931",
    workspace_id: wsFnb2,
    task_id: null,
    created_by: creatorId,
    content_text:
      "Có những chiều tháng Mười Một gió se lạnh, điều Bạn cần đôi khi chỉ là một góc bàn ánh đèn vàng ở Nhà, tách Arabica Cầu Đất thơm dịu và vài dòng tâm sự chậm rãi cùng người thương. Mùa cưới đang về rất gần, Nhà sẵn sàng gói giúp Bạn những hộp quà trà bánh kèm tấm thiệp viết tay tinh tế.",
    hashtags: ["#TheCoffeeHouseSignature", "#ChuyenNha", "#MuaCuoiCuoiNam"],
    media: [],
    target_platforms: ["INSTAGRAM", "FACEBOOK"],
    platform: "INSTAGRAM",
    ai_generated: false,
    status: "PUBLISHED",
    content_version: NumberLong("1"),
    created_at: new Date("2026-11-19T03:00:00.000Z"),
    updated_at: new Date("2026-11-19T10:00:00.000Z"),
    published_at: new Date("2026-11-19T10:00:00.000Z"),
  },
  {
    _id: "d7e00000-0000-4000-8000-000000000932",
    workspace_id: wsFnb2,
    task_id: null,
    created_by: creatorId,
    content_text:
      "Mỗi nét khắc tên lên chiếc ly sứ trắng đều lưu giữ một kỷ niệm hẹn hò đáng nhớ tại Nhà ☕ Cuối tuần này, hãy cùng Bạn của Nhà ghé không gian acoustic lắng nghe vài bản tình ca và thưởng thức vị hoa hồng Đà Lạt dịu nhẹ.",
    hashtags: ["#BanCuaNha", "#CaPheDacSan", "#HenHoCuoiDong"],
    media: [],
    target_platforms: ["INSTAGRAM", "THREADS"],
    platform: "INSTAGRAM",
    ai_generated: false,
    status: "PUBLISHED",
    content_version: NumberLong("1"),
    created_at: new Date("2026-11-22T03:00:00.000Z"),
    updated_at: new Date("2026-11-22T10:00:00.000Z"),
    published_at: new Date("2026-11-22T10:00:00.000Z"),
  },
];

for (const post of posts) {
  db.posts.replaceOne({ _id: post._id }, post, { upsert: true });
}

print(
  "Mongo seed completed cleanly. Seeded tasks=" +
    db.tasks.countDocuments({ _id: /^d7e00000-0000-4000-8000-0000000008/ }) +
    ", seeded posts=" +
    db.posts.countDocuments({ _id: /^d7e00000-0000-4000-8000-0000000009/ })
);
