import 'package:flutter/material.dart';

class CategoriesSkeleton extends StatelessWidget {
  const CategoriesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(right: 8),
          width: 80,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
