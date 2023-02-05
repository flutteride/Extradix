//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Models/userapp_settings_model.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/liveListener.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

bool isDepartmentBased(
    {UserAppSettingsModel? userappsettings, required BuildContext context}) {
  final observer = Provider.of<Observer>(context, listen: false);
  return userappsettings != null
      ? userappsettings.departmentBasedContent!
      : observer.userAppSettingsDoc!.departmentBasedContent!;
}

bool iAmDepartmentManager(
    {UserAppSettingsModel? userappsettings,
    required String currentuserid,
    required BuildContext context}) {
  final observer = Provider.of<Observer>(context, listen: false);
  return userappsettings != null
      ? userappsettings.departmentBasedContent!
          ? userappsettings.departmentList!
                      .where((dept) =>
                          dept[Dbkeys.departmentManagerID] == currentuserid)
                      .length >
                  0
              ? true
              : false
          : false
      : observer.userAppSettingsDoc!.departmentBasedContent!
          ? observer.userAppSettingsDoc!.departmentList!
                      .where((dept) =>
                          dept[Dbkeys.departmentManagerID] == currentuserid)
                      .length >
                  0
              ? true
              : false
          : false;
}

bool iAmSecondAdmin(
    {SpecialLiveConfigData? specialLiveConfigData,
    required String currentuserid,
    required BuildContext context}) {
  SpecialLiveConfigData? livedata =
      Provider.of<SpecialLiveConfigData?>(context, listen: false);
  bool isready = livedata == null
      ? false
      : !livedata.docmap.containsKey(Dbkeys.secondadminID) ||
              livedata.docmap[Dbkeys.secondadminID] == '' ||
              livedata.docmap[Dbkeys.secondadminID] == null
          ? false
          : true;
  return specialLiveConfigData == null
      ? isready == false
          ? false
          : livedata!.docmap[Dbkeys.secondadminID] == currentuserid
      : specialLiveConfigData.docmap[Dbkeys.secondadminID] == currentuserid;
}

int myJoinedDepertments(
    {UserAppSettingsModel? userappsettings,
    required String currentuserid,
    required BuildContext context}) {
  final observer = Provider.of<Observer>(context, listen: false);
  return userappsettings != null
      ? userappsettings.departmentList!
          .where((dept) =>
              dept[Dbkeys.departmentAgentsUIDList].contains(currentuserid) &&
              dept[Dbkeys.departmentTitle] != "Default")
          .length
      : observer.userAppSettingsDoc!.departmentList!
          .where((dept) =>
              dept[Dbkeys.departmentAgentsUIDList].contains(currentuserid) &&
              dept[Dbkeys.departmentTitle] != "Default")
          .length;
}
