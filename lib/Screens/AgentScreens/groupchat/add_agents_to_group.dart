//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Models/user_registry_model.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/callhistory.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:thinkcreative_technologies/Services/FirebaseServices/firebase_api.dart';
import 'package:thinkcreative_technologies/Services/Providers/GroupChatProvider.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/DataModel.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custominput.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAgentsToGroup extends StatefulWidget {
  const AddAgentsToGroup({
    required this.currentUserID,
    required this.model,
    required this.biometricEnabled,
    required this.prefs,
    required this.isAddingWhileCreatingGroup,
    this.groupID,
  });
  final String? groupID;
  final String? currentUserID;
  final DataModel? model;
  final SharedPreferences prefs;
  final bool biometricEnabled;
  final bool isAddingWhileCreatingGroup;

  @override
  _AddAgentsToGroupState createState() => new _AddAgentsToGroupState();
}

class _AddAgentsToGroupState extends State<AddAgentsToGroup>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  Map<String?, String?>? contacts;
  List<UserRegistryModel> _selectedList = [];
  List<String> targetUserNotificationTokens = [];
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _filter = new TextEditingController();
  final TextEditingController groupname = new TextEditingController();
  final TextEditingController groupdesc = new TextEditingController();
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void dispose() {
    super.dispose();
    _filter.dispose();
  }

  loading() {
    return Stack(children: [
      Container(
        color: Colors.white,
        child: Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Mycolors.secondary),
        )),
      )
    ]);
  }

  bool iscreatinggroup = false;
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PickupLayout(
        curentUserID: widget.currentUserID!,
        prefs: widget.prefs,
        scaffold: Utils.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model!,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Consumer<UserRegistry>(
                  builder: (context, registry, _child) =>
                      Consumer<List<GroupModel>>(
                          builder: (context, groupList, _child) => Scaffold(
                              key: _scaffold,
                              backgroundColor: Colors.white,
                              appBar: AppBar(
                                leading: IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(
                                    Icons.arrow_back,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                                elevation: 0.4,
                                backgroundColor: Mycolors.getColor(
                                    widget.prefs, Colortype.primary.index),
                                centerTitle: false,
                                // leadingWidth: 40,
                                title: _selectedList.length == 0 ||
                                        widget.isAddingWhileCreatingGroup ==
                                            false
                                    ? Text(
                                        getTranslatedForCurrentUser(
                                                this.context,
                                                'xxselectxxtoaddxx')
                                            .replaceAll(
                                                '(####)',
                                                getTranslatedForCurrentUser(
                                                    this.context,
                                                    'xxagentsxx')),
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.left,
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            getTranslatedForCurrentUser(
                                                    this.context,
                                                    'xxselectxxtoaddxx')
                                                .replaceAll(
                                                    '(####)',
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxagentsxx')),
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            '${_selectedList.length} ${getTranslatedForCurrentUser(this.context, 'xxselectedxx')}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                actions: <Widget>[
                                  _selectedList.length == 0
                                      ? SizedBox()
                                      : IconButton(
                                          icon: Icon(
                                            Icons.check,
                                            color: Mycolors.black,
                                          ),
                                          onPressed:
                                              widget.isAddingWhileCreatingGroup ==
                                                      true
                                                  ? () async {
                                                      final observer =
                                                          Provider.of<Observer>(
                                                              context,
                                                              listen: false);
                                                      groupdesc.clear();
                                                      groupname.clear();
                                                      showModalBottomSheet(
                                                          isScrollControlled:
                                                              true,
                                                          context: context,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.vertical(
                                                                    top: Radius
                                                                        .circular(
                                                                            25.0)),
                                                          ),
                                                          builder: (BuildContext
                                                              context) {
                                                            // return your layout
                                                            var w =
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width;
                                                            return Padding(
                                                              padding: EdgeInsets.only(
                                                                  bottom: MediaQuery.of(
                                                                          context)
                                                                      .viewInsets
                                                                      .bottom),
                                                              child: Container(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              16),
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height /
                                                                      2.2,
                                                                  child: Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .stretch,
                                                                      children: [
                                                                        SizedBox(
                                                                          height:
                                                                              12,
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              3,
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(left: 8),
                                                                          child:
                                                                              Text(
                                                                            getTranslatedForCurrentUser(this.context,
                                                                                'xxsetgroupxx'),
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Container(
                                                                          margin:
                                                                              EdgeInsets.only(top: 10),
                                                                          padding: EdgeInsets.fromLTRB(
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                          // height: 63,
                                                                          height:
                                                                              83,
                                                                          width:
                                                                              w / 1.24,
                                                                          child:
                                                                              InpuTextBox(
                                                                            controller:
                                                                                groupname,
                                                                            leftrightmargin:
                                                                                0,
                                                                            showIconboundary:
                                                                                false,
                                                                            boxcornerradius:
                                                                                5.5,
                                                                            boxheight:
                                                                                50,
                                                                            hinttext:
                                                                                getTranslatedForCurrentUser(this.context, 'xxgroupnamexx'),
                                                                            prefixIconbutton:
                                                                                Icon(
                                                                              Icons.edit,
                                                                              color: Colors.grey.withOpacity(0.5),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          margin:
                                                                              EdgeInsets.only(top: 10),
                                                                          padding: EdgeInsets.fromLTRB(
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                          // height: 63,
                                                                          height:
                                                                              83,
                                                                          width:
                                                                              w / 1.24,
                                                                          child:
                                                                              InpuTextBox(
                                                                            maxLines:
                                                                                1,
                                                                            controller:
                                                                                groupdesc,
                                                                            leftrightmargin:
                                                                                0,
                                                                            showIconboundary:
                                                                                false,
                                                                            boxcornerradius:
                                                                                5.5,
                                                                            boxheight:
                                                                                50,
                                                                            hinttext:
                                                                                getTranslatedForCurrentUser(this.context, 'xxgroupdescxx'),
                                                                            prefixIconbutton:
                                                                                Icon(
                                                                              Icons.message,
                                                                              color: Colors.grey.withOpacity(0.5),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              6,
                                                                        ),
                                                                        myElevatedButton(
                                                                            color:
                                                                                Mycolors.secondary,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                                                              child: Text(
                                                                                getTranslatedForCurrentUser(this.context, 'xxcreategroupxx'),
                                                                                style: TextStyle(color: Colors.white, fontSize: 18),
                                                                              ),
                                                                            ),
                                                                            onPressed: observer.checkIfCurrentUserIsDemo(widget.currentUserID!) == true
                                                                                ? () {
                                                                                    Utils.toast(getTranslatedForCurrentUser(context, 'xxxnotalwddemoxxaccountxx'));
                                                                                  }
                                                                                : () async {
                                                                                    Navigator.of(_scaffold.currentContext!).pop();
                                                                                    List<String> listusers = [];
                                                                                    List<String> listmembers = [];
                                                                                    _selectedList.forEach((element) {
                                                                                      listusers.add(element.id);
                                                                                      listmembers.add(element.id);

                                                                                      targetUserNotificationTokens.add(element.id);
                                                                                    });
                                                                                    listmembers.add(widget.currentUserID!);
                                                                                    if (widget.model!.currentUser![Dbkeys.notificationTokens].last != null) {
                                                                                      targetUserNotificationTokens.add(widget.model!.currentUser![Dbkeys.notificationTokens].last);
                                                                                    }

                                                                                    DateTime time = DateTime.now();
                                                                                    DateTime time2 = DateTime.now().add(Duration(seconds: 1));
                                                                                    String groupID = '${widget.currentUserID!.toString()}--${time.millisecondsSinceEpoch.toString()}';
                                                                                    Map<String, dynamic> groupdata = {
                                                                                      Dbkeys.groupDESCRIPTION: groupdesc.text.isEmpty ? '' : groupdesc.text.trim(),
                                                                                      Dbkeys.groupCREATEDON: time,
                                                                                      Dbkeys.groupCREATEDBY: widget.currentUserID,
                                                                                      Dbkeys.groupNAME: groupname.text.isEmpty ? 'Unnamed Group' : groupname.text.trim(),
                                                                                      Dbkeys.groupIDfiltered: groupID.replaceAll(RegExp('-'), '').substring(1, groupID.replaceAll(RegExp('-'), '').toString().length),
                                                                                      Dbkeys.groupISTYPINGUSERID: '',
                                                                                      Dbkeys.groupADMINLIST: [
                                                                                        widget.currentUserID
                                                                                      ],
                                                                                      Dbkeys.groupID: groupID,
                                                                                      Dbkeys.groupPHOTOURL: '',
                                                                                      Dbkeys.groupMEMBERSLIST: listmembers,
                                                                                      Dbkeys.groupLATESTMESSAGETIME: time.millisecondsSinceEpoch,
                                                                                      Dbkeys.groupTYPE: Dbkeys.groupTYPEallusersmessageallowed,
                                                                                      "exBool1": true,
                                                                                      "exBool2": true,
                                                                                      "exBool3": true,
                                                                                      "exBool4": true,
                                                                                      "exBool5": true,
                                                                                      "exBool6": true,
                                                                                      "exBool7": false,
                                                                                      "exBool8": false,
                                                                                      "exBool9": false,
                                                                                      "exBool10": false,
                                                                                      "exString1": "",
                                                                                      "exString2": "",
                                                                                      "exString3": "",
                                                                                      "exString4": "",
                                                                                      "exString5": "",
                                                                                      "exList1": [],
                                                                                      "exList2": [],
                                                                                      "exList3": [],
                                                                                      "exList4": [],
                                                                                      "exInt1": 0,
                                                                                      "exInt2": 0,
                                                                                      "exInt3": 0,
                                                                                      "exMap": {},
                                                                                    };

                                                                                    listmembers.forEach((element) {
                                                                                      groupdata.putIfAbsent(element.toString(), () => time.millisecondsSinceEpoch);

                                                                                      groupdata.putIfAbsent('$element-joinedOn', () => time.millisecondsSinceEpoch);
                                                                                    });
                                                                                    setStateIfMounted(() {
                                                                                      iscreatinggroup = true;
                                                                                    });
                                                                                    await FirebaseFirestore.instance.collection(DbPaths.collectionAgentGroups).doc(widget.currentUserID!.toString() + '--' + time.millisecondsSinceEpoch.toString()).set(groupdata).then((value) async {
                                                                                      await FirebaseFirestore.instance.collection(DbPaths.collectionAgentGroups).doc(widget.currentUserID!.toString() + '--' + time.millisecondsSinceEpoch.toString()).collection(DbPaths.collectiongroupChats).doc(time.millisecondsSinceEpoch.toString() + '--' + widget.currentUserID!.toString()).set({
                                                                                        Dbkeys.groupmsgCONTENT: '',
                                                                                        Dbkeys.deletedReason: '',
                                                                                        Dbkeys.groupmsgLISToptional: listusers,
                                                                                        Dbkeys.groupmsgTIME: time.millisecondsSinceEpoch,
                                                                                        Dbkeys.groupmsgSENDBY: widget.currentUserID,
                                                                                        Dbkeys.groupmsgISDELETED: false,
                                                                                        Dbkeys.groupmsgTYPE: Dbkeys.groupmsgTYPEnotificationCreatedGroup,
                                                                                      }).then((value) async {
                                                                                        await FirebaseFirestore.instance.collection(DbPaths.collectionAgentGroups).doc(widget.currentUserID!.toString() + '--' + time.millisecondsSinceEpoch.toString()).collection(DbPaths.collectiongroupChats).doc(time2.millisecondsSinceEpoch.toString() + '--' + widget.currentUserID!.toString()).set({
                                                                                          Dbkeys.groupmsgCONTENT: '',
                                                                                          Dbkeys.deletedReason: '',
                                                                                          Dbkeys.groupmsgLISToptional: listmembers,
                                                                                          Dbkeys.groupmsgTIME: time2.millisecondsSinceEpoch,
                                                                                          Dbkeys.groupmsgSENDBY: widget.currentUserID,
                                                                                          Dbkeys.groupmsgISDELETED: false,
                                                                                          Dbkeys.groupmsgTYPE: Dbkeys.groupmsgTYPEnotificationAddedUser,
                                                                                        }).then((val) async {
                                                                                          await FirebaseFirestore.instance.collection(DbPaths.collectiontemptokensforunsubscribe).doc(groupID).set({
                                                                                            Dbkeys.groupIDfiltered: '${groupID.replaceAll(RegExp('-'), '').substring(1, groupID.replaceAll(RegExp('-'), '').toString().length)}',
                                                                                            Dbkeys.notificationTokens: targetUserNotificationTokens,
                                                                                            'type': 'subscribe'
                                                                                          });
                                                                                        }).then((value) async {
                                                                                          await FirebaseFirestore.instance.collection(DbPaths.userapp).doc(DbPaths.docdashboarddata).update({
                                                                                            Dbkeys.totalAgentGroups: FieldValue.increment(1)
                                                                                          });
                                                                                          await FirebaseApi.runTransactionRecordActivity(parentid: "GROUP--${widget.currentUserID!.toString() + '--' + time.millisecondsSinceEpoch.toString()}", title: "New Group Created", postedbyID: widget.currentUserID!, onErrorFn: (e) {}, onSuccessFn: () {}, styledDesc: "New Group <bold>${groupname.text.isEmpty ? 'Unnamed Group' : groupname.text.trim()}</bold> Created by Agent ID: <bold>${widget.currentUserID}</bold>", plainDesc: "New Group ${groupname.text.isEmpty ? 'Unnamed Group' : groupname.text.trim()} Created by Agent ID: ${widget.currentUserID}");
                                                                                          Navigator.of(_scaffold.currentContext!).pop();
                                                                                        }).catchError((err) {
                                                                                          setStateIfMounted(() {
                                                                                            iscreatinggroup = false;
                                                                                          });

                                                                                          Utils.toast('Error Creating group. $err');
                                                                                          print('Error Creating group: $err');
                                                                                        });
                                                                                      });
                                                                                    });
                                                                                  }),
                                                                      ])),
                                                            );
                                                          });
                                                    }
                                                  : () async {
                                                      // List<String> listusers = [];
                                                      List<String> listmembers =
                                                          [];
                                                      _selectedList
                                                          .forEach((element) {
                                                        listmembers
                                                            .add(element.id);

                                                        targetUserNotificationTokens
                                                            .add(element.id);
                                                      });
                                                      DateTime time =
                                                          DateTime.now();

                                                      setStateIfMounted(() {
                                                        iscreatinggroup = true;
                                                      });

                                                      Map<String, dynamic>
                                                          docmap = {
                                                        Dbkeys.groupMEMBERSLIST:
                                                            FieldValue
                                                                .arrayUnion(
                                                                    listmembers)
                                                      };

                                                      _selectedList.forEach(
                                                          (element) async {
                                                        docmap.putIfAbsent(
                                                            '${element.id}-joinedOn',
                                                            () => time
                                                                .millisecondsSinceEpoch);
                                                        docmap.putIfAbsent(
                                                            '${element.id}',
                                                            () => time
                                                                .millisecondsSinceEpoch);
                                                      });
                                                      setStateIfMounted(() {});
                                                      try {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(DbPaths
                                                                .collectiontemptokensforunsubscribe)
                                                            .doc(widget.groupID)
                                                            .delete();
                                                      } catch (err) {}
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(DbPaths
                                                              .collectionAgentGroups)
                                                          .doc(widget.groupID)
                                                          .update(docmap)
                                                          .then((value) async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(DbPaths
                                                                .collectionAgentGroups)
                                                            .doc(widget.groupID)
                                                            .collection(DbPaths
                                                                .collectiongroupChats)
                                                            .doc(widget.groupID)
                                                            .set({
                                                          Dbkeys.groupmsgCONTENT:
                                                              '',
                                                          Dbkeys.deletedReason:
                                                              '',
                                                          Dbkeys.groupmsgLISToptional:
                                                              listmembers,
                                                          Dbkeys.groupmsgTIME: time
                                                              .millisecondsSinceEpoch,
                                                          Dbkeys.groupmsgSENDBY:
                                                              widget
                                                                  .currentUserID,
                                                          Dbkeys.groupmsgISDELETED:
                                                              false,
                                                          Dbkeys.groupmsgTYPE:
                                                              Dbkeys
                                                                  .groupmsgTYPEnotificationAddedUser,
                                                        }).then((v) async {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(DbPaths
                                                                  .collectiontemptokensforunsubscribe)
                                                              .doc(widget
                                                                  .groupID)
                                                              .set({
                                                            Dbkeys.groupIDfiltered:
                                                                '${widget.groupID!.replaceAll(RegExp('-'), '').substring(1, widget.groupID!.replaceAll(RegExp('-'), '').toString().length)}',
                                                            Dbkeys.notificationTokens:
                                                                targetUserNotificationTokens,
                                                            'type': 'subscribe'
                                                          });
                                                        }).then((value) async {
                                                          Navigator.of(context)
                                                              .pop();
                                                        }).catchError((err) {
                                                          setStateIfMounted(() {
                                                            iscreatinggroup =
                                                                false;
                                                          });

                                                          Utils.toast(
                                                              getTranslatedForCurrentUser(
                                                                  this.context,
                                                                  'xxerrorcreatinggroupxx'));
                                                        });
                                                      });
                                                    },
                                        )
                                ],
                              ),
                              bottomSheet: _selectedList.length == 0
                                  ? SizedBox(
                                      height: 0,
                                      width: 0,
                                    )
                                  : Container(
                                      padding: EdgeInsets.only(top: 6),
                                      width: MediaQuery.of(context).size.width,
                                      height: 94,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _selectedList.reversed
                                              .toList()
                                              .length,
                                          itemBuilder: (context, int i) {
                                            return Stack(
                                              children: [
                                                Container(
                                                  width: 90,
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          11, 10, 12, 10),
                                                  child: Column(
                                                    children: [
                                                      customCircleAvatar(
                                                          url: _selectedList
                                                              .reversed
                                                              .toList()[i]
                                                              .photourl,
                                                          radius: 20),
                                                      SizedBox(
                                                        height: 7,
                                                      ),
                                                      Text(
                                                        _selectedList.reversed
                                                            .toList()[i]
                                                            .fullname,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 17,
                                                  top: 5,
                                                  child: new InkWell(
                                                    onTap: () {
                                                      setStateIfMounted(() {
                                                        _selectedList.remove(
                                                            _selectedList
                                                                .reversed
                                                                .toList()[i]);
                                                      });
                                                    },
                                                    child: new Container(
                                                      width: 20.0,
                                                      height: 20.0,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      decoration:
                                                          new BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.black,
                                                      ),
                                                      child: Icon(
                                                        Icons.close,
                                                        size: 14,
                                                        color: Colors.white,
                                                      ),
                                                    ), //............
                                                  ),
                                                )
                                              ],
                                            );
                                          }),
                                    ),
                              body: RefreshIndicator(
                                  onRefresh: () {
                                    return registry.fetchUserRegistry(context);
                                  },
                                  child: iscreatinggroup == true
                                      ? loading()
                                      : registry.agents.length == 0
                                          ? ListView(
                                              shrinkWrap: true,
                                              children: [
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          top: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              2.5),
                                                      child: Center(
                                                        child: Text(
                                                            getTranslatedForCurrentUser(
                                                                context,
                                                                'xxnosearchresultxx'),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Mycolors
                                                                    .grey)),
                                                      ))
                                                ])
                                          : Padding(
                                              padding: EdgeInsets.only(
                                                  bottom:
                                                      _selectedList.length == 0
                                                          ? 0
                                                          : 80),
                                              child: Stack(
                                                children: [
                                                  FutureBuilder(
                                                      future: Future.delayed(
                                                          Duration(seconds: 2)),
                                                      builder: (c, s) =>
                                                          s.connectionState ==
                                                                  ConnectionState
                                                                      .done
                                                              ? Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            30),
                                                                    child: Card(
                                                                      elevation:
                                                                          0.5,
                                                                      color: Colors
                                                                              .grey[
                                                                          100],
                                                                      child: Container(
                                                                          padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                                                                          child: RichText(
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            text:
                                                                                TextSpan(
                                                                              children: [
                                                                                WidgetSpan(
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(bottom: 2.5, right: 4),
                                                                                    child: Icon(
                                                                                      Icons.person,
                                                                                      color: Mycolors.secondary.withOpacity(0.7),
                                                                                      size: 14,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                TextSpan(text: getTranslatedForCurrentUser(context, 'xxnoxxavailabletoaddxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxagentsxx')), style: TextStyle(color: Mycolors.secondary.withOpacity(0.7), height: 1.3, fontSize: 13, fontWeight: FontWeight.w400)),
                                                                              ],
                                                                            ),
                                                                          )),
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                  child: Padding(
                                                                      padding: EdgeInsets.all(30),
                                                                      child: CircularProgressIndicator(
                                                                        valueColor:
                                                                            AlwaysStoppedAnimation<Color>(Mycolors.secondary),
                                                                      )),
                                                                )),
                                                  ListView.builder(
                                                    physics:
                                                        AlwaysScrollableScrollPhysics(),
                                                    padding: EdgeInsets.all(10),
                                                    itemCount:
                                                        registry.agents.length,
                                                    itemBuilder:
                                                        (context, idx) {
                                                      String uid = registry
                                                          .agents[idx].id;
                                                      Widget? alreadyAddedUser = widget
                                                                  .isAddingWhileCreatingGroup ==
                                                              true
                                                          ? null
                                                          : groupList
                                                                      .lastWhere((element) =>
                                                                          element.docmap[Dbkeys.groupID] ==
                                                                          widget
                                                                              .groupID)
                                                                      .docmap[Dbkeys
                                                                          .groupMEMBERSLIST]
                                                                      .contains(
                                                                          uid) ||
                                                                  groupList
                                                                      .lastWhere((element) =>
                                                                          element.docmap[Dbkeys
                                                                              .groupID] ==
                                                                          widget
                                                                              .groupID)
                                                                      .docmap[Dbkeys
                                                                          .groupADMINLIST]
                                                                      .contains(
                                                                          uid)
                                                              ? SizedBox()
                                                              : null;
                                                      return widget
                                                                  .currentUserID ==
                                                              uid
                                                          ? SizedBox()
                                                          : alreadyAddedUser ??
                                                              Container(
                                                                  color: Colors
                                                                      .white,
                                                                  child: Column(
                                                                    children: [
                                                                      ListTile(
                                                                        tileColor:
                                                                            Colors.white,
                                                                        leading:
                                                                            customCircleAvatar(
                                                                          url: registry
                                                                              .getUserData(context, uid)
                                                                              .photourl,
                                                                          radius:
                                                                              22.5,
                                                                        ),
                                                                        trailing:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            border:
                                                                                Border.all(color: Mycolors.grey, width: 1),
                                                                            borderRadius:
                                                                                BorderRadius.circular(5),
                                                                          ),
                                                                          child: _selectedList.lastIndexWhere((element) => element.id == uid) >= 0
                                                                              ? Icon(
                                                                                  Icons.check,
                                                                                  size: 19.0,
                                                                                  color: Mycolors.secondary,
                                                                                )
                                                                              : Icon(
                                                                                  null,
                                                                                  size: 19.0,
                                                                                ),
                                                                        ),
                                                                        title: Text(
                                                                            registry.getUserData(context, uid).fullname,
                                                                            style: TextStyle(color: Mycolors.black)),
                                                                        subtitle: Text(
                                                                            "${getTranslatedForCurrentUser(context, 'xxidxx')} " +
                                                                                registry.getUserData(context, uid).id.toString(),
                                                                            style: TextStyle(color: Mycolors.grey)),
                                                                        contentPadding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10.0,
                                                                            vertical:
                                                                                0.0),
                                                                        onTap:
                                                                            () {
                                                                          setStateIfMounted(
                                                                              () {
                                                                            if (_selectedList.lastIndexWhere((element) => element.id == uid) >=
                                                                                0) {
                                                                              _selectedList.remove(registry.getUserData(context, uid));
                                                                              setStateIfMounted(() {});
                                                                            } else {
                                                                              _selectedList.add(registry.getUserData(context, uid));
                                                                              setStateIfMounted(() {});
                                                                            }
                                                                          });
                                                                        },
                                                                      ),
                                                                      Divider()
                                                                    ],
                                                                  ));
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )))));
            }))));
  }
}
