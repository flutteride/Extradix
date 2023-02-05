//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/optional_constants.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/groupchat/GroupDetails.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/groupchat/groupChatBubble.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/chat.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/utils/uploadMediaWithProgress.dart';
import 'package:thinkcreative_technologies/Services/Admob/admob.dart';
import 'package:thinkcreative_technologies/Services/Providers/GroupChatProvider.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Utils/custom_url_launcher.dart';
import 'package:thinkcreative_technologies/Utils/mime_type.dart';
import 'package:thinkcreative_technologies/Utils/setStatusBarColor.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/widgets/AllinOneCameraGalleryImageVideoPicker/AllinOneCameraGalleryImageVideoPicker.dart';
import 'package:thinkcreative_technologies/widgets/CameraGalleryImagePicker/camera_image_gallery_picker.dart';
import 'package:thinkcreative_technologies/widgets/CameraGalleryImagePicker/multiMediaPicker.dart';
import 'package:thinkcreative_technologies/widgets/CustomAlertDialog/CustomDialog.dart';
import 'package:thinkcreative_technologies/widgets/DownloadManager/download_all_file_type.dart';
import 'package:thinkcreative_technologies/widgets/InfiniteList/InfiniteCOLLECTIONListViewWidget.dart';
import 'package:thinkcreative_technologies/widgets/MultiDocumentPicker/multiDocumentPicker.dart';
import 'package:thinkcreative_technologies/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custominput.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
import 'package:thinkcreative_technologies/widgets/SoundPlayer/SoundPlayerPro.dart';
import 'package:thinkcreative_technologies/Services/Providers/currentchat_peer.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/callhistory.dart';
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
import 'package:video_compress/video_compress.dart' as compress;
import 'package:path/path.dart' as p;

class GroupChatPage extends StatefulWidget {
  final String currentUserno;
  final String groupID;
  final int joinedTime;
  final DataModel model;
  final SharedPreferences prefs;
  final List<SharedMediaFile>? sharedFiles;
  final MessageType? sharedFilestype;
  final bool isSharingIntentForwarded;
  final String? sharedText;
  final bool isCurrentUserMuted;
  GroupChatPage({
    Key? key,
    required this.currentUserno,
    required this.groupID,
    required this.joinedTime,
    required this.model,
    required this.prefs,
    required this.isSharingIntentForwarded,
    required this.isCurrentUserMuted,
    this.sharedFiles,
    this.sharedFilestype,
    this.sharedText,
  }) : super(key: key);

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage>
    with WidgetsBindingObserver {
  bool isgeneratingSomethingLoader = false;
  int tempSendIndex = 0;
  late String messageReplyOwnerName;
  late Stream<QuerySnapshot> groupChatMessages;
  final TextEditingController reportEditingController =
      new TextEditingController();
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
  bool isCurrentUserMuted = false;
  @override
  void initState() {
    super.initState();
    isCurrentUserMuted = widget.isCurrentUserMuted;
    firestoreChatquery = FirebaseFirestore.instance
        .collection(DbPaths.collectionAgentGroups)
        .doc(widget.groupID)
        .collection(DbPaths.collectiongroupChats)
        .where(Dbkeys.groupmsgTIME, isGreaterThanOrEqualTo: widget.joinedTime)
        .orderBy(Dbkeys.groupmsgTIME, descending: true)
        .limit(maxChatMessageDocsLoadAtOnce);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var currentpeer =
          Provider.of<CurrentChatPeer>(this.context, listen: false);
      var firestoreProvider =
          Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(this.context,
              listen: false);
      final observer = Provider.of<Observer>(this.context, listen: false);
      firestoreProvider.reset();
      Future.delayed(const Duration(milliseconds: 1700), () {
        loadMessagesAndListen();

        currentpeer.setpeer(widget.groupID
            .replaceAll(RegExp('-'), '')
            .substring(1,
                widget.groupID.replaceAll(RegExp('-'), '').toString().length));

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
    setStatusBarColor();
  }

  // ignore: cancel_subscriptions
  StreamSubscription<QuerySnapshot>? subscription;
  loadMessagesAndListen() async {
    subscription = firestoreChatquery.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          var chatprovider =
              Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(
                  this.context,
                  listen: false);
          DocumentSnapshot newDoc = change.doc;

          chatprovider.addDoc(newDoc);
        } else if (change.type == DocumentChangeType.modified) {
          var chatprovider =
              Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(
                  this.context,
                  listen: false);
          DocumentSnapshot updatedDoc = change.doc;
          if (chatprovider.checkIfDocAlreadyExits(
                  newDoc: updatedDoc,
                  timestamp: updatedDoc[Dbkeys.groupmsgTIME]) ==
              true) {
            chatprovider.updateparticulardocinProvider(updatedDoc: updatedDoc);
          }
        } else if (change.type == DocumentChangeType.removed) {
          var chatprovider =
              Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(
                  this.context,
                  listen: false);
          DocumentSnapshot deletedDoc = change.doc;
          if (chatprovider.checkIfDocAlreadyExits(
                  newDoc: deletedDoc,
                  timestamp: deletedDoc[Dbkeys.groupmsgTIME]) ==
              true) {
            chatprovider.deleteparticulardocinProvider(deletedDoc: deletedDoc);
          }
        }
      });
    });

    setStateIfMounted(() {});

