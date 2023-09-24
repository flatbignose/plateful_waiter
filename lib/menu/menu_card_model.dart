import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  const MenuCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Container(
          height: size.height /4,
          width: size.width /8,
          decoration: const BoxDecoration(
            
          ),
        ),
      ),
    );
  }
}