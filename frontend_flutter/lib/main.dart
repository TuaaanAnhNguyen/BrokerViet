// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:app_links/app_links.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/password_reset_page.dart';
import 'services/auth/auth_service.dart';
import 'services/profile/profile_service.dart';
import 'features/main/main_navigation_shell.dart';
import 'features/payment/vnpay_result_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import './services/notification/firebase_cloud_messaging_handler.dart';
import './services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);

  await dotenv.load(fileName: '.env');

  String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await initializeDateFormatting('vi_VN', null);

  String firebaseMessagingApiKey =
      dotenv.env['FIREBASE_MESSAGING_API_KEY'] ?? '';
  String firebaseMessagingAppId = dotenv.env['FIREBASE_MESSAGING_APP_ID'] ?? '';
  String firebaseMessagingSenderId =
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  String firebaseProjectId = dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: firebaseMessagingApiKey,
        appId: firebaseMessagingAppId,
        messagingSenderId: firebaseMessagingSenderId,
        projectId: firebaseProjectId,
        storageBucket: "$firebaseProjectId.firebasestorage.app",
      ),
    );

    await FcmHandler().initNotificationLifecycle();
  } catch (e) {
    print("Firebase Init Failed: $e");
  }

  runApp(const BrokerVietApp());
}

class BrokerVietApp extends StatefulWidget {
  const BrokerVietApp({super.key});

  @override
  State<BrokerVietApp> createState() => _BrokerVietAppState();
}

class _BrokerVietAppState extends State<BrokerVietApp> {
  final _appLinks = AppLinks();
  static String? _processedInitialLink;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    final initialUri = await _appLinks.getInitialLink();

    if (initialUri != null) {
      final uriString = initialUri.toString();
      if (_processedInitialLink == uriString) {
        debugPrint("Bỏ qua Initial Deep Link cũ đã xử lý: $uriString");
      } else {
        _processedInitialLink = uriString;
        _handleDeepLink(initialUri);
      }
    }

    _appLinks.uriLinkStream.listen((uri) {
      _processedInitialLink = uri.toString();
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    print("======================");
    print("Deep Link Received");
    debugPrint("FULL URI:");
    debugPrint(uri.toString());

    debugPrint("scheme=${uri.scheme}");
    debugPrint("host=${uri.host}");
    debugPrint("path=${uri.path}");
    debugPrint("query=${uri.query}");
    debugPrint("fragment=${uri.fragment}");

    switch (uri.host) {
      case "vnpay_result_page":
        _handleVNPay(uri);
        break;

      case "password_reset":
        _handlePasswordReset(uri);
        break;
      case "email_confirmed":
        _handleEmailConfirmed();
        break;

      default:
        print("Unknown deep link");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthService>(
          create: (context) => AuthService()..add(AppStarted()),
        ),
        BlocProvider<ProfileService>(create: (context) => ProfileService()),
      ],
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        title: 'BrokerViet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),

        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => BlocBuilder<AuthService, AuthState>(
              builder: (context, state) {
                if (state is AuthSuccess) {
                  return const MainNavigationShell();
                }
                print("CURRENT STATE: ${state.runtimeType}");
                return const LoginScreen();
              },
            ),
          );
        },

        home: BlocBuilder<AuthService, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is AuthSuccess) {
              return const MainNavigationShell();
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}

void _handleVNPay(Uri uri) {
  final bookingId = uri.queryParameters["booking_id"];

  if (bookingId == null) return;

  Future.delayed(const Duration(milliseconds: 300), () {
    final navigator = NavigationService.navigatorKey.currentState;

    if (navigator == null) return;

    navigator.push(
      MaterialPageRoute(builder: (_) => VNPayResultPage(bookingId: bookingId)),
    );
  });
}

void _handlePasswordReset(Uri uri) {
  debugPrint("PASSWORD RESET LINK RECEIVED");
  debugPrint(uri.toString());

  Future.delayed(const Duration(milliseconds: 300), () {
    final context = NavigationService.navigatorKey.currentContext;
    final navigator = NavigationService.navigatorKey.currentState;

    if (context != null && navigator != null) {
      final authService = BlocProvider.of<AuthService>(context);
      final currentState = authService.state;

      if (currentState is AuthSuccess) {
        debugPrint(
          "Bỏ qua Deep Link Password Reset cũ vì người dùng đã đăng nhập.",
        );
        return;
      }

      navigator.push(
        MaterialPageRoute(builder: (_) => const PasswordResetPage()),
      );
    }
  });
}

void _handleEmailConfirmed() {
  final navigator = NavigationService.navigatorKey.currentState;

  if (navigator == null) return;

  ScaffoldMessenger.of(
    NavigationService.navigatorKey.currentContext!,
  ).showSnackBar(
    const SnackBar(
      backgroundColor: Colors.green,
      content: Text('Email đã được xác thực thành công.'),
    ),
  );
}
