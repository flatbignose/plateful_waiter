import 'package:flutter/material.dart';
import 'package:restro_range_waiter/const/colors.dart';
import 'package:restro_range_waiter/const/size_radius.dart';

void showSnackbar({required BuildContext context, required String content}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      content,
      style: const TextStyle(color: backgroundColor),
    ),
    showCloseIcon: true,
    dismissDirection: DismissDirection.down,
    backgroundColor: backgroundColor,
    shape: const ContinuousRectangleBorder(borderRadius: radius20),
    animation: CurvedAnimation(
        parent: kAlwaysCompleteAnimation, curve: Curves.easeInOut),
    duration: const Duration(milliseconds: 1500),
  ));
}
