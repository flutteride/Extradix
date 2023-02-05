//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/number_limits.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/DataModel.dart';
import 'package:thinkcreative_technologies/Models/department_model.dart';
import 'package:thinkcreative_technologies/Models/userapp_settings_model.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:thinkcreative_technologies/Screens/department/add_agents_to_department.dart';
import 'package:thinkcreative_technologies/Screens/department/department_details.dart';
import 'package:thinkcreative_technologies/Screens/department/set_department_manager.dart';
import 'package:thinkcreative_technologies/Services/FirebaseServices/firebase_api.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/widgets/CustomAlertDialog/CustomDialog.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custominput.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/loadingDialog.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/page_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/myscaffold.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/nodata_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllDepartmentList extends StatefulWidget {
  final String currentuserid;
  final bool ishidebackbutton;
  final bool showOnlyWhereManager;
  final Function onbackpressed;
  final SharedPreferences prefs;
  final DataModel cachedModel;
  const AllDepartmentList(
      {Key? key,
      required this.currentuserid,
      required this.showOnlyWhereManager,
      required this.ishidebackbutton,
      required this.cachedModel,
      required this.prefs,
      required this.onbackpressed})
      : super(key: key);

  @override
  _AllDepartmentListState createState() => _AllDepartmentListState();
}

class _AllDepartmentListState extends State<AllDepartmentList> {
  DocumentReference docRef = FirebaseFirestore.instance
      .collection(DbPaths.userapp)
      .doc(DbPaths.appsettings);
  String error = "";
  bool isloading = true;
  UserAppSettingsModel? userAppSettings;
  List<dynamic> departments = [];
  final TextEditingController _textEditingController =
      new TextEditingController();
  bool isAll = true;
  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  filterManagerOnly() async {
    setState(() {
      isloading = true;
    });
    await docRef.get().then((dc) async {
      if (dc.exists) {
        userAppSettings = UserAppSettingsModel.fromSnapshot(dc);

        departments = userAppSettings!.departmentList!
            .where((dept) =>
                (dept[Dbkeys.departmentManagerID] == widget.currentuserid) &&
                dept[Dbkeys.departmentTitle].toString().trim() != "Default")
            .toList()
            .reversed
            .toList();

        setState(() {
          isloading = false;
          isAll = false;
        });
      } else {
        setState(() {
          error =
              "User App setup is not completed yet. Kindly complete the User App Setup & Installation process & Reload the app ";
        });
      }
    }).catchError((onError) {
      setState(() {
        error =
            "User App setup is not completed yet. Kindly complete the User App Setup & Installation process & Reload the app $onError";

        isloading = false;
      });
    });
  }

  fetchdata() async {
    setState(() {
      isloading = true;
    });
    await docRef.get().then((dc) async {
      if (dc.exists) {
        userAppSettings = UserAppSettingsModel.fromSnapshot(dc);
        if (widget.showOnlyWhereManager == true) {
          departments = userAppSettings!.departmentList!
              .where((dept) =>
                  (dept[Dbkeys.departmentManagerID] == widget.currentuserid ||
                      dept[Dbkeys.departmentAgentsUIDList]
                          .contains(widget.currentuserid)) &&
                  dept[Dbkeys.departmentTitle] != "Default")
              .toList()
              .reversed
              .toList();
        } else {
          departments = userAppSettings!.departmentList!
              .where((dept) => dept[Dbkeys.departmentTitle] != "Default")
              .toList()
              .reversed
              .toList();
          // if (Optionalconstants.isEditDefaultDepartment == false) {
          //   departments.removeLast();
          // }
        }

        setState(() {
          isloading = false;
          isAll = true;
        });
      } else {
        setState(() {
          error =
              "User App setup is not completed yet. Kindly complete the User App Setup & Installation process & Reload the app ";
        });
      }
    }).catchError((onError) {
      setState(() {
        error =
            "User App setup is not completed yet. Kindly complete the User App Setup & Installation process & Reload the app $onError";

        isloading = false;
      });
    });
  }

