import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/signup_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class DateOfBirthSelector extends ConsumerWidget {
  const DateOfBirthSelector({super.key});

  // Open custom bottom sheet for picking a value
  void _showPicker({
    required BuildContext context,
    required String title,
    required List<int> values,
    required int? currentValue,
    required String Function(int) formatDisplay,
    required ValueChanged<int> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: true,
      builder: (context) {
        final double sheetHeight = MediaQuery.sizeOf(context).height * 0.45;

        return Container(
          height: sheetHeight,
          decoration: BoxDecoration(
            color: AppColors.authSurface.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: AppColors.authBorderDark, width: 1),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: SafeArea(
                child: Column(
                  children: [
                    // Handle/Bar
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),

                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'SF ProText',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 1),

                    // List
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: values.length,
                        itemBuilder: (context, index) {
                          final val = values[index];
                          final isSelected = val == currentValue;
                          return InkWell(
                            onTap: () {
                              onSelected(val);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              alignment: Alignment.center,
                              color: isSelected
                                  ? AppColors.authNeonLime.withOpacity(0.08)
                                  : Colors.transparent,
                              child: Text(
                                formatDisplay(val),
                                style: TextStyle(
                                  fontFamily: 'SF ProText',
                                  fontSize: 18,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppColors.authNeonLime
                                      : Colors.white70,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signupProvider);
    final notifier = ref.read(signupProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color labelColor = isDark
        ? AppColors.authMutedTextDark
        : AppColors.lightMutedText;
    final Color glassBg = isDark
        ? AppColors.authSurfaceGlassDark
        : AppColors.authSurfaceGlassLight;
    final Color borderColor = state.dobError != null
        ? AppColors.authError
        : (isDark ? AppColors.authBorderDark : AppColors.authBorderLight);

    final currentYear = DateTime.now().year;

    // Months formatted nicely
    final List<String> monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 6, top: 12, bottom: 8),
          child: Text(
            'Date of Birth',
            style: TextStyle(
              fontFamily: 'SF ProText',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: labelColor,
            ),
          ),
        ),

        // Selectors Row
        LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth =
                constraints.maxWidth - 16; // Adjusting for two 8px gaps
            final dayWidth = totalWidth * 0.35;
            final monthWidth = totalWidth * 0.27;
            final yearWidth = totalWidth * 0.38;

            return Row(
              children: [
                // Day Selector (35%)
                SizedBox(
                  width: dayWidth,
                  height: 62,
                  child: _buildSelectorCard(
                    context: context,
                    hasIcon: true,
                    valueText: state.dobDay != null
                        ? state.dobDay!.toString().padLeft(2, '0')
                        : 'DD',
                    isEmpty: state.dobDay == null,
                    isDark: isDark,
                    glassBg: glassBg,
                    borderColor: borderColor,
                    onTap: () {
                      _showPicker(
                        context: context,
                        title: 'Select Day',
                        values: List.generate(31, (i) => i + 1),
                        currentValue: state.dobDay,
                        formatDisplay: (v) => v.toString().padLeft(2, '0'),
                        onSelected: (v) =>
                            notifier.setDob(v, state.dobMonth, state.dobYear),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Month Selector (27%)
                SizedBox(
                  width: monthWidth,
                  height: 62,
                  child: _buildSelectorCard(
                    context: context,
                    hasIcon: false,
                    valueText: state.dobMonth != null
                        ? monthNames[state.dobMonth! - 1]
                        : 'MM',
                    isEmpty: state.dobMonth == null,
                    isDark: isDark,
                    glassBg: glassBg,
                    borderColor: borderColor,
                    onTap: () {
                      _showPicker(
                        context: context,
                        title: 'Select Month',
                        values: List.generate(12, (i) => i + 1),
                        currentValue: state.dobMonth,
                        formatDisplay: (v) => '$v (${monthNames[v - 1]})',
                        onSelected: (v) =>
                            notifier.setDob(state.dobDay, v, state.dobYear),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Year Selector (38%)
                SizedBox(
                  width: yearWidth,
                  height: 62,
                  child: _buildSelectorCard(
                    context: context,
                    hasIcon: false,
                    valueText: state.dobYear != null
                        ? state.dobYear!.toString()
                        : 'YYYY',
                    isEmpty: state.dobYear == null,
                    isDark: isDark,
                    glassBg: glassBg,
                    borderColor: borderColor,
                    onTap: () {
                      _showPicker(
                        context: context,
                        title: 'Select Year',
                        values: List.generate(100, (i) => currentYear - i),
                        currentValue: state.dobYear,
                        formatDisplay: (v) => v.toString(),
                        onSelected: (v) =>
                            notifier.setDob(state.dobDay, state.dobMonth, v),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),

        // Error message space
        if (state.dobError != null)
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 6),
            child: Text(
              state.dobError!,
              style: const TextStyle(
                color: AppColors.authError,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectorCard({
    required BuildContext context,
    required bool hasIcon,
    required String valueText,
    required bool isEmpty,
    required bool isDark,
    required Color glassBg,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    final textStyle = TextStyle(
      fontFamily: 'SF ProText',
      fontSize: 17,
      fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w600,
      color: isEmpty
          ? (isDark ? AppColors.authMutedTextDark : AppColors.lightMutedText)
          : (isDark ? Colors.white : Colors.black87),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: hasIcon ? 14 : 16),
            decoration: BoxDecoration(
              color: glassBg,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasIcon) ...[
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.authNeonLime,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          valueText,
                          style: textStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDark
                      ? AppColors.authMutedTextDark
                      : AppColors.lightMutedText,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
