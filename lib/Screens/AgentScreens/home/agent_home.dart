//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/MyRegisteredFonts.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Models/agent_model.dart';
import 'package:thinkcreative_technologies/Models/basic_settings_model_userapp.dart';
import 'package:thinkcreative_technologies/Models/userapp_settings_model.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/allticketsforAgent.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/groupchat/GroupChatPage.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/profile/profileSettings.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/profile/profile.dart';
import 'package:thinkcreative_technologies/Screens/SelectUsers/all_users.dart';
import 'package:thinkcreative_technologies/Screens/department/all_departments_list.dart';
import 'package:thinkcreative_technologies/Utils/Setupdata.dart';
import 'package:thinkcreative_technologies/Screens/landingScreens/login_landing.dart';
import 'package:thinkcreative_technologies/Screens/notifications/user_notifications.dart';
import 'package:thinkcreative_technologies/Screens/splash_screen/splash_screen.dart';
import 'package:thinkcreative_technologies/Screens/webLinkpage/open_web_page.dart';
import 'package:thinkcreative_technologies/Services/Providers/BottomNavigationBarProvider.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/call_history_provider.dart';
import 'package:thinkcreative_technologies/Services/Providers/liveListener.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/Utils/color_light_dark.dart';
import 'package:thinkcreative_technologies/Utils/error_codes.dart';
import 'package:thinkcreative_technologies/Utils/getRolePermission.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as local;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:thinkcreative_technologies/Services/Providers/currentchat_peer.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';

import 'package:thinkcreative_technologies/main.dart';
import 'package:thinkcreative_technologies/Models/DataModel.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Utils/unawaited.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/myinkwell.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/page_navigator.dart';

GlobalKey navBarGlobalKey = GlobalKey(debugLabel: 'bottomAppBar');

class AgentHome extends StatefulWidget {
  AgentHome(
      {required this.currentUserID,
      required this.basicsettings,
      required this.prefs,
      key})
      : super(key: key);
  final String? currentUserID;
  final BasicSettingModelUserApp basicsettings;
  final SharedPreferences prefs;
  @override
  State createState() => new AgentHomeState(currentUserID: this.currentUserID);
}

