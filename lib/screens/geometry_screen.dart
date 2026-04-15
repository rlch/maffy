import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/geometry_provider.dart';
import '../widgets/geometry/algebra_panel.dart';
import '../widgets/geometry/geometry_canvas.dart';
import '../widgets/geometry/geometry_toolbar.dart';

class GeometryScreen extends StatelessWidget {
  const GeometryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Geometry'),
        ),
        body: Column(
          children: [
            const GeometryToolbar(),
            Expanded(
              child: Row(
                children: [
                  const AlgebraPanel(),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: const GeometryCanvas(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
