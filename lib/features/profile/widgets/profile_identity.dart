import 'package:flutter/material.dart';
import 'verified_badge.dart';

class ProfileIdentity extends StatefulWidget {
  final String name;
  final bool isVerified;
  final String? username;
  final int? age;
  final String? location;
  final String bio;
  final bool isOwnProfile;

  const ProfileIdentity({
    super.key,
    required this.name,
    required this.isVerified,
    this.username,
    this.age,
    this.location,
    required this.bio,
    required this.isOwnProfile,
  });

  @override
  State<ProfileIdentity> createState() => _ProfileIdentityState();
}

class _ProfileIdentityState extends State<ProfileIdentity> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = isDark ? const Color(0xFFF5F5F6) : const Color(0xFF111216);
    final secondaryColor = isDark ? const Color(0xFFB0B0B7) : const Color(0xFF666971);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name and Verified Badge Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                widget.name,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: widget.isOwnProfile ? 36 : 32,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.isVerified) ...[
              const SizedBox(width: 8),
              const VerifiedBadge(size: 24),
            ],
          ],
        ),

        // Supporting info (age/location or username/location)
        if (widget.isOwnProfile) ...[
          // My Profile Supporting Info
          if (widget.username != null) ...[
            const SizedBox(height: 3),
            Text(
              '@${widget.username}',
              style: TextStyle(
                color: secondaryColor,
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          if (widget.location != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFBFFF27), // Neon Lime Accent
                  size: 18,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.location!,
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ] else ...[
          // Other User Supporting Info (Arjun style)
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.age != null) ...[
                Text(
                  '${widget.age}',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: secondaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (widget.location != null) ...[
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFBFFF27), // Neon Lime location pin to fit Arjun mockup theme
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.location!,
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],

        // Bio section
        if (widget.bio.isNotEmpty) ...[
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Text(
                widget.bio,
                style: TextStyle(
                  color: secondaryColor.withOpacity(0.95),
                  fontSize: 16,
                  height: 1.4,
                ),
                maxLines: _isExpanded ? null : 3,
                overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
