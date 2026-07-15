import 'package:flutter/material.dart';

class StoryShareButton extends StatelessWidget {
  final String text;
  final bool isEnabled;
  final bool isLoading;
  final double progress;
  final VoidCallback? onPressed;

  const StoryShareButton({
    super.key,
    required this.text,
    this.isEnabled = true,
    this.isLoading = false,
    this.progress = 0.0,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final activeGradient = const LinearGradient(
      colors: [Color(0xFFD1FF2F), Color(0xFFE0FF49)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final disabledColor = Colors.white.withOpacity(0.08);
    final isInteractive = isEnabled && !isLoading;

    return Semantics(
      button: true,
      enabled: isInteractive,
      label: text,
      child: GestureDetector(
        onTap: isInteractive ? onPressed : null,
        child: Container(
          width: double.infinity,
          height: 64,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: isInteractive ? activeGradient : null,
            color: isInteractive ? null : disabledColor,
            boxShadow: isInteractive
                ? [
                    BoxShadow(
                      color: const Color(0xFFD1FF2F).withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // For upload progress backing
              if (isLoading)
                Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: MediaQuery.of(context).size.width * progress,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 44), // balance right button
                    Expanded(
                      child: Center(
                        child: Text(
                          isLoading
                              ? 'Uploading ${(progress * 100).toInt()}%'
                              : text,
                          style: TextStyle(
                            color: isInteractive
                                ? const Color(0xFF050506)
                                : Colors.white.withOpacity(0.3),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF050506),
                        shape: BoxShape.circle,
                      ),
                      child: isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 3,
                                valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFFD1FF2F),
                                ),
                                backgroundColor: Colors.white.withOpacity(0.1),
                              ),
                            )
                          : Icon(
                              Icons.arrow_upward_rounded,
                              color: isInteractive
                                  ? const Color(0xFFD1FF2F)
                                  : Colors.white.withOpacity(0.3),
                              size: 20,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
