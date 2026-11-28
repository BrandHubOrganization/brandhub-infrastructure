-- Dedicated Idempotent Seed Script for Testing:
--   (1) Client Profile Brand DNA (brand_dna JSONB)
--   (2) Campaign & Client-linked Trend-Fit Scoring + Post Application
--   (3) Zero Re-selection Gen Caption Auto-fill & Campaign/Brand Context Injection
--
-- Covers 4 distinct workspaces & campaigns across 3 industries:
--   1. EDUCATION : Đại học FPT Tuyển sinh 2027 x SE08 Digital (REGISTRATION_LEADS / CREATIVE)
--   2. FNB       : Tiệm Trà & Bánh Mùa Thu x SE08 Digital (SALES_CONVERSION / FRIENDLY / Gió mùa đông + Black Friday)
--   3. TECHNOLOGY: CloudWork SaaS Vietnam x SE08 Digital (B2B SaaS / PROFESSIONAL / voiceLevel=0 / emoji=none)
--   4. FNB       : The Coffee House x Circus Digital (EMOTIONAL_STORY / PREMIUM / Mùa cưới & Hẹn hò cuối năm)
--
-- Run against brandhub-postgres:
--   docker exec -i brandhub-postgres sh -c 'psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB"' < brandhub-infrastructure/docs/database/seed-trend-caption-feature-test.sql

BEGIN;

DO $$
DECLARE
  v_manager_id uuid := COALESCE(
    (SELECT id FROM users WHERE email = 'nguyenthanhloc20092004@gmail.com' LIMIT 1),
    '48a55552-71bd-468c-ba02-fa849eeb7682'::uuid
  );
  v_creator_id uuid := COALESCE(
    (SELECT id FROM users WHERE email = 'chontem123@gmail.com' LIMIT 1),
    '56034372-e963-4717-8dfa-e68e34d34c7a'::uuid
  );
  v_client_user_id uuid := COALESCE(
    (SELECT id FROM users WHERE email = 'winhtuan@gmail.com' LIMIT 1),
    '38fcc012-0aff-426f-8466-05de1109ee13'::uuid
  );

  v_pkg_template_id uuid := COALESCE(
    (SELECT id FROM media_packages WHERE id = '43d6ee5d-b752-4f5f-81c6-6ec369054517'),
    (SELECT id FROM media_packages LIMIT 1)
  );

  -- Workspaces
  v_ws_edu  uuid := 'b47477c4-13ad-44ff-8c49-f73f1837461b';
  v_ws_fnb1 uuid := 'd7e00000-0000-4000-8000-000000000092';
  v_ws_tech uuid := 'd7e00000-0000-4000-8000-000000000091';
  v_ws_fnb2 uuid := '4934f53b-7b6b-481f-86f8-949bbb9ade28';

  -- Client Profiles
  v_cp_edu  uuid := 'd7e00000-0000-4000-8000-000000000001';
  v_cp_fnb1 uuid := 'd7e00000-0000-4000-8000-000000000002';
  v_cp_tech uuid := 'd7e00000-0000-4000-8000-000000000003';
  v_cp_fnb2 uuid := '85fc36ce-24c3-7ef2-45a6-3d5565e7cdeb';

  -- Workspace Media Packages
  v_wmp_edu  uuid := 'd7e00000-0000-4000-8000-000000000201';
  v_wmp_fnb1 uuid := 'd7e00000-0000-4000-8000-000000000202';
  v_wmp_tech uuid := 'b20f050b-068b-4b38-97ce-6c91375aca98';
  v_wmp_fnb2 uuid := '2e26351a-c169-4690-a539-936bd54af3e0';
