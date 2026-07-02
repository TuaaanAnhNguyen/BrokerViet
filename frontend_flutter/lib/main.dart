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

  void _initDeepLinks() {
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.host == 'payment-result') {
      final txnRef = uri.queryParameters['vnp_TxnRef'];
      if (txnRef != null) {
        // Assume txnRef is bookingId_timestamp_random
        final bookingId = txnRef.split('_').first;
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => VNPayResultPage(bookingId: bookingId),
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
