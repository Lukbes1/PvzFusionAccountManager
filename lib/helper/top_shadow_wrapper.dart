import 'package:flutter/material.dart';

class TopShadowWrapper extends StatelessWidget {
  final double childContainerHeight;
  final double shadowHeight;
  final Widget child;
  final double top;
  final double circleRadius;
  final bool expand;
  final EdgeInsetsGeometry padding;

  const TopShadowWrapper({
    this.circleRadius = 5,
    this.shadowHeight = 12,
    this.padding = EdgeInsetsGeometry.zero,
    this.top = 0,
    required this.childContainerHeight,
    this.expand = false,
    required this.child,
    super.key,
  });

  Widget _buildStack() {
    return Stack(
      children: [
        // CONTENT
        Positioned.fill(child: child),

        // INNER TOP SHADOW
        Positioned(
          top: top,
          left: 0,
          right: 0,
          height: shadowHeight,
          child: Padding(
            padding: padding,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(circleRadius),
      child: SizedBox(
        height: expand ? null : childContainerHeight,
        child: _buildStack(),
      ),
    );
  }
}
