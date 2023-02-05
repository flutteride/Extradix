//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/optional_constants.dart';
import 'package:thinkcreative_technologies/Models/customer_model.dart';
import 'package:thinkcreative_technologies/Models/ticket_message.dart';
import 'package:thinkcreative_technologies/Models/ticket_model.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/TicketUtils/ticket_utils.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/quick_replies.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/close_ticket_action_widget.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/isRoboticResponse.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/messageTypeWidgets/close_message.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/messageTypeWidgets/created_message.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/messageTypeWidgets/deniedclosingrequest_message.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/messageTypeWidgets/removeattention_message.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/messageTypeWidgets/reopen_message.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/messageTypeWidgets/requestclose_message.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/messageTypeWidgets/requireattention_message.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/rate_widget.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/reopen_widget.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/ticket_menu.dart';
import 'package:thinkcreative_technologies/Utils/formatStatusTime.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/ticket_appbar.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/ticket_chat_bubble.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/chat.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/utils/uploadMediaWithProgress.dart';
import 'package:thinkcreative_technologies/Services/Admob/admob.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/TicketChatProvider.dart';
import 'package:thinkcreative_technologies/Services/Providers/liveListener.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Utils/crc.dart';
import 'package:thinkcreative_technologies/Utils/custom_url_launcher.dart';
import 'package:thinkcreative_technologies/Utils/setStatusBarColor.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/widgets/AllinOneCameraGalleryImageVideoPicker/AllinOneCameraGalleryImageVideoPicker.dart';
import 'package:thinkcreative_technologies/widgets/CameraGalleryImagePicker/camera_image_gallery_picker.dart';
import 'package:thinkcreative_technologies/widgets/CameraGalleryImagePicker/multiMediaPicker.dart';
import 'package:thinkcreative_technologies/widgets/CustomAlertDialog/CustomDialog.dart';
import 'package:thinkcreative_technologies/widgets/InfiniteList/InfiniteCOLLECTIONListViewWidget.dart';
import 'package:thinkcreative_technologies/widgets/MultiDocumentPicker/multiDocumentPicker.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/late_load.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/loadingDialog.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:media_info/media_info.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emojipic;
import 'dart:convert';
import 'dart:io';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Screens/privacypolicy&TnC/PdfViewFromCachedUrl.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/page_navigator.dart';
import 'package:thinkcreative_technologies/widgets/SoundPlayer/SoundPlayerPro.dart';
import 'package:thinkcreative_technologies/Services/Providers/currentchat_peer.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/callhistory.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/utils/downloadMedia.dart';
import 'package:thinkcreative_technologies/Models/DataModel.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/utils/photo_view.dart';
import 'package:thinkcreative_technologies/Utils/save.dart';
import 'package:thinkcreative_technologies/widgets/AudioRecorder/Audiorecord.dart';
import 'package:thinkcreative_technologies/widgets/VideoEditor/video_editor.dart';
import 'package:thinkcreative_technologies/widgets/VideoPicker/VideoPreview.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Utils/unawaited.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:stream_transform/stream_transform.dart';
import 'package:path/path.dart' as p;

