import 'package:flutter/material.dart';
import 'package:pvz_fusion_acc_manager/helper/general_selectable_button.dart';
import 'package:pvz_fusion_acc_manager/models/data/profil_bild.dart';

class ProfilbildListButton extends StatelessWidget {
  final ProfilBild profilBild;
  final bool isSelected;
  final VoidCallback onPressed;
  const ProfilbildListButton({
    required this.profilBild,
    required this.onPressed,
    required this.isSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GeneralSelectableButton(
      onPressed: onPressed,
      isSelected: isSelected,
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(6),
        child: Image.memory(
          profilBild.bild,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
