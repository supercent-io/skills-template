---
name: file-organization
description: Organize project files and folders for maintainability and scalability. Use when structuring new projects, refactoring folder structure, or establishing conventions. Handles project structure, naming conventions, and file organization best practices.
allowed-tools: Read Write Glob Bash
metadata:
  tags: file-organization, project-structure, folder-structure, naming-conventions
  platforms: Claude, ChatGPT, Gemini
---


# Project File Organization


## When to use this skill

- **신규 프로젝트**: 초기 폴더 구조 설계
- **프로젝트 성장**: 복잡도 증가 시 리팩토링
- **팀 표준화**: 일관된 구조 확립

## Instructions

### Step 1: React/Next.js 프로젝트 구조

```
src/
├── app/                      # Next.js 13+ App Router
│   ├── (auth)/               # Route groups
│   │   ├── login/
│   │   └── signup/
│   ├── (dashboard)/
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── settings/
│   ├── api/                  # API routes
│   │   ├── auth/
│   │   └── users/
│   └── layout.tsx
│
├── components/               # UI Components
│   ├── ui/                   # Reusable UI (Button, Input)
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.test.tsx
│   │   │   └── index.ts
│   │   └── Input/
│   ├── layout/               # Layout components (Header, Footer)
│   ├── features/             # Feature-specific components
│   │   ├── auth/
│   │   └── dashboard/
│   └── shared/               # Shared across features
│
├── lib/                      # Utilities & helpers
│   ├── utils.ts
│   ├── hooks/
│   │   ├── useAuth.ts
│   │   └── useLocalStorage.ts
│   └── api/
│       └── client.ts
│
├── store/                    # State management
│   ├── slices/
│   │   ├── authSlice.ts
│   │   └── userSlice.ts
│   └── index.ts
│
├── types/                    # TypeScript types
│   ├── api.ts
│   ├── models.ts
│   └── index.ts
│
├── config/                   # Configuration
│   ├── env.ts
│   └── constants.ts
│
└── styles/                   # Global styles
    ├── globals.css
    └── theme.ts
```

### Step 2: Node.js/Express 백엔드 구조

```
src/
├── api/                      # API layer
│   ├── routes/
│   │   ├── auth.routes.ts
│   │   ├── user.routes.ts
│   │   └── index.ts
│   ├── controllers/
│   │   ├── auth.controller.ts
│   │   └── user.controller.ts
│   └── middlewares/
│       ├── auth.middleware.ts
│       ├── errorHandler.ts
│       └── validation.ts
│
├── services/                 # Business logic
│   ├── auth.service.ts
│   ├── user.service.ts
│   └── email.service.ts
│
├── repositories/             # Data access layer
│   ├── user.repository.ts
│   └── session.repository.ts
│
├── models/                   # Database models
│   ├── User.ts
│   └── Session.ts
│
├── database/                 # Database setup
│   ├── connection.ts
│   ├── migrations/
│   └── seeds/
│
├── utils/                    # Utilities
│   ├── logger.ts
│   ├── crypto.ts
│   └── validators.ts
│
├── config/                   # Configuration
│   ├── index.ts
│   ├── database.ts
│   └── env.ts
│
├── types/                    # TypeScript types
│   ├── express.d.ts
│   └── models.ts
│
├── __tests__/                # Tests
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
└── index.ts                  # Entry point
```

### Step 3: Feature-Based 구조 (대규모 앱)

```
src/
├── features/
│   ├── auth/
│   │   ├── components/
│   │   │   ├── LoginForm.tsx
│   │   │   └── SignupForm.tsx
│   │   ├── hooks/
│   │   │   └── useAuth.ts
│   │   ├── api/
│   │   │   └── authApi.ts
│   │   ├── store/
│   │   │   └── authSlice.ts
│   │   ├── types/
│   │   │   └── auth.types.ts
│   │   └── index.ts
│   │
│   ├── products/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── api/
│   │   └── types/
│   │
│   └── orders/
│
├── shared/                   # Shared across features
│   ├── components/
│   ├── hooks/
│   ├── utils/
│   └── types/
│
└── core/                     # App-wide
    ├── store/
    ├── router/
    └── config/
```

