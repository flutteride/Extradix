//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:random_string/random_string.dart';
import 'package:thinkcreative_technologies/Configs/MyRegisteredFonts.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/number_limits.dart';
import 'package:thinkcreative_technologies/Configs/optional_constants.dart';
import 'package:thinkcreative_technologies/Models/agent_model.dart';
import 'package:thinkcreative_technologies/Models/basic_settings_model_userapp.dart';
import 'package:thinkcreative_technologies/Models/batch_write_component.dart';
import 'package:thinkcreative_technologies/Models/role_management.dart';
import 'package:thinkcreative_technologies/Models/department_model.dart';
import 'package:thinkcreative_technologies/Models/user_registry_model.dart';
import 'package:thinkcreative_technologies/Models/userapp_settings_model.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/ticketWidget.dart';
import 'package:thinkcreative_technologies/Services/FirebaseServices/firebase_api.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/TimerProvider.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Utils/backupUserTable.dart';
import 'package:thinkcreative_technologies/Utils/batch_write.dart';
import 'package:thinkcreative_technologies/Utils/phonenumberVariantsGenerator.dart';
import 'package:thinkcreative_technologies/Utils/unawaited.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/main.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custominput.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/myscaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:thinkcreative_technologies/Models/E2EE/e2ee.dart' as e2ee;

class VerifyPhoneForAgents extends StatefulWidget {
  final Function(String title, String desc, String error) onError;
  final String onlyPhone;
  final String onlyCode;
  final SharedPreferences prefs;
  final bool issecutitysetupdone;
  final BasicSettingModelUserApp basicsettings;
  VerifyPhoneForAgents({
    Key? key,
    required this.onlyPhone,
    required this.issecutitysetupdone,
    required this.onlyCode,
    required this.onError,
    required this.prefs,
    required this.basicsettings,
  }) : super(key: key);

  @override
  _VerifyPhoneForAgentsState createState() => _VerifyPhoneForAgentsState();
}

