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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);

  await dotenv.load(fileName: '.env');

  String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await initializeDateFormatting('vi_VN', null);

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCcf9ueYgdZdtODLjBYMmSpcPoRdJ7jjI4",
        appId: "1:579951195028:android:c39859a995e4badf6a9581",
        messagingSenderId: "579951195028",
        projectId: "brokerviet-b7d3f",
        storageBucket: "brokerviet-b7d3f.firebasestorage.app",
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
    print("Scheme: ${uri.scheme}");
    print("Host: ${uri.host}");
    print("Query: ${uri.queryParameters}");
    if (uri.host == 'vnpay_result_page') {
      final txnRef = uri.queryParameters['txn_ref'];
      if (txnRef != null) {
        // Assume txnRef is bookingId_timestamp_random
        final bookingId = txnRef.split('_').first;
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => VNPayResultPage(
              bookingId: bookingId,

            ),
          ),
        );
      }
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
          navigatorKey: _navigatorKey,
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
