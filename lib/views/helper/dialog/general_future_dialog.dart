import 'package:flutter/material.dart';
import 'package:pvz_fusion_acc_manager/views/helper/general_circular_progress_indicator.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:window_manager/window_manager.dart';

///Useful for Dialogs
class GeneralFutureDialog<T> extends StatelessWidget {
  final Widget Function(T initData) builder;
  final Future<T> onInit;
  final String onLoadText;
  final double width;
  final double height;
  final Alignment alignment;
  final Color? onLoadColor;

  ///If true, the dialgo can be dragged to drag the app
  final bool canDragApp;

  ///onInit is first called and the value is then passed to the builder
  ///
  ///
  const GeneralFutureDialog({
    super.key,
    this.onLoadColor,
    required this.onLoadText,
    required this.builder,
    required this.onInit,
    required this.width,
    required this.height,
    this.canDragApp = false,
    required this.alignment,
  });

  Widget buildWidget(Widget child) {
    return Align(
      alignment: alignment,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appGreen,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: appGreenBorder, width: 5),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(80, 0, 0, 0),
                blurRadius: 2,
                spreadRadius: 1,
                offset: Offset(-4, 5),
                // pushed downward
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: canDragApp
          ? (details) => WindowManager.instance.startDragging()
          : null,
      child: FutureBuilder(
        future: onInit,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return buildWidget(
              GeneralCircularProgressIndicator(
                text: onLoadText,
                color: onLoadColor,
              ),
            );
          }
          return buildWidget(builder(snapshot.data as T));
        },
      ),
    );
  }
}
