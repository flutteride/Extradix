//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Models/user_registry_model.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/ticketWidget.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/callhistory.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:flutter/material.dart';

Widget usercard(var doc) {
  return Container(
    decoration: boxDecoration(showShadow: true),
    margin: EdgeInsets.all(8),
    padding: EdgeInsets.fromLTRB(14, 15, 14, 18),
    child: ListTile(
      leading: customCircleAvatar(url: '', radius: 20),
    ),
  );
}

Widget selectableusercard(
    {required BuildContext context,
    required UserRegistryModel doc,
    bool? isManager = false,
    required Function(String uid, UserRegistryModel usermodel) onselected,
    required List<dynamic> bannedusers,
    required bool isCustomer,
    required bool isShowPhonenumber}) {
  return bannedusers.contains(doc.id)
      ? SizedBox()
      : Container(
          decoration: boxDecoration(showShadow: true),
          margin: EdgeInsets.fromLTRB(7, 3, 7, 3),
          padding: EdgeInsets.fromLTRB(6, 4, 6, 4),
          child: ListTile(
            onTap: bannedusers.contains(doc.id)
                ? () {
                    Utils.toast(getTranslatedForCurrentUser(
                        context, 'xxcannotselectthisxx'));
                  }
                : () {
                    Navigator.pop(context);
                    onselected(doc.id, doc);
                  },
            leading: customCircleAvatar(url: doc.photourl, radius: 20),
            title: Text(
              doc.fullname,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: isShowPhonenumber == true ? Text(doc.id) : null,
            trailing: Container(
              width: 70,
              child: Center(
                child: Text(
                  isCustomer == true
                      ? getTranslatedForCurrentUser(context, 'xxcustomerxx')
                      : isManager == false
                          ? getTranslatedForCurrentUser(context, 'xxagentxx')
                          : getTranslatedForCurrentUser(context, 'xxmanagerxx'),
                  style: TextStyle(color: Mycolors.black, fontSize: 11),
                ),
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Mycolors.agentPrimary.withOpacity(0.1)),
              height: 20,
            ),
          ),
        );
}

Widget tickableusercard(
    {required BuildContext context,
    required UserRegistryModel doc,
    bool? isManager = false,
    required Function(String s, UserRegistryModel map) onselected,
    required List<dynamic> bannedusers,
    required List<dynamic> selectedusers,
    required bool isCustomer,
    required bool isShowPhonenumber}) {
  return Container(
    decoration: boxDecoration(showShadow: true),
    margin: EdgeInsets.all(8),
    padding: EdgeInsets.fromLTRB(6, 4, 6, 4),
    child: ListTile(
      onTap: bannedusers.contains(doc.id)
          ? () {
              Utils.toast(
                  getTranslatedForCurrentUser(context, 'xxcannotselectthisxx'));
            }
          : () {
              onselected(doc.id, doc);
            },
      leading: customCircleAvatar(url: doc.id, radius: 20),
      title: Text(
        doc.id,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: isShowPhonenumber == true ? Text(doc.id) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            child: Center(
              child: Text(
                isCustomer == true
                    ? getTranslatedForCurrentUser(context, 'xxcustomerxx')
                    : isManager == false
                        ? getTranslatedForCurrentUser(context, 'xxagentxx')
                        : getTranslatedForCurrentUser(context, 'xxmanagerxx'),
                style: TextStyle(color: Mycolors.agentPrimary, fontSize: 11),
              ),
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Mycolors.agentPrimary.withOpacity(0.1)),
            height: 20,
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(5),
            ),
            child:
                selectedusers.lastIndexWhere((element) => element == doc.id) >=
                        0
                    ? Icon(
                        Icons.check,
                        size: 19.0,
                        color: Mycolors.green,
                      )
                    : Icon(
                        null,
                        size: 19.0,
                      ),
          ),
        ],
      ),
    ),
  );
}
