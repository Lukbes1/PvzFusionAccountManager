import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

///Useful for Buttons that stay with the same icon, but need different color for different states
class GeneralSvgIconButton extends StatelessWidget {
  final WidgetStateProperty<Color> iconColor;
  final String iconRessource;
  final VoidCallback? onPressed;
  final double width;
  final double height;

  ///A general icon button. Use WidgetState.any: Colors.transparent to use default icon color.
  const GeneralSvgIconButton({
    required this.width,
    required this.height,
    required this.iconColor,
    required this.iconRessource,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      style: ButtonStyle(iconColor: iconColor),
      onPressed: onPressed,
      icon: Builder(
        builder: (context) {
          final color = IconTheme.of(context).color;
          return SvgPicture.asset(
            width: width,
            height: height,
            iconRessource,
            colorFilter: color == Colors.transparent
                ? null
                : ColorFilter.mode(
                    color ?? Colors.transparent,
                    BlendMode.srcIn,
                  ),
          );
        },
      ),
    );
  }
}
