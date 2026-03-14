import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/meal_plan_provider.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  DateTime _weekStart = _getMonday(DateTime.now());
  final Set<String> _checked = {};

  static DateTime _getMonday(DateTime d) {
    return d.subtract(Duration(days: d.weekday - 1));
  }

  void _prevWeek() => setState(() {
        _weekStart = _weekStart.subtract(const Duration(days: 7));
        _checked.clear();
      });

  void _nextWeek() => setState(() {
        _weekStart = _weekStart.add(const Duration(days: 7));
        _checked.clear();
      });

  String _formatWeek() {
    final end = _weekStart.add(const Duration(days: 6));
    return '${_weekStart.day}/${_weekStart.month} – ${end.day}/${end.month}/${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealPlanProvider>();
    final items = provider.generateShoppingList(_weekStart);

    return Column(
      children: [
        // Week selector
        Container(
          color: Colors.green.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: _prevWeek,
                  icon: const Icon(Icons.chevron_left)),
              Text('Semaine du ${_formatWeek()}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              IconButton(
                  onPressed: _nextWeek,
                  icon: const Icon(Icons.chevron_right)),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Aucun repas planifié cette semaine',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final ing = items[i];
                    final key = ing.name.toLowerCase();
                    final done = _checked.contains(key);
                    return Card(
                      child: CheckboxListTile(
                        value: done,
                        activeColor: Colors.green,
                        onChanged: (_) => setState(() {
                          if (done) {
                            _checked.remove(key);
                          } else {
                            _checked.add(key);
                          }
                        }),
                        title: Text(
                          ing.name,
                          style: TextStyle(
                            decoration:
                                done ? TextDecoration.lineThrough : null,
                            color: done ? Colors.grey : Colors.black87,
                          ),
                        ),
                        subtitle: ing.quantity.isNotEmpty
                            ? Text('${ing.quantity} ${ing.unit}'.trim())
                            : null,
                        secondary: const Icon(Icons.shopping_basket_outlined,
                            color: Colors.green),
                      ),
                    );
                  },
                ),
        ),
        if (items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '${_checked.length}/${items.length} articles cochés',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
