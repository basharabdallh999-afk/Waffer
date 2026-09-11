import 'package:flutter/material.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../offers/data/datasources/offers_remote_datasource.dart';
import '../../../offers/data/repositories/offers_repository_impl.dart';
import '../../../offers/domain/usecases/get_offers_usecase.dart';
import '../../../offers/presentation/controllers/offers_controller.dart';
import '../../../offers/presentation/screens/categories_screen.dart';
import '../../../offers/presentation/screens/favorites_screen.dart';
import '../../../offers/presentation/screens/home_screen.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../profile/presentation/screens/account_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
    this.initialUser,
    this.initialIndex = 0,
  });

  final UserEntity? initialUser;
  final int initialIndex;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  late OffersController _offersController;
  late ProfileController _profileController;

  static const Color primaryRed = Color(0xFFB3241C);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    final offersRepo = OffersRepositoryImpl(OffersRemoteDataSourceImpl());
    _offersController = OffersController(
      getOffersUseCase: GetOffersUseCase(offersRepo),
    )..loadOffers();

    _profileController = ProfileController(initialUser: widget.initialUser);
  }

  @override
  void dispose() {
    _offersController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        offersController: _offersController,
        onSelectTab: (index) => setState(() => _currentIndex = index),
      ),
      CategoriesScreen(offersController: _offersController),
      FavoritesScreen(offersController: _offersController),
      AccountScreen(profileController: _profileController),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: primaryRed,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'الأقسام',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite_rounded),
              label: 'المفضلة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}
