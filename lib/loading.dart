import 'package:flutter/material.dart';

class ScreenLoading extends StatelessWidget {
  const ScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
