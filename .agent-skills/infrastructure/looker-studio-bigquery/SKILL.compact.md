# looker-studio-bigquery

> Design and configure Looker Studio dashboards with BigQuery data sources. Use when creating analytics dashboards, connecting BigQuery to visualization tools, or optimizing data pipeline performance.

## When to use this skill
• **분석 대시보드 생성**: BigQuery 데이터를 시각화하여 비즈니스 인사이트 도출
• **실시간 리포팅**: 자동 새로고침되는 대시보드 구축
• **성능 최적화**: 대용량 데이터셋의 쿼리 비용 및 로딩 시간 최적화
• **데이터 파이프라인**: 스케줄된 쿼리로 ETL 프로세스 자동화
• **팀 협업**: 공유 가능한 인터랙티브 대시보드 구축

## Instructions
▶ S1: GCP BigQuery 환경 준비
프로젝트 생성, BigQuery API 활성화, 데이터셋/테이블 생성
IAM 권한: BigQuery Data Viewer, BigQuery User, BigQuery Job User
```bash
gcloud projects create my-analytics-project
gcloud services enable bigquery.googleapis.com
```

▶ S2: Looker Studio에서 BigQuery 연결
네이티브 커넥터: + 만들기 → 데이터 소스 → BigQuery 선택 → 프로젝트/테이블 선택
맞춤 SQL 쿼리: 복잡한 변환, 조인, 집계를 SQL로 처리
```sql
SELECT event_date, COUNT(DISTINCT user_id) as users, SUM(event_value) as revenue
FROM `project.dataset.events`
WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY event_date
```

▶ S3: 스케줄된 쿼리로 성능 최적화
미리 집계된 테이블 생성 → Looker Studio 연결 → 로딩 시간 50-80% 단축
```sql
CREATE OR REPLACE TABLE `project.looker_data.daily_summary` AS
SELECT event_date, event_name, COUNT(DISTINCT user_id) as users, SUM(revenue) as revenue
FROM `project.analytics.events`
WHERE event_date = CURRENT_DATE() - 1
GROUP BY event_date, event_name;
```

▶ S4: 대시보드 레이아웃 설계
F-패턴: 헤더(필터) → KPI 타일(3-4개) → 주요 차트 → 상세 테이블 → 추가 인사이트
차트 종류: 스코어카드(KPI), 라인(추세), 막대(비교), 테이블(상세), 맵(지역)

▶ S5: 인터랙티브 필터
필수: 날짜 범위 필터 (모든 차트에 반영)
추가: 드롭다운(국가/카테고리), 체크박스, 슬라이더

▶ S6: 쿼리 성능 최적화
파티션 키 사용, SELECT * 지양, 캐싱 활용 (Looker 3시간, BigQuery 6시간)
대시보드당 차트 20-25개 이하

▶ S7: Community Connector (고급)
Apps Script로 커스텀 데이터 소스 개발
서비스 계정 사용, 커스텀 캐싱, 파라미터화

▶ S8: 보안 및 접근 제어
BigQuery: GRANT, Row-Level Security
Looker Studio: Viewer/Editor 권한, 데이터 소스별 권한 관리

## Best practices
1. 스케줄된 쿼리로 야간에 데이터 집계
2. 파티션 키 직접 사용 (DATE 함수 대신)
3. 대시보드당 차트 25개 이하
4. 날짜 필터 필수, 추가 필터 3-5개
5. 브랜드 색상 3-4가지로 통일
6. 평균 로딩 시간 2-3초 목표
7. 월 BigQuery 스캔량 5TB 이내