  addNewDepartment(BuildContext context) async {
    var registry = Provider.of<UserRegistry>(context, listen: false);
    final observer = Provider.of<Observer>(context, listen: false);
    await pageOpenOnTop(
        context,
        AddAgentsToDepartment(
          currentuserid: widget.currentuserid,
          prefs: widget.prefs,
          isdepartmentalreadycreated: false,
          agents: registry.agents,
          onselectagents: (agentids, agentmodels) async {
            await pageOpenOnTop(
                context,
                SetDepartmentManager(
                  currentUserId: widget.currentuserid,
                  prefs: widget.prefs,
                  selecteduser: (manager) {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(25.0)),
                        ),
                        builder: (BuildContext context) {
                          // return your layout
                          var w = MediaQuery.of(context).size.width;
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: Container(
                                padding: EdgeInsets.all(16),
                                height: MediaQuery.of(context).size.height >
                                        MediaQuery.of(context).size.width
                                    ? MediaQuery.of(context).size.height / 2
                                    : MediaQuery.of(context).size.height / 1.6,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(
                                        height: 12,
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 7),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              getTranslatedForCurrentUser(
                                                      context, 'xxaddnewxxxx')
                                                  .replaceAll(
                                                      '(####)',
                                                      getTranslatedForCurrentUser(
                                                          context,
                                                          'xxdepartmentxx')),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.5),
                                            ),
                                            SizedBox(
                                              height: 18,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  EvaIcons.person,
                                                  color: Mycolors.yellow,
                                                ),
                                                SizedBox(
                                                  width: 7,
                                                ),
                                                Text(
                                                  getTranslatedForCurrentUser(
                                                              context,
                                                              'xxselectedxxxx')
                                                          .replaceAll(
                                                              '(####)',
                                                              getTranslatedForCurrentUser(
                                                                  context,
                                                                  'xxagentsxx')) +
                                                      " : " +
                                                      (agentids.length)
                                                          .toString(),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 13.5),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${getTranslatedForCurrentUser(context, 'xxdepartmentmanagerxx')} : ",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      color: Mycolors.pink,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13.5),
                                                ),
                                                SizedBox(
                                                  width: 7,
                                                ),
                                                Text(
                                                  manager.fullname,
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 13.5),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        // height: 63,
                                        height: 93,
                                        width: w / 1.24,
                                        child: InpuTextBox(
                                          controller: _textEditingController,
                                          leftrightmargin: 0,
                                          showIconboundary: false,
                                          maxcharacters: Numberlimits
                                              .maxdepartmenttitlechar,
                                          boxcornerradius: 5.5,
                                          boxheight: 70,
                                          hinttext:
                                              "${getTranslatedForCurrentUser(context, 'xxdepartmentxx')} ${getTranslatedForCurrentUser(context, 'xxtitlexx')}",
                                          prefixIconbutton: Icon(
                                            Icons.location_city,
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      MySimpleButton(
                                        buttontext: getTranslatedForCurrentUser(
                                                context, 'xxaddnewxxxx')
                                            .replaceAll(
                                                '(####)',
                                                getTranslatedForCurrentUser(
                                                    context, 'xxdepartmentxx'))
                                            .toUpperCase(),
                                        onpressed:
                                            observer.checkIfCurrentUserIsDemo(
                                                        widget.currentuserid) ==
                                                    true
                                                ? () {
                                                    Utils.toast(
                                                        getTranslatedForCurrentUser(
                                                            context,
                                                            'xxxnotalwddemoxxaccountxx'));
                                                  }
                                                : () async {
                                                    if (_textEditingController
                                                            .text
                                                            .trim()
                                                            .length <
                                                        2) {
                                                      Utils.toast(
                                                        getTranslatedForCurrentUser(
                                                                context,
                                                                'xxvalidxxxx')
                                                            .replaceAll(
                                                                '(####)',
                                                                getTranslatedForCurrentUser(
                                                                    context,
                                                                    'xxtitlexx')),
                                                      );
                                                    } else if (_textEditingController
                                                                .text
                                                                .trim() ==
                                                            "Default" ||
                                                        _textEditingController
                                                                .text
                                                                .trim() ==
                                                            "default") {
                                                      Utils.toast(
                                                          "This title cannot be used !");
                                                    } else if (_textEditingController
                                                            .text
                                                            .trim()
                                                            .length >
                                                        Numberlimits
                                                            .maxdepartmenttitlechar) {
                                                      Utils.toast(
                                                          getTranslatedForCurrentUser(
                                                                  context,
                                                                  'xxmaxxxcharxx')
                                                              .replaceAll(
                                                                  '(####)',
                                                                  "${Numberlimits.maxdepartmenttitlechar}"));
                                                    } else {
                                                      Navigator.of(context)
                                                          .pop();
                                                      setState(() {
                                                        isloading = true;
                                                      });
                                                      int epoch = DateTime.now()
                                                          .millisecondsSinceEpoch;
                                                      await docRef
                                                          .get()
                                                          .then((value) async {
                                                        if (value.exists) {
                                                          UserAppSettingsModel
                                                              userAppSettingsModel =
                                                              UserAppSettingsModel
                                                                  .fromSnapshot(
                                                                      value);
                                                          if (userAppSettingsModel.departmentList!.indexWhere((element) =>
                                                                      element[Dbkeys
                                                                              .departmentTitle]
                                                                          .toString()
                                                                          .toLowerCase()
                                                                          .trim() ==
                                                                      _textEditingController
                                                                          .text
                                                                          .trim()
                                                                          .toLowerCase()) >=
                                                                  0 ||
                                                              _textEditingController
                                                                      .text
                                                                      .trim() ==
                                                                  "Default" ||
                                                              _textEditingController
                                                                      .text
                                                                      .trim() ==
                                                                  "default") {
                                                            setState(() {
                                                              isloading = false;
                                                            });
                                                            Utils.toast(getTranslatedForCurrentUser(
                                                                    context,
                                                                    'xxfailedtocreatedeptxx')
                                                                .replaceAll(
                                                                    '(####)',
                                                                    getTranslatedForCurrentUser(
                                                                        context,
                                                                        'xxdepartmentxx')));
                                                          } else {
                                                            await docRef.update({
                                                              Dbkeys.departmentList:
                                                                  FieldValue
                                                                      .arrayUnion([
                                                                DepartmentModel(
                                                                        departmentManagerID: manager
                                                                            .id,
                                                                        departmentExtraMap1: {},
                                                                        departmentExtraMap2: {},
                                                                        departmentLogoURL:
                                                                            "",
                                                                        departmentLastEditedby: widget
                                                                            .currentuserid,
                                                                        departmentTitle: _textEditingController
                                                                            .text
                                                                            .trim(),
                                                                        departmentDesc:
                                                                            "",
                                                                        departmentAgentsUIDList:
                                                                            agentids,
                                                                        departmentIsShow:
                                                                            true,
                                                                        departmentCreatedby: widget
                                                                            .currentuserid,
                                                                        departmentLastEditedOn:
                                                                            epoch,
                                                                        departmentCreatedTime:
                                                                            epoch)
                                                                    .toMap()
                                                              ])
                                                            }).then(
                                                                (value) async {
                                                              await FirebaseApi
                                                                  .runTransactionRecordActivity(
                                                                      parentid:
                                                                          "DEPT--$epoch",
                                                                      isOnlyAlertNotSave:
                                                                          false,
                                                                      title:
                                                                          "New Department Created",
                                                                      plainDesc:
                                                                          "A New Department ${_textEditingController.text.trim()} has been created by ${widget.currentuserid}",
                                                                      styledDesc:
                                                                          "A New Department <bold>${_textEditingController.text.trim()}</bold> has been created by ${widget.currentuserid}.\n\n${agentids.length} Agent(s) assigned ID: ${agentids.toString()} ",
                                                                      onErrorFn:
                                                                          (e) {
                                                                        _textEditingController
                                                                            .clear();
                                                                        setState(
                                                                            () {
                                                                          isloading =
                                                                              false;
                                                                        });

                                                                        Utils.toast(
                                                                            "Failed to add new department ! ERROR: $e");
                                                                      },
                                                                      postedbyID:
                                                                          widget
                                                                              .currentuserid,
                                                                      onSuccessFn:
                                                                          () {
                                                                        _textEditingController
                                                                            .clear();
                                                                        fetchdata();
                                                                        agentids
                                                                            .forEach((element) {
                                                                          Utils.sendDirectNotification(
                                                                              title: "You are added to a New Department",
                                                                              parentID: "DEPT--$epoch",
                                                                              plaindesc: "A New Department ${_textEditingController.text.trim()} has been created by ${widget.currentuserid}. You are added as a member.",
                                                                              docRef: FirebaseFirestore.instance.collection(DbPaths.collectionagents).doc(element).collection(DbPaths.agentnotifications).doc(DbPaths.agentnotifications),
                                                                              postedbyID: widget.currentuserid);
                                                                        });
                                                                      });
                                                            });
                                                          }
                                                        } else {
                                                          setState(() {
                                                            isloading = false;
                                                            error =
                                                                "User App Settings does not exists";
                                                          });
                                                        }
                                                      });
                                                    }
                                                  },
                                      ),
                                    ])),
                          );
                        });
                  },
                  agents: agentmodels,
                  alreadyselecteduserid: "",
                ));
          },
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(context, listen: true);
    return PickupLayout(
        curentUserID: widget.currentuserid,
        prefs: widget.prefs,
        scaffold: Utils.getNTPWrappedWidget(MyScaffold(
          elevation: 0.5,
          isforcehideback: widget.ishidebackbutton == true,
          leadingIconData: LineAwesomeIcons.arrow_left,
          leadingIconPress: () {
            Navigator.of(context).pop();
            widget.onbackpressed();
          },
          icondata1: widget.showOnlyWhereManager == true ? null : Icons.add,
          icon1press: widget.showOnlyWhereManager == true
              ? () {}
              : () async {
                  await addNewDepartment(context);
                },
          title: widget.showOnlyWhereManager == true
              ? getTranslatedForCurrentUser(context, 'xxmyxxxxx').replaceAll(
                  '(####)',
                  getTranslatedForCurrentUser(context, 'xxdepartmentsxx'))
              : departments.length.toString() == "0"
                  ? getTranslatedForCurrentUser(context, 'xxdepartmentsxx')
                  : departments.length == 1
                      ? "1 ${getTranslatedForCurrentUser(context, 'xxdepartmentxx')}"
                      : "${departments.length.toString()} ${getTranslatedForCurrentUser(context, 'xxdepartmentsxx')}",
          body: error != ""
              ? Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        error,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Mycolors.red),
                      )),
                )
              : isloading == true
                  ? circularProgress()
                  : departments.length == 0
                      ? Center(
                          child: noDataWidget(
                              context: context,
                              iconData: Icons.location_city_rounded,
                              title: getTranslatedForCurrentUser(
                                      context, 'xxnoxxavailabletoaddxx')
                                  .replaceAll(
                                      '(####)',
                                      getTranslatedForCurrentUser(
                                          context, 'xxdepartmentsxx')),
                              subtitle: getTranslatedForCurrentUser(
                                      context, 'xxaddxxandxxxx')
                                  .replaceAll(
                                      '(####)',
                                      getTranslatedForCurrentUser(
                                          context, 'xxdepartmentxx'))
                                  .replaceAll(
                                      '(##)',
                                      getTranslatedForCurrentUser(
                                              context, 'xxdepartmentmanagerxx')
                                          .replaceAll(
                                              '(###)',
                                              getTranslatedForCurrentUser(
                                                  context, 'xxagentsxx')))),
                        )
                      : ListView(
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          children: [
                            widget.showOnlyWhereManager
                                ? Container(
                                    padding:
                                        EdgeInsets.only(bottom: 20, top: 10),
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MySimpleButton(
                                          buttontextcolor: isAll
                                              ? Mycolors.white
                                              : Mycolors.black,
                                          buttoncolor: isAll
                                              ? Mycolors.primary
                                              : Mycolors.greylightcolor,
                                          onpressed: () async {
                                            fetchdata();
                                          },
                                          borderradius: 10,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.2,
                                          buttontext:
                                              "${getTranslatedForCurrentUser(context, 'xxiamxxxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxagentxx'))} (${departments.length})",
                                          height: 38,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        MySimpleButton(
                                          buttontextcolor: !isAll
                                              ? Mycolors.white
                                              : Mycolors.black,
                                          buttoncolor: !isAll
                                              ? Mycolors.primary
                                              : Mycolors.greylightcolor,
                                          onpressed: () async {
                                            await filterManagerOnly();
                                          },
                                          height: 38,
                                          borderradius: 10,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.2,
                                          buttontext:
                                              "${getTranslatedForCurrentUser(context, 'xxiamxxxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxmanagerxx'))} (${departments.length})",
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: departments.length,
                                itemBuilder: (BuildContext context, int i) {
                                  return Card(
                                    elevation: 0.2,
                                    color: departments[i]
                                                [Dbkeys.departmentIsShow] ==
                                            false
                                        ? Colors.red[50]
                                        : Colors.white,
                                    margin: EdgeInsets.fromLTRB(4, 8, 4, 2),
                                    child: ListTile(
                                        onTap: () {
                                          pageNavigator(
                                              context,
                                              DepartmentDetails(
                                                  cachedModel:
                                                      widget.cachedModel,
                                                  prefs: widget.prefs,
                                                  showOnlyWhereManager: widget
                                                      .showOnlyWhereManager,
                                                  currentuserid:
                                                      widget.currentuserid,
                                                  onrefreshPreviousPage: () {
                                                    fetchdata();
                                                  },
                                                  departmentID: departments[i][
                                                          Dbkeys
                                                              .departmentTitle]
                                                      .toString()));
                                        },
                                        trailing: IconButton(
                                            onPressed: () {
                                              pageNavigator(
                                                  context,
                                                  DepartmentDetails(
                                                      cachedModel:
                                                          widget.cachedModel,
                                                      prefs: widget.prefs,
                                                      showOnlyWhereManager: widget
                                                          .showOnlyWhereManager,
                                                      currentuserid:
                                                          widget.currentuserid,
                                                      onrefreshPreviousPage:
                                                          () {
                                                        fetchdata();
                                                      },
                                                      departmentID:
                                                          departments[i][Dbkeys
                                                                  .departmentTitle]
                                                              .toString()));
                                            },
                                            icon: Icon(Icons
                                                .keyboard_arrow_right_rounded)),
                                        contentPadding:
                                            EdgeInsets.fromLTRB(5, 8, 2, 8),
                                        title: MtCustomfontBold(
                                          fontsize: 17,
                                          color: Mycolors.black,
                                          lineheight: 1.3,
                                          text: departments[i]
                                              [Dbkeys.departmentTitle],
                                        ),
                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              MtCustomfontRegular(
                                                  fontsize: 13,
                                                  text: departments[i][Dbkeys
                                                                  .departmentAgentsUIDList]
                                                              .length ==
                                                          1
                                                      ? "1 ${getTranslatedForCurrentUser(context, 'xxagentxx')}"
                                                      : departments[i][Dbkeys
                                                                  .departmentAgentsUIDList]
                                                              .length
                                                              .toString() +
                                                          " ${getTranslatedForCurrentUser(context, 'xxagentsxx')} "),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  departments[i][Dbkeys
                                                              .departmentIsShow] ==
                                                          true
                                                      ? SizedBox()
                                                      : Icon(
                                                          Icons.visibility_off,
                                                          size: 13,
                                                          color: Mycolors.red,
                                                        ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  FlutterSwitch(
                                                      activeColor:
                                                          Mycolors.green,
                                                      inactiveColor:
                                                          Mycolors.red,
                                                      width: 36,
                                                      toggleSize: 10,
                                                      height: 17,
                                                      value: departments[i][
                                                          Dbkeys
                                                              .departmentIsShow],
                                                      onToggle: (cv) async {
                                                        ShowConfirmDialog()
                                                            .open(
                                                                context:
                                                                    context,
                                                                subtitle: departments[i][Dbkeys.departmentIsShow] ==
                                                                        true
                                                                    ? getTranslatedForCurrentUser(context, 'xxareusurehidexx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxagentsxx')).replaceAll(
                                                                        '(###)',
                                                                        getTranslatedForCurrentUser(
                                                                            context,
                                                                            'xxcustomersxx'))
                                                                    : getTranslatedForCurrentUser(context, 'xxareusurelivexx')
                                                                        .replaceAll(
                                                                            '(####)',
                                                                            getTranslatedForCurrentUser(
                                                                                context, 'xxagentsxx'))
                                                                        .replaceAll(
                                                                            '(###)',
                                                                            getTranslatedForCurrentUser(context,
                                                                                'xxcustomersxx')),
                                                                title: getTranslatedForCurrentUser(
                                                                    context,
                                                                    'xxconfirmxx'),
                                                                rightbtnonpress:
                                                                    observer.checkIfCurrentUserIsDemo(widget.currentuserid) ==
                                                                            true
                                                                        ? () {
                                                                            Utils.toast(getTranslatedForCurrentUser(context,
                                                                                'xxxnotalwddemoxxaccountxx'));
                                                                          }
                                                                        : () async {
                                                                            Navigator.of(context).pop();
                                                                            if (departments[i][Dbkeys.departmentIsShow] == false &&
                                                                                departments[i][Dbkeys.departmentAgentsUIDList].length < 1) {
                                                                              Utils.toast(getTranslatedForCurrentUser(context, 'xxaddxxtoxxtobexx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxagentsxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxdepartmentxx')).replaceAll('(##)', getTranslatedForCurrentUser(context, 'xxcustomersxx'))

                                                                                  // "Add Agents to Department to Set it LIVE to be visible by customers"
                                                                                  );
                                                                            } else {
                                                                              setState(() {
                                                                                isloading = true;
                                                                              });
                                                                              await FirebaseApi.runUPDATEmapobjectinListField(
                                                                                  compareKey: Dbkeys.departmentTitle,
                                                                                  compareVal: departments[i][Dbkeys.departmentTitle],
                                                                                  docrefdata: docRef,
                                                                                  replaceableMapObjectWithOnlyFieldsRequired: {
                                                                                    Dbkeys.departmentIsShow: !departments[i][Dbkeys.departmentIsShow],
                                                                                    Dbkeys.departmentLastEditedOn: DateTime.now().millisecondsSinceEpoch
                                                                                  },
                                                                                  context: context,
                                                                                  listkeyname: Dbkeys.departmentList,
                                                                                  onSuccessFn: () async {
                                                                                    await FirebaseApi.runTransactionRecordActivity(
                                                                                        isOnlyAlertNotSave: false,
                                                                                        parentid: "DEPT--${departments[i][Dbkeys.departmentTitle]}",
                                                                                        title: "Department  status updated",
                                                                                        plainDesc: departments[i][Dbkeys.departmentIsShow] == true ? "Department ${departments[i][Dbkeys.departmentTitle]} status has been set to HIDDEN" : "Department ${departments[i][Dbkeys.departmentTitle]} status has been set to LIVE",
                                                                                        styledDesc: departments[i][Dbkeys.departmentIsShow] == true ? "<bold>${departments[i][Dbkeys.departmentTitle]}</bold> Department has been set to <bold>HIDDEN</bold> by Agent ID: ${widget.currentuserid}" : "<bold>${departments[i][Dbkeys.departmentTitle]}</bold> Department has been set to <bold>LIVE</bold> by Agent ID: ${widget.currentuserid}",
                                                                                        onErrorFn: (e) {
                                                                                          _textEditingController.clear();
                                                                                          fetchdata();

                                                                                          Utils.toast("Failed to update department status! ERROR: $e");
                                                                                        },
                                                                                        postedbyID: widget.currentuserid,
                                                                                        onSuccessFn: () {
                                                                                          _textEditingController.clear();
                                                                                          fetchdata();
                                                                                        });
                                                                                  },
                                                                                  onErrorFn: (String s) {
                                                                                    setState(() {
                                                                                      isloading = false;
                                                                                    });
                                                                                    Utils.toast("Error occured!. Error log: $s");
                                                                                  });
                                                                            }
                                                                          });
                                                      }),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        leading: Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: departments[i][Dbkeys
                                                      .departmentLogoURL] ==
                                                  ""
                                              ? Utils.squareAvatarIcon(
                                                  backgroundColor: Utils
                                                      .randomColorgenratorBasedOnFirstLetter(
                                                          departments[i][Dbkeys
                                                              .departmentTitle]),
                                                  iconData: Icons.location_city,
                                                  size: 55)
                                              : Utils.squareAvatarImage(
                                                  url: departments[i]
                                                      [Dbkeys.departmentLogoURL],
                                                  size: 55),
                                        )),
                                  );
                                }),
                          ],
                        ),
        )));
  }
}
