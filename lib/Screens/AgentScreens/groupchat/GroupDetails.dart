//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Models/DataModel.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/groupchat/add_agents_to_group.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/groupchat/edit_group_details.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/callhistory.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:thinkcreative_technologies/Services/Admob/admob.dart';
import 'package:thinkcreative_technologies/Services/Providers/GroupChatProvider.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/widgets/ImagePicker/image_picker.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:thinkcreative_technologies/widgets/WarningWidgets/warning_tile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/optional_constants.dart';

class GroupDetails extends StatefulWidget {
  final DataModel model;
  final SharedPreferences prefs;
  final String currentUserID;
  final String groupID;
  const GroupDetails(
      {Key? key,
      required this.model,
      required this.prefs,
      required this.currentUserID,
      required this.groupID})
      : super(key: key);

  @override
  _GroupDetailsState createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  File? imageFile;

  getImage(File image) {
    // ignore: unnecessary_null_comparison
    if (image != null) {
      setStateIfMounted(() {
        imageFile = image;
      });
    }
    return uploadFile(false);
  }

  bool isloading = false;
  String? videometadata;
  int? uploadTimestamp;
  int? thumnailtimestamp;
  final TextEditingController textEditingController =
      new TextEditingController();
  final BannerAd myBanner = BannerAd(
    adUnitId: getBannerAdUnitId()!,
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  AdWidget? adWidget;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = Provider.of<Observer>(this.context, listen: false);
      if (IsBannerAdShow == true && observer.isadmobshow == true) {
        myBanner.load();
        adWidget = AdWidget(ad: myBanner);
        setState(() {});
      }
    });
  }

  Future uploadFile(bool isthumbnail) async {
    uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName = 'GROUP_ICON';
    Reference reference = FirebaseStorage.instance
        .ref("+00_AGENT_GROUP_MEDIA/${widget.groupID}/")
        .child(fileName);
    TaskSnapshot uploading = await reference.putFile(imageFile!);
    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }

    return uploading.ref.getDownloadURL();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  userAction(value, String targetUID, bool targetUIDIsAdmin,
      List targetUserNotificationTokens) async {
    final observer = Provider.of<Observer>(context, listen: false);
    if (value == 'Remove as Admin') {
      showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(
              getTranslatedForCurrentUser(context, 'xxremoveasadminxx'),
            ),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    getTranslatedForCurrentUser(context, 'xxcancelxx'),
                    style: TextStyle(
                        color: Mycolors.getColor(
                            widget.prefs, Colortype.primary.index),
                        fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                child: Text(
                  getTranslatedForCurrentUser(context, 'xxconfirmxx'),
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
                onPressed: observer
                            .checkIfCurrentUserIsDemo(widget.currentUserID) ==
                        true
                    ? () {
                        Utils.toast(getTranslatedForCurrentUser(
                            context, 'xxxnotalwddemoxxaccountxx'));
                      }
                    : () async {
                        Navigator.of(context).pop();
                        setStateIfMounted(() {
                          isloading = true;
                        });
                        await FirebaseFirestore.instance
                            .collection(DbPaths.collectionAgentGroups)
                            .doc(widget.groupID)
                            .update({
                          Dbkeys.groupADMINLIST:
                              FieldValue.arrayRemove([targetUID]),
                        }).then((value) async {
                          DateTime time = DateTime.now();
                          await FirebaseFirestore.instance
                              .collection(DbPaths.collectionAgentGroups)
                              .doc(widget.groupID)
                              .collection(DbPaths.collectiongroupChats)
                              .doc(time.millisecondsSinceEpoch.toString() +
                                  '--' +
                                  widget.currentUserID)
                              .set({
                            Dbkeys.groupmsgCONTENT: '',
                            Dbkeys.groupmsgLISToptional: [
                              targetUID,
                            ],
                            Dbkeys.groupmsgTIME: time.millisecondsSinceEpoch,
                            Dbkeys.groupmsgSENDBY: widget.currentUserID,
                            Dbkeys.groupmsgISDELETED: false,
                            Dbkeys.groupmsgTYPE: Dbkeys
                                .groupmsgTYPEnotificationUserRemovedAsAdmin,
                          });
                          setStateIfMounted(() {
                            isloading = false;
                          });
                        }).catchError((onError) {
                          setStateIfMounted(() {
                            isloading = false;
                          });
                          Utils.toast(
                              'Failed to set as Admin ! \nError occured -$onError');
                        });
                      },
              )
            ],
          );
        },
        context: context,
      );
    } else if (value == 'Set as Admin') {
      showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(
              getTranslatedForCurrentUser(context, 'xxsetasadminxx'),
            ),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    getTranslatedForCurrentUser(context, 'xxcancelxx'),
                    style: TextStyle(
                        color: Mycolors.getColor(
                            widget.prefs, Colortype.primary.index),
                        fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                child: Text(
                  getTranslatedForCurrentUser(context, 'xxconfirmxx'),
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
                onPressed: observer
                            .checkIfCurrentUserIsDemo(widget.currentUserID) ==
                        true
                    ? () {
                        Utils.toast(getTranslatedForCurrentUser(
                            context, 'xxxnotalwddemoxxaccountxx'));
                      }
                    : () async {
                        Navigator.of(context).pop();
                        setStateIfMounted(() {
                          isloading = true;
                        });
                        await FirebaseFirestore.instance
                            .collection(DbPaths.collectionAgentGroups)
                            .doc(widget.groupID)
                            .update({
                          Dbkeys.groupADMINLIST:
                              FieldValue.arrayUnion([targetUID]),
                        }).then((value) async {
                          DateTime time = DateTime.now();
                          await FirebaseFirestore.instance
                              .collection(DbPaths.collectionAgentGroups)
                              .doc(widget.groupID)
                              .collection(DbPaths.collectiongroupChats)
                              .doc(time.millisecondsSinceEpoch.toString() +
                                  '--' +
                                  widget.currentUserID)
                              .set({
                            Dbkeys.groupmsgCONTENT: '',
                            Dbkeys.deletedReason: '',
                            Dbkeys.groupmsgLISToptional: [
                              targetUID,
                            ],
                            Dbkeys.groupmsgTIME: time.millisecondsSinceEpoch,
                            Dbkeys.groupmsgSENDBY: widget.currentUserID,
                            Dbkeys.groupmsgISDELETED: false,
                            Dbkeys.groupmsgTYPE:
                                Dbkeys.groupmsgTYPEnotificationUserSetAsAdmin,
                          });
                          setStateIfMounted(() {
                            isloading = false;
                          });
                        }).catchError((onError) {
                          setStateIfMounted(() {
                            isloading = false;
                          });
                          Utils.toast(
                              'Failed to set as Admin ! \nError occured -$onError');
                        });
                      },
              )
            ],
          );
        },
        context: context,
      );
    } else if (value == 'Remove from Group') {
      showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(
              getTranslatedForCurrentUser(context, 'xxremovefromgroupxx'),
            ),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    getTranslatedForCurrentUser(context, 'xxcancelxx'),
                    style: TextStyle(
                        color: Mycolors.getColor(
                            widget.prefs, Colortype.primary.index),
                        fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                child: Text(
                  getTranslatedForCurrentUser(context, 'xxremovexx'),
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
                onPressed: observer
                            .checkIfCurrentUserIsDemo(widget.currentUserID) ==
                        true
                    ? () {
                        Utils.toast(getTranslatedForCurrentUser(
                            context, 'xxxnotalwddemoxxaccountxx'));
                      }
                    : () async {
                        Navigator.of(context).pop();
                        setStateIfMounted(() {
                          isloading = true;
                        });
                        try {
                          await FirebaseFirestore.instance
                              .collection(
                                  DbPaths.collectiontemptokensforunsubscribe)
                              .doc(targetUID)
                              .delete();
                        } catch (err) {}
                        await FirebaseFirestore.instance
                            .collection(
                                DbPaths.collectiontemptokensforunsubscribe)
                            .doc(targetUID)
                            .set({
                          Dbkeys.groupIDfiltered:
                              '${widget.groupID.replaceAll(RegExp('-'), '').substring(1, widget.groupID.replaceAll(RegExp('-'), '').toString().length)}',
                          Dbkeys.notificationTokens:
                              targetUserNotificationTokens,
                          'type': 'unsubscribe'
                        });

                        await FirebaseFirestore.instance
                            .collection(DbPaths.collectionAgentGroups)
                            .doc(widget.groupID)
                            .update(targetUIDIsAdmin == true
                                ? {
                                    Dbkeys.groupMEMBERSLIST:
                                        FieldValue.arrayRemove([targetUID]),
                                    Dbkeys.groupADMINLIST:
                                        FieldValue.arrayRemove([targetUID]),
                                    targetUID: FieldValue.delete(),
                                    '$targetUID-joinedOn': FieldValue.delete(),
                                    '$targetUID': FieldValue.delete(),
                                  }
                                : {
                                    Dbkeys.groupMEMBERSLIST:
                                        FieldValue.arrayRemove([targetUID]),
                                    targetUID: FieldValue.delete(),
                                    '$targetUID-joinedOn': FieldValue.delete(),
                                    '$targetUID': FieldValue.delete(),
                                  })
                            .then((value) async {
                          DateTime time = DateTime.now();
                          await FirebaseFirestore.instance
                              .collection(DbPaths.collectionAgentGroups)
                              .doc(widget.groupID)
                              .collection(DbPaths.collectiongroupChats)
                              .doc(time.millisecondsSinceEpoch.toString() +
                                  '--' +
                                  widget.currentUserID)
                              .set({
                            Dbkeys.groupmsgCONTENT:
                                '$targetUID ${getTranslatedForCurrentUser(context, 'xxremovedbyadminxx')}',
                            Dbkeys.deletedReason: '',
                            Dbkeys.groupmsgLISToptional: [
                              targetUID,
                            ],
                            Dbkeys.groupmsgTIME: time.millisecondsSinceEpoch,
                            Dbkeys.groupmsgSENDBY: widget.currentUserID,
                            Dbkeys.groupmsgISDELETED: false,
                            Dbkeys.groupmsgTYPE:
                                Dbkeys.groupmsgTYPEnotificationRemovedUser,
                          });
                          setStateIfMounted(() {
                            isloading = false;
                          });
                          try {
                            await FirebaseFirestore.instance
                                .collection(
                                    DbPaths.collectiontemptokensforunsubscribe)
                                .doc(targetUID)
                                .delete();
                          } catch (err) {}
                        }).catchError((onError) {
                          setStateIfMounted(() {
                            isloading = false;
                          });
                          // Utils.toast(
                          //     'Failed to remove ! \nError occured -$onError');
                        });
                      },
              )
            ],
          );
        },
        context: context,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (IsBannerAdShow == true) {
      myBanner.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    final observer = Provider.of<Observer>(context, listen: false);
    return PickupLayout(
        curentUserID: widget.currentUserID,
        prefs: widget.prefs,
        scaffold: Utils.getNTPWrappedWidget(
            Consumer<List<GroupModel>>(builder: (context, groupList, _child) {
          Map<dynamic, dynamic> groupDoc = groupList.indexWhere((element) =>
                      element.docmap[Dbkeys.groupID] == widget.groupID) <
                  0
              ? {}
              : groupList
                  .lastWhere((element) =>
                      element.docmap[Dbkeys.groupID] == widget.groupID)
                  .docmap;
          return Scaffold(
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
            appBar: AppBar(
              elevation: 0.4,
              titleSpacing: -5,
              leading: Container(
                margin: EdgeInsets.only(right: 0),
                width: 10,
                child: IconButton(
                  icon: Icon(
                    LineAwesomeIcons.arrow_left,
                    size: 24,
                    color: Mycolors.getColor(
                        widget.prefs, Colortype.primary.index),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              actions: <Widget>[
                groupDoc[Dbkeys.groupADMINLIST].contains(widget.currentUserID)
                    ? IconButton(
                        onPressed: observer.checkIfCurrentUserIsDemo(
                                    widget.currentUserID) ==
                                true
                            ? () {
                                Utils.toast(getTranslatedForCurrentUser(
                                    context, 'xxxnotalwddemoxxaccountxx'));
                              }
                            : () {
                                Navigator.push(
                                    this.context,
                                    new MaterialPageRoute(
                                        builder: (context) =>
                                            new EditGroupDetails(
                                              prefs: widget.prefs,
                                              currentUserID:
                                                  widget.currentUserID,
                                              isadmin: groupDoc[
                                                      Dbkeys.groupCREATEDBY] ==
                                                  widget.currentUserID,
                                              groupType:
                                                  groupDoc[Dbkeys.groupTYPE],
                                              groupDesc: groupDoc[
                                                  Dbkeys.groupDESCRIPTION],
                                              groupName:
                                                  groupDoc[Dbkeys.groupNAME],
                                              groupID: widget.groupID,
                                            )));
                              },
                        icon: Icon(
                          Icons.edit,
                          size: 21,
                          color: Mycolors.getColor(
                              widget.prefs, Colortype.primary.index),
                        ))
                    : SizedBox()
              ],
              backgroundColor: Mycolors.whiteDynamic,
              title: InkWell(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     PageRouteBuilder(
                  //         opaque: false,
                  //         pageBuilder: (context, a1, a2) => ProfileView(peer)));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MtCustomfontBoldSemi(
                      text: groupDoc[Dbkeys.groupNAME],
                      fontsize: 17,
                      color: Mycolors.black,
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      widget.currentUserID == groupDoc[Dbkeys.groupCREATEDBY]
                          ? '${getTranslatedForCurrentUser(context, 'xxcreatedbyuxx')}, ${formatDate(groupDoc[Dbkeys.groupCREATEDON].toDate())}'
                          : '${getTranslatedForCurrentUser(context, 'xxxcreatedbyxx')} ${groupDoc[Dbkeys.groupCREATEDBY]}, ${formatDate(groupDoc[Dbkeys.groupCREATEDON].toDate())}',
                      style: TextStyle(
                          color: Mycolors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.only(
                  bottom: IsBannerAdShow == true && observer.isadmobshow == true
                      ? 60
                      : 0),
              child: Stack(
                children: [
                  ListView(
                    children: [
                      Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: groupDoc[Dbkeys.groupPHOTOURL] ?? '',
                            imageBuilder: (context, imageProvider) => Container(
                              width: w,
                              height: w / 1.2,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            placeholder: (context, url) => Container(
                              width: w,
                              height: w / 1.2,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                              ),
                              child: Icon(Icons.people,
                                  color: Mycolors.grey.withOpacity(0.5),
                                  size: 75),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: w,
                              height: w / 1.2,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                              ),
                              child: Icon(Icons.people,
                                  color: Mycolors.grey.withOpacity(0.5),
                                  size: 75),
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomRight,
                            width: w,
                            height: w / 1.2,
                            decoration: BoxDecoration(
                              color: groupDoc[Dbkeys.groupPHOTOURL] == null
                                  ? Mycolors.black.withOpacity(0.2)
                                  : Mycolors.black.withOpacity(0.3),
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  groupDoc[Dbkeys.groupADMINLIST]
                                          .contains(widget.currentUserID)
                                      ? IconButton(
                                          onPressed: observer
                                                      .checkIfCurrentUserIsDemo(
                                                          widget
                                                              .currentUserID) ==
                                                  true
                                              ? () {
                                                  Utils.toast(
                                                      getTranslatedForCurrentUser(
                                                          context,
                                                          'xxxnotalwddemoxxaccountxx'));
                                                }
                                              : () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              SingleImagePicker(
                                                                title: getTranslatedForCurrentUser(
                                                                    this.context,
                                                                    'xxpickimagexx'),
                                                                callback:
                                                                    getImage,
                                                              ))).then(
                                                      (url) async {
                                                    if (url != null) {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(DbPaths
                                                              .collectionAgentGroups)
                                                          .doc(widget.groupID)
                                                          .update({
                                                        Dbkeys.groupPHOTOURL:
                                                            url
                                                      }).then((value) async {
                                                        DateTime time =
                                                            DateTime.now();
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(DbPaths
                                                                .collectionAgentGroups)
                                                            .doc(widget.groupID)
                                                            .collection(DbPaths
                                                                .collectiongroupChats)
                                                            .doc(time
                                                                    .millisecondsSinceEpoch
                                                                    .toString() +
                                                                '--' +
                                                                widget
                                                                    .currentUserID
                                                                    .toString())
                                                            .set({
                                                          Dbkeys
                                                              .groupmsgCONTENT: groupDoc[
                                                                      Dbkeys
                                                                          .groupCREATEDBY] ==
                                                                  widget
                                                                      .currentUserID
                                                              ? '${getTranslatedForCurrentUser(context, 'xxgrpiconchangedbyxx')} ${getTranslatedForCurrentUser(context, 'xxadminxx')}'
                                                              : '${getTranslatedForCurrentUser(context, 'xxgrpiconchangedbyxx')} ${widget.currentUserID}',
                                                          Dbkeys.groupmsgLISToptional:
                                                              [],
                                                          Dbkeys.deletedReason:
                                                              '',
                                                          Dbkeys.groupmsgTIME: time
                                                              .millisecondsSinceEpoch,
                                                          Dbkeys.groupmsgSENDBY:
                                                              widget
                                                                  .currentUserID,
                                                          Dbkeys.groupmsgISDELETED:
                                                              false,
                                                          Dbkeys.groupmsgTYPE:
                                                              Dbkeys
                                                                  .groupmsgTYPEnotificationUpdatedGroupicon,
                                                        });
                                                      });
                                                    } else {}
                                                  });
                                                },
                                          icon: Icon(Icons.camera_alt_rounded,
                                              color: Colors.white, size: 35),
                                        )
                                      : SizedBox(),
                                  groupDoc[Dbkeys.groupPHOTOURL] == null ||
                                          groupDoc[Dbkeys.groupCREATEDBY] !=
                                              widget.currentUserID
                                      ? SizedBox()
                                      : groupDoc[Dbkeys.groupADMINLIST]
                                              .contains(widget.currentUserID)
                                          ? IconButton(
                                              onPressed: observer
                                                          .checkIfCurrentUserIsDemo(
                                                              widget
                                                                  .currentUserID) ==
                                                      true
                                                  ? () {
                                                      Utils.toast(
                                                          getTranslatedForCurrentUser(
                                                              context,
                                                              'xxxnotalwddemoxxaccountxx'));
                                                    }
                                                  : () async {
                                                      Utils.toast(
                                                          getTranslatedForCurrentUser(
                                                              context,
                                                              'xxplswaitxx'));
                                                      await FirebaseStorage
                                                          .instance
                                                          .refFromURL(groupDoc[
                                                              Dbkeys
                                                                  .groupPHOTOURL])
                                                          .delete()
                                                          .then((d) async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(DbPaths
                                                                .collectionAgentGroups)
                                                            .doc(widget.groupID)
                                                            .update({
                                                          Dbkeys.groupPHOTOURL:
                                                              null,
                                                        });
                                                        DateTime time =
                                                            DateTime.now();
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(DbPaths
                                                                .collectionAgentGroups)
                                                            .doc(widget.groupID)
                                                            .collection(DbPaths
                                                                .collectiongroupChats)
                                                            .doc(time
                                                                    .millisecondsSinceEpoch
                                                                    .toString() +
                                                                '--' +
                                                                widget
                                                                    .currentUserID
                                                                    .toString())
                                                            .set({
                                                          Dbkeys
                                                              .groupmsgCONTENT: groupDoc[
                                                                      Dbkeys
                                                                          .groupCREATEDBY] ==
                                                                  widget
                                                                      .currentUserID
                                                              ? '${getTranslatedForCurrentUser(context, 'xxgrpicondeletedbyxx')} ${getTranslatedForCurrentUser(context, 'xxadminxx')}'
                                                              : '${getTranslatedForCurrentUser(context, 'xxgrpicondeletedbyxx')} ${widget.currentUserID}',
                                                          Dbkeys.groupmsgLISToptional:
                                                              [],
                                                          Dbkeys.groupmsgTIME: time
                                                              .millisecondsSinceEpoch,
                                                          Dbkeys.deletedReason:
                                                              '',
                                                          Dbkeys.groupmsgSENDBY:
                                                              widget
                                                                  .currentUserID,
                                                          Dbkeys.groupmsgISDELETED:
                                                              false,
                                                          Dbkeys.groupmsgTYPE:
                                                              Dbkeys
                                                                  .groupmsgTYPEnotificationDeletedGroupicon,
                                                        });
                                                      }).catchError(
                                                              (error) async {
                                                        if (error.toString().contains(Dbkeys.firebaseStorageNoObjectFound1) ||
                                                            error
                                                                .toString()
                                                                .contains(Dbkeys
                                                                    .firebaseStorageNoObjectFound2) ||
                                                            error
                                                                .toString()
                                                                .contains(Dbkeys
                                                                    .firebaseStorageNoObjectFound3) ||
                                                            error
                                                                .toString()
                                                                .contains(Dbkeys
                                                                    .firebaseStorageNoObjectFound4)) {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(DbPaths
                                                                  .collectionAgentGroups)
                                                              .doc(widget
                                                                  .groupID)
                                                              .update({
                                                            Dbkeys.groupPHOTOURL:
                                                                null,
                                                          });
                                                        }
                                                      });
                                                    },
                                              icon: Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: Colors.white,
                                                  size: 35),
                                            )
                                          : SizedBox(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getTranslatedForCurrentUser(
                                      context, 'xxdescxx'),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Mycolors.getColor(widget.prefs,
                                          Colortype.primary.index),
                                      fontSize: 16),
                                ),
                                groupDoc[Dbkeys.groupADMINLIST]
                                        .contains(widget.currentUserID)
                                    ? IconButton(
                                        onPressed: observer
                                                    .checkIfCurrentUserIsDemo(
                                                        widget.currentUserID) ==
                                                true
                                            ? () {
                                                Utils.toast(
                                                    getTranslatedForCurrentUser(
                                                        context,
                                                        'xxxnotalwddemoxxaccountxx'));
                                              }
                                            : () {
                                                Navigator.push(
                                                    this.context,
                                                    new MaterialPageRoute(
                                                        builder: (context) =>
                                                            new EditGroupDetails(
                                                              prefs:
                                                                  widget.prefs,
                                                              currentUserID: widget
                                                                  .currentUserID,
                                                              isadmin: groupDoc[
                                                                      Dbkeys
                                                                          .groupCREATEDBY] ==
                                                                  widget
                                                                      .currentUserID,
                                                              groupType:
                                                                  groupDoc[Dbkeys
                                                                      .groupTYPE],
                                                              groupDesc:
                                                                  groupDoc[Dbkeys
                                                                      .groupDESCRIPTION],
                                                              groupName:
                                                                  groupDoc[Dbkeys
                                                                      .groupNAME],
                                                              groupID: widget
                                                                  .groupID,
                                                            )));
                                              },
                                        icon: Icon(
                                          Icons.edit,
                                          color: Mycolors.grey,
                                        ))
                                    : SizedBox()
                              ],
                            ),
                            Divider(),
                            SizedBox(
                              height: 7,
                            ),
                            Text(
                              groupDoc[Dbkeys.groupDESCRIPTION] == ''
                                  ? getTranslatedForCurrentUser(
                                      context, 'xxnodescxx')
                                  : groupList
                                      .lastWhere((element) =>
                                          element.docmap[Dbkeys.groupID] ==
                                          widget.groupID)
                                      .docmap[Dbkeys.groupDESCRIPTION],
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: groupDoc[Dbkeys.groupDESCRIPTION] == ''
                                      ? Mycolors.grey
                                      : Mycolors.black,
                                  fontSize: 15.3),
                            ),
                            SizedBox(
                              height: 7,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getTranslatedForCurrentUser(
                                      context, 'xxgrouptypexx'),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Mycolors.getColor(widget.prefs,
                                          Colortype.primary.index),
                                      fontSize: 16),
                                ),
                                groupDoc[Dbkeys.groupADMINLIST]
                                        .contains(widget.currentUserID)
                                    ? IconButton(
                                        onPressed: observer
                                                    .checkIfCurrentUserIsDemo(
                                                        widget.currentUserID) ==
                                                true
                                            ? () {
                                                Utils.toast(
                                                    getTranslatedForCurrentUser(
                                                        context,
                                                        'xxxnotalwddemoxxaccountxx'));
                                              }
                                            : () {
                                                Navigator.push(
                                                    this.context,
                                                    new MaterialPageRoute(
                                                        builder: (context) =>
                                                            new EditGroupDetails(
                                                              prefs:
                                                                  widget.prefs,
                                                              currentUserID: widget
                                                                  .currentUserID,
                                                              isadmin: groupDoc[
                                                                      Dbkeys
                                                                          .groupCREATEDBY] ==
                                                                  widget
                                                                      .currentUserID,
                                                              groupType:
                                                                  groupDoc[Dbkeys
                                                                      .groupTYPE],
                                                              groupDesc:
                                                                  groupDoc[Dbkeys
                                                                      .groupDESCRIPTION],
                                                              groupName:
                                                                  groupDoc[Dbkeys
                                                                      .groupNAME],
                                                              groupID: widget
                                                                  .groupID,
                                                            )));
                                              },
                                        icon: Icon(
                                          Icons.edit,
                                          color: Mycolors.grey,
                                        ))
                                    : SizedBox()
                              ],
                            ),
                            Divider(),
                            SizedBox(
                              height: 7,
                            ),
                            Text(
                              groupDoc[Dbkeys.groupTYPE] ==
                                      Dbkeys.groupTYPEonlyadminmessageallowed
                                  ? getTranslatedForCurrentUser(
                                      context, 'xxonlyadminxx')
                                  : getTranslatedForCurrentUser(
                                          context, 'xxbothxxmssgalowedxx')
                                      .replaceAll(
                                          '(####)',
                                          getTranslatedForCurrentUser(
                                              context, 'xxagentsxx')),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Mycolors.black,
                                  fontSize: 15.3),
                            ),
                            SizedBox(
                              height: 7,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${groupList.firstWhere((element) => element.docmap[Dbkeys.groupID] == widget.groupID).docmap[Dbkeys.groupMEMBERSLIST].length}' +
                                            ' ' +
                                            '${getTranslatedForCurrentUser(context, 'xxagentsxx')}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Mycolors.getColor(
                                                widget.prefs,
                                                Colortype.primary.index),
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                (groupDoc[Dbkeys.groupMEMBERSLIST].length >=
                                            observer.groupMemberslimit) ||
                                        !(groupDoc[Dbkeys.groupADMINLIST]
                                            .contains(widget.currentUserID))
                                    ? SizedBox()
                                    : InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddAgentsToGroup(
                                                        currentUserID: widget
                                                            .currentUserID,
                                                        model: widget.model,
                                                        biometricEnabled: false,
                                                        prefs: widget.prefs,
                                                        groupID: widget.groupID,
                                                        isAddingWhileCreatingGroup:
                                                            false,
                                                      )));
                                        },
                                        child: SizedBox(
                                          height: 50,
                                          // width: 70,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                  width: 40,
                                                  child: CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor:
                                                        Mycolors.getColor(
                                                            widget.prefs,
                                                            Colortype
                                                                .primary.index),
                                                    child: Icon(Icons.add,
                                                        size: 19,
                                                        color: Colors.white),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                            getAdminList(),
                            getUsersList(),
                          ],
                        ),
                      ),
                      widget.currentUserID == groupDoc[Dbkeys.groupCREATEDBY]
                          ? Container(
                              margin: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  warningTile(
                                      title: getTranslatedForCurrentUser(
                                          context, 'xxonlyadmindeletexx'),
                                      warningTypeIndex:
                                          WarningType.alert.index),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  MySimpleButton(
                                    onpressed: observer
                                                .checkIfCurrentUserIsDemo(
                                                    widget.currentUserID) ==
                                            true
                                        ? () {
                                            Utils.toast(
                                                getTranslatedForCurrentUser(
                                                    context,
                                                    'xxxnotalwddemoxxaccountxx'));
                                          }
                                        : () async {
                                            await Utils.requestDelete(
                                                context: this.context,
                                                topicName: getTranslatedForCurrentUser(
                                                        context,
                                                        'xxgroupchatxx')
                                                    .replaceAll(
                                                        '(####)',
                                                        getTranslatedForCurrentUser(
                                                            context,
                                                            'xxagentxx')),
                                                sendBy: widget.currentUserID,
                                                reportEditingController:
                                                    textEditingController,
                                                topicid: widget.groupID,
                                                isDeleteRequest: true);
                                          },
                                    buttoncolor: Mycolors.red,
                                    width: w / 1.3,
                                    buttontext: getTranslatedForCurrentUser(
                                        context, 'xxrequestdeletexx'),
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                ],
                              ))
                          : SizedBox(
                              height: 20,
                            ),
                    ],
                  ),
                  Positioned(
                    child: isloading
                        ? Container(
                            child: Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Mycolors.secondary)),
                            ),
                            color: Colors.white.withOpacity(0.6))
                        : Container(),
                  )
                ],
              ),
            ),
          );
        })));
  }

  getAdminList() {
    return Consumer<List<GroupModel>>(builder: (context, groupList, _child) {
      Map<dynamic, dynamic> groupDoc = groupList
          .lastWhere(
              (element) => element.docmap[Dbkeys.groupID] == widget.groupID)
          .docmap;

      return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemCount: groupDoc[Dbkeys.groupADMINLIST].length,
          itemBuilder: (context, int i) {
            List adminlist = groupDoc[Dbkeys.groupADMINLIST].toList();
            return Consumer<UserRegistry>(builder: (context, registry, _child) {
              bool isCurrentUserSuperAdmin =
                  widget.currentUserID == groupDoc[Dbkeys.groupCREATEDBY];
              bool isCurrentUserAdmin = groupDoc[Dbkeys.groupADMINLIST]
                  .contains(widget.currentUserID);

              bool isListUserSuperAdmin =
                  groupDoc[Dbkeys.groupCREATEDBY] == adminlist[i];
              //----
              bool islisttUserAdmin =
                  groupDoc[Dbkeys.groupADMINLIST].contains(adminlist[i]);
              bool isListUserOnlyUser =
                  !groupDoc[Dbkeys.groupADMINLIST].contains(adminlist[i]);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(
                    height: 3,
                  ),
                  Stack(
                    children: [
                      ListTile(
                        trailing: SizedBox(
                          width: 30,
                          child: (isCurrentUserSuperAdmin ||
                                  ((isCurrentUserAdmin && isListUserOnlyUser) ==
                                      true))
                              ? isListUserSuperAdmin
                                  ? null
                                  : PopupMenuButton<String>(
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<String>>[
                                            PopupMenuItem<String>(
                                              value: 'Remove from Group',
                                              child: Text(
                                                  getTranslatedForCurrentUser(
                                                      context,
                                                      'xxremovefromgroupxx')),
                                            ),
                                            // PopupMenuItem<String>(
                                            //   value: isListUserOnlyUser
                                            //       ? 'Set as Admin'
                                            //       : 'Remove as Admin',
                                            //   child: Text(
                                            //     isListUserOnlyUser
                                            //         ? '${getTranslatedForCurrentUser(context, 'xxsetasadminxx')}'
                                            //         : '${getTranslatedForCurrentUser(context, 'xxremoveasadminxx')}',
                                            //   ),
                                            // ),
                                          ],
                                      onSelected: (String value) {
                                        userAction(value, adminlist[i],
                                            islisttUserAdmin, [adminlist[i]]);
                                      },
                                      child: Icon(
                                        Icons.more_vert_outlined,
                                        size: 20,
                                        color: Mycolors.black,
                                      ))
                              : null,
                        ),
                        isThreeLine: false,
                        contentPadding: EdgeInsets.fromLTRB(2, 0, 0, 0),
                        leading: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: registry
                                        .getUserData(context, adminlist[i])
                                        .photourl ==
                                    ""
                                ? Container(
                                    width: 50.0,
                                    height: 50.0,
                                    child: Icon(Icons.person),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: registry
                                        .getUserData(context, adminlist[i])
                                        .photourl,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                          width: 50.0,
                                          height: 50.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                    placeholder: (context, url) => Container(
                                          width: 50.0,
                                          height: 50.0,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: customCircleAvatar(radius: 50),
                                        )),
                          ),
                        ),
                        title: Text(
                          registry.getUserData(context, adminlist[i]).fullname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        enabled: true,
                        subtitle: Text(
                          //-- or about me
                          "${getTranslatedForCurrentUser(context, 'xxidxx')} " +
                              registry.getUserData(context, adminlist[i]).id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(height: 1.4),
                        ),
                        onTap: widget.currentUserID ==
                                registry.getUserData(context, adminlist[i]).id
                            ? () {}
                            : () {
                                // Navigator.push(
                                //     context,
                                //     new MaterialPageRoute(
                                //         builder: (context) => new ProfileView(
                                //               snapshot.data.data(),
                                //               widget.currentUserID,
                                //               widget.model,
                                //               widget.prefs,
                                //               firestoreUserDoc: snapshot.data,
                                //             )));
                              },
                      ),
                      groupDoc[Dbkeys.groupADMINLIST].contains(adminlist[i])
                          ? Positioned(
                              right: 27,
                              top: 10,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                                // width: 50.0,
                                height: 18.0,
                                decoration: new BoxDecoration(
                                  color: Colors.white,
                                  border: new Border.all(
                                      color: adminlist[i] ==
                                              groupDoc[Dbkeys.groupCREATEDBY]
                                          ? Colors.purple[400]!
                                          : Colors.green[400]!,
                                      width: 1.0),
                                  borderRadius: new BorderRadius.circular(5.0),
                                ),
                                child: new Center(
                                  child: new Text(
                                    getTranslatedForCurrentUser(
                                        context, 'xxadminxx'),
                                    style: new TextStyle(
                                      fontSize: 11.0,
                                      color: adminlist[i] ==
                                              groupDoc[Dbkeys.groupCREATEDBY]
                                          ? Colors.purple[400]
                                          : Colors.green[400],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ],
              );
            });
          });
    });
  }

  getUsersList() {
    return Consumer<List<GroupModel>>(builder: (context, groupList, _child) {
      Map<dynamic, dynamic> groupDoc = groupList
          .lastWhere(
              (element) => element.docmap[Dbkeys.groupID] == widget.groupID)
          .docmap;

      List onlyuserslist = groupDoc[Dbkeys.groupMEMBERSLIST];
      groupDoc[Dbkeys.groupMEMBERSLIST].toList().forEach((member) {
        if (groupDoc[Dbkeys.groupADMINLIST].contains(member)) {
          onlyuserslist.remove(member);
        }
      });
      return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemCount: onlyuserslist.length,
          itemBuilder: (context, int i) {
            List viewerslist = onlyuserslist;
            return Consumer<UserRegistry>(builder: (context, registry, _child) {
              bool isCurrentUserSuperAdmin =
                  widget.currentUserID == groupDoc[Dbkeys.groupCREATEDBY];
              bool isCurrentUserAdmin = groupDoc[Dbkeys.groupADMINLIST]
                  .contains(widget.currentUserID);

              bool isListUserSuperAdmin =
                  groupDoc[Dbkeys.groupCREATEDBY] == viewerslist[i];
              //----
              bool islisttUserAdmin =
                  groupDoc[Dbkeys.groupADMINLIST].contains(viewerslist[i]);
              bool isListUserOnlyUser =
                  !groupDoc[Dbkeys.groupADMINLIST].contains(viewerslist[i]);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(
                    height: 3,
                  ),
                  Stack(
                    children: [
                      ListTile(
                        trailing: SizedBox(
                          width: 30,
                          child: (isCurrentUserSuperAdmin ||
                                  ((isCurrentUserAdmin && isListUserOnlyUser) ==
                                      true))
                              ? isListUserSuperAdmin
                                  ? null
                                  : PopupMenuButton<String>(
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<String>>[
                                            PopupMenuItem<String>(
                                              value: 'Remove from Group',
                                              child: Text(
                                                  getTranslatedForCurrentUser(
                                                      context,
                                                      'xxremovefromgroupxx')),
                                            ),
                                            // PopupMenuItem<String>(
                                            //   value: isListUserOnlyUser == true
                                            //       ? 'Set as Admin'
                                            //       : 'Remove as Admin',
                                            //   child: Text(
                                            //     isListUserOnlyUser == true
                                            //         ? '${getTranslatedForCurrentUser(context, 'xxsetasadminxx')}'
                                            //         : '${getTranslatedForCurrentUser(context, 'xxremoveasadminxx')}',
                                            //   ),
                                            // ),
                                          ],
                                      onSelected: (String value) {
                                        userAction(value, viewerslist[i],
                                            islisttUserAdmin, [viewerslist[i]]);
                                      },
                                      child: Icon(
                                        Icons.more_vert_outlined,
                                        size: 20,
                                        color: Mycolors.black,
                                      ))
                              : null,
                        ),
                        isThreeLine: false,
                        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        leading: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: registry
                                        .getUserData(context, viewerslist[i])
                                        .photourl ==
                                    ""
                                ? Container(
                                    width: 50.0,
                                    height: 50.0,
                                    child: Icon(Icons.person),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: registry
                                        .getUserData(context, viewerslist[i])
                                        .photourl,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                    placeholder: (context, url) => Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: customCircleAvatar(radius: 40),
                                        )),
                          ),
                        ),
                        title: MtCustomfontBoldSemi(
                          text: registry
                              .getUserData(context, viewerslist[i])
                              .fullname,
                          fontsize: 16,
                        ),
                        subtitle: Text(
                          //-- or about me
                          '${getTranslatedForCurrentUser(context, 'xxidxx')} ' +
                              registry
                                  .getUserData(context, viewerslist[i])
                                  .id
                                  .toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 14, height: 1.4, color: Mycolors.grey),
                        ),
                        onTap: widget.currentUserID ==
                                registry.getUserData(context, viewerslist[i]).id
                            ? () {}
                            : () {
                                // Navigator.push(
                                //     context,
                                //     new MaterialPageRoute(
                                //         builder: (context) => new ProfileView(
                                //             snapshot.data.data(),
                                //             widget.currentUserID,
                                //             widget.model,
                                //             widget.prefs,
                                //             firestoreUserDoc: snapshot.data)));
                              },
                        enabled: true,
                      ),
                    ],
                  ),
                ],
              );
            });
          });
    });
  }
}

formatDate(DateTime timeToFormat) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final String formatted = formatter.format(timeToFormat);
  return formatted;
}
