import 'dart:ui';
import 'package:equatable/equatable.dart';

/// Base class for all geometric objects
abstract class GeometryObject extends Equatable {
  final String id;
  final String name;
  final Color color;
  final bool isVisible;
  final bool isLocked;
  final double strokeWidth;

  const GeometryObject({
    required this.id,
    required this.name,
    required this.color,
    this.isVisible = true,
    this.isLocked = false,
    this.strokeWidth = 2.0,
  });

  GeometryObject copyWith({
    String? name,
    Color? color,
    bool? isVisible,
    bool? isLocked,
    double? strokeWidth,
  });

  /// Get all dependent objects (objects that rely on this one)
  List<String> getDependencies();

  @override
  List<Object?> get props => [id, name, color, isVisible, isLocked, strokeWidth];
}

/// Point in 2D space
class GeoPoint extends GeometryObject {
  final double x;
  final double y;
  final bool isFree; // Can be dragged
  final String? constraintId; // ID of object this point is constrained to

  const GeoPoint({
    required super.id,
    required super.name,
    required super.color,
    required this.x,
    required this.y,
    this.isFree = true,
    this.constraintId,
    super.isVisible,
    super.isLocked,
    super.strokeWidth,
  });

  @override
  GeoPoint copyWith({
    String? name,
    Color? color,
    double? x,
    double? y,
    bool? isFree,
    String? constraintId,
    bool? isVisible,
    bool? isLocked,
    double? strokeWidth,
  }) {
    return GeoPoint(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      x: x ?? this.x,
      y: y ?? this.y,
      isFree: isFree ?? this.isFree,
      constraintId: constraintId ?? this.constraintId,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  @override
  List<String> getDependencies() => constraintId != null ? [constraintId!] : [];

  @override
  List<Object?> get props => [...super.props, x, y, isFree, constraintId];
}

/// Line defined by two points or equation
class GeoLine extends GeometryObject {
  final String? point1Id;
  final String? point2Id;
  final double? slope; // For lines defined by slope
  final double? yIntercept;

  const GeoLine({
    required super.id,
    required super.name,
    required super.color,
    this.point1Id,
    this.point2Id,
    this.slope,
    this.yIntercept,
    super.isVisible,
    super.isLocked,
    super.strokeWidth,
  });

  bool get isDefinedByPoints => point1Id != null && point2Id != null;

  @override
  GeoLine copyWith({
    String? name,
    Color? color,
    String? point1Id,
    String? point2Id,
    double? slope,
    double? yIntercept,
    bool? isVisible,
    bool? isLocked,
    double? strokeWidth,
  }) {
    return GeoLine(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      point1Id: point1Id ?? this.point1Id,
      point2Id: point2Id ?? this.point2Id,
      slope: slope ?? this.slope,
      yIntercept: yIntercept ?? this.yIntercept,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  @override
  List<String> getDependencies() {
    final deps = <String>[];
    if (point1Id != null) deps.add(point1Id!);
    if (point2Id != null) deps.add(point2Id!);
    return deps;
  }

  @override
  List<Object?> get props => [...super.props, point1Id, point2Id, slope, yIntercept];
}

/// Line segment with fixed endpoints
class GeoSegment extends GeometryObject {
  final String point1Id;
  final String point2Id;

  const GeoSegment({
    required super.id,
    required super.name,
    required super.color,
    required this.point1Id,
    required this.point2Id,
    super.isVisible,
    super.isLocked,
    super.strokeWidth,
  });

  @override
  GeoSegment copyWith({
    String? name,
    Color? color,
    bool? isVisible,
    bool? isLocked,
    double? strokeWidth,
  }) {
    return GeoSegment(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      point1Id: point1Id,
      point2Id: point2Id,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  @override
  List<String> getDependencies() => [point1Id, point2Id];

  @override
  List<Object?> get props => [...super.props, point1Id, point2Id];
}

/// Ray starting at a point
class GeoRay extends GeometryObject {
  final String startPointId;
  final String throughPointId;

  const GeoRay({
    required super.id,
    required super.name,
    required super.color,
    required this.startPointId,
    required this.throughPointId,
    super.isVisible,
    super.isLocked,
    super.strokeWidth,
  });

  @override
  GeoRay copyWith({
    String? name,
    Color? color,
    bool? isVisible,
    bool? isLocked,
    double? strokeWidth,
  }) {
    return GeoRay(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      startPointId: startPointId,
      throughPointId: throughPointId,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  @override
  List<String> getDependencies() => [startPointId, throughPointId];

  @override
  List<Object?> get props => [...super.props, startPointId, throughPointId];
}

/// Vector defined by start and end points
class GeoVector extends GeometryObject {
  final String startPointId;
  final String endPointId;

  const GeoVector({
    required super.id,
    required super.name,
    required super.color,
    required this.startPointId,
    required this.endPointId,
    super.isVisible,
    super.isLocked,
    super.strokeWidth,
  });

  @override
  GeoVector copyWith({
    String? name,
    Color? color,
    bool? isVisible,
    bool? isLocked,
    double? strokeWidth,
  }) {
    return GeoVector(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      startPointId: startPointId,
      endPointId: endPointId,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  @override
  List<String> getDependencies() => [startPointId, endPointId];

  @override
  List<Object?> get props => [...super.props, startPointId, endPointId];
}

/// Circle defined by center and radius or center and point
class GeoCircle extends GeometryObject {
  final String centerPointId;
  final double? radius;
  final String? radiusPointId; // Point on the circle

  const GeoCircle({
    required super.id,
    required super.name,
    required super.color,
    required this.centerPointId,
    this.radius,
    this.radiusPointId,
    super.isVisible,
    super.isLocked,
    super.strokeWidth,
  });

  @override
  GeoCircle copyWith({
    String? name,
    Color? color,
    double? radius,
    String? radiusPointId,
    bool? isVisible,
    bool? isLocked,
    double? strokeWidth,
  }) {
    return GeoCircle(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      centerPointId: centerPointId,
      radius: radius ?? this.radius,
      radiusPointId: radiusPointId ?? this.radiusPointId,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  @override
  List<String> getDependencies() {
    final deps = [centerPointId];
    if (radiusPointId != null) deps.add(radiusPointId!);
    return deps;
  }

  @override
  List<Object?> get props => [...super.props, centerPointId, radius, radiusPointId];
}

/// Polygon defined by vertices
class GeoPolygon extends GeometryObject {
  final List<String> vertexIds;
  final bool isFilled;
  final Color? fillColor;

  const GeoPolygon({
    required super.id,
    required super.name,
    required super.color,
    required this.vertexIds,
    this.isFilled = false,
    this.fillColor,
    super.isVisible,
    super.isLocked,
    super.strokeWidth,
  });

  @override
  GeoPolygon copyWith({
    String? name,
    Color? color,
    List<String>? vertexIds,
    bool? isFilled,
    Color? fillColor,
    bool? isVisible,
    bool? isLocked,
    double? strokeWidth,
  }) {
    return GeoPolygon(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      vertexIds: vertexIds ?? this.vertexIds,
      isFilled: isFilled ?? this.isFilled,
      fillColor: fillColor ?? this.fillColor,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  @override
  List<String> getDependencies() => vertexIds;

  @override
  List<Object?> get props => [...super.props, vertexIds, isFilled, fillColor];
}

/// Angle measurement
class GeoAngle extends GeometryObject {
  final String vertexId;
  final String point1Id;
  final String point2Id;
  final bool showLabel;

  const GeoAngle({
    required super.id,
    required super.name,
    required super.color,
    required this.vertexId,
    required this.point1Id,
    required this.point2Id,
    this.showLabel = true,
    super.isVisible,
    super.isLocked,
    super.strokeWidth,
  });

  @override
  GeoAngle copyWith({
    String? name,
    Color? color,
    bool? showLabel,
    bool? isVisible,
    bool? isLocked,
    double? strokeWidth,
  }) {
    return GeoAngle(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      vertexId: vertexId,
      point1Id: point1Id,
      point2Id: point2Id,
      showLabel: showLabel ?? this.showLabel,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  @override
  List<String> getDependencies() => [vertexId, point1Id, point2Id];

  @override
  List<Object?> get props => [...super.props, vertexId, point1Id, point2Id, showLabel];
}

/// Distance measurement between two points
class GeoDistance extends GeometryObject {
  final String point1Id;
  final String point2Id;
  final bool showLabel;

  const GeoDistance({
    required super.id,
    required super.name,
    required super.color,
    required this.point1Id,
    required this.point2Id,
    this.showLabel = true,
    super.isVisible,
    super.isLocked,
    super.strokeWidth,
  });

  @override
  GeoDistance copyWith({
    String? name,
    Color? color,
    bool? showLabel,
    bool? isVisible,
    bool? isLocked,
    double? strokeWidth,
  }) {
    return GeoDistance(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      point1Id: point1Id,
      point2Id: point2Id,
      showLabel: showLabel ?? this.showLabel,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  @override
  List<String> getDependencies() => [point1Id, point2Id];

  @override
  List<Object?> get props => [...super.props, point1Id, point2Id, showLabel];
}
