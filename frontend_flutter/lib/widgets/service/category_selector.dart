// lib/widgets/service/category_selector.dart

import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final int activeIndex;
  final List<Map<String, dynamic>> categories;
  final ValueChanged<int> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.activeIndex,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final count = categories.length;
    const double spacing = 12.0;

    if (count == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildItem(0, isHorizontalTile: true),
      );
    } 
    
    if (count == 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(child: _buildItem(0)),
            const SizedBox(width: spacing),
            Expanded(child: _buildItem(1)),
          ],
        ),
      );
    } 
    
    if (count == 3) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildItem(0, isHorizontalTile: true),
            const SizedBox(height: spacing),
            Row(
              children: [
                Expanded(child: _buildItem(1)),
                const SizedBox(width: spacing),
                Expanded(child: _buildItem(2)),
              ],
            ),
          ],
        ),
      );
    } 
    
    if (count == 4) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: _buildItem(0)),
                const SizedBox(width: spacing),
                Expanded(child: _buildItem(1)),
              ],
            ),
            const SizedBox(height: spacing),
            Row(
              children: [
                Expanded(child: _buildItem(2)),
                const SizedBox(width: spacing),
                Expanded(child: _buildItem(3)),
              ],
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: count,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 80,
              child: _buildItem(index, forceFixedSquare: true),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItem(int index, {bool isHorizontalTile = false, bool forceFixedSquare = false}) {
    final isSelected = activeIndex == index;
    final item = categories[index];
    final iconData = item['icon'] as IconData;
    final label = item['label'] as String;

    final Color activeBg = const Color(0xFF39B8FD);
    final Color inactiveBg = const Color(0xFFDCE9FF);
    final Color activeContent = Colors.white;
    final Color inactiveContent = const Color(0xFF004AC6);

    if (isHorizontalTile) {
      return GestureDetector(
        onTap: () => onCategorySelected(index),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, size: 26, color: isSelected ? activeContent : inactiveContent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? activeContent : const Color(0xFF0B1C30),
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

    return GestureDetector(
      onTap: () => onCategorySelected(index),
      child: forceFixedSquare
          ? SizedBox(
              height: 72,
              width: 80,
              child: _buildBlockContent(iconData, label, isSelected, activeBg, inactiveBg, activeContent, inactiveContent, isFixedSlider: true),
            )
          : AspectRatio(
              aspectRatio: 1.2,
              child: _buildBlockContent(iconData, label, isSelected, activeBg, inactiveBg, activeContent, inactiveContent, isFixedSlider: false),
            ),
    );
  }

  Widget _buildBlockContent(
    IconData iconData,
    String label,
    bool isSelected,
    Color activeBg,
    Color inactiveBg,
    Color activeContent,
    Color inactiveContent, {
    required bool isFixedSlider,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? activeBg : inactiveBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double iconSize = 28.0;
          double fontSize = 12.0;

          if (!isFixedSlider) {
            iconSize = (constraints.maxWidth * 0.22).clamp(26.0, 40.0);
            fontSize = (constraints.maxWidth * 0.09).clamp(11.0, 14.0);
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconData,
                size: iconSize,
                color: isSelected ? activeContent : inactiveContent,
              ),
              SizedBox(height: isFixedSlider ? 6 : constraints.maxHeight * 0.08),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? activeContent : const Color(0xFF0B1C30),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }
}