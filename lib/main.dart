import 'package:flutter/material.dart';
import 'package:jbh_academy/theme.dart';
import 'package:jbh_academy/util.dart';

import 'app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Poppins", "Poppins");

    MaterialTheme theme = MaterialTheme(textTheme);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JBH Tech Academy',
      theme: theme.light().copyWith(
        // This is the new property you are adding
        pageTransitionsTheme: const PageTransitionsTheme(
          // This map defines the transition for each platform
          builders: <TargetPlatform, PageTransitionsBuilder>{
            // Use the same animation for all platforms
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: AppRoutes.login,
      routes: appRoutes,
    );
  }
}
