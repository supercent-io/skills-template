# npm-git-install

> GitHub 리포지토리에서 직접 npm 패키지 설치. npm 레지스트리에 없는 패키지, 특정 브랜치, 프라이빗 리포지토리 설치에 사용.

## When to use this skill
• **npm에 없는 패키지**: 퍼블리시 전 패키지
• **특정 브랜치/태그**: main, develop, v1.0.0
• **프라이빗 리포지토리**: 내부 패키지
• **포크된 패키지**: 수정된 포크 버전

## Instructions
▶ S1: 기본 설치 명령어
```bash
# HTTPS (일반)
npm install -g git+https://github.com/owner/repo.git#main

# SSH (SSH 키 설정 시)
npm install -g git+ssh://git@github.com:owner/repo.git#main

# 특정 태그
npm install git+https://github.com/owner/repo.git#v1.0.0
```

▶ S2: npm install 플로우
```
Git Clone → 의존성 설치 → prepare 스크립트 → 바이너리 등록
```

▶ S3: 설치 위치 확인
```bash
npm root -g                    # 글로벌 경로
npm list -g <package>          # 설치 확인
which <command>                # 바이너리 위치
```

▶ S4: package.json 의존성
```json
{
  "dependencies": {
    "pkg": "git+https://github.com/owner/repo.git#main",
    "pkg2": "github:owner/repo#v1.0.0"
  }
}
```

▶ S5: 프라이빗 리포 설치
```bash
# SSH 방식 (권장)
npm install git+ssh://git@github.com:owner/private.git

# PAT 방식
npm install git+https://${GITHUB_TOKEN}@github.com/owner/private.git
```

▶ S6: 오류 해결
| 오류 | 해결 |
|-----|------|
| EACCES | `mkdir ~/.npm-global && npm config set prefix '~/.npm-global'` |
| Git 없음 | `brew install git` / `apt install git` |
| 인증 실패 | `ssh -T git@github.com` 테스트 |
| 캐시 문제 | `npm cache clean --force` |

▶ S7: 업데이트 & 제거
```bash
npm uninstall -g <pkg> && npm install -g git+https://...  # 업데이트
npm uninstall -g <pkg>                                     # 제거
```

## Best Practices
1. 특정 버전/태그 사용 `#v1.0.0`
2. SSH 방식 선호 (프라이빗)
3. 환경변수로 토큰 관리
4. package-lock.json 커밋
5. verbose 옵션으로 디버깅

## Constraints
• **MUST**: Git 설치, 네트워크 접근, Node.js 버전 확인
• **MUST NOT**: 토큰 하드코딩, 프로덕션에서 #main, 무분별한 sudo
