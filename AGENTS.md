# Repository Guidelines

## Project Structure & Module Organization
- Flutter 레이아웃: 앱 코드는 `lib/`, 플랫폼 설정은 `android/`, `ios/`, 위젯/알림 확장은 각 플랫폼 폴더에서 관리.
- 리소스 `assets/`(이미지·폰트)와 환경 샘플 `.env.example`; 기획/명세는 `docs/`(예: `docs/todo_app_spec.md`).
- 테스트는 `test/` 루트, 골든 에셋은 `test/golden/`, 샘플/픽스처는 `test/fixtures/`.
- 빌드 산출물은 생성 후 커밋하지 않음; 임시 파일은 `.gitignore`로 관리.

## Build, Test, and Development Commands
- `flutter pub get` 의존성 동기화.
- `flutter analyze` 정적 분석.
- `flutter test` 단위/위젯/골든 테스트 실행.
- `flutter run -d <device>` 로컬 실행 및 디버그.
- `flutter test --coverage` 커버리지 수집(`coverage/` 생성).

## Coding Style & Naming Conventions
- Dart 표준 + 2스페이스 들여쓰기, 커밋 전 `dart format .`.
- 클래스/위젯 UpperCamelCase, 변수/메서드 lowerCamelCase, 상수 `kPascalCase`.
- 파일명은 역할 중심(`home_screen.dart`, `routine_tile.dart`), 상태 관리자는 `..._provider.dart`/`..._bloc.dart`.
- null-safety 준수, UI 빌드는 side-effect 없이, 불변 모델 선호.

## Testing Guidelines
- 테스트 파일은 `_test.dart`, `group('feature: ...')`로 섹션화.
- 위젯 테스트는 `ProviderScope` 등으로 의존성 주입, `pump()`/`pumpAndSettle()`로 시간 제어.
- 골든은 고정 해상도/폰트 후 `matchesGoldenFile('golden/name.png')`.
- 새 로직에는 최소 한 개 테스트, UI 변경 시 스크린샷 또는 골든 업데이트.

## Commit & Pull Request Guidelines
- 커밋 메시지는 명령형 현재형(예: `Add routine list widget`, `Fix reminder scheduling`); 한 기능당 한 커밋 지향.
- PR에는 변경 요약, 테스트 결과(`flutter test`), 영향 영역, UI 변경 시 스크린샷/GIF 포함.
- 이슈가 있으면 `Closes #<id>` 명시; 체크리스트 충족 여부를 본문에 기록.

## Security & Configuration Tips
- 비밀키/토큰은 커밋 금지; 필요 시 `.env.example` 복사해 로컬 `.env` 사용.
- 로컬 전용 앱: 데이터는 파일/SharedPreferences에만 저장, 외부 전송 없는지 확인.
- 빌드/테스트 후 남는 민감 로그나 캐시는 정리하고 커밋하지 않음.

## Agent-Specific Instructions
- 기존 사용자 변경을 덮어쓰지 말 것; 의문점은 새 섹션/파일로 제안.
- 포맷→분석→테스트 순(`dart format .`, `flutter analyze`, `flutter test`)을 실행하고 결과를 요약에 남길 것.
