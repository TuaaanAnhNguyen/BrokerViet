// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:app_links/app_links.dart';
import 'features/auth/login_screen.dart';
import 'services/auth/auth_service.dart';
import 'features/main/main_navigation_shell.dart';
import 'features/payment/vnpay_result_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);

  await dotenv.load(fileName: '.env');

  String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await initializeDateFormatting('vi_VN', null);

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
    if (uri.host == 'payment-result') {
      final bookingId = uri.queryParameters['booking_id'];
      final responseCode = uri.queryParameters['response_code'];

      if (bookingId != null) {
        _navigatorKey.currentState?.pushReplacement(
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
        BlocProvider<AuthService>(create: (context) => AuthService()),
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