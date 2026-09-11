import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/auth_screen.dart';
import '../services/api_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, ApiService? apiService});

  @override
  Widget build(BuildContext context) {
    return const AuthScreen();
  }
}