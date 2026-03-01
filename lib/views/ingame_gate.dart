import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pvz_fusion_acc_manager/models/provider/accounts_provider.dart';

/// Verhindert das anklicken des Elements, falls jemand spielt
class InGameGate extends ConsumerWidget {
  final Widget child;

  const InGameGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSomeonePlaying = ref.watch(isSomeonePlayingProvider);
    return IgnorePointer(
      ignoring: isSomeonePlaying,
      child: Opacity(opacity: isSomeonePlaying ? 0.4 : 1.0, child: child),
    );
  }
}
