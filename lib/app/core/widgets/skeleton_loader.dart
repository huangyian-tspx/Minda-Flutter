import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonProjectCard extends StatelessWidget {
  const SkeletonProjectCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 20, width: 120, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Container(height: 16, width: double.infinity, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Container(height: 16, width: 200, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(height: 32, width: 32, decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Container(height: 16, width: 80, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
