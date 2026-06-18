// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'features/auth/login_screen.dart';
import 'services/auth/auth_service.dart';
import 'features/main/main_navigation_shell.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);

  await dotenv.load(fileName: '.env');

  String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const BrokerVietApp());
}

class BrokerVietApp extends StatelessWidget {
  const BrokerVietApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthService>(create: (context) => AuthService()),
      ],
      child: MaterialApp(
        title: 'BrokerViet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: BlocBuilder<AuthService, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              return MainNavigationShell();
            }
            return LoginScreen();
          },
        ),
      ),
    );
  }
}
