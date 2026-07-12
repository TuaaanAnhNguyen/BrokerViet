// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:app_links/app_links.dart';
import 'features/auth/login_screen.dart';
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
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    final initialUri = await _appLinks.getInitialLink();

    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    print("Deep link received: $uri");

    if (uri.host != 'vnpay_result_page') return;

    final bookingId = uri.queryParameters['booking_id'];
    if (bookingId == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = _navigatorKey.currentState;

      print("Navigator ready: $navigator");

      navigator?.push(
        MaterialPageRoute(
          builder: (_) => VNPayResultPage(bookingId: bookingId),
        ),
      );
    });
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
                return const LoginScreen();
              },
            ),
          );
        },

        home: BlocBuilder<AuthService, AuthState>(
          builder: (context, state) {
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
