enum GeometryToolType {
  move,
  point,
  line,
  segment,
  ray,
  vector,
  circleCenterRadius,
  circleCenterPoint,
  polygon,
  regularPolygon,
  perpendicularLine,
  parallelLine,
  midpoint,
  angle,
  distance,
}

class GeometryTool {
  final GeometryToolType type;
  final String name;
  final String iconName; // We'll use CupertinoIcons, so this might be a mapping key

  const GeometryTool({
    required this.type,
    required this.name,
    required this.iconName,
  });

  static const List<GeometryTool> allTools = [
    GeometryTool(type: GeometryToolType.move, name: 'Move', iconName: 'move'),
    GeometryTool(type: GeometryToolType.point, name: 'Point', iconName: 'point'),
    GeometryTool(type: GeometryToolType.line, name: 'Line', iconName: 'line'),
    GeometryTool(type: GeometryToolType.segment, name: 'Segment', iconName: 'segment'),
    GeometryTool(type: GeometryToolType.ray, name: 'Ray', iconName: 'ray'),
    GeometryTool(type: GeometryToolType.vector, name: 'Vector', iconName: 'vector'),
    GeometryTool(type: GeometryToolType.circleCenterPoint, name: 'Circle (Center & Point)', iconName: 'circle'),
    GeometryTool(type: GeometryToolType.polygon, name: 'Polygon', iconName: 'polygon'),
    GeometryTool(type: GeometryToolType.angle, name: 'Angle', iconName: 'angle'),
    GeometryTool(type: GeometryToolType.distance, name: 'Distance', iconName: 'ruler'),
  ];
}
