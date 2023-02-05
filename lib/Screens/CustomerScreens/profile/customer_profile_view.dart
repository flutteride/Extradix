// //*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

// import 'dart:async';
// import 'dart:io';
// import 'package:thinkcreative_technologies/Configs/my_colors.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:thinkcreative_technologies/Configs/db_keys.dart';
// import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
// import 'package:thinkcreative_technologies/Configs/app_constants.dart';
// import 'package:thinkcreative_technologies/Models/DataModel.dart';
// import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/callhistory.dart';
// import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/pickup_layout.dart';
// import 'package:thinkcreative_technologies/Screens/chat_screen/chat.dart';
// import 'package:thinkcreative_technologies/Screens/status/components/formatStatusTime.dart';
// import 'package:thinkcreative_technologies/Services/Admob/admob.dart';
// import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
// import 'package:thinkcreative_technologies/Localization/language_constants.dart';
// import 'package:thinkcreative_technologies/Utils/open_settings.dart';
// import 'package:thinkcreative_technologies/Utils/permissions.dart';
// import 'package:thinkcreative_technologies/Utils/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ProfileView extends StatefulWidget {
//   final Map<String, dynamic> user;
//   final String? currentUserID;
//   final DataModel? model;
//   final SharedPreferences prefs;
//   final DocumentSnapshot<Map<String, dynamic>>? firestoreUserDoc;
//   ProfileView(this.user, this.currentUserID, this.model, this.prefs,
//       {this.firestoreUserDoc});

//   @override
//   State<ProfileView> createState() => _ProfileViewState();
// }

// class _ProfileViewState extends State<ProfileView> {
//   call(BuildContext context, bool isvideocall) async {
//     // var mynickname = widget.prefs.getString(Dbkeys.nickname) ?? '';

//     // var myphotoUrl = widget.prefs.getString(Dbkeys.photoUrl) ?? '';

//     // CallUtils.dial(

//     //     currentUserID: widget.currentUserID,
//     //     fromDp: myphotoUrl,
//     //     toDp: widget.user[Dbkeys.photoUrl],
//     //     fromUID: widget.currentUserID,
//     //     fromFullname: mynickname,
//     //     toUID: widget.user[Dbkeys.phone],
//     //     toFullname: widget.user[Dbkeys.nickname],
//     //     context: context,
//     //     isvideocall: isvideocall);
//   }

//   final BannerAd myBanner = BannerAd(
//     adUnitId: getBannerAdUnitId()!,
//     size: AdSize.banner,
//     request: AdRequest(),
//     listener: BannerAdListener(),
//   );
//   AdWidget? adWidget;
//   StreamSubscription? chatStatusSubscriptionForPeer;
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       final observer = Provider.of<Observer>(this.context, listen: false);
//       listenToBlock();
//       if (IsBannerAdShow == true && observer.isadmobshow == true) {
//         myBanner.load();
//         adWidget = AdWidget(ad: myBanner);
//         setState(() {});
//       }
//     });
//   }

//   bool hasPeerBlockedMe = false;
//   listenToBlock() {
//     chatStatusSubscriptionForPeer = FirebaseFirestore.instance
//         .collection(DbPaths.collectionagents)
//         .doc(widget.user[Dbkeys.phone])
//         .collection(Dbkeys.chatsWith)
//         .doc(Dbkeys.chatsWith)
//         .snapshots()
//         .listen((doc) {
//       if (doc.data()!.containsKey(widget.currentUserID)) {
//         print('CHANGED');
//         if (doc.data()![widget.currentUserID] == 0) {
//           hasPeerBlockedMe = true;
//           setState(() {});
//         } else if (doc.data()![widget.currentUserID] == 3) {
//           hasPeerBlockedMe = false;
//           setState(() {});
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     chatStatusSubscriptionForPeer?.cancel();
//     if (IsBannerAdShow == true) {
//       myBanner.dispose();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final observer = Provider.of<Observer>(context, listen: false);