class _VerifyPhoneForAgentsState extends State<VerifyPhoneForAgents> {
  int currentStatus = LoginStatus.sendingSMScode.index;
  bool isShowCompletedLoading = false;
  bool isVerifyingCode = false;
  bool isCodeSent = false;
  String _code = '';
  int attempt = 1;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final _name = TextEditingController();
  final storage = new FlutterSecureStorage();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  String? verificationId;
  dynamic isLoggedIn = false;
  User? currentUser;
  String? deviceid;
  var mapDeviceInfo = {};
  @override
  void initState() {
    super.initState();
    setdeviceinfo();

    verifyPhoneNumber();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final timerProvider = Provider.of<TimerProvider>(context, listen: false);
      timerProvider.resetTimer();
    });
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

  subscribeToNotification(String currentUserID, bool isFreshNewAccount) async {
    await FirebaseMessaging.instance
        .subscribeToTopic('$currentUserID')
        .catchError((err) {
      print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    });
    await FirebaseMessaging.instance
        .subscribeToTopic(Dbkeys.topicAGENTS)
        .catchError((err) {
      print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    });
    await FirebaseMessaging.instance
        .subscribeToTopic(Platform.isAndroid
            ? Dbkeys.topicUSERSandroid
            : Platform.isIOS
                ? Dbkeys.topicUSERSios
                : Dbkeys.topicUSERSweb)
        .catchError((err) {
      print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    });

    if (isFreshNewAccount == false) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionAgentGroups)
          .where(Dbkeys.groupMEMBERSLIST, arrayContains: currentUserID)
          .get()
          .then((query) async {
        if (query.docs.length > 0) {
          query.docs.forEach((doc) async {
            await FirebaseMessaging.instance
                .subscribeToTopic(
                    "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                .catchError((err) {
              print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
            });
          });
        }
      });
    }
  }

  createNewUser(String finalID) async {
    var phoneNo = (widget.onlyCode + widget.onlyPhone).trim();
    final observer = Provider.of<Observer>(context, listen: false);

    // int id = DateTime.now().millisecondsSinceEpoch;

    String myname = _name.text;
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      Navigator.of(context).pop();
      widget.onError(
        'Login Failed !',
        'Error occured while registering for Notification. Please try again',
        'Failed to get fCMtoken',
      );
    } else {
      var names = myname.trim().split(' ');

      String shortname = myname.trim();
      String lastName = "";
      if (names.length > 1) {
        shortname = names[0];
        lastName = names[1];
        if (shortname.length < 3) {
          shortname = lastName;
          if (lastName.length < 3) {
            shortname = myname;
          }
        }
      }

      //Add user to default ticket category for future new tickets

      DepartmentModel cat = DepartmentModel.fromJson(
          observer.userAppSettingsDoc!.departmentList![0]);

      List<dynamic> l = observer.userAppSettingsDoc!.departmentList![0]
          [Dbkeys.departmentAgentsUIDList];
      l.add((finalID));

      var modified = cat.copyWith(departmentAgentsUIDList: l);

      List<dynamic> list = observer.userAppSettingsDoc!.departmentList!;

      list[0] = modified.toMap();
      setStateIfMounted(() {});

      final pair = await e2ee.X25519().generateKeyPair();
      await storage.write(
          key: Dbkeys.privateKey, value: pair.secretKey.toBase64());
      // Update data to server if new user
      await batchwriteFirestoreData([
        BatchWriteComponent(
                ref: FirebaseFirestore.instance
                    .collection(DbPaths.collectionagents)
                    .doc(finalID),
                map: AgentModel(
                  rolesassigned: defaultAgentRoles,
                  platform: Platform.isAndroid
                      ? "android"
                      : Platform.isIOS
                          ? "ios"
                          : "",
                  id: finalID,
                  userLoginType: LoginType.phone.index,
                  email: '',
                  password: '',
                  firebaseuid: currentUser!.uid,
                  nickname: _name.text.trim(),
                  searchKey: _name.text.trim().substring(0, 1).toUpperCase(),
                  phone: phoneNo,
                  phoneRaw: widget.onlyPhone,
                  countryCode: widget.onlyCode,
                  photoUrl: currentUser!.photoURL ?? '',
                  aboutMe: '',
                  actionmessage:
                      widget.basicsettings.accountapprovalmessage ?? '',
                  currentDeviceID: deviceid ?? '',
                  privateKey: pair.secretKey.toBase64(),
                  publicKey: pair.publicKey.toBase64(),
                  accountstatus:
                      widget.basicsettings.agentVerificationNeeded == true
                          ? Dbkeys.sTATUSpending
                          : Dbkeys.sTATUSallowed,
                  audioCallMade: 0,
                  videoCallMade: 0,
                  audioCallRecieved: 0,
                  videoCallRecieved: 0,
                  groupsCreated: 0,
                  authenticationType: 0,
                  passcode: '',
                  totalvisitsANDROID: 0,
                  totalvisitsIOS: 0,
                  lastLogin: DateTime.now().millisecondsSinceEpoch,
                  joinedOn: DateTime.now().millisecondsSinceEpoch,
                  lastOnline: DateTime.now().millisecondsSinceEpoch,
                  lastSeen: DateTime.now().millisecondsSinceEpoch,
                  lastNotificationSeen: DateTime.now().millisecondsSinceEpoch,
                  isNotificationStringsMulitilanguageEnabled: false,
                  notificationStringsMap: {},
                  kycMap: {},
                  geoMap: {},
                  phonenumbervariants: phoneNumberVariantsList(
                      countrycode: widget.onlyCode,
                      phonenumber: widget.onlyPhone),
                  hidden: [],
                  locked: [],
                  notificationTokens: [fcmToken],
                  deviceDetails: mapDeviceInfo,
                  quickReplies: [],
                  lastVerified: 0,
                  ratings: [],
                  totalRepliesInTickets: 0,
                  twoFactorVerification: {},
                  userTypeIndex: Usertype.agent.index,
                ).toMap())
            .toMap(),
        BatchWriteComponent(
            ref: FirebaseFirestore.instance
                .collection(DbPaths.collectionagents)
                .doc(finalID)
                .collection(DbPaths.agentnotifications)
                .doc(DbPaths.agentnotifications),
            map: {
              Dbkeys.nOTIFICATIONisunseen: true,
              Dbkeys.nOTIFICATIONxxtitle: '',
              Dbkeys.nOTIFICATIONxxdesc: '',
              Dbkeys.nOTIFICATIONxxaction: Dbkeys.nOTIFICATIONactionNOPUSH,
              Dbkeys.nOTIFICATIONxximageurl: '',

              Dbkeys.nOTIFICATIONxxlastupdateepoch:
                  DateTime.now().millisecondsSinceEpoch,
              Dbkeys.nOTIFICATIONxxpagecomparekey: Dbkeys.docid,
              Dbkeys.nOTIFICATIONxxpagecompareval: '',
              Dbkeys.nOTIFICATIONxxparentid: '',
              Dbkeys.nOTIFICATIONxxextrafield: '',
              Dbkeys.nOTIFICATIONxxpagetype:
                  Dbkeys.nOTIFICATIONpagetypeSingleLISTinDOCSNAP,
              Dbkeys.nOTIFICATIONxxpageID: DbPaths.agentnotifications,
              //-----
              Dbkeys.nOTIFICATIONpagecollection1: DbPaths.collectionagents,
              Dbkeys.nOTIFICATIONpagedoc1: phoneNo,
              Dbkeys.nOTIFICATIONpagecollection2: DbPaths.agentnotifications,
              Dbkeys.nOTIFICATIONpagedoc2: DbPaths.agentnotifications,
              Dbkeys.nOTIFICATIONtopic: Dbkeys.topicAGENTS,
              Dbkeys.list: [],
            }).toMap(),
        BatchWriteComponent(
          ref: FirebaseFirestore.instance
              .collection(DbPaths.userapp)
              .doc(DbPaths.docusercount),
          map: widget.basicsettings.agentVerificationNeeded == false
              ? {
                  Dbkeys.totalapprovedagents: FieldValue.increment(1),
                }
              : {
                  Dbkeys.totalpendingagents: FieldValue.increment(1),
                },
        ).toMap(),
        BatchWriteComponent(
          ref: FirebaseFirestore.instance
              .collection(DbPaths.collectioncountrywiseAgentData)
              .doc(widget.onlyCode),
          map: {
            Dbkeys.totalusers: FieldValue.increment(1),
          },
        ).toMap(),
        BatchWriteComponent(
                ref: FirebaseFirestore.instance
                    .collection(DbPaths.collectionagents)
                    .doc(finalID)
                    .collection("backupTable")
                    .doc("backupTable"),
                map: userbackuptable)
            .toMap(),
        BatchWriteComponent(
          ref: FirebaseFirestore.instance
              .collection(DbPaths.userapp)
              .doc(DbPaths.registry),
          map: {
            Dbkeys.lastupdatedepoch: DateTime.now().millisecondsSinceEpoch,
            Dbkeys.list: FieldValue.arrayUnion([
              UserRegistryModel(
                  shortname: shortname,
                  fullname: _name.text.trim(),
                  id: finalID,
                  phone: phoneNo,
                  photourl: currentUser!.photoURL ?? "",
                  usertype: Usertype.agent.index,
                  email: "",
                  extra1: "",
                  extra2: "",
                  extraMap: {}).toMap()
            ])
          },
        ).toMap(),
        // BatchWriteComponent(
        //   ref: FirebaseFirestore.instance
        //       .collection(DbPaths.adminapp)
        //       .doc(DbPaths.adminnotifications),
        //   map: {
        //     Dbkeys.nOTIFICATIONxxaction: Dbkeys.nOTIFICATIONactionPUSH,
        //     Dbkeys.nOTIFICATIONxxdesc: observer
        //                 .userAppSettingsDoc!.isaccountapprovalbyadminneeded ==
        //             true
        //         ? '${_name.text.trim()} has Joined $Appname. APPROVE the agent account (ID:$finalID). You can view the agent profile from All Agents page.'
        //         : '${_name.text.trim()} has Joined $Appname. You can view the agent profile from All Agents page.',
        //     Dbkeys.nOTIFICATIONxxtitle: 'New Agent Joined',
        //     Dbkeys.nOTIFICATIONxximageurl: currentUser!.photoURL ?? "",
        //     Dbkeys.nOTIFICATIONxxlastupdateepoch:
        //         DateTime.now().millisecondsSinceEpoch,
        //   },
        // ).toMap(),
        BatchWriteComponent(
          ref: FirebaseFirestore.instance
              .collection(DbPaths.collectionagents)
              .doc(finalID),
          map: {
            Dbkeys.notificationTokens: [fcmToken]
          },
        ).toMap()
      ]).then((value) async {
        if (value == false) {
          //faild to write
          if (currentUser != null) {
            final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
            await firebaseAuth.signOut();
          }

          Navigator.of(context).pop();
          widget.onError(
            'Login Failed !',
            'Error occured while authentication. Please try again',
            'Failed to batch Write for Agent Doc',
          );
        } else {
          if (observer.userAppSettingsDoc!.autoJoinNewAgentsToDefaultList ==
              true) {
            FirebaseFirestore.instance
                .collection(DbPaths.userapp)
                .doc(DbPaths.appsettings)
                .set({Dbkeys.departmentList: list}, SetOptions(merge: true));
          }
          // Write data to local
          await widget.prefs.setString(Dbkeys.firebaseuid, currentUser!.uid);
          await widget.prefs.setString(Dbkeys.id, finalID);
          await widget.prefs.setString(Dbkeys.nickname, _name.text.trim());
          await widget.prefs
              .setString(Dbkeys.photoUrl, currentUser!.photoURL ?? '');
          await widget.prefs.setString(Dbkeys.phone, phoneNo);
          await widget.prefs.setString(Dbkeys.countryCode, widget.onlyCode);
          await widget.prefs.setInt(Dbkeys.userLoginType, Usertype.agent.index);

          unawaited(widget.prefs.setBool(Dbkeys.isTokenGenerated, true));
          await FirebaseApi.runTransactionRecordActivity(
            parentid: "AGENT_REGISTRATION--$finalID",
            title: "New Agent Joined",
            postedbyID: "sys",
            onErrorFn: (e) {},
            onSuccessFn: () {},
            styledDesc: widget.basicsettings.agentVerificationNeeded == true
                ? '<bold>${_name.text.trim()}</bold> has Joined $Appname. APPROVE the agent account <bold>(ID:$finalID)</bold>. You can view the agent profile from All Agents page.'
                : '<bold>${_name.text.trim()}</bold> has Joined $Appname. You can view the agent account <bold>(ID:$finalID)</bold> from <bold>All Agents</bold> page.',
            plainDesc: widget.basicsettings.agentVerificationNeeded == true
                ? '${_name.text.trim()} has Joined $Appname. APPROVE the agent account (ID:$finalID). You can view the agent profile from All Agents page.'
                : '${_name.text.trim()} has Joined $Appname. You can view the agent profile from All Agents page.',
          );
          // unawaited(Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(
          //         builder: (newContext) => AgentHome(
          //               basicsettings: widget.basicsettings,
          //               currentUserID: finalID,
          //               prefs: widget.prefs,
          //             ))));

          // await widget.prefs.setString(Dbkeys.isSecuritySetupDone, phoneNo);
          await subscribeToNotification(finalID, true);
          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => AppWrapper(
                      loadAttempt: 0,
                    )),
            (route) => false, //if you want to disable back feature set to false
          );
        }
      });
    }
  }

  updateUser(DocumentSnapshot<Map<String, dynamic>> document) async {
    await storage.write(
        key: Dbkeys.privateKey, value: document[Dbkeys.privateKey]);
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    AgentModel agent = AgentModel.fromSnapshot(document);
    final updatedAgent = agent.copyWith(
      userLoginType: LoginType.phone.index,
      lastLogin: DateTime.now().millisecondsSinceEpoch,
      platform: Platform.isAndroid
          ? "android"
          : Platform.isIOS
              ? "ios"
              : "",

      // mssgSent: 0,
      deviceDetails: mapDeviceInfo,
      currentDeviceID: deviceid,

      notificationTokens: [fcmToken!],
    );
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionagents)
        .doc(document.data()![Dbkeys.id])
        .update(updatedAgent.toMap());

    // Write data to local
    await widget.prefs
        .setString(Dbkeys.firebaseuid, document[Dbkeys.firebaseuid]);
    await widget.prefs.setString(Dbkeys.id, document[Dbkeys.id]);
    await widget.prefs.setString(Dbkeys.nickname, _name.text.trim());
    await widget.prefs
        .setString(Dbkeys.photoUrl, document[Dbkeys.photoUrl] ?? '');
    await widget.prefs
        .setString(Dbkeys.aboutMe, document[Dbkeys.aboutMe] ?? '');
    await widget.prefs.setString(Dbkeys.phone, document[Dbkeys.phone]);
    await widget.prefs.setInt(Dbkeys.userLoginType, Usertype.agent.index);
    if (widget.issecutitysetupdone == false) {
      await subscribeToNotification(document[Dbkeys.id], false);
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => AppWrapper(
                  loadAttempt: 0,
                )),
        (route) => false, //if you want to disable back feature set to false
      );
    } else {
      // unawaited(Navigator.pushReplacement(context,
      //     new MaterialPageRoute(builder: (context) => AppWrapper())));

      await subscribeToNotification(document[Dbkeys.id], false);
      Utils.toast(getTranslatedForCurrentUser(context, 'xxwelcomebackxx'));
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => AppWrapper(
                  loadAttempt: 0,
                )),
        (route) => false, //if you want to disable back feature set to false
      );
      // Restart.restartApp();
    }
  }

  Future<Null> handleSignIn({AuthCredential? authCredential}) async {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    final observerold = Provider.of<Observer>(context, listen: false);

    setStateIfMounted(() {
      isShowCompletedLoading = true;
    });

    try {
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: _code);

      UserCredential firebaseUser =
          await firebaseAuth.signInWithCredential(credential);

      currentUser = firebaseUser.user;

      setStateIfMounted(() {});

      await FirebaseFirestore.instance
          .collection(DbPaths.userapp)
          .doc(DbPaths.appsettings)
          .get()
          .then((appsettings) async {
        if (appsettings.exists) {
          observerold.setObserver(
              currentUserID: null,
              isAgent: true,
              userAppSettings: UserAppSettingsModel.fromSnapshot(appsettings));

          await FirebaseFirestore.instance
              .collection(DbPaths.collectionagents)
              .where(Dbkeys.phone,
                  isEqualTo: widget.onlyCode + widget.onlyPhone)
              .get()
              .then((agent) async {
            if (agent.docs.length >= 1) {
              setStateIfMounted(() {
                _name.text = agent.docs[0][Dbkeys.nickname];
              });
              if (widget.basicsettings.agentLoginEnabled == false) {
                if (currentUser != null) {
                  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                  await firebaseAuth.signOut();
                }
                Navigator.of(context).pop();
                widget.onError(
                  getTranslatedForCurrentUser(context, 'xxfailedxx'),
                  getTranslatedForCurrentUser(
                      context, 'xxxlogintempdisbaledxxx'),
                  '',
                );
              } else {
                updateUser(agent.docs.first);
              }
            } else {
              if (widget.basicsettings.agentRegistartionEnabled == false) {
                if (currentUser != null) {
                  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                  await firebaseAuth.signOut();
                }
                Navigator.of(context).pop();
                widget.onError(
                  getTranslatedForCurrentUser(context, 'xxfailedxx'),
                  getTranslatedForCurrentUser(
                      context, 'xxregistrationdisabledxx'),
                  '',
                );
              } else {
                await FirebaseFirestore.instance
                    .collection(DbPaths.collectioncustomers)
                    .where(Dbkeys.phone,
                        isEqualTo: widget.onlyCode + widget.onlyPhone)
                    .get()
                    .then((customer) async {
                  if (customer.docs.length >= 1) {
                    setStateIfMounted(() {
                      currentStatus = LoginStatus.failure.index;
                      isCodeSent = false;
                      timerProvider.resetTimer();
                      isShowCompletedLoading = false;
                      isVerifyingCode = false;
                      currentPinAttemps = 0;
                    });
                    if (currentUser != null) {
                      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                      await firebaseAuth.signOut();
                    }
                    Navigator.of(context).pop();
                    widget.onError(
                      getTranslatedForCurrentUser(
                              context, 'xxalreadyregisteredasxx')
                          .replaceAll('(####)',
                              '${getTranslatedForCurrentUser(context, getTranslatedForCurrentUser(context, 'xxcustomerxx'))}'),
                      getTranslatedForCurrentUser(
                              context, 'xxalreadyregistereddescxx')
                          .replaceAll('(####)',
                              '${(widget.onlyCode + widget.onlyPhone).trim().toString()}')
                          .replaceAll('(###)',
                              '${getTranslatedForCurrentUser(context, getTranslatedForCurrentUser(context, 'xxcustomerxx'))}')
                          .replaceAll('(##)',
                              '${getTranslatedForCurrentUser(context, 'xxagentxx')}'),
                      '',
                    );
                  } else {
                    setStateIfMounted(() {
                      currentStatus = LoginStatus.entername.index;
                    });
                  }
                });
              }
            }
          }).catchError((onError) async {
            if (currentUser != null) {
              final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
              await firebaseAuth.signOut();
            }
            Navigator.of(context).pop();
            widget.onError(
              getTranslatedForCurrentUser(context, 'xxfailedxx'),
              getTranslatedForCurrentUser(context, 'xxauthfailedxx'),
              'ERROR:2-${onError.toString()}',
            );
          });
        } else {
          if (currentUser != null) {
            final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
            await firebaseAuth.signOut();
          }
          Navigator.of(context).pop();
          widget.onError(
            'Login Failed',
            'User app is not installed properly.',
            '',
          );
        }
      }).catchError((onError) async {
        if (currentUser != null) {
          final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
          await firebaseAuth.signOut();
        }
        Navigator.of(context).pop();
        widget.onError(
          'Login Failed',
          'Failed to load please try again.',
          'ERROR:9-${onError.toString()}',
        );
      });
    } catch (e) {
      setStateIfMounted(() {
        if (currentPinAttemps >= 4) {
          currentStatus = LoginStatus.failure.index;
          isCodeSent = false;
        }
        isShowCompletedLoading = false;
        isVerifyingCode = false;
        currentPinAttemps++;
      });

      if (e.toString().contains('invalid') ||
          e.toString().contains('code') ||
          e.toString().contains('verification')) {
        if (currentUser != null) {
          final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
          await firebaseAuth.signOut();
        }
        Navigator.of(context).pop();
        widget.onError(
          'Login Failed',
          getTranslatedForCurrentUser(context, 'xxmakesureotpxx'),
          'ERROR:4-${e.toString()}',
        );
      } else {
        if (currentUser != null) {
          final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
          await firebaseAuth.signOut();
        }
        Navigator.of(context).pop();
        widget.onError(
          'Login Failed',
          getTranslatedForCurrentUser(context, 'xxmakesureotpxx'),
          'ERROR:6-${e.toString()}',
        );
      }
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  int currentPinAttemps = 0;
  Future<void> verifyPhoneNumber() async {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    // start----
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      isShowCompletedLoading = true;
      setStateIfMounted(() {});
      handleSignIn(authCredential: phoneAuthCredential);
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setStateIfMounted(() {
        currentStatus = LoginStatus.failure.index;
        isCodeSent = false;
        timerProvider.resetTimer();
        isShowCompletedLoading = false;
        isVerifyingCode = false;
        currentPinAttemps = 0;
      });

      print(
          'Authentication failed -ERROR: ${authException.message}. Try again later.');

      Navigator.of(context).pop();
      widget.onError(
        getTranslatedForCurrentUser(context, 'xxfailedxx'),
        getTranslatedForCurrentUser(context, 'xxauthfailedxx'),
        '',
      );
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      timerProvider.startTimer();
      setStateIfMounted(() {
        currentStatus = LoginStatus.sentSMSCode.index;
        isVerifyingCode = false;
        isCodeSent = true;
      });

      this.verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.verificationId = verificationId;
      setStateIfMounted(() {
        currentStatus = LoginStatus.failure.index;
        isCodeSent = false;
        timerProvider.resetTimer();
        isShowCompletedLoading = false;
        isVerifyingCode = false;
        currentPinAttemps = 0;
      });
      Navigator.of(context).pop();
      widget.onError(
        getTranslatedForCurrentUser(context, 'xxfailedxx'),
        getTranslatedForCurrentUser(context, 'xxverffailedxx'),
        '',
      );
    };
    print('Verify phone triggered');

    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: (widget.onlyCode + widget.onlyPhone).trim(),
        timeout: Duration(seconds: timeOutSeconds + timeOutSeconds + 20),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);

