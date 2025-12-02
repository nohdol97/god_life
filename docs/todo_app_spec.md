# Todo 루틴/할 일 앱 기획안 (MyRoutine 레퍼런스)

## 1. 목표와 포지셔닝
- 하루/주간 루틴과 일반 할 일을 한 화면에서 관리하는 오프라인 우선 Todo 앱.
- 루틴 유지율을 직관적 지표(연속 수행, 달성률, 주간 캘린더)로 보여주는 것이 핵심 가치.
- 가벼운 입력 → 자동 반복/알림 → 위젯/알림으로 바로 체크 → 통계로 동기 부여.

## 2. 타깃 페르소나
- 루틴을 만들었지만 자주 잊어버리는 직장인/학생.
- 하루/주간 단위로 일정을 빠르게 검토하고 싶고, 체크/미루기/건너뛰기를 손쉽게 하길 원함.
- 위젯/알림 인터랙션을 선호하며, 캘린더형 달력으로 한눈에 빈칸을 확인하고 싶음.

## 3. 핵심 기능
- 오늘/주간 보드: 오늘 남은 루틴, 예정된 할 일, 완료/미완료 요약.
- 루틴 관리: 요일별 반복, 특정 기간 반복, 시간/장소/태그 지정, 스누즈/건너뛰기.
- 일반 할 일: 마감일/우선순위/메모/체크리스트, 당겨오기(오늘 할 일로 이동) 기능.
- 캘린더 뷰: 월간 달력에 완료/미완료 배지, 루틴/할 일 필터, 날짜 선택 시 일간 목록.
- 리마인더/알림: 지정 시간/장소 기반 알림, 완료/미룸 액션 버튼, 알림 내 체크 처리.
- 홈 위젯: 오늘 남은 루틴/할 일, 체크/스누즈/건너뛰기 액션.
- 통계/동기 부여: 연속 수행 횟수, 주간 달성률, 카테고리별 시간/횟수 분포.
- 빠른 입력: 자연어 파싱(예: “내일 8시 운동”), 최근 템플릿 불러오기, 다중 선택 삭제/완료.
- 백업/복원: 로컬 백업 파일 export/import, 기기 내 보관(클라우드 동기화 없음).
- 접근성/현지화: 다크/라이트, 폰트 크기, 스크린리더 레이블, 한국어 기본 + 영어 확장.

## 4. IA 및 주요 화면
- 온보딩/허용: 알림 권한, 위젯 안내, 주간 시작 요일 선택.
- 홈(오늘): 상단 요약 카드(달성률, 남은 개수), 루틴 섹션, 할 일 섹션, “오늘에 추가” FAB.
- 캘린더: 월간 달력 + 날짜별 목록, 필터(루틴/할 일/태그), 요일 시작 변경 지원.
- 루틴 상세: 반복 규칙, 알림 설정, 체크리스트, 메모, 기록 탭(완료/미룸 로그).
- 할 일 상세: 마감일, 우선순위, 체크리스트, 첨부 이미지/링크 메모, 반복 여부 설정.
- 통계: 주간/월간 차트, 연속 수행, 카테고리별 달성률, 역대 최고 스트릭.
- 설정: 계정/백업, 알림/위젯 설정, 데이터 내보내기, 테마/언어, 개인정보 안내.

## 5. 데이터 모델 (초안)
- UserPreference: startOfWeek, themeMode, language, backupPath, reminderDefaults.
- Routine: id, title, description, tags, color, repeatRule(cron/weekday list/기간), startDate, endDate, remindAt(TimeOfDay[]), allowSnooze(bool), order.
- RoutineInstance(전개된 개별 항목): id, routineId, date, status(pending/done/skipped/deferred), completedAt, deferredTo(Date), note.
- Task: id, title, description, dueDate, priority, checklist[], tags, repeatRule(optional), remindAt, status.
- Tag: id, name, color, icon.
- ActivityLog: id, source(routine/task), action(done/skip/defer/create/update), timestamp, meta(json).

