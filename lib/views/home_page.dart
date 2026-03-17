import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'recipe/recipe_list_page.dart';
import 'mealplan/meal_calendar_page.dart';
import 'shopping/shopping_list_page.dart';
import 'favorites_page.dart';
import 'auth/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    RecipeListPage(),
    MealCalendarPage(),
    ShoppingListPage(),
    FavoritesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GestionRepas'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton(
              icon: const Icon(Icons.account_circle),
              itemBuilder: (_) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text(user?.name ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const PopupMenuItem(value: 'logout', child: Text('Déconnexion')),
              ],
              onSelected: (val) async {
                if (val == 'logout') {
                  final authProvider = context.read<AuthProvider>();
                  final nav = Navigator.of(context);
                  await authProvider.logout();
                  if (!mounted) return;
                  nav.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (_) => false,
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book), label: 'Recettes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Planning'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Courses'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favoris'),
        ],
      ),
    );
  }
}
