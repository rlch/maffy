import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/geometry_object.dart';
import '../../providers/geometry_provider.dart';
import '../../theme/geogebra_theme.dart';

/// Left algebra column on the Geometry screen, styled like GeoGebra's.
///
/// Header shows "Algebra" with an overflow menu.  Below, each object
/// is listed as a row with a colored dot that toggles visibility, the
/// derived description (e.g. `A = (1.00, 2.00)`), and an "x" to
/// delete.  Empty state suggests the user click a tool to get
/// started.
class AlgebraPanel extends StatelessWidget {
  const AlgebraPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: GG.panelDivider)),
      ),
      child: Column(
        children: [
          const _Header(),
          const Divider(height: 1),
          Expanded(
            child: Consumer<GeometryProvider>(
              builder: (context, provider, _) {
                final objects = provider.objects.values.toList();
                if (objects.isEmpty) return const _EmptyAlgebra();
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: objects.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 44,
                    color: GG.panelDivider,
                  ),
                  itemBuilder: (context, index) {
                    final obj = objects[index];
                    final selected =
                        provider.selectedObjectIds.contains(obj.id);
                    return _ObjectTile(
                      obj: obj,
                      selected: selected,
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
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Text(
              'Algebra',
              style: TextStyle(
                color: GG.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            const Spacer(),
            IconButton(
              splashRadius: 18,
              tooltip: 'Options',
              iconSize: 18,
              icon: const Icon(CupertinoIcons.ellipsis_vertical,
                  color: GG.textSecondary),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAlgebra extends StatelessWidget {
  const _EmptyAlgebra();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: GG.primaryTint,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Icon(
                CupertinoIcons.square_grid_2x2,
                color: GG.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nothing here yet',
              style: TextStyle(
                color: GG.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              'Pick a tool above to start constructing.',
              style: TextStyle(
                color: GG.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectTile extends StatefulWidget {
  final GeometryObject obj;
  final bool selected;

  const _ObjectTile({required this.obj, required this.selected});

  @override
  State<_ObjectTile> createState() => _ObjectTileState();
}

class _ObjectTileState extends State<_ObjectTile> {
  bool _hover = false;

  String _describe(GeometryObject obj) {
    if (obj is GeoPoint) {
      return '${obj.name} = (${obj.x.toStringAsFixed(2)}, ${obj.y.toStringAsFixed(2)})';
    }
    if (obj is GeoLine) return '${obj.name}: Line';
    if (obj is GeoSegment) return '${obj.name}: Segment';
    if (obj is GeoCircle) return '${obj.name}: Circle';
    return obj.name;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GeometryProvider>();
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: () => provider.selectObject(widget.obj.id),
        child: Container(
          color: widget.selected
              ? GG.primaryTint
              : (_hover ? GG.subtle : Colors.transparent),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => provider.updateObject(
                  widget.obj.copyWith(isVisible: !widget.obj.isVisible),
                ),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.obj.isVisible
                        ? widget.obj.color
                        : Colors.transparent,
                    border: Border.all(
                      color: widget.obj.isVisible
                          ? widget.obj.color
                          : GG.textHint,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _describe(widget.obj),
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.selected
                        ? GG.primary
                        : GG.textPrimary,
                    fontWeight: widget.selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                width: 28,
                child: _hover
                    ? IconButton(
                        splashRadius: 14,
                        iconSize: 16,
                        padding: EdgeInsets.zero,
                        icon: const Icon(CupertinoIcons.xmark,
                            color: GG.textHint),
                        onPressed: () =>
                            provider.removeObject(widget.obj.id),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
