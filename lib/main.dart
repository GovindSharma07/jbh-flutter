import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jbh_academy/state/auth_notifier.dart';
import 'package:jbh_academy/theme.dart';
import 'package:jbh_academy/util.dart';

import 'app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextTheme textTheme = createTextTheme(context, "Poppins", "Poppins");
    MaterialTheme theme = MaterialTheme(textTheme);

    final authState = ref.watch(authNotifierProvider);

    String initialRoute;
    if (authState.token != null && authState.user != null) {
      initialRoute = AppRoutes.home; // Logged in
    } else {
      initialRoute = AppRoutes.login; // Not logged in
    }


    return MaterialApp(
      debugShowCheckedModeBanner: true,
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
      initialRoute: AppRoutes.splash,
      routes: appRoutes,
    );
  }
}

