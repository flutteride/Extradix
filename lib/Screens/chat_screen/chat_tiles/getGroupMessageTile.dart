//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Models/DataModel.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/groupchat/GroupChatPage.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/callhistory.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/chat_tiles/getLastMessageTime.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/chat_tiles/getMediaMessage.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/liveListener.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Utils/getRolePermission.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/late_load.dart';

Color darkGrey = Colors.blueGrey[700]!;
Color lightGrey = Colors.blueGrey[400]!;

Widget groupMessageTile(
    {required BuildContext context,
    required List<Map<String, dynamic>> streamDocSnap,
    required int index,
    required String currentUserNo,
    required SharedPreferences prefs,
    required DataModel cachedModel,
    required int unRead,
    required bool isGroupChatMuted}) {
  final observer = Provider.of<Observer>(context, listen: false);

  SpecialLiveConfigData? livedata =
      Provider.of<SpecialLiveConfigData?>(context, listen: false);
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
  showMenuForGroupChat(contextForDialog, var groupDoc) {
    List<Widget> tiles = List.from(<Widget>[]);
    tiles.add(ListTile(
        dense: true,
        leading: Icon(isGroupChatMuted ? Icons.volume_up : Icons.volume_off,
            size: 22),
        title: Text(
          getTranslatedForCurrentUser(
              contextForDialog,
              isGroupChatMuted
                  ? 'xxunmutenotificationsxx'
                  : 'xxmutenotificationsxx'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onTap: observer.checkIfCurrentUserIsDemo(currentUserNo) == true
            ? () {
                Utils.toast(getTranslatedForCurrentUser(
                    context, 'xxxnotalwddemoxxaccountxx'));
              }
            : () async {
                Navigator.of(contextForDialog).pop();

                await FirebaseFirestore.instance
                    .collection(DbPaths.collectionAgentGroups)
                    .doc(streamDocSnap[index][Dbkeys.groupID])
                    .update({
                  Dbkeys.groupMUTEDMEMBERS: isGroupChatMuted
                      ? FieldValue.arrayRemove([currentUserNo])
                      : FieldValue.arrayUnion([currentUserNo]),
                }).then((value) async {
                  if (isGroupChatMuted == true) {
                    await FirebaseMessaging.instance
                        .subscribeToTopic(
                            "GROUP${streamDocSnap[index][Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, streamDocSnap[index][Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                        .catchError((err) {
                      FirebaseFirestore.instance
                          .collection(DbPaths.collectionAgentGroups)
                          .doc(streamDocSnap[index][Dbkeys.groupID])
                          .update({
                        Dbkeys.groupMUTEDMEMBERS: !isGroupChatMuted
                            ? FieldValue.arrayRemove([currentUserNo])
                            : FieldValue.arrayUnion([currentUserNo]),
                      });
                    });
                  } else {
                    await FirebaseMessaging.instance
                        .unsubscribeFromTopic(
                            "GROUP${streamDocSnap[index][Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, streamDocSnap[index][Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                        .catchError((err) {
                      FirebaseFirestore.instance
                          .collection(DbPaths.collectionAgentGroups)
                          .doc(streamDocSnap[index][Dbkeys.groupID])
                          .update({
                        Dbkeys.groupMUTEDMEMBERS: !isGroupChatMuted
                            ? FieldValue.arrayRemove([currentUserNo])
                            : FieldValue.arrayUnion([currentUserNo]),
                      });
                    });
                  }
                });
              }));

    showDialog(
        context: contextForDialog,
        builder: (contextForDialog) {
          return SimpleDialog(children: tiles);
        });
  }

  return streamLoadCollections(
      stream: FirebaseFirestore.instance
          .collection(DbPaths.collectionAgentGroups)
          .doc(streamDocSnap[index][Dbkeys.groupID])
          .collection(DbPaths.collectiongroupChats)
          .where(Dbkeys.groupmsgTYPE, whereIn: [
            MessageType.text.index,
            MessageType.image.index,
            MessageType.doc.index,
            MessageType.audio.index,
            MessageType.video.index,
            MessageType.contact.index,
            MessageType.location.index
          ])
          .orderBy(Dbkeys.groupmsgTIME, descending: true)
          .limit(1)
          .snapshots(),
      placeholder: SizedBox(),
      noDataWidget: Container(
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
                onLongPress: () {
                  showMenuForGroupChat(context, streamDocSnap[index]);
                },
                contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                leading: customCircleAvatarGroup(
                    url: streamDocSnap[index][Dbkeys.groupPHOTOURL],
                    radius: 22),
                title: Text(
                  streamDocSnap[index][Dbkeys.groupNAME],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Mycolors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.4,
                  ),
                ),
                subtitle: Text(
                  '${streamDocSnap[index][Dbkeys.groupMEMBERSLIST].length} ${getTranslatedForCurrentUser(context, 'xxagentsxx')}',
                  style: TextStyle(
                    color: lightGrey,
                    fontSize: 14,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new GroupChatPage(
                              isCurrentUserMuted: isGroupChatMuted,
                              isSharingIntentForwarded: false,
                              model: cachedModel,
                              prefs: prefs,
                              joinedTime: streamDocSnap[index]
                                  ['$currentUserNo-joinedOn'],
                              currentUserno: currentUserNo,
                              groupID: streamDocSnap[index][Dbkeys.groupID])));
                },
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    unRead == 0
                        ? SizedBox()
                        : Container(
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
                    SizedBox(
                      height: 3,
                    ),
                  ],
                )),
            Divider(
              height: 0,
            ),
          ],
        ),
      ),
      onfetchdone: (messages) {
        var lastMessage = messages.last;

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              ListTile(
                  onLongPress: () {
                    showMenuForGroupChat(context, streamDocSnap[index]);
                  },
                  contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  leading: customCircleAvatarGroup(
                      url: streamDocSnap[index][Dbkeys.groupPHOTOURL],
                      radius: 22),
                  title: Text(
                    streamDocSnap[index][Dbkeys.groupNAME],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Mycolors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.4,
                    ),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      lastMessage[Dbkeys.groupmsgSENDBY] == currentUserNo
                          ? SizedBox()
                          : Consumer<UserRegistry>(
                              builder: (context, registry, _child) {
                              // _filtered = availableContacts.filtered;
                              return Text(
                                  isShownamePhoto == false
                                      ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${lastMessage[Dbkeys.groupmsgSENDBY]}" +
                                          " : "
                                      : registry
                                              .getUserData(
                                                  context,
                                                  lastMessage[
                                                      Dbkeys.groupmsgSENDBY])
                                              .fullname +
                                          " : ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: unRead > 0 ? darkGrey : lightGrey,
                                  ));
                            }),
                      lastMessage[Dbkeys.groupmsgISDELETED] == true
                          ? Text(
                              getTranslatedForCurrentUser(
                                  context, 'xxmsgdeletedxx'),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: unRead > 0
                                      ? darkGrey.withOpacity(0.4)
                                      : lightGrey.withOpacity(0.4),
                                  fontStyle: FontStyle.italic))
                          : lastMessage[Dbkeys.groupmsgTYPE] ==
                                  MessageType.text.index
                              ? Container(
                                  width: lastMessage[Dbkeys.groupmsgSENDBY] ==
                                          currentUserNo
                                      ? MediaQuery.of(context).size.width / 2.7
                                      : MediaQuery.of(context).size.width / 4.1,
                                  child: Text(
                                      lastMessage[Dbkeys.groupmsgCONTENT],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: unRead > 0
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: unRead > 0
                                              ? darkGrey
                                              : lightGrey)),
                                )
                              : getMediaMessage(context, false, lastMessage),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new GroupChatPage(
                                  isCurrentUserMuted: isGroupChatMuted,
                                  isSharingIntentForwarded: false,
                                  model: cachedModel,
                                  prefs: prefs,
                                  joinedTime: streamDocSnap[index]
                                      ['$currentUserNo-joinedOn'],
                                  groupID: streamDocSnap[index][Dbkeys.groupID],
                                  currentUserno: currentUserNo,
                                )));
                  },
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      lastMessage == {} || lastMessage == null
                          ? SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                getLastMessageTime(context, currentUserNo,
                                    lastMessage[Dbkeys.groupmsgTIME]),
                                style: TextStyle(
                                    color:
                                        unRead != 0 ? Colors.green : lightGrey,
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
                          isGroupChatMuted
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
                                  margin: EdgeInsets.only(
                                      left: isGroupChatMuted ? 7 : 0),
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
      });
}
