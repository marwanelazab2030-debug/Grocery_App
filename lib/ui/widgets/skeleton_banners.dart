import 'package:flutter/material.dart';

class BannersSkeleton extends StatelessWidget {
  const BannersSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          width: 320,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}
