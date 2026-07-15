import 'package:flutter/material.dart';

class CaptionInputCard extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const CaptionInputCard({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<CaptionInputCard> createState() => _CaptionInputCardState();
}

class _CaptionInputCardState extends State<CaptionInputCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant CaptionInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If initialValue changes from outside (e.g. draft restored), update local text
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colors based on theme mode
    final primaryTextColor = isDark
        ? const Color(0xFFF7F7F8)
        : const Color(0xFF111216);
    final mutedTextColor = isDark
        ? const Color(0xFF6F7078)
        : const Color(0xFF92959D);
    final surfaceColor = isDark
        ? const Color(0xFF0C0C0F)
        : const Color(0xFFFFFFFF);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(top: 26, bottom: 12),
          child: Text(
            'Write a caption',
            style: TextStyle(
              color: primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // Text Field Container
        Container(
          constraints: const BoxConstraints(minHeight: 110),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Multiline TextField
              TextField(
                controller: _controller,
                maxLines: null,
                maxLength: 300,
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 16,
                  fontFamily: 'SF ProText',
                ),
                decoration: InputDecoration(
                  hintText: 'Share your thoughts...',
                  hintStyle: TextStyle(color: mutedTextColor, fontSize: 16),
                  border: InputBorder.none,
                  counterText: '', // Hide default counter
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) {
                  setState(() {});
                  widget.onChanged(val);
                },
              ),
              const SizedBox(height: 8),
              // Custom character counter bottom-right
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_controller.text.length}/300',
                  style: TextStyle(
                    color: mutedTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
