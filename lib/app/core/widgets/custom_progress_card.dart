import 'package:flutter/material.dart';

class CustomProgressCard extends StatelessWidget {
  final double progressValue;
  const CustomProgressCard({Key? key, required this.progressValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progressValue,
            strokeWidth: 4,
            backgroundColor: Colors.green.shade100,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          Center(
            child: Text(
              "${(progressValue * 100).toInt()}%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 