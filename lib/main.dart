import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/meal_plan_provider.dart';
import 'views/auth/login_page.dart';
import 'views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(MealPlannerApp(authProvider: authProvider));
}

class MealPlannerApp extends StatelessWidget {
  final AuthProvider authProvider;
  const MealPlannerApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => MealPlanProvider()),
      ],
      child: MaterialApp(
        title: 'GestionRepas',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: authProvider.isLoggedIn
            ? const _AutoLoadHome()
            : const LoginPage(),
      ),
    );
  }
}

class _AutoLoadHome extends StatefulWidget {
  const _AutoLoadHome();

  @override
  State<_AutoLoadHome> createState() => _AutoLoadHomeState();
}

class _AutoLoadHomeState extends State<_AutoLoadHome> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final recipeProvider = context.read<RecipeProvider>();
    final mealProvider = context.read<MealPlanProvider>();
    final userId = auth.user!.id;
    await recipeProvider.load(userId);
    await mealProvider.load(userId);
    if (mounted) setState(() => _loaded = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }
    return const HomePage();
  }
}
