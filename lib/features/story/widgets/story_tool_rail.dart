import 'package:flutter/material.dart';
import '../providers/story_composer_provider.dart';
import 'story_tool_button.dart';

class StoryToolRail extends StatelessWidget {
  final StoryTool? activeTool;
  final ValueChanged<StoryTool?> onToolSelected;
  final bool isLeftHanded;

  const StoryToolRail({
    super.key,
    required this.activeTool,
    required this.onToolSelected,
    this.isLeftHanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      right: isLeftHanded ? null : 16,
      left: isLeftHanded ? 16 : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StoryToolButton(
            icon: Icons.title_rounded,
            label: 'Text',
            isActive: activeTool == StoryTool.text,
            onTap: () => onToolSelected(
              activeTool == StoryTool.text ? null : StoryTool.text,
            ),
          ),
          const SizedBox(height: 12),
          StoryToolButton(
            icon: Icons.emoji_emotions_outlined,
            label: 'Stickers',
            isActive: activeTool == StoryTool.stickers,
            onTap: () => onToolSelected(
              activeTool == StoryTool.stickers ? null : StoryTool.stickers,
            ),
          ),
          const SizedBox(height: 12),
          StoryToolButton(
            icon: Icons.gesture_rounded,
            label: 'Draw',
            isActive: activeTool == StoryTool.draw,
            onTap: () => onToolSelected(
              activeTool == StoryTool.draw ? null : StoryTool.draw,
            ),
          ),
          const SizedBox(height: 12),
          StoryToolButton(
            icon: Icons.crop_rotate_rounded,
            label: 'Crop',
            isActive: activeTool == StoryTool.crop,
            onTap: () => onToolSelected(
              activeTool == StoryTool.crop ? null : StoryTool.crop,
            ),
          ),
          const SizedBox(height: 12),
          StoryToolButton(
            icon: Icons.music_note_rounded,
            label: 'Music',
            isActive: activeTool == StoryTool.music,
            onTap: () => onToolSelected(
              activeTool == StoryTool.music ? null : StoryTool.music,
            ),
          ),
        ],
      ),
    );
  }
}
