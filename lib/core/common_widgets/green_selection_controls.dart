import 'package:flutter/material.dart';

class GreenTextSelectionControls extends MaterialTextSelectionControls {
  static const Color _handleColor = Color(0xFF01bc41);

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) {
    final Widget handle = SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _HandlePainter(_handleColor),
      ),
    );

    switch (type) {
      case TextSelectionHandleType.left:
        return Transform.rotate(angle: 0.5 * 3.14, child: handle);
      case TextSelectionHandleType.right:
        return Transform.rotate(angle: -0.5 * 3.14, child: handle);
      case TextSelectionHandleType.collapsed:
        return handle;
    }
  }
}

class _HandlePainter extends CustomPainter {
  final Color color;
  _HandlePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const double radius = 6;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
