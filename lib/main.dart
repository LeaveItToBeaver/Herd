import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/utils/router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    // Use provider for Android
    androidProvider: AndroidProvider.debug,
    // Use provider for iOS/macOS
    appleProvider: AppleProvider.debug,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: goRouter,
      // builder: (BuildContext context, Widget? child) {
      //   return AppScaffold(child: child!);
      // },
      title: 'App with Tab Navigator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
