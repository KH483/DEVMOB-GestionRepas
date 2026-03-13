import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/meal_plan.dart';
import '../../providers/meal_plan_provider.dart';
import 'assign_recipe_page.dart';
import '../../widgets/meal_tile.dart';

class MealCalendarPage extends StatefulWidget {
  const MealCalendarPage({super.key});

  @override
  State<MealCalendarPage> createState() => _MealCalendarPageState();
}

class _MealCalendarPageState extends State<MealCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealPlanProvider>();
    final dayMeal = provider.getDayMeal(_selectedDay);

    return Column(
      children: [
        TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime(2024),
          lastDay: DateTime(2027),
          selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
          onDaySelected: (selected, focused) {
            setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            });
          },
          calendarStyle: CalendarStyle(
            selectedDecoration: const BoxDecoration(
                color: Colors.green, shape: BoxShape.circle),
            todayDecoration: BoxDecoration(
                color: Colors.green.shade200, shape: BoxShape.circle),
          ),
          headerStyle: const HeaderStyle(formatButtonVisible: false),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (ctx, day, events) {
              final dm = provider.getDayMeal(day);
              final count = dm.allRecipes.length;
              if (count == 0) return null;
              return Positioned(
                bottom: 1,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: Colors.orange, shape: BoxShape.circle),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: MealSlot.values.map((slot) {
              return MealTile(
                slot: slot,
                recipe: dayMeal.getSlot(slot),
                onAssign: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AssignRecipePage(
                      date: _selectedDay,
                      slot: slot,
                    ),
                  ),
                ),
                onRemove: () =>
                    provider.assignRecipe(_selectedDay, slot, null),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
