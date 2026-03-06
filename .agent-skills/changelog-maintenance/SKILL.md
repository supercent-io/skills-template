---
name: changelog-maintenance
description: Maintain a clear and informative changelog for software releases. Use when documenting version changes, tracking features, or communicating updates to users. Handles semantic versioning, changelog formats, and release notes.
metadata:
  tags: changelog, release-notes, versioning, semantic-versioning, documentation
  platforms: Claude, ChatGPT, Gemini
---


# Changelog Maintenance


## When to use this skill

- **릴리스 전**: 버전 출시 전 변경사항 정리
- **지속적**: 주요 변경 발생 시마다 업데이트
- **마이그레이션 가이드**: Breaking changes 문서화

## Instructions

### Step 1: Keep a Changelog 형식

**CHANGELOG.md**:
```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New user profile customization options
- Dark mode support

### Changed
- Improved performance of search feature

### Fixed
- Bug in password reset email

## [1.2.0] - 2025-01-15

### Added
- Two-factor authentication (2FA)
- Export user data feature (GDPR compliance)
- API rate limiting
- Webhook support for order events

### Changed
- Updated UI design for dashboard
- Improved email templates
- Database query optimization (40% faster)

### Deprecated
- `GET /api/v1/users/list` (use `GET /api/v2/users` instead)

### Removed
- Legacy authentication method (Basic Auth)

### Fixed
- Memory leak in background job processor
- CORS issue with Safari browser
- Timezone bug in date picker

### Security
- Updated dependencies (fixes CVE-2024-12345)
- Implemented CSRF protection
- Added helmet.js security headers

## [1.1.2] - 2025-01-08

### Fixed
- Critical bug in payment processing
- Session timeout issue

## [1.1.0] - 2024-12-20

### Added
- User profile pictures
- Email notifications
- Search functionality

### Changed
- Redesigned login page
- Improved mobile responsiveness

## [1.0.0] - 2024-12-01

Initial release

### Added
- User registration and authentication
- Basic profile management
- Product catalog
- Shopping cart
- Order management

[Unreleased]: https://github.com/username/repo/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/username/repo/compare/v1.1.2...v1.2.0
[1.1.2]: https://github.com/username/repo/compare/v1.1.0...v1.1.2
[1.1.0]: https://github.com/username/repo/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/username/repo/releases/tag/v1.0.0
```

### Step 2: Semantic Versioning

**버전 번호**: `MAJOR.MINOR.PATCH`

```
Given a version number MAJOR.MINOR.PATCH, increment:

MAJOR (1.0.0 → 2.0.0): Breaking changes
  - API 변경으로 기존 코드가 동작하지 않음
  - 예: 필수 파라미터 추가, 응답 구조 변경

MINOR (1.1.0 → 1.2.0): Backward-compatible features
  - 새로운 기능 추가
  - 기존 기능은 그대로 동작
  - 예: 새 API 엔드포인트, optional 파라미터

PATCH (1.1.1 → 1.1.2): Backward-compatible bug fixes
  - 버그 수정
  - 보안 패치
  - 예: 메모리 누수 수정, 타이포 수정
```

**예시**:
- `1.0.0` → `1.0.1`: 버그 수정
- `1.0.1` → `1.1.0`: 새 기능 추가
- `1.1.0` → `2.0.0`: Breaking change

### Step 3: Release Notes (사용자 친화적)

```markdown
# Release Notes v1.2.0
**Released**: January 15, 2025

## 🎉 What's New

### Two-Factor Authentication
You can now enable 2FA for enhanced security. Go to Settings > Security to set it up.

![2FA Setup](https://example.com/images/2fa.png)

### Export Your Data
We've added the ability to export all your data in JSON format. Perfect for backing up or migrating your account.

## ✨ Improvements

- **Faster Search**: Search is now 40% faster thanks to database optimizations
- **Better Emails**: Redesigned email templates for a cleaner look
- **Dashboard Refresh**: Updated UI with modern design

## 🐛 Bug Fixes

- Fixed a bug where password reset emails weren't being sent
- Resolved timezone issues in the date picker
- Fixed memory leak in background jobs

## ⚠️ Breaking Changes

If you're using our API:

- **Removed**: Basic Authentication is no longer supported
  - **Migration**: Use JWT tokens instead (see [Auth Guide](docs/auth.md))

- **Deprecated**: `GET /api/v1/users/list`
  - **Migration**: Use `GET /api/v2/users` with pagination

## 🔒 Security

- Updated all dependencies to latest versions
- Added CSRF protection to all forms
- Implemented security headers with helmet.js

## 📝 Full Changelog

See [CHANGELOG.md](CHANGELOG.md) for complete details.

---

**Upgrade Instructions**: [docs/upgrade-to-v1.2.md](docs/upgrade-to-v1.2.md)
```

### Step 4: Breaking Changes 마이그레이션 가이드

```markdown
# Migration Guide: v1.x to v2.0

## Breaking Changes

### 1. Authentication Method Changed

**Before** (v1.x):
\`\`\`javascript
fetch('/api/users', {
  headers: {
    'Authorization': 'Basic ' + btoa(username + ':' + password)
  }
});
\`\`\`

**After** (v2.0):
\`\`\`javascript
// 1. Get JWT token
const { accessToken } = await fetch('/api/auth/login', {
  method: 'POST',
  body: JSON.stringify({ email, password })
}).then(r => r.json());

// 2. Use token
fetch('/api/users', {
  headers: {
    'Authorization': 'Bearer ' + accessToken
  }
});
\`\`\`

### 2. User List API Response Format

**Before** (v1.x):
\`\`\`json
{
  "users": [...]
}
\`\`\`

**After** (v2.0):
\`\`\`json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
\`\`\`

**Migration**:
\`\`\`javascript
// v1.x
const users = response.users;

// v2.0
const users = response.data;
\`\`\`

## Deprecation Timeline

- v2.0 (Jan 2025): Basic Auth marked as deprecated
- v2.1 (Feb 2025): Warning logs for Basic Auth usage
- v2.2 (Mar 2025): Basic Auth removed
```

## Output format

```
CHANGELOG.md             # 개발자용 상세 로그
RELEASES.md              # 사용자용 릴리스 노트
docs/migration/
  ├── v1-to-v2.md        # 마이그레이션 가이드
  └── v2-to-v3.md
```

## Constraints

### 필수 규칙 (MUST)

1. **역순 정렬**: 최신 버전이 위에
2. **날짜 포함**: ISO 8601 형식 (YYYY-MM-DD)
3. **카테고리 분류**: Added, Changed, Fixed, etc.

### 금지 사항 (MUST NOT)

1. **Git Log 복사 금지**: 사용자 관점으로 작성
2. **모호한 표현**: "버그 수정", "성능 개선" (구체적으로)

## Best practices

1. **Keep a Changelog**: 표준 형식 따르기
2. **Semantic Versioning**: 일관된 버전 관리
3. **Breaking Changes**: 마이그레이션 가이드 제공

## References

- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)

## Metadata

### 버전
- **현재 버전**: 1.0.0
- **최종 업데이트**: 2025-01-01
- **호환 플랫폼**: Claude, ChatGPT, Gemini

### 태그
`#changelog` `#release-notes` `#versioning` `#semantic-versioning` `#documentation`

## Examples

### Example 1: Basic usage
<!-- Add example content here -->

### Example 2: Advanced usage
<!-- Add advanced example content here -->
