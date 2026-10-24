import 'package:flutter/material.dart';

import 'pages/root_page.dart';
import 'services/auth.dart';
import 'services/repository.dart';
import 'services/services.dart';

class KinkerApp extends StatelessWidget {
  const KinkerApp({
    super.key,
    required this.auth,
    required this.repository,
    this.isDemo = false,
  });

  final BaseAuth auth;
  final Repository repository;
  final bool isDemo;

  @override
  Widget build(BuildContext context) {
    return Services(
      auth: auth,
      repository: repository,
      isDemo: isDemo,
      child: MaterialApp(
        title: 'Kinker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
        ),
        home: const RootPage(),
      ),
    );
  }
}
