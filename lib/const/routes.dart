// import 'package:flutter/material.dart';
// import 'package:restro_range_waiter/home_waiter.dart';
// import 'package:restro_range_waiter/launch_screen.dart';
// import 'package:restro_range_waiter/waiters.dart';
// import 'error.dart';

// Route<dynamic> generateRoute(RouteSettings settings) {
//   switch (settings.name) {
//     case LaunchScreen.routeName:
//       return MaterialPageRoute(
//         builder: (context) => const LaunchScreen(),
//       );
//     // case WaiterHome.routeName:
    
//     //   return MaterialPageRoute(
//     //     builder: (context) => const WaiterHome(),
//     //   );
//     case ScreenWaitersList.routeName:
//       final arguments = settings.arguments as Map<String, dynamic>;
//       final restroId = arguments['restroId'];
//       final restroName = arguments['restroName'];
//       return MaterialPageRoute(
//         builder: (context) => ScreenWaitersList(
//           restroId: restroId,
//           restroName: restroName,
//         ),
//       );

//     default:
//       return MaterialPageRoute(
//         builder: (context) => const Scaffold(
//           body: ErrorScreen(error: 'This page doesn\'t exist'),
//         ),
//       );
//   }
// }
