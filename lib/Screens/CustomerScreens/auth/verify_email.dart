import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Configs/number_limits.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/basic_settings_model_userapp.dart';
import 'package:thinkcreative_technologies/Models/batch_write_component.dart';
import 'package:thinkcreative_technologies/Models/customer_model.dart';
import 'package:thinkcreative_technologies/Models/user_registry_model.dart';
import 'package:thinkcreative_technologies/Services/FirebaseServices/firebase_api.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Utils/backupUserTable.dart';
import 'package:thinkcreative_technologies/Utils/batch_write.dart';
import 'package:thinkcreative_technologies/Utils/error_codes.dart';
import 'package:thinkcreative_technologies/Utils/unawaited.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/main.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custominput.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/loadingDialog.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';

class VerifyEmailForCustomers extends StatefulWidget {
  final SharedPreferences prefs;
  final BasicSettingModelUserApp basicSettings;
  final String email;
  final String password;
  final Function(String title, String desc, String error) onError;
  const VerifyEmailForCustomers(
      {Key? key,
      required this.prefs,
      required this.email,
      required this.onError,
      required this.basicSettings,
      required this.password})
      : super(key: key);

  @override
  State<VerifyEmailForCustomers> createState() =>
      _VerifyEmailForCustomersState();
}

class _VerifyEmailForCustomersState extends State<VerifyEmailForCustomers> {
  bool isloading = true;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceid = "";
  var mapDeviceInfo = {};
  @override
  void initState() {
    super.initState();
    _email.text = widget.email;
    _password.text = widget.password;
    checkUser();
    setdeviceinfo();
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

  createNewUser() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: widget.email, password: widget.password)
          .then((user) async {
        await checkUser();
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Navigator.of(context).pop();
        showERRORSheet(context, "EM_114",
            message:
                "${getTranslatedForCurrentUser(context, 'xxfailedxx')}\n\n. ${getTranslatedForCurrentUser(context, 'xxpwdweakxx')}");
      } else if (e.code == 'email-already-in-use') {
        Navigator.of(context).pop();
        showERRORSheet(context, "EM_113",
            message:
                "${getTranslatedForCurrentUser(context, 'xxfailedxx')}\n\n. ${getTranslatedForCurrentUser(context, 'xxacalreadyexistsxx')}");
      }
    } catch (e) {
      Navigator.of(context).pop();
      showERRORSheet(context, "EM_102",
          message:
              "${getTranslatedForCurrentUser(context, 'xxfailedxx')}\n\n. Error: $e");
    }
  }

  checkUser({UserCredential? registereduserCredential}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: widget.email, password: widget.password);
      if (userCredential.user != null) {
        final observer = Provider.of<Observer>(context, listen: false);
        observer.fetchUserAppSettingsFromFirestore();
        await loginChecks(registereduserCredential: registereduserCredential);
      } else {
        Navigator.of(context).pop();
        Utils.toast("not found");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        Navigator.of(context).pop();
        showERRORSheet(context, "EM_115",
            message: getTranslatedForCurrentUser(context, 'xxinvalidemailxx'));
      } else if (e.code == 'user-disabled') {
        Navigator.of(context).pop();
        showERRORSheet(context, "EM_116",
            message: getTranslatedForCurrentUser(context, 'xxemaildisabledxx'));
      } else if (e.code == 'user-not-found') {
        if (widget.basicSettings.customerRegistationEnabled == true) {
          await createNewUser();
        } else {
          Navigator.of(context).pop();
          showERRORSheet(context, "EM_124",
              message: getTranslatedForCurrentUser(
                      context, 'xxemailnotfoundlxx')
                  .replaceAll('(####)',
                      getTranslatedForCurrentUser(context, 'xxcustomerxx')));
        }
      } else if (e.code == 'wrong-password') {
        Navigator.of(context).pop();
        showERRORSheet(context, "EM_112",
            message:
                "${getTranslatedForCurrentUser(context, 'xxfailedxx')}\n\n ${getTranslatedForCurrentUser(context, 'xxincorrectpwdxx')}");
      }
    } catch (e) {
      if (e.toString().contains("no user") ||
          e.toString().contains("user record") ||
          e.toString().contains("not-found")) {
        //---create a user if Allowed

        if (widget.basicSettings.customerRegistationEnabled == true) {
          await createNewUser();
        } else {
          Navigator.of(context).pop();
          showERRORSheet(context, "EM_101",
              message: getTranslatedForCurrentUser(
                      context, 'xxemailnotfoundlxx')
                  .replaceAll('(####)',
                      getTranslatedForCurrentUser(context, 'xxcustomerxx')));
        }
      } else if (e.toString().contains("does not have a password") ||
          e.toString().contains("password is invalid") ||
          e.toString().contains("wrong-password")) {
        //---create a user if Allowed
        if (e.toString().contains("does not have a password")) {
          Navigator.of(context).pop();
          showERRORSheet(context, "EM_111",
              message:
                  "${getTranslatedForCurrentUser(context, 'xxfailedxx')}\n\n Error: ${getTranslatedForCurrentUser(context, 'xxcannotuseemailxx')}");
        } else if (e.toString().contains("password is invalid") ||
            e.toString().contains("wrong-password")) {
          Navigator.of(context).pop();
          showERRORSheet(context, "EM_120",
              message:
                  "${getTranslatedForCurrentUser(context, 'xxfailedxx')}\n\n ${getTranslatedForCurrentUser(context, 'xxincorrectpwdxx')}");
        } else {
          if (widget.basicSettings.customerRegistationEnabled == true) {
            await createNewUser();
          } else {
            Navigator.of(context).pop();
            showERRORSheet(context, "EM_123",
                message: getTranslatedForCurrentUser(
                        context, 'xxemailnotfoundlxx')
                    .replaceAll('(####)',
                        getTranslatedForCurrentUser(context, 'xxcustomerxx')));
          }
        }
      } else {
        Navigator.of(context).pop();
        showERRORSheet(context, "EM_100",
            message:
                "${getTranslatedForCurrentUser(context, 'xxfailedxx')}\n\n. Error: $e");
      }
    }
  }

  loginChecks({UserCredential? registereduserCredential}) async {
    //check user account after he has has verified email and password & is signed currently
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    await FirebaseFirestore.instance
        .collection(DbPaths.collectioncustomers)
        .where(Dbkeys.email, isEqualTo: widget.email)
        .get()
        .then((customerList) async {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionagents)
          .where(Dbkeys.email, isEqualTo: widget.email)
          .get()
          .then((agentList) async {
        if (agentList.docs.length > 0) {
          firebaseAuth.signOut();
          Navigator.of(context).pop();
          showERRORSheet(context, "EM_105",
              message:
                  "${getTranslatedForCurrentUser(context, 'xxfailedxx')}\n\n. Error: ${getTranslatedForCurrentUser(context, 'xxalreadyregistereddescxx').replaceAll('(####)', widget.email).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxagentxx')).replaceAll('(##)', getTranslatedForCurrentUser(context, 'xxcustomerxx'))}");
        } else {
          if (customerList.docs.length == 0) {
            if (widget.basicSettings.customerRegistationEnabled == true) {
              String finalID1 = randomNumeric(Numberlimits.customerIDlength);
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectioncustomers)
                  .doc(finalID1)
                  .get()
                  .then((value1) async {
                if (value1.exists) {
                  String finalID2 =
                      randomNumeric(Numberlimits.customerIDlength);
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectioncustomers)
                      .doc(finalID2)
                      .get()
                      .then((value2) async {
                    if (value2.exists) {
                      String finalID3 =
                          randomNumeric(Numberlimits.customerIDlength);
                      await FirebaseFirestore.instance
                          .collection(DbPaths.collectioncustomers)
                          .doc(finalID3)
                          .get()
                          .then((value3) async {
                        if (value3.exists) {
                          String finalID4 =
                              randomNumeric(Numberlimits.customerIDlength);
                          await FirebaseFirestore.instance
                              .collection(DbPaths.collectioncustomers)
                              .doc(finalID4)
                              .get()
                              .then((value4) async {
                            if (value4.exists) {
                              Utils.toast(
                                  "Failed! Please restart app & try again");
                            } else {
                              await createFreshNewAccountInFirebase(finalID4, 0,
                                  registereduserCredential:
                                      registereduserCredential);
                            }
                          });
                        } else {
                          await createFreshNewAccountInFirebase(finalID3, 0,
                              registereduserCredential:
                                  registereduserCredential);
                        }
                      });
                    } else {
                      await createFreshNewAccountInFirebase(finalID2, 0,
                          registereduserCredential: registereduserCredential);
                    }
                  });
                } else {
                  await createFreshNewAccountInFirebase(finalID1, 0,
                      registereduserCredential: registereduserCredential);
                }
              });
            } else {
              Navigator.of(context).pop();
              showERRORSheet(context, "EM_108",
                  message:
                      "${getTranslatedForCurrentUser(context, 'xxfailedxx')}\n\n ${getTranslatedForCurrentUser(context, 'xxemailnotfoundlxx')}");
            }
          } else if (customerList.docs.length == 1) {
            await updateExistingUser(customerList.docs[0], 0,
                registereduserCredential: registereduserCredential);
          } else {
            firebaseAuth.signOut();
            Navigator.of(context).pop();
            showERRORSheet(context, "EM_104",
                message:
                    "${getTranslatedForCurrentUser(context, 'xxfailedxx')}\n\n${getTranslatedForCurrentUser(context, 'xxmultipleacxx')}");
          }
        }
      });
    }).catchError((err) {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      firebaseAuth.signOut();
      Navigator.of(context).pop();
      showERRORSheet(context, "EM_103",
          message: "Login failed !\n\n. Error: $err");
    });
    // } else {
    //   //existing registered in firebase

    // }
  }

  subscribeToNotification(String currentUserID, bool isFreshNewAccount) async {
    await FirebaseMessaging.instance
        .subscribeToTopic('$currentUserID')
        .catchError((err) {
      print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    });
    await FirebaseMessaging.instance
        .subscribeToTopic(Dbkeys.topicCUSTOMERS)
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

    // if (isFreshNewAccount == false) {
    //   await FirebaseFirestore.instance
    //       .collection(DbPaths.collectionAgentGroups)
    //       .where(Dbkeys.groupMEMBERSLIST, arrayContains: currentUserID)
    //       .get()
    //       .then((query) async {
    //     if (query.docs.length > 0) {
    //       query.docs.forEach((doc) async {
    //         await FirebaseMessaging.instance
    //             .subscribeToTopic(
    //                 "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
    //             .catchError((err) {
    //           print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    //         });
    //       });
    //     }
    //   });
    // }
  }

  bool isAskName = false;
  String storedFinalID = "";
  UserCredential? storedregistereduserCredential;
  createFreshNewAccountInFirebase(String finalID, int tries,
      {UserCredential? registereduserCredential, String? name}) async {
    final observer = Provider.of<Observer>(context, listen: false);
    if (observer.userAppSettingsDoc == null) {
      if (tries > 5) {
        Navigator.of(context).pop();
        showERRORSheet(context, "EM_121",
            message:
                "Login failed !\n\n.Error occured while registering fa new account. Please try again . Unable to fetch settings");
      } else {
        observer.fetchUserAppSettingsFromFirestore();
        await createFreshNewAccountInFirebase(finalID, tries + 1,
            registereduserCredential: registereduserCredential, name: name);
      }
    } else {
      if (name == null) {
        setStateIfMounted(() {
          isAskName = true;
          storedFinalID = finalID;
          storedregistereduserCredential = registereduserCredential;
        });
      } else {
        setStateIfMounted(() {
          isAskName = false;
        });

        String myname = name;
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken == null) {
          if (tries > 5) {
            Navigator.of(context).pop();
            showERRORSheet(context, "EM_109",
                message:
                    "Login failed !\n\n.Error occured while registering for Notification. Please try again  .Failed to get fCMtoken");
          } else {
            await createFreshNewAccountInFirebase(finalID, tries,
                name: name, registereduserCredential: registereduserCredential);
          }
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

          // DepartmentModel cat = DepartmentModel.fromJson(
          //     observer.userAppSettingsDoc!.departmentList![0]);

          // List<dynamic> l = observer.userAppSettingsDoc!.departmentList![0]
          //     [Dbkeys.departmentAgentsUIDList];
          // l.add((finalID));

          // var modified = cat.copyWith(departmentAgentsUIDList: l);

          // List<dynamic> list = observer.userAppSettingsDoc!.departmentList!;

          // list[0] = modified.toMap();
          setStateIfMounted(() {});

          await batchwriteFirestoreData([
            BatchWriteComponent(
                    ref: FirebaseFirestore.instance
                        .collection(DbPaths.collectioncustomers)
                        .doc(finalID),
                    map: CustomerModel(
                      rolesassigned: [],
                      platform: Platform.isAndroid
                          ? "android"
                          : Platform.isIOS
                              ? "ios"
                              : "",
                      id: finalID,
                      userLoginType: LoginType.email.index,
                      email: widget.email,
                      password: '',
                      firebaseuid: registereduserCredential == null
                          ? ""
                          : registereduserCredential.user == null
                              ? ""
                              : registereduserCredential.user!.uid,
                      nickname: name.trim(),
                      searchKey: name.trim().substring(0, 1).toUpperCase(),
                      phone: "",
                      phoneRaw: "",
                      countryCode: "",
                      photoUrl: registereduserCredential == null
                          ? ""
                          : registereduserCredential.user == null
                              ? ""
                              : registereduserCredential.user!.photoURL ?? "",
                      aboutMe: '',
                      actionmessage:
                          widget.basicSettings.accountapprovalmessage ?? '',
                      currentDeviceID: deviceid,
                      privateKey: "",
                      publicKey: "",
                      accountstatus:
                          widget.basicSettings.customerVerificationNeeded ==
                                  true
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
                      lastNotificationSeen:
                          DateTime.now().millisecondsSinceEpoch,
                      isNotificationStringsMulitilanguageEnabled: false,
                      notificationStringsMap: {},
                      kycMap: {},
                      geoMap: {},
                      phonenumbervariants: [],
                      hidden: [],
                      locked: [],
                      notificationTokens: [fcmToken],
                      deviceDetails: mapDeviceInfo,
                      quickReplies: [],
                      lastVerified: 0,
                      ratings: [],
                      totalRepliesInTickets: 0,
                      twoFactorVerification: {},
                      userTypeIndex: Usertype.customer.index,
                    ).toMap())
                .toMap(),
            BatchWriteComponent(
                ref: FirebaseFirestore.instance
                    .collection(DbPaths.collectioncustomers)
                    .doc(finalID)
                    .collection(DbPaths.customernotifications)
                    .doc(DbPaths.customernotifications),
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
                  Dbkeys.nOTIFICATIONxxpageID: DbPaths.customernotifications,
                  //-----
                  Dbkeys.nOTIFICATIONpagecollection1:
                      DbPaths.collectioncustomers,
                  Dbkeys.nOTIFICATIONpagedoc1: finalID,
                  Dbkeys.nOTIFICATIONpagecollection2:
                      DbPaths.agentnotifications,
                  Dbkeys.nOTIFICATIONpagedoc2: DbPaths.customernotifications,
                  Dbkeys.nOTIFICATIONtopic: Dbkeys.topicCUSTOMERS,
                  Dbkeys.list: [],
                }).toMap(),
            BatchWriteComponent(
              ref: FirebaseFirestore.instance
                  .collection(DbPaths.userapp)
                  .doc(DbPaths.docusercount),
              map: widget.basicSettings.customerVerificationNeeded == false
                  ? {
                      Dbkeys.totalapprovedcustomers: FieldValue.increment(1),
                    }
                  : {
                      Dbkeys.totalpendingcustomers: FieldValue.increment(1),
                    },
            ).toMap(),
            // BatchWriteComponent(
            //   ref: FirebaseFirestore.instance
            //       .collection(DbPaths.collectioncountrywiseAgentData)
            //       .doc(widget.onlyCode),
            //   map: {
            //     Dbkeys.totalusers: FieldValue.increment(1),
            //   },
            // ).toMap(),
            BatchWriteComponent(
                    ref: FirebaseFirestore.instance
                        .collection(DbPaths.collectioncustomers)
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
                      fullname: name.trim(),
                      id: finalID,
                      phone: "",
                      photourl: registereduserCredential == null
                          ? ""
                          : registereduserCredential.user == null
                              ? ""
                              : registereduserCredential.user!.photoURL ?? "",
                      usertype: Usertype.customer.index,
                      email: widget.email,
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
            //         ? '${name.trim()} has Joined $Appname. APPROVE the agent account (ID:$finalID). You can view the agent profile from All Agents page.'
            //         : '${name.trim()} has Joined $Appname. You can view the agent profile from All Agents page.',
            //     Dbkeys.nOTIFICATIONxxtitle: 'New Agent Joined',
            //     Dbkeys.nOTIFICATIONxximageurl: registereduserCredential == null
            //         ? ""
            //         : registereduserCredential.user == null
            //             ? ""
            //             : registereduserCredential.user!.photoURL ?? "",
            //     Dbkeys.nOTIFICATIONxxlastupdateepoch:
            //         DateTime.now().millisecondsSinceEpoch,
            //   },
            // ).toMap(),
            // BatchWriteComponent(
            //   ref: FirebaseFirestore.instance
            //       .collection(DbPaths.collectioncustomers)
            //       .doc(finalID),
            //   map: {
            //     Dbkeys.notificationTokens: [fcmToken]
            //   },
            // ).toMap()
          ]).then((value) async {
            if (value == false) {
              //faild to write
              if (registereduserCredential != null) {
                final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                await firebaseAuth.signOut();
              }

              Navigator.of(context).pop();
              showERRORSheet(context, "EM_100",
                  message:
                      "Login failed !\n\n. Error occured while authentication. Please try again,  Failed to batch Write for Customer Doc");
            } else {
              // if (observer.userAppSettingsDoc!.autoJoinNewAgentsToDefaultList ==
              //     true) {
              //   FirebaseFirestore.instance
              //       .collection(DbPaths.userapp)
              //       .doc(DbPaths.appsettings)
              //       .set(
              //           {Dbkeys.departmentList: list}, SetOptions(merge: true));
              // }
              // Write data to local
              await widget.prefs.setString(
                Dbkeys.firebaseuid,
                registereduserCredential == null
                    ? ""
                    : registereduserCredential.user == null
                        ? ""
                        : registereduserCredential.user!.uid,
              );
              await widget.prefs.setString(Dbkeys.id, finalID);
              await widget.prefs.setString(Dbkeys.nickname, name.trim());
              await widget.prefs.setString(
                Dbkeys.photoUrl,
                registereduserCredential == null
                    ? ""
                    : registereduserCredential.user == null
                        ? ""
                        : registereduserCredential.user!.photoURL ?? "",
              );
              await widget.prefs.setString(Dbkeys.phone, "");
              await widget.prefs.setString(Dbkeys.countryCode, "");
              await widget.prefs
                  .setInt(Dbkeys.userLoginType, Usertype.customer.index);

              unawaited(widget.prefs.setBool(Dbkeys.isTokenGenerated, true));
              await FirebaseApi.runTransactionRecordActivity(
                parentid: "CUSTOMER_REGISTRATION--$finalID",
                title: "New Customer Joined",
                postedbyID: "sys",
                onErrorFn: (e) {},
                onSuccessFn: () {},
                styledDesc: widget.basicSettings.customerVerificationNeeded ==
                        true
                    ? '<bold>${name.trim()}</bold> has Joined $Appname. APPROVE the customer account <bold>(ID:$finalID)</bold>. You can view the customer profile from All Customers page.'
                    : '<bold>${name.trim()}</bold> has Joined $Appname. You can view the customer account <bold>(ID:$finalID)</bold> from <bold>All Customers</bold> page.',
                plainDesc: widget.basicSettings.customerVerificationNeeded ==
                        true
                    ? '${name.trim()} has Joined $Appname. APPROVE the customer account (ID:$finalID). You can view the customer profile from All Customers page.'
                    : '${name.trim()} has Joined $Appname. You can view the customer profile from All Customers page.',
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
                (route) =>
                    false, //if you want to disable back feature set to false
              );
            }
          });
        }
      }
    }
  }

  updateExistingUser(DocumentSnapshot doc, int tries,
      {UserCredential? registereduserCredential}) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    if (registereduserCredential != null) {
      if (widget.basicSettings.customerLoginEnabled == false) {
        await firebaseAuth.signOut();

        Navigator.of(context).pop();
        widget.onError(
          getTranslatedForCurrentUser(context, 'xxfailedxx'),
          getTranslatedForCurrentUser(context, 'xxxlogintempdisbaledxxx'),
          '',
        );
      } else {
        // freshly registered in firebase - need to update firebase UID & notifcation token
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken == null) {
          if (tries > 5) {
            firebaseAuth.signOut();
            Navigator.of(context).pop();
            showERRORSheet(context, "EM_106",
                message:
                    "Login failed !\n\n. Error: After Multiple tries to fetch fcmTokens, failed to get token.");
          } else {
            await updateExistingUser(doc, tries + 1,
                registereduserCredential: registereduserCredential);
          }
        } else {
          if (registereduserCredential.user == null) {
            firebaseAuth.signOut();
            Navigator.of(context).pop();
            showERRORSheet(context, "EM_107",
                message: "Login failed !\n\n. Error: Unexpected error occured");
          } else {
            await doc.reference.update({
              Dbkeys.userLoginType: LoginType.email.index,
              Dbkeys.email: widget.email,
              Dbkeys.firebaseuid: registereduserCredential.user!.uid,
              Dbkeys.notificationTokens: [fcmToken],
              Dbkeys.lastLogin: DateTime.now().millisecondsSinceEpoch,
              Dbkeys.currentDeviceID: deviceid,
              Dbkeys.deviceDetails: mapDeviceInfo
            });
            await widget.prefs.setString(
              Dbkeys.firebaseuid,
              registereduserCredential.user!.uid,
            );
            await widget.prefs.setString(Dbkeys.id, doc[Dbkeys.id]);
            await widget.prefs.setString(Dbkeys.nickname, doc[Dbkeys.nickname]);
            await widget.prefs
                .setString(Dbkeys.photoUrl, doc[Dbkeys.photoUrl] ?? '');
            await widget.prefs
                .setString(Dbkeys.aboutMe, doc[Dbkeys.aboutMe] ?? '');
            await widget.prefs.setString(Dbkeys.phone, doc[Dbkeys.phone] ?? '');
            await widget.prefs
                .setInt(Dbkeys.userLoginType, Usertype.customer.index);
            await subscribeToNotification(doc[Dbkeys.id], false);
            Utils.toast(
                getTranslatedForCurrentUser(context, 'xxwelcomebackxx'));
            Navigator.pushAndRemoveUntil<dynamic>(
              context,
              MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => AppWrapper(
                        loadAttempt: 0,
                      )),
              (route) =>
                  false, //if you want to disable back feature set to false
            );
          }
        }
      }
    } else {
      if (widget.basicSettings.customerLoginEnabled == false) {
        await firebaseAuth.signOut();

        Navigator.of(context).pop();
        widget.onError(
          getTranslatedForCurrentUser(context, 'xxfailedxx'),
          getTranslatedForCurrentUser(context, 'xxxlogintempdisbaledxxx'),
          '',
        );
      } else {
        //only update notifcation token
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken == null) {
          if (tries > 5) {
            firebaseAuth.signOut();
            Navigator.of(context).pop();
            showERRORSheet(context, "EM_106",
                message:
                    "Login failed !\n\n. Error: After Multiple tries to fetch fcmTokens, failed to get token.");
          } else {
            await updateExistingUser(doc, tries + 1,
                registereduserCredential: registereduserCredential);
          }
        } else {
          await doc.reference.update({
            Dbkeys.userLoginType: LoginType.email.index,
            Dbkeys.email: widget.email,
            Dbkeys.notificationTokens: [fcmToken],
            Dbkeys.lastLogin: DateTime.now().millisecondsSinceEpoch,
            Dbkeys.currentDeviceID: deviceid,
            Dbkeys.deviceDetails: mapDeviceInfo
          });
          await widget.prefs.setString(
            Dbkeys.firebaseuid,
            doc[Dbkeys.firebaseuid],
          );
          await widget.prefs.setString(Dbkeys.id, doc[Dbkeys.id]);
          await widget.prefs.setString(Dbkeys.nickname, doc[Dbkeys.nickname]);
          await widget.prefs
              .setString(Dbkeys.photoUrl, doc[Dbkeys.photoUrl] ?? '');
          await widget.prefs
              .setString(Dbkeys.aboutMe, doc[Dbkeys.aboutMe] ?? '');
          await widget.prefs.setString(Dbkeys.phone, doc[Dbkeys.phone] ?? '');
          await widget.prefs
              .setInt(Dbkeys.userLoginType, Usertype.customer.index);
          await subscribeToNotification(doc[Dbkeys.id], false);
          Utils.toast(getTranslatedForCurrentUser(context, 'xxwelcomebackxx'));
          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => AppWrapper(
                      loadAttempt: 0,
                    )),
            (route) => false, //if you want to disable back feature set to false
          );
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => AppWrapper(
                          loadAttempt: 0,
                        )),
                (route) =>
                    false, //if you want to disable back feature set to false
              );
            },
            icon: Icon(
              EvaIcons.arrowBack,
              size: 23,
              color: Mycolors.getColor(widget.prefs, Colortype.primary.index),
            )),
        title: MtCustomfontBoldSemi(
          text:
              "${getTranslatedForCurrentUser(context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(context, 'xxaccountxx')}",
          fontsize: 17,
          color: Mycolors.black,
        ),
      ),
      body: isAskName == true
          ? ListView(
              padding: EdgeInsets.all(20),
              children: [
                Container(
                  margin: EdgeInsets.only(top: 0),
                  width: w / 1.24,
                  child: Form(
                    child: Column(
                      children: [
                        InpuTextBox(
                          controller: _name,
                          hinttext: getTranslatedForCurrentUser(
                              context, 'xxenterfullnamexx'),
                          title:
                              getTranslatedForCurrentUser(context, 'xxnamexx'),
                        ),
                        InpuTextBox(
                          isboldinput: true,
                          controller: _email,
                          disabled: true,
                          title:
                              getTranslatedForCurrentUser(context, 'xxemailxx'),
                        ),
                        InpuTextBox(
                          disabled: true,
                          obscuretext: true,
                          controller: _password,
                          title: getTranslatedForCurrentUser(
                              context, 'xxpasswordxx'),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        MtCustomfontLight(
                          text: getTranslatedForCurrentUser(
                                  context, 'xxplsremembercredxx')
                              .replaceAll(
                                  '(####)',
                                  getTranslatedForCurrentUser(
                                      context, 'xxcustomerxx')),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        MySimpleButtonWithIcon(
                          buttoncolor: Mycolors.getColor(
                              widget.prefs, Colortype.primary.index),
                          onpressed: () async {
                            if (_name.text.trim().length < 2) {
                              Utils.toast(getTranslatedForCurrentUser(
                                  context, 'xxentervalidnamexx'));
                            } else {
                              await createFreshNewAccountInFirebase(
                                  storedFinalID, 0,
                                  registereduserCredential:
                                      storedregistereduserCredential,
                                  name: _name.text.trim());
                            }
                          },
                          buttontext: getTranslatedForCurrentUser(
                              context, 'xxcreateacxx'),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )
          : isloading == true
              ? Center(
                  child: circularProgress(),
                )
              : ListView(
                  children: [],
                ),
    );
  }
}
