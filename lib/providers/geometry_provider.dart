import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

import '../models/geometry_object.dart';
import '../models/geometry_tools.dart';
import '../models/graph_colors.dart';

class GeometryProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  /// All geometry objects, keyed by ID
  final Map<String, GeometryObject> _objects = {};
  Map<String, GeometryObject> get objects => Map.unmodifiable(_objects);

  /// Currently active tool
  GeometryToolType _activeTool = GeometryToolType.move;
  GeometryToolType get activeTool => _activeTool;

  /// IDs of currently selected objects
  final Set<String> _selectedObjectIds = {};
  Set<String> get selectedObjectIds => Set.unmodifiable(_selectedObjectIds);

  /// IDs of objects being used for the current tool (e.g. first point of a line)
  final List<String> _toolStepObjectIds = [];
  List<String> get toolStepObjectIds => List.unmodifiable(_toolStepObjectIds);

  /// Color index for new objects
  int _colorIndex = 0;

  // ... (Undo/Redo section skipped for brevity in replacement, assuming it's correct)

  // ... (Actions section)

  // ... (Interaction Handlers)

  // ... (Tool Logic Helpers)

  void _handlePolygonTool(Offset position, String? tappedObjectId) {
    // Step 1: Get or create the point
    String pointId;
    if (tappedObjectId != null && _objects[tappedObjectId] is GeoPoint) {
      pointId = tappedObjectId;
    } else {
      // Create a new point at this location
      final point = GeoPoint(
        id: _uuid.v4(),
        name: _generateName('P'),
        color: GraphColors.getColor(_colorIndex),
        x: position.dx,
        y: position.dy,
      );
      pointId = addObject(point);
      _colorIndex++;
    }

    // Check if we are closing the polygon (clicking the first point)
    if (_toolStepObjectIds.isNotEmpty && pointId == _toolStepObjectIds.first) {
      if (_toolStepObjectIds.length >= 3) {
        // Create polygon
        final color = GraphColors.getColor(_colorIndex++);
        final polygon = GeoPolygon(
          id: _uuid.v4(),
          name: _generateName('poly'),
          color: color,
          vertexIds: List.from(_toolStepObjectIds),
          isFilled: true,
          fillColor: color.withValues(alpha: 0.2),
        );
        addObject(polygon);
        _toolStepObjectIds.clear();
      }
      return;
    }

    // Add point to current polygon path
    // Don't add if it's the same as the last point (double click prevention)
    if (_toolStepObjectIds.isEmpty || _toolStepObjectIds.last != pointId) {
      _toolStepObjectIds.add(pointId);
      notifyListeners(); // Notify to redraw pending polygon
    }
  }



  // --- Undo/Redo ---
  final List<Map<String, GeometryObject>> _undoStack = [];
  final List<Map<String, GeometryObject>> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void _saveState() {
    _undoStack.add(Map.from(_objects));
    _redoStack.clear();
    if (_undoStack.length > 50) {
      _undoStack.removeAt(0);
    }
  }

  void undo() {
    if (!canUndo) return;
    _redoStack.add(Map.from(_objects));
    final previousState = _undoStack.removeLast();
    _objects.clear();
    _objects.addAll(previousState);
    _selectedObjectIds.clear();
    _toolStepObjectIds.clear();
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    _undoStack.add(Map.from(_objects));
    final nextState = _redoStack.removeLast();
    _objects.clear();
    _objects.addAll(nextState);
    _selectedObjectIds.clear();
    _toolStepObjectIds.clear();
    notifyListeners();
  }

  // --- Actions ---

  void setTool(GeometryToolType tool) {
    _activeTool = tool;
    _toolStepObjectIds.clear();
    _selectedObjectIds.clear();
    notifyListeners();
  }

  void selectObject(String id, {bool multiSelect = false}) {
    if (!multiSelect) {
      _selectedObjectIds.clear();
    }
    _selectedObjectIds.add(id);
    notifyListeners();
  }

  void deselectAll() {
    _selectedObjectIds.clear();
    notifyListeners();
  }

  /// Add a new object and return its ID
  String addObject(GeometryObject object) {
    _saveState();
    _objects[object.id] = object;
    notifyListeners();
    return object.id;
  }

  /// Update an object and recursively update its dependencies
  void updateObject(GeometryObject object, {bool saveHistory = true}) {
    if (saveHistory) {
      _saveState();
    }
    _objects[object.id] = object;
    _updateDependencies(object.id);
    notifyListeners();
  }

  void removeObject(String id) {
    _saveState();
    // Find all objects that depend on this one
    final dependentIds = _objects.values
        .where((obj) => obj.getDependencies().contains(id))
        .map((obj) => obj.id)
        .toList();

    // Remove them recursively
    for (final depId in dependentIds) {
      removeObject(depId);
    }

    _objects.remove(id);
    _selectedObjectIds.remove(id);
    _toolStepObjectIds.remove(id);
    notifyListeners();
  }

  // --- Interaction Handlers ---

  /// Handle a tap on the canvas at (x, y)
  /// [tappedObjectId] is the ID of an object under the tap, if any
  void handleTap(Offset position, {String? tappedObjectId}) {
    switch (_activeTool) {
      case GeometryToolType.move:
        if (tappedObjectId != null) {
          selectObject(tappedObjectId);
        } else {
          deselectAll();
        }
        break;

      case GeometryToolType.point:
        // Create a free point
        if (tappedObjectId == null) {
          _createPoint(position.dx, position.dy);
        } else {
          // If tapped on an object (like a line), create a constrained point
          // For now, just create a point at that location (ignoring constraint logic for MVP start)
          _createPoint(position.dx, position.dy);
        }
        break;

      case GeometryToolType.line:
      case GeometryToolType.segment:
      case GeometryToolType.ray:
      case GeometryToolType.vector:
        _handleTwoPointTool(position, tappedObjectId);
        break;

      case GeometryToolType.circleCenterPoint:
        _handleTwoPointTool(position, tappedObjectId);
        break;
        
      case GeometryToolType.polygon:
        _handlePolygonTool(position, tappedObjectId);
        break;

      default:
        break;
    }
  }

  /// Handle dragging an object
  void handleDrag(String objectId, Offset delta) {
    final obj = _objects[objectId];
    if (obj is GeoPoint && obj.isFree) {
      final newPoint = obj.copyWith(
        x: obj.x + delta.dx,
        y: obj.y + delta.dy,
      );
      updateObject(newPoint, saveHistory: false);
    }
  }

  void startDragging(String objectId) {
    _saveState();
  }

  // --- Tool Logic Helpers ---

  void _createPoint(double x, double y) {
    final point = GeoPoint(
      id: _uuid.v4(),
      name: _generateName('P'),
      color: GraphColors.getColor(_colorIndex),
      x: x,
      y: y,
    );
    addObject(point);
    _colorIndex++;
  }

  void _handleTwoPointTool(Offset position, String? tappedObjectId) {
    // Step 1: Get or create the first point
    String pointId;
    if (tappedObjectId != null && _objects[tappedObjectId] is GeoPoint) {
      pointId = tappedObjectId;
    } else {
      // Create a new point at this location
      final point = GeoPoint(
        id: _uuid.v4(),
        name: _generateName('P'),
        color: GraphColors.getColor(_colorIndex),
        x: position.dx,
        y: position.dy,
      );
      pointId = addObject(point);
      _colorIndex++;
    }

    _toolStepObjectIds.add(pointId);

    // Step 2: If we have 2 points, create the object
    if (_toolStepObjectIds.length == 2) {
      final p1 = _toolStepObjectIds[0];
      final p2 = _toolStepObjectIds[1];

      if (p1 == p2) {
        // Cannot use same point twice for these tools
        _toolStepObjectIds.removeLast();
        return;
      }

      _createObjectFromPoints(p1, p2);
      _toolStepObjectIds.clear();
    }
  }
  


  void _createObjectFromPoints(String p1Id, String p2Id) {
    final color = GraphColors.getColor(_colorIndex++);
    
    GeometryObject? newObj;
    
    switch (_activeTool) {
      case GeometryToolType.line:
        newObj = GeoLine(
          id: _uuid.v4(),
          name: _generateName('f'),
          color: color,
          point1Id: p1Id,
          point2Id: p2Id,
        );
        break;
      case GeometryToolType.segment:
        newObj = GeoSegment(
          id: _uuid.v4(),
          name: _generateName('s'),
          color: color,
          point1Id: p1Id,
          point2Id: p2Id,
        );
        break;
      case GeometryToolType.ray:
        newObj = GeoRay(
          id: _uuid.v4(),
          name: _generateName('r'),
          color: color,
          startPointId: p1Id,
          throughPointId: p2Id,
        );
        break;
      case GeometryToolType.vector:
        newObj = GeoVector(
          id: _uuid.v4(),
          name: _generateName('v'),
          color: color,
          startPointId: p1Id,
          endPointId: p2Id,
        );
        break;
      case GeometryToolType.circleCenterPoint:
        newObj = GeoCircle(
          id: _uuid.v4(),
          name: _generateName('c'),
          color: color,
          centerPointId: p1Id,
          radiusPointId: p2Id,
        );
        break;
      default:
        break;
    }

    if (newObj != null) {
      addObject(newObj);
    }
  }

  // --- Dependency Management ---

  void _updateDependencies(String changedObjectId) {
    // Find all objects that depend on the changed object
    final dependents = _objects.values.where((obj) {
      return obj.getDependencies().contains(changedObjectId);
    }).toList();

    for (final obj in dependents) {
      // Re-evaluate the object
      final updatedObj = _recalculateObject(obj);
      if (updatedObj != obj) {
        _objects[updatedObj.id] = updatedObj;
        // Recursively update dependents of this object
        _updateDependencies(updatedObj.id);
      }
    }
  }

  GeometryObject _recalculateObject(GeometryObject obj) {
    // For MVP, most objects don't store computed state (Lines just ref points).
    // But if we had "Midpoint", we'd calculate it here.
    // Example:
    // if (obj is GeoPoint && obj.constraintId != null) { ... }
    
    return obj;
  }

  String _generateName(String prefix) {
    // Simple auto-naming: P1, P2, etc.
    int i = 1;
    while (_objects.values.any((o) => o.name == '$prefix$i')) {
      i++;
    }
    return '$prefix$i';
  }
}
