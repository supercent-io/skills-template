---
name: firebase-ai-logic
description: Integrate Firebase AI Logic (Gemini in Firebase) for intelligent app features. Use when adding AI capabilities to Firebase apps, implementing generative AI features, or setting up Firebase AI SDK. Handles Firebase AI SDK setup, prompt engineering, and AI-powered features.
tags: [firebase, ai, gemini, generative-ai, sdk]
platforms: [Claude, ChatGPT, Gemini]
---

# Firebase AI Logic Integration

## 목적 (Purpose)

Firebase AI Logic (Gemini in Firebase)를 활용하여 앱에 AI 기능을 통합합니다.

이 스킬은 다음을 도와줍니다:
- Firebase AI SDK 설정
- Gemini 모델 통합
- 프롬프트 엔지니어링
- AI 기반 기능 구현

## 사용 시점 (When to Use)

- **AI 기능 추가**: 앱에 생성형 AI 기능 통합
- **Firebase 프로젝트**: Firebase 기반 앱에 AI 추가
- **텍스트 생성**: 콘텐츠 생성, 요약, 번역
- **이미지 분석**: 이미지 기반 AI 처리

## 작업 절차 (Procedure)

### 1단계: Firebase 프로젝트 설정

```bash
# Firebase CLI 설치
npm install -g firebase-tools

# 로그인
firebase login

# 프로젝트 초기화
firebase init
```

### 2단계: AI Logic 활성화

Firebase Console에서:
1. **Build > AI Logic** 선택
2. **Get Started** 클릭
3. Gemini API 활성화

### 3단계: SDK 설치

**Web (JavaScript)**:
```bash
npm install firebase @anthropic-ai/sdk
```

**초기화 코드**:
```typescript
import { initializeApp } from 'firebase/app';
import { getAI, getGenerativeModel } from 'firebase/ai';

const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
};

const app = initializeApp(firebaseConfig);
const ai = getAI(app);
const model = getGenerativeModel(ai, { model: "gemini-2.0-flash" });
```

### 4단계: AI 기능 구현

**텍스트 생성**:
```typescript
async function generateContent(prompt: string) {
  const result = await model.generateContent(prompt);
  return result.response.text();
}

// 사용 예시
const response = await generateContent("Firebase의 주요 기능을 설명해주세요.");
console.log(response);
```

**스트리밍 응답**:
```typescript
async function streamContent(prompt: string) {
  const result = await model.generateContentStream(prompt);

  for await (const chunk of result.stream) {
    const text = chunk.text();
    console.log(text);
  }
}
```

**멀티모달 (이미지 + 텍스트)**:
```typescript
async function analyzeImage(imageUrl: string, prompt: string) {
  const imagePart = {
    inlineData: {
      data: await fetchImageAsBase64(imageUrl),
      mimeType: "image/jpeg"
    }
  };

  const result = await model.generateContent([prompt, imagePart]);
  return result.response.text();
}
```

### 5단계: 보안 규칙 설정

**Firebase Security Rules**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // AI 요청 로그 보호
    match /ai_logs/{logId} {
      allow read: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
  }
}
```

## 출력 포맷 (Output Format)

### 프로젝트 구조
```
project/
├── src/
│   ├── ai/
│   │   ├── client.ts        # AI 클라이언트 초기화
│   │   ├── prompts.ts       # 프롬프트 템플릿
│   │   └── handlers.ts      # AI 핸들러
│   └── firebase/
│       └── config.ts        # Firebase 설정
├── firebase.json
└── .env.local               # API 키 (gitignore)
```

## 베스트 프랙티스

1. **프롬프트 최적화**: 명확하고 구체적인 프롬프트 작성
2. **에러 처리**: AI 응답 실패 시 폴백 구현
3. **Rate Limiting**: 사용량 제한 및 비용 관리
4. **캐싱**: 반복 요청에 대한 응답 캐싱
5. **보안**: API 키는 환경변수로 관리

## 제약사항 (Constraints)

### 필수 규칙 (MUST)
1. API 키를 코드에 하드코딩하지 않음
2. 사용자 입력 검증 수행
3. 에러 핸들링 구현

### 금지 사항 (MUST NOT)
1. 민감한 데이터를 AI에 전송하지 않음
2. 무제한 API 호출 허용하지 않음

## 참고 자료

- [Firebase AI Logic Docs](https://firebase.google.com/docs/ai-logic)
- [Gemini API](https://ai.google.dev/)
- [Firebase SDK](https://firebase.google.com/docs/web/setup)

## 메타데이터

- **버전**: 1.0.0
- **최종 업데이트**: 2025-01-05
- **호환 플랫폼**: Claude, ChatGPT, Gemini
