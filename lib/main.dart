import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/editing_state.dart';
import 'providers/geometry_provider.dart';
import 'providers/graph_state.dart';
import 'screens/home_screen.dart';
import 'theme/geogebra_theme.dart';

void main() {
  runApp(const MaffyApp());
}

class MaffyApp extends StatelessWidget {
  const MaffyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GraphState()),
        ChangeNotifierProvider(create: (_) => EditingState()),
        ChangeNotifierProvider(create: (_) => GeometryProvider()),
      ],
      child: MaterialApp(
        title: 'Maffy',
        debugShowCheckedModeBanner: false,
        theme: GG.light(),
        themeMode: ThemeMode.light,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
        ],
        home: const HomeScreen(),
      ),
    );
  }
}
