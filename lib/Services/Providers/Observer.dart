//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Models/basic_settings_model_userapp.dart';
import 'package:thinkcreative_technologies/Models/department_model.dart';
import 'package:thinkcreative_technologies/Models/userapp_settings_model.dart';
import 'package:flutter/foundation.dart';

class Observer with ChangeNotifier {
  bool isLoadedWebViewFirstpage = false;
  bool isOngoingCall = false;
  bool isblocknewlogins = false;
  // bool iscallsallowed = true;
  List<DepartmentModel> departmentlistlive = [];
  List<DepartmentModel> departmentlistotherthanDefault = [];
  UserAppSettingsModel? userAppSettingsDoc;
  BasicSettingModelUserApp? basicSettingDoc;
  bool istextmessagingallowed = true;
  bool ismediamessagingallowed = true;
  bool isadmobshow = false;

  bool is24hrsTimeformat = true;
  int groupMemberslimit = 100;
  int broadcastMemberslimit = 100;
  bool isPercentProgressShowWhileUploading = true;
  int maxFileSizeAllowedInMB = 60;
  //--
  int maxNoOfFilesInMultiSharing = 10;

  String appShareMessageStringAndroid = '';
  String appShareMessageStringiOS = '';
  bool isCustomAppShareLink = false;

  setisLoadedWebViewFirstpage(bool b) {
    isLoadedWebViewFirstpage = b;
    notifyListeners();
  }

  setbasicsettings({
    BasicSettingModelUserApp? basicModel,
  }) {
    this.basicSettingDoc = basicModel ?? this.basicSettingDoc;
    notifyListeners();
  }

  bool checkIfCurrentUserIsDemo(String id) {
    if (userAppSettingsDoc == null) {
      return false;
    } else {
      return userAppSettingsDoc!.demoIDsList!
              .indexWhere((element) => element['userid'] == id) >=
          0;
    }
  }

  setObserver(
      {UserAppSettingsModel? userAppSettings,
      String? currentUserID,
      required bool isAgent}) {
    this.userAppSettingsDoc = userAppSettings ?? this.userAppSettingsDoc;

    this.istextmessagingallowed =
        userAppSettings!.istextmessageallowed ?? this.istextmessagingallowed;
    this.ismediamessagingallowed =
        userAppSettings.ismediamessageallowed ?? this.ismediamessagingallowed;
    this.isadmobshow = userAppSettings.isadmobshow ?? this.isadmobshow;

    this.is24hrsTimeformat =
        userAppSettings.is24hrsTimeformat ?? this.is24hrsTimeformat;
    this.groupMemberslimit =
        userAppSettings.groupMemberslimit ?? this.groupMemberslimit;
    this.broadcastMemberslimit =
        userAppSettings.broadcastMemberslimit ?? this.broadcastMemberslimit;

    this.isPercentProgressShowWhileUploading =
        userAppSettings.isPercentProgressShowWhileUploading ??
            this.isPercentProgressShowWhileUploading;
    this.maxFileSizeAllowedInMB =
        userAppSettings.maxFileSizeAllowedInMB ?? this.maxFileSizeAllowedInMB;
    this.maxNoOfFilesInMultiSharing =
        userAppSettings.maxNoOfFilesInMultiSharing ??
            this.maxNoOfFilesInMultiSharing;

    this.appShareMessageStringAndroid =
        userAppSettings.appShareMessageStringAndroid ??
            this.appShareMessageStringAndroid;
    this.appShareMessageStringiOS = userAppSettings.appShareMessageStringiOS ??
        this.appShareMessageStringiOS;
    this.isCustomAppShareLink =
        userAppSettings.isCustomAppShareLink ?? this.isCustomAppShareLink;
    departmentlistlive = userAppSettings.departmentList!
        .where((element) =>
            element[Dbkeys.departmentTitle] != "Default" &&
            element[Dbkeys.departmentIsShow] == true)
        .map((e) => e = DepartmentModel.fromJson(e))
        .toList();
    departmentlistotherthanDefault = userAppSettings.departmentList!
        .where((element) => element[Dbkeys.departmentTitle] != "Default")
        .map((e) => e = DepartmentModel.fromJson(e))
        .toList();
    notifyListeners();
    if (currentUserID != null) {
      detectAndSetAgentsOffline(currentUserID, true);
      detectAndSetAgentsOffline(currentUserID, false);
    }
  }

  detectAndSetAgentsOffline(String currentUserID, bool isAgent) {
    CollectionReference ref = isAgent == true
        ? FirebaseFirestore.instance.collection(DbPaths.collectionagents)
        : FirebaseFirestore.instance.collection(DbPaths.collectioncustomers);

    ref
        .where(Dbkeys.lastSeen, isEqualTo: true)
        .where(Dbkeys.lastOnline,
            isLessThan: DateTime.now()
                .subtract(Duration(minutes: 10))
                .millisecondsSinceEpoch)
        .limit(10)
        .get()
        .then((allusers) async {
      if (allusers.docs.length > 0) {
        allusers.docs.forEach((eachUser) async {
          if (eachUser[Dbkeys.id] != currentUserID) {
            // if (eachUser.data()!.containsKey(Dbkeys.lastOnline)) {
            if (DateTime.now()
                    .difference(DateTime.fromMillisecondsSinceEpoch(
                        eachUser[Dbkeys.lastOnline]))
                    .inMinutes >=
                10) {
              eachUser.reference.update(
                  {Dbkeys.lastSeen: DateTime.now().millisecondsSinceEpoch});
            }
            // } else {
            //   eachUser.reference.update(
            //       {Dbkeys.lastSeen: DateTime.now().millisecondsSinceEpoch});
            // }
          }
        });
      }
    });
  }

  fetchUserAppSettingsFromFirestore() {
    FirebaseFirestore.instance
        .collection(DbPaths.userapp)
        .doc(DbPaths.appsettings)
        .get()
        .then((value) {
      if (value.exists) {
        setObserver(
            userAppSettings: UserAppSettingsModel.fromSnapshot(value),
            currentUserID: null,
            isAgent: true);
      }
    });
  }
}
