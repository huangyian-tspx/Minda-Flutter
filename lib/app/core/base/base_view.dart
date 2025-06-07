import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'base_controller.dart';

class BaseView<T extends BaseController> extends StatelessWidget {
  final Widget child;
  final T controller;

  const BaseView({super.key, required this.child, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Obx(() {
          if (controller.isLoading) {
            return Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
      ],
    );
  }
} 