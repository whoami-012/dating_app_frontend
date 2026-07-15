import 'package:flutter/material.dart';

class UploadPrimaryButton extends StatefulWidget {
  final bool isLoading;
  final double progress; // 0.0 to 1.0
  final bool isEnabled;
  final VoidCallback onPressed;

  const UploadPrimaryButton({
    super.key,
    required this.isLoading,
    required this.progress,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  State<UploadPrimaryButton> createState() => _UploadPrimaryButtonState();
}

class _UploadPrimaryButtonState extends State<UploadPrimaryButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  late AnimationController _arrowController;
  late Animation<double> _arrowTranslation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _arrowTranslation = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  void _handleTapDown() {
    if (!widget.isEnabled || widget.isLoading) return;
    _pressController.forward();
    _arrowController.forward();
  }

  void _handleTapUp() {
    if (!widget.isEnabled || widget.isLoading) return;
    _pressController.reverse();
    _arrowController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme Colors
    final disabledBg = isDark
        ? Colors.white.withOpacity(0.25)
        : Colors.black.withOpacity(0.12);
    final disabledText = isDark
        ? Colors.white.withOpacity(0.35)
        : Colors.black.withOpacity(0.35);

    // Gradient components for neon-lime background
    const gradientColors = [
      Color(0xFFD9FF2C),
      Color(0xFFCFFF2F),
      Color(0xFFC4FF30),
    ];

    final buttonText = widget.isLoading
        ? 'Uploading ${(widget.progress * 100).toInt()}%'
        : 'Upload';

    return MouseRegion(
      cursor: widget.isEnabled && !widget.isLoading
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: (_) => _handleTapDown(),
        onTapUp: (_) => _handleTapUp(),
        onTapCancel: () => _handleTapUp(),
        onTap: widget.isEnabled && !widget.isLoading ? widget.onPressed : null,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            height: 68,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: widget.isEnabled && !widget.isLoading
                  ? const LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: widget.isEnabled && !widget.isLoading ? null : disabledBg,
              boxShadow: [
                if (widget.isEnabled && !widget.isLoading && isDark)
                  BoxShadow(
                    color: const Color(0xFFD2FF27).withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Text centered
                Text(
                  buttonText,
                  style: TextStyle(
                    color: widget.isEnabled && !widget.isLoading
                        ? const Color(0xFF0C0C0F)
                        : disabledText,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                // Trailing Arrow Circle inside right side
                Positioned(
                  right: 8,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: widget.isEnabled ? 1.0 : 0.5,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0C0C0F),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _arrowTranslation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _arrowTranslation.value),
                              child: child,
                            );
                          },
                          child: const Icon(
                            Icons.arrow_upward, // Upward arrow
                            color: Color(0xFFD2FF27),
                            size: 28,
                          ),
                        ),
                      ),
                    ),
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
