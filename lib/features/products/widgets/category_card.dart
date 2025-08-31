import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final dynamic category; // Placeholder for now

  const CategoryCard({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category,
              size: 32,
              color: Colors.green,
            ),
            SizedBox(height: 8),
            Text(
              'Category',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
