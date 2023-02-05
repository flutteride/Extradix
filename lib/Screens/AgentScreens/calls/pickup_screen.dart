//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Screens/CustomerScreens/home/customer_home.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/call_history_provider.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/audio_call.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/video_call.dart';
import 'package:thinkcreative_technologies/widgets/Common/cached_image.dart';
import 'package:thinkcreative_technologies/Utils/open_settings.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:thinkcreative_technologies/Models/call.dart';
import 'package:thinkcreative_technologies/Models/call_methods.dart';
import 'package:thinkcreative_technologies/Utils/permissions.dart';
import 'package:provider/provider.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';

// ignore: must_be_immutable
class PickupScreen extends StatelessWidget {
  final Call call;
  final bool currentUserisAgent;
  final String? currentUserID;
  final CallMethods callMethods = CallMethods();
  final SharedPreferences prefs;
  PickupScreen(
      {required this.call,
      required this.currentUserisAgent,
      required this.currentUserID,
      required this.prefs});
  ClientRole _role = ClientRole.Broadcaster;
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    String incomingCallerName = call.callTypeIndex ==
            CallTypeIndex.callToCustomerFromAgentInTICKET.index
        ? call.isShowCallernameAndPhotoToReciever == false
            ? "${getTranslatedForCurrentUser(context, 'xxagentxx')}\n" +
                call.callerName!
            : call.callerName!
        : call.callTypeIndex ==
                CallTypeIndex.callToAgentFromCustomerInTICKET.index
            ? call.isShowCallernameAndPhotoToReciever == false
                ? "${getTranslatedForCurrentUser(context, getTranslatedForCurrentUser(context, 'xxcustomerxx'))}\n" +
                    call.callerName!
                : call.callerName!
            : call.isShowCallernameAndPhotoToReciever == false
                ? call.callTypeIndex ==
                        CallTypeIndex.callToAgentFromAgentInPERSONAL.index
                    ? getTranslatedForCurrentUser(context, 'xxagentxx')
                    : call.callTypeIndex ==
                            CallTypeIndex
                                .callToCustomerFromCustomerInPERSONAL.index
                        ? call.callerName!
                        : call.callerName!
                : call.callerName!;