class AgentHomeState extends State<AgentHome>
    with
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin,
        TickerProviderStateMixin {
  AgentHomeState({Key? key, this.currentUserID}) {
    _filter.addListener(() {
      _userQuery.add(_filter.text.isEmpty ? '' : _filter.text);
    });
  }
  TabController? controllerIfcallallowed;
  TabController? controllerIfcallNotallowed;
  @override
  bool get wantKeepAlive => true;

  bool isFetching = true;
  // List phoneNumberVariants = [];
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      setIsActive();
    else
      setLastSeen();
  }

  void setIsActive() async {
    if (currentUserID != null) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionagents)
          .doc(currentUserID)
          .update(
        {
          Dbkeys.lastSeen: true,
          Dbkeys.lastOnline: DateTime.now().millisecondsSinceEpoch
        },
      ).catchError((e) {});
    }
  }

  void setLastSeen() async {
    if (currentUserID != null) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionagents)
          .doc(currentUserID)
          .update(
        {Dbkeys.lastSeen: DateTime.now().millisecondsSinceEpoch},
      ).catchError((e) {});
    }
  }

  final TextEditingController _filter = new TextEditingController();
  bool isAuthenticating = false;

  StreamSubscription? spokenSubscription;
  List<StreamSubscription> unreadSubscriptions =
      List.from(<StreamSubscription>[]);

  List<StreamController> controllers = List.from(<StreamController>[]);
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  String? deviceid;
  var mapDeviceInfo = {};
  String? maintainanceMessage;
  bool isNotAllowEmulator = false;
  bool? isblockNewlogins = false;
  bool? isApprovalNeededbyAdminForNewUser = false;
  String? accountApprovalMessage = 'Account Approved';
  String? accountstatus;
  String? accountactionmessage;
  String? userPhotourl;
  String? userFullname;
  String? joinedList;
  analyse() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null || widget.currentUserID == null) {
      if (user != null) {
        await FirebaseAuth.instance.signOut();
      }

      // Utils.toast('User is currently signed out!');
      if (widget.currentUserID == null) {
        registerNotification();
        setdeviceinfo();
        getSignedInUserOrRedirect(false);
      } else {
        await logout(context);
      }
    } else {
      setdeviceinfo();
      getModel();

      getSignedInUserOrRedirect(true);

      registerNotification();
    }
  }

  @override
  void initState() {
    controllerIfcallallowed = TabController(length: 4, vsync: this);
    controllerIfcallallowed!.index = 1;
    currentUserID = widget.currentUserID ??
        widget.prefs.getString(Dbkeys.id) ??
        widget.currentUserID;
    listenToNotification();
    super.initState();
    analyse();
    WidgetsBinding.instance.addObserver(this);
    LocalAuthentication().canCheckBiometrics.then((res) {
      if (res) biometricEnabled = true;
    });

    Utils.internetLookUp();
  }

  // detectLocale() async {
  //   await Devicelocale.currentLocale.then((locale) async {
  //     if (locale == 'ja_JP' &&
  //         (widget.prefs.getBool('islanguageselected') == false ||
  //             widget.prefs.getBool('islanguageselected') == null)) {
  //       Locale _locale = await setLocale('ja');
  //       AppWrapper.setLocale(context, _locale);
  //       setStateIfMounted(() {});
  //     }
  //   }).catchError((onError) {
  //     Utils.toast(
  //       'Error occured while fetching Locale :$onError',
  //     );
  //   });
  // }

  incrementSessionCount() async {
    final FirestoreDataProviderCALLHISTORY firestoreDataProviderCALLHISTORY =
        Provider.of<FirestoreDataProviderCALLHISTORY>(context, listen: false);

    firestoreDataProviderCALLHISTORY.fetchNextData(
        'CALLHISTORY',
        FirebaseFirestore.instance
            .collection(DbPaths.collectionagents)
            .doc(currentUserID)
            .collection(DbPaths.collectioncallhistory)
            .orderBy('TIME', descending: true)
            .limit(10),
        true);
    await FirebaseFirestore.instance
        .collection(DbPaths.userapp)
        .doc(DbPaths.docusercount)
        .set(
            Platform.isAndroid
                ? {
                    Dbkeys.totalvisitsANDROID: FieldValue.increment(1),
                  }
                : {
                    Dbkeys.totalvisitsIOS: FieldValue.increment(1),
                  },
            SetOptions(merge: true));
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionagents)
        .doc(currentUserID)
        .set(
            Platform.isAndroid
                ? {
                    Dbkeys.isNotificationStringsMulitilanguageEnabled: true,
                    Dbkeys.notificationStringsMap:
                        getTranslateNotificationStringsMap(context),
                    Dbkeys.totalvisitsANDROID: FieldValue.increment(1),
                  }
                : {
                    Dbkeys.isNotificationStringsMulitilanguageEnabled: true,
                    Dbkeys.notificationStringsMap:
                        getTranslateNotificationStringsMap(context),
                    Dbkeys.totalvisitsIOS: FieldValue.increment(1),
                  },
            SetOptions(merge: true));
  }

  unsubscribeToNotification(String? userUID) async {
    if (userUID != null) {
      await FirebaseMessaging.instance.unsubscribeFromTopic('$userUID');
    }

    await FirebaseMessaging.instance
        .unsubscribeFromTopic(Dbkeys.topicAGENTS)
        .catchError((err) {
      print(err.toString());
    });
    await FirebaseMessaging.instance
        .unsubscribeFromTopic(Platform.isAndroid
            ? Dbkeys.topicUSERSandroid
            : Platform.isIOS
                ? Dbkeys.topicUSERSios
                : Dbkeys.topicUSERSweb)
        .catchError((err) {
      print(err.toString());
    });
  }

  void registerNotification() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  setdeviceinfo() async {
    if (Platform.isAndroid == true) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      setStateIfMounted(() {
        deviceid = androidInfo.id + androidInfo.androidId;
        mapDeviceInfo = {
          Dbkeys.deviceInfoMODEL: androidInfo.model,
          Dbkeys.deviceInfoOS: 'android',
          Dbkeys.deviceInfoISPHYSICAL: androidInfo.isPhysicalDevice,
          Dbkeys.deviceInfoDEVICEID: androidInfo.id,
          Dbkeys.deviceInfoOSID: androidInfo.androidId,
          Dbkeys.deviceInfoOSVERSION: androidInfo.version.baseOS,
          Dbkeys.deviceInfoMANUFACTURER: androidInfo.manufacturer,
          Dbkeys.deviceInfoLOGINTIMESTAMP:
              DateTime.now().millisecondsSinceEpoch,
        };
      });
    } else if (Platform.isIOS == true) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      setStateIfMounted(() {
        deviceid = iosInfo.systemName + iosInfo.model + iosInfo.systemVersion;
        mapDeviceInfo = {
          Dbkeys.deviceInfoMODEL: iosInfo.model,
          Dbkeys.deviceInfoOS: 'ios',
          Dbkeys.deviceInfoISPHYSICAL: iosInfo.isPhysicalDevice,
          Dbkeys.deviceInfoDEVICEID: iosInfo.identifierForVendor,
          Dbkeys.deviceInfoOSID: iosInfo.name,
          Dbkeys.deviceInfoOSVERSION: iosInfo.name,
          Dbkeys.deviceInfoMANUFACTURER: iosInfo.name,
          Dbkeys.deviceInfoLOGINTIMESTAMP:
              DateTime.now().millisecondsSinceEpoch,
        };
      });
    }
  }

  logout(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    await unsubscribeToNotification(widget.currentUserID);
    await widget.prefs.clear();

    FlutterSecureStorage storage = new FlutterSecureStorage();
    // ignore: await_only_futures
    await storage.delete;
    if (currentUserID != null) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionagents)
          .doc(currentUserID)
          .update({
        Dbkeys.lastSeen: DateTime.now().millisecondsSinceEpoch,
        Dbkeys.notificationTokens: [],
        Dbkeys.currentDeviceID: "",
      });
    }

    await firebaseAuth.signOut();
    // Restart.restartApp();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) => AppWrapper(
          loadAttempt: 0,
        ),
      ),
      (Route route) => false,
    );
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    controllers.forEach((controller) {
      controller.close();
    });
    _filter.dispose();
    spokenSubscription?.cancel();
    _userQuery.close();
    cancelUnreadSubscriptions();
    setLastSeen();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void cancelUnreadSubscriptions() {
    unreadSubscriptions.forEach((subscription) {
      subscription.cancel();
    });
  }

  showOverlayCustomNotifcation(
      {String? title,
      String? body,
      IconData? iconData,
      Function? onPress,
      RemoteMessage? remoteMessage}) {
    showOverlayNotification((context) {
      return Material(
        color: Colors.transparent,
        child: myinkwell(
          onTap: onPress == null
              ? () {}
              : () {
                  onPress();
                },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: new ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: new BackdropFilter(
                  filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: SafeArea(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: lighten(Colors.yellow, 0.2),
                                radius: 15,
                                child: Icon(
                                  iconData ?? Icons.notifications,
                                  size: 15,
                                  color: Mycolors.yellow,
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                child: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Mycolors.grey,
                                    ),
                                    onPressed: () {
                                      OverlaySupportEntry.of(context)!
                                          .dismiss();
                                    }),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          MtCustomfontBold(
                            text: remoteMessage != null
                                ? remoteMessage.data['titleMultilang']
                                : title ?? "New notification",
                            color: Mycolors.black,
                            maxlines: 2,
                            lineheight: 1.3,
                            overflow: TextOverflow.ellipsis,
                            fontsize: 17,
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          MtCustomfontRegular(
                            text: remoteMessage != null
                                ? remoteMessage.data['bodyMultilang']
                                : body ?? "",
                            maxlines: 2,
                            fontsize: 14,
                            lineheight: 1.3,
                            color: Mycolors.grey,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Divider()
                        ],
                      ),
                    ),
                  )),
            ),
          ),
        ),
      );
    }, duration: Duration(milliseconds: 3500));
  }

  void listenToNotification() async {
    //FOR ANDROID  background notification is handled here whereas for iOS it is handled at the very top of main.dart ------
    if (Platform.isAndroid) {
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandlerAndroid);
    }
    //------------- ANDROID & iOS  OnMessage callback -----------------------
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // Utils.toast("message on Listen");
      // flutterLocalNotificationsPlugin.cancel(int.tryParse(message.messageId!)!);
      var currentpeer = Provider.of<CurrentChatPeer>(context, listen: false);
      if (message.data.containsKey("notificationEventType")) {
        if (message.data["notificationEventType"] == 'TICKET_EVENTS') {
          if (currentpeer.currentPageID != message.data['ticketIDfiltered']) {
            showOverlayCustomNotifcation(remoteMessage: message);
          }
        } else if (message.data["notificationEventType"] == 'AGENT_MESSAGES') {
          if (currentpeer.currentPageID != message.data['peerid']) {
            showOverlayCustomNotifcation(
                remoteMessage: message, iconData: Icons.message);
          }
        } else if (message.data["notificationEventType"] ==
            'AGENT_GROUP_MESSAGES') {
          if (currentpeer.currentPageID != message.data['groupid']) {
            showOverlayCustomNotifcation(
                remoteMessage: message, iconData: Icons.people);
          }
        } else if (message.data["notificationEventType"] == 'CALLS') {
          if (message.data['title'] == 'Call Ended') {
            flutterLocalNotificationsPlugin.cancelAll();
          } else {
            flutterLocalNotificationsPlugin.cancelAll();
            //   if (message.data['title'] == 'Incoming Audio Call...' ||
            //       message.data['title'] == 'Incoming Video Call...') {
            //     final data = message.data;
            //     final title = data['title'];
            //     final body = data['body'];
            //     final titleMultilang = data['titleMultilang'];
            //     final bodyMultilang = data['bodyMultilang'];
            //     await _showNotificationWithDefaultSound(
            //         title, body, titleMultilang, bodyMultilang);
            //   } else if (message.data['title'] == 'You have new message(s)') {
            //     var currentpeer =
            //         Provider.of<CurrentChatPeer>(context, listen: false);
            //     if (currentpeer.currentPageID != message.data['peerid']) {
            //       // FlutterRingtonePlayer.playNotification();
            //       showOverlayCustomNotifcation(remoteMessage: message);
            //     }
            //   } else {
            //     showOverlayCustomNotifcation(remoteMessage: message);
            //   }
          }
        } else if (message.data["notificationEventType"] ==
            'SINGLE_AGENT_NOTIFICATION') {
          showOverlayCustomNotifcation(remoteMessage: message);
        } else if (message.data["notificationEventType"] ==
            "SINGLE_CUSTOMER_NOTIFICATION") {
          showOverlayCustomNotifcation(remoteMessage: message);
        } else if (message.data["notificationEventType"] ==
            "ALL_ADMIN_NOTIFICATION") {
        } else if (message.data["notificationEventType"] ==
            "ALL_ACTIVITY_NOTIFICATION") {
        } else if (message.data["notificationEventType"] ==
            "ALL_AGENTS_NOTIFICATION") {
          showOverlayCustomNotifcation(remoteMessage: message);
        } else if (message.data["notificationEventType"] ==
            "ALL_CUSTOMERS_NOTIFICATION") {
          showOverlayCustomNotifcation(remoteMessage: message);
        } else {
          if (message.data.containsKey("titleMultilang") &&
              message.data.containsKey("bodyMultilang")) {
            showOverlayCustomNotifcation(remoteMessage: message);
          }
        }
      } else {
        if (message.data.containsKey("titleMultilang") &&
            message.data.containsKey("bodyMultilang")) {
          showOverlayCustomNotifcation(remoteMessage: message);
        } else {
          Utils.toast("New Notification recieved");
        }
      }
    });

    //--------------  ANDROID & iOS  onMessageOpenedApp callback-----When app is back from minimized----------
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // flutterLocalNotificationsPlugin.cancel(int.tryParse(message.messageId!)!);
      // Utils.toast("message on onMessageOpenedApp");
      var currentpeer = Provider.of<CurrentChatPeer>(context, listen: false);
      if (message.data.containsKey("notificationEventType")) {
        if (message.data["notificationEventType"] == 'TICKET_EVENTS') {
          if (currentpeer.currentPageID != message.data['ticketIDfiltered']) {}
        } else if (message.data["notificationEventType"] == 'AGENT_MESSAGES') {
          flutterLocalNotificationsPlugin
              .cancel(int.tryParse(message.messageId!)!);
          if (currentpeer.currentPageID != message.data['peerid']) {}
        } else if (message.data["notificationEventType"] ==
            'AGENT_GROUP_MESSAGES') {
          flutterLocalNotificationsPlugin
              .cancel(int.tryParse(message.messageId!)!);
          if (currentpeer.currentPageID != message.data['groupid']) {
            FirebaseFirestore.instance
                .collection(DbPaths.collectionAgentGroups)
                .doc(message.data['groupid'])
                .get()
                .then((d) {
              pageNavigator(
                  context,
                  GroupChatPage(
                      currentUserno: widget.currentUserID!,
                      groupID: message.data['groupid'],
                      joinedTime: d['${widget.currentUserID}-joinedOn'],
                      model: _cachedModel!,
                      prefs: widget.prefs,
                      isSharingIntentForwarded: false,
                      isCurrentUserMuted:
                          d.data()!.containsKey(Dbkeys.groupMUTEDMEMBERS)
                              ? d[Dbkeys.groupMUTEDMEMBERS]
                                  .contains(widget.currentUserID)
                              : false));
            });
          }
        } else if (message.data["notificationEventType"] == 'CALLS') {
          if (message.data['title'] == 'Call Ended') {
            flutterLocalNotificationsPlugin.cancelAll();
          } else {
            flutterLocalNotificationsPlugin.cancelAll();
          }
        } else if (message.data["notificationEventType"] ==
            'SINGLE_AGENT_NOTIFICATION') {
          flutterLocalNotificationsPlugin
              .cancel(int.tryParse(message.messageId!)!);

          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => UsersNotifiaction(
                        isbackbuttonhide: false,
                        docRef1: FirebaseFirestore.instance
                            .collection(DbPaths.collectionagents)
                            .doc(widget.currentUserID)
                            .collection(DbPaths.agentnotifications)
                            .doc(DbPaths.agentnotifications),
                        docRef2: FirebaseFirestore.instance
                            .collection(DbPaths.userapp)
                            .doc(DbPaths.agentnotifications),
                      )));
        } else if (message.data["notificationEventType"] ==
            "SINGLE_CUSTOMER_NOTIFICATION") {
          flutterLocalNotificationsPlugin
              .cancel(int.tryParse(message.messageId!)!);

          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => UsersNotifiaction(
                        isbackbuttonhide: false,
                        docRef1: FirebaseFirestore.instance
                            .collection(DbPaths.collectioncustomers)
                            .doc(widget.currentUserID)
                            .collection(DbPaths.customernotifications)
                            .doc(DbPaths.customernotifications),
                        docRef2: FirebaseFirestore.instance
                            .collection(DbPaths.userapp)
                            .doc(DbPaths.customernotifications),
                      )));
        } else if (message.data["notificationEventType"] ==
            "ALL_ADMIN_NOTIFICATION") {
        } else if (message.data["notificationEventType"] ==
            "ALL_ACTIVITY_NOTIFICATION") {
        } else if (message.data["notificationEventType"] ==
            "ALL_AGENTS_NOTIFICATION") {
          flutterLocalNotificationsPlugin
              .cancel(int.tryParse(message.messageId!)!);

          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => UsersNotifiaction(
                        isbackbuttonhide: false,
                        docRef1: FirebaseFirestore.instance
                            .collection(DbPaths.collectionagents)
                            .doc(widget.currentUserID)
                            .collection(DbPaths.agentnotifications)
                            .doc(DbPaths.agentnotifications),
                        docRef2: FirebaseFirestore.instance
                            .collection(DbPaths.userapp)
                            .doc(DbPaths.agentnotifications),
                      )));
        } else if (message.data["notificationEventType"] ==
            "ALL_CUSTOMERS_NOTIFICATION") {
          flutterLocalNotificationsPlugin
              .cancel(int.tryParse(message.messageId!)!);
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => UsersNotifiaction(
                        isbackbuttonhide: false,
                        docRef1: FirebaseFirestore.instance
                            .collection(DbPaths.collectioncustomers)
                            .doc(widget.currentUserID)
                            .collection(DbPaths.customernotifications)
                            .doc(DbPaths.customernotifications),
                        docRef2: FirebaseFirestore.instance
                            .collection(DbPaths.userapp)
                            .doc(DbPaths.customernotifications),
                      )));
        } else {
          if (message.data.containsKey("titleMultilang") &&
              message.data.containsKey("bodyMultilang")) {
            showOverlayCustomNotifcation(remoteMessage: message);
          }
        }
      } else {
        if (message.data.containsKey("titleMultilang") &&
            message.data.containsKey("bodyMultilang")) {
          showOverlayCustomNotifcation(remoteMessage: message);
        } else {
          Utils.toast("New Notification recieved");
        }
      }
    });
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message == null) {
      } else {
        // Utils.toast("message on getInitialMessage");
        if (message.data.isNotEmpty) {
          var currentpeer =
              Provider.of<CurrentChatPeer>(context, listen: false);
          if (message.data.containsKey("notificationEventType")) {
            if (message.data["notificationEventType"] == 'TICKET_EVENTS') {
              if (currentpeer.currentPageID !=
                  message.data['ticketIDfiltered']) {}
            } else if (message.data["notificationEventType"] ==
                'AGENT_MESSAGES') {
              flutterLocalNotificationsPlugin
                  .cancel(int.tryParse(message.messageId!)!);
              if (currentpeer.currentPageID != message.data['peerid']) {}
            } else if (message.data["notificationEventType"] ==
                'AGENT_GROUP_MESSAGES') {
              flutterLocalNotificationsPlugin
                  .cancel(int.tryParse(message.messageId!)!);
              if (currentpeer.currentPageID != message.data['groupid']) {
                FirebaseFirestore.instance
                    .collection(DbPaths.collectionAgentGroups)
                    .doc(message.data['groupid'])
                    .get()
                    .then((d) {
                  pageNavigator(
                      context,
                      GroupChatPage(
                          currentUserno: widget.currentUserID!,
                          groupID: message.data['groupid'],
                          joinedTime: d['${widget.currentUserID}-joinedOn'],
                          model: _cachedModel!,
                          prefs: widget.prefs,
                          isSharingIntentForwarded: false,
                          isCurrentUserMuted:
                              d.data()!.containsKey(Dbkeys.groupMUTEDMEMBERS)
                                  ? d[Dbkeys.groupMUTEDMEMBERS]
                                      .contains(widget.currentUserID)
                                  : false));
                });
              }
            } else if (message.data["notificationEventType"] == 'CALLS') {
              if (message.data['title'] == 'Call Ended') {
                flutterLocalNotificationsPlugin.cancelAll();
              } else {
                flutterLocalNotificationsPlugin.cancelAll();
              }
            } else if (message.data["notificationEventType"] ==
                'SINGLE_AGENT_NOTIFICATION') {
              flutterLocalNotificationsPlugin
                  .cancel(int.tryParse(message.messageId!)!);

              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => UsersNotifiaction(
                            isbackbuttonhide: false,
                            docRef1: FirebaseFirestore.instance
                                .collection(DbPaths.collectionagents)
                                .doc(widget.currentUserID)
                                .collection(DbPaths.agentnotifications)
                                .doc(DbPaths.agentnotifications),
                            docRef2: FirebaseFirestore.instance
                                .collection(DbPaths.userapp)
                                .doc(DbPaths.agentnotifications),
                          )));
            } else if (message.data["notificationEventType"] ==
                "SINGLE_CUSTOMER_NOTIFICATION") {
              flutterLocalNotificationsPlugin
                  .cancel(int.tryParse(message.messageId!)!);

              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => UsersNotifiaction(
                            isbackbuttonhide: false,
                            docRef1: FirebaseFirestore.instance
                                .collection(DbPaths.collectioncustomers)
                                .doc(widget.currentUserID)
                                .collection(DbPaths.customernotifications)
                                .doc(DbPaths.customernotifications),
                            docRef2: FirebaseFirestore.instance
                                .collection(DbPaths.userapp)
                                .doc(DbPaths.customernotifications),
                          )));
            } else if (message.data["notificationEventType"] ==
                "ALL_ADMIN_NOTIFICATION") {
            } else if (message.data["notificationEventType"] ==
                "ALL_ACTIVITY_NOTIFICATION") {
            } else if (message.data["notificationEventType"] ==
                "ALL_AGENTS_NOTIFICATION") {
              flutterLocalNotificationsPlugin
                  .cancel(int.tryParse(message.messageId!)!);

              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => UsersNotifiaction(
                            isbackbuttonhide: false,
                            docRef1: FirebaseFirestore.instance
                                .collection(DbPaths.collectionagents)
                                .doc(widget.currentUserID)
                                .collection(DbPaths.agentnotifications)
                                .doc(DbPaths.agentnotifications),
                            docRef2: FirebaseFirestore.instance
                                .collection(DbPaths.userapp)
                                .doc(DbPaths.agentnotifications),
                          )));
            } else if (message.data["notificationEventType"] ==
                "ALL_CUSTOMERS_NOTIFICATION") {
              flutterLocalNotificationsPlugin
                  .cancel(int.tryParse(message.messageId!)!);
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => UsersNotifiaction(
                            isbackbuttonhide: false,
                            docRef1: FirebaseFirestore.instance
                                .collection(DbPaths.collectioncustomers)
                                .doc(widget.currentUserID)
                                .collection(DbPaths.customernotifications)
                                .doc(DbPaths.customernotifications),
                            docRef2: FirebaseFirestore.instance
                                .collection(DbPaths.userapp)
                                .doc(DbPaths.customernotifications),
                          )));
            } else {
              if (message.data.containsKey("titleMultilang") &&
                  message.data.containsKey("bodyMultilang")) {
                showOverlayCustomNotifcation(remoteMessage: message);
              }
            }
          } else {
            if (message.data.containsKey("titleMultilang") &&
                message.data.containsKey("bodyMultilang")) {
              showOverlayCustomNotifcation(remoteMessage: message);
            } else {
              Utils.toast("New Notification recieved");
            }
          }
        }
      }
    });
  }

  DataModel? _cachedModel;
  bool showHidden = false, biometricEnabled = false;

  DataModel? getModel() {
    _cachedModel ??= DataModel(currentUserID, DbPaths.collectionagents);
    return _cachedModel;
  }

  getSignedInUserOrRedirect(bool isloggedIn) async {
    final observer = Provider.of<Observer>(context, listen: false);

    if (isloggedIn == false) {
      await unsubscribeToNotification(widget.currentUserID);
      unawaited(Navigator.pushReplacement(
          context,
          new MaterialPageRoute(
              builder: (context) => new LoginLanding(
                    basicsettings: widget.basicsettings,
                    prefs: widget.prefs,
                    accountApprovalMessage: accountApprovalMessage,
                    isaccountapprovalbyadminneeded:
                        isApprovalNeededbyAdminForNewUser,
                    isblocknewlogins: isblockNewlogins,
                  ))));
    } else {
      await FirebaseFirestore.instance
          .collection(DbPaths.userapp)
          .doc(DbPaths.appsettings)
          .get()
          .then((appsettings) async {
        if (appsettings.exists) {
          observer.setObserver(
              currentUserID: currentUserID,
              isAgent: true,
              userAppSettings: UserAppSettingsModel.fromSnapshot(appsettings));
          await FirebaseFirestore.instance
              .collection(DbPaths.collectionagents)
              .where(Dbkeys.id,
                  isEqualTo: widget.currentUserID ?? currentUserID)
              .get()
              .then((agentDocumentSnapshot) async {
            if (agentDocumentSnapshot.docs.length > 0) {
              AgentModel agent =
                  AgentModel.fromSnapshot(agentDocumentSnapshot.docs[0]);

              if (deviceid != agent.currentDeviceID &&
                  observer.checkIfCurrentUserIsDemo(agent.id) == false) {
                await logout(context);
              } else {
                if (agent.accountstatus != Dbkeys.sTATUSallowed) {
                  setStateIfMounted(() {
                    accountstatus = agent.accountstatus;
                    accountactionmessage = agent.actionmessage;
                  });
                } else {
                  var registry =
                      Provider.of<UserRegistry>(context, listen: false);
                  registry.fetchUserRegistry(context);
                  widget.prefs.setString(
                      Dbkeys.dynamicPhoneORID, Dbkeys.joinedOn.toString());
                  setStateIfMounted(() {
                    currentUserID = agent.id;
                    userFullname = agent.nickname;
                    userPhotourl = agent.photoUrl;

                    isFetching = false;
                  });

                  setIsActive();

                  incrementSessionCount();
                }
              }
            } else {
              showERRORSheet(
                context,
                "6003",
                message:
                    'User does not exists in database. Please contact the developer.',
              );
            }
          }).catchError((e) {
            showERRORSheet(context, "6004",
                message:
                    "Unable to load user. Fetch failed. User Does not exists in database\n\n $e");
          });
        } else {
          showERRORSheet(context, "6005",
              message:
                  "Unable to load app settings. Installation not completed yet.");
        }
      }).catchError((e) {
        showERRORSheet(context, "6006",
            message:
                "Unable to load app settings. Fetch failed. Installation not completed yet.\n\n $e");
      });
    }
  }

  String? currentUserID;

  StreamController<String> _userQuery =
      new StreamController<String>.broadcast();
  // void _changeLanguage(Language language) async {
  //   Locale _locale = await setLocale(language.languageCode);
  //   AppWrapper.setLocale(context, _locale);
  //   if (currentUserID != null) {
  //     Future.delayed(const Duration(milliseconds: 800), () {
  //       FirebaseFirestore.instance
  //           .collection(DbPaths.collectionagents)
  //           .doc(currentUserID)
  //           .update({
  //         Dbkeys.notificationStringsMap:
  //             getTranslateNotificationStringsMap(context),
  //       });
  //     });
  //   }
  //   setStateIfMounted(() {
  //     // seletedlanguage = language;
  //   });

  //   await widget.prefs.setBool('islanguageselected', true);
  // }

  DateTime? currentBackPressTime = DateTime.now();
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime!) > Duration(seconds: 3)) {
      currentBackPressTime = now;
      Utils.toast(getTranslatedForCurrentUser(context, 'xxdoubletapxx'));
      return Future.value(false);
    } else {
      if (!isAuthenticating) setLastSeen();
      return Future.value(true);
    }
  }

  showWebView(String url, String label, bool isHideHeader, bool isHideFooter,
      bool isshowContent, int usertypeindex, bool isSmallLabel) {
    if (isshowContent == false) {
      return BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(
            EvaIcons.homeOutline,
            size: 22,
            color: Mycolors.bottomnavbariconcolor,
          ),
        ),
        label: label,
        activeIcon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(EvaIcons.homeOutline,
              size: 22,
              color: Mycolors.getColor(widget.prefs, Colortype.primary.index)),
        ),
      );
    } else {
      return OpenWebPage(
          currentUserID: widget.currentUserID!,
          prefs: widget.prefs,
          url: url,
          flag: true,
          hideHeader: isHideHeader,
          hideFooter: isHideFooter);
    }
  }

  usernotificationTab(bool isshowContent, bool isSmallLabel) {
    if (isshowContent == false) {
      return BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(
            Boxicons.bx_bell,
            size: 22,
            color: Mycolors.bottomnavbariconcolor,
          ),
        ),
        label: getTranslatedForCurrentUser(context, 'xxalertsxx'),
        activeIcon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(Boxicons.bxs_bell,
              size: 22,
              color: Mycolors.getColor(widget.prefs, Colortype.primary.index)),
        ),
      );
    } else {
      return UsersNotifiaction(
        isbackbuttonhide: true,
        docRef1: FirebaseFirestore.instance
            .collection(DbPaths.collectionagents)
            .doc(widget.currentUserID)
            .collection(DbPaths.agentnotifications)
            .doc(DbPaths.agentnotifications),
        docRef2: FirebaseFirestore.instance
            .collection(DbPaths.userapp)
            .doc(DbPaths.agentnotifications),
      );
    }
  }

  profileTab(bool isshowContent, bool isSmallLabel) {
    if (isshowContent == false) {
      return BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(
            Boxicons.bx_user,
            size: 22,
            color: Mycolors.bottomnavbariconcolor,
          ),
        ),
        label: getTranslatedForCurrentUser(context, 'xxaccountxx'),
        activeIcon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(Boxicons.bxs_user,
              size: 22,
              color: Mycolors.getColor(widget.prefs, Colortype.primary.index)),
        ),
      );
    } else {
      return AgentProfile(
        prefs: widget.prefs,
        onTapLogout: () async {
          await logout(context);
        },
        onTapEditProfile: () {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => AgentProfileSetting(
                        currentUserID: widget.currentUserID!,
                        prefs: widget.prefs,
                        biometricEnabled: biometricEnabled,
                        type: Utils.getAuthenticationType(
                            biometricEnabled, _cachedModel),
                      )));
        },
        currentUserID: currentUserID!,
        biometricEnabled: biometricEnabled,
        type: Utils.getAuthenticationType(biometricEnabled, _cachedModel),
      );
    }
  }

  allusersTab(bool isshowContent, int userTypeIndex, bool ishowcustomerTab,
      bool ishowAgentTab, bool isSmallLabel) {
    if (isshowContent == false) {
      return BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(
            Boxicons.bx_user_check,
            size: 24,
            color: Mycolors.bottomnavbariconcolor,
          ),
        ),
        label: getTranslatedForCurrentUser(context, 'xxusersxx'),
        activeIcon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(Boxicons.bxs_user_check,
              size: 24,
              color: Mycolors.getColor(widget.prefs, Colortype.primary.index)),
        ),
      );
    } else {
      return AllUsers(
          isShowAgentstab: ishowAgentTab,
          isShowCustomerstab: ishowcustomerTab,
          fullname: userFullname ?? '',
          photourl: userPhotourl ?? '',
          prefs: widget.prefs,
          currentUserID: currentUserID,
          isSecuritySetupDone: true);
    }
  }

  allagentsTicketTab(bool isshowContent, int usertypeindex, bool isSmallLabel) {
    if (isshowContent == false) {
      return BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(
            EvaIcons.messageSquareOutline,
            size: 22,
            color: Mycolors.bottomnavbariconcolor,
          ),
        ),
        label: getTranslatedForCurrentUser(context, 'xxchatxx'),
        activeIcon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(EvaIcons.messageSquare,
              size: 22,
              color: Mycolors.getColor(widget.prefs, Colortype.primary.index)),
        ),
      );
    } else {
      return AllTicketForAgent(
          fullname: userFullname ?? '',
          photourl: userPhotourl ?? '',
          prefs: widget.prefs,
          currentUserID: currentUserID,
          isSecuritySetupDone: true);
    }
  }

  alldepartmentsTab(bool isshowContent, bool showonlywhereManager, int usertype,
      bool isSmallLabel) {
    if (isshowContent == false) {
      return BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(
            Icons.location_city_outlined,
            size: 22,
            color: Mycolors.bottomnavbariconcolor,
          ),
        ),
        label: getTranslatedForCurrentUser(context, 'xxdepartmentxx'),
        activeIcon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(Icons.location_city,
              size: 22,
              color: Mycolors.getColor(widget.prefs, Colortype.primary.index)),
        ),
      );
    } else {
      return AllDepartmentList(
        cachedModel: _cachedModel!,
        prefs: widget.prefs,
        showOnlyWhereManager: showonlywhereManager,
        ishidebackbutton: true,
        onbackpressed: () {},
        currentuserid: widget.currentUserID!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // List? managerDoc = Provider.of<List<LiveDataModel>?>(context);
    var provider = Provider.of<BottomNavigationBarProvider>(context);
    var registry = Provider.of<UserRegistry>(context, listen: true);
    var observer = Provider.of<Observer>(context, listen: true);
    SpecialLiveConfigData? livedata =
        Provider.of<SpecialLiveConfigData?>(context, listen: true);

    bool isSmallLabel = true;
    List<Widget> navBaritems = [];
    List<int> tabNamesIndex = [];
    List<int> tabIconsIndex = [];
    List<BottomNavigationBarItem> navBarIcons = [];

    if (this.isFetching == false) {
      //---FOR NAB BAR ITEM -------
      if (isDepartmentBased(context: context)) {
        //------    IF DEPARTMENT BASED -----------#######################---------------------------------------

        if (iAmSecondAdmin(
            specialLiveConfigData: livedata,
            currentuserid: widget.currentUserID!,
            context: context)) {
          ///-----    IF SECOND ADMIN ---------------------------------------------------
          if (observer
                  .userAppSettingsDoc!.secondadminCanViewAllTicketGlobally! ||
              observer.userAppSettingsDoc!.viewowntickets!) {
            //Add tickets tab
            if (!tabNamesIndex.contains(TabName.chat.index)) {
              navBaritems.add(allagentsTicketTab(
                  true, Usertype.secondadmin.index, isSmallLabel));
              tabNamesIndex.add(TabName.chat.index);
            }
          }
          if (observer
                  .userAppSettingsDoc!.secondadminCanViewAllCustomerGlobally! ||
              observer
                  .userAppSettingsDoc!.secondadminCanViewAllAgentsGlobally!) {
            //Add users tab
            if (!tabNamesIndex.contains(TabName.users.index)) {
              navBaritems.add(allusersTab(
                  true,
                  Usertype.agent.index,
                  observer.userAppSettingsDoc!
                      .secondadminCanViewAllCustomerGlobally!,
                  observer
                      .userAppSettingsDoc!.secondadminCanViewAllAgentsGlobally!,
                  isSmallLabel));
              tabNamesIndex.add(TabName.users.index);
            }
          }

          if (observer
                  .userAppSettingsDoc!.secondadminCanViewGlobalDepartments! ||
              observer.userAppSettingsDoc!
                  .secondAdminCanCreateDepartmentGlobally!) {
            //Add department tab

            if (!tabNamesIndex.contains(TabName.departments.index)) {
              navBaritems.add(
                alldepartmentsTab(
                    true, false, Usertype.secondadmin.index, isSmallLabel),
              );
              tabNamesIndex.add(TabName.departments.index);
            }
          }
        }

        ///-----    IF DEPARTMENT MANAGER ---------------------------------------------------
        if (iAmDepartmentManager(
            currentuserid: widget.currentUserID!, context: context)) {
          if (observer.userAppSettingsDoc!
                  .departmentmanagerCanViewAllTicketGlobally! ||
              observer.userAppSettingsDoc!.viewowntickets!) {
            //Add tickets tab

            if (!tabNamesIndex.contains(TabName.chat.index)) {
              navBaritems.add(
                allagentsTicketTab(
                    true, Usertype.departmentmanager.index, isSmallLabel),
              );
              tabNamesIndex.add(TabName.chat.index);
            }
          }
          if (!tabNamesIndex.contains(TabName.departments.index)) {
            navBaritems.add(alldepartmentsTab(
                true, true, Usertype.departmentmanager.index, isSmallLabel));
            tabNamesIndex.add(TabName.departments.index);
          }

          if (observer.userAppSettingsDoc!
                  .departmentmanagerCanViewAllCustomerGlobally! ||
              observer.userAppSettingsDoc!
                  .departmentmanagerCanViewAllAgentsGlobally!) {
            //Add users tab

            if (!tabNamesIndex.contains(TabName.users.index)) {
              navBaritems.add(allusersTab(
                  true,
                  Usertype.departmentmanager.index,
                  observer.userAppSettingsDoc!
                      .departmentmanagerCanViewAllCustomerGlobally!,
                  observer.userAppSettingsDoc!
                      .departmentmanagerCanViewAllAgentsGlobally!,
                  isSmallLabel));
              tabNamesIndex.add(TabName.users.index);
            }
          }
        }

        ///-----    IF REGULAR AGENT ---------------------------------------------------
        if (observer.userAppSettingsDoc!.agentCanViewAllTicketGlobally! ||
            observer.userAppSettingsDoc!.viewowntickets!) {
          //Add tickets tab

          if (!tabNamesIndex.contains(TabName.chat.index)) {
            navBaritems.add(
                allagentsTicketTab(true, Usertype.agent.index, isSmallLabel));
            tabNamesIndex.add(TabName.chat.index);
          }
        }
        if (observer.userAppSettingsDoc!.agentsCanViewAllAgentsGlobally! ||
            observer.userAppSettingsDoc!.agentsCanViewAllCustomerGlobally! ||
            observer.userAppSettingsDoc!.agentsCanSeeOwnDepartmentAgents! ||
            observer.userAppSettingsDoc!.agentsCanSeeOwnDepartmentACustomer!) {
          //Add users tab

          if (!tabNamesIndex.contains(TabName.users.index)) {
            navBaritems.add(allusersTab(
                true,
                Usertype.agent.index,
                observer.userAppSettingsDoc!
                        .agentsCanViewAllCustomerGlobally! ||
                    observer.userAppSettingsDoc!
                        .agentsCanSeeOwnDepartmentACustomer!,
                observer.userAppSettingsDoc!.agentsCanViewAllAgentsGlobally! ||
                    observer
                        .userAppSettingsDoc!.agentsCanSeeOwnDepartmentAgents!,
                isSmallLabel));
            tabNamesIndex.add(TabName.users.index);
          }
        }

        //--common
        navBaritems.add(usernotificationTab(true, isSmallLabel));
        navBaritems.add(profileTab(true, isSmallLabel));
      } else {
        //------    IF NOT DEPARTMENT BASED -----------#######################----------------------------------------

        if (iAmSecondAdmin(
            specialLiveConfigData: livedata,
            currentuserid: widget.currentUserID!,
            context: context)) {
          ///-----    IF SECOND ADMIN ---------------------------------------------------
          if (observer
                  .userAppSettingsDoc!.secondadminCanViewAllTicketGlobally! ||
              observer.userAppSettingsDoc!.viewowntickets!) {
            //Add tickets tab

            if (!tabNamesIndex.contains(TabName.chat.index)) {
              navBaritems.add(allagentsTicketTab(
                  true, Usertype.secondadmin.index, isSmallLabel));
              tabNamesIndex.add(TabName.chat.index);
            }
          }
          if (observer
                  .userAppSettingsDoc!.secondadminCanViewAllCustomerGlobally! ||
              observer
                  .userAppSettingsDoc!.secondadminCanViewAllAgentsGlobally!) {
            //Add users tab

            if (!tabNamesIndex.contains(TabName.users.index)) {
              navBaritems.add(allusersTab(
                  true,
                  Usertype.secondadmin.index,
                  observer.userAppSettingsDoc!
                      .secondadminCanViewAllCustomerGlobally!,
                  observer
                      .userAppSettingsDoc!.secondadminCanViewAllAgentsGlobally!,
                  isSmallLabel));
              tabNamesIndex.add(TabName.users.index);
            }
          }
        }

        ///-----    IF REGULAR AGENT ---------------------------------------------------
        if (observer.userAppSettingsDoc!.agentCanViewAllTicketGlobally! ||
            observer.userAppSettingsDoc!.viewowntickets!) {
          //Add tickets tab

          if (!tabNamesIndex.contains(TabName.chat.index)) {
            navBaritems.add(
                allagentsTicketTab(true, Usertype.agent.index, isSmallLabel));
            tabNamesIndex.add(TabName.chat.index);
          }
        }
        if (observer.userAppSettingsDoc!.agentsCanViewAllAgentsGlobally! ||
            observer.userAppSettingsDoc!.agentsCanViewAllCustomerGlobally!) {
          //Add users tab

          if (!tabNamesIndex.contains(TabName.users.index)) {
            navBaritems.add(allusersTab(
                true,
                Usertype.agent.index,
                observer.userAppSettingsDoc!.agentsCanViewAllCustomerGlobally!,
                observer.userAppSettingsDoc!.agentsCanViewAllAgentsGlobally!,
                isSmallLabel));
            tabNamesIndex.add(TabName.users.index);
          }
        }
        //--common
        navBaritems.add(usernotificationTab(true, isSmallLabel));
        navBaritems.add(profileTab(true, isSmallLabel));
      }

//--
//---FOR NAB BAR ICON -------
      if (isDepartmentBased(context: context)) {
        //-----    IF DEPARTMENT BASED -----------#######################----------------------------------------

        if (iAmSecondAdmin(
            specialLiveConfigData: livedata,
            currentuserid: widget.currentUserID!,
            context: context)) {
          ///-----    IF SECOND ADMIN ---------------------------------------------------
          if (observer
                  .userAppSettingsDoc!.secondadminCanViewAllTicketGlobally! ||
              observer.userAppSettingsDoc!.viewowntickets!) {
            //Add tickets tab
            if (!tabIconsIndex.contains(TabName.chat.index)) {
              navBarIcons.add(allagentsTicketTab(
                  false, Usertype.secondadmin.index, isSmallLabel));
              tabIconsIndex.add(TabName.chat.index);
            }
          }
          if (observer
                  .userAppSettingsDoc!.secondadminCanViewAllCustomerGlobally! ||
              observer
                  .userAppSettingsDoc!.secondadminCanViewAllAgentsGlobally!) {
            //Add users tab
            if (!tabIconsIndex.contains(TabName.users.index)) {
              navBarIcons.add(allusersTab(
                  false,
                  Usertype.agent.index,
                  observer.userAppSettingsDoc!
                      .secondadminCanViewAllCustomerGlobally!,
                  observer
                      .userAppSettingsDoc!.secondadminCanViewAllAgentsGlobally!,
                  isSmallLabel));
              tabIconsIndex.add(TabName.users.index);
            }
          }

          if (observer
                  .userAppSettingsDoc!.secondadminCanViewGlobalDepartments! ||
              observer.userAppSettingsDoc!
                  .secondAdminCanCreateDepartmentGlobally!) {
            //Add department tab

            if (!tabIconsIndex.contains(TabName.departments.index)) {
              navBarIcons.add(
                alldepartmentsTab(
                    false, false, Usertype.secondadmin.index, isSmallLabel),
              );
              tabIconsIndex.add(TabName.departments.index);
            }
          }
        }

        ///-----    IF DEPARTMENT MANAGER ---------------------------------------------------
        if (iAmDepartmentManager(
            currentuserid: widget.currentUserID!, context: context)) {
          if (observer.userAppSettingsDoc!
                  .departmentmanagerCanViewAllTicketGlobally! ||
              observer.userAppSettingsDoc!.viewowntickets!) {
            //Add tickets tab

            if (!tabIconsIndex.contains(TabName.chat.index)) {
              navBarIcons.add(
                allagentsTicketTab(
                    false, Usertype.departmentmanager.index, isSmallLabel),
              );
              tabIconsIndex.add(TabName.chat.index);
            }
          }
          if (!tabIconsIndex.contains(TabName.departments.index)) {
            navBarIcons.add(alldepartmentsTab(
                false, true, Usertype.departmentmanager.index, isSmallLabel));
            tabIconsIndex.add(TabName.departments.index);
          }

          if (observer.userAppSettingsDoc!
                  .departmentmanagerCanViewAllCustomerGlobally! ||
              observer.userAppSettingsDoc!
                  .departmentmanagerCanViewAllAgentsGlobally!) {
            //Add users tab

            if (!tabIconsIndex.contains(TabName.users.index)) {
              navBarIcons.add(allusersTab(
                  false,
                  Usertype.departmentmanager.index,
                  observer.userAppSettingsDoc!
                      .departmentmanagerCanViewAllCustomerGlobally!,
                  observer.userAppSettingsDoc!
                      .departmentmanagerCanViewAllAgentsGlobally!,
                  isSmallLabel));
              tabIconsIndex.add(TabName.users.index);
            }
          }
        }

        ///-----    IF REGULAR AGENT ---------------------------------------------------
        if (observer.userAppSettingsDoc!.agentCanViewAllTicketGlobally! ||
            observer.userAppSettingsDoc!.viewowntickets!) {
          //Add tickets tab

          if (!tabIconsIndex.contains(TabName.chat.index)) {
            navBarIcons.add(
                allagentsTicketTab(false, Usertype.agent.index, isSmallLabel));
            tabIconsIndex.add(TabName.chat.index);
          }
        }
        if (observer.userAppSettingsDoc!.agentsCanViewAllAgentsGlobally! ||
            observer.userAppSettingsDoc!.agentsCanViewAllCustomerGlobally! ||
            observer.userAppSettingsDoc!.agentsCanSeeOwnDepartmentAgents! ||
            observer.userAppSettingsDoc!.agentsCanSeeOwnDepartmentACustomer!) {
          //Add users tab

          if (!tabIconsIndex.contains(TabName.users.index)) {
            navBarIcons.add(allusersTab(
                false,
                Usertype.agent.index,
                observer.userAppSettingsDoc!
                        .agentsCanViewAllCustomerGlobally! ||
                    observer.userAppSettingsDoc!
                        .agentsCanSeeOwnDepartmentACustomer!,
                observer.userAppSettingsDoc!.agentsCanViewAllAgentsGlobally! ||
                    observer
                        .userAppSettingsDoc!.agentsCanSeeOwnDepartmentAgents!,
                isSmallLabel));
            tabIconsIndex.add(TabName.users.index);
          }
        }

        //--common
        navBarIcons.add(usernotificationTab(false, isSmallLabel));
        navBarIcons.add(profileTab(false, isSmallLabel));
      } else {
        //------    IF NOT DEPARTMENT BASED -----------#######################----------------------------------------

        if (iAmSecondAdmin(
            specialLiveConfigData: livedata,
            currentuserid: widget.currentUserID!,
            context: context)) {
          ///-----    IF SECOND ADMIN ---------------------------------------------------
          if (observer
                  .userAppSettingsDoc!.secondadminCanViewAllTicketGlobally! ||
              observer.userAppSettingsDoc!.viewowntickets!) {
            //Add tickets tab

            if (!tabIconsIndex.contains(TabName.chat.index)) {
              navBarIcons.add(allagentsTicketTab(
                  false, Usertype.secondadmin.index, isSmallLabel));
              tabIconsIndex.add(TabName.chat.index);
            }
          }
          if (observer
                  .userAppSettingsDoc!.secondadminCanViewAllCustomerGlobally! ||
              observer
                  .userAppSettingsDoc!.secondadminCanViewAllAgentsGlobally!) {
            //Add users tab

            if (!tabIconsIndex.contains(TabName.users.index)) {
              navBarIcons.add(allusersTab(
                  false,
                  Usertype.secondadmin.index,
                  observer.userAppSettingsDoc!
                      .secondadminCanViewAllCustomerGlobally!,
                  observer
                      .userAppSettingsDoc!.secondadminCanViewAllAgentsGlobally!,
                  isSmallLabel));
              tabIconsIndex.add(TabName.users.index);
            }
          }
        }

        ///-----    IF REGULAR AGENT ---------------------------------------------------
        if (observer.userAppSettingsDoc!.agentCanViewAllTicketGlobally! ||
            observer.userAppSettingsDoc!.viewowntickets!) {
          //Add tickets tab

          if (!tabIconsIndex.contains(TabName.chat.index)) {
            navBarIcons.add(
                allagentsTicketTab(false, Usertype.agent.index, isSmallLabel));
            tabIconsIndex.add(TabName.chat.index);
          }
        }
        if (observer.userAppSettingsDoc!.agentsCanViewAllAgentsGlobally! ||
            observer.userAppSettingsDoc!.agentsCanViewAllCustomerGlobally!) {
          //Add users tab

          if (!tabIconsIndex.contains(TabName.users.index)) {
            navBarIcons.add(allusersTab(
                false,
                Usertype.agent.index,
                observer.userAppSettingsDoc!.agentsCanViewAllCustomerGlobally!,
                observer.userAppSettingsDoc!.agentsCanViewAllAgentsGlobally!,
                isSmallLabel));
            tabIconsIndex.add(TabName.users.index);
          }
        }
        //--common
        navBarIcons.add(usernotificationTab(false, isSmallLabel));
        navBarIcons.add(profileTab(false, isSmallLabel));
      }

      if (observer.userAppSettingsDoc!.agentsLandingCustomTabURL != "") {
        int customtabIndex =
            observer.userAppSettingsDoc!.agentTabIndexPosition!;

        if (customtabIndex == 0) {
          navBaritems.insert(
              0,
              showWebView(
                  observer.userAppSettingsDoc!.agentsLandingCustomTabURL!,
                  observer.userAppSettingsDoc!.agentCustomTabLabel == "" ||
                          observer.userAppSettingsDoc!.agentCustomTabLabel!
                                  .trim()
                                  .toLowerCase() ==
                              "home"
                      ? getTranslatedForCurrentUser(context, 'xxhomexx')
                      : observer.userAppSettingsDoc!.agentCustomTabLabel!,
                  !observer.userAppSettingsDoc!.isShowHeaderAgentsTab!,
                  !observer.userAppSettingsDoc!.isShowFooterAgentsTab!,
                  true,
                  1,
                  isSmallLabel));
          navBarIcons.insert(
              0,
              showWebView(
                  observer.userAppSettingsDoc!.agentsLandingCustomTabURL!,
                  observer.userAppSettingsDoc!.agentCustomTabLabel == "" ||
                          observer.userAppSettingsDoc!.agentCustomTabLabel!
                                  .trim()
                                  .toLowerCase() ==
                              "home"
                      ? getTranslatedForCurrentUser(context, 'xxhomexx')
                      : observer.userAppSettingsDoc!.agentCustomTabLabel!,
                  !observer.userAppSettingsDoc!.isShowHeaderAgentsTab!,
                  !observer.userAppSettingsDoc!.isShowFooterAgentsTab!,
                  false,
                  1,
                  isSmallLabel));
        } else if (customtabIndex == 1) {
          navBaritems.insert(
              1,
              showWebView(
                  observer.userAppSettingsDoc!.agentsLandingCustomTabURL!,
                  observer.userAppSettingsDoc!.agentCustomTabLabel == "" ||
                          observer.userAppSettingsDoc!.agentCustomTabLabel!
                                  .trim()
                                  .toLowerCase() ==
                              "home"
                      ? getTranslatedForCurrentUser(context, 'xxhomexx')
                      : observer.userAppSettingsDoc!.agentCustomTabLabel!,
                  !observer.userAppSettingsDoc!.isShowHeaderAgentsTab!,
                  !observer.userAppSettingsDoc!.isShowFooterAgentsTab!,
                  true,
                  1,
                  isSmallLabel));
          navBarIcons.insert(
              1,
              showWebView(
                  observer.userAppSettingsDoc!.agentsLandingCustomTabURL!,
                  observer.userAppSettingsDoc!.agentCustomTabLabel == "" ||
                          observer.userAppSettingsDoc!.agentCustomTabLabel!
                                  .trim()
                                  .toLowerCase() ==
                              "home"
                      ? getTranslatedForCurrentUser(context, 'xxhomexx')
                      : observer.userAppSettingsDoc!.agentCustomTabLabel!,
                  !observer.userAppSettingsDoc!.isShowHeaderAgentsTab!,
                  !observer.userAppSettingsDoc!.isShowFooterAgentsTab!,
                  false,
                  1,
                  isSmallLabel));
        } else if (customtabIndex == 2) {
          int l = navBaritems.length;
          navBaritems.insert(
              l - 1,
              showWebView(
                  observer.userAppSettingsDoc!.agentsLandingCustomTabURL!,
                  observer.userAppSettingsDoc!.agentCustomTabLabel == "" ||
                          observer.userAppSettingsDoc!.agentCustomTabLabel!
                                  .trim()
                                  .toLowerCase() ==
                              "home"
                      ? getTranslatedForCurrentUser(context, 'xxhomexx')
                      : observer.userAppSettingsDoc!.agentCustomTabLabel!,
                  !observer.userAppSettingsDoc!.isShowHeaderAgentsTab!,
                  !observer.userAppSettingsDoc!.isShowFooterAgentsTab!,
                  true,
                  1,
                  isSmallLabel));
          navBarIcons.insert(
              l - 1,
              showWebView(
                  observer.userAppSettingsDoc!.agentsLandingCustomTabURL!,
                  observer.userAppSettingsDoc!.agentCustomTabLabel == "" ||
                          observer.userAppSettingsDoc!.agentCustomTabLabel!
                                  .trim()
                                  .toLowerCase() ==
                              "home"
                      ? getTranslatedForCurrentUser(context, 'xxhomexx')
                      : observer.userAppSettingsDoc!.agentCustomTabLabel!,
                  !observer.userAppSettingsDoc!.isShowHeaderAgentsTab!,
                  !observer.userAppSettingsDoc!.isShowFooterAgentsTab!,
                  false,
                  1,
                  isSmallLabel));
        } else if (customtabIndex == 3) {
          int l = navBaritems.length;
          navBaritems.insert(
              l,
              showWebView(
                  observer.userAppSettingsDoc!.agentsLandingCustomTabURL!,
                  observer.userAppSettingsDoc!.agentCustomTabLabel == "" ||
                          observer.userAppSettingsDoc!.agentCustomTabLabel!
                                  .trim()
                                  .toLowerCase() ==
                              "home"
                      ? getTranslatedForCurrentUser(context, 'xxhomexx')
                      : observer.userAppSettingsDoc!.agentCustomTabLabel!,
                  !observer.userAppSettingsDoc!.isShowHeaderAgentsTab!,
                  !observer.userAppSettingsDoc!.isShowFooterAgentsTab!,
                  true,
                  1,
                  isSmallLabel));
          navBarIcons.insert(
              l,
              showWebView(
                  observer.userAppSettingsDoc!.agentsLandingCustomTabURL!,
                  observer.userAppSettingsDoc!.agentCustomTabLabel == "" ||
                          observer.userAppSettingsDoc!.agentCustomTabLabel!
                                  .trim()
                                  .toLowerCase() ==
                              "home"
                      ? getTranslatedForCurrentUser(context, 'xxhomexx')
                      : observer.userAppSettingsDoc!.agentCustomTabLabel!,
                  !observer.userAppSettingsDoc!.isShowHeaderAgentsTab!,
                  !observer.userAppSettingsDoc!.isShowFooterAgentsTab!,
                  false,
                  1,
                  isSmallLabel));
        } else {}
      }
    }

    if (navBaritems.length > 5) {
      isSmallLabel = false;
    }

    return isNotAllowEmulator == true
        ? errorScreen(context, '',
            ' ${getTranslatedForCurrentUser(this.context, 'xxemulatornotallowedxx')}')
        : accountstatus != null
            ? errorScreen(context, accountstatus, accountactionmessage,
                ontapprofile: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => AgentProfile(
                              prefs: widget.prefs,
                              onTapLogout: () async {
                                await logout(context);
                              },
                              onTapEditProfile: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) =>
                                            AgentProfileSetting(
                                              currentUserID:
                                                  widget.currentUserID!,
                                              prefs: widget.prefs,
                                              biometricEnabled:
                                                  biometricEnabled,
                                              type: Utils.getAuthenticationType(
                                                  biometricEnabled,
                                                  _cachedModel),
                                            )));
                              },
                              currentUserID: currentUserID!,
                              biometricEnabled: biometricEnabled,
                              type: Utils.getAuthenticationType(
                                  biometricEnabled, _cachedModel),
                            )));
              })
            : maintainanceMessage != null
                ? errorScreen(
                    context,
                    getTranslatedForCurrentUser(context, 'xxappundercxx'),
                    maintainanceMessage)
                : isFetching == true || widget.currentUserID == null
                    ? Splashscreen()
                    : PickupLayout(
                        curentUserID: widget.currentUserID!,
                        prefs: widget.prefs,
                        scaffold: Utils.getNTPWrappedWidget(WillPopScope(
                            onWillPop: onWillPop,
                            child: Scaffold(
                              body: navBaritems[provider.currentInd],
                              bottomNavigationBar: BottomNavigationBar(
                                elevation: 1.9,
                                selectedItemColor: Mycolors.getColor(
                                    widget.prefs, Colortype.primary.index),
                                backgroundColor: Colors.white,
                                type: BottomNavigationBarType.fixed,
                                unselectedLabelStyle: TextStyle(
                                    fontFamily: MyRegisteredFonts.semiBold),
                                selectedLabelStyle: TextStyle(
                                    fontFamily: MyRegisteredFonts.semiBold),
                                selectedFontSize:
                                    isSmallLabel == true ? 12 : 10.0,
                                unselectedFontSize:
                                    isSmallLabel == true ? 12 : 10,
                                unselectedItemColor:
                                    Mycolors.bottomnavbariconcolor,
                                key: navBarGlobalKey,
                                currentIndex: provider.currentInd,
                                onTap: (index) {
                                  provider.setcurrentIndex(index);
                                  observer.setisLoadedWebViewFirstpage(false);
                                  registry.fetchUserRegistry(context);
                                  observer.fetchUserAppSettingsFromFirestore();
                                },
                                items: navBarIcons,
                              ),
                            ))));
  }
}

