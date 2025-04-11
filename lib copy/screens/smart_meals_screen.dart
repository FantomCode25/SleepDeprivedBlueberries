import 'package:flutter/material.dart';

class SmartMealsScreen extends StatelessWidget {
  final List<String> mealTypes = ["Breakfast", "Lunch", "Dinner", "Snacks"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Today’s Intelligent Meals")),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: mealTypes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text("${mealTypes[index]}: Suggested meal (placeholder)"),
              leading: Checkbox(
                value: false,
                onChanged: (val) {},
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
        tooltip: "Add Meal",
      ),
    );
  }
}
