//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Models/DataModel.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/callhistory.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/chat.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/chat_tiles/getGroupMessageTile.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/chat_tiles/getLastMessageTime.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/chat_tiles/getMediaMessage.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/liveListener.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Utils/getRolePermission.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';

Widget getPersonalMessageTile({
  required BuildContext context,
  required String currentUserNo,
  required SharedPreferences prefs,
  required String chatID,
  required DataModel cachedModel,
  var lastMessage,
  required var peer,
  required int unRead,
  peerSeenStatus,
  required var isPeerChatMuted,
}) {
  final observer = Provider.of<Observer>(context, listen: true);

  SpecialLiveConfigData? livedata =
      Provider.of<SpecialLiveConfigData?>(context, listen: true);
  bool isShownamePhoto = observer
              .userAppSettingsDoc!.agentcanseeagentnameandphoto! ==
          true ||
      (iAmSecondAdmin(
                  specialLiveConfigData: livedata,
                  currentuserid: currentUserNo,
                  context: context) ==
              true &&
          observer.userAppSettingsDoc!.secondadmincanseeagentnameandphoto ==
              true) ||
      (iAmDepartmentManager(currentuserid: currentUserNo, context: context) ==
              true &&
          observer.userAppSettingsDoc!
                  .departmentmanagercanseeagentnameandphoto ==
              true);
  //-- New context menu with Set Alias & Delete Chat tile
  showMenuForOneToOneChat(
      contextForDialog, Map<String, dynamic> targetUser, bool isMuted) {
    List<Widget> tiles = List.from(<Widget>[]);

    tiles.add(ListTile(
        dense: true,
        leading: Icon(isMuted ? Icons.volume_up : Icons.volume_off, size: 22),
        title: Text(
          getTranslatedForCurrentUser(contextForDialog,
              isMuted ? 'xxunmutenotificationsxx' : 'xxmutenotificationsxx'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onTap: observer.checkIfCurrentUserIsDemo(currentUserNo) == true
            ? () {
                Utils.toast(getTranslatedForCurrentUser(
                    context, 'xxxnotalwddemoxxaccountxx'));
              }
            : () async {
                Navigator.of(contextForDialog).pop();

                FirebaseFirestore.instance
                    .collection(DbPaths.collectionAgentIndividiualmessages)
                    .doc(chatID)
                    .update({
                  "$currentUserNo-muted": !isMuted,
                });
              }));

    showDialog(
        context: contextForDialog,
        builder: (contextForDialog) {
          return SimpleDialog(children: tiles);
        });
  }

  return Container(
    color: Colors.white,
    child: Column(
      children: [
        ListTile(
            contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            onLongPress: () {
              showMenuForOneToOneChat(context, peer, isPeerChatMuted);
            },
            leading: Stack(
              children: [
                customCircleAvatar(
                    url: isShownamePhoto == false ? "" : peer[Dbkeys.photoUrl],
                    radius: 22),
                peer[Dbkeys.lastSeen] == true ||
                        peer[Dbkeys.lastSeen] == currentUserNo
                    ? Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 8,
                          child: CircleAvatar(
                            backgroundColor: Color(0xff08cc8a),
                            radius: 6,
                          ),
                        ))
                    : SizedBox()
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                peer[Dbkeys.lastSeen] == currentUserNo
                    ? MtCustomfontRegular(
                        text:
                            getTranslatedForCurrentUser(context, 'xxtypingxx'),
                        fontsize: 14,
                        isitalic: true,
                        color: lightGrey,
                      )
                    : lastMessage == null || lastMessage == {}
                        ? SizedBox(
                            width: 0,
                          )
                        : lastMessage![Dbkeys.from] != currentUserNo
                            ? SizedBox()
                            : lastMessage![Dbkeys.messageType] ==
                                    MessageType.text.index
                                ? Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Icon(
                                      Icons.done_all,
                                      size: 15,
                                      color: peerSeenStatus == null
                                          ? lightGrey
                                          : lastMessage == null ||
                                                  lastMessage == {}
                                              ? lightGrey
                                              : peerSeenStatus is bool
                                                  ? Colors.lightBlue
                                                  : peerSeenStatus >
                                                          lastMessage[
                                                              Dbkeys.timestamp]
                                                      ? Colors.lightBlue
                                                      : lightGrey,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Icon(
                                      Icons.done_all,
                                      size: 15,
                                      color: peerSeenStatus == null
                                          ? lightGrey
                                          : lastMessage == null ||
                                                  lastMessage == {}
                                              ? lightGrey
                                              : peerSeenStatus is bool
                                                  ? Colors.lightBlue
                                                  : peerSeenStatus >
                                                          lastMessage[
                                                              Dbkeys.timestamp]
                                                      ? Colors.lightBlue
                                                      : lightGrey,
                                    ),
                                  ),
                peer[Dbkeys.lastSeen] == currentUserNo
                    ? SizedBox()
                    : lastMessage == null || lastMessage == {}
                        ? SizedBox()
                        : (currentUserNo == lastMessage[Dbkeys.from] &&
                                        lastMessage![
                                            Dbkeys.hasSenderDeleted]) ==
                                    true ||
                                (currentUserNo != lastMessage[Dbkeys.from] &&
                                    lastMessage![Dbkeys.hasRecipientDeleted])
                            ? Text(
                                getTranslatedForCurrentUser(
                                    context, 'xxmsgdeletedxx'),
                                style: TextStyle(
                                    fontSize: 14,
                                    color: unRead > 0
                                        ? darkGrey.withOpacity(0.4)
                                        : lightGrey.withOpacity(0.4),
                                    fontStyle: FontStyle.italic))
                            : lastMessage![Dbkeys.messageType] ==
                                    MessageType.text.index
                                ? SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    child: Text(lastMessage[Dbkeys.content],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: unRead > 0
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: unRead > 0
                                                ? darkGrey
                                                : lightGrey)))
                                : getMediaMessage(
                                    context, unRead > 0, lastMessage),
              ],
            ),
            title: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Consumer<UserRegistry>(
                    builder: (context, registry, _child) {
                  // _filtered = availableContacts.filtered;
                  return MtCustomfontBoldSemi(
                    text: isShownamePhoto == false
                        ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${peer[Dbkeys.id]}"
                        : registry
                            .getUserData(context, peer[Dbkeys.id])
                            .fullname,
                    fontsize: 16.4,
                    maxlines: 1,
                    color: Mycolors.black,
                    overflow: TextOverflow.ellipsis,
                  );
                })),
            onTap: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new ChatScreen(
                            isSharingIntentForwarded: false,
                            prefs: prefs,
                            unread: unRead,
                            model: cachedModel,
                            currentUserID: currentUserNo,
                            peerUID: peer[Dbkeys.id],
                          )));
            },
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                lastMessage == {} || lastMessage == null
                    ? SizedBox()
                    : Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          getLastMessageTime(context, currentUserNo,
                              lastMessage[Dbkeys.timestamp]),
                          style: TextStyle(
                              color: unRead != 0 ? Colors.green : lightGrey,
                              fontWeight: FontWeight.w400,
                              fontSize: 12),
                        ),
                      ),
                SizedBox(
                  height: 6,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    isPeerChatMuted
                        ? Icon(
                            Icons.volume_off,
                            size: 20,
                            color: lightGrey.withOpacity(0.5),
                          )
                        : Icon(
                            Icons.volume_up,
                            size: 20,
                            color: Colors.transparent,
                          ),
                    unRead == 0
                        ? SizedBox()
                        : Container(
                            margin:
                                EdgeInsets.only(left: isPeerChatMuted ? 7 : 0),
                            child: Text(unRead.toString(),
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            padding: const EdgeInsets.all(7.0),
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green[400],
                            ),
                          ),
                  ],
                ),
              ],
            )),
        Divider(
          height: 0,
        ),
      ],
    ),
  );
}
