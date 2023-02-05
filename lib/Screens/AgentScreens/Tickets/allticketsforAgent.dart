//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Configs/number_limits.dart';
import 'package:thinkcreative_technologies/Models/ticket_model.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/create_support_ticket.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/ticket_chat_room.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/ticketWidget.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/groupchat/add_agents_to_group.dart';
import 'package:thinkcreative_technologies/Screens/SelectUsers/SingleSelectUser.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/chat_tiles/getGroupMessageTile.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/chat_tiles/getPersonalMessageTile.dart';
import 'package:thinkcreative_technologies/Utils/Setupdata.dart';
import 'package:thinkcreative_technologies/Services/Admob/admob.dart';
import 'package:thinkcreative_technologies/Services/Providers/BroadcastProvider.dart';
import 'package:thinkcreative_technologies/Services/Providers/GroupChatProvider.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/call_history_provider.dart';
import 'package:thinkcreative_technologies/Services/Providers/liveListener.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/Localization/language.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/utils/messagedata.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/callhistory.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/chat.dart';
import 'package:thinkcreative_technologies/Models/DataModel.dart';
import 'package:thinkcreative_technologies/Utils/getRolePermission.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/main.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custominput.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/delayed_function.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/late_load.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/loadingDialog.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/myinkwell.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/nodata_widget.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/page_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:thinkcreative_technologies/Configs/optional_constants.dart';

class AllTicketForAgent extends StatefulWidget {
  AllTicketForAgent(
      {required this.currentUserID,
      required this.isSecuritySetupDone,
      required this.prefs,
      required this.fullname,
      required this.photourl,
      key})
      : super(key: key);
  final String? currentUserID;
  final String fullname;

  final String photourl;

  final SharedPreferences prefs;
  final bool isSecuritySetupDone;
  @override
  State createState() => new AllTicketForAgentState();
}

