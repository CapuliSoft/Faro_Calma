import 'package:flutter/material.dart';
import 'package:gtc6/core/theme/colors.dart';

import '../../domain/models/web_type.dart';

/// A pill-shaped toggle button used to switch between [WebType] options.
class WebTypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const WebTypeButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? SensoryColors.primary.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? SensoryColors.primary
                : SensoryColors.primary.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected
                ? SensoryColors.primary
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}
