//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/ticket_message.dart';
import 'package:thinkcreative_technologies/Utils/formatStatusTime.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Widget getTicketRequestCloseMessage(
    {required BuildContext context,
    required TicketMessage mssg,
    required String currentUserID,
    required String customerUID,
    required bool cuurentUserCanSeeAgentNamePhoto}) {
  bool is24hrsFormat = true;
  humanReadableTime() => DateFormat(is24hrsFormat == true ? 'HH:mm' : 'h:mm a')
      .format(DateTime.fromMillisecondsSinceEpoch(mssg.tktMssgTIME));
  final registry = Provider.of<UserRegistry>(context, listen: false);
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        height: 15,
      ),
      Chip(
        backgroundColor: Mycolors.purple,
        label: MtCustomfontBoldSemi(
          text: mssg.tktMssgSENDBY == customerUID
              ? currentUserID == customerUID
                  ? " ${getTranslatedForCurrentUser(context, 'xxrequestedxx').replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxtktsxx')).replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxyouxx'))} "
                  : " ${getTranslatedForCurrentUser(context, 'xxrequestedxx').replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxtktsxx')).replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxcustomerxx'))} "
              : currentUserID == customerUID
                  ? " ${getTranslatedForCurrentUser(context, 'xxrequestedxx').replaceAll('(#####)', getTranslatedForCurrentUser(context, 'xxagentxx')).replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxyouxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxtktsxx'))} "
                  : "  ${getTranslatedForCurrentUser(context, 'xxrequestedxx').replaceAll('(#####)', getTranslatedForCurrentUser(context, 'xxagentxx')).replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxagentxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxtktsxx'))} ",
          color: Colors.white,
          fontsize: 13,
        ),
      ),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            mssg.tktMssgSENDBY == customerUID
                ? SizedBox()
                : Icon(
                    Icons.person,
                    color: Mycolors.greytext,
                    size: 12,
                  ),
            mssg.tktMssgSENDBY == customerUID
                ? SizedBox()
                : Text(
                    cuurentUserCanSeeAgentNamePhoto
                        ? "  ${registry.getUserData(context, mssg.tktMssgSENDBY).fullname}"
                        : "  ${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${registry.getUserData(context, mssg.tktMssgSENDBY).id}",
                    style: TextStyle(fontSize: 12, color: Mycolors.greytext),
                  ),
            mssg.tktMssgSENDBY == customerUID
                ? SizedBox()
                : SizedBox(
                    width: 30,
                  ),
            Text(
                getWhen(DateTime.fromMillisecondsSinceEpoch(mssg.tktMssgTIME),
                        context) +
                    ', ',
                style: TextStyle(
                  color: Mycolors.greytext,
                  fontSize: 11.0,
                )),
            Text(' ' + humanReadableTime().toString(),
                style: TextStyle(
                  color: Mycolors.greytext,
                  fontSize: 11.0,
                )),
            // isMe ? icon : SizedBox()
            // ignore: unnecessary_null_comparison
          ].where((o) => o != null).toList()),
      SizedBox(
        height: 10,
      ),
    ],
  );
}
