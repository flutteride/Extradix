//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:flutter/material.dart';

Widget roleBasedSticker(BuildContext context, int userType) {
  return Center(
    child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: userType == Usertype.agent.index
              ? Colors.purple.withOpacity(0.7)
              : userType == Usertype.customer.index
                  ? Colors.pink.withOpacity(0.7)
                  : userType == Usertype.secondadmin.index
                      ? Colors.green.withOpacity(0.7)
                      : userType == Usertype.departmentmanager.index
                          ? Colors.orange.withOpacity(0.7)
                          : Colors.pink.withOpacity(0.7),
        ),
        height: 17,
        padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
        // width: 70,
        child: MtCustomfontBoldSemi(
          text: userType == Usertype.agent.index
              ? getTranslatedForCurrentUser(context, 'xxagentxx')
              : userType == Usertype.customer.index
                  ? getTranslatedForCurrentUser(context, 'xxcustomerxx')
                  : userType == Usertype.secondadmin.index
                      ? getTranslatedForCurrentUser(context, 'xxsecondadminxx')
                      : userType == Usertype.departmentmanager.index
                          ? getTranslatedForCurrentUser(
                              context, 'xxdepartmentmanagerxx')
                          : getTranslatedForCurrentUser(
                              context, 'xxcustomerxx'),
          fontsize: 11,
          lineheight: 1.1,
          color: Mycolors.whiteDynamic,
        )),
  );
}