## 6. 아키텍처/기술 스택
- Flutter 최신 stable, 최소 SDK는 iOS 15/Android 7.0 이상.
- 상태 관리: Riverpod(또는 Bloc) + immutable state; 라우팅: go_router.
- 로컬 저장소: DB 미사용, JSON 파일/SharedPreferences 기반 영속화(앱 시작 시 로드, 액션마다 비동기 flush).
- 알림: flutter_local_notifications + timezone; Android Foreground service 없이 단순 스케줄.
- 위젯: Android AppWidget + iOS Widget Extension(단, Flutter 플러그인 제약 검토 필요).
- DI/레이어: presentation(ui) / application(usecase) / domain(model) / infra(repo, storage, notif).
- 테스트: 유스케이스 단위 테스트, 스토리지/리포지토리 통합 테스트, 위젯 골든 테스트(핵심 화면).

## 7. 주요 흐름/로직
- 루틴 전개: repeatRule 기반으로 오늘~N일(예: 30일) 프리캐시, 완료/스킵/미룸 시 RoutineInstance 상태 업데이트.
- 알림 스케줄: Routine/Task별 remindAt을 timezone-safe로 스케줄, 완료 시 취소/재설정.
- 미룸/건너뛰기: 미룸은 deferredTo로 재배치, 건너뛰기는 상태만 skip 처리 후 통계에 반영.
- 통계 계산: 로그 기반으로 주간/월간 달성률, 스트릭 계산(연속 완료일 기준), 태그별 분포.
- 동기화: 기기 로컬 백업 파일 export/import, 오프라인 전제. 추후 클라우드 확장 여지를 위한 Repository 인터페이스 유지.

## 8. UX 가이드
- 홈은 “오늘 집중” 컨셉: 남은 루틴을 상단에, 다음 알림 예정 시간을 명시.
- 캘린더 배지 색상: 완료(채움), 미완료(테두리), 없음(빈칸)으로 직관적 상태 표현.
- 위젯/알림에서 바로 체크/스누즈/건너뛰기 가능하도록 액션 버튼 포함.
- 단일 손가락 제스처: 스와이프 완료/미룸, 길게 눌러 태그/색상 변경, 멀티셀 선택 편집.
- 오프라인 친화: 네트워크 없이 전 기능 동작, 백업만 사용자 트리거로 저장.

## 8-1. 비주얼 톤 & UI 가이드 (개인 여성 사용자, 연한 코랄 핑크 테마)
- 메인 팔레트: 코랄 핑크 🩷 `#F6B6B6` (배경), `#F9DADA`(카드), `#FDEEEF`(리스트/입력 배경), `#F26B8A`(포인트), `#3A2F2F`(본문 텍스트), `#6D5C5C`(보조 텍스트).
- 대비/가독성: 카드/입력 필드에 부드러운 그림자와 12~16px 코너 반경, 텍스트는 다크 초콜릿 톤으로 명도 대비 확보.
- 타이포: San-serif 라운드(예: Noto Sans KR Rounded) + 숫자 강조는 SemiBold; 헤더/숫자 강조에 포인트 색 사용.
- 아이콘/이모티콘 스타일: 둥근 라인/필 아이콘 + 귀여운 이모티콘(🐣, ✨, 🌷, 🍑)을 섹션 헤더와 토스트/빈 상태에 사용.
- 상태 피드백: 완료 체크는 포인트 색 채움 원형, 미룸/건너뛰기는 테두리만, 성공 토스트에 작은 이모티콘(예: “완료! ✨”).
- 빈 상태: “오늘의 작은 루틴을 추가해볼까요? 🐣”처럼 짧고 다정한 한 문장.

## 9. 접근성/보안/개인정보
- 접근성: SemanticLabel, 큰 텍스트 대응, 색약 대비 색상 팔레트 제공.
- 보안: 민감 정보 최소화, 앱 잠금 옵션(Local Auth), 백업 파일 암호화 옵션.
- 개인정보: 계정 없이 로컬 사용 기본, 클라우드 동기화 시 명시적 동의 및 옵트아웃 제공.

## 10. 일정/마일스톤(초안)
- M1: 데이터 모델/스토리지/상태 관리 뼈대, 오늘/루틴/할 일 CRUD, 알림 스케줄링.
- M2: 캘린더/통계 화면, 위젯 MVP(안드로이드), 백업/복원.
- M3: 접근성/현지화, iOS 위젯 검증, 퍼포먼스/배터리 튜닝, 스토어 배포 준비.