// end----
  }

  buildCurrentWidget(double w) {
    if (currentStatus == LoginStatus.entername.index) {
      return loginWidgetEnterName(w);
    } else if (currentStatus == LoginStatus.sendingSMScode.index) {
      return loginWidgetsendingSMScode();
    } else if (currentStatus == LoginStatus.sentSMSCode.index) {
      return loginWidgetsentSMScode();
    } else if (currentStatus == LoginStatus.verifyingSMSCode.index) {
      return loginWidgetVerifyingSMScode();
    } else if (currentStatus == LoginStatus.sendingSMScode.index) {
      return loginWidgetsendingSMScode();
    } else if (currentStatus == LoginStatus.checkingname.index) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
            28, MediaQuery.of(context).size.height / 5, 28, 40),
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Mycolors.secondary)),
        ),
      );
    }
    // else {
    //   return loginWidgetsendSMScode(w);
    // }
  }

  loginWidgetEnterName(double w) {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      margin: EdgeInsets.fromLTRB(15, 30, 16, 0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 13,
          ),
          Padding(
              padding: const EdgeInsets.only(left: 7),
              child: MtCustomfontBold(
                fontsize: 18,
                text: getTranslatedForCurrentUser(context, 'xxenterfullnamexx'),
              )
              // Text(
              //   getTranslatedForCurrentUser(context, 'xxenterfullnamexx'),
              //   textAlign: TextAlign.left,
              //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5),
              // ),
              ),
          SizedBox(
            height: 30,
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            // height: 63,
            height: 73,
            width: MediaQuery.of(context).size.width / 1.2,
            child: InpuTextBox(
              focuscolor: Mycolors.agentPrimary,
              boxbordercolor: Mycolors.textboxbordercolor,
              boxbcgcolor: Mycolors.textboxbgcolor,
              controller: _name,
              leftrightmargin: 0,
              showIconboundary: false,
              boxcornerradius: 5.5,
              hinttext: getTranslatedForCurrentUser(context, 'xxfullnamexx'),
              boxheight: 55,
              prefixIconbutton: Icon(Icons.person, color: Mycolors.greylight),
            ),
          ),
          SizedBox(
            height: 18,
          ),
          MySimpleButtonWithIcon(
            width: MediaQuery.of(context).size.width / 1.2,
            buttontext: getTranslatedForCurrentUser(context, 'xxcreateacxx'),
            buttoncolor:
                Mycolors.getColor(widget.prefs, Colortype.primary.index),
            onpressed: () async {
              final timerProvider =
                  Provider.of<TimerProvider>(context, listen: false);
              timerProvider.resetTimer();
              setStateIfMounted(() {
                currentStatus = LoginStatus.checkingname.index;
                isCodeSent = false;
              });
              //--
              // var rndnumber = "";
              // var rnd = new Random();
              // for (var i = 0; i < Numberlimits.agentIDlength; i++) {
              //   rndnumber = rndnumber + rnd.nextInt(9).toString();
              // }

              String finalID1 = randomNumeric(Numberlimits.agentIDlength);
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionagents)
                  .doc(finalID1)
                  .get()
                  .then((value1) async {
                if (value1.exists) {
                  String finalID2 = randomNumeric(Numberlimits.agentIDlength);
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectionagents)
                      .doc(finalID2)
                      .get()
                      .then((value2) async {
                    if (value2.exists) {
                      String finalID3 =
                          randomNumeric(Numberlimits.agentIDlength);
                      await FirebaseFirestore.instance
                          .collection(DbPaths.collectionagents)
                          .doc(finalID3)
                          .get()
                          .then((value3) async {
                        if (value3.exists) {
                          String finalID4 =
                              randomNumeric(Numberlimits.agentIDlength);
                          await FirebaseFirestore.instance
                              .collection(DbPaths.collectionagents)
                              .doc(finalID4)
                              .get()
                              .then((value4) async {
                            if (value4.exists) {
                              Utils.toast(
                                  "Failed! Please restart app & try again");
                            } else {
                              await createNewUser(finalID4);
                            }
                          });
                        } else {
                          await createNewUser(finalID3);
                        }
                      });
                    } else {
                      await createNewUser(finalID2);
                    }
                  });
                } else {
                  await createNewUser(finalID1);
                }
              });
            },
          )
        ],
      ),
    );
  }

  loginWidgetsendingSMScode() {
    var w = MediaQuery.of(context).size.width;
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      margin: EdgeInsets.fromLTRB(15, 30, 16, 0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 13,
          ),
          Container(
            padding: EdgeInsets.all(20),
            width: w * 0.95,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                      text: getTranslatedForCurrentUser(
                          context, 'xxsending_codexx'),
                      style: TextStyle(
                          height: 1.7,
                          fontFamily: MyRegisteredFonts.regular,
                          color: Mycolors.grey,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.8),
                      recognizer: TapGestureRecognizer()..onTap = () {}),
                  TextSpan(
                      text: ' ${widget.onlyCode}-${widget.onlyPhone}',
                      style: TextStyle(
                          height: 1.7,
                          fontFamily: MyRegisteredFonts.bold,
                          color: Mycolors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.8),
                      recognizer: TapGestureRecognizer()..onTap = () {}),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
              Mycolors.getColor(widget.prefs, Colortype.primary.index),
            )),
          ),
          SizedBox(
            height: 48,
          ),
        ],
      ),
    );
  }

  loginWidgetsentSMScode() {
    var w = MediaQuery.of(context).size.width;
    return Container(
      height: MediaQuery.of(context).size.height / 2.5,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 13,
          ),

          Container(
            margin: EdgeInsets.all(25),
            // height: 70,
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: PinFieldAutoFill(
                codeLength: 6,
                decoration: UnderlineDecoration(
                  bgColorBuilder: FixedColorBuilder(Color(0xfff0f4fb)),
                  textStyle: TextStyle(
                      fontSize: 22,
                      color: Mycolors.blackDynamic,
                      fontWeight: FontWeight.bold),
                  colorBuilder: FixedColorBuilder(Color(0xfff0f4fb)),
                ),
                currentCode: _code,
                onCodeSubmitted: (code) {
                  setStateIfMounted(() {
                    _code = code;
                  });
                  if (code.length == 6) {
                    setStateIfMounted(() {
                      currentStatus = LoginStatus.verifyingSMSCode.index;
                    });
                    handleSignIn();
                  } else {
                    Utils.toast(
                        getTranslatedForCurrentUser(context, 'xxcorrectotpxx'));
                  }
                },
                onCodeChanged: (code) {
                  if (code!.length == 6) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    setStateIfMounted(() {
                      _code = code;
                    });
                  }
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            width: w * 0.95,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                      text: getTranslatedForCurrentUser(
                          context, 'xxenter_verfcodexx'),
                      style: TextStyle(
                          height: 1.7,
                          fontFamily: MyRegisteredFonts.regular,
                          color: Mycolors.grey,
                          // fontWeight: FontWeight.w700,
                          fontSize: 14.8),
                      recognizer: TapGestureRecognizer()..onTap = () {}),
                  TextSpan(
                      text: ' ${widget.onlyCode}-${widget.onlyPhone}',
                      style: TextStyle(
                          height: 1.7,
                          fontFamily: MyRegisteredFonts.bold,
                          color: Mycolors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.8),
                      recognizer: TapGestureRecognizer()..onTap = () {}),
                ],
              ),
            ),
          ),

          isShowCompletedLoading == true
              ? Center(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Mycolors.secondary)),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MySimpleButtonWithIcon(
                      width: MediaQuery.of(context).size.width / 1.2,
                      buttontext: getTranslatedForCurrentUser(
                          context, 'xxverify_otpxx'),
                      buttoncolor: Mycolors.getColor(
                          widget.prefs, Colortype.primary.index),
                      onpressed: () {
                        if (_code.length == 6) {
                          setStateIfMounted(() {
                            isVerifyingCode = true;
                          });
                          handleSignIn();
                        } else
                          Utils.toast(getTranslatedForCurrentUser(
                              context, 'xxcorrectotpxx'));
                      },
                    ),
                  ],
                ),

          SizedBox(
            height: 20,
          ),
          isShowCompletedLoading == true
              ? SizedBox(
                  height: 36,
                )
              : Consumer<TimerProvider>(
                  builder: (context, timeProvider, _) => timeProvider.wait ==
                              true &&
                          isCodeSent == true
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                          child: RichText(
                              text: TextSpan(
                            children: [
                              TextSpan(
                                text: getTranslatedForCurrentUser(
                                    context, 'xxresendcodexx'),
                                style: TextStyle(
                                    fontFamily: MyRegisteredFonts.regular,
                                    fontSize: 14,
                                    color: Mycolors.grey),
                              ),
                              TextSpan(
                                text: "  00:${timeProvider.start}  ",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Mycolors.getColor(
                                        widget.prefs, Colortype.primary.index),
                                    fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: getTranslatedForCurrentUser(
                                    context, 'xxsecondsxx'),
                                style: TextStyle(
                                    fontFamily: MyRegisteredFonts.regular,
                                    fontSize: 14,
                                    color: Mycolors.grey),
                              ),
                            ],
                          )),
                        )
                      : timeProvider.isActionBarShow == false
                          ? SizedBox(
                              height: 35,
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                attempt > 1
                                    ? SizedBox(
                                        height: 0,
                                      )
                                    : InkWell(
                                        onTap: () {
                                          setStateIfMounted(() {
                                            attempt++;

                                            timeProvider.resetTimer();
                                            isCodeSent = false;
                                            currentStatus = LoginStatus
                                                .sendingSMScode.index;
                                          });
                                          verifyPhoneNumber();
                                        },
                                        child: Container(
                                          margin:
                                              EdgeInsets.fromLTRB(10, 4, 28, 4),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.restart_alt_outlined,
                                                color: Mycolors.getColor(
                                                    widget.prefs,
                                                    Colortype.secondary.index),
                                              ),
                                              Text(
                                                ' ' +
                                                    getTranslatedForCurrentUser(
                                                        context, 'xxresendxx'),
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Mycolors.getColor(
                                                        widget.prefs,
                                                        Colortype
                                                            .secondary.index),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ))
                              ],
                            ),
                ),

          //
        ],
      ),
    );
  }

  loginWidgetVerifyingSMScode() {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 13,
          ),

          Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Mycolors.secondary)),
          ),

          InkWell(
            onTap: () {
              setStateIfMounted(() {
                currentStatus = LoginStatus.sendSMScode.index;
              });
            },
            child: Padding(
                padding: EdgeInsets.fromLTRB(13, 22, 13, 8),
                child: Center(
                  child: Text(
                    getTranslatedForCurrentUser(context, 'xxbackxx'),
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                )),
          ),
          //
          SizedBox(
            height: 18,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: MyScaffold(
        iconTextColor: Mycolors.black,
        iconWidget: Consumer<TimerProvider>(
            builder: (context, timeProvider, _) => IconButton(
                onPressed: () async {
                  if ((currentStatus == LoginStatus.sentSMSCode.index &&
                          timeProvider.isActionBarShow == true) ||
                      currentStatus == LoginStatus.checkingname.index) {
                    if (currentUser != null) {
                      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                      await firebaseAuth.signOut();
                    }
                    Navigator.of(context).pop();
                  }
                },
                icon: Icon(
                  (currentStatus == LoginStatus.sentSMSCode.index &&
                              timeProvider.isActionBarShow == true) ||
                          currentStatus == LoginStatus.checkingname.index
                      ? Icons.close
                      : null,
                ))),
        title: getTranslatedForCurrentUser(context, 'xxverifynumberxx'),
        isforcehideback: true,
        body: Container(
          color: Mycolors.backgroundcolor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  color: Mycolors.whiteDynamic,
                  child: Center(
                      child: Image.asset('assets/images/verify.png',
                          height: MediaQuery.of(context).size.height / 3)),
                ),
              ),
              Container(
                decoration: boxDecoration(radius: 8),
                padding: const EdgeInsets.fromLTRB(18, 35, 18, 8),
                // color: Colors.white,
                child: buildCurrentWidget(MediaQuery.of(context).size.width),
              )
            ],
          ),
        ),
      ),
    );
  }
}
