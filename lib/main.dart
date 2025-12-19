import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/editing_state.dart';
import 'providers/graph_state.dart';
import 'screens/home_screen.dart';

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
      ],
      child: MaterialApp(
        title: 'Maffy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          sliderTheme: SliderThemeData(
            activeTrackColor: Colors.blue,
            thumbColor: Colors.blue,
            inactiveTrackColor: Colors.grey.shade300,
            overlayColor: Colors.blue.withValues(alpha: 0.2),
          ),
        ),
        // Required for math_keyboard locale support
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
