import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/character_provider.dart';
import 'router/app_router.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const SearUmaApp());
}

class SearUmaApp extends StatelessWidget {
  const SearUmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CharacterProvider(),
      child: MaterialApp.router(
        title: 'SearUma',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: AppColors.forestGreen,
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}