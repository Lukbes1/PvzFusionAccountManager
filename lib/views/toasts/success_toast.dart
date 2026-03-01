import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pvz_fusion_acc_manager/views/helper/general_svg_icon_button.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:zentoast/zentoast.dart';

class SuccessToast extends StatelessWidget {
  final String text;
  final Toast toast;
  final double fontSize;
  const SuccessToast({
    required this.text,
    required this.toast,
    this.fontSize = 28,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appGreen,
        borderRadius: BorderRadius.circular(8),
        border: BoxBorder.all(color: appGreenBorder, width: 4),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'resources/icons/checkmark.svg',
            height: 28,
            width: 28,
            colorFilter: ColorFilter.mode(appLightYellow, BlendMode.srcIn),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'pvz',
                fontSize: fontSize,
                color: appLightYellow,
              ),
            ),
          ),
          GeneralSvgIconButton(
            height: 20,
            width: 20,
            iconColor: const WidgetStateColor.fromMap({
              WidgetState.pressed: appOrange,
              WidgetState.hovered: appGreenBorder,
              WidgetState.any: Colors.transparent,
            }),
            iconRessource: 'resources/icons/x.svg',
            onPressed: () => toast.hide(context),
          ),
        ],
      ),
    );
  }
}
