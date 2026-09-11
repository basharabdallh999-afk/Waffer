import 'package:flutter/material.dart';

import '../features/navigation/presentation/screens/main_navigation_screen.dart';
import '../services/api_service.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({
    super.key,
    ApiService? apiService,
    String? userName,
  });

  @override
  Widget build(BuildContext context) {
    return const MainNavigationScreen();
  }
}
