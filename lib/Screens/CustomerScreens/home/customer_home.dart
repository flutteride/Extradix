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
import 'package:thinkcreative_technologies/Models/customer_model.dart';
import 'package:thinkcreative_technologies/Models/basic_settings_model_userapp.dart';
import 'package:thinkcreative_technologies/Models/userapp_settings_model.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/groupchat/GroupChatPage.dart';
import 'package:thinkcreative_technologies/Screens/CustomerScreens/profile/profile.dart';
import 'package:thinkcreative_technologies/Screens/CustomerScreens/profile/profileSettings.dart';
import 'package:thinkcreative_technologies/Screens/CustomerScreens/tickets/customer_tickets.dart';
import 'package:thinkcreative_technologies/Utils/Setupdata.dart';
import 'package:thinkcreative_technologies/Screens/landingScreens/login_landing.dart';
import 'package:thinkcreative_technologies/Screens/notifications/user_notifications.dart';
import 'package:thinkcreative_technologies/Screens/splash_screen/splash_screen.dart';
import 'package:thinkcreative_technologies/Screens/webLinkpage/open_web_page.dart';
import 'package:thinkcreative_technologies/Services/Providers/BottomNavigationBarProvider.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/call_history_provider.dart';
import 'package:thinkcreative_technologies/Services/Providers/exploreProvider.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/Localization/language.dart';
import 'package:thinkcreative_technologies/Utils/color_light_dark.dart';
import 'package:thinkcreative_technologies/Utils/error_codes.dart';
import 'package:thinkcreative_technologies/Utils/phonenumberVariantsGenerator.dart';
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

class CustomerHome extends StatefulWidget {
  CustomerHome(
      {required this.currentUserID,
      required this.basicsettings,
      required this.prefs,
      key})
      : super(key: key);
  final String? currentUserID;
  final BasicSettingModelUserApp basicsettings;
  final SharedPreferences prefs;
  @override
  State createState() =>
      new CustomerHomeState(currentUserID: this.currentUserID);
}

