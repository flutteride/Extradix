//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/department_model.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/dynamic_modal_bottomsheet.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget categoryCard(SharedPreferences prefs, DepartmentModel cat,
    Function(DepartmentModel c) onSelect) {
  return Container(
      // color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
          contentPadding: EdgeInsets.fromLTRB(10, 3, 10, 2),
          onTap: () {
            onSelect(cat);
          },
          title: MtCustomfontBoldSemi(
            text: cat.departmentTitle,
          ),
          subtitle: cat.departmentDesc == ''
              ? null
              : MtCustomfontRegular(
                  text: cat.departmentDesc,
                  maxlines: 1,
                  overflow: TextOverflow.ellipsis,
                  fontsize: 14,
                ),
          leading: cat.departmentLogoURL == ""
              ? Utils.squareAvatarIcon(
                  backgroundColor: Utils.randomColorgenratorBasedOnFirstLetter(
                      cat.departmentTitle),
                  iconData: Icons.location_city,
                  size: 45)
              : Utils.squareAvatarImage(url: cat.departmentLogoURL, size: 45)));
}

selectADepartment({
  required BuildContext context,
  required String title,
  required List<DepartmentModel> datalist,
  DepartmentModel? alreadyselected,
  required SharedPreferences prefs,
  required Function(DepartmentModel cat) onselected,
}) {
  showDynamicModalBottomSheet(
    context: context,
    widgetList: datalist
        .map((e) => categoryCard(prefs, e, (selectedCat) {
              Navigator.of(context).pop();
              onselected(selectedCat);
            }))
        .toList(),
    title: getTranslatedForCurrentUser(context, 'xxselectaxxxx').replaceAll(
        '(####)', getTranslatedForCurrentUser(context, 'xxdepartmentxx')),
  );
}