BEGIN
  -- ============================================================================
  -- SCENARIO 1: EDUCATION - Đại học FPT Tuyển sinh 2027 (Creative / Leads)
  -- ============================================================================
  UPDATE workspaces
     SET industry = 'EDUCATION'::workspace_industry,
         tagline = 'Trải nghiệm để thành công - Định hình thế hệ công dân toàn cầu',
         description = 'Kênh truyền thông tuyển sinh khóa K23 Đại học FPT tại 5 cơ sở toàn quốc: Công nghệ AI, Vi mạch bán dẫn, OJT doanh nghiệp và Học bổng Nguyễn Văn Đạo.',
         updated_at = now()
   WHERE id = v_ws_edu;

  INSERT INTO client_profiles (
    id, user_id, display_name, company, industry, tagline, description,
    website, location, contact_name, contact_email, brand_dna, created_at, updated_at
  ) VALUES (
    v_cp_edu,
    v_client_user_id,
    'Ban Tuyển sinh Đại học FPT',
    'Trường Đại học FPT (FPT University)',
    'EDUCATION',
    'Trải nghiệm để thành công',
    'Đơn vị tư vấn hướng nghiệp, xét tuyển đại học chính quy khóa K23 (2027) và Học bổng Nguyễn Văn Đạo tại 5 cơ sở của Trường Đại học FPT.',
    'https://tuyensinh.fpt.edu.vn',
    'Hà Nội - Đà Nẵng - Quy Nhơn - TP.HCM - Cần Thơ',
    'Nguyễn Minh Tuấn',
    'winhtuan@gmail.com',
    '{
      "targetAudience": "Học sinh THPT lớp 12 (2k9) yêu thích công nghệ, năng động và phụ huynh quan tâm học bổng Nguyễn Văn Đạo, thực tập doanh nghiệp OJT",
      "voiceLevel": 2,
      "defaultTones": ["CREATIVE", "PROFESSIONAL", "FRIENDLY"],
      "pronoun": "FPTU - Các bạn 2k9",
      "fanName": "Cóc FPTU",
      "emojiUsage": "few",
      "productFacts": [
        "Đào tạo các ngành mũi nhọn Thiết kế Vi mạch bán dẫn, Trí tuệ nhân tạo, Kỹ thuật phần mềm và Kinh tế số",
        "100% sinh viên tham gia học kỳ thực tập doanh nghiệp OJT từ học kỳ 6 tại FPT Software và đối tác toàn cầu",
        "Học bổng Nguyễn Văn Đạo mức 50%, 70%, 100% học phí toàn khóa tại 5 cơ sở toàn quốc",
        "Hệ sinh thái khuôn viên xanh hiện đại với hơn 40 CLB sinh viên, võ Vovinam và sân Pickleball"
      ],
      "taboos": [
        "cam kết việc làm lương nghìn đô 100%",
        "so sánh hạ thấp trường đại học khác",
        "chính trị nhạy cảm",
        "cờ bạc cá độ"
      ]
    }'::jsonb,
    now(),
    now()
  )
  ON CONFLICT (id) DO UPDATE
    SET industry = EXCLUDED.industry,
        tagline = EXCLUDED.tagline,
        description = EXCLUDED.description,
        brand_dna = EXCLUDED.brand_dna,
        updated_at = now();

  UPDATE media_campaigns
     SET status = 'IN_PROGRESS'::campaign_status,
         strategy_detail = 'Triển khai chuỗi nội dung đa nền tảng cho mùa tuyển sinh Đại học FPT 2027 (K23): mở rộng nhận diện qua trải nghiệm khuôn viên xanh, phòng Lab AI/Vi mạch, đời sống CLB thể thao Pickleball/Vovinam và tối ưu đăng ký xét tuyển học bổng Nguyễn Văn Đạo.',
         brand_guideline = 'Giữ tông giọng trẻ trung, truyền cảm hứng công nghệ nhưng chuẩn xác thông tin học bổng (50%-70%-100%) và cổng https://tuyensinh.fpt.edu.vn. Ưu tiên góc nhìn POV đời sống sinh viên tại khuôn viên trường.',
         timeline = jsonb_set(
           COALESCE(timeline, '{}'::jsonb),
           '{brief}',
           '{
             "objectives": ["REGISTRATION_LEADS", "BRAND_AWARENESS", "EVENT_LAUNCH"],
             "conceptType": "EXPERIENTIAL_INTERACTIVE",
             "conceptIdea": "Đưa trải nghiệm thực tế khuôn viên xanh Hòa Lạc, phòng Lab Vi mạch/AI, sân Pickleball và đời sống 40+ CLB Đại học FPT thành chuỗi bài POV đa nền tảng kết hợp Workshop & Open Day.",
             "keyMessage": "Tuyển sinh Đại học FPT 2027: Học thực tế tại khuôn viên xanh chuẩn quốc tế, OJT từ học kỳ 6 và cơ hội Học bổng Nguyễn Văn Đạo tới 100%.",
             "uspFocus": "Thực tập doanh nghiệp OJT 100%, Học bổng Nguyễn Văn Đạo 2027, Lab Vi mạch & AI tại 5 cơ sở",
             "seasonalHook": "Mùa định hướng chọn ngành của học sinh 2k9 & chuỗi sự kiện Open Day cuối năm",
             "primaryCta": "REGISTER_NOW",
             "brandTones": ["CREATIVE", "PROFESSIONAL", "FRIENDLY"],
             "channels": ["TikTok", "Facebook", "Instagram", "Threads"],
             "targetAudiences": ["GEN_Z", "STUDENTS"],
             "audienceInsights": ["EXPERIENCE_NOVELTY", "SOCIAL_PROOF"],
             "audienceNote": "Học sinh 2k9 muốn thấy tận mắt khuôn viên đại học, ký túc xá, sân thể thao Pickleball, phòng Lab AI và lắng nghe chia sẻ thật từ sinh viên đi OJT.",
             "contentPillars": ["PRODUCT_SPOTLIGHT", "BEHIND_THE_SCENES", "USER_STORIES_REVIEWS"],
             "campaignFormats": ["DIGITAL_SOCIAL", "OFFLINE_ACTIVATION", "INFLUENCER_PR"],
             "eventFormat": "HYBRID",
             "eventLocation": "Hệ thống 5 cơ sở Đại học FPT (Hà Nội, Đà Nẵng, Quy Nhơn, TP.HCM, Cần Thơ)",
             "expectedScale": "2.500 học sinh lớp 12 và phụ huynh tham dự Workshop & FPTU Open Day 2027",
             "notes": "Mỗi bài đều dẫn link đăng ký chính thức https://tuyensinh.fpt.edu.vn; không phóng đại cam kết lương."
           }'::jsonb,
           true
         ),
         updated_at = now()
   WHERE id = 'd7e00000-0000-4000-8000-000000000301'
     AND workspace_media_package_id = v_wmp_edu;

  -- ============================================================================
  -- SCENARIO 2: FNB - Tiệm Trà & Bánh Mùa Thu (Sales / Gió mùa đông & Black Friday)
  -- ============================================================================
  UPDATE workspaces
     SET industry = 'FNB'::workspace_industry,
         tagline = 'Ấm vị trà ngon, giòn tan bánh nướng mỗi sáng',
         description = 'Thương hiệu F&B đồ uống và bánh ngọt thủ công dành cho Gen Z và dân văn phòng: cốt trà Ô Long nướng Cầu Đất, bánh sừng bò bơ Pháp và không gian chill mùa đông.',
         updated_at = now()
   WHERE id = v_ws_fnb1;

  INSERT INTO client_profiles (
    id, user_id, display_name, company, industry, tagline, description,
    website, location, contact_name, contact_email, brand_dna, created_at, updated_at
  ) VALUES (
    v_cp_fnb1,
    v_client_user_id,
    'Tiệm Trà & Bánh Mùa Thu',
    'Công ty TNHH Tiệm Trà & Bánh Mùa Thu',
    'FNB',
    'Ấm vị trà ngon, giòn tan bánh nướng mỗi sáng',
    'Chuỗi tiệm trà trái cây ấm và bánh ngọt thủ công nướng mới mỗi ngày tại Hà Nội & TP.HCM.',
    'https://tiemtrabanhmuathu.vn',
    'Quận 1 (TP.HCM) & Cầu Giấy (Hà Nội)',
    'Nguyễn Minh Tuấn',
    'winhtuan@gmail.com',
    '{
      "targetAudience": "Gen Z, sinh viên và dân văn phòng 18-30 tuổi thích trà hoa quả ấm, bánh ngọt thủ công và tụ tập bạn bè mùa lạnh",
      "voiceLevel": 2,
      "defaultTones": ["FRIENDLY", "ENERGETIC"],
      "pronoun": "Tiệm - Bạn",
      "fanName": "Hội mê trà bánh",
      "emojiUsage": "many",
      "productFacts": [
        "100% cốt trà Ô Long nướng Cầu Đất ủ mới mỗi 4 giờ kết hợp đường mía hữu cơ thanh nhẹ",
        "Bánh sừng bò bơ Pháp và bánh tart phô mai nướng nóng tại lò mỗi sáng",
        "Combo Gió Mùa Đông Trà Ấm + Bánh Ngọt giảm ngay 30% trong tuần lễ Black Friday",
        "Miễn phí nâng size cho nhóm bạn từ 3 người ghé tiệm từ 14h-17h"
      ],
      "taboos": [
        "giảm cân thần tốc",
        "trà sữa hóa chất giá rẻ",
        "cận bình",
        "chính trị",
        "bạo lực"
      ]
    }'::jsonb,
    now(),
    now()
  )
  ON CONFLICT (id) DO UPDATE
    SET display_name = EXCLUDED.display_name,
        company = EXCLUDED.company,
        industry = EXCLUDED.industry,
        tagline = EXCLUDED.tagline,
        description = EXCLUDED.description,
        brand_dna = EXCLUDED.brand_dna,
        updated_at = now();

  INSERT INTO workspace_members (
    id, workspace_id, user_id, client_profile_id, role, added_by, joined_at, is_active, created_at, updated_at
  ) VALUES (
    'd7e00000-0000-4000-8000-000000000192',
    v_ws_fnb1,
    v_client_user_id,
    v_cp_fnb1,
    'CLIENT'::workspace_member_role,
    v_manager_id,
    now(),
    true,
    now(),
    now()
  )
  ON CONFLICT (workspace_id, user_id) WHERE (user_id IS NOT NULL) DO UPDATE
    SET client_profile_id = EXCLUDED.client_profile_id,
        role = 'CLIENT'::workspace_member_role,
        is_active = true,
        updated_at = now();

  INSERT INTO workspace_media_packages (
    id, workspace_id, package_id, negotiation_status, final_terms, terms_version,
    approved_by_agency_at, approved_by_client_at, manager_led, preparation_status, created_at, updated_at
  ) VALUES (
    v_wmp_fnb1,
    v_ws_fnb1,
    v_pkg_template_id,
    'APPROVED'::package_negotiation_status,
    '{
      "packageName": "Gói Chiến dịch Mùa Đông & Black Friday F&B",
      "durationWeeks": 4,
      "budgetAmount": 32000000,
      "deliverables": [
        {"id": "d7e00000-0000-4000-8000-000000000261", "name": "Bài Social giới thiệu Menu Trà Ấm & Bánh Ngọt", "unit": "bài", "quantity": 10, "serviceType": "SOCIAL_POST"},
        {"id": "d7e00000-0000-4000-8000-000000000262", "name": "Video ngắn 9:16 POV Gió Mùa Đông", "unit": "video", "quantity": 4, "serviceType": "SHORT_VIDEO"}
      ]
    }'::jsonb,
    1,
    now(),
    now(),
    true,
    'DEPLOYED',
    now(),
    now()
  )
  ON CONFLICT (workspace_id) DO UPDATE
    SET negotiation_status = 'APPROVED'::package_negotiation_status,
        preparation_status = 'DEPLOYED',
        updated_at = now();

  SELECT id INTO v_wmp_fnb1 FROM workspace_media_packages WHERE workspace_id = v_ws_fnb1 LIMIT 1;

  UPDATE workspaces
     SET workspace_media_package_id = v_wmp_fnb1,
         updated_at = now()
   WHERE id = v_ws_fnb1;

  INSERT INTO media_campaigns (
    id, workspace_media_package_id, name, strategy_detail, brand_guideline,
    allocation_period, allocations, deliverable_plan, work_items,
    timeline, status, approved_by_agency_at, approved_by_client_at, created_at, updated_at
  ) VALUES (
    'd7e00000-0000-4000-8000-000000000302',
    v_wmp_fnb1,
    'Chiến dịch Menu Gió Mùa Đông & Đại Tiệc Black Friday: Trà Ấm Bánh Ngon Chữa Lành Deadline',
    'Đẩy mạnh doanh số combo trà ấm & bánh nướng mùa lạnh trong đợt gió mùa đông đầu mùa và tuần lễ Black Friday. Tận dụng các format POV bắt trend văn phòng/sinh viên và ưu đãi mua combo nhận quà miễn phí.',
    'Ngôn ngữ gần gũi, giàu cảm xúc ấm áp mùa đông, nhiều emoji tự nhiên theo Brand DNA. Nhấn mạnh nguyên liệu trà Ô Long thật, bánh nướng mới, tránh mọi từ ngữ thổi phồng giảm cân hay so sánh giá rẻ hóa chất.',
    'WEEKLY',
    '[]'::jsonb,
    '[]'::jsonb,
    '[
      {"id": "d7e00000-0000-4000-8000-000000000721", "name": "[Black Friday F&B] Săn Combo Trà Ấm Bánh Ngọt giảm 30% đón gió mùa đông", "type": "POST", "dueDate": "2026-11-28T09:00:00Z", "deliverableId": "d7e00000-0000-4000-8000-000000000261"},
      {"id": "d7e00000-0000-4000-8000-000000000722", "name": "[TikTok POV] Ngày gió lạnh ghé Tiệm thưởng thức bánh sừng bò nóng giòn cùng hội bạn", "type": "POST", "dueDate": "2026-11-30T09:00:00Z", "deliverableId": "d7e00000-0000-4000-8000-000000000262"}
    ]'::jsonb,
    '{
      "startDate": "2026-11-18",
      "endDate": "2026-12-15",
      "brief": {
        "objectives": ["SALES_CONVERSION", "COMMUNITY_ENGAGEMENT"],
        "conceptType": "CONVERSION_OFFER_PUSH",
        "conceptIdea": "Biến Tiệm Trà & Bánh Mùa Thu thành điểm hẹn trốn gió lạnh và săn deal Black Friday siêu hời dành cho hội mê trà bánh văn phòng và sinh viên.",
        "keyMessage": "Gió mùa đông về rồi, ghé Tiệm ôm ly trà Ô Long ấm nóng cùng chiếc bánh sừng bò bơ Pháp giảm 30% tuần lễ Black Friday!",
        "uspFocus": "Trà Ô Long Cầu Đất ủ mới mỗi 4h, bánh bơ Pháp nướng lò mỗi sáng & Deal Black Friday giảm 30% combo",
        "seasonalHook": "Đợt gió mùa đông tràn về & Tuần lễ siêu sale Black Friday cuối tháng 11",
        "primaryCta": "BUY_WITH_OFFER",
        "brandTones": ["FRIENDLY", "ENERGETIC"],
        "channels": ["Facebook", "Instagram", "TikTok"],
        "targetAudiences": ["GEN_Z", "OFFICE_WORKERS"],
        "audienceInsights": ["VALUE_FOR_MONEY", "EXPERIENCE_NOVELTY"],
        "audienceNote": "Dân văn phòng và sinh viên tìm đồ uống ấm bụng giờ nghỉ trưa/tan làm và thích rủ nhóm bạn đi săn ưu đãi Black Friday.",
        "contentPillars": ["PROMO_CTA", "PRODUCT_SPOTLIGHT", "COMMUNITY_MINIGAME"],
        "campaignFormats": ["PROMOTION_SEASONAL", "DIGITAL_SOCIAL"],
        "notes": "Luôn đính kèm khung giờ mở bán bánh nóng (8h-21h) và mã ưu đãi tại quầy."
      }
    }'::jsonb,
    'IN_PROGRESS'::campaign_status,
    now(),
    now(),
    now(),
    now()
  )
  ON CONFLICT (workspace_media_package_id) DO UPDATE
    SET name = EXCLUDED.name,
        strategy_detail = EXCLUDED.strategy_detail,
        brand_guideline = EXCLUDED.brand_guideline,
        work_items = EXCLUDED.work_items,
        timeline = EXCLUDED.timeline,
        status = 'IN_PROGRESS'::campaign_status,
        updated_at = now();

  -- ============================================================================
  -- SCENARIO 3: TECHNOLOGY - CloudWork SaaS Vietnam (B2B Formal / voiceLevel=0)
  -- ============================================================================
  UPDATE workspaces
     SET industry = 'TECHNOLOGY'::workspace_industry,
         tagline = 'Tự động hóa vận hành doanh nghiệp bằng AI Agent',
         description = 'Nền tảng SaaS B2B giúp CEO và đội ngũ SME Việt Nam quản trị công việc, tự động hóa báo cáo và tiết kiệm 42% thời gian họp mỗi tuần.',
         updated_at = now()
   WHERE id = v_ws_tech;

  INSERT INTO client_profiles (
    id, user_id, display_name, company, industry, tagline, description,
    website, location, contact_name, contact_email, brand_dna, created_at, updated_at
  ) VALUES (
    v_cp_tech,
    v_client_user_id,
    'CloudWork SaaS Vietnam',
    'Công ty Cổ phần Công nghệ CloudWork Việt Nam',
    'TECHNOLOGY',
    'Tự động hóa vận hành doanh nghiệp bằng AI Agent',
    'Giải pháp SaaS B2B quản trị quy trình, OKR và trợ lý AI nội bộ dành cho doanh nghiệp SME từ 20 đến 500 nhân sự tại Việt Nam.',
    'https://cloudwork.vn',
    'Quận Cầu Giấy, Hà Nội & Quận 1, TP.HCM',
    'Nguyễn Minh Tuấn',
    'winhtuan@gmail.com',
    '{
      "targetAudience": "CEO, Giám đốc vận hành (COO), Trưởng phòng Nhân sự & IT tại các doanh nghiệp SME Việt Nam (20-500 nhân sự)",
      "voiceLevel": 0,
      "defaultTones": ["PROFESSIONAL"],
      "pronoun": "CloudWork - Quý doanh nghiệp",
      "fanName": "Cộng đồng Lãnh đạo Số SME",
      "emojiUsage": "none",
      "productFacts": [
        "Tích hợp AI Agent tự động tổng hợp tiến độ dự án và báo cáo tuần giảm 42% thời gian họp",
        "Đạt tiêu chuẩn bảo mật quốc tế ISO/IEC 27001, lưu trữ tại Data Center chuẩn Tier III Việt Nam",
        "Triển khai nhanh trong 48 giờ cho doanh nghiệp quy mô từ 20 đến 500 nhân sự",
        "Ưu đãi Black Friday B2B: Tặng 3 tháng sử dụng gói Enterprise khi ký hợp đồng năm trước 30/11"
      ],
      "taboos": [
        "hack",
        "crack phần mềm",
        "miễn phí trọn đời không điều kiện",
        "drama showbiz",
        "xe ôm",
        "gta vi"
      ]
    }'::jsonb,
    now(),
    now()
  )
  ON CONFLICT (id) DO UPDATE
    SET display_name = EXCLUDED.display_name,
        company = EXCLUDED.company,
        industry = EXCLUDED.industry,
        tagline = EXCLUDED.tagline,
        description = EXCLUDED.description,
        brand_dna = EXCLUDED.brand_dna,
        updated_at = now();

  UPDATE workspace_members
     SET client_profile_id = v_cp_tech,
         is_active = true,
         updated_at = now()
   WHERE workspace_id = v_ws_tech
     AND role = 'CLIENT'::workspace_member_role;

  UPDATE workspace_media_packages
     SET negotiation_status = 'APPROVED'::package_negotiation_status,
         preparation_status = 'DEPLOYED',
         updated_at = now()
   WHERE id = v_wmp_tech;

  UPDATE media_campaigns
     SET name = 'Chiến dịch Ra mắt CloudWork AI Workspace 2027 & Ưu đãi Black Friday cho Doanh nghiệp SME',
         strategy_detail = 'Xây dựng uy tín công nghệ B2B qua các case study đo lường ROI, giải pháp AI Agent tối ưu vận hành cuối năm và chương trình đặt lịch Demo nhận ưu đãi Black Friday Enterprise dành cho cấp quản lý SME.',
         brand_guideline = 'TUYỆT ĐỐI chuẩn mực B2B (voiceLevel=0), KHÔNG dùng emoji, KHÔNG dùng tiếng lóng hay bắt trend giải trí/showbiz. Dùng số liệu ROI cụ thể và xưng hô CloudWork - Quý doanh nghiệp.',
         work_items = '[
           {"id": "d7e00000-0000-4000-8000-000000000731", "name": "[B2B Thought Leadership] Tự động hóa báo cáo cuối năm với CloudWork AI Agent & Ưu đãi Black Friday Enterprise", "type": "POST", "dueDate": "2026-11-29T09:00:00Z", "deliverableId": "b20f050b-068b-4b38-97ce-6c91375aca98"}
         ]'::jsonb,
         timeline = '{
           "startDate": "2026-11-15",
           "endDate": "2026-12-20",
           "brief": {
             "objectives": ["BRAND_AWARENESS", "PR_CREDIBILITY"],
             "conceptType": "EXPERT_TRUST_EDUCATIONAL",
             "conceptIdea": "Phân tích bài toán tắc nghẽn báo cáo cuối năm tại SME Việt Nam và minh chứng giải pháp AI Workspace chuẩn ISO/IEC 27001 qua số liệu vận hành thực tế.",
             "keyMessage": "CloudWork AI Workspace giúp Quý doanh nghiệp giảm 42% thời gian họp báo cáo cuối năm và sẵn sàng bứt tốc kế hoạch 2027.",
             "uspFocus": "Tiết kiệm 42% thời gian báo cáo, chuẩn bảo mật ISO/IEC 27001, tặng 3 tháng Enterprise dịp Black Friday B2B",
             "seasonalHook": "Giai đoạn tổng kết KPI quý 4, lập ngân sách công nghệ 2027 & ưu đãi doanh nghiệp cuối tháng 11",
             "primaryCta": "BOOK_DEMO_CONSULT",
             "brandTones": ["PROFESSIONAL"],
             "channels": ["Facebook", "EMAIL", "PR_PRESS"],
             "targetAudiences": ["B2B_PARTNERS", "OFFICE_WORKERS"],
             "audienceInsights": ["TRUST_SECURITY", "TIME_SAVING"],
             "audienceNote": "CEO và COO quan tâm tính bảo mật dữ liệu doanh nghiệp, thời gian triển khai thực tế và khả năng kết nối với hệ thống nhân sự/kế toán sẵn có.",
             "contentPillars": ["EXPERT_TIPS", "PRODUCT_SPOTLIGHT", "USER_STORIES_REVIEWS"],
             "campaignFormats": ["BRAND_LAUNCH", "DIGITAL_SOCIAL"],
             "notes": "Không sử dụng emoji; luôn đính kèm nút đặt lịch Demo 1-1 cùng chuyên gia giải pháp."
           }
         }'::jsonb,
         status = 'IN_PROGRESS'::campaign_status,
         updated_at = now()
   WHERE id = '019de51f-a4c4-4dbd-9094-369b9a7fefad'
     AND workspace_media_package_id = v_wmp_tech;

  -- ============================================================================
  -- SCENARIO 4: FNB CONTRAST - The Coffee House Signature (Storytelling / Premium)
  -- ============================================================================
  UPDATE workspaces
     SET industry = 'FNB'::workspace_industry,
         tagline = 'Nơi mỗi tách cà phê kể một câu chuyện kết nối',
         description = 'Dòng cửa hàng Flagship Signature với trải nghiệm cà phê đặc sản Việt Nam, bánh ngọt nghệ nhân và không gian hẹn hò ấm áp mùa lễ hội cuối năm.',
         updated_at = now()
   WHERE id = v_ws_fnb2;

  INSERT INTO client_profiles (
    id, user_id, display_name, company, industry, tagline, description,
    website, location, contact_name, contact_email, brand_dna, created_at, updated_at
  ) VALUES (
    v_cp_fnb2,
    v_client_user_id,
    'The Coffee House Signature',
    'Công ty Cổ phần Thương mại Dịch vụ Trà Cà Phê VN',
    'FNB',
    'Nơi mỗi tách cà phê kể một câu chuyện kết nối',
    'Không gian thưởng thức cà phê đặc sản và tiệc trà thân mật cho các cặp đôi, hội bạn thân dịp mùa cưới và lễ hội cuối năm.',
    'https://thecoffeehouse.com',
    'TP.HCM - Hà Nội - Đà Nẵng',
    'Nguyễn Minh Tuấn',
    'winhtuan@gmail.com',
    '{
      "targetAudience": "Cặp đôi trẻ, dân sáng tạo và nhóm bạn 24-35 tuổi yêu trải nghiệm cà phê thủ công tinh tế và không gian trò chuyện cuối năm",
      "voiceLevel": 1,
      "defaultTones": ["PREMIUM", "FRIENDLY"],
      "pronoun": "Nhà - Bạn",
      "fanName": "Bạn của Nhà",
      "emojiUsage": "few",
      "productFacts": [
        "Hạt Arabica Cầu Đất tuyển chọn rang mộc kết hợp syrup hoa hồng Đà Lạt dịu nhẹ",
        "Bộ đôi hộp quà trà bánh Mùa Cưới & Hẹn Hò thiết kế tinh xảo giới hạn tháng 11-12",
        "Không gian Signature ánh đèn vàng ấm, âm nhạc acoustic cuối tuần lý tưởng cho những buổi tâm sự",
        "Dịch vụ khắc tên lên ly sứ và thiệp viết tay miễn phí cho đơn quà tặng"
      ],
      "taboos": [
        "câu view giật gân",
        "bình phẩm đời tư nghệ sĩ",
        "chính trị",
        "hàng giả"
      ]
    }'::jsonb,
    now(),
    now()
  )
  ON CONFLICT (id) DO UPDATE
    SET display_name = EXCLUDED.display_name,
        company = EXCLUDED.company,
        industry = EXCLUDED.industry,
        tagline = EXCLUDED.tagline,
        description = EXCLUDED.description,
        brand_dna = EXCLUDED.brand_dna,
        updated_at = now();

  INSERT INTO workspace_members (
    id, workspace_id, user_id, role, added_by, joined_at, is_active, created_at, updated_at
  ) VALUES (
    'd7e00000-0000-4000-8000-000000000193',
    v_ws_fnb2,
    v_manager_id,
    'MANAGER'::workspace_member_role,
    v_manager_id,
    now(),
    true,
    now(),
    now()
  )
  ON CONFLICT (workspace_id, user_id) WHERE (user_id IS NOT NULL) DO UPDATE
    SET role = 'MANAGER'::workspace_member_role,
        is_active = true,
        updated_at = now();

  INSERT INTO workspace_members (
    id, workspace_id, user_id, role, added_by, joined_at, is_active, created_at, updated_at
  ) VALUES (
    'd7e00000-0000-4000-8000-000000000194',
    v_ws_fnb2,
    v_creator_id,
    'CREATOR'::workspace_member_role,
    v_manager_id,
    now(),
    true,
    now(),
    now()
  )
  ON CONFLICT (workspace_id, user_id) WHERE (user_id IS NOT NULL) DO UPDATE
    SET role = 'CREATOR'::workspace_member_role,
        is_active = true,
        updated_at = now();

  UPDATE workspace_media_packages
     SET negotiation_status = 'APPROVED'::package_negotiation_status,
         approved_by_agency_at = COALESCE(approved_by_agency_at, now()),
         approved_by_client_at = COALESCE(approved_by_client_at, now()),
         manager_led = true,
         preparation_status = 'DEPLOYED',
         updated_at = now()
   WHERE id = v_wmp_fnb2;

  INSERT INTO media_campaigns (
    id, workspace_media_package_id, name, strategy_detail, brand_guideline,
    allocation_period, allocations, deliverable_plan, work_items,
    timeline, status, approved_by_agency_at, approved_by_client_at, created_at, updated_at
  ) VALUES (
    'd7e00000-0000-4000-8000-000000000304',
    v_wmp_fnb2,
    'Chiến dịch Chuyện Nhà Mùa Cưới & Hẹn Hò Cuối Năm: Tách Cà Phê Kết Nối Yêu Thương',
    'Khác với chiến dịch săn sale giảm giá, chiến dịch của Nhà tập trung vào kể chuyện cảm xúc (Emotional Storytelling) quanh mùa cưới cuối năm, những buổi hẹn hò đầu đông và bộ quà tặng thiệp viết tay tinh tế.',
    'Giọng văn dịu dàng, tinh tế, giàu chất thơ (tông PREMIUM + FRIENDLY, emoji tiết chế tối đa 1-2 biểu tượng). Tránh từ ngữ hô hào giảm giá sốc hay ngôn ngữ giật gân.',
    'WEEKLY',
    '[]'::jsonb,
    '[]'::jsonb,
    '[
      {"id": "d7e00000-0000-4000-8000-000000000741", "name": "[Storytelling Mùa Cưới] Buổi hẹn hò đầu đông ở Nhà và hộp quà thiệp viết tay dành cho cặp đôi", "type": "POST", "dueDate": "2026-12-01T09:00:00Z", "deliverableId": "2e26351a-c169-4690-a539-936bd54af3e0"}
    ]'::jsonb,
    '{
      "startDate": "2026-11-10",
      "endDate": "2026-12-24",
      "brief": {
        "objectives": ["COMMUNITY_ENGAGEMENT"],
        "conceptType": "EMOTIONAL_STORY",
        "conceptIdea": "Kể lại những khoảnh khắc đời thường ấm áp của các cặp đôi, hội bạn thân bên ly cà phê nóng tại Nhà trong mùa cưới và những ngày gió se lạnh cuối năm.",
        "keyMessage": "Cuối năm bận rộn đến mấy, hãy dành một buổi chiều chậm lại ở Nhà cùng người thương và viết tặng nhau lời chúc chân thành.",
        "uspFocus": "Cà phê đặc sản Arabica Cầu Đất, hộp quà Mùa Cưới khắc tên & thiệp viết tay miễn phí",
        "seasonalHook": "Mùa cưới cuối năm & không khí hẹn hò đầu đông lãng mạn",
        "primaryCta": "FOLLOW_SHARE",
        "brandTones": ["PREMIUM", "FRIENDLY"],
        "channels": ["Instagram", "Facebook", "Threads"],
        "targetAudiences": ["MILLENNIALS", "YOUNG_FAMILIES"],
        "audienceInsights": ["SELF_EXPRESSION", "EXPERIENCE_NOVELTY"],
        "audienceNote": "Các cặp đôi chuẩn bị cưới và người đi làm 25-35 tuổi trân trọng chiều sâu cảm xúc, tính thẩm mỹ tinh tế hơn là khuyến mãi giảm giá.",
        "contentPillars": ["USER_STORIES_REVIEWS", "BEHIND_THE_SCENES", "PRODUCT_SPOTLIGHT"],
        "campaignFormats": ["DIGITAL_SOCIAL", "BRAND_LAUNCH"],
        "notes": "Ưu tiên hình ảnh ánh sáng ấm, kể chuyện tự sự ngắn gọn 120-180 chữ."
      }
    }'::jsonb,
    'IN_PROGRESS'::campaign_status,
    now(),
    now(),
    now(),
    now()
  )
  ON CONFLICT (workspace_media_package_id) DO UPDATE
    SET name = EXCLUDED.name,
        strategy_detail = EXCLUDED.strategy_detail,
        brand_guideline = EXCLUDED.brand_guideline,
        work_items = EXCLUDED.work_items,
        timeline = EXCLUDED.timeline,
        status = 'IN_PROGRESS'::campaign_status,
        updated_at = now();

  -- Mirror the 6 new test tasks in Postgres fallback `tasks` table
  INSERT INTO tasks (id, workspace_id, type, title, created_by, created_at, updated_at) VALUES
    ('d7e00000-0000-4000-8000-000000000801', v_ws_edu,  'POST'::task_type, '[POV Trend] Một ngày học thực tế tại khuôn viên xanh & sân Pickleball Đại học FPT', v_manager_id, now(), now()),
    ('d7e00000-0000-4000-8000-000000000802', v_ws_edu,  'POST'::task_type, '[Bản nháp sẵn] Thông báo điều kiện xét Học bổng Nguyễn Văn Đạo 2027 (50%-100%)', v_manager_id, now(), now()),
    ('d7e00000-0000-4000-8000-000000000803', v_ws_fnb1, 'POST'::task_type, '[Black Friday F&B] Săn Combo Trà Ấm Bánh Ngọt giảm 30% đón gió mùa đông', v_manager_id, now(), now()),
    ('d7e00000-0000-4000-8000-000000000804', v_ws_fnb1, 'POST'::task_type, '[TikTok POV] Ngày gió lạnh ghé Tiệm thưởng thức bánh sừng bò nóng giòn cùng hội bạn', v_manager_id, now(), now()),
    ('d7e00000-0000-4000-8000-000000000805', v_ws_tech, 'POST'::task_type, '[B2B Thought Leadership] Tự động hóa báo cáo cuối năm với CloudWork AI Agent & Ưu đãi Black Friday Enterprise', v_manager_id, now(), now()),
    ('d7e00000-0000-4000-8000-000000000806', v_ws_fnb2, 'POST'::task_type, '[Storytelling Mùa Cưới] Buổi hẹn hò đầu đông ở Nhà và hộp quà thiệp viết tay dành cho cặp đôi', v_manager_id, now(), now())
  ON CONFLICT (id) DO UPDATE
    SET workspace_id = EXCLUDED.workspace_id,
        title = EXCLUDED.title,
        updated_at = now();

END $$;

COMMIT;