class AllTicketForAgentState extends State<AllTicketForAgent>
    with TickerProviderStateMixin {
  AllTicketForAgentState({Key? key}) {
    _filter.addListener(() {
      _userQuery.add(_filter.text.isEmpty ? '' : _filter.text);
    });
  }

  final TextEditingController _filter = new TextEditingController();
  bool isAuthenticating = false;

  List<StreamSubscription> unreadSubscriptions = [];
  TextEditingController _textcontroller = new TextEditingController();
  List<StreamController> controllers = [];
  final BannerAd myBanner = BannerAd(
    adUnitId: getBannerAdUnitId()!,
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  AdWidget? adWidget;
  late TabController tabController;
  late Stream<QuerySnapshot> ticketsStream;
  @override
  void initState() {
    super.initState();
    ticketsStream = FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        .where(Dbkeys.tktMEMBERSactiveList,
            arrayContainsAny: [widget.currentUserID])
        .orderBy(Dbkeys.ticketlatestTimestampForAgents, descending: true)
        .snapshots();
    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
    getModel();
    Utils.internetLookUp();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  bool isloading = true;

  void cancelUnreadSubscriptions() {
    unreadSubscriptions.forEach((subscription) {
      subscription.cancel();
    });
  }

  DataModel? _cachedModel;
  bool showHidden = false, biometricEnabled = false;

  bool isLoading = false;

  Widget buildItem(BuildContext context, Map<String, dynamic> user) {
    if (user[Dbkeys.id] == widget.currentUserID) {
      return Container(width: 0, height: 0);
    } else {
      return StreamBuilder(
        stream: getUnread(user).asBroadcastStream(),
        builder: (context, AsyncSnapshot<MessageData> unreadData) {
          int unread = unreadData.hasData &&
                  unreadData.data!.snapshot.docs.isNotEmpty
              ? unreadData.data!.snapshot.docs
                  .where((t) => t[Dbkeys.timestamp] > unreadData.data!.lastSeen)
                  .length
              : 0;
          return Theme(
              data: ThemeData(
                  splashColor: Mycolors.grey.withOpacity(0.2),
                  highlightColor: Colors.transparent),
              child: Column(
                children: [
                  ListTile(
                    tileColor: Colors.white,
                    contentPadding: EdgeInsets.fromLTRB(
                        user[Dbkeys.lastSeen] == true ? 17 : 20, 8, 20, 8),
                    onLongPress: () {
                      // showMenuForOneToOneChat(context, user);
                    },
                    leading: user[Dbkeys.lastSeen] == true
                        ? Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  Colors.green.withOpacity(0.7), // border color
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(2.6), // border width
                              child: Container(
                                padding: EdgeInsets.all(2), // border width
                                // or ClipRRect if you need to clip the content
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white, // inner circle color
                                ),
                                child: customCircleAvatar(
                                    url: user[Dbkeys.photoUrl],
                                    radius: 18), // inner content
                              ),
                            ),
                          )
                        : customCircleAvatar(
                            url: user[Dbkeys.photoUrl], radius: 22),
                    title: MtCustomfontRegular(
                      text: Utils.getNickname(user)!,
                      color: Mycolors.black,
                      fontsize: 16.4,
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new ChatScreen(
                                  isSharingIntentForwarded: false,
                                  prefs: widget.prefs,
                                  unread: unread,
                                  model: _cachedModel!,
                                  currentUserID: widget.currentUserID!,
                                  peerUID: user[Dbkeys.id])));
                    },
                    trailing: unread != 0
                        ? Container(
                            child: Text(unread.toString(),
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            padding: const EdgeInsets.all(7.0),
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              color: user[Dbkeys.lastSeen] == true
                                  ? Colors.green[400]
                                  : Colors.blue[400],
                            ),
                          )
                        : SizedBox(),
                  ),
                  Divider(
                    height: 0,
                  ),
                ],
              ));
        },
      );
    }
  }

  Stream<MessageData> getUnread(Map<String, dynamic> user) {
    String chatId = Utils.getChatId(widget.currentUserID, user[Dbkeys.id]);
    var controller = StreamController<MessageData>.broadcast();
    unreadSubscriptions.add(FirebaseFirestore.instance
        .collection(DbPaths.collectionAgentIndividiualmessages)
        .doc(chatId)
        .snapshots()
        .listen((doc) {
      if (doc[widget.currentUserID!] != null &&
          doc[widget.currentUserID!] is int) {
        unreadSubscriptions.add(FirebaseFirestore.instance
            .collection(DbPaths.collectionAgentIndividiualmessages)
            .doc(chatId)
            .collection(chatId)
            .snapshots()
            .listen((snapshot) {
          controller.add(MessageData(
              snapshot: snapshot, lastSeen: doc[widget.currentUserID!]));
        }));
      }
    }));
    controllers.add(controller);
    return controller.stream;
  }

  _isHidden(uid) {
    Map<String, dynamic> _currentUser = _cachedModel!.currentUser!;
    return _currentUser[Dbkeys.hidden] != null &&
        _currentUser[Dbkeys.hidden].contains(uid);
  }

  StreamController<String> _userQuery =
      new StreamController<String>.broadcast();

  List<Map<String, dynamic>> _streamDocSnap = [];
  buildPersonalMessage(
    Map<String, dynamic> realTimePeerData,
  ) {
    String chatId =
        Utils.getChatId(widget.currentUserID, realTimePeerData[Dbkeys.id]);
    return streamLoad(
        stream: FirebaseFirestore.instance
            .collection(DbPaths.collectionAgentIndividiualmessages)
            .doc(chatId)
            .snapshots(),
        placeholder: SizedBox(),
        onfetchdone: (chatDoc) {
          return streamLoadCollections(
              stream: FirebaseFirestore.instance
                  .collection(DbPaths.collectionAgentIndividiualmessages)
                  .doc(chatId)
                  .collection(chatId)
                  .where(Dbkeys.timestamp,
                      isGreaterThan: chatDoc[widget.currentUserID])
                  .snapshots(),
              placeholder: getPersonalMessageTile(
                peerSeenStatus: chatDoc[realTimePeerData[Dbkeys.id]],
                unRead: 0,
                peer: realTimePeerData,
                context: this.context,
                cachedModel: _cachedModel!,
                currentUserNo: widget.currentUserID!,
                lastMessage: null,
                prefs: widget.prefs,
                isPeerChatMuted:
                    chatDoc.containsKey("${widget.currentUserID}-muted")
                        ? chatDoc["${widget.currentUserID}-muted"]
                        : false,
                chatID: Utils.getChatId(
                    widget.currentUserID, realTimePeerData[Dbkeys.id]),
              ),
              noDataWidget: streamLoadCollections(
                  stream: FirebaseFirestore.instance
                      .collection(DbPaths.collectionAgentIndividiualmessages)
                      .doc(chatId)
                      .collection(chatId)
                      .orderBy(Dbkeys.timestamp, descending: true)
                      .limit(1)
                      .snapshots(),
                  placeholder: getPersonalMessageTile(
                      chatID: Utils.getChatId(
                          widget.currentUserID, realTimePeerData[Dbkeys.id]),
                      peerSeenStatus: chatDoc[realTimePeerData[Dbkeys.id]],
                      unRead: 0,
                      peer: realTimePeerData,
                      context: this.context,
                      cachedModel: _cachedModel!,
                      currentUserNo: widget.currentUserID!,
                      lastMessage: null,
                      prefs: widget.prefs,
                      isPeerChatMuted:
                          chatDoc.containsKey("${widget.currentUserID}-muted")
                              ? chatDoc["${widget.currentUserID}-muted"]
                              : false),
                  noDataWidget: SizedBox(),
                  onfetchdone: (messages) {
                    return getPersonalMessageTile(
                        chatID: Utils.getChatId(
                            widget.currentUserID, realTimePeerData[Dbkeys.id]),
                        peerSeenStatus: chatDoc[realTimePeerData[Dbkeys.id]],
                        unRead: 0,
                        peer: realTimePeerData,
                        context: this.context,
                        cachedModel: _cachedModel!,
                        currentUserNo: widget.currentUserID!,
                        lastMessage: messages.last,
                        prefs: widget.prefs,
                        isPeerChatMuted:
                            chatDoc.containsKey("${widget.currentUserID}-muted")
                                ? chatDoc["${widget.currentUserID}-muted"]
                                : false);
                  }),
              onfetchdone: (messages) {
                return getPersonalMessageTile(
                    peerSeenStatus: chatDoc[realTimePeerData[Dbkeys.id]],
                    unRead: messages.length,
                    peer: realTimePeerData,
                    context: this.context,
                    cachedModel: _cachedModel!,
                    currentUserNo: widget.currentUserID!,
                    lastMessage: messages.last,
                    prefs: widget.prefs,
                    isPeerChatMuted:
                        chatDoc.containsKey("${widget.currentUserID}-muted")
                            ? chatDoc["${widget.currentUserID}-muted"]
                            : false,
                    chatID: Utils.getChatId(
                        widget.currentUserID, realTimePeerData[Dbkeys.id]));
              });
        });
  }

  _chats(Map<String?, Map<String, dynamic>?> _userData,
      Map<String, dynamic>? currentUser) {
    return Consumer<List<GroupModel>>(
        builder: (context, groupList, _child) => Consumer<List<BroadcastModel>>(
                builder: (context, broadcastList, _child) {
              _streamDocSnap = Map.from(_userData)
                  .values
                  .where((_user) => _user.keys.contains(Dbkeys.chatStatus))
                  .toList()
                  .cast<Map<String, dynamic>>();
              Map<String?, int?> _lastSpokenAt = _cachedModel!.lastSpokenAt;
              List<Map<String, dynamic>> filtered =
                  List.from(<Map<String, dynamic>>[]);
              groupList.forEach((element) {
                _streamDocSnap.add(element.docmap);
              });
              broadcastList.forEach((element) {
                _streamDocSnap.add(element.docmap);
              });
              _streamDocSnap.sort((a, b) {
                int aTimestamp = a.containsKey(Dbkeys.groupISTYPINGUSERID)
                    ? a[Dbkeys.groupLATESTMESSAGETIME]
                    : a.containsKey(Dbkeys.broadcastBLACKLISTED)
                        ? a[Dbkeys.broadcastLATESTMESSAGETIME]
                        : _lastSpokenAt[a[Dbkeys.id]] ?? 0;
                int bTimestamp = b.containsKey(Dbkeys.groupISTYPINGUSERID)
                    ? b[Dbkeys.groupLATESTMESSAGETIME]
                    : b.containsKey(Dbkeys.broadcastBLACKLISTED)
                        ? b[Dbkeys.broadcastLATESTMESSAGETIME]
                        : _lastSpokenAt[b[Dbkeys.id]] ?? 0;
                return bTimestamp - aTimestamp;
              });

              if (!showHidden) {
                _streamDocSnap.removeWhere((_user) =>
                    !_user.containsKey(Dbkeys.groupISTYPINGUSERID) &&
                    !_user.containsKey(Dbkeys.broadcastBLACKLISTED) &&
                    _isHidden(_user[Dbkeys.id]));
              }
              var observer = Provider.of<Observer>(context, listen: true);
              SpecialLiveConfigData? livedata =
                  Provider.of<SpecialLiveConfigData?>(this.context,
                      listen: false);
              bool isShowCallHistory =
                  observer.userAppSettingsDoc!.iscallsallowed == false
                      ? false
                      : observer.userAppSettingsDoc!.agentCanCallAgents! ==
                              true ||
                          (iAmSecondAdmin(
                                      specialLiveConfigData: livedata,
                                      currentuserid: widget.currentUserID!,
                                      context: context) ==
                                  true &&
                              observer.userAppSettingsDoc!
                                      .secondadminCanCallAgents ==
                                  true);
              return ListView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                // shrinkWrap: true,
                children: [
                  Container(
                      child: _streamDocSnap.isNotEmpty
                          ? Column(
                              children: [
                                StreamBuilder(
                                    stream:
                                        _userQuery.stream.asBroadcastStream(),
                                    builder: (context, snapshot) {
                                      if (_filter.text.isNotEmpty ||
                                          snapshot.hasData) {
                                        filtered =
                                            this._streamDocSnap.where((user) {
                                          return user[Dbkeys.nickname]
                                              .toLowerCase()
                                              .trim()
                                              .contains(new RegExp(r'' +
                                                  _filter.text
                                                      .toLowerCase()
                                                      .trim() +
                                                  ''));
                                        }).toList();
                                        if (filtered.isNotEmpty)
                                          return Text('filtered not empty');
                                        else
                                          return ListView(
                                              physics:
                                                  AlwaysScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              children: [
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            3.5),
                                                    child: Center(
                                                      child: Text(
                                                          getTranslatedForCurrentUser(
                                                              context,
                                                              'xxnosearchresultxx'),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Mycolors.grey,
                                                          )),
                                                    ))
                                              ]);
                                      }
                                      return ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        padding:
                                            EdgeInsets.fromLTRB(0, 10, 0, 80),
                                        itemBuilder: (context, index) {
                                          if (_streamDocSnap[index].containsKey(
                                              Dbkeys.groupISTYPINGUSERID)) {
                                            ///----- Build Group Chat Tile ----
                                            return streamLoadCollections(
                                              stream: FirebaseFirestore.instance
                                                  .collection(DbPaths
                                                      .collectionAgentGroups)
                                                  .doc(_streamDocSnap[index]
                                                      [Dbkeys.groupID])
                                                  .collection(DbPaths
                                                      .collectiongroupChats)
                                                  .where(Dbkeys.groupmsgTIME,
                                                      isGreaterThan:
                                                          _streamDocSnap[index][
                                                              widget
                                                                  .currentUserID])
                                                  .snapshots(),
                                              placeholder: groupMessageTile(
                                                  context: context,
                                                  streamDocSnap: _streamDocSnap,
                                                  index: index,
                                                  currentUserNo:
                                                      widget.currentUserID!,
                                                  prefs: widget.prefs,
                                                  cachedModel: _cachedModel!,
                                                  unRead: 0,
                                                  isGroupChatMuted: _streamDocSnap[
                                                              index]
                                                          .containsKey(Dbkeys
                                                              .groupMUTEDMEMBERS)
                                                      ? _streamDocSnap[index][Dbkeys
                                                              .groupMUTEDMEMBERS]
                                                          .contains(widget
                                                              .currentUserID)
                                                      : false),
                                              noDataWidget: groupMessageTile(
                                                  context: context,
                                                  streamDocSnap: _streamDocSnap,
                                                  index: index,
                                                  currentUserNo:
                                                      widget.currentUserID!,
                                                  prefs: widget.prefs,
                                                  cachedModel: _cachedModel!,
                                                  unRead: 0,
                                                  isGroupChatMuted: _streamDocSnap[
                                                              index]
                                                          .containsKey(Dbkeys
                                                              .groupMUTEDMEMBERS)
                                                      ? _streamDocSnap[index][Dbkeys
                                                              .groupMUTEDMEMBERS]
                                                          .contains(widget
                                                              .currentUserID)
                                                      : false),
                                              onfetchdone: (docs) {
                                                return groupMessageTile(
                                                    context: context,
                                                    streamDocSnap:
                                                        _streamDocSnap,
                                                    index: index,
                                                    currentUserNo:
                                                        widget.currentUserID!,
                                                    prefs: widget.prefs,
                                                    cachedModel: _cachedModel!,
                                                    unRead: docs
                                                        .where((mssg) =>
                                                            mssg[Dbkeys
                                                                .groupmsgSENDBY] !=
                                                            widget
                                                                .currentUserID)
                                                        .toList()
                                                        .length,
                                                    isGroupChatMuted: _streamDocSnap[
                                                                index]
                                                            .containsKey(Dbkeys
                                                                .groupMUTEDMEMBERS)
                                                        ? _streamDocSnap[index][
                                                                Dbkeys
                                                                    .groupMUTEDMEMBERS]
                                                            .contains(widget
                                                                .currentUserID)
                                                        : false);
                                              },
                                            );
                                          } else {
                                            return buildPersonalMessage(
                                                _streamDocSnap
                                                    .elementAt(index));
                                          }
                                        },
                                        itemCount: _streamDocSnap.length,
                                      );
                                    }),
                                isShowCallHistory == true
                                    ? myinkwell(
                                        onTap: () {
                                          final firestoreDataProviderCALLHISTORY =
                                              Provider.of<
                                                      FirestoreDataProviderCALLHISTORY>(
                                                  this.context,
                                                  listen: false);
                                          firestoreDataProviderCALLHISTORY
                                              .fetchNextData(
                                                  'CALLHISTORY',
                                                  FirebaseFirestore.instance
                                                      .collection(DbPaths
                                                          .collectionagents)
                                                      .doc(widget.currentUserID)
                                                      .collection(DbPaths
                                                          .collectioncallhistory)
                                                      .orderBy('TIME',
                                                          descending: true)
                                                      .limit(14),
                                                  true);
                                          pageNavigator(
                                              context,
                                              CallHistoryForAgents(
                                                  userphone:
                                                      widget.currentUserID,
                                                  prefs: widget.prefs));
                                        },
                                        child: Container(
                                            color: Colors.white,
                                            // padding: const EdgeInsets.all(16.0),
                                            child: ListTile(
                                              trailing: Icon(
                                                Icons.keyboard_arrow_right,
                                                color: Mycolors.grey
                                                    .withOpacity(0.8),
                                              ),
                                              title: MtCustomfontBoldSemi(
                                                text:
                                                    getTranslatedForCurrentUser(
                                                        context,
                                                        'xxcallhistoryxx'),
                                                fontsize: 17,
                                              ),
                                              leading: Icon(
                                                Icons.phone_callback_outlined,
                                                color: Mycolors.getColor(
                                                    widget.prefs,
                                                    Colortype.primary.index),
                                              ),
                                            )),
                                      )
                                    : SizedBox(
                                        height: 0,
                                      )
                              ],
                            )
                          : ListView(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.all(0),
                              children: [
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              3.5),
                                      child: Center(
                                        child: Padding(
                                            padding: EdgeInsets.all(30.0),
                                            child: Text(
                                                groupList.length != 0
                                                    ? ''
                                                    : getTranslatedForCurrentUser(
                                                            context,
                                                            'xxstartchatxx')
                                                        .replaceAll(
                                                            '(####)',
                                                            getTranslatedForCurrentUser(
                                                                context,
                                                                'xxagentxx')),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  height: 1.59,
                                                  color: Mycolors.grey,
                                                ))),
                                      )),
                                ])),
                ],
              );
            }));
  }

  Widget buildGroupitem() {
    return Text(
      Dbkeys.groupNAME,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  DataModel? getModel() {
    _cachedModel ??= DataModel(widget.currentUserID, DbPaths.collectionagents);
    return _cachedModel;
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
    if (IsBannerAdShow == true) {
      myBanner.dispose();
    }
  }

  // ignore: unused_element
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocaleForUsers(language.languageCode);
    AppWrapper.setLocale(context, _locale);
    if (widget.currentUserID != null) {
      Future.delayed(const Duration(milliseconds: 800), () {
        FirebaseFirestore.instance
            .collection(DbPaths.collectionagents)
            .doc(widget.currentUserID)
            .update({
          Dbkeys.notificationStringsMap:
              getTranslateNotificationStringsMap(this.context),
        });
      });
    }
    setState(() {
      // seletedlanguage = language;
    });

    await widget.prefs.setBool('islanguageselected', true);
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    final registry = Provider.of<UserRegistry>(this.context, listen: false);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor:
          Mycolors.whiteDynamic, //or set color with: Color(0xFF0000FF)
    ));
    return PickupLayout(
        curentUserID: widget.currentUserID!,
        prefs: widget.prefs,
        scaffold: Utils.getNTPWrappedWidget(ScopedModel<DataModel>(
          model: getModel()!,
          child: ScopedModelDescendant<DataModel>(
              builder: (context, child, _model) {
            _cachedModel = _model;
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  bottom: PreferredSize(
                      preferredSize: new Size(30.0, 50.0),
                      child: new Container(
                        width: MediaQuery.of(context).size.width / 1.0,
                        child: new TabBar(
                          controller: tabController,
                          indicatorWeight: 1.2,
                          unselectedLabelColor: Mycolors.grey,
                          labelColor: Mycolors.getColor(
                              widget.prefs, Colortype.primary.index),
                          indicatorColor: Mycolors.getColor(
                              widget.prefs, Colortype.primary.index),
                          tabs: [
                            new Tab(
                                icon: MtCustomfontBold(
                              isNullColor: true,
                              text: getTranslatedForCurrentUser(
                                      context, 'xxsupporttktsxx')
                                  .toUpperCase(),
                              fontsize: 13,
                              // color: Mycolors.getColor(
                              //     widget.prefs, Colortype.primary.index),
                            )),
                            new Tab(
                                icon: MtCustomfontBold(
                              isNullColor: true,
                              text: getTranslatedForCurrentUser(
                                      context, 'xxagentchatsxx')
                                  .toUpperCase(),
                              fontsize: 13,
                              // color: Mycolors.getColor(
                              //     widget.prefs, Colortype.primary.index),
                            )),
                          ],
                        ),
                      )),
                  elevation: 0.4,
                  backgroundColor: Mycolors.whiteDynamic,
                  // title: Text(
                  //   Appname,
                  //   style: TextStyle(
                  //     color: DESIGN_TYPE == Themetype.whatsapp
                  //         ? Colors.white
                  //         : Mycolors.black,
                  //     fontSize: 16.0,
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  // ),

                  title: MtCustomfontBold(
                    text: getTranslatedForCurrentUser(context, 'xxchatxx'),
                    color: Mycolors.blackDynamic,
                    textalign: TextAlign.center,
                    fontsize: 18,
                  ),
                  centerTitle: true,
                  leading: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      15,
                      10,
                      10,
                      10,
                    ),
                    child: Stack(
                      children: [
                        customCircleAvatar(
                            url: widget.prefs.getString(Dbkeys.photoUrl) ??
                                'photo not found',
                            radius: 20),
                      ],
                    ),
                  ),

                  titleSpacing: -1,
                  actions: <Widget>[
                    Language.languageList().length < 2
                        ? SizedBox()
                        : Container(
                            alignment: Alignment.centerRight,
                            margin: EdgeInsets.only(top: 4),
                            width: 120,
                            child: DropdownButton<Language>(
                              // iconSize: 40,

                              isExpanded: true,
                              underline: SizedBox(),
                              icon: Container(
                                width: 60,
                                height: 30,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.language_outlined,
                                      color: Mycolors.grey,
                                      size: 22,
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Mycolors.grey,
                                      size: 27,
                                    )
                                  ],
                                ),
                              ),
                              onChanged: (Language? language) {
                                _changeLanguage(language!);
                              },
                              items: Language.languageList()
                                  .map<DropdownMenuItem<Language>>(
                                    (e) => DropdownMenuItem<Language>(
                                      value: e,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            IsShowLanguageNameInNativeLanguage ==
                                                    true
                                                ? '' +
                                                    e.name +
                                                    '  ' +
                                                    e.flag +
                                                    ' '
                                                : ' ' +
                                                    e.languageNameInEnglish +
                                                    '  ' +
                                                    e.flag +
                                                    ' ',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                    SizedBox(
                      width: 5,
                    ),
                    tabController.index == 0
                        ? (iAmSecondAdmin(
                                        currentuserid: widget.currentUserID!,
                                        context: context) &&
                                    observer
                                        .userAppSettingsDoc!.secondadminCanCreateTicket!) ||
                                (iAmDepartmentManager(
                                        currentuserid: widget.currentUserID!,
                                        context: context) &&
                                    observer.userAppSettingsDoc!
                                        .departmentManagerCanCreateTicket!) ||
                                (observer.userAppSettingsDoc!
                                        .agentCanCreateTicket ==
                                    true)
                            ? CircleAvatar(
                                radius: 14,
                                backgroundColor: Mycolors.getColor(
                                    widget.prefs, Colortype.primary.index),
                                child: IconButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: tabController.index == 0
                                        ? () {
                                            showTicketOptions(
                                                context: this.context);

                                            registry.fetchUserRegistry(context);
                                            observer
                                                .fetchUserAppSettingsFromFirestore();
                                          }
                                        : () {
                                            showTicketOptions(
                                                context: this.context);

                                            registry.fetchUserRegistry(context);
                                            observer
                                                .fetchUserAppSettingsFromFirestore();
                                          },
                                    icon: Icon(
                                      EvaIcons.plus,
                                      size: 20,
                                      color: Mycolors.white,
                                    )),
                              )
                            : SizedBox()
                        : CircleAvatar(
                            radius: 14,
                            backgroundColor: Mycolors.getColor(
                                widget.prefs, Colortype.primary.index),
                            child: IconButton(
                                padding: EdgeInsets.all(0),
                                onPressed: tabController.index == 0
                                    ? () {
                                        showTicketOptions(
                                            context: this.context);
                                      }
                                    : () {
                                        showTicketOptions(
                                            context: this.context);
                                      },
                                icon: Icon(
                                  EvaIcons.plus,
                                  size: 20,
                                  color: Mycolors.white,
                                )),
                          ),
                    SizedBox(
                      width: 12,
                    ),
                  ],
                ),
                bottomSheet: IsBannerAdShow == true &&
                        observer.isadmobshow == true &&
                        adWidget != null
                    ? Container(
                        height: 60,
                        margin: EdgeInsets.only(
                            bottom: Platform.isIOS == true ? 25.0 : 5, top: 0),
                        child: Center(child: adWidget),
                      )
                    : SizedBox(
                        height: 0,
                      ),
                backgroundColor: Mycolors.backgroundcolor,
                body: TabBarView(
                  controller: tabController,
                  children: [
                    streamLoadCollections(
                        stream: this.ticketsStream,
                        placeholder: Center(
                          child: circularProgress(),
                        ),
                        noDataWidget: noDataWidget(
                            padding: EdgeInsets.fromLTRB(
                                28,
                                MediaQuery.of(context).size.height / 20,
                                28,
                                20),
                            context: context,
                            iconData: LineAwesomeIcons.alternate_ticket,
                            subtitle: getTranslatedForCurrentUser(
                                    context, 'xxallticketswherexx')
                                .replaceAll(
                                    '(####)',
                                    getTranslatedForCurrentUser(
                                        context, 'xxsupporttktxx'))
                                .replaceAll(
                                    '(##)',
                                    getTranslatedForCurrentUser(
                                        context, 'xxagentxx'))
                                .replaceAll(
                                    '(###)',
                                    getTranslatedForCurrentUser(
                                        context, 'xxcustomersxx')),
                            title: getTranslatedForCurrentUser(
                                context, 'xxnosupporttktxx')),
                        onfetchdone: (ticketDocList) {
                          if (ticketDocList.length == 0) {
                            return noDataWidget(
                                padding: EdgeInsets.fromLTRB(
                                    28,
                                    MediaQuery.of(context).size.height / 20,
                                    28,
                                    20),
                                context: context,
                                iconData: LineAwesomeIcons.alternate_ticket,
                                subtitle: getTranslatedForCurrentUser(
                                        context, 'xxallticketswherexx')
                                    .replaceAll(
                                        '(####)',
                                        getTranslatedForCurrentUser(
                                            context, 'xxsupporttktxx'))
                                    .replaceAll(
                                        '(##)',
                                        getTranslatedForCurrentUser(
                                            context, 'xxagentxx'))
                                    .replaceAll(
                                        '(###)',
                                        getTranslatedForCurrentUser(
                                            context, 'xxcustomersxx')),
                                title: getTranslatedForCurrentUser(
                                    context, 'xxnosupporttktxx'));
                          } else {
                            return ListView.builder(
                                // shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                itemCount:
                                    ticketDocList.reversed.toList().length,
                                itemBuilder: (BuildContext context, int i) {
                                  return ticketWidgetForAgents(
                                      currentUserID: widget.currentUserID!,
                                      ticketdoc: ticketDocList[i],
                                      context: this.context,
                                      ontap: (ticketid, customerUID) {
                                        pageNavigator(
                                            this.context,
                                            TicketChatRoom(
                                              agentsListinParticularDepartment: observer
                                                          .userAppSettingsDoc!
                                                          .departmentBasedContent ==
                                                      true
                                                  ? observer.userAppSettingsDoc!
                                                              .departmentList!
                                                              .where((element) =>
                                                                  element[Dbkeys.departmentTitle] ==
                                                                  ticketDocList[i][Dbkeys
                                                                      .ticketDepartmentID])
                                                              .toList()
                                                              .length >
                                                          0
                                                      ? observer
                                                          .userAppSettingsDoc!
                                                          .departmentList!
                                                          .where((element) =>
                                                              element[Dbkeys.departmentTitle] == ticketDocList[i][Dbkeys.ticketDepartmentID])
                                                          .toList()[0][Dbkeys.departmentAgentsUIDList]
                                                      : []
                                                  : [],
                                              ticketTitle: ticketDocList[i]
                                                  [Dbkeys.ticketTitle],
                                              cuurentUserCanSeeAgentNamePhoto: iAmSecondAdmin(
                                                      currentuserid:
                                                          widget.currentUserID!,
                                                      context: context)
                                                  ? observer.userAppSettingsDoc!
                                                      .secondadmincanseeagentnameandphoto!
                                                  : iAmDepartmentManager(
                                                          currentuserid: widget
                                                              .currentUserID!,
                                                          context: context)
                                                      ? observer
                                                          .userAppSettingsDoc!
                                                          .departmentmanagercanseeagentnameandphoto!
                                                      : customerUID ==
                                                              widget
                                                                  .currentUserID
                                                          ? observer
                                                              .userAppSettingsDoc!
                                                              .customercanseeagentnameandphoto!
                                                          : observer
                                                              .userAppSettingsDoc!
                                                              .agentcanseeagentnameandphoto!,
                                              cuurentUserCanSeeCustomerNamePhoto: iAmSecondAdmin(
                                                      currentuserid:
                                                          widget.currentUserID!,
                                                      context: context)
                                                  ? observer.userAppSettingsDoc!
                                                      .secondadmincanseecustomernameandphoto!
                                                  : iAmDepartmentManager(
                                                          currentuserid: widget
                                                              .currentUserID!,
                                                          context: context)
                                                      ? observer
                                                          .userAppSettingsDoc!
                                                          .departmentmanagercanseecustomernameandphoto!
                                                      : observer
                                                          .userAppSettingsDoc!
                                                          .agentcanseecustomernameandphoto!,
                                              currentuserfullname: registry
                                                  .getUserData(context,
                                                      widget.currentUserID!)
                                                  .fullname,
                                              customerUID: customerUID,
                                              currentUserID:
                                                  widget.currentUserID!,
                                              isSharingIntentForwarded: false,
                                              ticketID: ticketid,
                                              prefs: widget.prefs,
                                              model: _cachedModel!,
                                            ));
                                      },
                                      prefs: widget.prefs,
                                      ticket: TicketModel.fromSnapshot(
                                          ticketDocList[i]));
                                });
                          }
                        }),
                    RefreshIndicator(
                      onRefresh: () {
                        isAuthenticating = !isAuthenticating;
                        setState(() {
                          showHidden = !showHidden;
                        });
                        return Future.value(true);
                      },
                      child: _chats(_model.userData, _model.currentUser),
                    ),
                  ],
                ),
              ),
            );
          }),
        )));
  }

  setGroupTitle(int totalmembers, Function(String title) onSet) {
    _textcontroller.clear();
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Consumer<Observer>(
              builder: (context, observer, _child) => Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Container(
                        padding: EdgeInsets.all(22),
                        height: 320,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MtCustomfontBold(
                                text: getTranslatedForCurrentUser(
                                    context, 'xxcreatenewgroupxx'),
                                color: Mycolors.getColor(
                                    widget.prefs, Colortype.secondary.index),
                                fontsize: 17,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  MtCustomfontBoldSemi(
                                    text: getTranslatedForCurrentUser(
                                            context, 'xxselectedxxxx')
                                        .replaceAll(
                                            '(####)',
                                            getTranslatedForCurrentUser(
                                                context, 'xxagentsxx')),
                                    fontsize: 12.5,
                                    color: Mycolors.grey,
                                  ),
                                  SizedBox(height: 5),
                                  MtCustomfontBoldSemi(
                                    text: '$totalmembers',
                                    fontsize: 16,
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              InpuTextBox(
                                focuscolor: Mycolors.getColor(
                                    widget.prefs, Colortype.primary.index),
                                controller: _textcontroller,
                                maxcharacters: Numberlimits.maxTicketTitle,
                                title: getTranslatedForCurrentUser(
                                    context, 'xxgroupnamexx'),
                                hinttext: getTranslatedForCurrentUser(
                                    context, 'xxgroupnamexx'),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              MySimpleButtonWithIcon(
                                iconData: Icons.add,
                                buttoncolor: Mycolors.getColor(
                                    widget.prefs, Colortype.primary.index),
                                buttontext: getTranslatedForCurrentUser(
                                    context, 'xxcreategroupxx'),
                                onpressed: observer.checkIfCurrentUserIsDemo(
                                            widget.currentUserID!) ==
                                        true
                                    ? () {
                                        Utils.toast(getTranslatedForCurrentUser(
                                            context,
                                            'xxxnotalwddemoxxaccountxx'));
                                      }
                                    : () {
                                        onSet(_textcontroller.text.trim());
                                        Navigator.of(context).pop();
                                      },
                              )
                            ])),
                  ));
        });
  }

  showTicketOptions({
    required BuildContext context,
  }) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return tabController.index == 0
              ? Container(
                  padding: EdgeInsets.all(12),
                  height: 100,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.of(context).pop();

                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => SingleSelectUser(
                                          isShowPhonenumber: false,
                                          prefs: widget.prefs,
                                          title: getTranslatedForCurrentUser(
                                                  context, 'xxselectaxxxx')
                                              .replaceAll(
                                                  '(####)',
                                                  getTranslatedForCurrentUser(
                                                      context,
                                                      getTranslatedForCurrentUser(
                                                          context,
                                                          'xxcustomerxx'))),
                                          usertype: Usertype.customer.index,
                                          bannedusers: [widget.currentUserID],
                                          onselected: (customerUID, usermap) {
                                            pageNavigator(
                                                context,
                                                CreateSupportTicket(
                                                  prefs: widget.prefs,
                                                  currentUserID:
                                                      widget.currentUserID!,
                                                  customerUID: customerUID,
                                                ));
                                            // setGroupTitle(name, (title) {
                                            //   createNewTicketByAgent(
                                            //       createdbyuid:
                                            //           widget.currentUserID!,
                                            //       customerid: customerUID,
                                            //       title: title,
                                            //       desc: '');
                                            // });
                                          },
                                        )));
                          },
                          title: MtCustomfontBoldSemi(
                            text: getTranslatedForCurrentUser(
                                    context, 'xxxxnewxx')
                                .replaceAll(
                                    '(####)',
                                    getTranslatedForCurrentUser(
                                        context, 'xxsupporttktxx')),
                            fontsize: 16,
                          ),
                          leading: Icon(
                            Boxicons.bxs_add_to_queue,
                            size: 30,
                            color: Mycolors.getColor(
                                widget.prefs, Colortype.primary.index),
                          ),
                        ),
                      ]))
              : Container(
                  padding: EdgeInsets.all(12),
                  height: 180,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.of(context).pop();
                            pageNavigator(
                                context,
                                AddAgentsToGroup(
                                  prefs: widget.prefs,
                                  biometricEnabled: true,
                                  currentUserID: widget.currentUserID,
                                  isAddingWhileCreatingGroup: true,
                                  model: _cachedModel,
                                ));

                            // Navigator.push(
                            //     context,
                            //     new MaterialPageRoute(
                            //         builder: (context) => MultiSelectUsers(
                            //               isShowPhonenumber: true,
                            //               prefs: widget.prefs,
                            //               title: 'Add Agents to Group',
                            //               usertype: Usertype.agent.index,
                            //               bannedusers: [widget.currentUserID],
                            //               onselected:
                            //                   (selecteduidlist, maplist) {
                            //                 print(
                            //                     'selected users are : $selecteduidlist');
                            //                 print(
                            //                     'selected users are : $maplist');
                            //                setGroupTitle(
                            //                     selecteduidlist.length,
                            //                     (title) {
                            //                   print(title);
                            //                });
                            //               },
                            //             )));
                          },
                          title: MtCustomfontBoldSemi(
                            text: getTranslatedForCurrentUser(
                                    context, 'xxgroupchatxx')
                                .replaceAll(
                                    '(####)',
                                    getTranslatedForCurrentUser(
                                        context, 'xxagentxx')),
                            fontsize: 16,
                          ),
                          leading: Icon(
                            LineAwesomeIcons.user_friends,
                            size: 36,
                            color: Mycolors.getColor(
                                widget.prefs, Colortype.secondary.index),
                          ),
                        ),
                        Divider(
                          height: 0,
                        ),
                        ListTile(
                          onTap: () async {
                            Navigator.of(context).pop();

                            await Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => SingleSelectUser(
                                          isShowPhonenumber: false,
                                          prefs: widget.prefs,
                                          title: getTranslatedForCurrentUser(
                                                  context, 'xxselectaxxxx')
                                              .replaceAll(
                                                  '(####)',
                                                  getTranslatedForCurrentUser(
                                                      context, 'xxagentxx')),
                                          usertype: Usertype.agent.index,
                                          bannedusers: [widget.currentUserID],
                                          onselected:
                                              (agentUID, usermap) async {
                                            Utils.toast(
                                                getTranslatedForCurrentUser(
                                                    context, 'xxplswaitxx'));

                                            await FirebaseFirestore.instance
                                                .collection(
                                                    DbPaths.collectionagents)
                                                .doc(agentUID)
                                                .get()
                                                .then((agent) async {
                                              if (agent.exists) {
                                                await _cachedModel!
                                                    .addUsermap(agent.data());
                                                // ShowLoading().close(
                                                //     context: this.context,
                                                //     key: _keyLoader98);
                                                delayedFunction(
                                                    durationmilliseconds: 200,
                                                    setstatefn: () {
                                                      pageNavigator(
                                                          this.context,
                                                          ChatScreen(
                                                              currentUserID: widget
                                                                  .currentUserID!,
                                                              peerUID: agentUID,
                                                              model:
                                                                  _cachedModel!,
                                                              prefs:
                                                                  widget.prefs,
                                                              unread: 0,
                                                              isSharingIntentForwarded:
                                                                  false));
                                                    });
                                              } else {
                                                // ShowLoading().close(
                                                //     context: this.context,
                                                //     key: _keyLoader98);

                                                Utils.toast(
                                                    "Agent does not exists");
                                              }
                                            }).catchError((e) {
                                              // ShowLoading().close(
                                              //     context: this.context,
                                              //     key: _keyLoader98);
                                              Utils.toast(
                                                  "Error occured while loading agent doc. ERROR- ${e.toString()}");
                                            });
                                          },
                                        )));
                          },
                          title: MtCustomfontBoldSemi(
                            text: getTranslatedForCurrentUser(
                                    context, 'xxindividualxxchatxx')
                                .replaceAll(
                                    '(####)',
                                    getTranslatedForCurrentUser(
                                        context, 'xxagentxx')),
                            fontsize: 16,
                          ),
                          leading: Icon(
                            LineAwesomeIcons.user,
                            size: 33,
                            color: Mycolors.getColor(
                                widget.prefs, Colortype.secondary.index),
                          ),
                        ),
                      ]));
        });
  }
}
