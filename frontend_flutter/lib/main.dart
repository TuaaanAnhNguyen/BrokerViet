// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'features/auth/login_screen.dart';
import 'services/auth/auth_service.dart';
import 'features/main/main_navigation_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://dhknnhtskaeltqjdhunl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRoa25uaHRza2FlbHRxamRodW5sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwODAxMjgsImV4cCI6MjA5NDY1NjEyOH0.9BwnUdYlt4PQA8jyvCP7caWjNAmCN9tvGz8-JQ0iWwM',
  );

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
