# 03. Thiết Kế Cơ Sở Dữ Liệu & Migration (Database Schema Changes)

## 1. Phân Tích Thay Đổi Cơ Sở Dữ Liệu (Schema DDL)

Để hỗ trợ phân loại Agency Cá nhân (`PERSONAL`) và Doanh nghiệp (`BUSINESS`), hệ thống PostgreSQL cần bổ sung một kiểu ENUM mới và mở rộng bảng `agencies`.

### 1.1. Script Migration: `2026-10-06-add-agency-type-and-personal-mode.sql`

```sql
-- Migration: Add agency_type ENUM and type column to agencies table
-- Apply once: psql -X -v ON_ERROR_STOP=1 -f 2026-10-06-add-agency-type-and-personal-mode.sql

BEGIN;

SET LOCAL lock_timeout = '5s';
SET LOCAL statement_timeout = '30s';
SET LOCAL search_path = public;

-- 1. Tạo kiểu ENUM agency_type nếu chưa tồn tại
DO $$ BEGIN
    CREATE TYPE agency_type AS ENUM ('PERSONAL', 'BUSINESS');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- 2. Thêm cột type vào bảng agencies (Mặc định là BUSINESS để tương thích 100% dữ liệu cũ)
ALTER TABLE agencies
    ADD COLUMN IF NOT EXISTS type agency_type NOT NULL DEFAULT 'BUSINESS';

-- 3. Đánh index trên cột type để tối ưu hóa truy vấn lọc theo loại hình agency
CREATE INDEX IF NOT EXISTS idx_agencies_type ON agencies(type);

COMMIT;
```

---

## 2. Kịch Bản Tương Thích Dữ Liệu Cũ (Backwards Compatibility)

* **Giá trị mặc định**: Toàn bộ các Agency đã được tạo trước thời điểm migration sẽ tự động nhận giá trị `type = 'BUSINESS'`, bảo toàn 100% các tính năng quản lý client, thành viên, và phân quyền mà không gây bất kỳ tác động tiêu cực nào tới các tổ chức hiện tại.
* **Không làm hỏng khóa ngoại**: Bảng `workspaces` và `agency_members` vẫn giữ nguyên mối quan hệ khóa ngoại `agency_id REFERENCES agencies(id) ON DELETE RESTRICT`.

---

## 3. Cập Nhật Java Entity & Persistence Model

### 3.1. Tạo Enum `AgencyType.java`
Vị trí: `brandhub-business-service/src/main/java/com/brandhub/business/model/enums/AgencyType.java`

```java
package com.brandhub.business.model.enums;

public enum AgencyType {
    PERSONAL,
    BUSINESS
}
```

### 3.2. Cập nhật `Agency.java`
Thêm thuộc tính `type`:

```java
    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(nullable = false, columnDefinition = "agency_type")
    @Builder.Default
    private AgencyType type = AgencyType.BUSINESS;
```

### 3.3. Cập nhật `AgencyRequest.java` (DTO)
Bổ sung `AgencyType type`:

```java
public record AgencyRequest(
        @NotBlank String name,
        AgencyType type, // Mặc định là BUSINESS nếu client không truyền
        String logoUrl,
        String bannerUrl,
        String description,
        AgencyCategory category,
        CompanySize companySize,
        String website,
        String phone,
        String location,
        String brandColor,
        String logoIcon,
        String tagline,
        Integer foundedYear,
        String facebookUrl,
        String linkedinUrl,
        String instagramUrl
) { ... }
```

### 3.4. Cập nhật `AgencyResponse.java` (DTO)
Bổ sung `AgencyType type` và `UUID defaultWorkspaceId`:

```java
public record AgencyResponse(
        UUID id,
        String name,
        AgencyType type,
        UUID ownerId,
        AgencyMemberRole myRole,
        // ... các trường hiện có
        UUID defaultWorkspaceId, // Id của workspace vừa được auto-create (khi type == PERSONAL)
        OffsetDateTime createdAt,
        OffsetDateTime updatedAt
) { ... }
```

---

## 4. Nghiệp Vụ Auto-Provisioning Workspace (Trong `AgencyServiceImpl.java`)

Khi tạo Agency với `type == AgencyType.PERSONAL`, phương thức `createAgency` sẽ tự động thực hiện:

```java
    @Override
    @Transactional
    public AgencyResponse createAgency(AuthenticatedUser currentUser, AgencyRequest request) {
        AgencyType effectiveType = request.type() != null ? request.type() : AgencyType.BUSINESS;

        // 1. Lưu Agency
        Agency agency = Agency.builder()
                .name(request.name().trim())
                .type(effectiveType)
                .logoUrl(request.logoUrl())
                .bannerUrl(request.bannerUrl())
                .description(request.description())
                .category(request.category())
                .companySize(effectiveType == AgencyType.PERSONAL ? CompanySize.SIZE_1_10 : request.companySize())
                .website(request.website())
                .phone(request.phone())
                .location(request.location())
                .brandColor(request.brandColor())
                .logoIcon(request.logoIcon())
                .tagline(request.tagline())
                .foundedYear(request.foundedYear())
                .facebookUrl(request.facebookUrl())
                .linkedinUrl(request.linkedinUrl())
                .instagramUrl(request.instagramUrl())
                .ownerId(currentUser.getId())
                .build();
        agency = agencyRepository.save(agency);

        // 2. Lưu Owner Member
        AgencyMember owner = AgencyMember.builder()
                .agencyId(agency.getId())
                .userId(currentUser.getId())
                .role(AgencyMemberRole.OWNER)
                .build();
        agencyMemberRepository.save(owner);

        UUID defaultWorkspaceId = null;

        // 3. Nếu là PERSONAL: Tự động khởi tạo 1 Workspace cá nhân đi kèm
        if (effectiveType == AgencyType.PERSONAL) {
            Workspace personalWorkspace = Workspace.builder()
                    .agencyId(agency.getId())
                    .name(agency.getName()) // Đồng bộ tên với Agency
                    .createdBy(currentUser.getId())
                    .description(agency.getDescription())
                    .brandColor(agency.getBrandColor())
                    .logoIcon(agency.getLogoIcon())
                    .logoUrl(agency.getLogoUrl())
                    .bannerUrl(agency.getBannerUrl())
                    .tagline(agency.getTagline())
                    .companySize(CompanySize.SIZE_1_10)
                    .location(agency.getLocation())
                    .website(agency.getWebsite())
                    .phone(agency.getPhone())
                    .timezoneConfig("Asia/Ho_Chi_Minh")
                    .settings("{}")
                    .build();
            personalWorkspace = workspaceRepository.save(personalWorkspace);

            // Gán người dùng là MANAGER của workspace này
            WorkspaceMember wsMember = WorkspaceMember.builder()
                    .workspaceId(personalWorkspace.getId())
                    .userId(currentUser.getId())
                    .role(MemberRole.MANAGER)
                    .joinedAt(OffsetDateTime.now())
                    .isActive(true)
                    .build();
            workspaceMemberRepository.save(wsMember);

            defaultWorkspaceId = personalWorkspace.getId();
        }

        return toResponse(agency, AgencyMemberRole.OWNER, defaultWorkspaceId);
    }
```

### Đảm bảo tính toàn vẹn giao dịch (Atomicity & Rollback)
Nhờ `@Transactional`, nếu quá trình tạo Workspace hoặc gán WorkspaceMember gặp bất kỳ ngoại lệ nào, toàn bộ giao dịch bao gồm việc tạo Agency sẽ được rollback hoàn toàn, không để lại dữ liệu rác hay trạng thái mồ côi.
