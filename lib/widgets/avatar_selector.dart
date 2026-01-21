import 'package:flutter/material.dart';

class AvatarSelector extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelected;

  // Simple list of Flutter Icons/Colors to simulate avatars
  final List<IconData> icons = [
    Icons.person,
    Icons.person_outline,
    Icons.face,
    Icons.face_2,
    Icons.face_3,
    Icons.face_4,
    Icons.emoji_emotions,
    Icons.tag_faces,
  ];

  final List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  AvatarSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: () => onSelected(index),
          child: Container(
            decoration: BoxDecoration(
              color: colors[index].withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: colors[index], width: 3)
                  : null,
            ),
            child: Icon(icons[index], color: colors[index], size: 30),
          ),
        );
      },
    );
  }
}