//       //----sharing intent action:
    if (widget.isSharingIntentForwarded == true) {
      if (widget.sharedText != null) {
        onSendMessage(
            context: this.context,
            content: widget.sharedText!,
            type: MessageType.text,
            timestamp: DateTime.now().millisecondsSinceEpoch);
      } else if (widget.sharedFiles != null) {
        setStateIfMounted(() {
          isgeneratingSomethingLoader = true;
        });
        uploadEach(0);
      }
    }
  }

  int currentUploadingIndex = 0;

  uploadEach(
    int index,
  ) async {
    File file = new File(widget.sharedFiles![index].path);
    String fileName = file.path.split('/').last.toLowerCase();

    if (index >= widget.sharedFiles!.length) {
      setStateIfMounted(() {
        isgeneratingSomethingLoader = false;
      });
    } else {
      int messagetime = DateTime.now().millisecondsSinceEpoch;
      setState(() {
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
              : fileName.contains('.mp4') || fileName.contains('.mov')
                  ? MessageType.video
                  : fileName.contains('.mp3') || fileName.contains('.aac')
                      ? MessageType.audio
                      : MessageType.doc;
          String? thumbnailurl;
          if (type == MessageType.video) {
            thumbnailurl = await getThumbnail(imageUrl);
            print('THUMNBNAIL URL::::: ' + thumbnailurl!);
            setStateIfMounted(() {});
          }

          String finalUrl = fileName.contains('.png') ||
                  fileName.contains('.gif') ||
                  fileName.contains('.jpg') ||
                  fileName.contains('.jpeg') ||
                  fileName.contains('giphy')
              ? imageUrl
              : fileName.contains('.mp4') || fileName.contains('.mov')
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
              context: this.context,
              content: finalUrl,
              type: type,
              timestamp: messagetime);
        }
      }).then((value) {
        if (widget.sharedFiles!.last == widget.sharedFiles![index]) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = false;
          });
        } else {
          uploadEach(currentUploadingIndex + 1);
        }
      });
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  setLastSeen(bool iswillpop, isemojikeyboardopen) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionAgentGroups)
        .doc(widget.groupID)
        .update(
      {
        widget.currentUserno: DateTime.now().millisecondsSinceEpoch,
      },
    );
    setStatusBarColor();
    if (iswillpop == true && isemojikeyboardopen == false) {
      Navigator.of(this.context).pop();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    setLastSeen(false, isemojiShowing);
    subscription!.cancel();
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

  getFileName(groupid, timestamp) {
    return "${widget.currentUserno}-$timestamp";
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
        widget.groupID,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_GROUP_MEDIA/${widget.groupID}/")
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
        Utils.toast(getTranslatedForCurrentUser(this.context, 'xxfailedxx'));
        print('ERROR SENDING MEDIA: $onError');
      });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionagents)
          .doc(widget.currentUserno)
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

  Future uploadFileWithProgressIndicator(
    bool isthumbnail, {
    int? timestamp,
  }) async {
    uploadTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

    String fileName = getFileName(
        widget.currentUserno,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_GROUP_MEDIA/${widget.groupID}/")
        .child(fileName);

    File fileToCompress;
    File? compressedImage;

    if (isthumbnail == false && isVideo(pickedFile!.path) == true) {
      fileToCompress = File(pickedFile!.path);
      await compress.VideoCompress.setLogLevel(0);

      final compress.MediaInfo? info =
          await compress.VideoCompress.compressVideo(
        fileToCompress.path,
        quality: IsVideoQualityCompress == true
            ? compress.VideoQuality.MediumQuality
            : compress.VideoQuality.HighestQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      pickedFile = File(info!.path!);
    } else if (isthumbnail == false && isImage(pickedFile!.path) == true) {
      final targetPath = pickedFile!.absolute.path
              .replaceAll(basename(pickedFile!.absolute.path), "") +
          "temp.jpg";

      compressedImage = await FlutterImageCompress.compressAndGetFile(
        pickedFile!.absolute.path,
        targetPath,
        quality: ImageQualityCompress,
        rotate: 0,
      );
    } else {}

    UploadTask uploading = reference.putFile(isthumbnail == true
        ? thumbnailFile!
        : isImage(pickedFile!.path) == true
            ? compressedImage!
            : pickedFile!);

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
          .doc(widget.currentUserno)
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
    // String fileName = getFileName(widget.currentUserno,
    //     isthumbnail == false ? '$timeEpoch' : '${timeEpoch}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_GROUP_MEDIA/${widget.groupID}/")
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
        Utils.toast(getTranslatedForCurrentUser(this.context, 'xxfailedxx'));
        print('ERROR SENDING FILE: $onError');
      });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionagents)
          .doc(widget.currentUserno)
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

  void onSendMessage(
      {required BuildContext context,
      required String content,
      required MessageType type,
      int? timestamp,
      bool? isForward = false}) async {
    final observer = Provider.of<Observer>(this.context, listen: false);

    final List<GroupModel> groupList =
        Provider.of<List<GroupModel>>(context, listen: false);
    // var chatprovider = Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(
    //     this.context,
    //     listen: false);
    Map<dynamic, dynamic> groupDoc = groupList.indexWhere(
                (element) => element.docmap[Dbkeys.groupID] == widget.groupID) <
            0
        ? {}
        : groupList
            .lastWhere(
                (element) => element.docmap[Dbkeys.groupID] == widget.groupID)
            .docmap;
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    if (content.trim() != '') {
      content = content.trim();
      textEditingController.clear();
      FirebaseFirestore.instance
          .collection(DbPaths.collectionAgentGroups)
          .doc(widget.groupID)
          .collection(DbPaths.collectiongroupChats)
          .doc(timestamp.toString() + '--' + widget.currentUserno)
          .set({
        Dbkeys.groupmsgCONTENT: content,
        Dbkeys.deletedReason: '',
        Dbkeys.groupmsgISDELETED: false,
        Dbkeys.groupmsgLISToptional: [],
        Dbkeys.groupmsgTIME: timestamp,
        Dbkeys.groupmsgSENDBY: widget.currentUserno,
        Dbkeys.groupmsgISDELETED: false,
        Dbkeys.groupmsgTYPE: type.index,
        Dbkeys.groupNAME: groupDoc[Dbkeys.groupNAME],
        Dbkeys.groupID: groupDoc[Dbkeys.groupNAME],
        Dbkeys.sendername: widget.model.currentUser![Dbkeys.nickname],
        Dbkeys.groupIDfiltered: groupDoc[Dbkeys.groupIDfiltered],
        Dbkeys.isReply: isReplyKeyboard,
        Dbkeys.replyToMsgDoc: replyDoc,
        Dbkeys.deletedType: "",
        Dbkeys.deletedReason: "",
        Dbkeys.isForward: isForward
      }, SetOptions(merge: true));

      unawaited(realtime.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut));
      // _playPopSound();
      FirebaseFirestore.instance
          .collection(DbPaths.collectionAgentGroups)
          .doc(widget.groupID)
          .update(
        {Dbkeys.groupLATESTMESSAGETIME: timestamp},
      );
      setStateIfMounted(() {
        isReplyKeyboard = false;
        replyDoc = null;
      });
      setStatusBarColor();
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

  final TextEditingController textEditingController =
      new TextEditingController();
  FocusNode keyboardFocusNode = new FocusNode();
  Widget buildInputAndroid(BuildContext context, bool isemojiShowing,
      Function refreshThisInput, bool keyboardVisible) {
    final observer = Provider.of<Observer>(context, listen: true);

    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
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
                        color: Mycolors.white,
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
                            onTap: () {
                              if (isemojiShowing == true) {
                              } else {
                                keyboardFocusNode.requestFocus();
                                setStateIfMounted(() {});
                              }
                            },
                            onChanged: (f) {
                              if (textEditingController.text.isNotEmpty &&
                                  textEditingController.text.length == 1) {
                                setStateIfMounted(() {});
                              }
                              setStateIfMounted(() {});
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
                        Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                            width: textEditingController.text.isNotEmpty
                                ? 10
                                : 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                                      shareMedia(context);
                                                    },
                                          color: Mycolors.white,
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
                                                      await Navigator.push(
                                                          context,
                                                          new MaterialPageRoute(
                                                              builder: (context) =>
                                                                  new AllinOneCameraGalleryImageVideoPicker(
                                                                    onTakeFile: (file,
                                                                        isVideo,
                                                                        thumnail) async {
                                                                      setStatusBarColor();
                                                                      if (observer
                                                                              .checkIfCurrentUserIsDemo(widget.currentUserno) ==
                                                                          true) {
                                                                        Utils.toast(getTranslatedForCurrentUser(
                                                                            context,
                                                                            'xxxnotalwddemoxxaccountxx'));
                                                                      } else {
                                                                        int timeStamp =
                                                                            DateTime.now().millisecondsSinceEpoch;
                                                                        if (isVideo ==
                                                                            true) {
                                                                          int timeStamp =
                                                                              DateTime.now().millisecondsSinceEpoch;
                                                                          String
                                                                              videoFileext =
                                                                              p.extension(file.path);
                                                                          String
                                                                              videofileName =
                                                                              'Video-$timeStamp$videoFileext';
                                                                          String? videoUrl = await uploadSelectedLocalFileWithProgressIndicator(
                                                                              file,
                                                                              true,
                                                                              false,
                                                                              timeStamp,
                                                                              filenameoptional: videofileName);
                                                                          if (videoUrl !=
                                                                              null) {
                                                                            String? thumnailUrl = await uploadSelectedLocalFileWithProgressIndicator(
                                                                                thumnail!,
                                                                                false,
                                                                                true,
                                                                                timeStamp);
                                                                            if (thumnailUrl !=
                                                                                null) {
                                                                              onSendMessage(context: this.context, content: videoUrl + '-BREAK-' + thumnailUrl + '-BREAK-' + videometadata! + '-BREAK-' + videofileName, type: MessageType.video, timestamp: timeStamp);
                                                                              file.delete();
                                                                              thumnail.delete();
                                                                            }
                                                                          }
                                                                        } else {
                                                                          String
                                                                              imageFileext =
                                                                              p.extension(file.path);
                                                                          String
                                                                              imagefileName =
                                                                              'IMG-$timeStamp$imageFileext';
                                                                          String? url = await uploadSelectedLocalFileWithProgressIndicator(
                                                                              file,
                                                                              false,
                                                                              false,
                                                                              timeStamp,
                                                                              filenameoptional: imagefileName);
                                                                          if (url !=
                                                                              null) {
                                                                            onSendMessage(
                                                                                context: this.context,
                                                                                content: url,
                                                                                type: MessageType.image,
                                                                                timestamp: timeStamp);
                                                                            file.delete();
                                                                          }
                                                                        }
                                                                      }
                                                                    },
                                                                  )));
                                                    },
                                          color: Mycolors.white,
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
                                            color: Mycolors.white,
                                            padding: EdgeInsets.all(0.0),
                                            icon: Icon(
                                              Icons.gif_rounded,
                                              size: 40,
                                              color: Mycolors.grey,
                                            ),
                                            onPressed: observer
                                                        .checkIfCurrentUserIsDemo(
                                                            widget
                                                                .currentUserno) ==
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
                                                              .agentPrimary,
                                                          context: context,
                                                          apiKey:
                                                              GiphyAPIKey, //YOUR API KEY HERE
                                                          lang: GiphyLanguage
                                                              .english,
                                                        );
                                                        if (gif != null &&
                                                            mounted) {
                                                          onSendMessage(
                                                            context: context,
                                                            content: gif.images!
                                                                .original!.url,
                                                            type: MessageType
                                                                .image,
                                                          );
                                                          hidekeyboard(context);
                                                          setStateIfMounted(
                                                              () {});
                                                        }
                                                      }),
                                      ),
                              ],
                            ))
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
                      color: Mycolors.agentSecondary,
                      // border: Border.all(
                      //   color: Colors.red[500],
                      // ),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: IconButton(
                      icon: new Icon(
                        textEditingController.text.isNotEmpty == true
                            ? Icons.send
                            : Icons.mic,
                        color: Mycolors.white.withOpacity(0.99),
                      ),
                      onPressed: observer.checkIfCurrentUserIsDemo(
                                  widget.currentUserno) ==
                              true
                          ? () {
                              Utils.toast(getTranslatedForCurrentUser(
                                  context, 'xxxnotalwddemoxxaccountxx'));
                            }
                          : observer.ismediamessagingallowed == true
                              ? textEditingController.text.isNotEmpty == false
                                  ? () {
                                      hidekeyboard(context);

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
                                          onSendMessage(
                                            context: context,
                                            content: url +
                                                '-BREAK-' +
                                                uploadTimestamp.toString(),
                                            type: MessageType.audio,
                                          );
                                        } else {}
                                      });
                                    }
                                  : observer.istextmessagingallowed == false
                                      ? () {
                                          Utils.showRationale(
                                              getTranslatedForCurrentUser(
                                                  this.context,
                                                  'xxtextmssgnotallowedxx'));
                                        }
                                      : () => onSendMessage(
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
                      color: Mycolors.white,
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
                            indicatorColor: Mycolors.agentPrimary,
                            iconColor: Colors.grey,
                            iconColorSelected: Mycolors.agentPrimary,
                            progressIndicatorColor: Colors.blue,
                            backspaceColor: Mycolors.agentPrimary,
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
              color: Mycolors.white,
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
                        color: replyDoc![Dbkeys.groupmsgSENDBY] ==
                                widget.currentUserno
                            ? Mycolors.agentPrimary
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
                              replyDoc![Dbkeys.groupmsgSENDBY] ==
                                      widget.currentUserno
                                  ? getTranslatedForCurrentUser(
                                      this.context, 'xxyouxx')
                                  : messageReplyOwnerName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: replyDoc![Dbkeys.groupmsgSENDBY] ==
                                          widget.currentUserno
                                      ? Mycolors.agentPrimary
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
                                        Mycolors.loadingindicator),
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
                                                    Mycolors.loadingindicator,
                                                  ),
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

  buildEachMessage(Map<String, dynamic> doc, GroupModel groupData) {
    if (doc[Dbkeys.groupmsgTYPE] == Dbkeys.groupmsgTYPEnotificationAddedUser) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgLISToptional].contains(widget.currentUserno) &&
                  doc[Dbkeys.groupmsgLISToptional].length > 1
              ? doc[Dbkeys.groupmsgLISToptional]
                      .contains(groupData.docmap[Dbkeys.groupCREATEDBY])
                  ? widget.currentUserno ==
                          groupData.docmap[Dbkeys.groupCREATEDBY]
                      ? '${getTranslatedForCurrentUser(this.context, 'xxuhaveaddedxx')} ${doc[Dbkeys.groupmsgLISToptional].length - 1} ${getTranslatedForCurrentUser(this.context, 'xxagentsxx')} '
                      : '${getTranslatedForCurrentUser(this.context, 'xxadminahasaddedxx')} ${getTranslatedForCurrentUser(this.context, 'xxyouandotherxx')} ${doc[Dbkeys.groupmsgLISToptional].length - 1} ${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}'
                  : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslatedForCurrentUser(this.context, 'xxaddedxx')} ${getTranslatedForCurrentUser(this.context, 'xxyouandotherxx')} ${doc[Dbkeys.groupmsgLISToptional].length - 1} ${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}'
              : doc[Dbkeys.groupmsgLISToptional]
                          .contains(widget.currentUserno) &&
                      doc[Dbkeys.groupmsgLISToptional].length == 1
                  ? '${getTranslatedForCurrentUser(this.context, 'xxyouareaddedtothisgrpxx')}'
                  : !doc[Dbkeys.groupmsgLISToptional]
                              .contains(widget.currentUserno) &&
                          doc[Dbkeys.groupmsgLISToptional].length == 1
                      ? doc[Dbkeys.groupmsgSENDBY] ==
                              groupData.docmap[Dbkeys.groupCREATEDBY]
                          ? widget.currentUserno ==
                                  groupData.docmap[Dbkeys.groupCREATEDBY]
                              ? '${getTranslatedForCurrentUser(this.context, 'xxuhaveaddedxx')} ${doc[Dbkeys.groupmsgLISToptional][0]}'
                              : '${getTranslatedForCurrentUser(this.context, 'xxadminhasaddedxx')} ${doc[Dbkeys.groupmsgLISToptional][0]}'
                          : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslatedForCurrentUser(this.context, 'xxadminhasaddedxx')} ${doc[Dbkeys.groupmsgLISToptional][0]}'
                      : doc[Dbkeys.groupmsgSENDBY] ==
                              groupData.docmap[Dbkeys.groupCREATEDBY]
                          ? '${getTranslatedForCurrentUser(this.context, 'xxadminahasaddedxx')} ${doc[Dbkeys.groupmsgLISToptional].length} ${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}'
                          : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslatedForCurrentUser(this.context, 'xxaddedxx')} ${doc[Dbkeys.groupmsgLISToptional].length} ${getTranslatedForCurrentUser(this.context, 'xxagentsxx')}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationCreatedGroup) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          groupData.docmap[Dbkeys.groupCREATEDBY].contains(widget.currentUserno)
              ? getTranslatedForCurrentUser(
                  this.context, 'xxyoucreatedthisgroupxx')
              : '${groupData.docmap[Dbkeys.groupCREATEDBY]} ${getTranslatedForCurrentUser(this.context, 'xxhascreatedthisgroupxx')}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUpdatedGroupDetails) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
              ? getTranslatedForCurrentUser(
                  this.context, 'xxuhvupdatedgrpdetailsxx')
              : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslatedForCurrentUser(this.context, 'xxhasupdatedgrpdetailsxx')}'
                      .contains(groupData.docmap[Dbkeys.groupCREATEDBY])
                  ? getTranslatedForCurrentUser(
                      this.context, 'xxgrpdetailsupdatebyadminxx')
                  : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslatedForCurrentUser(this.context, 'xxhasupdatedgrpdetailsxx')}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUserSetAsAdmin) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
              ? '${doc[Dbkeys.groupmsgLISToptional][0]} ${getTranslatedForCurrentUser(this.context, 'xxhasbeensetasadminbyuxx')}'
              : doc[Dbkeys.groupmsgLISToptional][0] == widget.currentUserno
                  ? '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslatedForCurrentUser(this.context, 'xxhvsetuasadsminxx')}'
                  : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslatedForCurrentUser(this.context, 'xxsetxx')} ${doc[Dbkeys.groupmsgLISToptional][0]} ${getTranslatedForCurrentUser(this.context, 'xxasadminxx')}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUserRemovedAsAdmin) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
              ? '${getTranslatedForCurrentUser(this.context, 'xxyouhaveremovedxx')} ${doc[Dbkeys.groupmsgLISToptional][0]} ${getTranslatedForCurrentUser(this.context, 'xxfromadminxx')}'
              : doc[Dbkeys.groupmsgLISToptional][0] == widget.currentUserno
                  ? '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslatedForCurrentUser(this.context, 'xxtheyremoveduasadminxx')}'
                  : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslatedForCurrentUser(this.context, 'xxhasremovedxx')} ${doc[Dbkeys.groupmsgLISToptional][0]} ${getTranslatedForCurrentUser(this.context, 'xxfromadminxx')}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUpdatedGroupicon) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
              ? getTranslatedForCurrentUser(
                  this.context, 'xxyouupdatedgrpiconxx')
              : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslatedForCurrentUser(this.context, 'xxhasupdatedgrpiconxx')}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationDeletedGroupicon) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
              ? getTranslatedForCurrentUser(
                  this.context, 'xxyouremovedgrpiconxx')
              : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslatedForCurrentUser(this.context, 'xxhasremovedgrpiconxx')}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationRemovedUser) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgCONTENT].contains('by ' + widget.currentUserno)
              ? '${getTranslatedForCurrentUser(this.context, 'xxyouhaveremovedxx')} ${doc[Dbkeys.groupmsgLISToptional][0]}'
              : doc[Dbkeys.groupmsgSENDBY] ==
                      groupData.docmap[Dbkeys.groupCREATEDBY]
                  ? '${doc[Dbkeys.groupmsgLISToptional][0]} ${getTranslatedForCurrentUser(this.context, 'xxremovedbyadminxx')}'
                  : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslatedForCurrentUser(this.context, 'xxhasremovedxx')} ${doc[Dbkeys.groupmsgLISToptional][0]}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUserLeft) {
      return Center(
          child: Chip(
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgCONTENT].contains(widget.currentUserno)
              ? getTranslatedForCurrentUser(this.context, 'xxyouleftthegroupxx')
              : '${doc[Dbkeys.groupmsgCONTENT]}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] == MessageType.image.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.doc.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.text.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.video.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.audio.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.contact.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.location.index) {
      return doc[Dbkeys.content] == null || doc[Dbkeys.content] == ''
          ? buildMediaMessages(doc, groupData)
          : Dismissible(
              direction: DismissDirection.startToEnd,
              key: Key(doc[Dbkeys.groupmsgTIME].toString()),
              confirmDismiss: (direction) {
                onDismiss(doc);
                return Future.value(false);
              },
              child: buildMediaMessages(doc, groupData));
    }

    return Text(doc[Dbkeys.groupmsgCONTENT]);
  }

  onDismiss(Map<String, dynamic> doc) {
    if ((doc[Dbkeys.content] == '' || doc[Dbkeys.content] == null) == false) {
      final registry = Provider.of<UserRegistry>(this.context, listen: false);
      setStateIfMounted(() {
        isReplyKeyboard = true;
        replyDoc = doc;
        messageReplyOwnerName = registry
            .getUserData(this.context, doc[Dbkeys.groupmsgSENDBY])
            .fullname;
      });
      HapticFeedback.heavyImpact();
      keyboardFocusNode.requestFocus();
    }
  }

  FlutterSecureStorage storage = new FlutterSecureStorage();
  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);

  contextMenu(BuildContext context, Map<String, dynamic> mssgDoc,
      {bool saved = false}) {
    final observer = Provider.of<Observer>(context, listen: false);
    List<Widget> tiles = List.from(<Widget>[]);

    if (mssgDoc[Dbkeys.groupmsgSENDBY] == widget.currentUserno &&
        mssgDoc[Dbkeys.groupmsgISDELETED] == false) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(
            Icons.delete,
            color: Mycolors.red,
          ),
          title: Text(
            getTranslatedForCurrentUser(context, 'xxdeleteforallmembersxx'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            getTranslatedForCurrentUser(context, 'xxadmincanstillseeitxx'),
            style: TextStyle(fontSize: 12, color: Mycolors.grey),
          ),
          onTap: observer.checkIfCurrentUserIsDemo(widget.currentUserno) == true
              ? () {
                  Utils.toast(getTranslatedForCurrentUser(
                      context, 'xxxnotalwddemoxxaccountxx'));
                }
              : () async {
                  Navigator.of(this.context).pop();

                  ShowLoading().open(context: this.context, key: _keyLoader);
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectionAgentGroups)
                      .doc(widget.groupID)
                      .collection(DbPaths.collectiongroupChats)
                      .doc(mssgDoc[Dbkeys.groupmsgTIME].toString() +
                          "--" +
                          mssgDoc[Dbkeys.groupmsgSENDBY].toString())
                      .update({
                    Dbkeys.groupmsgISDELETED: true,
                    Dbkeys.deletedReason: "Message deleted by Sender",
                  }).then((value) {
                    var chatprovider =
                        Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(
                            this.context,
                            listen: false);
                    chatprovider.reset();
                    chatprovider.fetchNextData(
                        Dbkeys.datatypeGROUPCHATMSGS,
                        FirebaseFirestore.instance
                            .collection(DbPaths.collectionAgentGroups)
                            .doc(widget.groupID)
                            .collection(DbPaths.collectiongroupChats)
                            .orderBy(Dbkeys.groupmsgTIME, descending: true)
                            .limit(15),
                        false);
                    setState(() {});
                    ShowLoading().close(context: this.context, key: _keyLoader);
                    Utils.toast(
                        getTranslatedForCurrentUser(context, 'xxdeletedxx'));
                  }).catchError((e) {
                    ShowLoading().close(context: this.context, key: _keyLoader);
                    Utils.toast(
                        "${getTranslatedForCurrentUser(context, 'xxfailedxx')}   ERROR: $e");
                  });
                }));
    }
    if (mssgDoc[Dbkeys.messageType] == MessageType.text.index) {
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
            Clipboard.setData(
                ClipboardData(text: mssgDoc[Dbkeys.groupmsgCONTENT]));
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

  Widget buildMediaMessages(Map<String, dynamic> doc, GroupModel groupData) {
    bool isMe = widget.currentUserno == doc[Dbkeys.groupmsgSENDBY];
    bool saved = false;
    final observer = Provider.of<Observer>(this.context, listen: false);
    bool isContainURL = false;
    try {
      isContainURL = Uri.tryParse(doc[Dbkeys.content]!) == null
          ? false
          : Uri.tryParse(doc[Dbkeys.content]!)!.isAbsolute;
    } on Exception catch (_) {
      isContainURL = false;
    }
    return Consumer<UserRegistry>(
        builder: (context, registry, _child) => InkWell(
              onLongPress: doc[Dbkeys.groupmsgISDELETED] == false
                  ? () {
                      contextMenu(
                        context,
                        doc,
                      );
                      hidekeyboard(context);
                    }
                  : null,
              child: GroupChatBubble(
                isURLtext: doc[Dbkeys.groupmsgTYPE] == MessageType.text.index &&
                    isContainURL == true,
                is24hrsFormat: observer.is24hrsTimeformat,
                prefs: widget.prefs,
                currentUserNo: widget.currentUserno,
                model: widget.model,
                savednameifavailable: null,
                postedbyname: registry
                    .getUserData(context, doc[Dbkeys.groupmsgSENDBY])
                    .fullname,
                postedbyphone: doc[Dbkeys.groupmsgSENDBY],
                messagetype: doc[Dbkeys.groupmsgISDELETED] == true
                    ? MessageType.text
                    : doc[Dbkeys.messageType] == MessageType.text.index
                        ? MessageType.text
                        : doc[Dbkeys.messageType] == MessageType.contact.index
                            ? MessageType.contact
                            : doc[Dbkeys.messageType] ==
                                    MessageType.location.index
                                ? MessageType.location
                                : doc[Dbkeys.messageType] ==
                                        MessageType.image.index
                                    ? MessageType.image
                                    : doc[Dbkeys.messageType] ==
                                            MessageType.video.index
                                        ? MessageType.video
                                        : doc[Dbkeys.messageType] ==
                                                MessageType.doc.index
                                            ? MessageType.doc
                                            : doc[Dbkeys.messageType] ==
                                                    MessageType.audio.index
                                                ? MessageType.audio
                                                : MessageType.text,
                child: doc[Dbkeys.groupmsgISDELETED] == true
                    ? Text(
                        doc[Dbkeys.deletedReason] == "" ||
                                doc[Dbkeys.groupmsgSENDBY] !=
                                    widget.currentUserno
                            ? getTranslatedForCurrentUser(
                                context, 'xxmsgdeletedxx')
                            : doc[Dbkeys.deletedReason],
                        style: TextStyle(
                            color: Mycolors.black.withOpacity(0.6),
                            fontSize: 12,
                            fontStyle: FontStyle.italic),
                      )
                    : doc[Dbkeys.messageType] == MessageType.text.index
                        ? getTextMessage(isMe, doc, saved)
                        : doc[Dbkeys.messageType] == MessageType.location.index
                            ? getLocationMessage(doc[Dbkeys.content], doc,
                                saved: false)
                            : doc[Dbkeys.messageType] == MessageType.doc.index
                                ? getDocmessage(
                                    context, doc[Dbkeys.content], doc,
                                    saved: false)
                                : doc[Dbkeys.messageType] ==
                                        MessageType.audio.index
                                    ? getAudiomessage(
                                        context, doc[Dbkeys.content], doc,
                                        isMe: isMe, saved: false)
                                    : doc[Dbkeys.messageType] ==
                                            MessageType.video.index
                                        ? getVideoMessage(
                                            context, doc[Dbkeys.content], doc,
                                            saved: false)
                                        : doc[Dbkeys.messageType] ==
                                                MessageType.contact.index
                                            ? getContactMessage(context,
                                                doc[Dbkeys.content], doc,
                                                saved: false)
                                            : getImageMessage(
                                                doc,
                                                saved: saved,
                                              ),
                isMe: isMe,
                delivered: true,
                isContinuing: true,
                timestamp: doc[Dbkeys.groupmsgTIME],
              ),
            ));
  }

  Widget getVideoMessage(
      BuildContext context, String message, Map<String, dynamic> doc,
      {bool saved = false}) {
    Map<dynamic, dynamic>? meta =
        jsonDecode((message.split('-BREAK-')[2]).toString());
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
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
            doc.containsKey(Dbkeys.isForward) == true
                ? doc[Dbkeys.isForward] == true
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
                    : SizedBox(height: 0, width: 0)
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
      BuildContext context, String message, Map<String, dynamic> doc,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return SizedBox(
      width: 210,
      height: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
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
                  : SizedBox(height: 0, width: 0)
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

  Widget getTextMessage(bool isMe, Map<String, dynamic> doc, bool saved) {
    return doc.containsKey(Dbkeys.isReply) == true
        ? doc[Dbkeys.isReply] == true
            ? Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  replyAttachedWidget(this.context, doc[Dbkeys.replyToMsgDoc]),
                  SizedBox(
                    height: 10,
                  ),
                  selectablelinkify(doc[Dbkeys.content], 15.5, TextAlign.left),
                ],
              )
            : doc.containsKey(Dbkeys.isForward) == true
                ? doc[Dbkeys.isForward] == true
                    ? Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
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
                          selectablelinkify(
                              doc[Dbkeys.content], 15.5, TextAlign.left)
                        ],
                      )
                    : selectablelinkify(
                        doc[Dbkeys.content], 15.5, TextAlign.left)
                : selectablelinkify(doc[Dbkeys.content], 15.5, TextAlign.left)
        : selectablelinkify(doc[Dbkeys.content], 15.5, TextAlign.left);
  }

  Widget getLocationMessage(String? message, Map<String, dynamic> doc,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return InkWell(
      onTap: () {
        custom_url_launcher(message!);
      },
      child: doc.containsKey(Dbkeys.isForward) == true
          ? doc[Dbkeys.isForward] == true
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
                      height:
                          (MediaQuery.of(this.context).size.width / 1.7) * 0.6,
                    ),
                  ],
                )
              : Image.asset(
                  'assets/images/mapview.jpg',
                  width: MediaQuery.of(this.context).size.width / 1.7,
                  height: (MediaQuery.of(this.context).size.width / 1.7) * 0.6,
                )
          : Image.asset(
              'assets/images/mapview.jpg',
              width: MediaQuery.of(this.context).size.width / 1.7,
              height: (MediaQuery.of(this.context).size.width / 1.7) * 0.6,
            ),
    );
  }

  Widget getAudiomessage(
      BuildContext context, String message, Map<String, dynamic> doc,
      {bool saved = false, bool isMe = true}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      // width: 250,
      // height: 116,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
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
                  : SizedBox(height: 0, width: 0)
              : SizedBox(height: 0, width: 0),
          SizedBox(
            width: 200,
            height: 80,
            child: MultiPlayback(
              isMe: isMe,
              onTapDownloadFn: () async {
                await MobileDownloadService().download(
                    keyloader: _keyLoader,
                    url: message.split('-BREAK-')[0],
                    fileName:
                        'Recording_' + message.split('-BREAK-')[1] + '.mp3',
                    context: this.context,
                    isOpenAfterDownload: true);
              },
              url: message.split('-BREAK-')[0],
            ),
          )
        ],
      ),
    );
  }

  Widget getDocmessage(
      BuildContext context, String message, Map<String, dynamic> doc,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return SizedBox(
      width: 220,
      height: 126,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
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
                  : SizedBox(height: 0, width: 0)
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
                                currentUserID: widget.currentUserno,
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
                        onPressed: () async {
                          await MobileDownloadService().download(
                              url: message.split('-BREAK-')[0],
                              fileName: message.split('-BREAK-')[1],
                              context: context,
                              keyloader: _keyLoader,
                              isOpenAfterDownload: true);
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
                  onPressed: () async {
                    await MobileDownloadService().download(
                        url: message.split('-BREAK-')[0],
                        fileName: message.split('-BREAK-')[1],
                        context: context,
                        keyloader: _keyLoader,
                        isOpenAfterDownload: true);
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

  Widget getImageMessage(Map<String, dynamic> doc, {bool saved = false}) {
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
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
                  : SizedBox(height: 0, width: 0)
              : SizedBox(height: 0, width: 0),
          saved
              ? Material(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: Save.getImageFromBase64(doc[Dbkeys.content])
                              .image,
                          fit: BoxFit.cover),
                    ),
                    width: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                    height: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
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
                          imageUrl: doc[Dbkeys.content],
                          message: doc[Dbkeys.content],
                          tag: doc[Dbkeys.groupmsgTIME].toString(),
                          imageProvider:
                              CachedNetworkImageProvider(doc[Dbkeys.content]),
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
                          doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                      height:
                          doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
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
                            doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                        height:
                            doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                    ),
                    imageUrl: doc[Dbkeys.content],
                    width: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                    height: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                    fit: BoxFit.cover,
                  ),
                ),
        ],
      ),
    );
  }

  replyAttachedWidget(BuildContext context, var doc) {
    return Consumer<UserRegistry>(
        builder: (context, registry, _child) => Flexible(
              child: Container(
                  // width: 280,
                  height: 70,
                  margin: EdgeInsets.only(left: 0, right: 0),
                  decoration: BoxDecoration(
                      color: Mycolors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Stack(
                    children: [
                      Container(
                          margin: EdgeInsetsDirectional.all(4),
                          decoration: BoxDecoration(
                              color: Mycolors.grey.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: Row(children: [
                            Container(
                              decoration: BoxDecoration(
                                color: doc[Dbkeys.groupmsgSENDBY] ==
                                        widget.currentUserno
                                    ? Mycolors.agentPrimary
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
                                      doc[Dbkeys.groupmsgSENDBY] ==
                                              widget.currentUserno
                                          ? getTranslatedForCurrentUser(
                                              this.context, 'xxyouxx')
                                          : registry
                                              .getUserData(context,
                                                  doc[Dbkeys.groupmsgSENDBY])
                                              .fullname,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: doc[Dbkeys.groupmsgSENDBY] ==
                                                  widget.currentUserno
                                              ? Mycolors.agentPrimary
                                              : Colors.purple),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  doc[Dbkeys.messageType] ==
                                          MessageType.text.index
                                      ? Text(
                                          doc[Dbkeys.content],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        )
                                      : doc[Dbkeys.messageType] ==
                                              MessageType.doc.index
                                          ? Container(
                                              padding: const EdgeInsets.only(
                                                  right: 75),
                                              child: Text(
                                                doc[Dbkeys.content]
                                                    .split('-BREAK-')[1],
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            )
                                          : Text(
                                              getTranslatedForCurrentUser(
                                                  this.context,
                                                  doc[Dbkeys.messageType] ==
                                                          MessageType
                                                              .image.index
                                                      ? 'xxnimxx'
                                                      : doc[Dbkeys.messageType] ==
                                                              MessageType
                                                                  .video.index
                                                          ? 'xxnvmxx'
                                                          : doc[Dbkeys.messageType] ==
                                                                  MessageType
                                                                      .audio
                                                                      .index
                                                              ? 'xxnamxx'
                                                              : doc[Dbkeys.messageType] ==
                                                                      MessageType
                                                                          .contact
                                                                          .index
                                                                  ? 'xxncmxx'
                                                                  : doc[Dbkeys.messageType] ==
                                                                          MessageType
                                                                              .location
                                                                              .index
                                                                      ? 'xxnlmxx'
                                                                      : doc[Dbkeys.messageType] ==
                                                                              MessageType.doc.index
                                                                          ? 'xxndmxx'
                                                                          : ''),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                ],
                              ),
                            ))
                          ])),
                      doc[Dbkeys.messageType] == MessageType.text.index ||
                              doc[Dbkeys.messageType] ==
                                  MessageType.location.index
                          ? SizedBox(
                              width: 0,
                              height: 0,
                            )
                          : doc[Dbkeys.messageType] == MessageType.image.index
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
                                        placeholder: (context, url) =>
                                            Container(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Mycolors.loadingindicator),
                                          ),
                                          width: doc[Dbkeys.content]
                                                  .contains('giphy')
                                              ? 60
                                              : 60.0,
                                          height: doc[Dbkeys.content]
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
                                        errorWidget: (context, str, error) =>
                                            Material(
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
                                        imageUrl: doc[Dbkeys.messageType] ==
                                                MessageType.video.index
                                            ? ''
                                            : doc[Dbkeys.content],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                              : doc[Dbkeys.messageType] ==
                                      MessageType.video.index
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
                                                  bottomRight:
                                                      Radius.circular(5),
                                                  topLeft: Radius.circular(0),
                                                  bottomLeft:
                                                      Radius.circular(0)),
                                              child: Container(
                                                color: Colors.blueGrey[200],
                                                height: 74,
                                                width: 74,
                                                child: Stack(
                                                  children: [
                                                    CachedNetworkImage(
                                                      placeholder:
                                                          (context, url) =>
                                                              Container(
                                                        child:
                                                            CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Mycolors
                                                                      .loadingindicator),
                                                        ),
                                                        width: 74,
                                                        height: 74,
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .blueGrey[200],
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(
                                                                0.0),
                                                          ),
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              str, error) =>
                                                          Material(
                                                        child: Image.asset(
                                                          'assets/images/img_not_available.jpeg',
                                                          width: 60,
                                                          height: 60,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(0.0),
                                                        ),
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                      ),
                                                      imageUrl:
                                                          doc[Dbkeys.content]
                                                              .split(
                                                                  '-BREAK-')[1],
                                                      width: 74,
                                                      height: 74,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Container(
                                                      color: Colors.black
                                                          .withOpacity(0.4),
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
                                                  bottomRight:
                                                      Radius.circular(5),
                                                  topLeft: Radius.circular(0),
                                                  bottomLeft:
                                                      Radius.circular(0)),
                                              child: Container(
                                                  color: doc[Dbkeys.messageType] ==
                                                          MessageType.doc.index
                                                      ? Colors.yellow[800]
                                                      : doc[Dbkeys.messageType] ==
                                                              MessageType
                                                                  .audio.index
                                                          ? Colors.green[400]
                                                          : doc[Dbkeys.messageType] ==
                                                                  MessageType
                                                                      .location
                                                                      .index
                                                              ? Colors.red[700]
                                                              : doc[Dbkeys.messageType] ==
                                                                      MessageType
                                                                          .contact
                                                                          .index
                                                                  ? Colors
                                                                      .blue[400]
                                                                  : Colors
                                                                      .cyan[700],
                                                  height: 74,
                                                  width: 74,
                                                  child: Icon(
                                                    doc[Dbkeys.messageType] ==
                                                            MessageType
                                                                .doc.index
                                                        ? Icons
                                                            .insert_drive_file
                                                        : doc[Dbkeys.messageType] ==
                                                                MessageType
                                                                    .audio.index
                                                            ? Icons.mic_rounded
                                                            : doc[Dbkeys.messageType] ==
                                                                    MessageType
                                                                        .location
                                                                        .index
                                                                ? Icons
                                                                    .location_on
                                                                : doc[Dbkeys.messageType] ==
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
            ));
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

  Widget buildMessagesUsingProvider(BuildContext context) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    return Consumer<List<GroupModel>>(
        builder: (context, groupList, _child) => Consumer<
                FirestoreDataProviderMESSAGESforGROUPCHAT>(
            builder: (context, firestoreDataProvider, _) =>
                InfiniteCOLLECTIONListViewWidget(
                  scrollController: realtime,
                  isreverse: true,
                  firestoreDataProviderMESSAGESforGROUPCHAT:
                      firestoreDataProvider,
                  datatype: Dbkeys.datatypeGROUPCHATMSGS,
                  refdata: firestoreChatquery,
                  list: ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.all(7),
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: firestoreDataProvider.recievedDocs.length,
                      itemBuilder: (BuildContext context, int i) {
                        var dc = firestoreDataProvider.recievedDocs[i];

                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              i ==
                                      firestoreDataProvider
                                              .datalistSnapshot.length -
                                          1
                                  ? Card(
                                      elevation: 0.5,
                                      color: Color(0xffFFF2BE),
                                      margin:
                                          EdgeInsets.fromLTRB(10, 20, 10, 20),
                                      child: Container(
                                          padding:
                                              EdgeInsets.fromLTRB(8, 10, 8, 10),
                                          child: RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                              children: [
                                                WidgetSpan(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 2.5,
                                                            right: 4),
                                                    child: Icon(
                                                      EvaIcons.bulb,
                                                      color: Color(0xff78754A),
                                                      size: 14,
                                                    ),
                                                  ),
                                                ),
                                                TextSpan(
                                                    text: observer
                                                                .userAppSettingsDoc!
                                                                .defaultMessageDeletingTimeForGroup ==
                                                            0
                                                        ? getTranslatedForCurrentUser(
                                                            context,
                                                            'xxchatroommonitoredxx')
                                                        : getTranslatedForCurrentUser(
                                                                context,
                                                                'xxchatroommonitoredlongxx')
                                                            .replaceAll(
                                                                '(####)',
                                                                observer
                                                                    .userAppSettingsDoc!
                                                                    .defaultMessageDeletingTimeForGroup
                                                                    .toString()),
                                                    // text: "afafsdf",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff78754A),
                                                        height: 1.3,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              ],
                                            ),
                                          )),
                                    )
                                  : SizedBox(),
                              buildEachMessage(
                                  dc,
                                  groupList.lastWhere((element) =>
                                      element.docmap[Dbkeys.groupID] ==
                                      widget.groupID))
                            ]);
                      }),
                )));
  }

  Widget buildLoadingThumbnail() {
    return Positioned(
      child: isgeneratingSomethingLoader
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Mycolors.loadingindicator)),
              ),
              color: Mycolors.white.withOpacity(0.2),
            )
          : Container(),
    );
  }

  shareMedia(BuildContext context) {
    final observer = Provider.of<Observer>(context, listen: false);
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                      widget.currentUserno) ==
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
                                                    String finalUrl = url +
                                                        '-BREAK-' +
                                                        basename(pickedFile!
                                                                .path)
                                                            .toString();
                                                    onSendMessage(
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
                                  context, "xxinvalidfilexx"));
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
                                                              .currentUserno) ==
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
                                                    onSendMessage(
                                                      context: this.context,
                                                      content: videoUrl +
                                                          '-BREAK-' +
                                                          thumnailUrl +
                                                          '-BREAK-' +
                                                          videometadata! +
                                                          '-BREAK-' +
                                                          "$videofileName",
                                                      type: MessageType.video,
                                                    );
                                                    file.delete();
                                                    thumnailFile.delete();
                                                  }
                                                }
                                              }
                                            },
                                            file: File(file.path))));
                              } else {
                                Utils.toast(
                                    "File type not supported. Please choose a valid .mp4, .mov file. \n\nSelected file was $fileExtension ");
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
                                                        widget.currentUserno) ==
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
                                                onSendMessage(
                                                    context: this.context,
                                                    content: url,
                                                    type: MessageType.image,
                                                    timestamp: timeStamp);
                                                file.delete();
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                      widget.currentUserno) ==
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
                                      onSendMessage(
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
                                      widget.currentUserno) ==
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

    return PickupLayout(
        curentUserID: widget.currentUserno,
        prefs: widget.prefs,
        scaffold: Utils.getNTPWrappedWidget(Consumer<List<GroupModel>>(
            builder: (context, groupList, _child) => WillPopScope(
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
                              WidgetsBinding.instance
                                  .addPostFrameCallback((timeStamp) {
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
                      Scaffold(
                          key: _scaffold,
                          appBar: AppBar(
                            elevation: 0.4,
                            titleSpacing: -10,
                            leading: Container(
                              margin: EdgeInsets.only(right: 0),
                              width: 10,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  size: 20,
                                  color: Mycolors.black,
                                ),
                                onPressed: onWillPop,
                              ),
                            ),
                            backgroundColor: Mycolors.white,
                            title: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => new GroupDetails(
                                            model: widget.model,
                                            prefs: widget.prefs,
                                            currentUserID: widget.currentUserno,
                                            groupID: widget.groupID)));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 7, 0, 7),
                                      child: customCircleAvatarGroup(
                                          radius: 20,
                                          url: groupList
                                              .lastWhere((element) =>
                                                  element
                                                      .docmap[Dbkeys.groupID] ==
                                                  widget.groupID)
                                              .docmap[Dbkeys.groupPHOTOURL])),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            groupList
                                                .lastWhere((element) =>
                                                    element.docmap[
                                                        Dbkeys.groupID] ==
                                                    widget.groupID)
                                                .docmap[Dbkeys.groupNAME],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Mycolors.black,
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          isCurrentUserMuted
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5.0),
                                                  child: Icon(
                                                    Icons.volume_off,
                                                    color: Mycolors.black
                                                        .withOpacity(0.5),
                                                    size: 17,
                                                  ),
                                                )
                                              : SizedBox(),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.7,
                                        child: Text(
                                          getTranslatedForCurrentUser(
                                              this.context,
                                              'xxtapherefrgrpinfoxx'),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Mycolors.grey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              Container(
                                margin: EdgeInsets.only(right: 15, left: 15),
                                width: 25,
                                child: PopupMenuButton(
                                    icon: Padding(
                                      padding: const EdgeInsets.only(right: 0),
                                      child: Icon(
                                        Icons.more_vert_outlined,
                                        color: Mycolors.black,
                                      ),
                                    ),
                                    color: Mycolors.white,
                                    onSelected: (dynamic val) {
                                      switch (val) {
                                        case 'mute':
                                          setStateIfMounted(() {
                                            isCurrentUserMuted =
                                                !isCurrentUserMuted;
                                          });

                                          FirebaseMessaging.instance
                                              .unsubscribeFromTopic(
                                                  "GROUP${widget.groupID.replaceAll(RegExp('-'), '').substring(1, widget.groupID.replaceAll(RegExp('-'), '').toString().length)}")
                                              .then((value) {
                                            FirebaseFirestore.instance
                                                .collection(DbPaths
                                                    .collectionAgentGroups)
                                                .doc(widget.groupID)
                                                .update({
                                              Dbkeys.groupMUTEDMEMBERS:
                                                  FieldValue.arrayUnion(
                                                      [widget.currentUserno]),
                                            });
                                          }).catchError((err) {
                                            setStateIfMounted(() {
                                              isCurrentUserMuted =
                                                  !isCurrentUserMuted;
                                            });
                                            FirebaseFirestore.instance
                                                .collection(DbPaths
                                                    .collectionAgentGroups)
                                                .doc(widget.groupID)
                                                .update({
                                              Dbkeys.groupMUTEDMEMBERS:
                                                  FieldValue.arrayRemove(
                                                      [widget.currentUserno]),
                                            });
                                          });

                                          break;
                                        case 'unmute':
                                          setStateIfMounted(() {
                                            isCurrentUserMuted =
                                                !isCurrentUserMuted;
                                          });

                                          FirebaseMessaging.instance
                                              .subscribeToTopic(
                                                  "GROUP${widget.groupID.replaceAll(RegExp('-'), '').substring(1, widget.groupID.replaceAll(RegExp('-'), '').toString().length)}")
                                              .then((value) {
                                            FirebaseFirestore.instance
                                                .collection(DbPaths
                                                    .collectionAgentGroups)
                                                .doc(widget.groupID)
                                                .update({
                                              Dbkeys.groupMUTEDMEMBERS:
                                                  FieldValue.arrayRemove(
                                                      [widget.currentUserno]),
                                            });
                                          }).catchError((err) {
                                            setStateIfMounted(() {
                                              isCurrentUserMuted =
                                                  !isCurrentUserMuted;
                                            });
                                            FirebaseFirestore.instance
                                                .collection(DbPaths
                                                    .collectionAgentGroups)
                                                .doc(widget.groupID)
                                                .update({
                                              Dbkeys.groupMUTEDMEMBERS:
                                                  FieldValue.arrayUnion(
                                                      [widget.currentUserno]),
                                            });
                                          });

                                          break;
                                        case 'report':
                                          showModalBottomSheet(
                                              isScrollControlled: true,
                                              context: context,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            25.0)),
                                              ),
                                              builder: (BuildContext context) {
                                                final observer =
                                                    Provider.of<Observer>(
                                                        context,
                                                        listen: false);
                                                // return your layout
                                                var w = MediaQuery.of(context)
                                                    .size
                                                    .width;
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom:
                                                          MediaQuery.of(context)
                                                              .viewInsets
                                                              .bottom),
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.all(16),
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height /
                                                              2.6,
                                                      child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .stretch,
                                                          children: [
                                                            SizedBox(
                                                              height: 12,
                                                            ),
                                                            SizedBox(
                                                              height: 3,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 7),
                                                              child: Text(
                                                                getTranslatedForCurrentUser(
                                                                    this.context,
                                                                    'xxreportshortxx'),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        16.5),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 10),
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0),
                                                              // height: 63,
                                                              height: 63,
                                                              width: w / 1.24,
                                                              child:
                                                                  InpuTextBox(
                                                                controller:
                                                                    reportEditingController,
                                                                leftrightmargin:
                                                                    0,
                                                                showIconboundary:
                                                                    false,
                                                                boxcornerradius:
                                                                    5.5,
                                                                boxheight: 50,
                                                                hinttext: getTranslatedForCurrentUser(
                                                                    this.context,
                                                                    'xxreportdescxx'),
                                                                prefixIconbutton:
                                                                    Icon(
                                                                  Icons.message,
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.5),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: w / 10,
                                                            ),
                                                            myElevatedButton(
                                                                color: Mycolors
                                                                    .agentSecondary,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          10,
                                                                          15,
                                                                          10,
                                                                          15),
                                                                  child: Text(
                                                                    getTranslatedForCurrentUser(
                                                                        context,
                                                                        'xxreportxx'),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            18),
                                                                  ),
                                                                ),
                                                                onPressed: observer
                                                                            .checkIfCurrentUserIsDemo(widget.currentUserno) ==
                                                                        true
                                                                    ? () {
                                                                        Utils.toast(getTranslatedForCurrentUser(
                                                                            context,
                                                                            'xxxnotalwddemoxxaccountxx'));
                                                                      }
                                                                    : () async {
                                                                        Navigator.of(context)
                                                                            .pop();

                                                                        DateTime
                                                                            time =
                                                                            DateTime.now();

                                                                        Map<String,
                                                                                dynamic>
                                                                            mapdata =
                                                                            {
                                                                          'title':
                                                                              'New report by User',
                                                                          'desc':
                                                                              '${reportEditingController.text}',
                                                                          'phone':
                                                                              '${widget.currentUserno}',
                                                                          'type':
                                                                              'Group Chat',
                                                                          'time':
                                                                              time.millisecondsSinceEpoch,
                                                                          'id':
                                                                              widget.groupID,
                                                                        };

                                                                        await FirebaseFirestore
                                                                            .instance
                                                                            .collection('reports')
                                                                            .doc(time.millisecondsSinceEpoch.toString())
                                                                            .set(mapdata)
                                                                            .then((value) async {
                                                                          showModalBottomSheet(
                                                                              isScrollControlled: true,
                                                                              context: context,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                                                                              ),
                                                                              builder: (BuildContext context) {
                                                                                return Container(
                                                                                  height: 220,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(28.0),
                                                                                    child: Column(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Icon(Icons.check, color: Colors.green[400], size: 40),
                                                                                        SizedBox(
                                                                                          height: 30,
                                                                                        ),
                                                                                        Text(
                                                                                          getTranslatedForCurrentUser(context, 'xxreportsuccessxx'),
                                                                                          textAlign: TextAlign.center,
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              });

                                                                          //----
                                                                        }).catchError((err) {
                                                                          showModalBottomSheet(
                                                                              isScrollControlled: true,
                                                                              context: this.context,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                                                                              ),
                                                                              builder: (BuildContext context) {
                                                                                return Container(
                                                                                  height: 220,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.all(28.0),
                                                                                    child: Column(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Icon(Icons.check, color: Colors.green[400], size: 40),
                                                                                        SizedBox(
                                                                                          height: 30,
                                                                                        ),
                                                                                        Text(
                                                                                          getTranslatedForCurrentUser(context, 'xxreportsuccessxx'),
                                                                                          textAlign: TextAlign.center,
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              });
                                                                        });
                                                                      }),
                                                          ])),
                                                );
                                              });
                                          break;
                                      }
                                    },
                                    itemBuilder: ((context) =>
                                        <PopupMenuItem<String>>[
                                          PopupMenuItem<String>(
                                            value: isCurrentUserMuted
                                                ? 'unmute'
                                                : 'mute',
                                            child: Text(
                                              isCurrentUserMuted
                                                  ? '${getTranslatedForCurrentUser(this.context, 'xxunmutexx')}'
                                                  : '${getTranslatedForCurrentUser(this.context, 'xxmutexx')}',
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'report',
                                            child: Text(
                                              '${getTranslatedForCurrentUser(this.context, 'xxreportxx')}',
                                            ),
                                          ),
                                          // ignore: unnecessary_null_comparison
                                        ].toList())),
                              ),
                            ],
                          ),
                          body: Stack(children: <Widget>[
                            new Container(
                              decoration: new BoxDecoration(
                                color: Mycolors.chatbackground,
                                image: new DecorationImage(
                                    image: AssetImage(
                                        "assets/images/background.png"),
                                    fit: BoxFit.cover),
                              ),
                            ),
                            PageView(children: <Widget>[
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                        child: buildMessagesUsingProvider(
                                            context)),
                                    groupList
                                                    .lastWhere((element) =>
                                                        element.docmap[
                                                            Dbkeys.groupID] ==
                                                        widget.groupID)
                                                    .docmap[Dbkeys.groupTYPE] ==
                                                Dbkeys
                                                    .groupTYPEallusersmessageallowed ||
                                            groupList
                                                .lastWhere((element) =>
                                                    element.docmap[
                                                        Dbkeys.groupID] ==
                                                    widget.groupID)
                                                .docmap[Dbkeys.groupADMINLIST]
                                                .contains(widget.currentUserno)
                                        ? buildInputAndroid(
                                            context,
                                            isemojiShowing,
                                            refreshInput,
                                            _keyboardVisible,
                                          )
                                        : Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.fromLTRB(
                                                14, 7, 14, 7),
                                            color: Colors.white,
                                            height: 70,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Text(
                                              getTranslatedForCurrentUser(
                                                  context, 'xxonlyadminsendxx'),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(height: 1.3),
                                            ),
                                          ),
                                  ])
                            ]),
                          ])),
                      buildLoadingThumbnail()
                    ],
                  ),
                ))));
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
    bool isContainURL = false;
    try {
      isContainURL =
          Uri.tryParse(text!) == null ? false : Uri.tryParse(text)!.isAbsolute;
    } on Exception catch (_) {
      isContainURL = false;
    }
    return isContainURL == false
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
              text: text,
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
    appBar: AppBar(),
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
