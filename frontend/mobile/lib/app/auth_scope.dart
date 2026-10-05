import 'package:flutter/widgets.dart';

import '../features/authentication/data/auth_repository.dart';

class AuthScope extends InheritedWidget {
  const AuthScope({
    required this.repository,
    required super.child,
    super.key,
  });

  final AuthRepository repository;

  static AuthRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope is missing above this screen');
    return scope!.repository;
  }

  @override
  bool updateShouldNotify(AuthScope oldWidget) {
    return repository != oldWidget.repository;
  }
}
