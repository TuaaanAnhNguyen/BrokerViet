
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
│  │  │  ├─ noVersion
│  │  │  │  └─ buildLogic.lock
│  │  │  └─ vcs-1
│  │  │     └─ gc.properties
│  │  ├─ .kotlin
│  │  │  ├─ errors
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
│  ├─ devtools_options.yaml
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
│  │  │  │  ├─ forgot_password_screen.dart
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
│  │  │  │  ├─ map_screen.dart
│  │  │  │  ├─ notification_screen.dart
│  │  │  │  ├─ search_screen.dart
│  │  │  │  ├─ service_detail_screen.dart
│  │  │  │  └─ service_marketplace_screen.dart
│  │  │  ├─ payment
│  │  │  │  ├─ payment_checkout_screen.dart
│  │  │  │  └─ vnpay_result_page.dart
│  │  │  └─ profile
│  │  │     ├─ account_setting.dart
│  │  │     ├─ profile_menu_screen.dart
│  │  │     └─ profile_screen.dart
│  │  ├─ main.dart
│  │  ├─ models
│  │  │  ├─ bank_mapper.dart
│  │  │  ├─ booking_model.dart
│  │  │  ├─ dashboard_summary_model.dart
│  │  │  ├─ notification_model.dart
│  │  │  ├─ payment_model.dart
│  │  │  ├─ profile_model.dart
│  │  │  ├─ provider_booking_model.dart
│  │  │  ├─ review_model.dart
│  │  │  ├─ service_category_model.dart
│  │  │  └─ service_model.dart
│  │  ├─ screens
│  │  │  └─ provider
│  │  │     ├─ provider_bookings_screen.dart
│  │  │     ├─ provider_dashboard_screen.dart
│  │  │     ├─ provider_services_list_screen.dart
│  │  │     ├─ provider_service_form_screen.dart
│  │  │     ├─ view_provider_screen.dart
│  │  │     └─ widgets
│  │  │        └─ booking_detail_sheet.dart
│  │  ├─ services
│  │  │  ├─ auth
│  │  │  │  └─ auth_service.dart
│  │  │  ├─ booking
│  │  │  │  └─ booking_service.dart
│  │  │  ├─ chat
│  │  │  │  └─ chat_service.dart
│  │  │  ├─ map
│  │  │  │  └─ map_service.dart
│  │  │  ├─ marketplace
│  │  │  │  └─ service_marketplace_service.dart
│  │  │  ├─ notification
│  │  │  │  ├─ firebase_cloud_messaging_handler.dart
│  │  │  │  └─ notification_service.dart
│  │  │  ├─ payment
│  │  │  │  └─ vnpay_service.dart
│  │  │  ├─ profile
│  │  │  │  └─ profile_service.dart
│  │  │  └─ provider
│  │  │     ├─ provider_bookings_service.dart
│  │  │     ├─ provider_dashboard_service.dart
│  │  │     └─ provider_services_service.dart
│  │  ├─ utils
│  │  │  └─ booking_status_utils.dart
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
│  │     ├─ payment
│  │     │  └─ vietqr_payment.dart
│  │     ├─ profile
│  │     │  ├─ account_setting_tile.dart
│  │     │  └─ edit_profile_sheet.dart
│  │     ├─ provider
│  │     │  └─ provider_booking_card.dart
│  │     └─ service
│  │        ├─ category_selector.dart
│  │        ├─ nearby_provider_tile.dart
│  │        └─ service_card.dart
│  ├─ pubspec.lock
│  ├─ pubspec.yaml
│  ├─ README.md
│  ├─ test
│  │  └─ widget_test.dart
│  ├─ VNPAY_INTERGRATION_GUIDE.md
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