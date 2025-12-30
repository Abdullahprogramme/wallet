import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app_router.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const _AppWithAuth(),
    );
  }
}

class _AppWithAuth extends StatefulWidget {
  const _AppWithAuth();

  @override
  State<_AppWithAuth> createState() => _AppWithAuthState();
}

class _AppWithAuthState extends State<_AppWithAuth> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.loadFromPrefs();
    if (mounted) {
      setState(() {
        _isLoggedIn = auth.isLoggedIn;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking auth state
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wallet App',
      theme: AppTheme.lightTheme,
      home: _isLoggedIn ? const HomeScreen() : const SignInScreen(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