### Step 4: 명명 규칙 (Naming Conventions)

**파일명**:
```
Components:       PascalCase.tsx
Hooks:            camelCase.ts        (useAuth.ts)
Utils:            camelCase.ts        (formatDate.ts)
Constants:        UPPER_SNAKE_CASE.ts (API_ENDPOINTS.ts)
Types:            camelCase.types.ts  (user.types.ts)
Tests:            *.test.ts, *.spec.ts
```

**폴더명**:
```
kebab-case:       user-profile/
camelCase:        userProfile/       (선택: hooks/, utils/)
PascalCase:       UserProfile/       (선택: components/)

✅ 일관성이 중요 (팀 전체가 같은 규칙 사용)
```

**변수/함수명**:
```typescript
// Components: PascalCase
const UserProfile = () => {};

// Functions: camelCase
function getUserById() {}

// Constants: UPPER_SNAKE_CASE
const API_BASE_URL = 'https://api.example.com';

// Private: _prefix (선택)
class User {
  private _id: string;

  private _hashPassword() {}
}

// Booleans: is/has/can prefix
const isAuthenticated = true;
const hasPermission = false;
const canEdit = true;
```

### Step 5: index.ts 배럴 파일

**components/ui/index.ts**:
```typescript
// ✅ 좋은 예: Named exports 재export
export { Button } from './Button/Button';
export { Input } from './Input/Input';
export { Modal } from './Modal/Modal';

// 사용:
import { Button, Input } from '@/components/ui';
```

**❌ 나쁜 예**:
```typescript
// 모든 것을 재export (tree-shaking 저해)
export * from './Button';
export * from './Input';
```

## Output format

### 프로젝트 템플릿

```
my-app/
├── .github/
│   └── workflows/
├── public/
├── src/
│   ├── app/
│   ├── components/
│   ├── lib/
│   ├── types/
│   └── config/
├── tests/
├── docs/
├── scripts/
├── .env.example
├── .gitignore
├── .eslintrc.json
├── .prettierrc
├── tsconfig.json
├── package.json
└── README.md
```

## Constraints

### 필수 규칙 (MUST)

1. **일관성**: 팀 전체가 같은 규칙 사용
2. **명확한 폴더명**: 역할이 명확해야 함
3. **최대 깊이**: 5단계 이하 권장

### 금지 사항 (MUST NOT)

1. **과도한 중첩**: 폴더 깊이 7단계 이상 지양
2. **모호한 이름**: utils2/, helpers/, misc/ 지양
3. **순환 의존성**: A → B → A 참조 금지

## Best practices

1. **Colocation**: 관련 파일은 가까이 (컴포넌트 + 스타일 + 테스트)
2. **Feature-Based**: 기능별로 모듈화
3. **Path Aliases**: `@/` 사용으로 import 간소화

**tsconfig.json**:
```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@/components/*": ["./src/components/*"],
      "@/lib/*": ["./src/lib/*"]
    }
  }
}
```

**사용**:
```typescript
// ❌ 나쁜 예
import { Button } from '../../../components/ui/Button';

// ✅ 좋은 예
import { Button } from '@/components/ui';
```

## References

- [React File Structure](https://react.dev/learn/thinking-in-react#step-1-break-the-ui-into-a-component-hierarchy)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## Metadata

### 버전
- **현재 버전**: 1.0.0
- **최종 업데이트**: 2025-01-01
- **호환 플랫폼**: Claude, ChatGPT, Gemini

### 태그
`#file-organization` `#project-structure` `#folder-structure` `#naming-conventions` `#utilities`

## Examples

### Example 1: Basic usage
<!-- Add example content here -->

### Example 2: Advanced usage
<!-- Add advanced example content here -->