    String incomingCallerID = call.callTypeIndex ==
            CallTypeIndex.callToCustomerFromAgentInTICKET.index
        ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} " +
            call.callerId!
        : call.callTypeIndex ==
                CallTypeIndex.callToAgentFromCustomerInTICKET.index
            ? "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} " +
                call.callerId!
            : call.isShowCallernameAndPhotoToReciever == false
                ? call.callTypeIndex ==
                        CallTypeIndex.callToAgentFromAgentInPERSONAL.index
                    ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} " +
                        call.callerId!
                    : call.callTypeIndex ==
                            CallTypeIndex
                                .callToCustomerFromCustomerInPERSONAL.index
                        ? "${getTranslatedForCurrentUser(context, 'xxidxx')} " +
                            call.callerId!
                        : "${getTranslatedForCurrentUser(context, 'xxidxx')} " +
                            call.callerId!
                : "${getTranslatedForCurrentUser(context, 'xxidxx')} " +
                    call.callerId!;

    String callerCollectionpath = "";
    String recieverCollectionPath = "";
    callerCollectionpath = call.callTypeIndex ==
                CallTypeIndex.callToAgentFromAgentInPERSONAL.index ||
            call.callTypeIndex ==
                CallTypeIndex.callToCustomerFromAgentInTICKET.index
        ? DbPaths.collectionagents
        : DbPaths.collectioncustomers;

    recieverCollectionPath = call.callTypeIndex ==
                CallTypeIndex.callToAgentFromAgentInPERSONAL.index ||
            call.callTypeIndex ==
                CallTypeIndex.callToAgentFromCustomerInTICKET.index
        ? DbPaths.collectionagents
        : DbPaths.collectioncustomers;
    final observer = Provider.of<Observer>(context, listen: true);
    return Consumer<FirestoreDataProviderCALLHISTORY>(
        builder: (context, firestoreDataProviderCALLHISTORY, _child) => h > w &&
                ((h / w) > 1.5)
            ? Scaffold(
                backgroundColor: Mycolors.primary,
                body: Container(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top),
                        color: Mycolors.primary,
                        height: h / 4,
                        width: w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 7,
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  call.isvideocall == true
                                      ? Icons.videocam
                                      : Icons.mic_rounded,
                                  size: 40,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  call.isvideocall == true
                                      ? getTranslatedForCurrentUser(
                                          context, 'xxincomingvideoxx')
                                      : getTranslatedForCurrentUser(
                                          context, 'xxincomingaudioxx'),
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white.withOpacity(0.5),
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: h / 9,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 7),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 1.1,
                                    child: Text(
                                      incomingCallerName,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        fontSize: 27,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    incomingCallerID,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white.withOpacity(0.34),
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // SizedBox(height: h / 25),

                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                      call.callerPic == null ||
                              call.callerPic == '' ||
                              call.isShowCallernameAndPhotoToReciever == false
                          ? Container(
                              height: w + (w / 140),
                              width: w,
                              color: Colors.white12,
                              child: Icon(
                                Icons.person,
                                size: 140,
                                color: Mycolors.primary,
                              ),
                            )
                          : Stack(
                              children: [
                                Container(
                                    height: w + (w / 140),
                                    width: w,
                                    color: Colors.white12,
                                    child: CachedNetworkImage(
                                      imageUrl: call.callerPic!,
                                      fit: BoxFit.cover,
                                      height: w + (w / 140),
                                      width: w,
                                      placeholder: (context, url) => Center(
                                          child: Container(
                                        height: w + (w / 140),
                                        width: w,
                                        color: Colors.white12,
                                        child: Icon(
                                          Icons.person,
                                          size: 140,
                                          color: Mycolors.primary,
                                        ),
                                      )),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        height: w + (w / 140),
                                        width: w,
                                        color: Colors.white12,
                                        child: Icon(
                                          Icons.person,
                                          size: 140,
                                          color: Mycolors.primary,
                                        ),
                                      ),
                                    )),
                                Container(
                                  height: w + (w / 140),
                                  width: w,
                                  color: Colors.black.withOpacity(0.18),
                                ),
                              ],
                            ),
                      Container(
                        height: h / 6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RawMaterialButton(
                              onPressed: observer.checkIfCurrentUserIsDemo(
                                          currentUserID!) ==
                                      true
                                  ? () {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : () async {
                                      flutterLocalNotificationsPlugin
                                          .cancelAll();
                                      await callMethods.endCall(call: call);
                                      FirebaseFirestore.instance
                                          .collection(callerCollectionpath)
                                          .doc(call.callerId)
                                          .collection(
                                              DbPaths.collectioncallhistory)
                                          .doc(call.timeepoch.toString())
                                          .set({
                                        'STATUS': 'rejected',
                                        'ENDED': DateTime.now(),
                                      }, SetOptions(merge: true));
                                      FirebaseFirestore.instance
                                          .collection(recieverCollectionPath)
                                          .doc(call.receiverId)
                                          .collection(
                                              DbPaths.collectioncallhistory)
                                          .doc(call.timeepoch.toString())
                                          .set({
                                        'STATUS': 'rejected',
                                        'ENDED': DateTime.now(),
                                      }, SetOptions(merge: true));
                                      //----------
                                      await FirebaseFirestore.instance
                                          .collection(recieverCollectionPath)
                                          .doc(call.receiverId)
                                          .collection('recent')
                                          .doc('xxcallendedxx')
                                          .set({
                                        'id': call.receiverId,
                                        'ENDED': DateTime.now()
                                            .millisecondsSinceEpoch
                                      }, SetOptions(merge: true));

                                      firestoreDataProviderCALLHISTORY
                                          .fetchNextData(
                                              'CALLHISTORY',
                                              FirebaseFirestore.instance
                                                  .collection(
                                                      recieverCollectionPath)
                                                  .doc(call.receiverId)
                                                  .collection(DbPaths
                                                      .collectioncallhistory)
                                                  .orderBy('TIME',
                                                      descending: true)
                                                  .limit(14),
                                              true);
                                    },
                              child: Icon(
                                Icons.call_end,
                                color: Colors.white,
                                size: 35.0,
                              ),
                              shape: CircleBorder(),
                              elevation: 2.0,
                              fillColor: Colors.redAccent,
                              padding: const EdgeInsets.all(15.0),
                            ),
                            SizedBox(width: 45),
                            RawMaterialButton(
                              onPressed: observer.checkIfCurrentUserIsDemo(
                                          currentUserID!) ==
                                      true
                                  ? () {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : () async {
                                      flutterLocalNotificationsPlugin
                                          .cancelAll();
                                      await Permissions
                                              .cameraAndMicrophonePermissionsGranted()
                                          .then((isgranted) async {
                                        if (isgranted == true) {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  call.isvideocall == true
                                                      ? VideoCall(
                                                          currentUserisAgent:
                                                              currentUserisAgent,
                                                          callTypeindex: call
                                                              .callTypeIndex!,
                                                          isShownamePhotoToCaller:
                                                              call.isShowNameAndPhotoToDialer!,
                                                          currentUserID:
                                                              currentUserID,
                                                          call: call,
                                                          channelName:
                                                              call.channelId!,
                                                          role: _role,
                                                        )
                                                      : AudioCall(
                                                          currentUserisAgent:
                                                              currentUserisAgent,
                                                          callTypeindex: call
                                                              .callTypeIndex!,
                                                          isShownamePhotoToCaller:
                                                              call.isShowNameAndPhotoToDialer!,
                                                          currentUserID:
                                                              currentUserID,
                                                          call: call,
                                                          channelName:
                                                              call.channelId,
                                                          role: _role,
                                                        ),
                                            ),
                                          );
                                        } else {
                                          Utils.showRationale(
                                              getTranslatedForCurrentUser(
                                                  context, 'xxpmcxx'));
                                          Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                  builder: (context) =>
                                                      OpenSettings()));
                                        }
                                      }).catchError((onError) {
                                        Utils.showRationale(
                                            getTranslatedForCurrentUser(
                                                context, 'xxpmcxx'));
                                        Navigator.push(
                                            context,
                                            new MaterialPageRoute(
                                                builder: (context) =>
                                                    OpenSettings()));
                                      });
                                    },
                              child: Icon(
                                Icons.call,
                                color: Colors.white,
                                size: 35.0,
                              ),
                              shape: CircleBorder(),
                              elevation: 2.0,
                              fillColor: Colors.green[400],
                              padding: const EdgeInsets.all(15.0),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
            : Scaffold(
                backgroundColor: Colors.white,
                body: SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: w > h ? 60 : 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        w > h
                            ? SizedBox(
                                height: 0,
                              )
                            : Icon(
                                call.isvideocall == true
                                    ? Icons.videocam_outlined
                                    : Icons.mic,
                                size: 80,
                                color: Mycolors.black.withOpacity(0.3),
                              ),
                        w > h
                            ? SizedBox(
                                height: 0,
                              )
                            : SizedBox(
                                height: 20,
                              ),
                        Text(
                          call.isvideocall == true
                              ? getTranslatedForCurrentUser(
                                  context, 'xxincomingvideoxx')
                              : getTranslatedForCurrentUser(
                                  context, 'xxincomingaudioxx'),
                          style: TextStyle(
                            fontSize: 19,
                            color: Mycolors.black.withOpacity(0.54),
                          ),
                        ),
                        SizedBox(height: w > h ? 16 : 50),
                        CachedImage(
                          call.callerPic == null ||
                                  call.callerPic == '' ||
                                  call.isShowCallernameAndPhotoToReciever ==
                                      false
                              ? null
                              : call.callerPic,
                          isRound: true,
                          height: w > h ? 60 : 110,
                          width: w > h ? 60 : 110,
                          radius: w > h ? 70 : 138,
                        ),
                        SizedBox(height: 15),
                        Text(
                          incomingCallerName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Mycolors.black,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          incomingCallerID,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.white.withOpacity(0.34),
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: w > h ? 30 : 75),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RawMaterialButton(
                              onPressed: observer.checkIfCurrentUserIsDemo(
                                          currentUserID!) ==
                                      true
                                  ? () {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : () async {
                                      flutterLocalNotificationsPlugin
                                          .cancelAll();
                                      await callMethods.endCall(call: call);
                                      FirebaseFirestore.instance
                                          .collection(callerCollectionpath)
                                          .doc(call.callerId)
                                          .collection(
                                              DbPaths.collectioncallhistory)
                                          .doc(call.timeepoch.toString())
                                          .set({
                                        'STATUS': 'rejected',
                                        'ENDED': DateTime.now(),
                                      }, SetOptions(merge: true));
                                      FirebaseFirestore.instance
                                          .collection(recieverCollectionPath)
                                          .doc(call.receiverId)
                                          .collection(
                                              DbPaths.collectioncallhistory)
                                          .doc(call.timeepoch.toString())
                                          .set({
                                        'STATUS': 'rejected',
                                        'ENDED': DateTime.now(),
                                      }, SetOptions(merge: true));
                                      //----------
                                      await FirebaseFirestore.instance
                                          .collection(recieverCollectionPath)
                                          .doc(call.receiverId)
                                          .collection('recent')
                                          .doc('xxcallendedxx')
                                          .set({
                                        'id': call.receiverId,
                                        'ENDED': DateTime.now()
                                            .millisecondsSinceEpoch
                                      }, SetOptions(merge: true));

                                      firestoreDataProviderCALLHISTORY
                                          .fetchNextData(
                                              'CALLHISTORY',
                                              FirebaseFirestore.instance
                                                  .collection(
                                                      recieverCollectionPath)
                                                  .doc(call.receiverId)
                                                  .collection(DbPaths
                                                      .collectioncallhistory)
                                                  .orderBy('TIME',
                                                      descending: true)
                                                  .limit(14),
                                              true);
                                    },
                              child: Icon(
                                Icons.call_end,
                                color: Colors.white,
                                size: 35.0,
                              ),
                              shape: CircleBorder(),
                              elevation: 2.0,
                              fillColor: Colors.redAccent,
                              padding: const EdgeInsets.all(15.0),
                            ),
                            SizedBox(width: 45),
                            RawMaterialButton(
                              onPressed: observer.checkIfCurrentUserIsDemo(
                                          currentUserID!) ==
                                      true
                                  ? () {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          context,
                                          'xxxnotalwddemoxxaccountxx'));
                                    }
                                  : () async {
                                      flutterLocalNotificationsPlugin
                                          .cancelAll();
                                      await Permissions
                                              .cameraAndMicrophonePermissionsGranted()
                                          .then((isgranted) async {
                                        if (isgranted == true) {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  call.isvideocall == true
                                                      ? VideoCall(
                                                          currentUserisAgent:
                                                              currentUserisAgent,
                                                          callTypeindex: call
                                                              .callTypeIndex!,
                                                          isShownamePhotoToCaller:
                                                              call.isShowNameAndPhotoToDialer!,
                                                          currentUserID:
                                                              currentUserID,
                                                          call: call,
                                                          channelName:
                                                              call.channelId!,
                                                          role: _role,
                                                        )
                                                      : AudioCall(
                                                          currentUserisAgent:
                                                              currentUserisAgent,
                                                          callTypeindex: call
                                                              .callTypeIndex!,
                                                          isShownamePhotoToCaller:
                                                              call.isShowNameAndPhotoToDialer!,
                                                          currentUserID:
                                                              currentUserID,
                                                          call: call,
                                                          channelName:
                                                              call.channelId,
                                                          role: _role,
                                                        ),
                                            ),
                                          );
                                        } else {
                                          Utils.showRationale(
                                              getTranslatedForCurrentUser(
                                                  context, 'xxpmcxx'));
                                          Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                  builder: (context) =>
                                                      OpenSettings()));
                                        }
                                      }).catchError((onError) {
                                        Utils.showRationale(
                                            getTranslatedForCurrentUser(
                                                context, 'xxpmcxx'));
                                        Navigator.push(
                                            context,
                                            new MaterialPageRoute(
                                                builder: (context) =>
                                                    OpenSettings()));
                                      });
                                    },
                              child: Icon(
                                Icons.call,
                                color: Colors.white,
                                size: 35.0,
                              ),
                              shape: CircleBorder(),
                              elevation: 2.0,
                              fillColor: Mycolors.secondary,
                              padding: const EdgeInsets.all(15.0),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ));
  }
}
