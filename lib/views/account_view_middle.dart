import 'package:flutter/material.dart';
import 'package:pvz_fusion_acc_manager/models/data/account.dart';
import 'package:pvz_fusion_acc_manager/models/data/profil_bild.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/style/text.dart';

class AccountViewMiddle extends StatelessWidget {
  final ProfilBild? profilBild;
  final bool? isSelected;
  final Account account;
  final double fontSizeName;
  final double fontSizeLastPlayed;
  final double? fontHeightName;
  final double? fontHeightLastPlayed;
  const AccountViewMiddle({
    super.key,
    required this.account,
    this.isSelected,
    required this.profilBild,
    this.fontSizeName = 28.0,
    this.fontHeightName,
    this.fontSizeLastPlayed = 17.0,
    this.fontHeightLastPlayed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appNormalYellow,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.35),
            blurRadius: 15,
            spreadRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
        border: BoxBorder.all(
          color: isSelected != null && isSelected == true
              ? const Color(0xFFB7994B)
              : Colors.transparent,
          width: 4,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 5),

          Visibility(
            visible: profilBild != null,
            child: SizedBox(
              width: 50,
              height: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: profilBild != null
                    ? Image.memory(profilBild!.bild, fit: BoxFit.cover)
                    : const Center(
                        child: Text(
                          'No Image',
                          style: purpleTextNormal,
                          softWrap: true,
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
          ),

          Visibility(
            visible: profilBild != null,
            child: const SizedBox(width: 12),
          ),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: fontHeightName == null
                      ? TextStyle(
                          color: appPurple,
                          fontSize: fontSizeName,
                          fontFamily: 'Pvz',
                        )
                      : TextStyle(
                          color: appPurple,
                          fontSize: fontSizeName,
                          fontFamily: 'Pvz',
                          height: fontSizeName,
                        ),
                ),
                Text(
                  account.getLastPlayedString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: fontHeightLastPlayed == null
                      ? purpleTextSmall.copyWith(fontSize: fontSizeLastPlayed)
                      : purpleTextSmall.copyWith(
                          fontSize: fontSizeLastPlayed,
                          height: fontHeightLastPlayed,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