//     return PickupLayout(
//         curentUserID: widget.currentUserID!,
//         prefs: widget.prefs,
//         scaffold: Utils.getNTPWrappedWidget(Scaffold(
//           appBar: AppBar(
//             elevation: 0,
//             backgroundColor: Colors.white,
//             leading: IconButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               icon: Icon(
//                 Icons.arrow_back_ios,
//                 size: 20,
//                 color: Mycolors.black,
//               ),
//             ),
//           ),
//           bottomSheet: IsBannerAdShow == true &&
//                   observer.isadmobshow == true &&
//                   adWidget != null
//               ? Container(
//                   height: 60,
//                   margin: EdgeInsets.only(
//                       bottom: Platform.isIOS == true ? 25.0 : 5, top: 0),
//                   child: Center(child: adWidget),
//                 )
//               : SizedBox(
//                   height: 0,
//                 ),
//           backgroundColor: Colors.white,
//           body: ListView(
//             padding: EdgeInsets.only(top: 10),
//             children: [
//               Column(
//                 children: [
//                   customCircleAvatar(
//                     radius: 45,
//                     url: widget.user[Dbkeys.photoUrl],
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Text(
//                     widget.user[Dbkeys.nickname],
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                         fontSize: 17,
//                         color: Mycolors.black,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//               SizedBox(
//                 height: 55,
//               ),
//               Container(
//                 color: Colors.white,
//                 padding: EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Row(
//                       mainAxisSize: MainAxisSize.max,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                          "",
//                           textAlign: TextAlign.left,
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Mycolors.primary,
//                               fontSize: 16),
//                         ),
//                       ],
//                     ),
//                     Divider(),
//                     SizedBox(
//                       height: 7,
//                     ),
//                     Text(
//                       widget.user[Dbkeys.aboutMe] == null ||
//                               widget.user[Dbkeys.aboutMe] == ''
//                           ? '${getTranslatedForCurrentUser(context, 'heyim')} $Appname'
//                           : widget.user[Dbkeys.aboutMe],
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                           fontWeight: FontWeight.normal,
//                           color: Mycolors.black,
//                           fontSize: 15.9),
//                     ),
//                     SizedBox(
//                       height: 14,
//                     ),
//                     Text(
//                       getJoinTime(widget.user[Dbkeys.joinedOn], context),
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                           fontWeight: FontWeight.normal,
//                           color: Mycolors.grey,
//                           fontSize: 13.3),
//                     ),
//                     SizedBox(
//                       height: 7,
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Container(
//                 color: Colors.white,
//                 padding: EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Row(
//                       mainAxisSize: MainAxisSize.max,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           getTranslatedForCurrentUser(context, 'xxenter_mobilenumberxx'),
//                           textAlign: TextAlign.left,
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Mycolors.primary,
//                               fontSize: 16),
//                         ),
//                       ],
//                     ),
//                     Divider(),
//                     SizedBox(
//                       height: 0,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           widget.user[Dbkeys.phone],
//                           textAlign: TextAlign.left,
//                           style: TextStyle(
//                               fontWeight: FontWeight.normal,
//                               color: Mycolors.black,
//                               fontSize: 15.3),
//                         ),
//                         Container(
//                           child: Row(
//                             children: [
//                               observer.isCallFeatureTotallyHide == true
//                                   ? SizedBox()
//                                   : IconButton(
//                                       onPressed: hasPeerBlockedMe == true
//                                           ? () {
//                                               Utils.toast(
//                                                 getTranslatedForCurrentUser(
//                                                     context, 'xxuserhasblockedxx'),
//                                               );
//                                             }
//                                           : () async {
//                                               await Permissions
//                                                       .cameraAndMicrophonePermissionsGranted()
//                                                   .then((isgranted) {
//                                                 if (isgranted == true) {
//                                                   call(context, false);
//                                                 } else {
//                                                   Utils.showRationale(
//                                                       getTranslatedForCurrentUser(
//                                                           context, 'xxpmcxx'));
//                                                   Navigator.push(
//                                                       context,
//                                                       new MaterialPageRoute(
//                                                           builder: (context) =>
//                                                               OpenSettings()));
//                                                 }
//                                               }).catchError((onError) {
//                                                 Utils.showRationale(
//                                                     getTranslatedForCurrentUser(
//                                                         context, 'xxpmcxx'));
//                                                 Navigator.push(
//                                                     context,
//                                                     new MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             OpenSettings()));
//                                               });
//                                             },
//                                       icon: Icon(
//                                         Icons.phone,
//                                         color: Mycolors.primary,
//                                       )),
//                               observer.isCallFeatureTotallyHide == true
//                                   ? SizedBox()
//                                   : IconButton(
//                                       onPressed: hasPeerBlockedMe == true
//                                           ? () {
//                                               Utils.toast(
//                                                 getTranslatedForCurrentUser(
//                                                     context, 'xxuserhasblockedxx'),
//                                               );
//                                             }
//                                           : () async {
//                                               await Permissions
//                                                       .cameraAndMicrophonePermissionsGranted()
//                                                   .then((isgranted) {
//                                                 if (isgranted == true) {
//                                                   call(context, true);
//                                                 } else {
//                                                   Utils.showRationale(
//                                                       getTranslatedForCurrentUser(
//                                                           context, 'xxpmcxx'));
//                                                   Navigator.push(
//                                                       context,
//                                                       new MaterialPageRoute(
//                                                           builder: (context) =>
//                                                               OpenSettings()));
//                                                 }
//                                               }).catchError((onError) {
//                                                 Utils.showRationale(
//                                                     getTranslatedForCurrentUser(
//                                                         context, 'xxpmcxx'));
//                                                 Navigator.push(
//                                                     context,
//                                                     new MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             OpenSettings()));
//                                               });
//                                             },
//                                       icon: Icon(
//                                         Icons.videocam_rounded,
//                                         size: 26,
//                                         color: Mycolors.primary,
//                                       )),
//                               IconButton(
//                                   onPressed: () {
//                                     if (widget.firestoreUserDoc != null) {
//                                       widget.model!
//                                           .addUser(widget.firestoreUserDoc!);
//                                     }

//                                     Navigator.pushAndRemoveUntil(
//                                         context,
//                                         new MaterialPageRoute(
//                                             builder: (context) =>
//                                                 new ChatScreen(
//                                                     isSharingIntentForwarded:
//                                                         false,
//                                                     prefs: widget.prefs,
//                                                     model: widget.model!,
//                                                     currentUserID:
//                                                         widget.currentUserID!,
//                                                     peerUID:
//                                                         widget.user[Dbkeys.id],
//                                                     unread: 0)),
//                                         (Route r) => r.isFirst);
//                                   },
//                                   icon: Icon(
//                                     Icons.message,
//                                     color: Mycolors.primary,
//                                   )),
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
//                     SizedBox(
//                       height: 0,
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               Container(
//                 padding: EdgeInsets.only(bottom: 18, top: 8),
//                 color: Colors.white,
//                 // height: 30,
//                 child: ListTile(
//                   title: Padding(
//                     padding: const EdgeInsets.only(bottom: 9),
//                     child: Text(
//                       getTranslatedForCurrentUser(context, 'encryption'),
//                       style: TextStyle(fontWeight: FontWeight.w600, height: 2),
//                     ),
//                   ),
//                   dense: false,
//                   subtitle: Text(
//                     getTranslatedForCurrentUser(context, 'encryptionshort'),
//                     style: TextStyle(
//                         color: Mycolors.grey, height: 1.3, fontSize: 15),
//                   ),
//                   trailing: Padding(
//                     padding: const EdgeInsets.only(top: 32),
//                     child: Icon(
//                       Icons.lock,
//                       color: Mycolors.primary,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: IsBannerAdShow == true &&
//                         observer.isadmobshow == true &&
//                         adWidget != null
//                     ? 90
//                     : 20,
//               ),
//             ],
//           ),
//         )));
//   }
// }
