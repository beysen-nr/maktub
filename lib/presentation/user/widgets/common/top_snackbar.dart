import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maktub/core/constants/constants.dart';

void showTopSnackbar({
  required BuildContext context,
  required TickerProvider vsync,
  required String message,
  required bool isError,
  required bool withLove,
}) {
  if (!context.mounted) return;
  
  final overlay = Overlay.of(context, rootOverlay: true);

  final animationController = AnimationController(
    vsync: vsync,
    duration: const Duration(milliseconds: 200),
  );

  final animation = Tween<Offset>(
    begin: const Offset(0, -2.0),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(parent: animationController, curve: Curves.easeOut),
  );

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: animation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.withOpacity(0.25),
                    Colors.grey.withOpacity(0.25),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 70,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isError ? Icons.error : Icons.done,
                    color: isError ? Colors.redAccent : Gradients.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: GoogleFonts.montserrat(
                        color: isError ? Colors.redAccent : Gradients.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  if (withLove)
                    Image.asset(
                      'assets/icons/heart.png',
                      width: 25,
                      height: 25,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);

  animationController.forward().then((_) {
    Future.delayed(const Duration(seconds: 3)).then((_) async {
      if (animationController.status == AnimationStatus.forward ||
          animationController.status == AnimationStatus.completed) {
        await animationController.reverse();
      }

      if (entry.mounted) {
        entry.remove();
      }

      animationController.dispose();
    });
  });
}