class CustomerHomeState extends State<CustomerHome>
    with
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin,
        TickerProviderStateMixin {
  CustomerHomeState({Key? key, this.currentUserID}) {
    _filter.addListener(() {
      _userQuery.add(_filter.text.isEmpty ? '' : _filter.text);
    });
  }
  // TabController? controllerIfcallallowed;
  // TabController? controllerIfcallNotallowed;
  @override
  bool get wantKeepAlive => true;

  bool isFetching = true;
  List phoneNumberVariants = [];
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
          .collection(DbPaths.collectioncustomers)
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
          .collection(DbPaths.collectioncustomers)
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
      // Utils.toast('User is signed in!');
      getSignedInUserOrRedirect(true);

      registerNotification();
    }
  }

  @override
  void initState() {
    // controllerIfcallallowed = TabController(length: 3, vsync: this);
    // controllerIfcallallowed!.index = 1;
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
    // final explore = Provider.of<ExploreProvider>(context, listen: false);

    firestoreDataProviderCALLHISTORY.fetchNextData(
        'CALLHISTORY',
        FirebaseFirestore.instance
            .collection(DbPaths.collectioncustomers)
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
        .collection(DbPaths.collectioncustomers)
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
        .unsubscribeFromTopic(Dbkeys.topicCUSTOMERS)
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
    final explore = Provider.of<ExploreProvider>(context, listen: false);
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    await unsubscribeToNotification(widget.currentUserID);
    explore.reset();

    await widget.prefs.clear();

    FlutterSecureStorage storage = new FlutterSecureStorage();
    // ignore: await_only_futures
    await storage.delete;
    if (currentUserID != null) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectioncustomers)
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
                                : title ??
                                    getTranslatedForCurrentUser(
                                        context, 'xxnewnotificationsxx'),
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
          Utils.toast(
              getTranslatedForCurrentUser(context, 'xxnewnotificationsxx'));
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
              Utils.toast(
                  getTranslatedForCurrentUser(context, 'xxnewnotificationsxx'));
            }
          }
        }
      }
    });
  }

  DataModel? _cachedModel;
  bool showHidden = false, biometricEnabled = false;

  DataModel? getModel() {
    _cachedModel ??= DataModel(currentUserID, DbPaths.collectioncustomers);
    return _cachedModel;
  }

  getSignedInUserOrRedirect(bool isloggedIn) async {
    final observer = Provider.of<Observer>(context, listen: false);
    final registry = Provider.of<UserRegistry>(context, listen: false);

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
                    // title: getTranslatedForCurrentUser(context, 'signin'),
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
              isAgent: false,
              userAppSettings: UserAppSettingsModel.fromSnapshot(appsettings));
          await FirebaseFirestore.instance
              .collection(DbPaths.collectioncustomers)
              .where(Dbkeys.id,
                  isEqualTo: widget.currentUserID ?? currentUserID)
              .get()
              .then((customerDocumentSnapshot) async {
            if (customerDocumentSnapshot.docs.length > 0) {
              CustomerModel customer =
                  CustomerModel.fromSnapshot(customerDocumentSnapshot.docs[0]);

              if (deviceid != customer.currentDeviceID &&
                  observer.checkIfCurrentUserIsDemo(customer.id) == false) {
                await logout(context);
              } else {
                if (customer.accountstatus != Dbkeys.sTATUSallowed) {
                  setStateIfMounted(() {
                    accountstatus = customer.accountstatus;
                    accountactionmessage = customer.actionmessage;
                  });
                } else {
                  registry.fetchUserRegistry(context);
                  widget.prefs.setString(
                      Dbkeys.dynamicPhoneORID, Dbkeys.joinedOn.toString());
                  setStateIfMounted(() {
                    currentUserID = customer.id;
                    userFullname = customer.nickname;
                    userPhotourl = customer.photoUrl;
                    phoneNumberVariants = phoneNumberVariantsList(
                        countrycode: customer.countryCode,
                        phonenumber: customer.phoneRaw);
                    isFetching = false;
                  });

                  setIsActive();

                  incrementSessionCount();
                }
              }
            } else {
              showERRORSheet(
                context,
                "6009",
                message:
                    'User does not exists in database. Please contact the developer.',
              );
            }
          }).catchError((e) {
            showERRORSheet(context, "6010",
                message:
                    "Unable to load user. Fetch failed. User Does not exists in database");
          });
        } else {
          showERRORSheet(context, "6011",
              message:
                  "Unable to load app settings. Installation not completed yet.");
        }
      }).catchError((e) {
        showERRORSheet(context, "6012",
            message:
                "Unable to load app settings. Fetch failed. Installation not completed yet.");
      });
    }
  }

  String? currentUserID;

  StreamController<String> _userQuery =
      new StreamController<String>.broadcast();
  // ignore: unused_element
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocaleForUsers(language.languageCode);
    AppWrapper.setLocale(context, _locale);
    if (currentUserID != null) {
      Future.delayed(const Duration(milliseconds: 800), () {
        FirebaseFirestore.instance
            .collection(DbPaths.collectioncustomers)
            .doc(currentUserID)
            .update({
          Dbkeys.notificationStringsMap:
              getTranslateNotificationStringsMap(context),
        });
      });
    }
    setStateIfMounted(() {
      // seletedlanguage = language;
    });

    await widget.prefs.setBool('islanguageselected', true);
  }

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // List? managerDoc = Provider.of<List<LiveDataModel>?>(context);
    var registry = Provider.of<UserRegistry>(context, listen: true);
    var provider = Provider.of<BottomNavigationBarProvider>(context);
    var observer = Provider.of<Observer>(context);
    List<Widget> navBarPages = widget.currentUserID == null
        ? []
        : <Widget>[
            CustomerTickets(
                phonevariants: this.phoneNumberVariants,
                fullname: userFullname ?? '',
                photourl: userPhotourl ?? '',
                prefs: widget.prefs,
                currentUserID: currentUserID,
                isSecuritySetupDone: true),
            UsersNotifiaction(
              isbackbuttonhide: true,
              docRef1: FirebaseFirestore.instance
                  .collection(DbPaths.collectioncustomers)
                  .doc(widget.currentUserID)
                  .collection(DbPaths.customernotifications)
                  .doc(DbPaths.customernotifications),
              docRef2: FirebaseFirestore.instance
                  .collection(DbPaths.userapp)
                  .doc(DbPaths.customernotifications),
            ),
            CustomerProfile(
              prefs: widget.prefs,
              onTapLogout: () async {
                await logout(context);
              },
              onTapEditProfile: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => CustomerProfileSetting(
                              currentUserID: widget.currentUserID!,
                              prefs: widget.prefs,
                              biometricEnabled: biometricEnabled,
                              type: Utils.getAuthenticationType(
                                  biometricEnabled, _cachedModel),
                            )));
              },
              currentUserID: widget.currentUserID!,
              biometricEnabled: biometricEnabled,
              type: Utils.getAuthenticationType(biometricEnabled, _cachedModel),
            )
          ];
    List<BottomNavigationBarItem> navBarIcons = [
      BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(
            EvaIcons.messageSquareOutline,
            size: 22,
            color: Mycolors.bottomnavbariconcolor,
          ),
        ),
        // label: getTranslatedForCurrentUser(context, 'chats'),
        label: getTranslatedForCurrentUser(context, 'xxtktssxx'),
        activeIcon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(EvaIcons.messageSquare,
              size: 22,
              color: Mycolors.getColor(widget.prefs, Colortype.primary.index)),
        ),
      ),
      BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(
            Boxicons.bx_bell,
            size: 22,
            color: Mycolors.bottomnavbariconcolor,
          ),
        ),
        // label: getTranslatedForCurrentUser(context, 'chats'),
        label: getTranslatedForCurrentUser(context, 'xxalertsxx'),
        activeIcon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(Boxicons.bxs_bell,
              size: 22,
              color: Mycolors.getColor(widget.prefs, Colortype.primary.index)),
        ),
      ),
      BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(
            Boxicons.bx_user,
            size: 22,
            color: Mycolors.bottomnavbariconcolor,
          ),
        ),
        // label: getTranslatedForCurrentUser(context, 'chats'),
        label: getTranslatedForCurrentUser(context, 'xxaccountxx'),
        activeIcon: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 3),
          child: Icon(Boxicons.bxs_user,
              size: 22,
              color: Mycolors.getColor(widget.prefs, Colortype.primary.index)),
        ),
      ),
    ];
    if (widget.currentUserID != null && observer.userAppSettingsDoc != null) {
      if (observer.userAppSettingsDoc!.customersLandingCustomTabURL != "") {
        int customtabIndex =
            observer.userAppSettingsDoc!.customerTabIndexPosition!;

        if (customtabIndex == 0 || customtabIndex == 1) {
          navBarIcons.insert(
            customtabIndex,
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 3),
                child: Icon(
                  EvaIcons.homeOutline,
                  size: 22,
                  color: Mycolors.bottomnavbariconcolor,
                ),
              ),
              // label: getTranslatedForCurrentUser(context, 'chats'),
              label:
                  observer.userAppSettingsDoc!.customerCustomTabLabel == "" ||
                          observer.userAppSettingsDoc!.customerCustomTabLabel!
                                  .trim()
                                  .toLowerCase() ==
                              "home"
                      ? getTranslatedForCurrentUser(context, 'xxhomexx')
                      : observer.userAppSettingsDoc!.customerCustomTabLabel,
              activeIcon: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 3),
                child: Icon(EvaIcons.homeOutline,
                    size: 22,
                    color: Mycolors.getColor(
                        widget.prefs, Colortype.primary.index)),
              ),
            ),
          );
          navBarPages.insert(
              customtabIndex,
              OpenWebPage(
                  currentUserID: widget.currentUserID!,
                  prefs: widget.prefs,
                  url: observer
                      .userAppSettingsDoc!.customersLandingCustomTabURL!,
                  flag: true,
                  hideHeader:
                      !observer.userAppSettingsDoc!.isShowHeaderCustomersTab!,
                  hideFooter:
                      !observer.userAppSettingsDoc!.isShowFooterCustomersTab!));
        } else if (customtabIndex == 2 || customtabIndex == 3) {
          int l = navBarPages.length;
          navBarIcons.insert(
            customtabIndex == 2 ? l - 1 : l,
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 3),
                child: Icon(
                  EvaIcons.homeOutline,
                  size: 22,
                  color: Mycolors.bottomnavbariconcolor,
                ),
              ),
              // label: getTranslatedForCurrentUser(context, 'chats'),
              label:
                  observer.userAppSettingsDoc!.customerCustomTabLabel == "" ||
                          observer.userAppSettingsDoc!.customerCustomTabLabel!
                                  .trim()
                                  .toLowerCase() ==
                              "home"
                      ? getTranslatedForCurrentUser(context, 'xxhomexx')
                      : observer.userAppSettingsDoc!.customerCustomTabLabel,
              activeIcon: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 3),
                child: Icon(EvaIcons.homeOutline,
                    size: 22,
                    color: Mycolors.getColor(
                        widget.prefs, Colortype.primary.index)),
              ),
            ),
          );
          navBarPages.insert(
              customtabIndex == 2 ? l - 1 : l,
              OpenWebPage(
                  currentUserID: widget.currentUserID!,
                  prefs: widget.prefs,
                  url: observer
                      .userAppSettingsDoc!.customersLandingCustomTabURL!,
                  flag: true,
                  hideHeader:
                      !observer.userAppSettingsDoc!.isShowHeaderCustomersTab!,
                  hideFooter:
                      !observer.userAppSettingsDoc!.isShowFooterCustomersTab!));
        }
      }
    }

    return isNotAllowEmulator == true
        ? errorScreen(context, "",
            getTranslatedForCurrentUser(context, 'xxemulatornotallowedxx'))
        : accountstatus != null
            ? errorScreen(context, accountstatus, accountactionmessage,
                ontapprofile: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => CustomerProfile(
                              prefs: widget.prefs,
                              onTapLogout: () async {
                                await logout(context);
                              },
                              onTapEditProfile: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) =>
                                            CustomerProfileSetting(
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
                                body: navBarPages[provider.currentInd],
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
                                  selectedFontSize: 12.0,
                                  unselectedFontSize: 12,
                                  unselectedItemColor:
                                      Mycolors.bottomnavbariconcolor,
                                  key: navBarGlobalKey,
                                  currentIndex: provider.currentInd,
                                  onTap: (index) {
                                    provider.setcurrentIndex(index);
                                    observer.setisLoadedWebViewFirstpage(false);
                                    registry.fetchUserRegistry(context);
                                    observer
                                        .fetchUserAppSettingsFromFirestore();
                                  },
                                  items: navBarIcons,
                                )))));
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