const List<Color> _kDefaultRainbowColors = const [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

class TicketChatRoom extends StatefulWidget {
  final String currentUserID;
  final String ticketID;

  final String customerUID;
  final DataModel model;
  final SharedPreferences prefs;
  final List<SharedMediaFile>? sharedFiles;
  final MessageType? sharedFilestype;
  final bool isSharingIntentForwarded;
  final String? sharedText;
  final String currentuserfullname;
  final bool cuurentUserCanSeeCustomerNamePhoto;
  final bool cuurentUserCanSeeAgentNamePhoto;
  final String? ticketTitle;

  final List<dynamic> agentsListinParticularDepartment;

  TicketChatRoom({
    Key? key,
    required this.currentUserID,
    required this.ticketID,
    required this.customerUID,
    required this.model,
    required this.prefs,
    required this.cuurentUserCanSeeAgentNamePhoto,
    required this.cuurentUserCanSeeCustomerNamePhoto,
    required this.currentuserfullname,
    required this.isSharingIntentForwarded,
    required this.agentsListinParticularDepartment,
    this.ticketTitle,
    this.sharedFiles,
    this.sharedFilestype,
    this.sharedText,
  }) : super(key: key);

  @override
  _TicketChatRoomState createState() => _TicketChatRoomState();
}

class _TicketChatRoomState extends State<TicketChatRoom>
    with WidgetsBindingObserver {
  bool isgeneratingSomethingLoader = false;
  int tempSendIndex = 0;
  late String messageReplyOwnerName;
  bool isPreLoading = false;
  late Query firestoreChatquery;
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  GlobalKey<State> _keyLoader =
      new GlobalKey<State>(debugLabel: 'qqqeqeqsssaadqeqe');
  final ScrollController realtime = new ScrollController();
  Map<String, dynamic>? replyDoc;
  bool isReplyKeyboard = false;
  InterstitialAd? _interstitialAd;

  int _numInterstitialLoadAttempts = 0;
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  late Stream<DocumentSnapshot> streamTicketSnapshots;
  late Stream<DocumentSnapshot> customerLiveSnapshots;
  bool isSecretChat = false;
  int finalrating = 0;
  final GlobalKey<State> _keyLoader225645 =
      new GlobalKey<State>(debugLabel: 'dsdadasd');
  StreamController<String> controller = StreamController();
  StreamTransformer<String, dynamic> debounce = StreamTransformer.fromBind(
      (s) => s.debounce(const Duration(milliseconds: 3000)));

  @override
  void initState() {
    super.initState();

    controller.stream.transform(this.debounce).listen((s) {
      setStateIfMounted(() {
        isAmTyping = false;
      });
      if (widget.currentUserID == widget.customerUID) {
        FirebaseFirestore.instance
            .collection(DbPaths.collectiontickets)
            .doc(widget.ticketID)
            .collection(DbPaths.collectioncLIVEEVENTS)
            .doc(Dbkeys.liveEventListenForAgent)
            .set({"customer": false, "currentagenttyping": ""},
                SetOptions(merge: true));
      } else {
        FirebaseFirestore.instance
            .collection(DbPaths.collectiontickets)
            .doc(widget.ticketID)
            .collection(DbPaths.collectioncLIVEEVENTS)
            .doc(Dbkeys.liveEventListenForCustomer)
            .set({
          "agentid--${widget.currentUserID}": false,
          // "agentid": "",
        }, SetOptions(merge: true));
      }
    });
    streamTicketSnapshots = FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        .doc(widget.ticketID)
        .snapshots();
    customerLiveSnapshots = FirebaseFirestore.instance
        .collection(DbPaths.collectioncustomers)
        .doc(widget.customerUID)
        .snapshots();
    firestoreChatquery = widget.currentUserID == widget.customerUID
        ? FirebaseFirestore.instance
            .collection(DbPaths.collectiontickets)
            .doc(widget.ticketID)
            .collection(DbPaths.collectionticketChats)
            .where(Dbkeys.tktMssgSENDFOR,
                arrayContains: MssgSendFor.customer.index)
            .orderBy(Dbkeys.tktMssgTIME, descending: true)
            .limit(maxChatMessageDocsLoadAtOnce)
        : FirebaseFirestore.instance
            .collection(DbPaths.collectiontickets)
            .doc(widget.ticketID)
            .collection(DbPaths.collectionticketChats)
            .orderBy(Dbkeys.tktMssgTIME, descending: true)
            .limit(maxChatMessageDocsLoadAtOnce * 1);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var currentpeer =
          Provider.of<CurrentChatPeer>(this.context, listen: false);
      var firestoreProvider =
          Provider.of<FirestoreDataProviderMESSAGESforTICKETCHAT>(this.context,
              listen: false);
      final observer = Provider.of<Observer>(this.context, listen: false);
      currentpeer.setpeer(widget.ticketID);
      firestoreProvider.reset();
      Future.delayed(const Duration(milliseconds: 1700), () {
        loadMessagesAndListen();

        Future.delayed(const Duration(milliseconds: 3000), () {
          if (IsVideoAdShow == true && observer.isadmobshow == true) {
            _createRewardedAd();
          }

          if (IsInterstitialAdShow == true && observer.isadmobshow == true) {
            _createInterstitialAd();
          }
        });
      });
    });
    // Future.delayed(const Duration(milliseconds: 200), () {
    //   isPreLoading = false;
    // });
    setAgentOnline();
  }

  setAgentOnline() {
    if (widget.currentUserID != widget.customerUID) {
      FirebaseFirestore.instance
          .collection(DbPaths.collectiontickets)
          .doc(widget.ticketID)
          .update(widget.agentsListinParticularDepartment.length != 0
              ? {
                  Dbkeys.liveAgentID: widget.currentUserID,
                  Dbkeys.liveAgentLastonline:
                      DateTime.now().millisecondsSinceEpoch,
                  Dbkeys.tktMEMBERSactiveList:
                      widget.agentsListinParticularDepartment
                }
              : {
                  Dbkeys.liveAgentID: widget.currentUserID,
                  Dbkeys.liveAgentLastonline:
                      DateTime.now().millisecondsSinceEpoch,
                });
    }
  }

  bool isPeerTyping = false;
  // ignore: cancel_subscriptions
  StreamSubscription<QuerySnapshot>? subscription;
  // ignore: cancel_subscriptions
  StreamSubscription<QuerySnapshot>? typingSubscriptionForAgents;
  List<DocumentSnapshot<Map<String, dynamic>>> typingList = [];
  loadMessagesAndListen() async {
    if (widget.currentUserID != widget.customerUID) {
      typingSubscriptionForAgents = FirebaseFirestore.instance
          .collection(DbPaths.collectiontickets)
          .doc(widget.ticketID)
          .collection(DbPaths.collectioncLIVEEVENTS)
          .where('currentagenttyping', isNotEqualTo: widget.currentUserID)
          .snapshots()
          .listen((snapshot) {
        snapshot.docChanges.forEach((change) {
          if (change.type == DocumentChangeType.added) {
            typingList.add(change.doc);
          } else if (change.type == DocumentChangeType.modified) {
            typingList.removeWhere(
                (element) => element.reference.id == change.doc.id);
            typingList.add(change.doc);
            setStateIfMounted(() {});
          } else if (change.type == DocumentChangeType.removed) {
            typingList.remove(change.doc);
            setStateIfMounted(() {});
          }
        });
      });
    }

    subscription = firestoreChatquery.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          var chatprovider =
              Provider.of<FirestoreDataProviderMESSAGESforTICKETCHAT>(
                  this.context,
                  listen: false);
          DocumentSnapshot newDoc = change.doc;
          // if (chatprovider.datalistSnapshot.length == 0) {
          // } else if ((chatprovider.checkIfDocAlreadyExits(
          //       newDoc: newDoc,
          //     ) ==
          //     false)) {

          // if (newmssg.tktMssgSENDBY != widget.currentUserID) {
          chatprovider.addDoc(newDoc);
          // unawaited(realtime.animateTo(0.0,
          //     duration: Duration(milliseconds: 300), curve: Curves.easeOut));
          // }
          // }
        } else if (change.type == DocumentChangeType.modified) {
          var chatprovider =
              Provider.of<FirestoreDataProviderMESSAGESforTICKETCHAT>(
                  this.context,
                  listen: false);
          DocumentSnapshot updatedDoc = change.doc;
          if (chatprovider.checkIfDocAlreadyExits(
                  newDoc: updatedDoc,
                  timestamp: updatedDoc[Dbkeys.tktMssgTIME]) ==
              true) {
            chatprovider.updateparticulardocinProvider(updatedDoc: updatedDoc);
          }
        } else if (change.type == DocumentChangeType.removed) {
          var chatprovider =
              Provider.of<FirestoreDataProviderMESSAGESforTICKETCHAT>(
                  this.context,
                  listen: false);
          DocumentSnapshot deletedDoc = change.doc;
          if (chatprovider.checkIfDocAlreadyExits(
                  newDoc: deletedDoc,
                  timestamp: deletedDoc[Dbkeys.tktMssgTIME]) ==
              true) {
            chatprovider.deleteparticulardocinProvider(deletedDoc: deletedDoc);
          }
        }
      });
    });

    setStateIfMounted(() {});
  }

  int currentUploadingIndex = 0;

  uploadEach(
    int index,
    String ticketName,
    String ticketfilteredID,
    String departmentTitle,
    List<dynamic> agents,
  ) async {
    File file = new File(widget.sharedFiles![index].path);
    String fileName = file.path.split('/').last;

    print(fileName);
    if (index > widget.sharedFiles!.length) {
      setStateIfMounted(() {
        isgeneratingSomethingLoader = false;
      });
    } else {
      int messagetime = DateTime.now().millisecondsSinceEpoch;
      setStateIfMounted(() {
        currentUploadingIndex = index;
      });
      await getFileData(File(widget.sharedFiles![index].path),
              timestamp: messagetime, totalFiles: widget.sharedFiles!.length)
          .then((imageUrl) async {
        if (imageUrl != null) {
          MessageType type = fileName.contains('.png') ||
                  fileName.contains('.gif') ||
                  fileName.contains('.jpg') ||
                  fileName.contains('.jpeg') ||
                  fileName.contains('giphy')
              ? MessageType.image
              : fileName.contains('.mp4')
                  ? MessageType.video
                  : fileName.contains('.mp3') || fileName.contains('.aac')
                      ? MessageType.audio
                      : MessageType.doc;
          String? thumbnailurl;
          if (type == MessageType.video) {
            thumbnailurl = await getThumbnail(imageUrl);

            setStateIfMounted(() {});
          }

          String finalUrl = fileName.contains('.png') ||
                  fileName.contains('.gif') ||
                  fileName.contains('.jpg') ||
                  fileName.contains('.jpeg') ||
                  fileName.contains('giphy')
              ? imageUrl
              : fileName.contains('.mp4')
                  ? imageUrl +
                      '-BREAK-' +
                      thumbnailurl +
                      '-BREAK-' +
                      videometadata
                  : fileName.contains('.mp3') || fileName.contains('.aac')
                      ? imageUrl + '-BREAK-' + uploadTimestamp.toString()
                      : imageUrl +
                          '-BREAK-' +
                          basename(pickedFile!.path).toString();
          onSendMessage(
              ticketName: ticketName,
              ticketfilteredID: ticketfilteredID,
              context: this.context,
              content: finalUrl,
              type: type,
              timestamp: messagetime,
              agents: agents,
              departmentTitle: departmentTitle);
        }
      }).then((value) {
        if (widget.sharedFiles!.last == widget.sharedFiles![index]) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = false;
          });
        } else {
          uploadEach(currentUploadingIndex + 1, ticketName, ticketfilteredID,
              departmentTitle, agents);
        }
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  setLastSeen(bool iswillpop, isemojikeyboardopen) {
    setStatusBarColor();
    try {
      var currentpeer =
          Provider.of<CurrentChatPeer>(this.context, listen: false);
      currentpeer.setpeer('s');
      FirebaseFirestore.instance
          .collection(DbPaths.collectiontickets)
          .doc(widget.ticketID)
          .update(
        {
          widget.currentUserID: DateTime.now().millisecondsSinceEpoch,
        },
      );
      if (iswillpop == true && isemojikeyboardopen == false) {
        Navigator.of(this.context).pop();
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    subscription!.cancel();
    controller.close();
    if (typingSubscriptionForAgents != null &&
        widget.customerUID != widget.currentUserID) {
      typingSubscriptionForAgents!.cancel();
    }
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    setLastSeen(false, isemojiShowing);

    if (IsInterstitialAdShow == true) {
      _interstitialAd!.dispose();
    }
    if (IsVideoAdShow == true) {
      _rewardedAd!.dispose();
    }
  }

  File? pickedFile;
  File? thumbnailFile;

  getFileData(File image, {int? timestamp, int? totalFiles}) {
    final observer = Provider.of<Observer>(this.context, listen: false);

    setStateIfMounted(() {
      pickedFile = image;
    });

    return observer.isPercentProgressShowWhileUploading
        ? (totalFiles == null
            ? uploadFileWithProgressIndicator(
                false,
                timestamp: timestamp,
              )
            : totalFiles == 1
                ? uploadFileWithProgressIndicator(
                    false,
                    timestamp: timestamp,
                  )
                : uploadFile(false, timestamp: timestamp))
        : uploadFile(false, timestamp: timestamp);
  }

  getFileName(ticketID, timestamp) {
    return "${widget.currentUserID}-$timestamp";
  }

  getThumbnail(String url) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    setStateIfMounted(() {
      isgeneratingSomethingLoader = true;
    });
    String? path = await VideoThumbnail.thumbnailFile(
        video: url,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        quality: 20);
    thumbnailFile = File(path!);
    setStateIfMounted(() {
      isgeneratingSomethingLoader = false;
    });
    return observer.isPercentProgressShowWhileUploading
        ? uploadFileWithProgressIndicator(true)
        : uploadFile(true);
  }

  String? videometadata;
  int? uploadTimestamp;
  int? thumnailtimestamp;
  Future uploadFile(bool isthumbnail, {int? timestamp}) async {
    uploadTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    String fileName = getFileName(
        widget.ticketID,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_TICKET_MEDIA/${widget.ticketID}/")
        .child(fileName);
    TaskSnapshot uploading = await reference
        .putFile(isthumbnail == true ? thumbnailFile! : pickedFile!);
    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }
    if (isthumbnail == true) {
      MediaInfo _mediaInfo = MediaInfo();
      await _mediaInfo.getMediaInfo(thumbnailFile!.path).then((mediaInfo) {
        setStateIfMounted(() {
          videometadata = jsonEncode({
            "width": mediaInfo['width'],
            "height": mediaInfo['height'],
            "orientation": null,
            "duration": mediaInfo['durationMs'],
            "filesize": null,
            "author": null,
            "date": null,
            "framerate": null,
            "location": null,
            "path": null,
            "title": '',
            "mimetype": mediaInfo['mimeType'],
          }).toString();
        });
      }).catchError((onError) {
        Utils.toast('Sending failed !');
        print('ERROR SENDING MEDIA: $onError');
      });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionagents)
          .doc(widget.currentUserID)
          .set({
        Dbkeys.mssgSent: FieldValue.increment(1),
      }, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection(DbPaths.userapp)
          .doc(DbPaths.docdashboarddata)
          .set({
        Dbkeys.mediamessagessent: FieldValue.increment(1),
      }, SetOptions(merge: true));
    }
    return uploading.ref.getDownloadURL();
  }

  Future uploadSelectedLocalFileWithProgressIndicator(
      File selectedFile, bool isVideo, bool isthumbnail, int timeEpoch,
      {String? filenameoptional}) async {
    String ext = p.extension(selectedFile.path);
    String fileName = filenameoptional != null
        ? filenameoptional
        : isthumbnail == true
            ? 'Thumbnail-$timeEpoch$ext'
            : isVideo
                ? 'Video-$timeEpoch$ext'
                : 'IMG-$timeEpoch$ext';
    Reference reference = FirebaseStorage.instance
        .ref("+00_TICKET_MEDIA/${widget.ticketID}/")
        .child(fileName);

    UploadTask uploading = reference.putFile(selectedFile);

    showDialog<void>(
        context: this.context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  // side: BorderSide(width: 5, color: Colors.green)),
                  key: _keyLoader,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: StreamBuilder(
                          stream: uploading.snapshotEvents,
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.hasData) {
                              final TaskSnapshot snap = uploading.snapshot;

                              return openUploadDialog(
                                context: context,
                                percent: bytesTransferred(snap) / 100,
                                title: isthumbnail == true
                                    ? getTranslatedForCurrentUser(
                                        context, 'xxgeneratingthumbnailxx')
                                    : getTranslatedForCurrentUser(
                                        context, 'xxsendingxx'),
                                subtitle:
                                    "${((((snap.bytesTransferred / 1024) / 1000) * 100).roundToDouble()) / 100}/${((((snap.totalBytes / 1024) / 1000) * 100).roundToDouble()) / 100} MB",
                              );
                            } else {
                              return openUploadDialog(
                                context: context,
                                percent: 0.0,
                                title: isthumbnail == true
                                    ? getTranslatedForCurrentUser(
                                        context, 'xxgeneratingthumbnailxx')
                                    : getTranslatedForCurrentUser(
                                        context, 'xxsendingxx'),
                                subtitle: '',
                              );
                            }
                          }),
                    ),
                  ]));
        });

    TaskSnapshot downloadTask = await uploading;
    String downloadedurl = await downloadTask.ref.getDownloadURL();

    if (isthumbnail == true) {
      MediaInfo _mediaInfo = MediaInfo();

      await _mediaInfo.getMediaInfo(selectedFile.path).then((mediaInfo) {
        setStateIfMounted(() {
          videometadata = jsonEncode({
            "width": mediaInfo['width'],
            "height": mediaInfo['height'],
            "orientation": null,
            "duration": mediaInfo['durationMs'],
            "filesize": null,
            "author": null,
            "date": null,
            "framerate": null,
            "location": null,
            "path": null,
            "title": '',
            "mimetype": mediaInfo['mimeType'],
          }).toString();
        });
      }).catchError((onError) {
        Utils.toast('Sending failed !');
        print('ERROR SENDING FILE: $onError');
      });
    } else {
      FirebaseFirestore.instance
          .collection(widget.currentUserID == widget.customerUID
              ? DbPaths.collectioncustomers
              : DbPaths.collectionagents)
          .doc(widget.currentUserID)
          .set({
        Dbkeys.mssgSent: FieldValue.increment(1),
      }, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection(DbPaths.userapp)
          .doc(DbPaths.docdashboarddata)
          .set({
        Dbkeys.mediamessagessent: FieldValue.increment(1),
      }, SetOptions(merge: true));
    }
    Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop(); //
    return downloadedurl;
  }

  Future uploadFileWithProgressIndicator(
    bool isthumbnail, {
    int? timestamp,
  }) async {
    uploadTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    String fileName = getFileName(
        widget.currentUserID,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_TICKET_MEDIA/${widget.ticketID}/")
        .child(fileName);
    UploadTask uploading =
        reference.putFile(isthumbnail == true ? thumbnailFile! : pickedFile!);

    showDialog<void>(
        context: this.context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  // side: BorderSide(width: 5, color: Colors.green)),
                  key: _keyLoader,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: StreamBuilder(
                          stream: uploading.snapshotEvents,
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.hasData) {
                              final TaskSnapshot snap = uploading.snapshot;

                              return openUploadDialog(
                                context: context,
                                percent: bytesTransferred(snap) / 100,
                                title: isthumbnail == true
                                    ? getTranslatedForCurrentUser(
                                        context, 'xxgeneratingthumbnailxx')
                                    : getTranslatedForCurrentUser(
                                        context, 'xxsendingxx'),
                                subtitle:
                                    "${((((snap.bytesTransferred / 1024) / 1000) * 100).roundToDouble()) / 100}/${((((snap.totalBytes / 1024) / 1000) * 100).roundToDouble()) / 100} MB",
                              );
                            } else {
                              return openUploadDialog(
                                context: context,
                                percent: 0.0,
                                title: isthumbnail == true
                                    ? getTranslatedForCurrentUser(
                                        context, 'xxgeneratingthumbnailxx')
                                    : getTranslatedForCurrentUser(
                                        context, 'xxsendingxx'),
                                subtitle: '',
                              );
                            }
                          }),
                    ),
                  ]));
        });

    TaskSnapshot downloadTask = await uploading;
    String downloadedurl = await downloadTask.ref.getDownloadURL();

    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }
    if (isthumbnail == true) {
      MediaInfo _mediaInfo = MediaInfo();

      await _mediaInfo.getMediaInfo(thumbnailFile!.path).then((mediaInfo) {
        setStateIfMounted(() {
          videometadata = jsonEncode({
            "width": mediaInfo['width'],
            "height": mediaInfo['height'],
            "orientation": null,
            "duration": mediaInfo['durationMs'],
            "filesize": null,
            "author": null,
            "date": null,
            "framerate": null,
            "location": null,
            "path": null,
            "title": '',
            "mimetype": mediaInfo['mimeType'],
          }).toString();
        });
      }).catchError((onError) {
        Utils.toast('Sending failed !');
        print('ERROR SENDING FILE: $onError');
      });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionagents)
          .doc(widget.currentUserID)
          .set({
        Dbkeys.mssgSent: FieldValue.increment(1),
      }, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection(DbPaths.userapp)
          .doc(DbPaths.docdashboarddata)
          .set({
        Dbkeys.mediamessagessent: FieldValue.increment(1),
      }, SetOptions(merge: true));
    }
    Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop(); //
    return downloadedurl;
  }

  void onSendMessage({
    required BuildContext context,
    required String content,
    required MessageType type,
    int? timestamp,
    bool? isForward = false,
    bool? isReplyDocSecret = false,
    required String ticketName,
    required String ticketfilteredID,
    required String departmentTitle,
    required List<dynamic> agents,
  }) async {
    setStatusBarColor();
    final observer = Provider.of<Observer>(this.context, listen: false);
    // final List<GroupModel> groupList =
    //     Provider.of<List<GroupModel>>(context, listen: false);
    // var chatprovider = Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(
    //     this.context,
    //     listen: false);

    int finaltimeStamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    if (content.trim() != '') {
      content = content.trim();
      textEditingController.clear();
      FirebaseFirestore.instance
          .collection(DbPaths.collectiontickets)
          .doc(widget.ticketID)
          .collection(DbPaths.collectionticketChats)
          .doc(finaltimeStamp.toString() + '--' + widget.currentUserID)
          .set(
              TicketMessage(
                      tktMssgCONTENT: content,
                      tktMssgISDELETED: false,
                      tktMssgTIME: finaltimeStamp,
                      tktMssgSENDBY: widget.currentUserID,
                      tktMssgTYPE: type.index,
                      tktMssgSENDERNAME:
                          widget.model.currentUser![Dbkeys.nickname],
                      tktMssgISREPLY: isReplyKeyboard,
                      tktMssgISFORWARD: isForward ?? false,
                      tktMssgREPLYTOMSSGDOC: {},
                      tktMssgTicketName: ticketName,
                      tktMssgTicketIDflitered: ticketfilteredID,
                      tktMssgSENDFOR: isSecretChat == true
                          ? [
                              MssgSendFor.agent.index,
                            ]
                          : [
                              MssgSendFor.agent.index,
                              MssgSendFor.customer.index,
                            ],
                      tktMsgCUSTOMERID: widget.customerUID,
                      tktMsgSenderIndex: widget.prefs
                                      .getInt(Dbkeys.userLoginType) ==
                                  Usertype.customer.index ||
                              widget.prefs.getInt(Dbkeys.userLoginType) == null
                          ? Usertype.customer.index
                          : Usertype.agent.index,
                      tktMsgInt2: 0,
                      isShowSenderNameInNotification: false,
                      tktMsgBool2: true,
                      notificationActiveList: agents,
                      tktMssgLISToptional: [],
                      tktMsgList2: [],
                      tktMsgList3: [],
                      tktMsgMap1: {},
                      tktMsgMap2: {},
                      tktMsgDELETEREASON: '',
                      tktMsgDELETEDby: '',
                      tktMsgString4: '',
                      tktMsgString5: '',
                      ttktMsgString3: '')
                  .toMap(),
              SetOptions(merge: true));

      unawaited(realtime.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut));
      // _playPopSound();
      FirebaseFirestore.instance
          .collection(DbPaths.collectiontickets)
          .doc(widget.ticketID)
          .update(
            isSecretChat == true
                ? {Dbkeys.ticketlatestTimestampForAgents: finaltimeStamp}
                : {
                    Dbkeys.ticketlatestTimestampForCustomer: finaltimeStamp,
                    Dbkeys.ticketlatestTimestampForAgents: finaltimeStamp
                  },
          );
      if (isReplyKeyboard == true) {
        setStateIfMounted(() {
          isReplyKeyboard = false;
          replyDoc = null;
        });
      }

      unawaited(realtime.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut));
      if (type == MessageType.doc ||
          type == MessageType.audio ||
          // (type == MessageType.image && !content.contains('giphy')) ||
          type == MessageType.location ||
          type == MessageType.contact &&
              widget.isSharingIntentForwarded == false) {
        if (IsVideoAdShow == true &&
            observer.isadmobshow == true &&
            IsInterstitialAdShow == false) {
          Future.delayed(const Duration(milliseconds: 800), () {
            _showRewardedAd();
          });
        } else if (IsInterstitialAdShow == true &&
            observer.isadmobshow == true) {
          _showInterstitialAd();
        }
      } else if (type == MessageType.video) {
        if (IsVideoAdShow == true && observer.isadmobshow == true) {
          Future.delayed(const Duration(milliseconds: 800), () {
            _showRewardedAd();
          });
        }
      }
    }
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: getInterstitialAdUnitId()!,
        request: AdRequest(
          nonPersonalizedAds: true,
        ),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxAdFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: getRewardBasedVideoAdUnitId()!,
        request: AdRequest(
          nonPersonalizedAds: true,
        ),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts <= maxAdFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(onUserEarnedReward: (a, b) {});
    _rewardedAd = null;
  }

  _onEmojiSelected(Emoji emoji) {
    textEditingController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
    setStateIfMounted(() {});
    if (textEditingController.text.isNotEmpty &&
        textEditingController.text.length == 1) {
      setStateIfMounted(() {});
    }
    if (textEditingController.text.isEmpty) {
      setStateIfMounted(() {});
    }
  }

  _onBackspacePressed() {
    textEditingController
      ..text = textEditingController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
    if (textEditingController.text.isNotEmpty &&
        textEditingController.text.length == 1) {
      setStateIfMounted(() {});
    }
    if (textEditingController.text.isEmpty) {
      setStateIfMounted(() {});
    }
  }

  bool isAmTyping = false;
  final TextEditingController textEditingController =
      new TextEditingController();
  final TextEditingController attentionMessageController =
      new TextEditingController();

  final TextEditingController feedbacktextEditingController =
      new TextEditingController();
  FocusNode keyboardFocusNode = new FocusNode();

  Widget typingIndicator(String string) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 13, 18, 18),
      child: Row(
        children: [
          Container(
            height: 10,
            width: 40,
            child: LoadingIndicator(
              colors: _kDefaultRainbowColors,
              indicatorType: Indicator.values[0],
              strokeWidth: 1,

              // pathBackgroundColor: Colors.black45,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(string)
        ],
      ),
    );
  }

  Widget buildInputForCustomer(
    BuildContext context,
    bool isemojiShowing,
    Function refreshThisInput,
    bool keyboardVisible,
    String ticketName,
    String ticketfilteredID,
    String departmentTitle,
    List<dynamic> agents,
  ) {
    final observer = Provider.of<Observer>(context, listen: true);
    final registry = Provider.of<UserRegistry>(context, listen: true);

    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          streamLoad(
              stream: FirebaseFirestore.instance
                  .collection(DbPaths.collectiontickets)
                  .doc(widget.ticketID)
                  .collection(DbPaths.collectioncLIVEEVENTS)
                  .doc(Dbkeys.liveEventListenForCustomer)
                  .snapshots(),
              placeholder: SizedBox(),
              onfetchdone: (data) {
                if (data != null) {
                  var onlineagentId = data.keys.firstWhere((k) =>
                      data[k] is int &&
                      DateTime.now()
                              .difference(
                                  DateTime.fromMillisecondsSinceEpoch(data[k]))
                              .inSeconds <
                          10);

                  if (onlineagentId == null) {
                    return SizedBox();
                  } else {
                    return DateTime.now()
                                .difference(DateTime.fromMillisecondsSinceEpoch(
                                    data[onlineagentId]))
                                .inSeconds >
                            30
                        ? SizedBox()
                        : typingIndicator(widget
                                    .cuurentUserCanSeeAgentNamePhoto ==
                                true
                            ? "${getTranslatedForCurrentUser(context, 'xxagentxx')} ${registry.getUserData(context, onlineagentId).fullname} ${getTranslatedForCurrentUser(context, 'xxtypingxx')}"
                            : "${getTranslatedForCurrentUser(context, 'xxagentxx')} ${getTranslatedForCurrentUser(context, 'xxtypingxx')}");
                  }
                } else {
                  return SizedBox();
                }
              }),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [],
          ),
          isReplyKeyboard == true
              ? buildReplyMessageForInput(
                  context,
                )
              : SizedBox(),
          Container(
            margin: EdgeInsets.only(bottom: Platform.isIOS == true ? 20 : 0),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 10,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: IconButton(
                            onPressed: () {
                              refreshThisInput();
                            },
                            icon: Icon(Icons.emoji_emotions,
                                color: Mycolors.grey, size: 23),
                          ),
                        ),
                        Flexible(
                          child: TextField(
                            onTap: () {},
                            onChanged: observer.checkIfCurrentUserIsDemo(
                                        widget.currentUserID) ==
                                    true
                                ? (s) {
                                    Utils.toast(getTranslatedForCurrentUser(
                                        context, 'xxxnotalwddemoxxaccountxx'));
                                  }
                                : (s) {
                                    if (s.length < 1) {
                                      setStateIfMounted(() {});
                                    }
                                    controller.add(s);

                                    if (isAmTyping == false) {
                                      setStateIfMounted(() {
                                        isAmTyping = true;
                                      });
                                      if (widget.currentUserID ==
                                          widget.customerUID) {
                                        FirebaseFirestore.instance
                                            .collection(
                                                DbPaths.collectiontickets)
                                            .doc(widget.ticketID)
                                            .collection(
                                                DbPaths.collectioncLIVEEVENTS)
                                            .doc(Dbkeys.liveEventListenForAgent)
                                            .set({
                                          "customer": DateTime.now()
                                              .millisecondsSinceEpoch,
                                          "currentagenttyping": ""
                                        }, SetOptions(merge: true));
                                      } else {
                                        FirebaseFirestore.instance
                                            .collection(
                                                DbPaths.collectiontickets)
                                            .doc(widget.ticketID)
                                            .collection(
                                                DbPaths.collectioncLIVEEVENTS)
                                            .doc(Dbkeys
                                                .liveEventListenForCustomer)
                                            .set({
                                          "agentid--${widget.currentUserID}":
                                              DateTime.now()
                                                  .millisecondsSinceEpoch,
                                          "currentagenttyping":
                                              widget.currentUserID,
                                        }, SetOptions(merge: true));
                                      }

                                      // Utils.toast("typing intiatated");
                                    }
                                  },
                            showCursor: true,
                            focusNode: keyboardFocusNode,
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(
                                fontSize: 16.0, color: Mycolors.black),
                            controller: textEditingController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderRadius: BorderRadius.circular(1),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 1.5),
                              ),
                              hoverColor: Colors.transparent,
                              focusedBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderRadius: BorderRadius.circular(1),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 1.5),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(1),
                                  borderSide:
                                      BorderSide(color: Colors.transparent)),
                              contentPadding: EdgeInsets.fromLTRB(10, 4, 7, 4),
                              hintText: getTranslatedForCurrentUser(
                                  this.context, 'xxmssgxx'),
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          ),
                        ),
                        observer.userAppSettingsDoc!
                                    .isMediaSendingAllowedInTicketChatRoom ==
                                true
                            ? Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                width: textEditingController.text.isNotEmpty
                                    ? 10
                                    : 120,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    textEditingController.text.isNotEmpty
                                        ? SizedBox()
                                        : SizedBox(
                                            width: 30,
                                            child: IconButton(
                                              icon: new Icon(
                                                Icons.attachment_outlined,
                                                color: Mycolors.grey,
                                              ),
                                              padding: EdgeInsets.all(0.0),
                                              onPressed:
                                                  observer.ismediamessagingallowed ==
                                                          false
                                                      ? () {
                                                          Utils.showRationale(
                                                              getTranslatedForCurrentUser(
                                                                  this.context,
                                                                  'xxmediamssgnotallowedxx'));
                                                        }
                                                      : () {
                                                          hidekeyboard(context);
                                                          shareMedia(
                                                              context,
                                                              ticketName,
                                                              ticketfilteredID,
                                                              departmentTitle,
                                                              agents);
                                                        },
                                              color: Colors.white,
                                            ),
                                          ),
                                    textEditingController.text.isNotEmpty
                                        ? SizedBox()
                                        : SizedBox(
                                            width: 30,
                                            child: IconButton(
                                              icon: new Icon(
                                                Icons.camera_alt_rounded,
                                                size: 20,
                                                color: Mycolors.grey,
                                              ),
                                              padding: EdgeInsets.all(0.0),
                                              onPressed:
                                                  observer.ismediamessagingallowed ==
                                                          false
                                                      ? () {
                                                          Utils.showRationale(
                                                              getTranslatedForCurrentUser(
                                                                  this.context,
                                                                  'xxmediamssgnotallowedxx'));
                                                        }
                                                      : () async {
                                                          hidekeyboard(context);

                                                          // Navigator.push(
                                                          //     context,
                                                          //     MaterialPageRoute(
                                                          //         builder:
                                                          //             (context) =>
                                                          //                 MultiImagePicker(
                                                          //                   title:
                                                          //                       getTranslatedForCurrentUser(this.context, 'xxpickimagexx'),
                                                          //                   callback:
                                                          //                       getFileData,
                                                          //                   writeMessage:
                                                          //                       (String? url, int time) async {
                                                          //                     if (url != null) {
                                                          //                       onSendMessage(departmentTitle: departmentTitle, agents: agents, context: this.context, content: url, ticketName: ticketName, ticketfilteredID: ticketfilteredID, type: MessageType.image, timestamp: time);
                                                          //                     }
                                                          //                   },
                                                          //                 )));

                                                          await Navigator.push(
                                                              context,
                                                              new MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          new AllinOneCameraGalleryImageVideoPicker(
                                                                            onTakeFile: (file,
                                                                                isVideo,
                                                                                thumnail) async {
                                                                              setStatusBarColor();
                                                                              if (observer.checkIfCurrentUserIsDemo(widget.currentUserID) == true) {
                                                                                Utils.toast(getTranslatedForCurrentUser(context, 'xxxnotalwddemoxxaccountxx'));
                                                                              } else {
                                                                                int timeStamp = DateTime.now().millisecondsSinceEpoch;
                                                                                if (isVideo == true) {
                                                                                  String videoFileext = p.extension(file.path);
                                                                                  String videofileName = 'Video-$timeStamp$videoFileext';
                                                                                  String? videoUrl = await uploadSelectedLocalFileWithProgressIndicator(file, true, false, timeStamp, filenameoptional: videofileName);
                                                                                  if (videoUrl != null) {
                                                                                    String? thumnailUrl = await uploadSelectedLocalFileWithProgressIndicator(thumnail!, false, true, timeStamp);
                                                                                    if (thumnailUrl != null) {
                                                                                      onSendMessage(departmentTitle: departmentTitle, agents: agents, context: this.context, content: videoUrl + '-BREAK-' + thumnailUrl + '-BREAK-' + videometadata! + '-BREAK-' + "$videofileName", ticketName: ticketName, ticketfilteredID: ticketfilteredID, type: MessageType.video, timestamp: timeStamp);

                                                                                      await file.delete();
                                                                                      await thumnail.delete();
                                                                                    }
                                                                                  }
                                                                                } else {
                                                                                  String imageFileext = p.extension(file.path);
                                                                                  String imagefileName = 'IMG-$timeStamp$imageFileext';
                                                                                  String? url = await uploadSelectedLocalFileWithProgressIndicator(file, false, false, timeStamp, filenameoptional: imagefileName);
                                                                                  if (url != null) {
                                                                                    onSendMessage(departmentTitle: departmentTitle, agents: agents, context: this.context, content: url, ticketName: ticketName, ticketfilteredID: ticketfilteredID, type: MessageType.image, timestamp: timeStamp);
                                                                                    await file.delete();
                                                                                  }
                                                                                }
                                                                              }
                                                                            },
                                                                          )));
                                                        },
                                              color: Colors.white,
                                            ),
                                          ),
                                    textEditingController.text.length != 0
                                        ? SizedBox(
                                            width: 0,
                                          )
                                        : Container(
                                            margin: EdgeInsets.only(bottom: 5),
                                            height: 35,
                                            alignment: Alignment.topLeft,
                                            width: 40,
                                            child: IconButton(
                                                color: Colors.white,
                                                padding: EdgeInsets.all(0.0),
                                                icon: Icon(
                                                  Icons.gif_rounded,
                                                  size: 40,
                                                  color: Mycolors.grey,
                                                ),
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
                                                    : observer.ismediamessagingallowed ==
                                                            false
                                                        ? () {
                                                            Utils.showRationale(
                                                                getTranslatedForCurrentUser(
                                                                    this.context,
                                                                    'xxmediamssgnotallowedxx'));
                                                          }
                                                        : () async {
                                                            GiphyGif? gif =
                                                                await GiphyGet
                                                                    .getGif(
                                                              tabColor: Mycolors
                                                                  .primary,
                                                              context: context,
                                                              apiKey:
                                                                  GiphyAPIKey, //YOUR API KEY HERE
                                                              lang:
                                                                  GiphyLanguage
                                                                      .english,
                                                            );
                                                            if (gif != null &&
                                                                mounted) {
                                                              onSendMessage(
                                                                departmentTitle:
                                                                    departmentTitle,
                                                                agents: agents,
                                                                ticketName:
                                                                    ticketName,
                                                                ticketfilteredID:
                                                                    ticketfilteredID,
                                                                context:
                                                                    context,
                                                                content: gif
                                                                    .images!
                                                                    .original!
                                                                    .url,
                                                                type:
                                                                    MessageType
                                                                        .image,
                                                              );
                                                              hidekeyboard(
                                                                  context);
                                                              setStateIfMounted(
                                                                  () {});
                                                            }
                                                          }),
                                          ),
                                  ],
                                ))
                            : SizedBox()
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 47,
                  width: 47,
                  // alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 6, right: 10),
                  decoration: BoxDecoration(
                      color: Mycolors.getColor(
                          widget.prefs, Colortype.secondary.index),
                      // border: Border.all(
                      //   color: Colors.red[500],
                      // ),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: IconButton(
                      icon: new Icon(
                        Icons.send,
                        color: Colors.white.withOpacity(0.99),
                      ),
                      onPressed: observer.checkIfCurrentUserIsDemo(
                                  widget.currentUserID) ==
                              true
                          ? () {
                              Utils.toast(getTranslatedForCurrentUser(
                                  context, 'xxxnotalwddemoxxaccountxx'));
                            }
                          : observer.ismediamessagingallowed == true
                              ? observer.istextmessagingallowed == false
                                  ? () {
                                      Utils.showRationale(
                                          getTranslatedForCurrentUser(
                                              this.context,
                                              'xxtextmssgnotallowedxx'));
                                    }
                                  : () => onSendMessage(
                                        departmentTitle: departmentTitle,
                                        agents: agents,
                                        ticketName: ticketName,
                                        ticketfilteredID: ticketfilteredID,
                                        context: context,
                                        content: textEditingController
                                            .value.text
                                            .trim(),
                                        type: MessageType.text,
                                      )
                              : () {
                                  Utils.showRationale(
                                      getTranslatedForCurrentUser(this.context,
                                          'xxmediamssgnotallowedxx'));
                                },
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            width: double.infinity,
            height: 60.0,
            decoration: new BoxDecoration(
              // border: new Border(top: new BorderSide(color: Colors.grey, width: 0.5)),
              color: Colors.transparent,
            ),
          ),
          isemojiShowing == true && keyboardVisible == false
              ? Offstage(
                  offstage: !isemojiShowing,
                  child: SizedBox(
                    height: 300,
                    child: EmojiPicker(
                        onEmojiSelected:
                            (emojipic.Category category, Emoji emoji) {
                          _onEmojiSelected(emoji);
                        },
                        onBackspacePressed: _onBackspacePressed,
                        config: Config(
                            columns: 7,
                            emojiSizeMax: 32.0,
                            verticalSpacing: 0,
                            horizontalSpacing: 0,
                            initCategory: emojipic.Category.RECENT,
                            bgColor: Color(0xFFF2F2F2),
                            indicatorColor: Mycolors.primary,
                            iconColor: Colors.grey,
                            iconColorSelected: Mycolors.primary,
                            progressIndicatorColor: Colors.blue,
                            backspaceColor: Mycolors.primary,
                            showRecentsTab: true,
                            recentsLimit: 28,
                            categoryIcons: CategoryIcons(),
                            buttonMode: ButtonMode.MATERIAL)),
                  ),
                )
              : SizedBox(),
        ]);
  }

  Widget buildInputForAgent(
    BuildContext context,
    bool isemojiShowing,
    Function refreshThisInput,
    bool keyboardVisible,
    String ticketName,
    String ticketfilteredID,
    String departmentTitle,
    List<dynamic> agents,
  ) {
    final observer = Provider.of<Observer>(context, listen: true);
    final registry = Provider.of<UserRegistry>(context, listen: true);

    List<Widget> isTypingWidgetlist = [];
    typingList.forEach((doc) {
      if (doc.data()!.containsKey("customer")) {
        if (doc.data()!["customer"] is int &&
            DateTime.now()
                    .difference(DateTime.fromMillisecondsSinceEpoch(
                        doc.data()!["customer"]))
                    .inSeconds <
                10) {
          isTypingWidgetlist.add(typingIndicator(
              "${getTranslatedForCurrentUser(context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(context, 'xxtypingxx')}"));
        }
      } else if (doc.data()!.containsKey("currentagenttyping")) {
        List<String> onlineagentIdList = doc
            .data()!
            .keys
            .where((k) =>
                doc.data()![k] is int &&
                DateTime.now()
                        .difference(
                            DateTime.fromMillisecondsSinceEpoch(doc.data()![k]))
                        .inSeconds <
                    10)
            .toList();

        onlineagentIdList.forEach((agent) {
          if (agent.toString() == "agentid--${widget.currentUserID}") {
          } else {
            isTypingWidgetlist.add(typingIndicator(widget
                        .cuurentUserCanSeeAgentNamePhoto ==
                    true
                ? "${getTranslatedForCurrentUser(context, 'xxagentxx')} ${registry.getUserData(context, agent.split('--')[1]).fullname} ${getTranslatedForCurrentUser(context, 'xxtypingxx')}"
                : "${getTranslatedForCurrentUser(context, 'xxagentidxx')}  ${agent.split('--')[1]} ${getTranslatedForCurrentUser(context, 'xxtypingxx')}"));
          }
        });
      }
    });
    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: isTypingWidgetlist +
            [
              isReplyKeyboard == true
                  ? buildReplyMessageForInput(
                      context,
                    )
                  : SizedBox(),
              Container(
                // constraints: BoxConstraints(
                //   maxHeight: 500,
                //   // minHeight: 200,
                // ),
                margin:
                    EdgeInsets.only(bottom: Platform.isIOS == true ? 20 : 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 7, bottom: 7),
                      width: MediaQuery.of(context).size.width - 70,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: double.infinity,
                            ),
                            // height: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: IconButton(
                                    onPressed: () {
                                      refreshThisInput();
                                    },
                                    icon: Icon(Icons.emoji_emotions,
                                        color: Mycolors.grey, size: 23),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width -
                                      70 -
                                      50,
                                  child: TextField(
                                    onTap: () {
                                      // if (isemojiShowing == true) {
                                      // } else {
                                      //   keyboardFocusNode.requestFocus();
                                      //   setStateIfMounted(() {});
                                      // }
                                    },
                                    onChanged: observer
                                                .checkIfCurrentUserIsDemo(
                                                    widget.currentUserID) ==
                                            true
                                        ? (s) {
                                            Utils.toast(
                                                getTranslatedForCurrentUser(
                                                    context,
                                                    'xxxnotalwddemoxxaccountxx'));
                                          }
                                        : isSecretChat == true
                                            ? null
                                            : (s) {
                                                if (s.length < 1) {
                                                  setStateIfMounted(() {});
                                                }
                                                controller.add(s);

                                                if (isAmTyping == false) {
                                                  setStateIfMounted(() {
                                                    isAmTyping = true;
                                                  });
                                                  if (widget.currentUserID ==
                                                      widget.customerUID) {
                                                    FirebaseFirestore.instance
                                                        .collection(DbPaths
                                                            .collectiontickets)
                                                        .doc(widget.ticketID)
                                                        .collection(DbPaths
                                                            .collectioncLIVEEVENTS)
                                                        .doc(Dbkeys
                                                            .liveEventListenForAgent)
                                                        .set({
                                                      "customer": DateTime.now()
                                                          .millisecondsSinceEpoch,
                                                      "currentagenttyping": ""
                                                    }, SetOptions(merge: true));
                                                  } else {
                                                    FirebaseFirestore.instance
                                                        .collection(DbPaths
                                                            .collectiontickets)
                                                        .doc(widget.ticketID)
                                                        .collection(DbPaths
                                                            .collectioncLIVEEVENTS)
                                                        .doc(Dbkeys
                                                            .liveEventListenForCustomer)
                                                        .set({
                                                      "agentid--${widget.currentUserID}":
                                                          DateTime.now()
                                                              .millisecondsSinceEpoch,
                                                      "currentagenttyping":
                                                          widget.currentUserID,
                                                    }, SetOptions(merge: true));
                                                  }

                                                  // Utils.toast("typing intiatated");
                                                }
                                              },
                                    showCursor: true,
                                    focusNode: keyboardFocusNode,
                                    maxLines: null,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: isSecretChat == true
                                            ? Colors.white
                                            : Mycolors.black,
                                        height: 1.2),
                                    controller: textEditingController,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        // width: 0.0 produces a thin "hairline" border
                                        borderRadius: BorderRadius.circular(1),
                                        borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 1.5),
                                      ),
                                      hoverColor: Colors.transparent,
                                      focusedBorder: OutlineInputBorder(
                                        // width: 0.0 produces a thin "hairline" border
                                        borderRadius: BorderRadius.circular(1),
                                        borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 1.5),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(1),
                                          borderSide: BorderSide(
                                              color: Colors.transparent)),
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 4, 7, 4),
                                      hintText: getTranslatedForCurrentUser(
                                          this.context, 'xxmssgxx'),
                                      hintStyle: TextStyle(
                                          color: Mycolors.grey, fontSize: 15),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          textEditingController.text.length == 0
                              ? Divider(
                                  height: 8,
                                )
                              : SizedBox(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              textEditingController.text.length != 0
                                  ? isSecretChat == false
                                      ? SizedBox()
                                      : Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2,
                                          padding: EdgeInsets.all(0),
                                          child: MtCustomfontRegular(
                                            fontsize: 11,
                                            color: Mycolors.cyan,
                                            text: '💬  ' +
                                                getTranslatedForCurrentUser(
                                                        context,
                                                        'xxvisbletoxxonlyxx')
                                                    .replaceAll(
                                                        '(####)',
                                                        getTranslatedForCurrentUser(
                                                            context,
                                                            'xxagentsxx')),
                                          ),
                                        )
                                  : Container(
                                      height: 30,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 15,
                                            width: 40,
                                            child: IconButton(
                                              icon: new Icon(
                                                Icons.attachment_outlined,
                                                color: Mycolors.grey,
                                              ),
                                              padding: EdgeInsets.all(0.0),
                                              onPressed:
                                                  observer.ismediamessagingallowed ==
                                                          false
                                                      ? () {
                                                          Utils.showRationale(
                                                              getTranslatedForCurrentUser(
                                                                  this.context,
                                                                  'xxmediamssgnotallowedxx'));
                                                        }
                                                      : () {
                                                          hidekeyboard(context);
                                                          shareMedia(
                                                              context,
                                                              ticketName,
                                                              ticketfilteredID,
                                                              departmentTitle,
                                                              agents);
                                                        },
                                              color: Colors.white,
                                            ),
                                          ),
                                          Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  7, 0, 7, 0),
                                              width: textEditingController
                                                      .text.isNotEmpty
                                                  ? 10
                                                  : 130,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10),
                                                    height: 35,
                                                    width: 30,
                                                    child: IconButton(
                                                      icon: new Icon(
                                                        Icons
                                                            .camera_alt_rounded,
                                                        size: 20,
                                                        color: Mycolors.grey,
                                                      ),
                                                      padding:
                                                          EdgeInsets.all(0.0),
                                                      onPressed:
                                                          observer.ismediamessagingallowed ==
                                                                  false
                                                              ? () {
                                                                  Utils.showRationale(
                                                                      getTranslatedForCurrentUser(
                                                                          this.context,
                                                                          'xxmediamssgnotallowedxx'));
                                                                }
                                                              : () async {
                                                                  hidekeyboard(
                                                                      context);

                                                                  // Navigator.push(
                                                                  //     context,
                                                                  //     MaterialPageRoute(
                                                                  //         builder: (context) => MultiImagePicker(
                                                                  //               title: getTranslatedForCurrentUser(this.context, 'xxpickimagexx'),
                                                                  //               callback: getFileData,
                                                                  //               writeMessage: (String? url, int time) async {
                                                                  //                 if (url != null) {
                                                                  //                   onSendMessage(agents: agents, departmentTitle: departmentTitle, context: this.context, content: url, ticketName: ticketName, ticketfilteredID: ticketfilteredID, type: MessageType.image, timestamp: time);
                                                                  //                 }
                                                                  //               },
                                                                  //             )));

                                                                  await Navigator.push(
                                                                      context,
                                                                      new MaterialPageRoute(
                                                                          builder: (context) => new AllinOneCameraGalleryImageVideoPicker(
                                                                                onTakeFile: (file, isVideo, thumnail) async {
                                                                                  setStatusBarColor();
                                                                                  if (observer.checkIfCurrentUserIsDemo(widget.currentUserID) == true) {
                                                                                    Utils.toast(getTranslatedForCurrentUser(context, 'xxxnotalwddemoxxaccountxx'));
                                                                                  } else {
                                                                                    int timeStamp = DateTime.now().millisecondsSinceEpoch;
                                                                                    if (isVideo == true) {
                                                                                      String videoFileext = p.extension(file.path);
                                                                                      String videofileName = 'Video-$timeStamp$videoFileext';
                                                                                      String? videoUrl = await uploadSelectedLocalFileWithProgressIndicator(file, true, false, timeStamp, filenameoptional: videofileName);
                                                                                      if (videoUrl != null) {
                                                                                        String? thumnailUrl = await uploadSelectedLocalFileWithProgressIndicator(thumnail!, false, true, timeStamp);
                                                                                        if (thumnailUrl != null) {
                                                                                          onSendMessage(departmentTitle: departmentTitle, agents: agents, context: this.context, content: videoUrl + '-BREAK-' + thumnailUrl + '-BREAK-' + videometadata! + '-BREAK-' + "$videofileName", ticketName: ticketName, ticketfilteredID: ticketfilteredID, type: MessageType.video, timestamp: timeStamp);

                                                                                          await file.delete();
                                                                                          await thumnail.delete();
                                                                                        }
                                                                                      }
                                                                                    } else {
                                                                                      String imageFileext = p.extension(file.path);
                                                                                      String imagefileName = 'IMG-$timeStamp$imageFileext';
                                                                                      String? url = await uploadSelectedLocalFileWithProgressIndicator(file, false, false, timeStamp, filenameoptional: imagefileName);
                                                                                      if (url != null) {
                                                                                        onSendMessage(departmentTitle: departmentTitle, agents: agents, context: this.context, content: url, ticketName: ticketName, ticketfilteredID: ticketfilteredID, type: MessageType.image, timestamp: timeStamp);
                                                                                        await file.delete();
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                },
                                                                              )));
                                                                },
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        bottom: 5),
                                                    height: 35,
                                                    alignment:
                                                        Alignment.topLeft,
                                                    width: 40,
                                                    child: IconButton(
                                                        color: Colors.white,
                                                        padding:
                                                            EdgeInsets.all(0.0),
                                                        icon: Icon(
                                                          Icons.gif_rounded,
                                                          size: 40,
                                                          color: Mycolors.grey,
                                                        ),
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
                                                            : observer.ismediamessagingallowed ==
                                                                    false
                                                                ? () {
                                                                    Utils.showRationale(getTranslatedForCurrentUser(
                                                                        this.context,
                                                                        'xxmediamssgnotallowedxx'));
                                                                  }
                                                                : () async {
                                                                    GiphyGif?
                                                                        gif =
                                                                        await GiphyGet
                                                                            .getGif(
                                                                      tabColor:
                                                                          Mycolors
                                                                              .primary,
                                                                      context:
                                                                          context,
                                                                      apiKey:
                                                                          GiphyAPIKey, //YOUR API KEY HERE
                                                                      lang: GiphyLanguage
                                                                          .english,
                                                                    );
                                                                    if (gif !=
                                                                            null &&
                                                                        mounted) {
                                                                      onSendMessage(
                                                                        agents:
                                                                            agents,
                                                                        departmentTitle:
                                                                            departmentTitle,
                                                                        ticketName:
                                                                            ticketName,
                                                                        ticketfilteredID:
                                                                            ticketfilteredID,
                                                                        context:
                                                                            context,
                                                                        content: gif
                                                                            .images!
                                                                            .original!
                                                                            .url,
                                                                        type: MessageType
                                                                            .image,
                                                                      );
                                                                      hidekeyboard(
                                                                          context);
                                                                      setStateIfMounted(
                                                                          () {});
                                                                    }
                                                                  }),
                                                  ),
                                                  Container(
                                                      margin: EdgeInsets.only(
                                                          top: 9),
                                                      alignment:
                                                          Alignment.topLeft,
                                                      width: 30,
                                                      child: IconButton(
                                                        color: Colors.white,
                                                        padding:
                                                            EdgeInsets.all(0.0),
                                                        icon: Icon(
                                                          Icons
                                                              .quickreply_outlined,
                                                          size: 19,
                                                          color: Mycolors.grey,
                                                        ),
                                                        onPressed: () {
                                                          hidekeyboard(context);
                                                          pageNavigator(
                                                              context,
                                                              QuickReplies(
                                                                  prefs: widget
                                                                      .prefs,
                                                                  currentuserid:
                                                                      widget
                                                                          .currentUserID,
                                                                  onreplyselect:
                                                                      (templateString) {
                                                                    String
                                                                        currenttext =
                                                                        textEditingController
                                                                            .text
                                                                            .trim();
                                                                    textEditingController
                                                                            .text =
                                                                        currenttext +
                                                                            " " +
                                                                            templateString;
                                                                    setStateIfMounted(
                                                                        () {});
                                                                    keyboardFocusNode
                                                                        .requestFocus();
                                                                  }));
                                                        },
                                                      ))
                                                ],
                                              ))
                                        ],
                                      ),
                                    ),
                              agents.length == 0
                                  ? SizedBox()
                                  : agents.length == 1
                                      ? SizedBox()
                                      : Container(
                                          width: 100,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              MtCustomfontBoldSemi(
                                                text:
                                                    getTranslatedForCurrentUser(
                                                        context,
                                                        'xxsecretchatxx'),
                                                color: Mycolors.greylight,
                                                textalign: TextAlign.right,
                                                fontsize: 9,
                                              ),
                                              SizedBox(
                                                width: 6,
                                              ),
                                              FlutterSwitch(
                                                activeToggleColor: Colors.white,
                                                activeColor: Mycolors.cyan,
                                                inactiveColor:
                                                    Mycolors.greylight,
                                                toggleSize: 10,
                                                height: 17,
                                                width: 40,
                                                value: isSecretChat,
                                                onToggle: (value) {
                                                  setStateIfMounted(() {
                                                    isSecretChat = value;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 47,
                      width: 47,
                      // alignment: Alignment.center,
                      margin: EdgeInsets.only(left: 6, right: 10),
                      decoration: BoxDecoration(
                          color: isSecretChat == true
                              ? Mycolors.grey
                              : Mycolors.getColor(
                                  widget.prefs, Colortype.secondary.index),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: IconButton(
                          icon: new Icon(
                            Icons.send,
                            color: Colors.white.withOpacity(0.99),
                          ),
                          onPressed: observer.checkIfCurrentUserIsDemo(
                                      widget.currentUserID) ==
                                  true
                              ? () {
                                  Utils.toast(getTranslatedForCurrentUser(
                                      context, 'xxxnotalwddemoxxaccountxx'));
                                }
                              : observer.ismediamessagingallowed == true
                                  ? observer.istextmessagingallowed == false
                                      ? () {
                                          Utils.showRationale(
                                              getTranslatedForCurrentUser(
                                                  this.context,
                                                  'xxtextmssgnotallowedxx'));
                                        }
                                      : () => onSendMessage(
                                            departmentTitle: departmentTitle,
                                            agents: agents,
                                            ticketName: ticketName,
                                            ticketfilteredID: ticketfilteredID,
                                            context: context,
                                            content: textEditingController
                                                .value.text
                                                .trim(),
                                            type: MessageType.text,
                                          )
                                  : () {
                                      Utils.showRationale(
                                          getTranslatedForCurrentUser(
                                              this.context,
                                              'xxmediamssgnotallowedxx'));
                                    },
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                width: double.infinity,

                decoration: new BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Mycolors.black.withOpacity(0.2),
                        blurRadius: 3.0,
                        offset: Offset(0.0, 0.35))
                  ],
                  color:
                      isSecretChat == true ? Color(0xff20202a) : Colors.white,
                ),
              ),
              isemojiShowing == true && keyboardVisible == false
                  ? Offstage(
                      offstage: !isemojiShowing,
                      child: SizedBox(
                        height: 300,
                        child: EmojiPicker(
                            onEmojiSelected:
                                (emojipic.Category category, Emoji emoji) {
                              _onEmojiSelected(emoji);
                            },
                            onBackspacePressed: _onBackspacePressed,
                            config: Config(
                                columns: 7,
                                emojiSizeMax: 32.0,
                                verticalSpacing: 0,
                                horizontalSpacing: 0,
                                initCategory: emojipic.Category.RECENT,
                                bgColor: Color(0xFFF2F2F2),
                                indicatorColor: Mycolors.primary,
                                iconColor: Colors.grey,
                                iconColorSelected: Mycolors.primary,
                                progressIndicatorColor: Colors.blue,
                                backspaceColor: Mycolors.primary,
                                showRecentsTab: true,
                                recentsLimit: 28,
                                categoryIcons: CategoryIcons(),
                                buttonMode: ButtonMode.MATERIAL)),
                      ),
                    )
                  : SizedBox(),
            ]);
  }

  Widget buildReplyMessageForInput(
    BuildContext context,
  ) {
    return Flexible(
      child: Container(
          height: 80,
          margin: EdgeInsets.only(left: 15, right: 70),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Stack(
            children: [
              Container(
                  margin: EdgeInsetsDirectional.all(4),
                  decoration: BoxDecoration(
                      color: Mycolors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Row(children: [
                    Container(
                      decoration: BoxDecoration(
                        color: replyDoc![Dbkeys.tktMssgSENDBY] ==
                                widget.currentUserID
                            ? Mycolors.primary
                            : Colors.purple,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      height: 75,
                      width: 3.3,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: Container(
                      padding: EdgeInsetsDirectional.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 30),
                            child: Text(
                              replyDoc![Dbkeys.tktMssgSENDBY] ==
                                      widget.currentUserID
                                  ? getTranslatedForCurrentUser(
                                      this.context, 'xxyouxx')
                                  : messageReplyOwnerName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: replyDoc![Dbkeys.tktMssgSENDBY] ==
                                          widget.currentUserID
                                      ? Mycolors.primary
                                      : Colors.purple),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          replyDoc![Dbkeys.messageType] ==
                                  MessageType.text.index
                              ? Text(
                                  replyDoc![Dbkeys.content],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                )
                              : replyDoc![Dbkeys.messageType] ==
                                      MessageType.doc.index
                                  ? Container(
                                      width: MediaQuery.of(context).size.width -
                                          125,
                                      padding: const EdgeInsets.only(right: 55),
                                      child: Text(
                                        replyDoc![Dbkeys.content]
                                            .split('-BREAK-')[1],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    )
                                  : Text(
                                      getTranslatedForCurrentUser(
                                          this.context,
                                          replyDoc![Dbkeys.messageType] ==
                                                  MessageType.image.index
                                              ? 'xxnimxx'
                                              : replyDoc![Dbkeys.messageType] ==
                                                      MessageType.video.index
                                                  ? 'xxnvmxx'
                                                  : replyDoc![Dbkeys
                                                              .messageType] ==
                                                          MessageType
                                                              .audio.index
                                                      ? 'xxnamxx'
                                                      : replyDoc![Dbkeys
                                                                  .messageType] ==
                                                              MessageType
                                                                  .contact.index
                                                          ? 'xxncmxx'
                                                          : replyDoc![Dbkeys
                                                                      .messageType] ==
                                                                  MessageType
                                                                      .location
                                                                      .index
                                                              ? 'xxnlmxx'
                                                              : replyDoc![Dbkeys
                                                                          .messageType] ==
                                                                      MessageType
                                                                          .doc
                                                                          .index
                                                                  ? 'xxndmxx'
                                                                  : ''),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                        ],
                      ),
                    ))
                  ])),
              replyDoc![Dbkeys.messageType] == MessageType.text.index
                  ? SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : replyDoc![Dbkeys.messageType] == MessageType.image.index
                      ? Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 84.0,
                            height: 84.0,
                            padding: EdgeInsetsDirectional.all(6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  bottomRight: Radius.circular(5),
                                  topLeft: Radius.circular(0),
                                  bottomLeft: Radius.circular(0)),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Mycolors.secondary),
                                  ),
                                  width: replyDoc![Dbkeys.content]
                                          .contains('giphy')
                                      ? 60
                                      : 60.0,
                                  height: replyDoc![Dbkeys.content]
                                          .contains('giphy')
                                      ? 60
                                      : 60.0,
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[200],
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, str, error) => Material(
                                  child: Image.asset(
                                    'assets/images/img_not_available.jpeg',
                                    width: 60.0,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                imageUrl: replyDoc![Dbkeys.messageType] ==
                                        MessageType.video.index
                                    ? ''
                                    : replyDoc![Dbkeys.content],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : replyDoc![Dbkeys.messageType] == MessageType.video.index
                          ? Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                  width: 84.0,
                                  height: 84.0,
                                  padding: EdgeInsetsDirectional.all(6),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                        color: Colors.blueGrey[200],
                                        height: 84,
                                        width: 84,
                                        child: Stack(
                                          children: [
                                            CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Container(
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Mycolors.secondary),
                                                ),
                                                width: 84,
                                                height: 84,
                                                padding: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueGrey[200],
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(0.0),
                                                  ),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, str, error) =>
                                                      Material(
                                                child: Image.asset(
                                                  'assets/images/img_not_available.jpeg',
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(0.0),
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                              ),
                                              imageUrl:
                                                  replyDoc![Dbkeys.content]
                                                      .split('-BREAK-')[1],
                                              width: 84,
                                              height: 84,
                                              fit: BoxFit.cover,
                                            ),
                                            Container(
                                              color:
                                                  Colors.black.withOpacity(0.4),
                                              height: 84,
                                              width: 84,
                                            ),
                                            Center(
                                              child: Icon(
                                                  Icons
                                                      .play_circle_fill_outlined,
                                                  color: Colors.white70,
                                                  size: 25),
                                            ),
                                          ],
                                        ),
                                      ))))
                          : Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                  width: 84.0,
                                  height: 84.0,
                                  padding: EdgeInsetsDirectional.all(6),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                          color: replyDoc![
                                                      Dbkeys.messageType] ==
                                                  MessageType.doc.index
                                              ? Colors.yellow[00]
                                              : replyDoc![Dbkeys.messageType] ==
                                                      MessageType.audio.index
                                                  ? Colors.green[400]
                                                  : replyDoc![Dbkeys
                                                              .messageType] ==
                                                          MessageType
                                                              .location.index
                                                      ? Colors.red[700]
                                                      : replyDoc![Dbkeys
                                                                  .messageType] ==
                                                              MessageType
                                                                  .contact.index
                                                          ? Colors.blue[400]
                                                          : Colors.cyan[700],
                                          height: 84,
                                          width: 84,
                                          child: Icon(
                                            replyDoc![Dbkeys.messageType] ==
                                                    MessageType.doc.index
                                                ? Icons.insert_drive_file
                                                : replyDoc![Dbkeys
                                                            .messageType] ==
                                                        MessageType.audio.index
                                                    ? Icons.mic_rounded
                                                    : replyDoc![Dbkeys
                                                                .messageType] ==
                                                            MessageType
                                                                .location.index
                                                        ? Icons.location_on
                                                        : replyDoc![Dbkeys
                                                                    .messageType] ==
                                                                MessageType
                                                                    .contact
                                                                    .index
                                                            ? Icons
                                                                .contact_page_sharp
                                                            : Icons
                                                                .insert_drive_file,
                                            color: Colors.white,
                                            size: 35,
                                          ))))),
              Positioned(
                right: 7,
                top: 7,
                child: InkWell(
                  onTap: () {
                    setStateIfMounted(() {
                      HapticFeedback.heavyImpact();
                      isReplyKeyboard = false;
                      hidekeyboard(context);
                    });
                  },
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: new BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: new Icon(
                      Icons.close,
                      color: Colors.blueGrey,
                      size: 13,
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  buildEachMessage(TicketMessage mssg, TicketModel tkt) {
    if (mssg.tktMssgTYPE == MessageType.rROBOTdepartmentChanged.index) {
      return buildDepartmentChanged(mssg, tkt);
    } else if (mssg.tktMssgTYPE ==
        MessageType.rROBOTassignAgentForACustomerCall.index) {
      return buildAssignCallMessage(mssg, tkt);
    } else if (mssg.tktMssgTYPE ==
        MessageType.rROBOTremoveAssignAgentForACustomerCall.index) {
      return buildRemoveCallAssignMessage(mssg, tkt);
    } else if (mssg.tktMssgTYPE == MessageType.rROBOTcallHistory.index) {
      return buildCallHistoryMessage(mssg, tkt);
    } else if (mssg.tktMssgTYPE == MessageType.image.index ||
        mssg.tktMssgTYPE == MessageType.doc.index ||
        mssg.tktMssgTYPE == MessageType.text.index ||
        mssg.tktMssgTYPE == MessageType.video.index ||
        mssg.tktMssgTYPE == MessageType.audio.index ||
        mssg.tktMssgTYPE == MessageType.contact.index ||
        mssg.tktMssgTYPE == MessageType.location.index) {
      return buildMediaMessages(mssg, tkt);
    } else if (mssg.tktMssgTYPE == MessageType.rROBOTticketclosed.index) {
      return getTicketClosedMessage(
          context: this.context,
          mssg: mssg,
          currentUserID: widget.currentUserID,
          customerUID: widget.customerUID,
          cuurentUserCanSeeAgentNamePhoto:
              widget.cuurentUserCanSeeAgentNamePhoto);
    } else if (mssg.tktMssgTYPE == MessageType.rROBOTticketreopened.index) {
      return getTicketReopenedMessage(
          context: this.context,
          mssg: mssg,
          currentUserID: widget.currentUserID,
          customerUID: widget.customerUID,
          cuurentUserCanSeeAgentNamePhoto:
              widget.cuurentUserCanSeeAgentNamePhoto);
    } else if (mssg.tktMssgTYPE == MessageType.rROBOTrequestedtoclose.index) {
      return getTicketRequestCloseMessage(
          context: this.context,
          mssg: mssg,
          currentUserID: widget.currentUserID,
          customerUID: widget.customerUID,
          cuurentUserCanSeeAgentNamePhoto:
              widget.cuurentUserCanSeeAgentNamePhoto);
    } else if (mssg.tktMssgTYPE == MessageType.rROBOTrequireattention.index) {
      return getTicketRequireAttentionMessage(
          context: this.context,
          mssg: mssg,
          currentUserID: widget.currentUserID,
          customerUID: widget.customerUID,
          cuurentUserCanSeeAgentNamePhoto:
              widget.cuurentUserCanSeeAgentNamePhoto);
    } else if (mssg.tktMssgTYPE == MessageType.rROBOTremovettention.index) {
      return getTicketRemoveAttentionMessage(
          context: this.context,
          mssg: mssg,
          currentUserID: widget.currentUserID,
          customerUID: widget.customerUID,
          cuurentUserCanSeeAgentNamePhoto:
              widget.cuurentUserCanSeeAgentNamePhoto);
    } else if (mssg.tktMssgTYPE == MessageType.rROBOTticketcreated.index) {
      return getTicketCreatedMessage(
          title: widget.ticketTitle ?? "",
          context: this.context,
          mssg: mssg,
          currentUserID: widget.currentUserID,
          customerUID: widget.customerUID,
          cuurentUserCanSeeAgentNamePhoto:
              widget.cuurentUserCanSeeAgentNamePhoto);
    } else if (mssg.tktMssgTYPE ==
            MessageType.rROBOTclosingDeniedByCustomer.index ||
        mssg.tktMssgTYPE == MessageType.rROBOTclosingDeniedByAgent.index) {
      return getTicketClosingRequestDenied(
          context: this.context,
          mssg: mssg,
          currentUserID: widget.currentUserID,
          customerUID: widget.customerUID,
          cuurentUserCanSeeAgentNamePhoto:
              widget.cuurentUserCanSeeAgentNamePhoto);
    } else {
      return Text(mssg.tktMssgCONTENT);
    }
  }

  onDismiss(
    TicketMessage mssg,
  ) {}

  FlutterSecureStorage storage = new FlutterSecureStorage();
  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);

  dynamic encryptWithCRC(String input) {
    try {
      String encrypted = cryptor.encrypt(input, iv: iv).base64;
      int crc = CRC32.compute(input);
      return '$encrypted${Dbkeys.crcSeperator}$crc';
    } catch (e) {
      Utils.toast('Error occured while encrypting !');
      return false;
    }
  }

  contextMenu(BuildContext context, TicketMessage mssg, {bool saved = false}) {
    List<Widget> tiles = List.from(<Widget>[]);
    final observer = Provider.of<Observer>(context, listen: false);
    if (mssg.tktMssgSENDBY == widget.currentUserID) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(
            Icons.delete,
            color: Mycolors.red,
          ),
          title: Text(
            getTranslatedForCurrentUser(context, 'xxdeletexx'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            getTranslatedForCurrentUser(context, 'xxadmincanstillseeitxx'),
            style: TextStyle(
                fontSize: 12,
                color: Mycolors.grey,
                fontWeight: FontWeight.normal),
          ),
          onTap: observer.checkIfCurrentUserIsDemo(widget.currentUserID) == true
              ? () {
                  Utils.toast(getTranslatedForCurrentUser(
                      context, 'xxxnotalwddemoxxaccountxx'));
                }
              : () async {
                  Navigator.of(this.context).pop();
                  ShowLoading().open(context: context, key: _keyLoader);
                  FirebaseFirestore.instance
                      .collection(DbPaths.collectiontickets)
                      .doc(widget.ticketID)
                      .collection(DbPaths.collectionticketChats)
                      .doc('${mssg.tktMssgTIME}--${mssg.tktMssgSENDBY}')
                      .update({
                    Dbkeys.tktMssgISDELETED: true,
                    Dbkeys.tktMsgDELETEREASON: "",
                    Dbkeys.tktMsgDELETEDby: widget.currentUserID
                  }).then((value) {
                    ShowLoading().close(context: context, key: _keyLoader);
                    Utils.toast(
                        getTranslatedForCurrentUser(context, 'xxdeletedxx'));
                  }).catchError((e) {
                    ShowLoading().close(context: context, key: _keyLoader);
                    Utils.toast("Failed to Delete the Message. ERROR: $e");
                  });
                }));
    }
    if (mssg.tktMssgTYPE == MessageType.text.index) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(
            Icons.content_copy,
            size: 17,
            color: Mycolors.primary,
          ),
          title: Text(
            getTranslatedForCurrentUser(context, 'xxcopyxx'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            Clipboard.setData(ClipboardData(text: mssg.tktMssgCONTENT));
            Navigator.pop(context);
            hidekeyboard(context);
            Utils.toast(
              getTranslatedForCurrentUser(context, 'xxcopiedxx'),
            );
          }));
    }
    showDialog(
        context: this.context,
        builder: (context) {
          return SimpleDialog(children: tiles);
        });
  }

  // }else if (mssg.tktMssgTYPE == MessageType.rROBOTremoveAssignAgentForACustomerCall.index) {
  //   return buildRemoveCallAssignMessage(mssg, tkt);
  Widget buildDepartmentChanged(
    TicketMessage mssg,
    TicketModel tkt,
  ) {
    final registry = Provider.of<UserRegistry>(this.context, listen: false);
    bool is24hrsFormat = true;
    humanReadableTime() =>
        DateFormat(is24hrsFormat == true ? 'HH:mm' : 'h:mm a')
            .format(DateTime.fromMillisecondsSinceEpoch(mssg.tktMssgTIME));
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 20,
          ),
          Container(
            width: MediaQuery.of(this.context).size.width / 1.3,
            padding: EdgeInsets.fromLTRB(12, 7, 12, 7),
            decoration: BoxDecoration(
                color: Color(0xff3d297a),
                border: Border.all(
                  color: Color(0xff3d297a),
                ),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: MtCustomfontBoldSemi(
              color: Colors.yellowAccent.withOpacity(0.9),
              textalign: TextAlign.center,
              lineheight: 1.3,
              fontsize: 13,
              text: getTranslatedForCurrentUser(this.context, 'xxchangedfromxx')
                  .replaceAll(
                      '(####)',
                      getTranslatedForCurrentUser(this.context, 'xxtktsxx') +
                          " " +
                          getTranslatedForCurrentUser(
                              this.context, 'xxdepartmentxx'))
                  .replaceAll('(###)',
                      "${mssg.tktMssgCONTENT.split('-xx-').toList()[1]}")
                  .replaceAll('(##)',
                      "${mssg.tktMssgCONTENT.split('-xx-').toList()[0]}"),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                mssg.tktMssgSENDBY == widget.customerUID
                    ? SizedBox()
                    : Icon(
                        Icons.person,
                        color: Mycolors.greytext,
                        size: 12,
                      ),
                mssg.tktMssgSENDBY == widget.customerUID
                    ? SizedBox()
                    : Text(
                        widget.cuurentUserCanSeeAgentNamePhoto
                            ? "  ${registry.getUserData(this.context, mssg.tktMssgSENDBY).fullname}"
                            : "  ${getTranslatedForCurrentUser(this.context, 'xxagentidxx')} ${registry.getUserData(this.context, mssg.tktMssgSENDBY).id}",
                        style:
                            TextStyle(fontSize: 12, color: Mycolors.greytext),
                      ),
                mssg.tktMssgSENDBY == widget.customerUID
                    ? SizedBox()
                    : SizedBox(
                        width: 30,
                      ),
                Text(
                    getWhen(
                            DateTime.fromMillisecondsSinceEpoch(
                                mssg.tktMssgTIME),
                            this.context) +
                        ', ',
                    style: TextStyle(
                      color: Mycolors.greytext,
                      fontSize: 11.0,
                    )),
                Text(' ' + humanReadableTime().toString(),
                    style: TextStyle(
                      color: Mycolors.greytext,
                      fontSize: 11.0,
                    )),
                // isMe ? icon : SizedBox()
                // ignore: unnecessary_null_comparison
              ].where((o) => o != null).toList()),
          SizedBox(
            height: 15,
          ),
        ]);
  }

  Widget buildAssignCallMessage(
    TicketMessage mssg,
    TicketModel tkt,
  ) {
    final registry = Provider.of<UserRegistry>(this.context, listen: false);
    bool is24hrsFormat = true;
    humanReadableTime() =>
        DateFormat(is24hrsFormat == true ? 'HH:mm' : 'h:mm a')
            .format(DateTime.fromMillisecondsSinceEpoch(mssg.tktMssgTIME));
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 20,
          ),
          Container(
            width: MediaQuery.of(this.context).size.width / 1.3,
            padding: EdgeInsets.fromLTRB(12, 7, 12, 7),
            decoration: BoxDecoration(
                color: Color(0xff8fffe0),
                border: Border.all(
                  color: Color(0xff8fffe0),
                ),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: MtCustomfontBoldSemi(
              color: Color(0xff0f267d),
              textalign: TextAlign.center,
              lineheight: 1.3,
              fontsize: 13,
              text: widget.currentUserID == widget.customerUID
                  ? getTranslatedForCurrentUser(
                          this.context, 'xxassignedforcall')
                      .replaceAll(
                          '(####)',
                          getTranslatedForCurrentUser(
                              this.context, 'xxagentxx'))
                      .replaceAll('(###)',
                          getTranslatedForCurrentUser(this.context, 'xxyouxx'))
                  : getTranslatedForCurrentUser(
                          this.context, 'xxassignedforcall')
                      .replaceAll(
                          '(####)',
                          getTranslatedForCurrentUser(
                                  this.context, 'xxagentidxx') +
                              " ${mssg.tktMssgCONTENT}")
                      .replaceAll(
                          '(###)',
                          getTranslatedForCurrentUser(
                              this.context, 'xxcustomerxx')),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                mssg.tktMssgSENDBY == widget.customerUID
                    ? SizedBox()
                    : Icon(
                        Icons.person,
                        color: Mycolors.greytext,
                        size: 12,
                      ),
                mssg.tktMssgSENDBY == widget.customerUID
                    ? SizedBox()
                    : Text(
                        widget.cuurentUserCanSeeAgentNamePhoto
                            ? "  ${registry.getUserData(this.context, mssg.tktMssgSENDBY).fullname}"
                            : "  ${getTranslatedForCurrentUser(this.context, 'xxagentidxx')} ${registry.getUserData(this.context, mssg.tktMssgSENDBY).id}",
                        style:
                            TextStyle(fontSize: 12, color: Mycolors.greytext),
                      ),
                mssg.tktMssgSENDBY == widget.customerUID
                    ? SizedBox()
                    : SizedBox(
                        width: 30,
                      ),
                Text(
                    getWhen(
                            DateTime.fromMillisecondsSinceEpoch(
                                mssg.tktMssgTIME),
                            this.context) +
                        ', ',
                    style: TextStyle(
                      color: Mycolors.greytext,
                      fontSize: 11.0,
                    )),
                Text(' ' + humanReadableTime().toString(),
                    style: TextStyle(
                      color: Mycolors.greytext,
                      fontSize: 11.0,
                    )),
                // isMe ? icon : SizedBox()
                // ignore: unnecessary_null_comparison
              ].where((o) => o != null).toList()),
          SizedBox(
            height: 15,
          ),
        ]);
  }

  Widget buildRemoveCallAssignMessage(
    TicketMessage mssg,
    TicketModel tkt,
  ) {
    final registry = Provider.of<UserRegistry>(this.context, listen: false);
    bool is24hrsFormat = true;
    humanReadableTime() =>
        DateFormat(is24hrsFormat == true ? 'HH:mm' : 'h:mm a')
            .format(DateTime.fromMillisecondsSinceEpoch(mssg.tktMssgTIME));
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 20,
          ),
          Container(
            width: MediaQuery.of(this.context).size.width / 1.3,
            padding: EdgeInsets.fromLTRB(12, 7, 12, 7),
            decoration: BoxDecoration(
                color: Color(0xffffccff),
                border: Border.all(
                  color: Color(0xffffccff),
                ),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: MtCustomfontBoldSemi(
              color: Color(0xff660066),
              textalign: TextAlign.center,
              lineheight: 1.3,
              fontsize: 13,
              text: widget.currentUserID == widget.customerUID
                  ? getTranslatedForCurrentUser(
                          this.context, 'xxaremovedorcall')
                      .replaceAll(
                          '(####)',
                          getTranslatedForCurrentUser(
                              this.context, 'xxagentxx'))
                      .replaceAll('(###)',
                          getTranslatedForCurrentUser(this.context, 'xxyouxx'))
                  : getTranslatedForCurrentUser(
                          this.context, 'xxaremovedorcall')
                      .replaceAll(
                          '(####)',
                          getTranslatedForCurrentUser(
                                  this.context, 'xxagentidxx') +
                              " ${mssg.tktMssgCONTENT}")
                      .replaceAll(
                          '(###)',
                          getTranslatedForCurrentUser(
                              this.context, 'xxcustomerxx')),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                mssg.tktMssgSENDBY == widget.customerUID
                    ? SizedBox()
                    : Icon(
                        Icons.person,
                        color: Mycolors.greytext,
                        size: 12,
                      ),
                mssg.tktMssgSENDBY == widget.customerUID
                    ? SizedBox()
                    : Text(
                        widget.cuurentUserCanSeeAgentNamePhoto
                            ? "  ${registry.getUserData(this.context, mssg.tktMssgSENDBY).fullname}"
                            : "  ${getTranslatedForCurrentUser(this.context, 'xxagentidxx')}  ${registry.getUserData(this.context, mssg.tktMssgSENDBY).id}",
                        style:
                            TextStyle(fontSize: 12, color: Mycolors.greytext),
                      ),
                mssg.tktMssgSENDBY == widget.customerUID
                    ? SizedBox()
                    : SizedBox(
                        width: 30,
                      ),
                Text(
                    getWhen(
                            DateTime.fromMillisecondsSinceEpoch(
                                mssg.tktMssgTIME),
                            this.context) +
                        ', ',
                    style: TextStyle(
                      color: Mycolors.greytext,
                      fontSize: 11.0,
                    )),
                Text(' ' + humanReadableTime().toString(),
                    style: TextStyle(
                      color: Mycolors.greytext,
                      fontSize: 11.0,
                    )),
                // isMe ? icon : SizedBox()
                // ignore: unnecessary_null_comparison
              ].where((o) => o != null).toList()),
          SizedBox(
            height: 15,
          ),
        ]);
  }

  Widget buildCallHistoryMessage(
    TicketMessage mssg,
    TicketModel tkt,
  ) {
    final registry = Provider.of<UserRegistry>(this.context, listen: false);
    bool is24hrsFormat = true;
    humanReadableTime() =>
        DateFormat(is24hrsFormat == true ? 'HH:mm' : 'h:mm a')
            .format(DateTime.fromMillisecondsSinceEpoch(mssg.tktMssgTIME));
    return Align(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                color: Color(0xffe0f5ff),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            padding: EdgeInsets.all(9),
            width: MediaQuery.of(this.context).size.width / 1.7,
            child: Center(
              child: futureLoad(
                  future: FirebaseFirestore.instance
                      .collection(widget.currentUserID == widget.customerUID
                          ? DbPaths.collectioncustomers
                          : DbPaths.collectionagents)
                      .doc(widget.currentUserID == widget.customerUID
                          ? mssg.tktMsgCUSTOMERID
                          : mssg.tktMsgDELETEREASON)
                      .collection(DbPaths.collectioncallhistory)
                      .doc(mssg.tktMssgTIME.toString())
                      .get(),
                  placeholder: Center(
                    child: MtCustomfontBoldSemi(
                        fontsize: 12,
                        color: Mycolors.grey,
                        text: mssg.tktMssgSENDBY == widget.customerUID
                            ? getTranslatedForCurrentUser(
                                    this.context, 'xxcallbyxxtoxx')
                                .replaceAll(
                                    '(####)',
                                    getTranslatedForCurrentUser(
                                        this.context,
                                        widget.currentUserID == widget.customerUID
                                            ? 'xxmexx'
                                            : 'xxcustomerxx'))
                                .replaceAll(
                                    '(###)',
                                    getTranslatedForCurrentUser(
                                            this.context, 'xxagentidxx') +
                                        " ${mssg.tktMsgDELETEREASON}")
                            : getTranslatedForCurrentUser(
                                    this.context, 'xxcallbyxxtoxx')
                                .replaceAll(
                                    '(###)',
                                    getTranslatedForCurrentUser(
                                        this.context,
                                        widget.currentUserID ==
                                                widget.customerUID
                                            ? 'xxmexx'
                                            : 'xxcustomerxx'))
                                .replaceAll(
                                    '(####)',
                                    getTranslatedForCurrentUser(
                                            this.context, 'xxagentidxx') +
                                        " ${mssg.tktMsgDELETEREASON}")),
                  ),
                  onfetchdone: (dc) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MtCustomfontBoldSemi(
                          color: Mycolors.grey,
                          fontsize: 12,
                          // text: widget.currentUserID == widget.customerUID
                          //     ? "Call with Agent ID: ${mssg.tktMsgDELETEREASON}"
                          //     : mssg.tktMssgSENDBY == widget.customerUID
                          //         ? "Call by Customer to Agent ID: ${mssg.tktMsgDELETEREASON}"
                          //         : "Call by Agent ID: ${mssg.tktMsgDELETEREASON}",
                          text: mssg.tktMssgSENDBY == widget.customerUID
                              ? getTranslatedForCurrentUser(
                                      this.context, 'xxcallbyxxtoxx')
                                  .replaceAll(
                                      '(####)',
                                      getTranslatedForCurrentUser(
                                          this.context,
                                          widget.currentUserID ==
                                                  widget.customerUID
                                              ? 'xxmexx'
                                              : 'xxcustomerxx'))
                                  .replaceAll(
                                      '(###)',
                                      getTranslatedForCurrentUser(
                                              this.context, 'xxagentidxx') +
                                          " ${mssg.tktMsgDELETEREASON}")
                              : getTranslatedForCurrentUser(
                                      this.context, 'xxcallbyxxtoxx')
                                  .replaceAll(
                                      '(###)',
                                      getTranslatedForCurrentUser(
                                          this.context,
                                          widget.currentUserID ==
                                                  widget.customerUID
                                              ? 'xxmexx'
                                              : 'xxcustomerxx'))
                                  .replaceAll(
                                      '(####)',
                                      getTranslatedForCurrentUser(
                                              this.context, 'xxagentidxx') +
                                          " ${mssg.tktMsgDELETEREASON}"),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              dc['ISVIDEOCALL'] == true
                                  ? Icons.video_call
                                  : Icons.call,
                              color: Mycolors.getColor(
                                  widget.prefs, Colortype.secondary.index),
                              size: 18,
                            ),
                            SizedBox(
                              width: 14,
                            ),
                            Icon(
                              dc['TYPE'] == 'INCOMING'
                                  ? (dc['STARTED'] == null
                                      ? Icons.call_missed
                                      : Icons.call_received)
                                  : (dc['STARTED'] == null
                                      ? Icons.call_made_rounded
                                      : Icons.call_made_rounded),
                              size: 15,
                              color: dc['TYPE'] == 'INCOMING'
                                  ? (dc['STARTED'] == null
                                      ? Colors.redAccent
                                      : Mycolors.secondary)
                                  : (dc['STARTED'] == null
                                      ? Colors.redAccent
                                      : Mycolors.secondary),
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            dc['STARTED'] == null || dc['ENDED'] == null
                                ? SizedBox(
                                    height: 0,
                                    width: 0,
                                  )
                                : Container(
                                    padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
                                    decoration: BoxDecoration(
                                        color: Mycolors.secondary,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Text(
                                      dc['ENDED']
                                                  .toDate()
                                                  .difference(
                                                      dc['STARTED'].toDate())
                                                  .inMinutes <
                                              1
                                          ? dc['ENDED']
                                                  .toDate()
                                                  .difference(
                                                      dc['STARTED'].toDate())
                                                  .inSeconds
                                                  .toString() +
                                              's'
                                          : dc['ENDED']
                                                  .toDate()
                                                  .difference(
                                                      dc['STARTED'].toDate())
                                                  .inMinutes
                                                  .toString() +
                                              'm',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ),
                                  )
                          ],
                        ),
                      ],
                    );
                  }),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                mssg.tktMssgSENDBY == widget.customerUID
                    ? SizedBox()
                    : Icon(
                        Icons.person,
                        color: Mycolors.greytext,
                        size: 12,
                      ),
                mssg.tktMssgSENDBY == widget.customerUID
                    ? SizedBox()
                    : Text(
                        widget.cuurentUserCanSeeAgentNamePhoto
                            ? "  ${registry.getUserData(this.context, mssg.tktMssgSENDBY).fullname}"
                            : "  ${getTranslatedForCurrentUser(this.context, 'xxagentidxx')} ${registry.getUserData(this.context, mssg.tktMssgSENDBY).id}",
                        style:
                            TextStyle(fontSize: 12, color: Mycolors.greytext),
                      ),
                mssg.tktMssgSENDBY == widget.customerUID
                    ? SizedBox()
                    : SizedBox(
                        width: 30,
                      ),
                Text(
                    getWhen(
                            DateTime.fromMillisecondsSinceEpoch(
                                mssg.tktMssgTIME),
                            this.context) +
                        ', ',
                    style: TextStyle(
                      color: Mycolors.greytext,
                      fontSize: 11.0,
                    )),
                Text(' ' + humanReadableTime().toString(),
                    style: TextStyle(
                      color: Mycolors.greytext,
                      fontSize: 11.0,
                    )),
                // isMe ? icon : SizedBox()
                // ignore: unnecessary_null_comparison
              ].where((o) => o != null).toList()),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget buildMediaMessages(
    TicketMessage mssg,
    TicketModel tkt,
  ) {
    bool isMe = widget.currentUserID == widget.customerUID
        ? (mssg.tktMssgSENDBY == widget.currentUserID ? true : false)
        : widget.customerUID != mssg.tktMssgSENDBY;
    bool saved = false;
    final observer = Provider.of<Observer>(this.context, listen: false);
    final registry = Provider.of<UserRegistry>(this.context, listen: false);

    return InkWell(
      onLongPress: mssg.tktMssgISDELETED == false
          ? () {
              contextMenu(this.context, mssg);
              hidekeyboard(this.context);
            }
          : null,
      child: TicketBubble(
        isHideAgentsNameToCustomer: true,
        isSecretMessage:
            !mssg.tktMssgSENDFOR.contains(MssgSendFor.customer.index),
        isRobotic: isRobotic(mssg.tktMssgTYPE),
        customerUID: widget.customerUID,
        mssg: mssg,
        is24hrsFormat: observer.is24hrsTimeformat,
        prefs: widget.prefs,
        currentUserNo: widget.currentUserID,
        model: widget.model,
        savednameifavailable: widget.currentUserID,
        postedbyname: mssg.tktMssgSENDBY == "sys" ||
                mssg.tktMssgSENDBY == "Admin"
            ? getTranslatedForCurrentUser(this.context, 'xxadminxx')
            : widget.customerUID == mssg.tktMssgSENDBY
                ? widget.cuurentUserCanSeeCustomerNamePhoto
                    ? registry
                        .getUserData(this.context, mssg.tktMssgSENDBY)
                        .fullname
                    : getTranslatedForCurrentUser(this.context, 'xxcustomerxx')
                : widget.cuurentUserCanSeeAgentNamePhoto
                    ? registry
                        .getUserData(this.context, mssg.tktMssgSENDBY)
                        .fullname
                    : "${getTranslatedForCurrentUser(this.context, 'xxagentidxx')} ${mssg.tktMssgSENDBY}",
        postedbyUID: mssg.tktMssgSENDBY,
        messagetype: mssg.tktMssgISDELETED == true
            ? MessageType.text
            : mssg.tktMssgTYPE == MessageType.text.index
                ? MessageType.text
                : mssg.tktMssgTYPE == MessageType.contact.index
                    ? MessageType.contact
                    : mssg.tktMssgTYPE == MessageType.location.index
                        ? MessageType.location
                        : mssg.tktMssgTYPE == MessageType.image.index
                            ? MessageType.image
                            : mssg.tktMssgTYPE == MessageType.video.index
                                ? MessageType.video
                                : mssg.tktMssgTYPE == MessageType.doc.index
                                    ? MessageType.doc
                                    : mssg.tktMssgTYPE ==
                                            MessageType.audio.index
                                        ? MessageType.audio
                                        : MessageType.text,
        child: mssg.tktMssgISDELETED == true
            ? Text(
                widget.currentUserID == widget.customerUID
                    ? getTranslatedForCurrentUser(
                        this.context, 'xxmsgdeletedxx')
                    : mssg.tktMsgDELETEDby == "Admin"
                        ? mssg.tktMsgDELETEREASON != ""
                            ? getTranslatedForCurrentUser(
                                    this.context, 'xxmsgdltdbyadminforreasonxx')
                                .replaceAll(
                                    '(####)', "${mssg.tktMsgDELETEREASON}")
                            : getTranslatedForCurrentUser(
                                this.context, 'xxmsgdltdbyadminxx')
                        : mssg.tktMsgDELETEDby == widget.currentUserID
                            ? getTranslatedForCurrentUser(
                                    this.context, 'xxdeletedbyxx')
                                .replaceAll(
                                    '(####)',
                                    getTranslatedForCurrentUser(
                                        this.context, 'xxmexx'))
                            : mssg.tktMsgDELETEDby == widget.customerUID
                                ? getTranslatedForCurrentUser(
                                        this.context, 'xxdeletedbyxx')
                                    .replaceAll(
                                        '(####)',
                                        getTranslatedForCurrentUser(
                                            this.context, 'xxcustomerxx'))
                                : getTranslatedForCurrentUser(
                                        this.context, 'xxdeletedbyxx')
                                    .replaceAll(
                                        '(####)',
                                        getTranslatedForCurrentUser(
                                            this.context, 'xxagentxx')),
                style: TextStyle(
                    color: Mycolors.black.withOpacity(0.6),
                    fontSize: 13,
                    fontStyle: FontStyle.italic),
              )
            : mssg.tktMssgTYPE == MessageType.text.index
                ? getTextMessage(isMe, mssg, saved)
                : mssg.tktMssgTYPE == MessageType.location.index
                    ? getLocationMessage(mssg.tktMssgCONTENT, mssg,
                        saved: false)
                    : mssg.tktMssgTYPE == MessageType.doc.index
                        ? getDocmessage(this.context, mssg.tktMssgCONTENT, mssg,
                            saved: false)
                        : mssg.tktMssgTYPE == MessageType.audio.index
                            ? getAudiomessage(
                                this.context, mssg.tktMssgCONTENT, mssg,
                                isMe: isMe, saved: false)
                            : mssg.tktMssgTYPE == MessageType.video.index
                                ? getVideoMessage(
                                    this.context, mssg.tktMssgCONTENT, mssg,
                                    saved: false)
                                : mssg.tktMssgTYPE == MessageType.contact.index
                                    ? getContactMessage(
                                        this.context, mssg.tktMssgCONTENT, mssg,
                                        saved: false)
                                    : getImageMessage(
                                        mssg,
                                        saved: saved,
                                      ),
        isMe: isMe,
        delivered: true,
        isContinuing: true,
        timestamp: mssg.tktMssgTIME,
      ),
    );
  }

  Widget getVideoMessage(
      BuildContext context, String message, TicketMessage mssg,
      {bool saved = false}) {
    Map<dynamic, dynamic>? meta =
        jsonDecode((message.split('-BREAK-')[2]).toString());
    final bool isMe = mssg.tktMssgSENDBY == widget.currentUserID;
    return Container(
      child: InkWell(
        onTap: () {
          Navigator.push(
              this.context,
              new MaterialPageRoute(
                  builder: (context) => new PreviewVideo(
                        isdownloadallowed: true,
                        filename: message.split('-BREAK-')[1],
                        id: null,
                        videourl: message.split('-BREAK-')[0],
                        aspectratio: meta!["width"] / meta["height"],
                      )));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            mssg.tktMssgISFORWARD == true
                ? Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Row(
                        mainAxisAlignment: isMe == true
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FontAwesomeIcons.share,
                            size: 12,
                            color: Mycolors.grey.withOpacity(0.5),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                              getTranslatedForCurrentUser(
                                  this.context, 'xxforwardedxx'),
                              maxLines: 1,
                              style: TextStyle(
                                  color: Mycolors.grey.withOpacity(0.7),
                                  fontStyle: FontStyle.italic,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 13))
                        ]))
                : SizedBox(height: 0, width: 0),
            Container(
              color: Colors.blueGrey,
              width: 245,
              height: 245,
              child: Stack(
                children: [
                  CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blueGrey[400]!),
                        ),
                      ),
                      width: 245,
                      height: 245,
                      padding: EdgeInsets.all(80.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.all(
                          Radius.circular(0.0),
                        ),
                      ),
                    ),
                    errorWidget: (context, str, error) => Material(
                      child: Image.asset(
                        'assets/images/img_not_available.jpeg',
                        width: 245,
                        height: 245,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(0.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                    ),
                    imageUrl: message.split('-BREAK-')[1],
                    width: 245,
                    height: 245,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.4),
                    width: 245,
                    height: 245,
                  ),
                  Center(
                    child: Icon(Icons.play_circle_fill_outlined,
                        color: Colors.white70, size: 65),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getContactMessage(
      BuildContext context, String message, TicketMessage mssg,
      {bool saved = false}) {
    final bool isMe = mssg.tktMssgSENDBY == widget.currentUserID;
    return SizedBox(
      width: 210,
      height: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mssg.tktMssgISFORWARD == true
              ? Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                      mainAxisAlignment: isMe == true
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FontAwesomeIcons.share,
                          size: 12,
                          color: Mycolors.grey.withOpacity(0.5),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                            getTranslatedForCurrentUser(
                                this.context, 'xxforwardedxx'),
                            maxLines: 1,
                            style: TextStyle(
                                color: Mycolors.grey.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 13))
                      ]))
              : SizedBox(height: 0, width: 0),
          ListTile(
            isThreeLine: false,
            leading: customCircleAvatar(url: null, radius: 20),
            title: Text(
              message.split('-BREAK-')[0],
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[400]),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                message.split('-BREAK-')[1],
                style: TextStyle(
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getTextMessage(bool isMe, TicketMessage mssg, bool saved) {
    return mssg.tktMssgISREPLY == true
        ? Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              replyAttachedWidget(this.context, mssg.tktMssgREPLYTOMSSGDOC),
              SizedBox(
                height: 10,
              ),
              selectablelinkify(mssg.tktMssgCONTENT, 15.5, TextAlign.left),
            ],
          )
        : mssg.tktMssgISFORWARD == true
            ? Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      child: Row(
                          mainAxisAlignment: isMe == true
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                        Icon(
                          FontAwesomeIcons.share,
                          size: 12,
                          color: Mycolors.grey.withOpacity(0.5),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                            getTranslatedForCurrentUser(
                                this.context, 'xxforwardedxx'),
                            maxLines: 1,
                            style: TextStyle(
                                color: Mycolors.grey.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 13))
                      ])),
                  SizedBox(
                    height: 10,
                  ),
                  selectablelinkify(mssg.tktMssgCONTENT, 15.5, TextAlign.left)
                ],
              )
            : selectablelinkify(mssg.tktMssgCONTENT, 15.5, TextAlign.left);
  }

  Widget getLocationMessage(String? message, TicketMessage mssg,
      {bool saved = false}) {
    final bool isMe = mssg.tktMssgSENDBY == widget.currentUserID;
    return InkWell(
      onTap: () {
        custom_url_launcher(message!);
      },
      child: mssg.tktMssgISFORWARD == true
          ? Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    child: Row(
                        mainAxisAlignment: isMe == true
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      Icon(
                        FontAwesomeIcons.share,
                        size: 12,
                        color: Mycolors.grey.withOpacity(0.5),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                          getTranslatedForCurrentUser(
                              this.context, 'xxforwardedxx'),
                          maxLines: 1,
                          style: TextStyle(
                              color: Mycolors.grey.withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 13))
                    ])),
                SizedBox(
                  height: 10,
                ),
                Image.asset(
                  'assets/images/mapview.jpg',
                  width: MediaQuery.of(this.context).size.width / 1.7,
                  height: (MediaQuery.of(this.context).size.width / 1.7) * 0.6,
                ),
              ],
            )
          : Image.asset(
              'assets/images/mapview.jpg',
              width: MediaQuery.of(this.context).size.width / 1.7,
              height: (MediaQuery.of(this.context).size.width / 1.7) * 0.6,
            ),
    );
  }

  Widget getAudiomessage(
      BuildContext context, String message, TicketMessage mssg,
      {bool saved = false, bool isMe = true}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      // width: 250,
      // height: 116,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mssg.tktMssgISFORWARD == true
              ? Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                      mainAxisAlignment: isMe == true
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FontAwesomeIcons.share,
                          size: 12,
                          color: Mycolors.grey.withOpacity(0.5),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                            getTranslatedForCurrentUser(
                                this.context, 'xxforwardedxx'),
                            maxLines: 1,
                            style: TextStyle(
                                color: Mycolors.grey.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 13))
                      ]))
              : SizedBox(height: 0, width: 0),
          SizedBox(
            width: 200,
            height: 80,
            child: MultiPlayback(
              isMe: isMe,
              onTapDownloadFn: Platform.isIOS || Platform.isAndroid
                  ? () {
                      custom_url_launcher(message.split('-BREAK-')[0]);
                    }
                  : () async {
                      await downloadFile(
                        context: _scaffold.currentContext!,
                        fileName:
                            'Recording_' + message.split('-BREAK-')[1] + '.mp3',
                        isonlyview: false,
                        keyloader: _keyLoader,
                        uri: message.split('-BREAK-')[0],
                      );
                    },
              url: message.split('-BREAK-')[0],
            ),
          )
        ],
      ),
    );
  }

  Widget getDocmessage(BuildContext context, String message, TicketMessage mssg,
      {bool saved = false}) {
    final bool isMe = mssg.tktMssgSENDBY == widget.currentUserID;
    return SizedBox(
      width: 220,
      height: 126,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mssg.tktMssgISFORWARD == true
              ? Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                      mainAxisAlignment: isMe == true
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FontAwesomeIcons.share,
                          size: 12,
                          color: Mycolors.grey.withOpacity(0.5),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                            getTranslatedForCurrentUser(
                                this.context, 'xxforwardedxx'),
                            maxLines: 1,
                            style: TextStyle(
                                color: Mycolors.grey.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 13))
                      ]))
              : SizedBox(height: 0, width: 0),
          ListTile(
            contentPadding: EdgeInsets.all(4),
            isThreeLine: false,
            leading: Container(
              decoration: BoxDecoration(
                color: Colors.yellow[800],
                borderRadius: BorderRadius.circular(7.0),
              ),
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.insert_drive_file,
                size: 25,
                color: Colors.white,
              ),
            ),
            title: Text(
              message.split('-BREAK-')[1],
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87),
            ),
          ),
          Divider(
            height: 3,
          ),
          message.split('-BREAK-')[1].endsWith('.pdf')
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (_) => PDFViewerCachedFromUrl(
                                currentUserID: widget.currentUserID,
                                prefs: widget.prefs,
                                title: message.split('-BREAK-')[1],
                                url: message.split('-BREAK-')[0],
                                isregistered: true,
                              ),
                            ),
                          );
                        },
                        child: Text(
                            getTranslatedForCurrentUser(context, 'xxpreviewxx'),
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.blue[400]))),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: Platform.isIOS || Platform.isAndroid
                            ? () {
                                custom_url_launcher(
                                    message.split('-BREAK-')[0]);
                              }
                            : () async {
                                await downloadFile(
                                  context: _scaffold.currentContext!,
                                  fileName: message.split('-BREAK-')[1],
                                  isonlyview: false,
                                  keyloader: _keyLoader,
                                  uri: message.split('-BREAK-')[0],
                                );
                              },
                        child: Text(
                            getTranslatedForCurrentUser(
                                context, 'xxdownloadxx'),
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.blue[400]))),
                  ],
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  onPressed: Platform.isIOS || Platform.isAndroid
                      ? () {
                          custom_url_launcher(message.split('-BREAK-')[0]);
                        }
                      : () async {
                          await downloadFile(
                            context: _scaffold.currentContext!,
                            fileName: message.split('-BREAK-')[1],
                            isonlyview: false,
                            keyloader: _keyLoader,
                            uri: message.split('-BREAK-')[0],
                          );
                        },
                  child: Text(
                      getTranslatedForCurrentUser(context, 'xxdownloadxx'),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.blue[400]))),
        ],
      ),
    );
  }

  Widget getImageMessage(TicketMessage mssg, {bool saved = false}) {
    final bool isMe = mssg.tktMssgSENDBY == widget.currentUserID;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          mssg.tktMssgISFORWARD == true
              ? Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                      mainAxisAlignment: isMe == true
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FontAwesomeIcons.share,
                          size: 12,
                          color: Mycolors.grey.withOpacity(0.5),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                            getTranslatedForCurrentUser(
                                this.context, 'xxforwardedxx'),
                            maxLines: 1,
                            style: TextStyle(
                                color: Mycolors.grey.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                                overflow: TextOverflow.ellipsis,
                                fontSize: 13))
                      ]))
              : SizedBox(height: 0, width: 0),
          saved
              ? Material(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: Save.getImageFromBase64(mssg.tktMssgCONTENT)
                              .image,
                          fit: BoxFit.cover),
                    ),
                    width: mssg.tktMssgCONTENT.contains('giphy') ? 160 : 245.0,
                    height: mssg.tktMssgCONTENT.contains('giphy') ? 160 : 245.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                )
              : InkWell(
                  onTap: () => Navigator.push(
                      this.context,
                      MaterialPageRoute(
                        builder: (context) => PhotoViewWrapper(
                          keyloader: _keyLoader,
                          imageUrl: mssg.tktMssgCONTENT,
                          message: mssg.tktMssgCONTENT,
                          tag: mssg.tktMssgTIME.toString(),
                          imageProvider:
                              CachedNetworkImageProvider(mssg.tktMssgCONTENT),
                        ),
                      )),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: Center(
                        child: SizedBox(
                          height: 60.0,
                          width: 60.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blueGrey[400]!),
                          ),
                        ),
                      ),
                      width:
                          mssg.tktMssgCONTENT.contains('giphy') ? 160 : 245.0,
                      height:
                          mssg.tktMssgCONTENT.contains('giphy') ? 160 : 245.0,
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                    ),
                    errorWidget: (context, str, error) => Material(
                      child: Image.asset(
                        'assets/images/img_not_available.jpeg',
                        width:
                            mssg.tktMssgCONTENT.contains('giphy') ? 160 : 245.0,
                        height:
                            mssg.tktMssgCONTENT.contains('giphy') ? 160 : 245.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                    ),
                    imageUrl: mssg.tktMssgCONTENT,
                    width: mssg.tktMssgCONTENT.contains('giphy') ? 160 : 245.0,
                    height: mssg.tktMssgCONTENT.contains('giphy') ? 160 : 245.0,
                    fit: BoxFit.cover,
                  ),
                ),
        ],
      ),
    );
  }

  replyAttachedWidget(BuildContext context, var doc) {
    return Flexible(
      child: Container(
          // width: 280,
          height: 70,
          margin: EdgeInsets.only(left: 0, right: 0),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Stack(
            children: [
              Container(
                  margin: EdgeInsetsDirectional.all(4),
                  decoration: BoxDecoration(
                      color: Mycolors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Row(children: [
                    Container(
                      decoration: BoxDecoration(
                        color: doc[Dbkeys.tktMssgSENDBY] == widget.currentUserID
                            ? Mycolors.primary
                            : Colors.purple,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      height: 75,
                      width: 3.3,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: Container(
                      padding: EdgeInsetsDirectional.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 30),
                            child: Text(
                              doc[Dbkeys.tktMssgSENDBY] == widget.currentUserID
                                  ? getTranslatedForCurrentUser(
                                      this.context, 'xxyouxx')
                                  : doc[Dbkeys.tktMssgSENDBY].toString(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: doc[Dbkeys.tktMssgSENDBY] ==
                                          widget.currentUserID
                                      ? Mycolors.primary
                                      : Colors.purple),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          doc[Dbkeys.tktMssgTYPE] == MessageType.text.index
                              ? Text(
                                  doc[Dbkeys.tktMssgCONTENT],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                )
                              : doc[Dbkeys.tktMssgTYPE] == MessageType.doc.index
                                  ? Container(
                                      padding: const EdgeInsets.only(right: 75),
                                      child: Text(
                                        doc[Dbkeys.tktMssgCONTENT]
                                            .split('-BREAK-')[1],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    )
                                  : Text(
                                      getTranslatedForCurrentUser(
                                          this.context,
                                          doc[Dbkeys.tktMssgTYPE] ==
                                                  MessageType.image.index
                                              ? 'xxnimxx'
                                              : doc[Dbkeys.tktMssgTYPE] ==
                                                      MessageType.video.index
                                                  ? 'xxnvmxx'
                                                  : doc[Dbkeys.tktMssgTYPE] ==
                                                          MessageType
                                                              .audio.index
                                                      ? 'xxnamxx'
                                                      : doc[Dbkeys.tktMssgTYPE] ==
                                                              MessageType
                                                                  .contact.index
                                                          ? 'xxncmxx'
                                                          : doc[Dbkeys.tktMssgTYPE] ==
                                                                  MessageType
                                                                      .location
                                                                      .index
                                                              ? 'xxnlmxx'
                                                              : doc[Dbkeys.tktMssgTYPE] ==
                                                                      MessageType
                                                                          .doc
                                                                          .index
                                                                  ? 'xxndmxx'
                                                                  : ''),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                        ],
                      ),
                    ))
                  ])),
              doc[Dbkeys.tktMssgTYPE] == MessageType.text.index ||
                      doc[Dbkeys.tktMssgTYPE] == MessageType.location.index
                  ? SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : doc[Dbkeys.tktMssgTYPE] == MessageType.image.index
                      ? Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 74.0,
                            height: 74.0,
                            padding: EdgeInsetsDirectional.all(6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  bottomRight: Radius.circular(5),
                                  topLeft: Radius.circular(0),
                                  bottomLeft: Radius.circular(0)),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Mycolors.secondary),
                                  ),
                                  width: doc[Dbkeys.tktMssgCONTENT]
                                          .contains('giphy')
                                      ? 60
                                      : 60.0,
                                  height: doc[Dbkeys.tktMssgCONTENT]
                                          .contains('giphy')
                                      ? 60
                                      : 60.0,
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[200],
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, str, error) => Material(
                                  child: Image.asset(
                                    'assets/images/img_not_available.jpeg',
                                    width: 60.0,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                imageUrl: doc[Dbkeys.tktMssgTYPE] ==
                                        MessageType.video.index
                                    ? ''
                                    : doc[Dbkeys.tktMssgCONTENT],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : doc[Dbkeys.tktMssgTYPE] == MessageType.video.index
                          ? Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                  width: 74.0,
                                  height: 74.0,
                                  padding: EdgeInsetsDirectional.all(6),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                        color: Colors.blueGrey[200],
                                        height: 74,
                                        width: 74,
                                        child: Stack(
                                          children: [
                                            CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Container(
                                                child:
                                                    CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          Mycolors.secondary),
                                                ),
                                                width: 74,
                                                height: 74,
                                                padding: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueGrey[200],
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(0.0),
                                                  ),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, str, error) =>
                                                      Material(
                                                child: Image.asset(
                                                  'assets/images/img_not_available.jpeg',
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(0.0),
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                              ),
                                              imageUrl:
                                                  doc[Dbkeys.tktMssgCONTENT]
                                                      .split('-BREAK-')[1],
                                              width: 74,
                                              height: 74,
                                              fit: BoxFit.cover,
                                            ),
                                            Container(
                                              color:
                                                  Colors.black.withOpacity(0.4),
                                              height: 74,
                                              width: 74,
                                            ),
                                            Center(
                                              child: Icon(
                                                  Icons
                                                      .play_circle_fill_outlined,
                                                  color: Colors.white70,
                                                  size: 25),
                                            ),
                                          ],
                                        ),
                                      ))))
                          : Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                  width: 74.0,
                                  height: 74.0,
                                  padding: EdgeInsetsDirectional.all(6),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                          color: doc[Dbkeys.tktMssgTYPE] ==
                                                  MessageType.doc.index
                                              ? Colors.yellow[800]
                                              : doc[Dbkeys.tktMssgTYPE] ==
                                                      MessageType.audio.index
                                                  ? Colors.green[400]
                                                  : doc[Dbkeys.tktMssgTYPE] ==
                                                          MessageType
                                                              .location.index
                                                      ? Colors.red[700]
                                                      : doc[Dbkeys.tktMssgTYPE] ==
                                                              MessageType
                                                                  .contact.index
                                                          ? Colors.blue[400]
                                                          : Colors.cyan[700],
                                          height: 74,
                                          width: 74,
                                          child: Icon(
                                            doc[Dbkeys.tktMssgTYPE] ==
                                                    MessageType.doc.index
                                                ? Icons.insert_drive_file
                                                : doc[Dbkeys.tktMssgTYPE] ==
                                                        MessageType.audio.index
                                                    ? Icons.mic_rounded
                                                    : doc[Dbkeys.tktMssgTYPE] ==
                                                            MessageType
                                                                .location.index
                                                        ? Icons.location_on
                                                        : doc[Dbkeys.tktMssgTYPE] ==
                                                                MessageType
                                                                    .contact
                                                                    .index
                                                            ? Icons
                                                                .contact_page_sharp
                                                            : Icons
                                                                .insert_drive_file,
                                            color: Colors.white,
                                            size: 35,
                                          ))))),
            ],
          )),
    );
  }

  Future<Position> _determinePosition() async {
    return await Geolocator.getCurrentPosition();
  }

  Future<bool> checkIfLocationEnabled() async {
    if (await Permission.location.request().isGranted) {
      return true;
    } else if (await Permission.locationAlways.request().isGranted) {
      return true;
    } else if (await Permission.locationWhenInUse.request().isGranted) {
      return true;
    } else {
      return false;
    }
  }

  Widget buildMessagesUsingProvider(
      BuildContext context, TicketModel currentTicket) {
    return Consumer<SpecialLiveConfigData?>(
        builder: (context, livedata, _child) =>
            Consumer<FirestoreDataProviderMESSAGESforTICKETCHAT>(
                builder: (context, firestoreDataProvider, _) =>
                    InfiniteCOLLECTIONListViewWidget(
                      scrollController: realtime,
                      isreverse: true,
                      firestoreDataProviderMESSAGESforTICKETCHAT:
                          firestoreDataProvider,
                      datatype: Dbkeys.datatypeTICKETMSSGS,
                      refdata: firestoreChatquery,
                      list: ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.all(7),
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: firestoreDataProvider.recievedDocs.length,
                          itemBuilder: (BuildContext context, int i) {
                            var dc = firestoreDataProvider.recievedDocs[i];

                            return buildEachMessage(
                                TicketMessage.fromJson(dc), currentTicket);
                          }),
                    )));
  }

  Widget buildLoadingThumbnail() {
    return Positioned(
      child: isgeneratingSomethingLoader
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Mycolors.secondary)),
              ),
              color: Colors.white.withOpacity(0.6),
            )
          : Container(),
    );
  }

  shareMedia(
    BuildContext context,
    String ticketName,
    String ticketfilteredID,
    String departmentTitle,
    List<dynamic> agents,
  ) {
    final observer = Provider.of<Observer>(context, listen: false);
    setStatusBarColor();
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Container(
            padding: EdgeInsets.all(12),
            height: 250,
            child: Column(children: [
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: observer.checkIfCurrentUserIsDemo(
                                      widget.currentUserID) ==
                                  true
                              ? () {
                                  Utils.toast(getTranslatedForCurrentUser(
                                      context, 'xxxnotalwddemoxxaccountxx'));
                                }
                              : () {
                                  hidekeyboard(context);
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MultiDocumentPicker(
                                                title:
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxpickdocxx'),
                                                callback: getFileData,
                                                writeMessage: (String? url,
                                                    int time) async {
                                                  if (url != null) {
                                                    // onSendMessage(
                                                    //     this.context,
                                                    //     finalUrl,
                                                    //     MessageType.doc,
                                                    //     time);

                                                    String finalUrl = url +
                                                        '-BREAK-' +
                                                        basename(pickedFile!
                                                                .path)
                                                            .toString();
                                                    onSendMessage(
                                                        departmentTitle:
                                                            departmentTitle,
                                                        agents: agents,
                                                        ticketName: ticketName,
                                                        ticketfilteredID:
                                                            ticketfilteredID,
                                                        context: this.context,
                                                        content: finalUrl,
                                                        type: MessageType.doc,
                                                        timestamp: time);
                                                  }
                                                },
                                              )));
                                },
                          elevation: .5,
                          fillColor: Colors.indigo,
                          child: Icon(
                            Icons.file_copy,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          getTranslatedForCurrentUser(this.context, 'xxdocxx'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 14),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () async {
                            hidekeyboard(context);
                            Navigator.of(context).pop();
                            File? selectedMedia =
                                await pickVideoFromgallery(context)
                                    .catchError((err) {
                              Utils.toast(getTranslatedForCurrentUser(
                                  context, "invalidfile"));
                            });

                            if (selectedMedia == null) {
                              setStatusBarColor();
                            } else {
                              setStatusBarColor();
                              String fileExtension =
                                  p.extension(selectedMedia.path).toLowerCase();

                              if (fileExtension == ".mp4" ||
                                  fileExtension == ".mov") {
                                final tempDir = await getTemporaryDirectory();
                                File file = await File(
                                        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4')
                                    .create();
                                file.writeAsBytesSync(
                                    selectedMedia.readAsBytesSync());

                                await Navigator.push(
                                    this.context,
                                    new MaterialPageRoute(
                                        builder: (context) => new VideoEditor(
                                            onClose: () {
                                              setStatusBarColor();
                                            },
                                            thumbnailQuality: 90,
                                            videoQuality: 100,
                                            maxDuration: 1900,
                                            onEditExported: (videoFile,
                                                thumnailFile) async {
                                              if (observer
                                                      .checkIfCurrentUserIsDemo(
                                                          widget
                                                              .currentUserID) ==
                                                  true) {
                                                Utils.toast(
                                                    getTranslatedForCurrentUser(
                                                        context,
                                                        'xxxnotalwddemoxxaccountxx'));
                                              } else {
                                                int timeStamp = DateTime.now()
                                                    .millisecondsSinceEpoch;
                                                String videoFileext =
                                                    p.extension(file.path);
                                                String videofileName =
                                                    'Video-$timeStamp$videoFileext';

                                                String? videoUrl =
                                                    await uploadSelectedLocalFileWithProgressIndicator(
                                                        file,
                                                        true,
                                                        false,
                                                        timeStamp,
                                                        filenameoptional:
                                                            videofileName);
                                                if (videoUrl != null) {
                                                  String? thumnailUrl =
                                                      await uploadSelectedLocalFileWithProgressIndicator(
                                                          thumnailFile,
                                                          false,
                                                          true,
                                                          timeStamp);
                                                  if (thumnailUrl != null) {
                                                    // onSendMessage(
                                                    // this.context,
                                                    // videoUrl +
                                                    //     '-BREAK-' +
                                                    //     thumnailUrl +
                                                    //     '-BREAK-' +
                                                    //     videometadata! +
                                                    //     '-BREAK-' +
                                                    //     videofileName,
                                                    // MessageType.video,
                                                    // timeStamp);

                                                    onSendMessage(
                                                      ticketName: ticketName,
                                                      departmentTitle:
                                                          departmentTitle,
                                                      agents: agents,
                                                      ticketfilteredID:
                                                          ticketfilteredID,
                                                      context: this.context,
                                                      content: videoUrl +
                                                          '-BREAK-' +
                                                          thumnailUrl +
                                                          '-BREAK-' +
                                                          videometadata! +
                                                          '-BREAK-' +
                                                          videofileName,
                                                      type: MessageType.video,
                                                    );
                                                    Utils.toast(
                                                        getTranslatedForCurrentUser(
                                                            this.context,
                                                            'xxsentxx'));
                                                    await file.delete();
                                                    await thumnailFile.delete();
                                                  }
                                                }
                                              }
                                            },
                                            file: File(file.path))));
                              } else {
                                Utils.toast(
                                    "${getTranslatedForCurrentUser(context, 'xxfiletypenotsupportedxx')} .mp4, .mov. \n\n ${getTranslatedForCurrentUser(context, 'xxselectedfilewasxx').replaceAll('(####)', fileExtension)} ");
                              }
                            }
                          },
                          elevation: .5,
                          fillColor: Colors.pink[600],
                          child: Icon(
                            Icons.video_collection_sharp,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          getTranslatedForCurrentUser(
                              this.context, 'xxvideoxx'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 14),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () async {
                            hidekeyboard(context);
                            Navigator.of(context).pop();

                            await Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) =>
                                        new CameraImageGalleryPicker(
                                          onTakeFile: (file) async {
                                            setStatusBarColor();
                                            if (observer
                                                    .checkIfCurrentUserIsDemo(
                                                        widget.currentUserID) ==
                                                true) {
                                              Utils.toast(
                                                  getTranslatedForCurrentUser(
                                                      context,
                                                      'xxxnotalwddemoxxaccountxx'));
                                            } else {
                                              int timeStamp = DateTime.now()
                                                  .millisecondsSinceEpoch;

                                              String? url =
                                                  await uploadSelectedLocalFileWithProgressIndicator(
                                                      file,
                                                      false,
                                                      false,
                                                      timeStamp);
                                              if (url != null) {
                                                // onSendMessage(this.context, url,
                                                //     MessageType.image, timeStamp);
                                                onSendMessage(
                                                    departmentTitle:
                                                        departmentTitle,
                                                    agents: agents,
                                                    ticketName: ticketName,
                                                    ticketfilteredID:
                                                        ticketfilteredID,
                                                    context: this.context,
                                                    content: url,
                                                    type: MessageType.image,
                                                    timestamp: timeStamp);
                                                await file.delete();
                                              }
                                            }
                                          },
                                        )));
                          },
                          elevation: .5,
                          fillColor: Colors.purple,
                          child: Icon(
                            Icons.image_rounded,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          getTranslatedForCurrentUser(
                              this.context, 'xximagexx'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(color: Colors.grey[700], fontSize: 14),
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: observer.checkIfCurrentUserIsDemo(
                                      widget.currentUserID) ==
                                  true
                              ? () {
                                  Utils.toast(getTranslatedForCurrentUser(
                                      context, 'xxxnotalwddemoxxaccountxx'));
                                }
                              : () {
                                  hidekeyboard(context);

                                  Navigator.of(context).pop();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AudioRecord(
                                                title:
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxrecordxx'),
                                                callback: getFileData,
                                              ))).then((url) {
                                    if (url != null) {
                                      // onSendMessage(
                                      //     context,
                                      //     url +
                                      //         '-BREAK-' +
                                      //         uploadTimestamp.toString(),
                                      //     MessageType.audio,
                                      //     uploadTimestamp);
                                      onSendMessage(
                                        departmentTitle: departmentTitle,
                                        agents: agents,
                                        ticketName: ticketName,
                                        ticketfilteredID: ticketfilteredID,
                                        context: this.context,
                                        content: url +
                                            '-BREAK-' +
                                            uploadTimestamp.toString(),
                                        type: MessageType.audio,
                                      );
                                    } else {}
                                  });
                                },
                          elevation: .5,
                          fillColor: Colors.yellow[900],
                          child: Icon(
                            Icons.mic_rounded,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          getTranslatedForCurrentUser(
                              this.context, 'xxaudioxx'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: observer.checkIfCurrentUserIsDemo(
                                      widget.currentUserID) ==
                                  true
                              ? () {
                                  Utils.toast(getTranslatedForCurrentUser(
                                      context, 'xxxnotalwddemoxxaccountxx'));
                                }
                              : () async {
                                  hidekeyboard(context);
                                  Navigator.of(context).pop();
                                  await checkIfLocationEnabled()
                                      .then((value) async {
                                    if (value == true) {
                                      Utils.toast(getTranslatedForCurrentUser(
                                          this.context, 'xxdetectinglocxx'));
                                      await _determinePosition().then(
                                        (location) async {
                                          var locationstring =
                                              'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
                                          onSendMessage(
                                            departmentTitle: departmentTitle,
                                            agents: agents,
                                            ticketName: ticketName,
                                            ticketfilteredID: ticketfilteredID,
                                            context: this.context,
                                            content: locationstring,
                                            type: MessageType.location,
                                          );
                                          setStateIfMounted(() {});
                                          Utils.toast(
                                            getTranslatedForCurrentUser(
                                                this.context, 'xxsentxx'),
                                          );
                                        },
                                      );
                                    } else {
                                      Utils.toast(
                                          "Kindly allow location permission !");
                                      openAppSettings();
                                    }
                                  });
                                },
                          elevation: .5,
                          fillColor: Colors.cyan[700],
                          child: Icon(
                            Icons.location_on,
                            size: 25.0,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          getTranslatedForCurrentUser(
                              this.context, 'xxlocationxx'),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                  )
                ],
              ),
            ]),
          );
        });
  }

  Future<bool> onWillPop() {
    if (isemojiShowing == true) {
      setStateIfMounted(() {
        isemojiShowing = false;
      });
      Future.value(false);
    } else {
      setLastSeen(true, isemojiShowing);
      return Future.value(true);
    }
    return Future.value(false);
  }

  bool isemojiShowing = false;
  refreshInput() {
    setStateIfMounted(() {
      if (isemojiShowing == false) {
        keyboardFocusNode.unfocus();
        isemojiShowing = true;
      } else {
        isemojiShowing = false;
        keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    var observer = Provider.of<Observer>(context, listen: true);
    return PickupLayout(
        curentUserID: widget.currentUserID,
        prefs: widget.prefs,
        scaffold: Utils.getNTPWrappedWidget(WillPopScope(
          onWillPop: isgeneratingSomethingLoader == true
              ? () async {
                  return Future.value(false);
                }
              : isemojiShowing == true
                  ? () {
                      setStateIfMounted(() {
                        isemojiShowing = false;
                        keyboardFocusNode.unfocus();
                      });
                      return Future.value(false);
                    }
                  : () async {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        var currentpeer = Provider.of<CurrentChatPeer>(
                            this.context,
                            listen: false);
                        currentpeer.setpeer('');
                      });
                      setLastSeen(false, false);

                      return Future.value(true);
                    },
          child: Stack(
            children: [
              StreamBuilder(
                  stream: streamTicketSnapshots,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data.exists) {
                      TicketModel liveTicketData =
                          TicketModel.fromSnapshot(snapshot.data);
                      return Scaffold(
                          key: _scaffold,
                          appBar:
                              //  PreferredSize(
                              //     preferredSize: Size.fromHeight(
                              //         100.0), // here the desired height
                              //     child:
                              widget.customerUID == widget.currentUserID
                                  ? ticketAppBarforCustomers(
                                      widget.prefs,
                                      context,
                                      liveTicketData,
                                      () {
                                        onPressMenu(
                                            context,
                                            liveTicketData.ticketcosmeticID,
                                            observer,
                                            widget.currentUserID ==
                                                widget.customerUID,
                                            liveTicketData,
                                            widget.currentUserID,
                                            _keyLoader,
                                            widget.customerUID,
                                            widget.ticketID,
                                            attentionMessageController,
                                            widget.prefs);
                                      },
                                      observer,
                                      widget.currentUserID,
                                      () {
                                        setLastSeen(true, isemojiShowing);
                                      })
                                  : observer.userAppSettingsDoc!
                                              .showIsCustomerOnline ==
                                          false
                                      ? ticketAppBarforAgentsUsingRegistry(
                                          widget.prefs,
                                          observer,
                                          context,
                                          liveTicketData,
                                          () {
                                            onPressMenu(
                                                context,
                                                liveTicketData.ticketcosmeticID,
                                                observer,
                                                widget.currentUserID ==
                                                    widget.customerUID,
                                                liveTicketData,
                                                widget.currentUserID,
                                                _keyLoader,
                                                widget.customerUID,
                                                widget.ticketID,
                                                attentionMessageController,
                                                widget.prefs);
                                          },
                                          isSecretChat,
                                          widget.currentUserID,
                                          () {
                                            setLastSeen(true, isemojiShowing);
                                          })
                                      : PreferredSize(
                                          preferredSize: Size.fromHeight(isSecretChat ||
                                                  liveTicketData.ticketStatus ==
                                                      TicketStatus
                                                          .needsAttention
                                                          .index ||
                                                  liveTicketData.ticketStatus ==
                                                      TicketStatus
                                                          .waitingForAgentsToJoinTicket
                                                          .index ||
                                                  liveTicketData.ticketStatus ==
                                                      TicketStatus.closedByAgent
                                                          .index ||
                                                  liveTicketData.ticketStatus ==
                                                      TicketStatus
                                                          .closedByCustomer
                                                          .index ||
                                                  liveTicketData.ticketStatus ==
                                                      TicketStatus
                                                          .mediaAutoDeleted
                                                          .index ||
                                                  liveTicketData.ticketStatus ==
                                                      TicketStatus
                                                          .canWeCloseByAgent
                                                          .index ||
                                                  liveTicketData.ticketStatus ==
                                                      TicketStatus
                                                          .canWeCloseByCustomer
                                                          .index
                                              ? AppBar().preferredSize.height +
                                                  30.0
                                              : AppBar().preferredSize.height +
                                                  3), // here the desired height
                                          child: streamLoad(
                                              stream: customerLiveSnapshots,
                                              placeholder:
                                                  ticketAppBarforAgentsUsingRegistry(
                                                      widget.prefs,
                                                      observer,
                                                      context,
                                                      liveTicketData,
                                                      () {
                                                        onPressMenu(
                                                            context,
                                                            liveTicketData
                                                                .ticketcosmeticID,
                                                            observer,
                                                            widget.currentUserID ==
                                                                widget
                                                                    .customerUID,
                                                            liveTicketData,
                                                            widget
                                                                .currentUserID,
                                                            _keyLoader,
                                                            widget.customerUID,
                                                            widget.ticketID,
                                                            attentionMessageController,
                                                            widget.prefs);
                                                      },
                                                      isSecretChat,
                                                      widget.currentUserID,
                                                      () {
                                                        setLastSeen(true,
                                                            isemojiShowing);
                                                      }),
                                              onfetchdone: (customerMap) {
                                                CustomerModel liveCustomerData =
                                                    CustomerModel.fromJson(
                                                        customerMap);
                                                return ticketAppBarforAgentsUsingRealtimeCustomerData(
                                                    widget.prefs,
                                                    context,
                                                    liveTicketData,
                                                    liveCustomerData,
                                                    observer,
                                                    () {
                                                      onPressMenu(
                                                          context,
                                                          liveTicketData
                                                              .ticketcosmeticID,
                                                          observer,
                                                          widget.currentUserID ==
                                                              widget
                                                                  .customerUID,
                                                          liveTicketData,
                                                          widget.currentUserID,
                                                          _keyLoader,
                                                          widget.customerUID,
                                                          widget.ticketID,
                                                          attentionMessageController,
                                                          widget.prefs);
                                                    },
                                                    widget.currentUserID,
                                                    isSecretChat,
                                                    () {
                                                      setLastSeen(
                                                          true, isemojiShowing);
                                                    });
                                              }
                                              // )
                                              ),
                                        ),
                          body: Stack(children: <Widget>[
                            new Container(
                              decoration: new BoxDecoration(
                                color: Mycolors.chatbackground,
                                image: new DecorationImage(
                                    image: AssetImage(isSecretChat == true
                                        ? "assets/images/background_dark.jpeg"
                                        : "assets/images/background.png"),
                                    fit: BoxFit.cover),
                              ),
                            ),
                            PageView(children: <Widget>[
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                        child: isPreLoading == true
                                            ? circularProgress()
                                            : buildMessagesUsingProvider(
                                                context, liveTicketData)),
                                    liveTicketData.ticketStatusShort ==
                                                TicketStatusShort.close.index ||
                                            liveTicketData.ticketStatusShort ==
                                                TicketStatusShort.expired.index
                                        ?
                                        //--when closed
                                        widget.currentUserID ==
                                                widget.customerUID
                                            //--customer
                                            ? observer.userAppSettingsDoc!.customerCanRateTicket == true &&
                                                    liveTicketData.rating == 0
                                                ? rateTicketByCustomer(
                                                    context: context,
                                                    currentUserID:
                                                        widget.customerUID,
                                                    customerUID:
                                                        widget.customerUID,
                                                    observer: observer,
                                                    liveTicketData:
                                                        liveTicketData,
                                                    onUpdaterating: (r) {
                                                      setStateIfMounted(() {
                                                        finalrating = r;
                                                      });
                                                    },
                                                    textEditingController:
                                                        textEditingController,
                                                    keyloader: _keyLoader225645,
                                                    finalrating: finalrating,
                                                    ticketID: widget.ticketID)
                                                : TicketUtils.isReopenAllowedForUserType(context, liveTicketData.ticketClosedOn!, Usertype.customer.index) ==
                                                        true
                                                    ? reopenWidget(context)
                                                    : mediadeletenotificationWidget(
                                                        context)
                                            : TicketUtils.isReopenAllowedForUserType(context, liveTicketData.ticketClosedOn!, Usertype.customer.index) ==
                                                    true
                                                ? reopenWidget(context)
                                                : mediadeletenotificationWidget(
                                                    context)
                                        : widget.customerUID == widget.currentUserID &&
                                                liveTicketData.ticketStatus ==
                                                    TicketStatus
                                                        .canWeCloseByAgent.index
                                            ? closeTicketAction(
                                                currentUserID:
                                                    widget.currentUserID,
                                                liveTicketModel: liveTicketData,
                                                ticketID: widget.ticketID,
                                                context: context,
                                                observer: observer,
                                                isActionShownToCustomer: true)
                                            : widget.customerUID != widget.currentUserID &&
                                                    liveTicketData.ticketStatus ==
                                                        TicketStatus.canWeCloseByCustomer.index
                                                ? closeTicketAction(currentUserID: widget.currentUserID, liveTicketModel: liveTicketData, ticketID: widget.ticketID, context: context, observer: observer, isActionShownToCustomer: false)
                                                : widget.customerUID == widget.currentUserID
                                                    ? buildInputForCustomer(context, isemojiShowing, refreshInput, _keyboardVisible, liveTicketData.ticketTitle, liveTicketData.ticketidFiltered, liveTicketData.tktdepartmentNameList[0], liveTicketData.tktMEMBERSactiveList)
                                                    : buildInputForAgent(context, isemojiShowing, refreshInput, _keyboardVisible, liveTicketData.ticketTitle, liveTicketData.ticketidFiltered, liveTicketData.tktdepartmentNameList[0], liveTicketData.tktMEMBERSactiveList)
                                  ])
                            ]),
                          ]));
                    }
                    return Scaffold(
                      backgroundColor: Mycolors.chatbackground,
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }),
              buildLoadingThumbnail()
            ],
          ),
        )));
  }

  // Widget selectablelinkify(
  //     String? text, double? fontsize, TextAlign? textalign) {
  //   return SelectableLinkify(
  //     style: TextStyle(
  //         fontSize: fontsize,
  //         color: Colors.black87,
  //         height: 1.3,
  //         fontStyle: FontStyle.normal),
  //     text: text ?? "",
  //     textAlign: textalign,
  //     onOpen: (link) async {
  //       if (1 == 1) {
  //         await custom_url_launcher(link.url);
  //       } else {
  //         throw 'Could not launch $link';
  //       }
  //     },
  //   );
  // }

  Widget selectablelinkify(
      String? text, double? fontsize, TextAlign? textalign) {
    bool _validURL = false;
    try {
      _validURL = text!.contains("http") || text.contains("https");
    } catch (e) {
      print(e);
    }

    return _validURL == false
        ? SelectableLinkify(
            style: TextStyle(fontSize: fontsize, color: Colors.black87),
            text: text!,
            onOpen: (link) async {
              custom_url_launcher(link.url);
            },
          )
        : LinkPreviewGenerator(
            removeElevation: true,
            graphicFit: BoxFit.contain,
            borderRadius: 5,
            showDomain: true,
            titleStyle: TextStyle(
                fontSize: 13, height: 1.4, fontWeight: FontWeight.bold),
            showBody: true,
            bodyStyle: TextStyle(fontSize: 11.6, color: Colors.black45),
            placeholderWidget: SelectableLinkify(
              textAlign: textalign,
              style: TextStyle(fontSize: fontsize, color: Colors.black87),
              text: text!,
              onOpen: (link) async {
                custom_url_launcher(link.url);
              },
            ),
            errorWidget: SelectableLinkify(
              style: TextStyle(fontSize: fontsize, color: Colors.black87),
              text: "",
              textAlign: textalign,
              onOpen: (link) async {
                custom_url_launcher(link.url);
              },
            ),
            link: text,
            linkPreviewStyle: LinkPreviewStyle.large,
          );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      setLastSeen(false, false);
    else
      setLastSeen(false, false);
  }
}

deletedGroupWidget(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      elevation: 0.4,
    ),
    body: Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text(
            getTranslatedForCurrentUser(context, 'xxdeletedgroupxx'),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
