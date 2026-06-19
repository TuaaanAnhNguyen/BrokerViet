
```
BrokerViet
├─ backend_dotnet
│  ├─ appsettings.json
│  ├─ brokerviet_dotnet.csproj
│  ├─ Configuration
│  │  └─ SupabaseSettings.cs
│  ├─ Controllers
│  │  ├─ ProfileController.cs
│  │  └─ ServiceController.cs
│  ├─ Dtos
│  │  ├─ Requests
│  │  │  ├─ RegisterRequestDto.cs
│  │  │  └─ ServiceSearchRequestDto.cs
│  │  └─ Responses
│  │     └─ ServiceSearchItemDto.cs
│  ├─ Extensions
│  │  └─ ServiceCollectionExtensions.cs
│  ├─ Models
│  │  ├─ AuditLog.cs
│  │  ├─ Booking.cs
│  │  ├─ Chatroom.cs
│  │  ├─ Message.cs
│  │  ├─ Notification.cs
│  │  ├─ Profile.cs
│  │  ├─ Service.cs
│  │  ├─ ServiceCategory.cs
│  │  └─ Temp.cs
│  ├─ Program.cs
│  ├─ Properties
│  │  └─ launchSettings.json
│  ├─ Repositories
│  │  ├─ AuditLogRepository.cs
│  │  ├─ BookingRepository.cs
│  │  ├─ ChatroomRepository.cs
│  │  ├─ MessageRepository.cs
│  │  ├─ NotificationRepository.cs
│  │  ├─ ProfileRepository.cs
│  │  ├─ ServiceCategoryRepository.cs
│  │  ├─ ServiceRepository.cs
│  │  ├─ SupabaseRepository.cs
│  │  └─ TempRepository.cs
│  └─ Services
│     ├─ Impl
│     │  ├─ ProfileServiceImpl.cs
│     │  └─ ServiceSearchServiceImpl.cs
│     ├─ ProfileService.cs
│     └─ ServiceSearchService.cs
├─ frontend_flutter
│  ├─ .metadata
│  ├─ analysis_options.yaml
│  ├─ android
│  │  ├─ .gradle
│  │  │  ├─ 8.14
│  │  │  │  ├─ checksums
│  │  │  │  │  ├─ checksums.lock
│  │  │  │  │  ├─ md5-checksums.bin
│  │  │  │  │  └─ sha1-checksums.bin
│  │  │  │  ├─ executionHistory
│  │  │  │  │  ├─ executionHistory.bin
│  │  │  │  │  └─ executionHistory.lock
│  │  │  │  ├─ expanded
│  │  │  │  ├─ fileChanges
│  │  │  │  │  └─ last-build.bin
│  │  │  │  ├─ fileHashes
│  │  │  │  │  ├─ fileHashes.bin
│  │  │  │  │  ├─ fileHashes.lock
│  │  │  │  │  └─ resourceHashesCache.bin
│  │  │  │  ├─ gc.properties
│  │  │  │  └─ vcsMetadata
│  │  │  ├─ buildOutputCleanup
│  │  │  │  ├─ buildOutputCleanup.lock
│  │  │  │  ├─ cache.properties
│  │  │  │  └─ outputFiles.bin
│  │  │  ├─ file-system.probe
│  │  │  ├─ kotlin
│  │  │  │  └─ errors
│  │  │  │     ├─ errors-1781048745797.log
│  │  │  │     ├─ errors-1781048745816.log
│  │  │  │     ├─ errors-1781051652967.log
│  │  │  │     ├─ errors-1781051652977.log
│  │  │  │     ├─ errors-1781071339465.log
│  │  │  │     ├─ errors-1781071339477.log
│  │  │  │     ├─ errors-1781072190139.log
│  │  │  │     ├─ errors-1781072190148.log
│  │  │  │     ├─ errors-1781108389885.log
│  │  │  │     ├─ errors-1781108389893.log
│  │  │  │     ├─ errors-1781110576626.log
│  │  │  │     ├─ errors-1781110576641.log
│  │  │  │     ├─ errors-1781157547997.log
│  │  │  │     ├─ errors-1781157548010.log
│  │  │  │     ├─ errors-1781158066479.log
│  │  │  │     ├─ errors-1781158066493.log
│  │  │  │     ├─ errors-1781160709209.log
│  │  │  │     ├─ errors-1781160709218.log
│  │  │  │     ├─ errors-1781169032369.log
│  │  │  │     ├─ errors-1781169032391.log
│  │  │  │     ├─ errors-1781505869064.log
│  │  │  │     └─ errors-1781505869082.log
│  │  │  ├─ noVersion
│  │  │  │  └─ buildLogic.lock
│  │  │  └─ vcs-1
│  │  │     └─ gc.properties
│  │  ├─ .kotlin
│  │  │  ├─ errors
│  │  │  │  ├─ errors-1781048745797.log
│  │  │  │  ├─ errors-1781048745816.log
│  │  │  │  ├─ errors-1781051652967.log
│  │  │  │  ├─ errors-1781051652977.log
│  │  │  │  ├─ errors-1781071339465.log
│  │  │  │  ├─ errors-1781071339477.log
│  │  │  │  ├─ errors-1781072190139.log
│  │  │  │  ├─ errors-1781072190148.log
│  │  │  │  ├─ errors-1781108389885.log
│  │  │  │  ├─ errors-1781108389893.log
│  │  │  │  ├─ errors-1781110576626.log
│  │  │  │  ├─ errors-1781110576641.log
│  │  │  │  ├─ errors-1781157547997.log
│  │  │  │  ├─ errors-1781157548010.log
│  │  │  │  ├─ errors-1781158066479.log
│  │  │  │  ├─ errors-1781158066493.log
│  │  │  │  ├─ errors-1781160709209.log
│  │  │  │  ├─ errors-1781160709218.log
│  │  │  │  ├─ errors-1781169032369.log
│  │  │  │  ├─ errors-1781169032390.log
│  │  │  │  ├─ errors-1781505869064.log
│  │  │  │  └─ errors-1781505869082.log
│  │  │  └─ sessions
│  │  ├─ app
│  │  │  ├─ build.gradle.kts
│  │  │  └─ src
│  │  │     ├─ debug
│  │  │     │  └─ AndroidManifest.xml
│  │  │     ├─ main
│  │  │     │  ├─ AndroidManifest.xml
│  │  │     │  ├─ java
│  │  │     │  │  └─ io
│  │  │     │  │     └─ flutter
│  │  │     │  │        └─ plugins
│  │  │     │  │           └─ GeneratedPluginRegistrant.java
│  │  │     │  ├─ kotlin
│  │  │     │  │  └─ com
│  │  │     │  │     └─ example
│  │  │     │  │        └─ broker_viet
│  │  │     │  │           └─ MainActivity.kt
│  │  │     │  └─ res
│  │  │     │     ├─ drawable
│  │  │     │     │  └─ launch_background.xml
│  │  │     │     ├─ drawable-v21
│  │  │     │     │  └─ launch_background.xml
│  │  │     │     ├─ mipmap-hdpi
│  │  │     │     │  └─ ic_launcher.png
│  │  │     │     ├─ mipmap-mdpi
│  │  │     │     │  └─ ic_launcher.png
│  │  │     │     ├─ mipmap-xhdpi
│  │  │     │     │  └─ ic_launcher.png
│  │  │     │     ├─ mipmap-xxhdpi
│  │  │     │     │  └─ ic_launcher.png
│  │  │     │     ├─ mipmap-xxxhdpi
│  │  │     │     │  └─ ic_launcher.png
│  │  │     │     ├─ values
│  │  │     │     │  └─ styles.xml
│  │  │     │     └─ values-night
│  │  │     │        └─ styles.xml
│  │  │     └─ profile
│  │  │        └─ AndroidManifest.xml
│  │  ├─ broker_viet_android.iml
│  │  ├─ build.gradle.kts
│  │  ├─ gradle
│  │  │  └─ wrapper
│  │  │     ├─ gradle-wrapper.jar
│  │  │     └─ gradle-wrapper.properties
│  │  ├─ gradle.properties
│  │  ├─ gradlew
│  │  ├─ gradlew.bat
│  │  ├─ local.properties
│  │  └─ settings.gradle.kts
│  ├─ assets
│  │  ├─ default_profile.png
│  │  └─ no_icon_placeholder.png
│  ├─ broker_viet.iml
│  ├─ ios
│  │  ├─ Flutter
│  │  │  ├─ AppFrameworkInfo.plist
│  │  │  ├─ Debug.xcconfig
│  │  │  ├─ ephemeral
│  │  │  │  ├─ flutter_lldbinit
│  │  │  │  └─ flutter_lldb_helper.py
│  │  │  ├─ flutter_export_environment.sh
│  │  │  ├─ Generated.xcconfig
│  │  │  └─ Release.xcconfig
│  │  ├─ Runner
│  │  │  ├─ AppDelegate.swift
│  │  │  ├─ Assets.xcassets
│  │  │  │  ├─ AppIcon.appiconset
│  │  │  │  │  ├─ Contents.json
│  │  │  │  │  ├─ Icon-App-1024x1024@1x.png
│  │  │  │  │  ├─ Icon-App-20x20@1x.png
│  │  │  │  │  ├─ Icon-App-20x20@2x.png
│  │  │  │  │  ├─ Icon-App-20x20@3x.png
│  │  │  │  │  ├─ Icon-App-29x29@1x.png
│  │  │  │  │  ├─ Icon-App-29x29@2x.png
│  │  │  │  │  ├─ Icon-App-29x29@3x.png
│  │  │  │  │  ├─ Icon-App-40x40@1x.png
│  │  │  │  │  ├─ Icon-App-40x40@2x.png
│  │  │  │  │  ├─ Icon-App-40x40@3x.png
│  │  │  │  │  ├─ Icon-App-60x60@2x.png
│  │  │  │  │  ├─ Icon-App-60x60@3x.png
│  │  │  │  │  ├─ Icon-App-76x76@1x.png
│  │  │  │  │  ├─ Icon-App-76x76@2x.png
│  │  │  │  │  └─ Icon-App-83.5x83.5@2x.png
│  │  │  │  └─ LaunchImage.imageset
│  │  │  │     ├─ Contents.json
│  │  │  │     ├─ LaunchImage.png
│  │  │  │     ├─ LaunchImage@2x.png
│  │  │  │     ├─ LaunchImage@3x.png
│  │  │  │     └─ README.md
│  │  │  ├─ Base.lproj
│  │  │  │  ├─ LaunchScreen.storyboard
│  │  │  │  └─ Main.storyboard
│  │  │  ├─ GeneratedPluginRegistrant.h
│  │  │  ├─ GeneratedPluginRegistrant.m
│  │  │  ├─ Info.plist
│  │  │  ├─ Runner-Bridging-Header.h
│  │  │  └─ SceneDelegate.swift
│  │  ├─ Runner.xcodeproj
│  │  │  ├─ project.pbxproj
│  │  │  ├─ project.xcworkspace
│  │  │  │  ├─ contents.xcworkspacedata
│  │  │  │  └─ xcshareddata
│  │  │  │     ├─ IDEWorkspaceChecks.plist
│  │  │  │     └─ WorkspaceSettings.xcsettings
│  │  │  └─ xcshareddata
│  │  │     └─ xcschemes
│  │  │        └─ Runner.xcscheme
│  │  ├─ Runner.xcworkspace
│  │  │  ├─ contents.xcworkspacedata
│  │  │  └─ xcshareddata
│  │  │     ├─ IDEWorkspaceChecks.plist
│  │  │     └─ WorkspaceSettings.xcsettings
│  │  └─ RunnerTests
│  │     └─ RunnerTests.swift
│  ├─ lib
│  │  ├─ features
│  │  │  ├─ auth
│  │  │  │  ├─ login_screen.dart
│  │  │  │  └─ signup_screen.dart
│  │  │  ├─ booking
│  │  │  │  ├─ booking_history_screen.dart
│  │  │  │  └─ booking_service_screen.dart
│  │  │  ├─ chat
│  │  │  │  ├─ chat_list_screen.dart
│  │  │  │  └─ conversation_screen.dart
│  │  │  ├─ home.dart
│  │  │  ├─ main
│  │  │  │  ├─ main_navigation_shell.dart
│  │  │  │  ├─ notification_screen.dart
│  │  │  │  ├─ search_screen.dart
│  │  │  │  ├─ service_detail_screen.dart
│  │  │  │  └─ service_marketplace_screen.dart
│  │  │  └─ profile
│  │  │     ├─ account_setting.dart
│  │  │     ├─ profile_menu_screen.dart
│  │  │     └─ profile_screen.dart
│  │  ├─ main.dart
│  │  ├─ models
│  │  │  ├─ booking_model.dart
│  │  │  ├─ notification_model.dart
│  │  │  ├─ service_category_model.dart
│  │  │  ├─ service_model.dart
│  │  │  └─ user_model.dart
│  │  ├─ services
│  │  │  ├─ auth
│  │  │  │  └─ auth_service.dart
│  │  │  ├─ booking
│  │  │  │  ├─ booking_service.dart
│  │  │  │  └─ booking_submission_service.dart
│  │  │  └─ marketplace
│  │  │     └─ service_marketplace_service.dart
│  │  └─ widgets
│  │     ├─ auth
│  │     │  ├─ auth_header.dart
│  │     │  ├─ login_form.dart
│  │     │  └─ signup_form.dart
│  │     ├─ avatar_builder.dart
│  │     ├─ booking_card.dart
│  │     ├─ button.dart
│  │     ├─ custom_text_field.dart
│  │     ├─ network_image_fallback.dart
│  │     ├─ notification_tile.dart
│  │     └─ service
│  │        ├─ category_selector.dart
│  │        ├─ nearby_provider_tile.dart
│  │        └─ service_card.dart
│  ├─ pubspec.lock
│  ├─ pubspec.yaml
│  ├─ README.md
│  ├─ test
│  │  └─ widget_test.dart
│  └─ web
│     ├─ favicon.png
│     ├─ icons
│     │  ├─ Icon-192.png
│     │  ├─ Icon-512.png
│     │  ├─ Icon-maskable-192.png
│     │  └─ Icon-maskable-512.png
│     ├─ index.html
│     └─ manifest.json
├─ README.md
└─ supabase
   └─ config.toml

```