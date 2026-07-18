
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
│  │  │  │     ├─ errors-1783826450204.log
│  │  │  │     ├─ errors-1783826450223.log
│  │  │  │     ├─ errors-1783826450234.log
│  │  │  │     ├─ errors-1783826450283.log
│  │  │  │     ├─ errors-1783826648114.log
│  │  │  │     ├─ errors-1783826648145.log
│  │  │  │     ├─ errors-1783826648154.log
│  │  │  │     ├─ errors-1783826648165.log
│  │  │  │     ├─ errors-1784096587824.log
│  │  │  │     ├─ errors-1784096587868.log
│  │  │  │     ├─ errors-1784096587891.log
│  │  │  │     ├─ errors-1784096587972.log
│  │  │  │     ├─ errors-1784184093988.log
│  │  │  │     ├─ errors-1784184094013.log
│  │  │  │     ├─ errors-1784184094019.log
│  │  │  │     ├─ errors-1784184094030.log
│  │  │  │     ├─ errors-1784202505838.log
│  │  │  │     ├─ errors-1784202505856.log
│  │  │  │     ├─ errors-1784202505864.log
│  │  │  │     ├─ errors-1784202505902.log
│  │  │  │     ├─ errors-1784206219886.log
│  │  │  │     ├─ errors-1784206219960.log
│  │  │  │     ├─ errors-1784206219984.log
│  │  │  │     └─ errors-1784206220020.log
│  │  │  ├─ noVersion
│  │  │  │  └─ buildLogic.lock
│  │  │  └─ vcs-1
│  │  │     └─ gc.properties
│  │  ├─ .kotlin
│  │  │  ├─ errors
│  │  │  │  ├─ errors-1783826450204.log
│  │  │  │  ├─ errors-1783826450223.log
│  │  │  │  ├─ errors-1783826450234.log
│  │  │  │  ├─ errors-1783826450283.log
│  │  │  │  ├─ errors-1783826648114.log
│  │  │  │  ├─ errors-1783826648145.log
│  │  │  │  ├─ errors-1783826648154.log
│  │  │  │  ├─ errors-1783826648165.log
│  │  │  │  ├─ errors-1784096587824.log
│  │  │  │  ├─ errors-1784096587867.log
│  │  │  │  ├─ errors-1784096587891.log
│  │  │  │  ├─ errors-1784096587972.log
│  │  │  │  ├─ errors-1784184093988.log
│  │  │  │  ├─ errors-1784184094013.log
│  │  │  │  ├─ errors-1784184094019.log
│  │  │  │  ├─ errors-1784184094030.log
│  │  │  │  ├─ errors-1784202505838.log
│  │  │  │  ├─ errors-1784202505856.log
│  │  │  │  ├─ errors-1784202505864.log
│  │  │  │  ├─ errors-1784202505902.log
│  │  │  │  ├─ errors-1784206219885.log
│  │  │  │  ├─ errors-1784206219960.log
│  │  │  │  ├─ errors-1784206219984.log
│  │  │  │  └─ errors-1784206220020.log
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
│  │  │  │  ├─ password_reset_page.dart
│  │  │  │  └─ signup_screen.dart
│  │  │  ├─ booking
│  │  │  │  ├─ booking_history_screen.dart
│  │  │  │  └─ booking_service_screen.dart
│  │  │  ├─ chat
│  │  │  │  ├─ chat_list_screen.dart
│  │  │  │  └─ conversation_screen.dart
│  │  │  ├─ home.dart
│  │  │  ├─ main
│  │  │  │  ├─ all_reviews_screen.dart
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
│  │  │  ├─ geocoding_result.dart
│  │  │  ├─ notification_model.dart
│  │  │  ├─ payment_model.dart
│  │  │  ├─ profile_model.dart
│  │  │  ├─ provider_booking_model.dart
│  │  │  ├─ provider_location_model.dart
│  │  │  ├─ provider_service_info_model.dart
│  │  │  ├─ reverse_geocoding_result.dart
│  │  │  ├─ review_model.dart
│  │  │  ├─ route_result_model.dart
│  │  │  ├─ service_category_model.dart
│  │  │  ├─ service_model.dart
│  │  │  └─ voucher_model.dart
│  │  ├─ screens
│  │  │  └─ provider
│  │  │     ├─ provider_bookings_screen.dart
│  │  │     ├─ provider_dashboard_screen.dart
│  │  │     ├─ provider_services_list_screen.dart
│  │  │     ├─ provider_service_form_screen.dart
│  │  │     ├─ view_provider_screen.dart
│  │  │     ├─ voucher
│  │  │     │  ├─ voucher_form_screen.dart
│  │  │     │  └─ voucher_list_screen.dart
│  │  │     └─ widgets
│  │  │        └─ booking_detail_sheet.dart
│  │  ├─ services
│  │  │  ├─ auth
│  │  │  │  ├─ auth_service.dart
│  │  │  │  └─ firebase_phone_auth_service.dart
│  │  │  ├─ booking
│  │  │  │  └─ booking_service.dart
│  │  │  ├─ chat
│  │  │  │  └─ chat_service.dart
│  │  │  ├─ map-location
│  │  │  │  └─ location_service.dart
│  │  │  ├─ marketplace
│  │  │  │  └─ service_marketplace_service.dart
│  │  │  ├─ navigation_service.dart
│  │  │  ├─ notification
│  │  │  │  ├─ firebase_cloud_messaging_handler.dart
│  │  │  │  └─ notification_service.dart
│  │  │  ├─ payment
│  │  │  │  └─ vnpay_service.dart
│  │  │  ├─ profile
│  │  │  │  └─ profile_service.dart
│  │  │  ├─ provider
│  │  │  │  ├─ provider_bookings_service.dart
│  │  │  │  ├─ provider_dashboard_service.dart
│  │  │  │  └─ provider_services_service.dart
│  │  │  └─ voucher_service.dart
│  │  ├─ utils
│  │  │  ├─ booking_status_utils.dart
│  │  │  └─ voucher_status_utils.dart
│  │  └─ widgets
│  │     ├─ auth
│  │     │  ├─ auth_header.dart
│  │     │  ├─ email_input_field.dart
│  │     │  ├─ forgot_password_form.dart
│  │     │  ├─ login_form.dart
│  │     │  ├─ phone_input_fields.dart
│  │     │  ├─ reset_password_fields.dart
│  │     │  └─ signup_form.dart
│  │     ├─ avatar_builder.dart
│  │     ├─ booking
│  │     │  ├─ booking_address_input.dart
│  │     │  ├─ booking_header_card.dart
│  │     │  ├─ booking_notes_input.dart
│  │     │  ├─ booking_schedule_tile.dart
│  │     │  ├─ bottom_booking_actions.dart
│  │     │  ├─ invoice_breakdown_card.dart
│  │     │  └─ payment_method_selector.dart
│  │     ├─ booking_card.dart
│  │     ├─ chat
│  │     │  ├─ chatroom_tile.dart
│  │     │  ├─ chat_app_bar.dart
│  │     │  ├─ chat_bubble.dart
│  │     │  └─ chat_input_bar.dart
│  │     ├─ custom_text_field.dart
│  │     ├─ map
│  │     │  ├─ destination_marker.dart
│  │     │  ├─ error_banner.dart
│  │     │  ├─ loading_overlay.dart
│  │     │  ├─ map_content_view.dart
│  │     │  ├─ map_floating_overlay.dart
│  │     │  ├─ map_tile_layer.dart
│  │     │  ├─ my_location_button.dart
│  │     │  ├─ provider_service_info_card.dart
│  │     │  ├─ route_info_card.dart
│  │     │  ├─ route_polyline_layer.dart
│  │     │  └─ user_location_marker.dart
│  │     ├─ network_image_fallback.dart
│  │     ├─ notification_tile.dart
│  │     ├─ payment
│  │     │  ├─ payment_failed_widget.dart
│  │     │  ├─ payment_pending_widget.dart
│  │     │  ├─ payment_success_widget.dart
│  │     │  ├─ payment_unknown_widget.dart
│  │     │  └─ vietqr_payment.dart
│  │     ├─ profile
│  │     │  ├─ profile_avatar_picker.dart
│  │     │  ├─ profile_contact_card.dart
│  │     │  ├─ profile_identity_card.dart
│  │     │  ├─ profile_info_section.dart
│  │     │  ├─ profile_provider_card.dart
│  │     │  ├─ profile_summary_card.dart
│  │     │  └─ setting
│  │     │     ├─ account_setting_tile.dart
│  │     │     ├─ change_email_sheet.dart
│  │     │     ├─ change_password_sheet.dart
│  │     │     ├─ edit_profile_sheet.dart
│  │     │     ├─ profile_address_section.dart
│  │     │     ├─ profile_contact_section.dart
│  │     │     ├─ profile_danger_section.dart
│  │     │     ├─ profile_edit_button.dart
│  │     │     ├─ profile_header.dart
│  │     │     ├─ profile_provider_section.dart
│  │     │     └─ profile_security_section.dart
│  │     ├─ provider
│  │     │  └─ provider_booking_card.dart
│  │     ├─ review
│  │     │  └─ review_tile.dart
│  │     ├─ service
│  │     │  ├─ category_selector.dart
│  │     │  ├─ marketplace
│  │     │  │  ├─ market_search_bar.dart
│  │     │  │  ├─ nearby_providers_section.dart
│  │     │  │  └─ service_list_section.dart
│  │     │  ├─ nearby_provider_tile.dart
│  │     │  ├─ search
│  │     │  │  ├─ search_empty_state.dart
│  │     │  │  ├─ search_no_results_state.dart
│  │     │  │  ├─ search_price_filter.dart
│  │     │  │  └─ search_results_list.dart
│  │     │  ├─ service_card.dart
│  │     │  └─ service_detail
│  │     │     ├─ service_description_section.dart
│  │     │     ├─ service_detail_app_bar.dart
│  │     │     ├─ service_price_packages_section.dart
│  │     │     ├─ service_provider_card.dart
│  │     │     ├─ service_reviews_section.dart
│  │     │     ├─ service_sticky_action_dock.dart
│  │     │     ├─ service_tags_section.dart
│  │     │     └─ service_title_section.dart
│  │     └─ voucher
│  │        ├─ voucher_badge.dart
│  │        └─ voucher_input_field.dart
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
   ├─ config.toml
   └─ functions
      ├─ create-booking-with-voucher
      │  ├─ .npmrc
      │  ├─ deno.json
      │  └─ index.ts
      ├─ create-provider-voucher
      │  ├─ .npmrc
      │  ├─ deno.json
      │  └─ index.ts
      ├─ get-active-vouchers-for-service
      │  ├─ .npmrc
      │  ├─ deno.json
      │  └─ index.ts
      ├─ get-provider-bookings
      │  ├─ .npmrc
      │  ├─ deno.json
      │  └─ index.ts
      ├─ get-provider-dashboard-summary
      │  ├─ .npmrc
      │  ├─ deno.json
      │  └─ index.ts
      ├─ get-provider-upcoming-bookings
      │  ├─ .npmrc
      │  ├─ deno.json
      │  └─ index.ts
      ├─ get-provider-vouchers
      │  ├─ .npmrc
      │  ├─ deno.json
      │  └─ index.ts
      ├─ update-booking-status
      │  ├─ .npmrc
      │  ├─ deno.json
      │  └─ index.ts
      ├─ update-voucher-status
      │  ├─ .npmrc
      │  ├─ deno.json
      │  └─ index.ts
      ├─ validate-voucher
      │  ├─ .npmrc
      │  ├─ deno.json
      │  └─ index.ts
      └─ _shared
         └─ cors.ts

```