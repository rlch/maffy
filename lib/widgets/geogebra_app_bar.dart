import 'package:flutter/material.dart';

import '../theme/geogebra_theme.dart';

/// Top app bar styled after the GeoGebra web header.
///
/// Structure left-to-right:
///  * Hamburger / menu icon to open the app-switcher drawer.
///  * The GeoGebra-like wordmark + sub-title ("Graphing Calculator", etc.).
///  * Optional trailing actions supplied by the caller.
///
/// The bar keeps a 56 dp height like the real web app and uses a
/// 1 dp bottom border instead of a Material shadow for a flat look.
class GeoGebraAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String subtitle;
  final List<Widget> actions;
  final VoidCallback? onMenuTap;
  final bool showLogo;
  final Widget? leading;

  const GeoGebraAppBar({
    super.key,
    required this.subtitle,
    this.actions = const [],
    this.onMenuTap,
    this.showLogo = true,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: GG.panelDivider)),
      ),
      child: Row(
        children: [
          leading ??
              IconButton(
                icon: const Icon(Icons.menu, color: GG.textPrimary),
                tooltip: 'Menu',
                onPressed: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
              ),
          if (showLogo) ...[
            const SizedBox(width: 4),
            _GeoGebraLogo(),
            const SizedBox(width: 10),
            Container(width: 1, height: 22, color: GG.panelDivider),
            const SizedBox(width: 10),
            Text(
              subtitle,
              style: const TextStyle(
                color: GG.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
          ] else
            Text(
              subtitle,
              style: const TextStyle(
                color: GG.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          const Spacer(),
          ...actions,
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

/// Tiny wordmark widget that draws a rounded-square glyph followed by
/// the word "GeoGebra-like". Uses pure Flutter (no asset).
class _GeoGebraLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: GG.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Text(
            'M',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Maffy',
          style: TextStyle(
            color: GG.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

/// Small rounded "pill" button used for header actions such as Share,
/// Sign-in, or Help on the GeoGebra site.
class GeoGebraHeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool primary;

  const GeoGebraHeaderAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = primary ? GG.primary : Colors.transparent;
    final fg = primary ? Colors.white : GG.textPrimary;
    final shape = primary
        ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
        : RoundedRectangleBorder(
            side: const BorderSide(color: GG.panelDivider),
            borderRadius: BorderRadius.circular(18),
          );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Material(
        color: bg,
        shape: shape,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
