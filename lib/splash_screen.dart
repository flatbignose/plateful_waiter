import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:restro_range_waiter/const/colors.dart';
import 'package:restro_range_waiter/home_waiter.dart';
import 'package:restro_range_waiter/launch_screen.dart';
import 'package:restro_range_waiter/models/waiter_model.dart';
import 'package:restro_range_waiter/repository/repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    isLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Lottie.asset('asset/lottie/splash.json'),
            Text(
              "RestroRange Waiters",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: primColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  isLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      String? restroId = prefs.getString('restroId');
      final snapshot = await ref
          .read(repoProvider)
          .getwaiter(restroId: restroId!, waiterId: userId);
      final data = snapshot.data() as Map<String, dynamic>;
      final waiter = WaiterModel.fromMap(data);
      await Future.delayed(Duration(seconds: 3)).then(
          (value) => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (context) {
                  return WaiterHome(
                    waiter: waiter,
                  );
                },
              ), (route) => false));
    } else {
      await Future.delayed(Duration(seconds: 3)).then(
          (value) => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (context) {
                  return LaunchScreen();
                },
              ), (route) => false));
    }
  }
}
