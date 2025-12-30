import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/change_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/categories/category_detail_screen.dart';
import 'providers/auth_provider.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '/signin';
    
    switch (routeName) {
      case '/signin':
        return MaterialPageRoute(builder: (_) => const SignInScreen());

      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case '/change-password':
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      case '/home':
        return MaterialPageRoute(
          builder: (context) {
            final auth = Provider.of<AuthProvider>(context, listen: false);

            if (!auth.isLoggedIn) {
              return const SignInScreen();
            }
            return const HomeScreen();
          },
        );

      case '/category':
        final category = settings.arguments as Map<String, dynamic>?;
        if (category != null) {
          return MaterialPageRoute(builder: (_) => CategoryDetailScreen(category: category));
        }
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      default:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
    }
  }
}
