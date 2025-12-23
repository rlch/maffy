import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/geometry_object.dart';
import '../../models/geometry_tools.dart';
import '../../providers/geometry_provider.dart';
import '../../models/graph_colors.dart';

class GeometryCanvas extends StatefulWidget {
  const GeometryCanvas({super.key});

  @override
  State<GeometryCanvas> createState() => _GeometryCanvasState();
}

class _GeometryCanvasState extends State<GeometryCanvas> {
  // Viewport state (local for now, could move to provider if needed for persistence)
  double _xMin = -10;
  double _xMax = 10;
  double _yMin = -10;
  double _yMax = 10;

  String? _draggedObjectId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        
        // Calculate scale factors
        final double scaleX = size.width / (_xMax - _xMin);
        final double scaleY = size.height / (_yMax - _yMin); // Inverted Y usually

        return Consumer<GeometryProvider>(
          builder: (context, provider, child) {
            return GestureDetector(
              onPanStart: (details) {
                final mathPos = _pixelsToMath(details.localPosition, size);
                final tappedId = _hitTest(mathPos, provider.objects, 10 / scaleX); // 10px hit radius
                
                if (tappedId != null) {
                  setState(() {
                    _draggedObjectId = tappedId;
                  });
                  provider.startDragging(tappedId);
                  provider.handleTap(mathPos, tappedObjectId: tappedId);
                } else {
                  provider.handleTap(mathPos);
                }
              },
              onPanUpdate: (details) {
                if (_draggedObjectId != null) {
                  final dx = details.delta.dx / scaleX;
                  final dy = -details.delta.dy / scaleY; // Invert dy because screen Y is down
                  provider.handleDrag(_draggedObjectId!, Offset(dx, dy));
                } else {
                  // Pan the view
                  setState(() {
                    final dx = details.delta.dx / scaleX;
                    final dy = -details.delta.dy / scaleY; // Invert dy
                    _xMin -= dx;
                    _xMax -= dx;
                    _yMin -= dy; // Panning up (negative dy) means moving view down (increasing yMin)
                    _yMax -= dy;
                  });
                }
              },
              onPanEnd: (details) {
                setState(() {
                  _draggedObjectId = null;
                });
              },
              child: CustomPaint(
                size: size,
                painter: GeometryPainter(
                  objects: provider.objects,
                  selectedIds: provider.selectedObjectIds,
                  activeTool: provider.activeTool,
                  toolStepObjectIds: provider.toolStepObjectIds,
                  xMin: _xMin,
                  xMax: _xMax,
                  yMin: _yMin,
                  yMax: _yMax,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Offset _pixelsToMath(Offset pixels, Size size) {
    final t = pixels.dx / size.width;
    final u = pixels.dy / size.height;
    
    final x = _xMin + t * (_xMax - _xMin);
    final y = _yMax - u * (_yMax - _yMin); // Flip Y
    
    return Offset(x, y);
  }

  String? _hitTest(Offset pos, Map<String, GeometryObject> objects, double threshold) {
    // Check points first (highest priority)
    for (final obj in objects.values) {
      if (obj is GeoPoint) {
        if ((pos - Offset(obj.x, obj.y)).distance < threshold) {
          return obj.id;
        }
      }
    }
    
    // Then lines/segments (simplified hit test)
    // ... implement line hit test later
    
    return null;
  }
}

class GeometryPainter extends CustomPainter {
  final Map<String, GeometryObject> objects;
  final Set<String> selectedIds;
  final GeometryToolType activeTool;
  final List<String> toolStepObjectIds;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;

  GeometryPainter({
    required this.objects,
    required this.selectedIds,
    required this.activeTool,
    required this.toolStepObjectIds,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
  });


  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / (xMax - xMin);
    final scaleY = size.height / (yMax - yMin);

    // Helper to convert math point to pixel point
    Offset toPixels(double x, double y) {
      final px = (x - xMin) * scaleX;
      final py = size.height - (y - yMin) * scaleY; // Flip Y
      return Offset(px, py);
    }

    // Draw Grid (Optional, but good for context)
    _drawGrid(canvas, size, toPixels);

    // Draw Objects
    // Order: Lines/Circles first, then Points on top
    
    // 1. Lines, Segments, Rays, Vectors, Circles
    for (final obj in objects.values) {
      if (!obj.isVisible) continue;
      
      final isSelected = selectedIds.contains(obj.id);
      final paint = Paint()
        ..color = isSelected ? GraphColors.blue : obj.color
        ..strokeWidth = isSelected ? obj.strokeWidth + 2 : obj.strokeWidth
        ..style = PaintingStyle.stroke;

      if (obj is GeoLine) {
        _drawGeoLine(canvas, obj, toPixels, paint, size);
      } else if (obj is GeoSegment) {
        _drawGeoSegment(canvas, obj, toPixels, paint);
      } else if (obj is GeoRay) {
        _drawGeoRay(canvas, obj, toPixels, paint, size);
      } else if (obj is GeoVector) {
        _drawGeoVector(canvas, obj, toPixels, paint);
      } else if (obj is GeoCircle) {
        _drawGeoCircle(canvas, obj, toPixels, paint);
      } else if (obj is GeoPolygon) {
        _drawGeoPolygon(canvas, obj, toPixels, paint);
      }
    }

    // Draw in-progress polygon
    if (activeTool == GeometryToolType.polygon && toolStepObjectIds.isNotEmpty) {
      _drawInProgressPolygon(canvas, toolStepObjectIds, toPixels);
    }

    // 2. Points
    for (final obj in objects.values) {
      if (!obj.isVisible) continue;
      if (obj is GeoPoint) {
        final isSelected = selectedIds.contains(obj.id);
        final center = toPixels(obj.x, obj.y);
        
        final paint = Paint()
          ..color = isSelected ? GraphColors.blue : obj.color
          ..style = PaintingStyle.fill;
          
        canvas.drawCircle(center, isSelected ? 6.0 : 4.0, paint);
        
        // Draw selection ring
        if (isSelected) {
          canvas.drawCircle(
            center, 
            8.0, 
            Paint()..color = GraphColors.blue.withValues(alpha: 0.3)..style = PaintingStyle.fill
          );
        }
        
        // Draw label
        final textSpan = TextSpan(
          text: obj.name,
          style: TextStyle(color: Colors.black, fontSize: 12),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, center + const Offset(5, -15));
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size, Offset Function(double, double) toPixels) {
    final paint = Paint()..color = Colors.grey.withValues(alpha: 0.2)..strokeWidth = 1;
    
    // Vertical lines
    for (double x = xMin.ceilToDouble(); x <= xMax; x += 1) {
      final p1 = toPixels(x, yMin);
      final p2 = toPixels(x, yMax);
      canvas.drawLine(p1, p2, paint);
    }
    
    // Horizontal lines
    for (double y = yMin.ceilToDouble(); y <= yMax; y += 1) {
      final p1 = toPixels(xMin, y);
      final p2 = toPixels(xMax, y);
      canvas.drawLine(p1, p2, paint);
    }
    
    // Axes
    final axisPaint = Paint()..color = Colors.black..strokeWidth = 2;
    final origin = toPixels(0, 0);
    
    // X Axis
    canvas.drawLine(Offset(0, origin.dy), Offset(size.width, origin.dy), axisPaint);
    // Y Axis
    canvas.drawLine(Offset(origin.dx, 0), Offset(origin.dx, size.height), axisPaint);
  }

  void _drawGeoLine(Canvas canvas, GeoLine line, Offset Function(double, double) toPixels, Paint paint, Size size) {
    if (line.point1Id != null && line.point2Id != null) {
      final p1Obj = objects[line.point1Id];
      final p2Obj = objects[line.point2Id];
      if (p1Obj is GeoPoint && p2Obj is GeoPoint) {
        // Calculate slope and draw infinite line
        // For now, just draw a long line through the points
        final p1 = toPixels(p1Obj.x, p1Obj.y);
        final p2 = toPixels(p2Obj.x, p2Obj.y);
        
        final dx = p2.dx - p1.dx;
        final dy = p2.dy - p1.dy;
        
        // Extrapolate
        canvas.drawLine(
          p1 - Offset(dx * 100, dy * 100),
          p2 + Offset(dx * 100, dy * 100),
          paint
        );
      }
    }
  }

  void _drawGeoSegment(Canvas canvas, GeoSegment segment, Offset Function(double, double) toPixels, Paint paint) {
    final p1Obj = objects[segment.point1Id];
    final p2Obj = objects[segment.point2Id];
    if (p1Obj is GeoPoint && p2Obj is GeoPoint) {
      canvas.drawLine(
        toPixels(p1Obj.x, p1Obj.y),
        toPixels(p2Obj.x, p2Obj.y),
        paint
      );
    }
  }

  void _drawGeoRay(Canvas canvas, GeoRay ray, Offset Function(double, double) toPixels, Paint paint, Size size) {
    final p1Obj = objects[ray.startPointId];
    final p2Obj = objects[ray.throughPointId];
    if (p1Obj is GeoPoint && p2Obj is GeoPoint) {
      final p1 = toPixels(p1Obj.x, p1Obj.y);
      final p2 = toPixels(p2Obj.x, p2Obj.y);
      
      final dx = p2.dx - p1.dx;
      final dy = p2.dy - p1.dy;
      
      canvas.drawLine(
        p1,
        p2 + Offset(dx * 100, dy * 100),
        paint
      );
    }
  }

  void _drawGeoVector(Canvas canvas, GeoVector vector, Offset Function(double, double) toPixels, Paint paint) {
    final p1Obj = objects[vector.startPointId];
    final p2Obj = objects[vector.endPointId];
    if (p1Obj is GeoPoint && p2Obj is GeoPoint) {
      final start = toPixels(p1Obj.x, p1Obj.y);
      final end = toPixels(p2Obj.x, p2Obj.y);
      canvas.drawLine(start, end, paint);
      
      // Draw arrow head
      final angle = (end - start).direction;
      final arrowSize = 10.0;
      final arrowAngle = 0.5; // radians
      
      final p3 = end - Offset.fromDirection(angle - arrowAngle, arrowSize);
      final p4 = end - Offset.fromDirection(angle + arrowAngle, arrowSize);
      
      final path = Path()..moveTo(end.dx, end.dy)..lineTo(p3.dx, p3.dy)..lineTo(p4.dx, p4.dy)..close();
      canvas.drawPath(path, paint..style = PaintingStyle.fill);
    }
  }

  void _drawGeoCircle(Canvas canvas, GeoCircle circle, Offset Function(double, double) toPixels, Paint paint) {
    final centerObj = objects[circle.centerPointId];
    if (centerObj is GeoPoint) {
      final center = toPixels(centerObj.x, centerObj.y);
      double radius = 0;
      
      if (circle.radius != null) {
        // Fixed radius (need to scale)
        final scaleX = (toPixels(1, 0) - toPixels(0, 0)).dx;
        radius = circle.radius! * scaleX;
      } else if (circle.radiusPointId != null) {
        final rObj = objects[circle.radiusPointId];
        if (rObj is GeoPoint) {
          final rPoint = toPixels(rObj.x, rObj.y);
          radius = (rPoint - center).distance;
        }
      }
      
      canvas.drawCircle(center, radius, paint);
    }
  }

  void _drawGeoPolygon(Canvas canvas, GeoPolygon polygon, Offset Function(double, double) toPixels, Paint paint) {
    if (polygon.vertexIds.length < 3) return;

    final path = Path();
    bool first = true;
    
    for (final id in polygon.vertexIds) {
      final obj = objects[id];
      if (obj is GeoPoint) {
        final p = toPixels(obj.x, obj.y);
        if (first) {
          path.moveTo(p.dx, p.dy);
          first = false;
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
    }
    path.close();

    if (polygon.isFilled && polygon.fillColor != null) {
      canvas.drawPath(
        path, 
        Paint()..color = polygon.fillColor!..style = PaintingStyle.fill
      );
    }
    
    canvas.drawPath(path, paint);
  }

  void _drawInProgressPolygon(Canvas canvas, List<String> vertexIds, Offset Function(double, double) toPixels) {
    if (vertexIds.isEmpty) return;

    final path = Path();
    bool first = true;
    
    for (final id in vertexIds) {
      final obj = objects[id];
      if (obj is GeoPoint) {
        final p = toPixels(obj.x, obj.y);
        if (first) {
          path.moveTo(p.dx, p.dy);
          first = false;
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
    }
    
    // Don't close the path yet
    
    // Draw fill preview
    if (vertexIds.length >= 3) {
      final fillPath = Path.from(path)..close();
      canvas.drawPath(
        fillPath, 
        Paint()..color = GraphColors.blue.withValues(alpha: 0.1)..style = PaintingStyle.fill
      );
    }

    // Draw lines
    canvas.drawPath(
      path, 
      Paint()..color = GraphColors.blue..strokeWidth = 2..style = PaintingStyle.stroke
    );
  }

  @override
  bool shouldRepaint(covariant GeometryPainter oldDelegate) {
    return true; // For now, always repaint. Optimize later.
  }
}
