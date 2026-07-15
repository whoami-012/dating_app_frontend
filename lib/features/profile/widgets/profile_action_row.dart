import 'package:flutter/material.dart';

// --- Other User Action Row ---

class OtherUserActionRow extends StatefulWidget {
  final String connectionState; // 'connect', 'request_sent', 'connected', 'loading', 'disabled'
  final bool isLiked;
  final VoidCallback onConnectTap;
  final VoidCallback onMessageTap;
  final VoidCallback onLikeTap;

  const OtherUserActionRow({
    super.key,
    required this.connectionState,
    required this.isLiked,
    required this.onConnectTap,
    required this.onMessageTap,
    required this.onLikeTap,
  });

  @override
  State<OtherUserActionRow> createState() => _OtherUserActionRowState();
}

class _OtherUserActionRowState extends State<OtherUserActionRow> with SingleTickerProviderStateMixin {
  late final AnimationController _likeController;
  late final Animation<double> _likeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // 180-220ms requirement
    );
    _likeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _likeController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant OtherUserActionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked != oldWidget.isLiked) {
      final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (!disableAnimations) {
        _likeController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final double screenWidth = MediaQuery.sizeOf(context).width;
    // Responsive padding adjustments for 320px screen width
    final bool isNarrow = screenWidth < 350;
    final double buttonGap = isNarrow ? 8.0 : 10.0;
    final double connectFontSize = isNarrow ? 15.0 : 17.0;
    final double messageFontSize = isNarrow ? 15.0 : 17.0;

    // Connect button styling
    Widget connectButton;
    final bool isLoading = widget.connectionState == 'loading';
    final bool isRequestSent = widget.connectionState == 'request_sent';
    final bool isConnected = widget.connectionState == 'connected';
    final bool isDisabled = widget.connectionState == 'disabled';

    final Color limeColor = const Color(0xFFBFFF27);

    if (isLoading) {
      connectButton = Container(
        height: 60,
        decoration: BoxDecoration(
          color: limeColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 2.5,
            ),
          ),
        ),
      );
    } else {
      Color bg;
      Color textIconColor;
      Border? border;
      IconData icon;
      String text;

      if (isRequestSent) {
        bg = isDark ? Colors.black : Colors.white;
        textIconColor = limeColor;
        border = Border.all(color: limeColor, width: 2.0);
        icon = Icons.check_circle_outline_rounded;
        text = 'Requested';
      } else if (isConnected) {
        bg = isDark ? const Color(0xFF18191C) : const Color(0xFFE5E5E5);
        textIconColor = isDark ? Colors.white : Colors.black;
        icon = Icons.people_alt_rounded;
        text = 'Connected';
      } else if (isDisabled) {
        bg = isDark ? Colors.white10 : Colors.black12;
        textIconColor = isDark ? Colors.white30 : Colors.black.withOpacity(0.3);
        icon = Icons.person_add_rounded;
        text = 'Connect';
      } else {
        // 'connect' state
        bg = limeColor;
        textIconColor = Colors.black;
        icon = Icons.person_add_rounded;
        text = 'Connect';
      }

      connectButton = Semantics(
        label: isRequestSent
            ? 'Cancel connection request'
            : isConnected
                ? 'Connected'
                : 'Send connection request',
        child: ElevatedButton(
          onPressed: isDisabled ? null : widget.onConnectTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: textIconColor,
            elevation: 0,
            minimumSize: const Size(0, 60),
            padding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: border?.top ?? BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: textIconColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: connectFontSize,
                    fontWeight: FontWeight.w700,
                    color: textIconColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Message button styling
    final Color purpleColor = const Color(0xFFA96BFF);
    final Color purpleBorderColor = const Color(0xFF8250C8);
    final Widget messageButton = ElevatedButton(
      onPressed: widget.onMessageTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? Colors.transparent : Colors.white,
        foregroundColor: purpleColor,
        elevation: 0,
        minimumSize: const Size(0, 60),
        padding: EdgeInsets.symmetric(horizontal: isNarrow ? 10 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: purpleBorderColor, width: 2.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_rounded, size: 19, color: purpleColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Message',
              style: TextStyle(
                fontSize: messageFontSize,
                fontWeight: FontWeight.w700,
                color: purpleColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    // Like button
    final Widget likeButton = ScaleTransition(
      scale: _likeScaleAnimation,
      child: Semantics(
        label: widget.isLiked ? 'Unlike profile' : 'Like profile',
        selected: widget.isLiked,
        child: GestureDetector(
          onTap: widget.onLikeTap,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111214) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isLiked
                    ? limeColor
                    : (isDark ? Colors.white12 : Colors.black12),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                widget.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: widget.isLiked ? limeColor : (isDark ? Colors.white70 : Colors.black54),
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );

    return Row(
      children: [
        // Connect: 42-45% width
        Expanded(
          flex: 43,
          child: connectButton,
        ),
        SizedBox(width: buttonGap),
        // Message: 34-38% width
        Expanded(
          flex: 36,
          child: messageButton,
        ),
        SizedBox(width: buttonGap),
        // Like: remaining circular button (approx 15-20%)
        likeButton,
      ],
    );
  }
}

// --- My Profile Action Row ---

class MyProfileActionRow extends StatelessWidget {
  final VoidCallback onEditProfileTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onShareProfileTap;

  const MyProfileActionRow({
    super.key,
    required this.onEditProfileTap,
    required this.onSettingsTap,
    required this.onShareProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color limeColor = const Color(0xFFBFFF27);
    final Color buttonBg = isDark ? const Color(0xFF18191C) : Colors.white;
    final Color borderColor = isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.10);
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Edit Profile Button (Full Width, Rounded Rectangle)
        ElevatedButton(
          onPressed: onEditProfileTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: limeColor,
            foregroundColor: Colors.black,
            elevation: 0,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_rounded, size: 20, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Settings and Share Row (Two Equal Buttons)
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onSettingsTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBg,
                  foregroundColor: textColor,
                  elevation: 0,
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: borderColor, width: 1.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.settings_rounded,
                      size: 20,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onShareProfileTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBg,
                  foregroundColor: textColor,
                  elevation: 0,
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: borderColor, width: 1.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.share_rounded,
                      size: 19,
                      color: Color(0xFFA96BFF), // Purple share icon
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Share Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
