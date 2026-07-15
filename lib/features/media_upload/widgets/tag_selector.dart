import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const TagChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme colors
    final borderDefaultColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);
    final surfaceDefaultColor = isDark
        ? const Color(0xFF0C0C0F)
        : const Color(0xFFFFFFFF);
    const neonLime = Color(0xFFD2FF27);

    final backgroundColor = isSelected
        ? neonLime.withOpacity(0.15)
        : surfaceDefaultColor;

    final borderColor = isSelected ? neonLime : borderDefaultColor;

    final textColor = isSelected
        ? (isDark ? neonLime : const Color(0xFF111216))
        : (isDark ? const Color(0xFFF7F7F8) : const Color(0xFF666971));

    return Semantics(
      label:
          'Tag $label, ${isSelected ? 'selected' : 'not selected'}, double tap to toggle',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              if (!isDark && !isSelected)
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '# ',
                  style: TextStyle(
                    color: neonLime,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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

class TagSelector extends StatelessWidget {
  final List<String> selectedTags;
  final ValueChanged<List<String>> onTagsChanged;

  const TagSelector({
    super.key,
    required this.selectedTags,
    required this.onTagsChanged,
  });

  // Reference tags from the design
  static const List<String> presetTags = [
    'Adventure',
    'Music',
    'Fitness',
    'Travel',
  ];

  // Additional tags for the "More" bottom sheet
  static const List<String> additionalTags = [
    'Art',
    'Cooking',
    'Fashion',
    'Photography',
    'Gaming',
    'Tech',
    'Sports',
    'Nature',
    'Comedy',
    'Design',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? const Color(0xFFF7F7F8)
        : const Color(0xFF111216);
    final mutedTextColor = isDark
        ? const Color(0xFF6F7078)
        : const Color(0xFF92959D);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: "Add Tags" and "Optional"
        Padding(
          padding: const EdgeInsets.only(top: 26, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Tags',
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Optional',
                style: TextStyle(
                  color: mutedTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        // Horizontal Tag Chips Row
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              // Display preset tags
              ...presetTags.map((tag) {
                final isSelected = selectedTags.contains(tag);
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TagChip(
                    label: tag,
                    isSelected: isSelected,
                    onTap: () => _toggleTag(tag),
                  ),
                );
              }),

              // Display any custom selected tags that are not presets
              ...selectedTags.where((tag) => !presetTags.contains(tag)).map((
                tag,
              ) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TagChip(
                    label: tag,
                    isSelected: true,
                    onTap: () => _toggleTag(tag),
                  ),
                );
              }),

              // "# More" Chip
              TagChip(
                label: 'More',
                isSelected: false,
                onTap: () => _showMoreTagsSheet(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleTag(String tag) {
    final newTags = List<String>.from(selectedTags);
    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      newTags.add(tag);
    }
    onTagsChanged(newTags);
  }

  void _showMoreTagsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? const Color(0xFFF7F7F8)
        : const Color(0xFF111216);
    final surfaceColor = isDark
        ? const Color(0xFF0C0C0F)
        : const Color(0xFFFFFFFF);
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Explore Tags',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: [
                      ...presetTags.map((tag) {
                        final isSel = selectedTags.contains(tag);
                        return TagChip(
                          label: tag,
                          isSelected: isSel,
                          onTap: () {
                            _toggleTag(tag);
                            setModalState(() {});
                          },
                        );
                      }),
                      ...additionalTags.map((tag) {
                        final isSel = selectedTags.contains(tag);
                        return TagChip(
                          label: tag,
                          isSelected: isSel,
                          onTap: () {
                            _toggleTag(tag);
                            setModalState(() {});
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFD2FF27),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