Future<dynamic> myBackgroundMessageHandlerAndroid(RemoteMessage message) async {
  if (message.data['title'] == 'Call Ended' ||
      message.data['title'] == 'Missed Call') {
    flutterLocalNotificationsPlugin.cancelAll();
    final data = message.data;
    final titleMultilang = data['titleMultilang'];
    final bodyMultilang = data['bodyMultilang'];

    await _showNotificationWithDefaultSound(message.data['title'],
        message.data['body'], titleMultilang, bodyMultilang);
  } else {
    if (message.data['title'] == 'You have new message(s)' ||
        message.data['title'] == 'New message in Group') {
      //-- need not to do anythig for these message type as it will be automatically popped up.

    } else if (message.data['title'] == 'Incoming Audio Call...' ||
        message.data['title'] == 'Incoming Video Call...') {
      final data = message.data;
      final title = data['title'];
      final body = data['body'];
      final titleMultilang = data['titleMultilang'];
      final bodyMultilang = data['bodyMultilang'];

      await _showNotificationWithDefaultSound(
          title, body, titleMultilang, bodyMultilang);
    }
  }

  return Future<void>.value();
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future _showNotificationWithDefaultSound(String? title, String? message,
    String? titleMultilang, String? bodyMultilang) async {
  if (Platform.isAndroid) {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  var initializationSettingsAndroid =
      new AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  var androidPlatformChannelSpecifics =
      title == 'Missed Call' || title == 'Call Ended'
          ? local.AndroidNotificationDetails('channel_id', 'channel_name',
              importance: local.Importance.max,
              priority: local.Priority.high,
              sound: RawResourceAndroidNotificationSound('whistle2'),
              playSound: true,
              ongoing: true,
              visibility: NotificationVisibility.public,
              timeoutAfter: 28000)
          : local.AndroidNotificationDetails('channel_id', 'channel_name',
              sound: RawResourceAndroidNotificationSound('ringtone'),
              playSound: true,
              ongoing: true,
              importance: local.Importance.max,
              priority: local.Priority.high,
              visibility: NotificationVisibility.public,
              timeoutAfter: 28000);
  var iOSPlatformChannelSpecifics = local.IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    sound:
        title == 'Missed Call' || title == 'Call Ended' ? '' : 'ringtone.caf',
    presentSound: true,
  );
  var platformChannelSpecifics = local.NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(
    0,
    '$titleMultilang',
    '$bodyMultilang',
    platformChannelSpecifics,
    payload: 'payload',
  )
      .catchError((err) {
    print('ERROR DISPLAYING NOTIFICATION: $err');
  });
}

Widget errorScreen(BuildContext context, String? title, String? subtitle,
    {Function? ontapprofile}) {
  return Scaffold(
    backgroundColor: Mycolors.primary,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_outlined,
              size: 60,
              color: Colors.yellowAccent,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              '$title'.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              '$subtitle',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 50,
            ),
            title == "pending" || title == "blocked"
                ? MySimpleButtonWithIcon(
                    onpressed: ontapprofile,
                    buttoncolor: Mycolors.black,
                    buttontext:
                        getTranslatedForCurrentUser(context, 'xxmyprofilexx'),
                  )
                : SizedBox()
          ],
        ),
      ),
    ),
  );
}
