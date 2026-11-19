import 'package:material_ui/material_ui.dart';

/// Widget Logo Resmi Aplikasi "Ingetin Sholat"
/// Menampilkan ikon lonceng bergetar dengan siluet orang berdoa di tengahnya.
class IngetinSholatLogo extends StatelessWidget {
  final double size;
  final bool withBorder;
  final double borderRadius;

  const IngetinSholatLogo({
    super.key,
    this.size = 32,
    this.withBorder = true,
    this.borderRadius = 9,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        'assets/icons/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFF0F5A47),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              size: size * 0.65,
              color: const Color(0xFFF3BA4F),
            ),
          );
        },
      ),
    );

    if (withBorder) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius + 1.5),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.65),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: content,
      );
    }

    return content;
  }
}
