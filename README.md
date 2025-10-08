## 프로젝트 개요

iOS Push Notification 기능 학습을 위한 실습 프로젝트입니다. APNs(Apple Push Notification service)를 활용한 다양한 푸시 알림 기능을 구현하고 있습니다.

## 아키텍처

이 프로젝트는 3개의 타겟으로 구성되어 있습니다:

### 1. Main App (`NotificationService-Practice`)
- **Entry Point**: [NotificationService_PracticeApp.swift](NotificationService-Practice/NotificationService-Practice/NotificationService_PracticeApp.swift)
- **AppDelegate**: [AppDelegate.swift](NotificationService-Practice/NotificationService-Practice/AppDelegate.swift)
  - Push 권한 요청 및 Device Token 획득
  - Foreground에서의 푸시 수신 처리
  - Custom Action 버튼 구현 (`myNotificationCategory`)
- SwiftUI + UIApplicationDelegateAdaptor 패턴 사용

### 2. Notification Service Extension (`NotificationSerciceExtension`)
- **Extension Point**: `com.apple.usernotifications.service`
- **Principal Class**: [NotificationService.swift](NotificationService-Practice/NotificationSerciceExtension/NotificationService.swift)
- **주요 기능**:
  - APNs 수신 후 푸시 내용 수정 (제목/부제목에 "변경 " 접두사 추가)
  - 원격 이미지 다운로드 및 로컬 저장 후 푸시에 첨부
  - **Intents Framework를 활용한 푸시 앱 아이콘 커스터마이징**
  - `didReceive(_:withContentHandler:)`에서 푸시 처리
  - `serviceExtensionTimeWillExpire()`로 타임아웃 처리

**중요 구현 사항**:

#### 1) 이미지 첨부 (`setAttachment`)
- 이미지는 반드시 `.png`, `.jpg` 등 확장자를 포함한 파일명으로 저장 (예: `myImage.png`)
- `userInfo["image"]`에서 이미지 URL을 가져와 처리
- `UNNotificationAttachment`로 이미지를 알림에 첨부

#### 2) 앱 아이콘 커스터마이징 (`setAppIconToCustom`)
- `INSendMessageIntent`와 `INPerson`을 사용하여 메시지형 알림 스타일 구현
- `INImage`로 커스텀 아바타 이미지 설정 (Assets에서 `my_image.png` 사용)
- `INInteraction.donate()`로 Intent 등록 후 `updating(from:)`으로 알림 업데이트
- **필수 설정**: Info.plist에 `NSUserActivityTypes` 배열 추가, 그 안에 `INSendMessageIntent` 값 포함 필요
- 주요 파라미터:
  - `senderPerson`: 발신자 정보 (아바타, 이름, 고유 ID)
  - `mePerson`: 수신자 정보 (`isMe: true`)
  - `conversationIdentifier`: 대화 고유 식별자

### 3. Notification Content Extension (`NotificationContentExtension`)
- **Extension Point**: `com.apple.usernotifications.content-extension`
- **Principal Class**: [NotificationViewController.swift](NotificationService-Practice/NotificationContentExtension/NotificationViewController.swift)
- **주요 기능**:
  - 푸시 알림의 커스텀 UI 렌더링
  - `myNotificationCategory` 카테고리에 대응
  - `didReceive(_:)` 메서드에서 알림 본문에 "+ Hello" 추가
- Storyboard 기반 UI ([MainInterface.storyboard](NotificationService-Practice/NotificationContentExtension/Base.lproj/MainInterface.storyboard))

## 개발 환경

### 빌드 및 실행
```bash
# Xcode에서 프로젝트 열기
open NotificationService-Practice/NotificationService-Practice.xcodeproj

# 또는 CLI로 빌드
xcodebuild -project NotificationService-Practice/NotificationService-Practice.xcodeproj \
  -scheme NotificationService-Practice \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Extension 디버깅
- Notification Service Extension 디버깅:
  1. Main App을 실행
  2. Xcode > Debug > Attach to Process > NotificationSerciceExtension 선택
  3. APNs 테스트 발송

- Notification Content Extension 디버깅:
  1. Main App을 실행
  2. Xcode > Debug > Attach to Process > NotificationContentExtension 선택
  3. 커스텀 카테고리(`myNotificationCategory`)가 포함된 푸시 발송

### APNs 테스트 페이로드 예시

기본 푸시:
```json
{
  "aps": {
    "alert": {
      "title": "테스트 제목",
      "subtitle": "테스트 부제목",
      "body": "테스트 본문"
    },
    "sound": "default",
    "badge": 1
  }
}
```

이미지 포함 푸시 (Service Extension 트리거):
```json
{
  "aps": {
    "alert": {
      "title": "이미지 푸시",
      "body": "이미지가 포함된 알림입니다"
    },
    "mutable-content": 1
  },
  "image": "https://example.com/image.png"
}
```

커스텀 UI 푸시 (Content Extension 트리거):
```json
{
  "aps": {
    "alert": {
      "title": "커스텀 UI",
      "body": "커스텀 화면이 표시됩니다"
    },
    "category": "myNotificationCategory",
    "mutable-content": 1
  }
}
```

## 주요 기능 구현 위치

| 기능 | 파일 | 메서드/라인 |
|------|------|------------|
| 푸시 권한 요청 | [AppDelegate.swift](NotificationService-Practice/NotificationService-Practice/AppDelegate.swift) | `application(_:didFinishLaunchingWithOptions:)` |
| Device Token 획득 | [AppDelegate.swift](NotificationService-Practice/NotificationService-Practice/AppDelegate.swift) | `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)` |
| Foreground 푸시 수신 | [AppDelegate.swift](NotificationService-Practice/NotificationService-Practice/AppDelegate.swift) | `userNotificationCenter(_:willPresent:withCompletionHandler:)` |
| 커스텀 액션 처리 | [AppDelegate.swift](NotificationService-Practice/NotificationService-Practice/AppDelegate.swift) | `userNotificationCenter(_:didReceive:withCompletionHandler:)` |
| 푸시 내용 수정 | [NotificationService.swift](NotificationService-Practice/NotificationSerciceExtension/NotificationService.swift) | `didReceive(_:withContentHandler:)` |
| 이미지 다운로드/첨부 | [NotificationService.swift](NotificationService-Practice/NotificationSerciceExtension/NotificationService.swift) | `setAttachment(request:contentHandler:)` |
| 앱 아이콘 커스터마이징 | [NotificationService.swift](NotificationService-Practice/NotificationSerciceExtension/NotificationService.swift) | `setAppIconToCustom(request:contentHandler:)` |
| 커스텀 UI 렌더링 | [NotificationViewController.swift](NotificationService-Practice/NotificationContentExtension/NotificationViewController.swift) | `didReceive(_:)` |

## 참고사항

- Extension Target은 Main App과 별도의 프로세스에서 실행됩니다
- Service Extension은 최대 30초의 실행 시간 제한이 있습니다
- Content Extension은 Category ID가 일치해야 트리거됩니다 (현재: `myNotificationCategory`)
- APNs 테스트는 실제 디바이스에서만 가능하며, Simulator에서는 제한적입니다

## 참고 자료

이 프로젝트는 다음 블로그 시리즈를 참고하여 작성되었습니다:
- [iOS) UserNotifications framework (3) - NotificationServiceExtension 알아보기](https://ios-development.tistory.com/1280)
- 해당 시리즈에서 APNs, Notification Service Extension, Notification Content Extension 구현 방법을 학습했습니다
