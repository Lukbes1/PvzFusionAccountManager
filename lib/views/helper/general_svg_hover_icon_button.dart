import 'package:flutter/material.dart';

///Useful for Icons that switch their icon when hovered
class GeneralSvgHoverIconButton extends StatefulWidget {
  final Widget icon;
  final Widget iconHovered;
  final VoidCallback onPressed;
  final double? iconSize;

  const GeneralSvgHoverIconButton({
    required this.icon,
    required this.iconHovered,
    required this.onPressed,
    this.iconSize,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _GeneralSvgHoverIconButton();
  }
}

class _GeneralSvgHoverIconButton extends State<GeneralSvgHoverIconButton> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: IconButton(
        onHover: (value) {
          setState(() {
            isHovered = value;
          });
        },
        iconSize: widget.iconSize,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onPressed: widget.onPressed,
        icon: isHovered ? widget.iconHovered : widget.icon,
      ),
    );
  }
}
