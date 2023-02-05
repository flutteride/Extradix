//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:flutter/material.dart';

Widget sectionHeader(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(10, 27, 7, 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: Text(
            text,
            style: TextStyle(
                fontSize: 12.5,
                letterSpacing: 0.9,
                color: Mycolors.grey,
                fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
