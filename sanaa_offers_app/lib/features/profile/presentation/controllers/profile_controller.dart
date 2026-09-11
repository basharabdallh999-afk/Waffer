import 'package:flutter/material.dart';

import '../../../auth/domain/entities/user_entity.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({UserEntity? initialUser})
      : _currentUser = initialUser ?? UserEntity.guest();

  UserEntity _currentUser;
  UserEntity get currentUser => _currentUser;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  void updateUser(UserEntity updated) {
    _currentUser = updated;
    notifyListeners();
  }

  void toggleNotifications(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }
}
