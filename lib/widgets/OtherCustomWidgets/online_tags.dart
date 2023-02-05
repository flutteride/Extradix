//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:flutter/material.dart';

Widget onlineTagText({String? text, double? width}) {
  return Container(
    // width: width ?? 60,
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: Mycolors.onlinetag,
          radius: 3.3,
        ),
        SizedBox(
          width: 6,
        ),
        MtCustomfontBold(
          text: text ?? "Online",
          fontsize: 12,
          color: Mycolors.onlinetag,
        )
      ],
    ),
  );
}
