import 'package:flutter/material.dart';
import 'package:pvz_fusion_acc_manager/helper/top_shadow_wrapper.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/style/text.dart';

class GeneralGreenButton extends StatelessWidget {
  final Size fixedSize;
  final String? text;
  final Widget? widget;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;
  final bool noBorderDefault;
  final bool withShadows;
  final double borderWidth;

  /// noBorderDefault:  If true, border only is there when any state other than any is present
  const GeneralGreenButton({
    required this.fixedSize,
    this.borderRadius,
    this.text,
    this.noBorderDefault = false,
    this.withShadows = true,
    this.padding = const EdgeInsets.all(8),
    this.widget,
    this.onPressed,
    this.borderWidth = 5,
    super.key,
  });

  Widget _buildChild() {
    return text != null ? Center(child: Text(text!)) : widget ?? Placeholder();
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadiusGeometry actualBorderRadius =
        borderRadius ?? BorderRadius.circular(10);
    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: !withShadows
              ? null
              : const [
                  BoxShadow(
                    color: Color.fromARGB(80, 0, 0, 0),
                    blurRadius: 2,
                    spreadRadius: 1,
                    offset: Offset(-4, 5),
                    // pushed downward
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
            backgroundColor: const WidgetStateColor.fromMap({
              WidgetState.any: appGreen,
            }),
            iconColor: const WidgetStateColor.fromMap({
              WidgetState.disabled: Color(0xFF4E654B),
              WidgetState.any: appLightYellow,
            }),
            foregroundColor: const WidgetStateColor.fromMap({
              WidgetState.disabled: Color(0xFF4E654B),
              WidgetState.any: appLightYellow,
            }),
            textStyle: const WidgetStateProperty.fromMap({
              WidgetState.any: normalYellowNormal,
            }),
            shape: WidgetStateOutlinedBorder.fromMap({
              WidgetState.disabled: RoundedRectangleBorder(
                borderRadius: actualBorderRadius,
                side: BorderSide(
                  color: const Color(0xFF4E654B),
                  width: borderWidth,
                ),
              ),
              WidgetState.pressed: RoundedRectangleBorder(
                borderRadius: actualBorderRadius,
                side: BorderSide(
                  color: const Color(0xFFCE7936),
                  width: borderWidth,
                ),
              ),
              WidgetState.hovered: RoundedRectangleBorder(
                borderRadius: actualBorderRadius,
                side: BorderSide(
                  color: const Color(0xFFD2B25F),
                  width: borderWidth,
                ),
              ),
              WidgetState.focused: RoundedRectangleBorder(
                borderRadius: actualBorderRadius,
                side: BorderSide(
                  color: const Color(0xFFD2B25F),
                  width: borderWidth,
                ),
              ),
              WidgetState.any: RoundedRectangleBorder(
                borderRadius: actualBorderRadius,
                side: noBorderDefault
                    ? BorderSide.none
                    : BorderSide(color: appGreenBorder, width: borderWidth),
              ),
            }),
            fixedSize: WidgetStatePropertyAll(fixedSize),
          ),
          child: !withShadows
              ? _buildChild()
              : TopShadowWrapper(
                  childContainerHeight: fixedSize.height,
                  top: 2,
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 4),
                  child: _buildChild(),
                ),
        ),
      ),
    );
  }
}

//    WidgetState.pressed: ,
//  WidgetState.hovered:,
