import 'package:flutter/material.dart';
import 'package:pvz_fusion_acc_manager/views/helper/dialog/general_future_dialog.dart';

///Useful for Dialogs
class GeneralDialog extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final Alignment alignment;

  ///If true, the dialgo can be dragged to drag the app
  final bool canDragApp;

  ///onInit is first called and the value is then passed to the builder
  ///
  ///
  const GeneralDialog({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.canDragApp = false,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return GeneralFutureDialog(
      builder: (initData) => child,
      onLoadText: '',
      onInit: Future.value(0),
      width: width,
      height: height,
      alignment: alignment,
    );
  }
}
