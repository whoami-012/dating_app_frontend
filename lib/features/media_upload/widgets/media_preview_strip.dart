import 'package:flutter/material.dart';
import '../models/selected_media.dart';
import 'media_preview_card.dart';
import 'add_media_card.dart';

class MediaPreviewStrip extends StatelessWidget {
  final List<SelectedMedia> mediaList;
  final VoidCallback onAddPressed;
  final ValueChanged<String> onRemovePressed;

  const MediaPreviewStrip({
    super.key,
    required this.mediaList,
    required this.onAddPressed,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = mediaList.length + 1; // +1 for the AddMoreMediaCard

    return SizedBox(
      height: 202, // 198 card height + 4 padding for borders/shadows
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        clipBehavior: Clip.none,
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index < mediaList.length) {
            final media = mediaList[index];
            return MediaPreviewCard(
              key: ValueKey(media.id),
              media: media,
              onRemove: () => onRemovePressed(media.id),
              index: index,
              totalCount: mediaList.length,
            );
          } else {
            return AddMoreMediaCard(onTap: onAddPressed);
          }
        },
      ),
    );
  }
}
