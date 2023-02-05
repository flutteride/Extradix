//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:math';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/audio_call.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/video_call.dart';
import 'package:flutter/material.dart';
import 'package:thinkcreative_technologies/Models/call.dart';
import 'package:thinkcreative_technologies/Models/call_methods.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial(
      {String? fromUID,
      String? fromFullname,
      String? fromDp,
      required SharedPreferences prefs,
      required int callTypeindex,
      required bool isShowCallernameAndPhotoToDialler,
      required bool isShowCallernameAndPhotoToReciever,
      required String callSessionID,
      required String callSessionInitatedBy,
      String? ticketCustomerID,
      String? toFullname,
      String? toDp,
      String? toUID,
      bool? isvideocall,
      String? ticketID,
      String? tickettitle,
      String? ticketidfiltered,
      required String? currentUserID,
      context}) async {
    int timeepoch = DateTime.now().millisecondsSinceEpoch;
    Call call = Call(
        ticketCustomerID: ticketCustomerID,
        ticketIDfiltered: ticketidfiltered,
        ticketTitle: tickettitle,
        callSessionID: callSessionID,
        callSessionInitiatedBy: callSessionInitatedBy,
        callTypeIndex: callTypeindex,
        isShowNameAndPhotoToDialer: isShowCallernameAndPhotoToDialler,
        isShowCallernameAndPhotoToReciever: isShowCallernameAndPhotoToReciever,
        timeepoch: timeepoch,
        callerId: fromUID,
        callerName: fromFullname,
        callerPic: fromDp,
        receiverId: toUID,
        receiverName: toFullname,
        receiverPic: toDp,
        channelId: Random().nextInt(1000).toString(),
        isvideocall: isvideocall,
        ticketID: ticketID);
    ClientRole _role = ClientRole.Broadcaster;
    bool callMade = await callMethods.makeCall(
        call: call, isvideocall: isvideocall, timeepoch: timeepoch);

    call.hasDialled = true;
    if (isvideocall == false) {
      if (callMade) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioCall(
              currentUserisAgent: prefs.getInt(Dbkeys.userLoginType) ==
                          Usertype.customer.index ||
                      prefs.getInt(Dbkeys.userLoginType) == null
                  ? false
                  : true,
              callTypeindex: callTypeindex,
              isShownamePhotoToCaller: call.isShowNameAndPhotoToDialer!,
              currentUserID: currentUserID,
              call: call,
              channelName: call.channelId,
              role: _role,
            ),
          ),
        );
      }
    } else {
      if (callMade) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCall(
              currentUserisAgent: prefs.getInt(Dbkeys.userLoginType) ==
                          Usertype.customer.index ||
                      prefs.getInt(Dbkeys.userLoginType) == null
                  ? false
                  : true,
              callTypeindex: callTypeindex,
              isShownamePhotoToCaller: call.isShowNameAndPhotoToDialer!,
              currentUserID: currentUserID,
              call: call,
              channelName: call.channelId!,
              role: _role,
            ),
          ),
        );
      }
    }
  }
}
