import 'package:flutter/material.dart';

class ProductsSkeleton extends StatelessWidget {
  const ProductsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: .68,
      ),
      itemBuilder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 14,
                width: 90,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 6),
              Container(
                height: 14,
                width: 60,
                color: Colors.grey.shade300,
              ),
              const Spacer(),
              Container(
                height: 30,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
