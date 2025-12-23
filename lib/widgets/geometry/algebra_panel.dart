import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/geometry_object.dart';
import '../../providers/geometry_provider.dart';

class AlgebraPanel extends StatelessWidget {
  const AlgebraPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                const Text(
                  'Algebra',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(CupertinoIcons.trash, size: 18),
                  onPressed: () {
                    // Clear all (not implemented in provider yet, but good to have)
                  },
                  tooltip: 'Clear All',
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<GeometryProvider>(
              builder: (context, provider, child) {
                final objects = provider.objects.values.toList();
                
                if (objects.isEmpty) {
                  return const Center(
                    child: Text(
                      'No objects',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: objects.length,
                  itemBuilder: (context, index) {
                    final obj = objects[index];
                    final isSelected = provider.selectedObjectIds.contains(obj.id);

                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: Colors.blue.withValues(alpha: 0.1),
                      leading: GestureDetector(
                        onTap: () {
                          // Toggle visibility
                          provider.updateObject(obj.copyWith(isVisible: !obj.isVisible));
                        },
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: obj.isVisible ? obj.color : Colors.transparent,
                            border: Border.all(
                              color: obj.isVisible ? obj.color : Colors.grey,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        _getObjectDescription(obj),
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: IconButton(
                        icon: const Icon(CupertinoIcons.xmark, size: 14),
                        onPressed: () => provider.removeObject(obj.id),
                      ),
                      onTap: () => provider.selectObject(obj.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getObjectDescription(GeometryObject obj) {
    if (obj is GeoPoint) {
      return '${obj.name} = (${obj.x.toStringAsFixed(2)}, ${obj.y.toStringAsFixed(2)})';
    } else if (obj is GeoLine) {
      return '${obj.name}: Line';
    } else if (obj is GeoSegment) {
      return '${obj.name}: Segment';
    } else if (obj is GeoCircle) {
      return '${obj.name}: Circle';
    }
    return obj.name;
  }
}
