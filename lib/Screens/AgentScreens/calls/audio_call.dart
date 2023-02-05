//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Models/ticket_message.dart';
import 'package:thinkcreative_technologies/Screens/CustomerScreens/home/customer_home.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/call_history_provider.dart';
import 'package:thinkcreative_technologies/Services/Providers/liveListener.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/call.dart';
import 'package:thinkcreative_technologies/Utils/getRolePermission.dart';
import 'package:thinkcreative_technologies/widgets/Common/cached_image.dart';
import 'package:thinkcreative_technologies/Utils/call_utilities.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart' as audioPlayers;
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';

class AudioCall extends StatefulWidget {
  final bool isShownamePhotoToCaller;
  final bool currentUserisAgent;
  final String? channelName;
  final Call call;
  final int callTypeindex;
  final String? currentUserID;
  final ClientRole? role;
  const AudioCall(
      {Key? key,
      required this.isShownamePhotoToCaller,
      required this.call,
      required this.currentUserisAgent,
      required this.callTypeindex,
      required this.currentUserID,
      this.channelName,
      this.role})
      : super(key: key);

  @override
  _AudioCallState createState() => _AudioCallState();
}

class _AudioCallState extends State<AudioCall> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  late RtcEngine _engine;

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    _engine.leaveChannel();
    _engine.destroy();

    streamController!.done;
    streamController!.close();
    timerSubscription!.cancel();

    super.dispose();
  }

  String callerCollectionpath = "";
  String recieverCollectionPath = "";
  Stream<DocumentSnapshot>? stream;
  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    callerCollectionpath = widget.call.callTypeIndex ==
                CallTypeIndex.callToAgentFromAgentInPERSONAL.index ||
            widget.call.callTypeIndex ==
                CallTypeIndex.callToCustomerFromAgentInTICKET.index
        ? DbPaths.collectionagents
        : DbPaths.collectioncustomers;

    recieverCollectionPath = widget.call.callTypeIndex ==
                CallTypeIndex.callToAgentFromAgentInPERSONAL.index ||
            widget.call.callTypeIndex ==
                CallTypeIndex.callToAgentFromCustomerInTICKET.index
        ? DbPaths.collectionagents
        : DbPaths.collectioncustomers;
    initialize();
    stream = FirebaseFirestore.instance
        .collection(widget.currentUserID == widget.call.callerId
            ? recieverCollectionPath
            : callerCollectionpath)
        .doc(widget.currentUserID == widget.call.callerId
            ? widget.call.receiverId
            : widget.call.callerId)
        .collection(DbPaths.collectioncallhistory)
        .doc(widget.call.timeepoch.toString())
        .snapshots();
  }

  String? mp3Uri;
  late audioPlayers.AudioPlayer player;
  AudioCache audioCache = AudioCache();
  Future<Null> _playCallingTone() async {
    player = await audioCache.loop('sounds/callingtone.mp3', volume: 6);

    setState(() {});
  }

  void _stopCallingSound() async {
    player.stop();
  }

  bool isspeaker = false;
  Future<void> initialize() async {
    if (Agora_APP_IDD.isEmpty) {
      setState(() {
        _infoStrings.add(
          'Agora_APP_ID missing, please provide your Agora_APP_ID in app_constant.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();

    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(height: 1920, width: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(Agora_TOKEN, widget.channelName!, null, 0);
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(Agora_APP_IDD);
    await _engine.setEnableSpeakerphone(isspeaker);
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role!);
  }

  bool isalreadyendedcall = false;
  void _addAgoraEventHandlers() {
    final observer = Provider.of<Observer>(this.context, listen: false);

    SpecialLiveConfigData? livedata =
        Provider.of<SpecialLiveConfigData?>(this.context, listen: false);
    bool isShownamePhoto =
        observer.userAppSettingsDoc!.agentcanseeagentnameandphoto! == true ||
            (iAmSecondAdmin(
                        specialLiveConfigData: livedata,
                        currentuserid: widget.call.receiverId!,
                        context: context) ==
                    true &&
                observer.userAppSettingsDoc!
                        .secondadmincanseeagentnameandphoto ==
                    true) ||
            (iAmDepartmentManager(
                        currentuserid: widget.call.receiverId!,
                        context: context) ==
                    true &&
                observer.userAppSettingsDoc!
                        .departmentmanagercanseeagentnameandphoto ==
                    true);
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      if (widget.call.callerId == widget.currentUserID) {
        _playCallingTone();
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
        if (widget.call.ticketID == "" || widget.call.ticketID == null) {
        } else {
          FirebaseFirestore.instance
              .collection(DbPaths.collectiontickets)
              .doc(widget.call.ticketID)
              .update({
            Dbkeys.ticketlatestTimestampForAgents:
                DateTime.now().millisecondsSinceEpoch,
            Dbkeys.ticketlatestTimestampForCustomer:
                DateTime.now().millisecondsSinceEpoch,
          });
          FirebaseFirestore.instance
              .collection(DbPaths.collectiontickets)
              .doc(widget.call.ticketID)
              .collection(DbPaths.collectionticketChats)
              .doc(widget.call.callSessionID.toString() +
                  '--' +
                  widget.call.callSessionInitiatedBy.toString())
              .set(
                  TicketMessage(
                    tktMsgCUSTOMERID: widget.call.ticketCustomerID!,
                    tktMssgCONTENT: widget.call.callSessionID.toString() +
                        '--' +
                        widget.call.callSessionInitiatedBy.toString(),
                    tktMssgISDELETED: false,
                    tktMssgTIME:
                        int.tryParse(widget.call.timeepoch.toString())!,
                    tktMssgSENDBY: widget.call.callSessionInitiatedBy!,
                    tktMssgTYPE: MessageType.rROBOTcallHistory.index,
                    tktMssgSENDERNAME: isShownamePhoto == false
                        ? widget.callTypeindex ==
                                CallTypeIndex
                                    .callToAgentFromAgentInPERSONAL.index
                            ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${widget.call.callerId}"
                            : widget.callTypeindex ==
                                    CallTypeIndex
                                        .callToAgentFromCustomerInTICKET.index
                                ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${widget.call.callerId}  - ${getTranslatedForCurrentUser(context, 'xxsupporttktxx')}"
                                : widget.callTypeindex ==
                                        CallTypeIndex
                                            .callToAgentFromCustomerInTICKET
                                            .index
                                    ? "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${widget.call.callerId}"
                                    : "${getTranslatedForCurrentUser(context, 'xxidxx')} ${widget.call.callerId}"
                        : widget.call.callerName!,
                    tktMssgISREPLY: false,
                    tktMssgISFORWARD: false,
                    tktMssgREPLYTOMSSGDOC: {},
                    tktMssgTicketName: widget.call.ticketTitle!,
                    tktMssgTicketIDflitered: widget.call.ticketIDfiltered!,
                    tktMssgSENDFOR: [
                      MssgSendFor.agent.index,
                      MssgSendFor.customer.index,
                    ],
                    tktMsgSenderIndex: widget.call.callTypeIndex ==
                            CallTypeIndex.callToAgentFromCustomerInTICKET.index
                        ? Usertype.customer.index
                        : Usertype.agent.index,
                    tktMsgInt2: 0,
                    isShowSenderNameInNotification: isShownamePhoto,
                    tktMsgBool2: true,
                    notificationActiveList: [],
                    tktMssgLISToptional: [],
                    tktMsgList2: [],
                    tktMsgList3: [],
                    tktMsgMap1: {},
                    tktMsgMap2: {},
                    tktMsgDELETEREASON: widget.currentUserisAgent
                        ? widget.call.callerId!
                        : widget.call.receiverId!,
                    tktMsgDELETEDby: '',
                    tktMsgString4: '',
                    tktMsgString5: '',
                    ttktMsgString3: '',
                  ).toMap(),
                  SetOptions(merge: true));
        }
        FirebaseFirestore.instance
            .collection(callerCollectionpath)
            .doc(widget.call.callerId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'TICKET_ID': widget.call.ticketID,
          'TYPE': 'OUTGOING',
          'ISVIDEOCALL': widget.call.isvideocall,
          'PEER': widget.call.receiverId,
          'TARGET': widget.call.receiverId,
          'TIME': widget.call.timeepoch,
          'DP': widget.call.receiverPic,
          'ISMUTED': false,
          'ISJOINEDEVER': false,
          'STATUS': 'calling',
          'STARTED': null,
          'ENDED': null,
          'CALLERNAME': isShownamePhoto == false
              ? widget.callTypeindex ==
                      CallTypeIndex.callToAgentFromAgentInPERSONAL.index
                  ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${widget.call.callerId}"
                  : widget.callTypeindex ==
                          CallTypeIndex.callToAgentFromCustomerInTICKET.index
                      ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${widget.call.callerId} - ${getTranslatedForCurrentUser(context, 'xxsupporttktxx')}"
                      : widget.callTypeindex ==
                              CallTypeIndex
                                  .callToAgentFromCustomerInTICKET.index
                          ? "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${widget.call.callerId}"
                          : "${getTranslatedForCurrentUser(context, 'xxidxx')} ${widget.call.callerId}"
              : widget.call.callerName,
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(recieverCollectionPath)
            .doc(widget.call.receiverId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'TICKET_ID': widget.call.ticketID,
          'TYPE': 'INCOMING',
          'ISVIDEOCALL': widget.call.isvideocall,
          'PEER': widget.call.callerId,
          'TARGET': widget.call.receiverId,
          'TIME': widget.call.timeepoch,
          'DP': widget.call.callerPic,
          'ISMUTED': false,
          'ISJOINEDEVER': true,
          'STATUS': 'missedcall',
          'STARTED': null,
          'ENDED': null,
          'CALLERNAME': isShownamePhoto == false
              ? widget.callTypeindex ==
                      CallTypeIndex.callToAgentFromAgentInPERSONAL.index
                  ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${widget.call.callerId}"
                  : widget.callTypeindex ==
                          CallTypeIndex.callToAgentFromCustomerInTICKET.index
                      ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${widget.call.callerId} - ${getTranslatedForCurrentUser(context, 'xxsupporttktxx')}"
                      : widget.callTypeindex ==
                              CallTypeIndex
                                  .callToAgentFromCustomerInTICKET.index
                          ? "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')}: ${widget.call.callerId}"
                          : "${getTranslatedForCurrentUser(context, 'xxidxx')} ${widget.call.callerId}"
              : widget.call.callerName,
        }, SetOptions(merge: true));
      }
      Wakelock.enable();
    }, leaveChannel: (stats) {
      _stopCallingSound();

      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
      if (isalreadyendedcall == false) {
        var now = DateTime.now();
        FirebaseFirestore.instance
            .collection(callerCollectionpath)
            .doc(widget.call.callerId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STATUS': 'ended',
          'ENDED': now,
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(recieverCollectionPath)
            .doc(widget.call.receiverId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STATUS': 'ended',
          'ENDED': now,
        }, SetOptions(merge: true));
        //----------
        FirebaseFirestore.instance
            .collection(recieverCollectionPath)
            .doc(widget.call.receiverId)
            .collection('recent')
            .doc('xxcallendedxx')
            .set({
          'TICKET_ID': widget.call.ticketID,
          'id': widget.call.receiverId,
          'ENDED': DateTime.now().millisecondsSinceEpoch,
          'CALLERNAME': isShownamePhoto == false
              ? widget.callTypeindex ==
                      CallTypeIndex.callToAgentFromAgentInPERSONAL.index
                  ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${widget.call.callerId}"
                  : widget.callTypeindex ==
                          CallTypeIndex.callToAgentFromCustomerInTICKET.index
                      ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${widget.call.callerId} - ${getTranslatedForCurrentUser(context, 'xxsupporttktxx')}"
                      : widget.callTypeindex ==
                              CallTypeIndex
                                  .callToAgentFromCustomerInTICKET.index
                          ? "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${widget.call.callerId}"
                          : "${getTranslatedForCurrentUser(context, 'xxidxx')} ${widget.call.callerId}"
              : widget.call.callerName,
        }, SetOptions(merge: true));
      }
      Wakelock.disable();
    }, userJoined: (uid, elapsed) {
      startTimerNow();

      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
      if (widget.currentUserID == widget.call.callerId) {
        _stopCallingSound();
        FirebaseFirestore.instance
            .collection(callerCollectionpath)
            .doc(widget.call.callerId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STARTED': DateTime.now(),
          'STATUS': 'pickedup',
          'ISJOINEDEVER': true,
        }, SetOptions(merge: true));

        FirebaseFirestore.instance
            .collection(recieverCollectionPath)
            .doc(widget.call.receiverId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STARTED': DateTime.now(),
          'STATUS': 'pickedup',
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(callerCollectionpath)
            .doc(widget.call.callerId)
            .set({
          Dbkeys.audioCallMade: FieldValue.increment(1),
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(recieverCollectionPath)
            .doc(widget.call.receiverId)
            .set({
          Dbkeys.audioCallRecieved: FieldValue.increment(1),
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(DbPaths.userapp)
            .doc(DbPaths.docdashboarddata)
            .set({
          Dbkeys.audioCallMade: FieldValue.increment(1),
        }, SetOptions(merge: true));
      }
      Wakelock.enable();
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
      _stopCallingSound();
      if (isalreadyendedcall == false) {
        var now = DateTime.now();
        FirebaseFirestore.instance
            .collection(callerCollectionpath)
            .doc(widget.call.callerId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STATUS': 'ended',
          'ENDED': now,
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(recieverCollectionPath)
            .doc(widget.call.receiverId)
            .collection(DbPaths.collectioncallhistory)
            .doc(widget.call.timeepoch.toString())
            .set({
          'STATUS': 'ended',
          'ENDED': now,
        }, SetOptions(merge: true));
        //----------
        FirebaseFirestore.instance
            .collection(recieverCollectionPath)
            .doc(widget.call.receiverId)
            .collection('recent')
            .doc('xxcallendedxx')
            .set({
          'TICKET_ID': widget.call.ticketID,
          'id': widget.call.receiverId,
          'ENDED': DateTime.now().millisecondsSinceEpoch,
          'CALLERNAME': isShownamePhoto == false
              ? widget.callTypeindex ==
                      CallTypeIndex.callToAgentFromAgentInPERSONAL.index
                  ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${widget.call.callerId}"
                  : widget.callTypeindex ==
                          CallTypeIndex.callToAgentFromCustomerInTICKET.index
                      ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${widget.call.callerId} - ${getTranslatedForCurrentUser(context, 'xxsupporttktxx')}"
                      : widget.callTypeindex ==
                              CallTypeIndex
                                  .callToAgentFromCustomerInTICKET.index
                          ? "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${widget.call.callerId}"
                          : "${getTranslatedForCurrentUser(context, 'xxidxx')} ${widget.call.callerId}"
              : widget.call.callerName,
        }, SetOptions(merge: true));
      }
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    }));
  }

  Widget _toolbar(
    bool isshowspeaker,
    String? status,
  ) {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          status == 'ended' || status == 'rejected'
              ? SizedBox(height: 42, width: 42)
              : RawMaterialButton(
                  onPressed: _onToggleMute,
                  child: Icon(
                    muted ? Icons.mic_off : Icons.mic,
                    color: muted ? Colors.white : Colors.blueAccent,
                    size: 22.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: muted ? Colors.blueAccent : Colors.white,
                  padding: const EdgeInsets.all(12.0),
                ),
          RawMaterialButton(
            onPressed: () async {
              setState(() {
                isalreadyendedcall =
                    status == 'ended' || status == 'rejected' ? true : false;
              });

              _onCallEnd(context);
            },
            child: Icon(
              status == 'ended' || status == 'rejected'
                  ? Icons.close
                  : Icons.call,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: status == 'ended' || status == 'rejected'
                ? Colors.black
                : Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          isshowspeaker == true
              ? RawMaterialButton(
                  onPressed: _onToggleSpeaker,
                  child: Icon(
                    isspeaker
                        ? Icons.volume_mute_rounded
                        : Icons.volume_off_sharp,
                    color: isspeaker ? Colors.white : Colors.blueAccent,
                    size: 22.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: isspeaker ? Colors.blueAccent : Colors.white,
                  padding: const EdgeInsets.all(12.0),
                )
              : SizedBox(height: 42, width: 42)
        ],
      ),
    );
  }

  audioscreenForPORTRAIT({
    required BuildContext context,
    String? status,
    bool? ispeermuted,
  }) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    if (status == 'rejected') {
      _stopCallingSound();
    }
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            color: Mycolors.primary,
            height: h / 4,
            width: w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 29),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Icon(
                //       Icons.lock_rounded,
                //       size: 17,
                //       color: Colors.white38,
                //     ),
                //     SizedBox(
                //       width: 6,
                //     ),
                //     // Text(
                //     // "label",
                //     //   style: TextStyle(
                //     //       color: Colors.white38, fontWeight: FontWeight.w400),
                //     // ),
                //   ],
                // ),
                // SizedBox(height: h / 35),
                SizedBox(
                  height: h / 9,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 7),
                      SizedBox(
                        width: w / 1.1,
                        child: Text(
                          widget.isShownamePhotoToCaller == false
                              ? getTranslatedForCurrentUser(
                                  context, 'xxagentxx')
                              : widget.call.callerId == widget.currentUserID
                                  ? widget.call.receiverName!
                                  : widget.call.callerName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 27,
                          ),
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        widget.call.callerId == widget.currentUserID
                            ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} " +
                                widget.call.receiverId!
                            : "${getTranslatedForCurrentUser(context, 'xxagentidxx')} " +
                                widget.call.callerId!,
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
                status == 'pickedup'
                    ? Text(
                        "$hoursStr:$minutesStr:$secondsStr",
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.green[300],
                            fontWeight: FontWeight.w600),
                      )
                    : Text(
                        status == 'pickedup'
                            ? getTranslatedForCurrentUser(context, 'xxpickedxx')
                            : status == 'nonetwork'
                                ? getTranslatedForCurrentUser(
                                    context, 'xxconnectingxx')
                                : status == 'ringing' || status == 'missedcall'
                                    ? getTranslatedForCurrentUser(
                                        context, 'xxcallingxx')
                                    : status == 'calling'
                                        ? getTranslatedForCurrentUser(
                                            context,
                                            widget.call.receiverId ==
                                                    widget.currentUserID
                                                ? 'xxconnectingxx'
                                                : 'xxcallingxx')
                                        : status == 'pickedup'
                                            ? getTranslatedForCurrentUser(
                                                context, 'xxoncallxx')
                                            : status == 'ended'
                                                ? getTranslatedForCurrentUser(
                                                    context, 'xxcallendedxx')
                                                : status == 'rejected'
                                                    ? getTranslatedForCurrentUser(
                                                        context,
                                                        'xxcallrejectedxx')
                                                    : getTranslatedForCurrentUser(
                                                        context, 'xxplswaitxx'),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: status == 'pickedup'
                              ? Mycolors.secondary
                              : Colors.white,
                          fontSize: 18,
                        ),
                      ),
                SizedBox(height: 16),
              ],
            ),
          ),
          Stack(
            children: [
              widget.isShownamePhotoToCaller == false
                  ? Container(
                      height: w + (w / 11),
                      width: w,
                      color: Colors.white12,
                      child: Icon(
                        Icons.person,
                        size: 140,
                        color: Mycolors.primary,
                      ),
                    )
                  : widget.call.callerId == widget.currentUserID
                      ? widget.call.receiverPic == null ||
                              widget.call.receiverPic == '' ||
                              status == 'ended' ||
                              status == 'rejected'
                          ? Container(
                              height: w + (w / 11),
                              width: w,
                              color: Colors.white12,
                              child: Icon(
                                status == 'ended'
                                    ? Icons.person_off
                                    : status == 'rejected'
                                        ? Icons.call_end_rounded
                                        : Icons.person,
                                size: 140,
                                color: Mycolors.primary,
                              ),
                            )
                          : Stack(
                              children: [
                                Container(
                                    height: w + (w / 11),
                                    width: w,
                                    color: Colors.white12,
                                    child: CachedNetworkImage(
                                      imageUrl: widget.call.callerId ==
                                              widget.currentUserID
                                          ? widget.call.receiverPic!
                                          : widget.call.callerPic!,
                                      fit: BoxFit.cover,
                                      height: w + (w / 11),
                                      width: w,
                                      placeholder: (context, url) => Center(
                                          child: Container(
                                        height: w + (w / 11),
                                        width: w,
                                        color: Colors.white12,
                                        child: Icon(
                                          status == 'ended'
                                              ? Icons.person_off
                                              : status == 'rejected'
                                                  ? Icons.call_end_rounded
                                                  : Icons.person,
                                          size: 140,
                                          color: Mycolors.primary,
                                        ),
                                      )),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        height: w + (w / 11),
                                        width: w,
                                        color: Colors.white12,
                                        child: Icon(
                                          status == 'ended'
                                              ? Icons.person_off
                                              : status == 'rejected'
                                                  ? Icons.call_end_rounded
                                                  : Icons.person,
                                          size: 140,
                                          color: Mycolors.primary,
                                        ),
                                      ),
                                    )),
                                Container(
                                  height: w + (w / 11),
                                  width: w,
                                  color: Colors.black.withOpacity(0.18),
                                ),
                              ],
                            )
                      : widget.call.callerPic == null ||
                              widget.call.callerPic == '' ||
                              status == 'ended' ||
                              status == 'rejected'
                          ? Container(
                              height: w + (w / 11),
                              width: w,
                              color: Colors.white12,
                              child: Icon(
                                status == 'ended'
                                    ? Icons.person_off
                                    : status == 'rejected'
                                        ? Icons.call_end_rounded
                                        : Icons.person,
                                size: 140,
                                color: Mycolors.primary,
                              ),
                            )
                          : Stack(
                              children: [
                                Container(
                                    height: w + (w / 11),
                                    width: w,
                                    color: Mycolors.primary.withOpacity(0.6),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.call.callerId ==
                                              widget.currentUserID
                                          ? widget.call.receiverPic!
                                          : widget.call.callerPic!,
                                      fit: BoxFit.cover,
                                      height: w + (w / 11),
                                      width: w,
                                      placeholder: (context, url) => Center(
                                          child: Container(
                                        height: w + (w / 11),
                                        width: w,
                                        color: Colors.white12,
                                        child: Icon(
                                          status == 'ended'
                                              ? Icons.person_off
                                              : status == 'rejected'
                                                  ? Icons.call_end_rounded
                                                  : Icons.person,
                                          size: 140,
                                          color: Mycolors.primary,
                                        ),
                                      )),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        height: w + (w / 11),
                                        width: w,
                                        color: Colors.white12,
                                        child: Icon(
                                          status == 'ended'
                                              ? Icons.person_off
                                              : status == 'rejected'
                                                  ? Icons.call_end_rounded
                                                  : Icons.person,
                                          size: 140,
                                          color: Mycolors.primary,
                                        ),
                                      ),
                                    )),
                                Container(
                                  height: w + (w / 11),
                                  width: w,
                                  color: Colors.black.withOpacity(0.18),
                                ),
                              ],
                            ),
              Positioned(
                  bottom: 20,
                  child: Container(
                    width: w,
                    height: 20,
                    child: Center(
                      child: status == 'pickedup'
                          ? ispeermuted == true
                              ? Text(
                                  getTranslatedForCurrentUser(
                                      context, 'xxmutedxx'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.yellow,
                                    fontSize: 16,
                                  ),
                                )
                              : SizedBox(
                                  height: 0,
                                )
                          : SizedBox(
                              height: 0,
                            ),
                    ),
                  )),
            ],
          ),
          SizedBox(height: h / 6),
        ],
      ),
    );
  }

  audioscreenForLANDSCAPE({
    required BuildContext context,
    String? status,
    bool? ispeermuted,
  }) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    if (status == 'rejected') {
      _stopCallingSound();
    }
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            status == 'nonetwork'
                ? getTranslatedForCurrentUser(context, 'xxconnectingxx')
                : status == 'ringing' || status == 'missedcall'
                    ? getTranslatedForCurrentUser(context, 'xxcallingxx')
                    : status == 'calling'
                        ? getTranslatedForCurrentUser(context, 'xxcallingxx')
                        : status == 'pickedup'
                            ? getTranslatedForCurrentUser(context, 'xxoncallxx')
                            : status == 'ended'
                                ? getTranslatedForCurrentUser(
                                    context, 'xxcallendedxx')
                                : status == 'rejected'
                                    ? getTranslatedForCurrentUser(
                                        context, 'xxcallrejectedxx')
                                    : getTranslatedForCurrentUser(
                                        context, 'xxplswaitxx'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: status == 'pickedup' ? Mycolors.secondary : Mycolors.black,
              fontSize: 25,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              status == 'pickedup'
                  ? getTranslatedForCurrentUser(context, 'xxpickedxx')
                  : getTranslatedForCurrentUser(context, 'xxvoicexx'),
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: status == 'pickedup' ? Mycolors.black : Mycolors.primary,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 25),
          status != 'pickedup'
              ? SizedBox()
              : Text(
                  "$hoursStr:$minutesStr:$secondsStr",
                  style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.pink,
                      fontWeight: FontWeight.w700),
                ),
          SizedBox(height: 45),
          status == 'pickedup'
              ? widget.call.callerId == widget.currentUserID
                  ? widget.call.receiverPic == null
                      ? SizedBox(
                          height: w > h ? 60 : 140,
                        )
                      : CachedImage(
                          widget.call.callerId == widget.currentUserID
                              ? widget.call.receiverPic
                              : widget.call.callerPic,
                          isRound: true,
                          height: w > h ? 60 : 140,
                          width: w > h ? 60 : 140,
                          radius: w > h ? 70 : 168,
                        )
                  : widget.call.callerPic == null
                      ? SizedBox(
                          height: w > h ? 60 : 140,
                        )
                      : CachedImage(
                          widget.call.callerId == widget.currentUserID
                              ? widget.call.receiverPic
                              : widget.call.callerPic,
                          isRound: true,
                          height: w > h ? 60 : 140,
                          width: w > h ? 60 : 140,
                          radius: w > h ? 70 : 168,
                        )
              : Container(
                  height: w > h ? 60 : 140,
                  width: w > h ? 60 : 140,
                  child: Icon(
                    status == 'ended' ||
                            status == 'rejected' ||
                            status == 'pickedup'
                        ? Icons.call_end_sharp
                        : Icons.call,
                    size: w > h ? 60 : 140,
                    color: Mycolors.black.withOpacity(0.25),
                  ),
                ),
          SizedBox(height: 45),
          Text(
            widget.isShownamePhotoToCaller == false
                ? getTranslatedForCurrentUser(context, 'xxagentxx')
                : widget.call.callerId == widget.currentUserID
                    ? widget.call.receiverName!
                    : widget.call.callerName!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Mycolors.black,
              fontSize: 22,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            widget.call.callerId == widget.currentUserID
                ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} " +
                    widget.call.receiverId!
                : "${getTranslatedForCurrentUser(context, 'xxagentidxx')} " +
                    widget.call.callerId!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Mycolors.black.withOpacity(0.54),
              fontSize: 19,
            ),
          ),
          SizedBox(
            height: h / 10,
          ),
          status == 'pickedup'
              ? ispeermuted == true
                  ? Text(
                      getTranslatedForCurrentUser(context, 'xxmutedxx'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 19,
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    )
              : SizedBox(
                  height: 0,
                )
        ],
      ),
    );
  }

  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return SizedBox();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) async {
    final observer = Provider.of<Observer>(this.context, listen: false);

    SpecialLiveConfigData? livedata =
        Provider.of<SpecialLiveConfigData?>(this.context, listen: false);
    bool isShownamePhoto =
        observer.userAppSettingsDoc!.agentcanseeagentnameandphoto! == true ||
            (iAmSecondAdmin(
                        specialLiveConfigData: livedata,
                        currentuserid: widget.call.receiverId!,
                        context: context) ==
                    true &&
                observer.userAppSettingsDoc!
                        .secondadmincanseeagentnameandphoto ==
                    true) ||
            (iAmDepartmentManager(
                        currentuserid: widget.call.receiverId!,
                        context: context) ==
                    true &&
                observer.userAppSettingsDoc!
                        .departmentmanagercanseeagentnameandphoto ==
                    true);
    final FirestoreDataProviderCALLHISTORY firestoreDataProviderCALLHISTORY =
        Provider.of<FirestoreDataProviderCALLHISTORY>(context, listen: false);
    stopWatchStream();
    await CallUtils.callMethods.endCall(call: widget.call);
    DateTime now = DateTime.now();
    _stopCallingSound();
    if (isalreadyendedcall == false) {
      await FirebaseFirestore.instance
          .collection(callerCollectionpath)
          .doc(widget.call.callerId)
          .collection(DbPaths.collectioncallhistory)
          .doc(widget.call.timeepoch.toString())
          .set({'STATUS': 'ended', 'ENDED': now}, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(recieverCollectionPath)
          .doc(widget.call.receiverId)
          .collection(DbPaths.collectioncallhistory)
          .doc(widget.call.timeepoch.toString())
          .set({'STATUS': 'ended', 'ENDED': now}, SetOptions(merge: true));
      //----------
      await FirebaseFirestore.instance
          .collection(recieverCollectionPath)
          .doc(widget.call.receiverId)
          .collection('recent')
          .doc('xxcallendedxx')
          .set({
        'TICKET_ID': widget.call.ticketID,
        'id': widget.call.receiverId,
        'ENDED': DateTime.now().millisecondsSinceEpoch,
        'CALLERNAME': isShownamePhoto == false
            ? widget.callTypeindex ==
                    CallTypeIndex.callToAgentFromAgentInPERSONAL.index
                ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${widget.call.callerId}"
                : widget.callTypeindex ==
                        CallTypeIndex.callToAgentFromCustomerInTICKET.index
                    ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${widget.call.callerId} - ${getTranslatedForCurrentUser(context, 'xxsupporttktxx')}"
                    : widget.callTypeindex ==
                            CallTypeIndex.callToAgentFromCustomerInTICKET.index
                        ? "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${widget.call.callerId}"
                        : "${getTranslatedForCurrentUser(context, 'xxidxx')} ${widget.call.callerId}"
            : widget.call.callerName,
      }, SetOptions(merge: true));
    }
    Wakelock.disable();
    firestoreDataProviderCALLHISTORY.fetchNextData(
        'CALLHISTORY',
        FirebaseFirestore.instance
            .collection(widget.currentUserisAgent == true
                ? DbPaths.collectionagents
                : DbPaths.collectioncustomers)
            .doc(widget.currentUserID)
            .collection(DbPaths.collectioncallhistory)
            .orderBy('TIME', descending: true)
            .limit(14),
        true);
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _stopCallingSound();
    _engine.muteLocalAudioStream(muted);
    FirebaseFirestore.instance
        .collection(widget.currentUserisAgent == true
            ? DbPaths.collectionagents
            : DbPaths.collectioncustomers)
        .doc(widget.currentUserID)
        .collection(DbPaths.collectioncallhistory)
        .doc(widget.call.timeepoch.toString())
        .set({'ISMUTED': muted}, SetOptions(merge: true));
  }

  void _onToggleSpeaker() {
    setState(() {
      isspeaker = !isspeaker;
    });
    _engine.setEnableSpeakerphone(isspeaker);
  }

  Future<bool> onWillPopNEw(BuildContext context) {
    // _onCallEnd(context);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () => onWillPopNEw(context),
      child: h > w && ((h / w) > 1.5)
          ? Scaffold(
              backgroundColor: Mycolors.primary,
              body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream:
                    stream as Stream<DocumentSnapshot<Map<String, dynamic>>>?,
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.data() == null ||
                        snapshot.data == null) {
                      return Center(
                        child: Stack(
                          children: <Widget>[
                            audioscreenForPORTRAIT(
                                context: context,
                                status: 'calling',
                                ispeermuted: false),
                            _panel(),
                            _toolbar(false, 'calling'),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: Stack(
                          children: <Widget>[
                            // _viewRows(),
                            audioscreenForPORTRAIT(
                                context: context,
                                status: snapshot.data!.data()!["STATUS"],
                                ispeermuted: snapshot.data!.data()!["ISMUTED"]),

                            _panel(),
                            _toolbar(
                                snapshot.data!.data()!["STATUS"] == 'pickedup'
                                    ? true
                                    : false,
                                snapshot.data!.data()!["STATUS"]),
                          ],
                        ),
                      );
                    }
                  } else if (!snapshot.hasData) {
                    return Center(
                      child: Stack(
                        children: <Widget>[
                          // _viewRows(),
                          audioscreenForPORTRAIT(
                              context: context,
                              status: 'nonetwork',
                              ispeermuted: false),
                          _panel(),
                          _toolbar(false, 'nonetwork'),
                        ],
                      ),
                    );
                  }

                  return Center(
                    child: Stack(
                      children: <Widget>[
                        // _viewRows(),
                        audioscreenForPORTRAIT(
                            context: context,
                            status: 'calling',
                            ispeermuted: false),
                        _panel(),
                        _toolbar(false, 'calling'),
                      ],
                    ),
                  );
                },
              ))
          : Scaffold(
              backgroundColor: Colors.white,
              body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream:
                    stream as Stream<DocumentSnapshot<Map<String, dynamic>>>?,
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.data() == null ||
                        snapshot.data == null) {
                      return Center(
                        child: Stack(
                          children: <Widget>[
                            audioscreenForLANDSCAPE(
                                context: context,
                                status: 'calling',
                                ispeermuted: false),
                            _panel(),
                            _toolbar(false, 'calling'),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: Stack(
                          children: <Widget>[
                            // _viewRows(),
                            audioscreenForLANDSCAPE(
                                context: context,
                                status: snapshot.data!.data()!["STATUS"],
                                ispeermuted: snapshot.data!.data()!["ISMUTED"]),
                            _panel(),
                            _toolbar(
                                snapshot.data!.data()!["STATUS"] == 'pickedup'
                                    ? true
                                    : false,
                                snapshot.data!.data()!["STATUS"]),
                          ],
                        ),
                      );
                    }
                  } else if (!snapshot.hasData) {
                    return Center(
                      child: Stack(
                        children: <Widget>[
                          // _viewRows(),
                          audioscreenForLANDSCAPE(
                              context: context,
                              status: 'nonetwork',
                              ispeermuted: false),
                          _panel(),
                          _toolbar(false, 'nonetwork'),
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: Stack(
                      children: <Widget>[
                        // _viewRows(),
                        audioscreenForLANDSCAPE(
                            context: context,
                            status: 'calling',
                            ispeermuted: false),
                        _panel(),
                        _toolbar(false, 'calling'),
                      ],
                    ),
                  );
                },
              )),
    );
  }

  //------ Timer Widget Section Below:
  bool flag = true;
  Stream<int>? timerStream;
  // ignore: cancel_subscriptions
  StreamSubscription<int>? timerSubscription;
  // ignore: close_sinks
  StreamController<int>? streamController;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';

  Stream<int> stopWatchStream() {
    // ignore: close_sinks

    Timer? timer;
    Duration timerInterval = Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer!.cancel();
        timer = null;
        counter = 0;
        streamController!.close();
      }
    }

    void tick(_) {
      counter++;
      streamController!.add(counter);
      if (!flag) {
        stopTimer();
      }
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController!.stream;
  }

  startTimerNow() {
    timerStream = stopWatchStream();
    timerSubscription = timerStream!.listen((int newTick) {
      setState(() {
        hoursStr =
            ((newTick / (60 * 60)) % 60).floor().toString().padLeft(2, '0');
        minutesStr = ((newTick / 60) % 60).floor().toString().padLeft(2, '0');
        secondsStr = (newTick % 60).floor().toString().padLeft(2, '0');
      });
      flutterLocalNotificationsPlugin.cancelAll();
    });
  }

  //------
}
