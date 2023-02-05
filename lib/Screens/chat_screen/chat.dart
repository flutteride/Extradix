//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Configs/optional_constants.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/callhistory.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/utils/uploadMediaWithProgress.dart';
import 'package:thinkcreative_technologies/Services/Admob/admob.dart';
import 'package:thinkcreative_technologies/Services/Providers/liveListener.dart';
import 'package:thinkcreative_technologies/Utils/custom_url_launcher.dart';
import 'package:thinkcreative_technologies/Utils/getRolePermission.dart';
import 'package:thinkcreative_technologies/Utils/mime_type.dart';
import 'package:thinkcreative_technologies/Utils/setStatusBarColor.dart';
import 'package:thinkcreative_technologies/main.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/utils/deleteChatMedia.dart';
import 'package:thinkcreative_technologies/Screens/privacypolicy&TnC/PdfViewFromCachedUrl.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/widgets/AllinOneCameraGalleryImageVideoPicker/AllinOneCameraGalleryImageVideoPicker.dart';
import 'package:thinkcreative_technologies/widgets/CameraGalleryImagePicker/camera_image_gallery_picker.dart';
import 'package:thinkcreative_technologies/widgets/CameraGalleryImagePicker/multiMediaPicker.dart';
import 'package:thinkcreative_technologies/widgets/CustomAlertDialog/CustomDialog.dart';
import 'package:thinkcreative_technologies/widgets/DownloadManager/download_all_file_type.dart';
import 'package:thinkcreative_technologies/widgets/MultiDocumentPicker/multiDocumentPicker.dart';
import 'package:thinkcreative_technologies/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custominput.dart';
import 'package:thinkcreative_technologies/widgets/SoundPlayer/SoundPlayerPro.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Services/Providers/currentchat_peer.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/utils/audioPlayback.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/utils/message.dart';
import 'package:thinkcreative_technologies/Models/DataModel.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/utils/photo_view.dart';
import 'package:thinkcreative_technologies/Services/Providers/seen_provider.dart';
import 'package:thinkcreative_technologies/Services/Providers/seen_state.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:thinkcreative_technologies/Utils/call_utilities.dart';
import 'package:thinkcreative_technologies/Utils/permissions.dart';
import 'package:thinkcreative_technologies/Utils/chat_controller.dart';
import 'package:thinkcreative_technologies/Utils/open_settings.dart';
import 'package:thinkcreative_technologies/Utils/save.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/widgets/AudioRecorder/Audiorecord.dart';
import 'package:thinkcreative_technologies/widgets/VideoEditor/video_editor.dart';
import 'package:thinkcreative_technologies/widgets/VideoPicker/VideoPreview.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/Widget/bubble.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:media_info/media_info.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkcreative_technologies/Utils/unawaited.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emojipic;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:video_compress/video_compress.dart' as compress;
import 'package:path/path.dart' as p;

hidekeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
  setStatusBarColor();
}

class ChatScreen extends StatefulWidget {
  final String peerUID, currentUserID;
  final DataModel model;
  final int unread;
  final SharedPreferences prefs;
  final List<SharedMediaFile>? sharedFiles;
  final MessageType? sharedFilestype;
  final bool isSharingIntentForwarded;
  final String? sharedText;
  ChatScreen({
    Key? key,
    required this.currentUserID,
    required this.peerUID,
    required this.model,
    required this.prefs,
    required this.unread,
    required this.isSharingIntentForwarded,
    this.sharedFiles,
    this.sharedFilestype,
    this.sharedText,
  });

  @override
  State createState() => new _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  bool isReplyKeyboard = false;
  bool isPeerMuted = false;
  Map<String, dynamic>? replyDoc;
  String? peerAvatar, peerUID, currentUserID;
  late bool locked, hidden;
  Map<String, dynamic>? peer, currentUser;
  int? chatStatus, unread;
  GlobalKey<State> _keyLoader =
      new GlobalKey<State>(debugLabel: 'qqqeqeqsseaadsqeqe');
  bool isCurrentUserMuted = false;
  String? chatId;
  bool isMessageLoading = true;
  bool typing = false;
  late File thumbnailFile;
  File? pickedFile;
  // bool isLoading = true;
  bool isgeneratingSomethingLoader = false;
  int tempSendIndex = 0;
  String? imageUrl;
  SeenState? seenState;
  List<Message> messages = new List.from(<Message>[]);
  List<Map<String, dynamic>> _savedMessageDocs =
      new List.from(<Map<String, dynamic>>[]);
  bool isDeletedDoc = false;
  int? uploadTimestamp;

  StreamSubscription? seenSubscription,
      msgSubscription,
      deleteUptoSubscription,
      chatStatusSubscriptionForPeer;

  final TextEditingController textEditingController =
      new TextEditingController();
  final TextEditingController reportEditingController =
      new TextEditingController();
  final ScrollController realtime = new ScrollController();
  final ScrollController saved = new ScrollController();
  late DataModel _cachedModel;

  Duration? duration;
  Duration? position;

  // AudioPlayer audioPlayer = AudioPlayer();

  String? localFilePath;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  @override
  void initState() {
    super.initState();
    _cachedModel = widget.model;
    peerUID = widget.peerUID;
    currentUserID = widget.currentUserID;
    unread = widget.unread;
    // initAudioPlayer();
    // _load();
    Utils.internetLookUp();

    updateLocalUserData(_cachedModel);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = Provider.of<Observer>(this.context, listen: false);
      var currentpeer =
          Provider.of<CurrentChatPeer>(this.context, listen: false);
      currentpeer.setpeer(widget.peerUID);
      seenState = new SeenState(false);
      WidgetsBinding.instance.addObserver(this);
      chatId = '';
      unread = widget.unread;
      // isLoading = false;
      imageUrl = '';
      listenToBlock();
      loadSavedMessages();
      readLocal(this.context);
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (IsVideoAdShow == true && observer.isadmobshow == true) {
          _createRewardedAd();
        }

        if (IsInterstitialAdShow == true && observer.isadmobshow == true) {
          _createInterstitialAd();
        }
      });
    });
    setStatusBarColor();
  }

  bool hasPeerBlockedMe = false;
  listenToBlock() {
    chatStatusSubscriptionForPeer = FirebaseFirestore.instance
        .collection(DbPaths.collectionAgentIndividiualmessages)
        .doc(Utils.getChatId(currentUserID, peerUID))
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        if (doc.data()!.containsKey(widget.currentUserID)) {
          if (doc.data()![widget.currentUserID] == 0) {
            hasPeerBlockedMe = true;
            setStateIfMounted(() {});
          } else if (doc.data()![widget.currentUserID] == 3) {
            hasPeerBlockedMe = false;
            setStateIfMounted(() {});
          }
        }
      } else {}
    });
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

  updateLocalUserData(model) {
    peer = model.userData[peerUID];
    currentUser = _cachedModel.currentUser;
    if (currentUser != null && peer != null) {
      hidden = currentUser![Dbkeys.hidden] != null &&
          currentUser![Dbkeys.hidden].contains(peerUID);
      locked = currentUser![Dbkeys.locked] != null &&
          currentUser![Dbkeys.locked].contains(peerUID);
      chatStatus = peer![Dbkeys.chatStatus];
      peerAvatar = peer![Dbkeys.photoUrl];
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    setLastSeen();
    // audioPlayer.stop();
    msgSubscription?.cancel();

    chatStatusSubscriptionForPeer?.cancel();
    seenSubscription?.cancel();
    deleteUptoSubscription?.cancel();
    if (IsInterstitialAdShow == true) {
      _interstitialAd!.dispose();
    }
    if (IsVideoAdShow == true) {
      _rewardedAd!.dispose();
    }
  }

  void setLastSeen() async {
    try {
      if (chatStatus != ChatStatus.blocked.index) {
        if (chatId != null) {
          await FirebaseFirestore.instance
              .collection(DbPaths.collectionAgentIndividiualmessages)
              .doc(chatId)
              .update(
            {'$currentUserID': DateTime.now().millisecondsSinceEpoch},
          );
          setStatusBarColor();
          if (typing == true) {
            FirebaseFirestore.instance
                .collection(DbPaths.collectionagents)
                .doc(currentUserID)
                .update(
              {Dbkeys.lastSeen: true},
            );
          }
        }
      }
    } catch (e) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      setIsActive();
    else
      setLastSeen();
  }

  void setIsActive() async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionAgentIndividiualmessages)
        .doc(chatId)
        .set({
      '$currentUserID': true,
      '$currentUserID-lastOnline': DateTime.now().millisecondsSinceEpoch
    }, SetOptions(merge: true));
  }

  dynamic lastSeen;

  FlutterSecureStorage storage = new FlutterSecureStorage();

  readLocal(
    BuildContext context,
  ) async {
    // Utils.toast("triggered !");

    try {
      seenState!.value = widget.prefs.getInt(getLastSeenKey());
    } catch (e) {
      seenState!.value = false;
    }
    chatId = Utils.getChatId(currentUserID, peerUID);
    textEditingController.addListener(() {
      if (textEditingController.text.isNotEmpty && typing == false) {
        lastSeen = peerUID;
        FirebaseFirestore.instance
            .collection(DbPaths.collectionagents)
            .doc(currentUserID)
            .update(
          {Dbkeys.lastSeen: peerUID},
        );
        typing = true;
      }
      if (textEditingController.text.isEmpty && typing == true) {
        lastSeen = true;
        FirebaseFirestore.instance
            .collection(DbPaths.collectionagents)
            .doc(currentUserID)
            .update(
          {Dbkeys.lastSeen: true},
        );
        typing = false;
      }
    });
    setIsActive();
    seenSubscription = FirebaseFirestore.instance
        .collection(DbPaths.collectionAgentIndividiualmessages)
        .doc(chatId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        setStateIfMounted(() {
          isDeletedDoc = false;
          isPeerMuted = doc.data()!.containsKey("$peerUID-muted")
              ? doc.data()!["$peerUID-muted"]
              : false;

          isCurrentUserMuted = doc.data()!.containsKey("$currentUserID-muted")
              ? doc.data()!["$currentUserID-muted"]
              : false;
        });

        if (mounted && doc.data()!.containsKey(peerUID)) {
          seenState!.value = doc[peerUID!] ?? false;
          if (seenState!.value is int) {
            widget.prefs.setInt(getLastSeenKey(), seenState!.value);
          }
          if (doc.data()!.containsKey("${peerUID!}-lastOnline")) {
            int lastOnline = doc.data()!["${peerUID!}-lastOnline"];
            if (doc.data()!["${peerUID!}"] == true &&
                DateTime.now()
                        .difference(
                            DateTime.fromMillisecondsSinceEpoch(lastOnline))
                        .inMinutes >
                    20) {
              doc.reference.update({"${peerUID!}": lastOnline});
            }
          }
        }
      } else {
        setStateIfMounted(() {
          isDeletedDoc = true;
        });
      }
    });
    loadMessagesAndListen();
  }

  String getLastSeenKey() {
    return "$peerUID-${Dbkeys.lastSeen}";
  }

  int? thumnailtimestamp;
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

  getThumbnail(String url) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    // ignore: unnecessary_null_comparison
    setStateIfMounted(() {
      isgeneratingSomethingLoader = true;
    });

    String? path = await VideoThumbnail.thumbnailFile(
        video: url,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        quality: 30);

    thumbnailFile = File(path!);

    setStateIfMounted(() {
      isgeneratingSomethingLoader = false;
    });

    return observer.isPercentProgressShowWhileUploading
        ? uploadFileWithProgressIndicator(true)
        : uploadFile(true);
  }

  getWallpaper(File image) {
    // ignore: unnecessary_null_comparison
    if (image != null) {
      _cachedModel.setWallpaper(peerUID, image);
    }
    return Future.value(false);
  }

  String? videometadata;
  Future uploadFile(bool isthumbnail, {int? timestamp}) async {
    uploadTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    String fileName = getFileName(
        currentUserID,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference =
        FirebaseStorage.instance.ref("+00_CHAT_MEDIA/$chatId/").child(fileName);
    TaskSnapshot uploading = await reference
        .putFile(isthumbnail == true ? thumbnailFile : pickedFile!);
    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }
    if (isthumbnail == true) {
      MediaInfo _mediaInfo = MediaInfo();

      await _mediaInfo.getMediaInfo(thumbnailFile.path).then((mediaInfo) {
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

    return uploading.ref.getDownloadURL();
  }

  Future uploadFileWithProgressIndicator(
    bool isthumbnail, {
    int? timestamp,
  }) async {
    uploadTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    File fileToCompress;
    File? compressedImage;
    String fileName = getFileName(
        currentUserID,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference =
        FirebaseStorage.instance.ref("+00_CHAT_MEDIA/$chatId/").child(fileName);
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
        ? thumbnailFile
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

      await _mediaInfo.getMediaInfo(thumbnailFile.path).then((mediaInfo) {
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

  void onSendMessage(
      BuildContext context, String content, MessageType type, int? timestamp,
      {bool isForward = false}) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    if (content.trim() != '') {
      SpecialLiveConfigData? livedata =
          Provider.of<SpecialLiveConfigData?>(context, listen: false);
      bool isShownamePhoto = observer
                  .userAppSettingsDoc!.agentcanseeagentnameandphoto! ==
              true ||
          (iAmSecondAdmin(
                      specialLiveConfigData: livedata,
                      currentuserid: peerUID!,
                      context: context) ==
                  true &&
              observer.userAppSettingsDoc!.secondadmincanseeagentnameandphoto ==
                  true) ||
          (iAmDepartmentManager(currentuserid: peerUID!, context: context) ==
                  true &&
              observer.userAppSettingsDoc!
                      .departmentmanagercanseeagentnameandphoto ==
                  true);
      String tempcontent = "";
      try {
        content = content.trim();
        tempcontent = content.trim();
        if (chatStatus == null || chatStatus == 4)
          ChatController.request(currentUserID, peerUID, chatId);
        textEditingController.clear();

        Future messaging = FirebaseFirestore.instance
            .collection(DbPaths.collectionAgentIndividiualmessages)
            .doc(chatId)
            .collection(chatId!)
            .doc('$timestamp')
            .set({
          Dbkeys.isMuted: isPeerMuted,
          Dbkeys.from: currentUserID,
          Dbkeys.to: peerUID,
          Dbkeys.timestamp: timestamp,
          Dbkeys.content: content,
          Dbkeys.messageType: type.index,
          Dbkeys.hasSenderDeleted: false,
          Dbkeys.hasRecipientDeleted: false,
          Dbkeys.sendername: isShownamePhoto == true
              ? _cachedModel.currentUser![Dbkeys.nickname]
              : "Agent ID ${widget.currentUserID}: ",
          Dbkeys.isReply: isReplyKeyboard,
          Dbkeys.replyToMsgDoc: replyDoc,
          Dbkeys.isForward: isForward,
          Dbkeys.deletedType: "",
          Dbkeys.deletedReason: "",
          Dbkeys.id: Utils.getChatId(widget.currentUserID, peerUID),
        }, SetOptions(merge: true));

        _cachedModel.addMessage(peerUID, timestamp, messaging);
        var tempDoc = {
          Dbkeys.isMuted: isPeerMuted,
          Dbkeys.from: currentUserID,
          Dbkeys.to: peerUID,
          Dbkeys.timestamp: timestamp,
          Dbkeys.content: content,
          Dbkeys.messageType: type.index,
          Dbkeys.hasSenderDeleted: false,
          Dbkeys.hasRecipientDeleted: false,
          Dbkeys.sendername: isShownamePhoto == true
              ? _cachedModel.currentUser![Dbkeys.nickname]
              : "Agent ID ${widget.currentUserID}: ",
          Dbkeys.isReply: isReplyKeyboard,
          Dbkeys.replyToMsgDoc: replyDoc,
          Dbkeys.isForward: isForward,
          Dbkeys.deletedType: "",
          Dbkeys.deletedReason: "",
          Dbkeys.tempcontent: tempcontent,
          Dbkeys.id: Utils.getChatId(widget.currentUserID, peerUID),
        };
        FirebaseFirestore.instance
            .collection(DbPaths.collectionAgentIndividiualmessages)
            .doc(chatId)
            .set({
          Dbkeys.lastMessageTime: DateTime.now().millisecondsSinceEpoch,
          "chatmembers": [widget.currentUserID, widget.peerUID]
        }, SetOptions(merge: true));
        setStatusBarColor();
        setStateIfMounted(() {
          isReplyKeyboard = false;
          replyDoc = null;
          messages = List.from(messages)
            ..add(Message(
              buildTempMessage(
                  context, type, content, timestamp, messaging, tempDoc),
              onTap: (tempDoc[Dbkeys.from] == widget.currentUserID &&
                          tempDoc[Dbkeys.hasSenderDeleted] == true) ==
                      true
                  ? () {}
                  : type == MessageType.image
                      ? () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhotoViewWrapper(
                                  keyloader: _keyLoader,
                                  imageUrl: content,
                                  message: content,
                                  tag: timestamp.toString(),
                                  imageProvider:
                                      CachedNetworkImageProvider(content),
                                ),
                              ));
                        }
                      : null,
              onDismiss: tempDoc[Dbkeys.content] == '' ||
                      tempDoc[Dbkeys.content] == null
                  ? () {}
                  : () {
                      setStateIfMounted(() {
                        isReplyKeyboard = true;
                        replyDoc = tempDoc;
                      });
                      HapticFeedback.heavyImpact();
                      keyboardFocusNode.requestFocus();
                    },
              onDoubleTap: () {
                // save(tempDoc);
              },
              onLongPress: () {
                if ((tempDoc[Dbkeys.from] == widget.currentUserID &&
                        tempDoc[Dbkeys.hasSenderDeleted] == true) ==
                    false) {
                  //--Show Menu only if message is not deleted by current user already
                  contextMenuNew(this.context, tempDoc, true);
                }
              },
              from: currentUserID,
              timestamp: timestamp,
            ));
        });

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
        // _playPopSound();

      } on Exception catch (_) {
        // print('Exception caught!');
        Utils.toast("Exception: $_");
      }
    }
  }

  delete(int? ts) {
    setStateIfMounted(() {
      messages.removeWhere((msg) => msg.timestamp == ts);
      messages = List.from(messages);
    });
  }

  updateDeleteBySenderField(int? ts, updateDoc, context) {
    setStateIfMounted(() {
      int i = messages.indexWhere((msg) => msg.timestamp == ts);
      var child = buildTempMessage(
          context,
          MessageType.text,
          updateDoc[Dbkeys.content],
          updateDoc[Dbkeys.timestamp],
          true,
          updateDoc);
      var timestamp = messages[i].timestamp;
      var from = messages[i].from;
      // var onTap = messages[i].onTap;
      var onDoubleTap = messages[i].onDoubleTap;
      var onDismiss = messages[i].onDismiss;
      var onLongPress = () {};
      if (i >= 0) {
        messages.removeWhere((msg) => msg.timestamp == ts);
        messages.insert(
            i,
            Message(child,
                timestamp: timestamp,
                from: from,
                onTap: () {},
                onDoubleTap: onDoubleTap,
                onDismiss: onDismiss,
                onLongPress: onLongPress));
      }
      messages = List.from(messages);
    });
  }

  contextMenuForSavedMessage(
    BuildContext context,
    Map<String, dynamic> doc,
  ) {
    List<Widget> tiles = List.from(<Widget>[]);
    tiles.add(ListTile(
        dense: true,
        leading: Icon(Icons.delete_outline),
        title: Text(
          getTranslatedForCurrentUser(this.context, 'xxdeletexx'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onTap: () async {
          Save.deleteMessage(peerUID, doc);
          _savedMessageDocs.removeWhere(
              (msg) => msg[Dbkeys.timestamp] == doc[Dbkeys.timestamp]);
          setStateIfMounted(() {
            _savedMessageDocs = List.from(_savedMessageDocs);
          });
          Navigator.pop(context);
        }));
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(children: tiles);
        });
  }

  //-- New context menu with Delete for Me & Delete For Everyone feature
  contextMenuNew(contextForDialog, Map<String, dynamic> mssgDoc, bool isTemp,
      {bool saved = false}) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    List<Widget> tiles = List.from(<Widget>[]);
    //####################----------------------- Delete Msgs for SENDER ---------------------------------------------------
    if ((mssgDoc[Dbkeys.from] == currentUserID &&
        mssgDoc[Dbkeys.hasSenderDeleted] == false)) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(
            Icons.delete_outline,
            color: Mycolors.red,
          ),
          title: Text(
            getTranslatedForCurrentUser(this.context, 'xxdeletexx'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
              getTranslatedForCurrentUser(
                  this.context, 'xxadmincanstillseeitxx'),
              style: TextStyle(color: Mycolors.grey, fontSize: 12)),
          onTap: observer.checkIfCurrentUserIsDemo(widget.currentUserID) == true
              ? () {
                  Utils.toast(getTranslatedForCurrentUser(
                      this.context, 'xxxnotalwddemoxxaccountxx'));
                }
              : () async {
                  Navigator.of(this.context).pop();
                  ShowLoading().open(context: this.context, key: _keyLoader);
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectionAgentIndividiualmessages)
                      .doc(chatId)
                      .get()
                      .then((chatroomDoc) async {
                    if (chatroomDoc.exists) {
                      if (chatroomDoc.data()!.containsKey(peerUID)) {
                        if (chatroomDoc[this.peerUID!] is bool) {
                          await FirebaseFirestore.instance
                              .collection(
                                  DbPaths.collectionAgentIndividiualmessages)
                              .doc(chatId)
                              .collection(chatId!)
                              .doc('${mssgDoc[Dbkeys.timestamp]}')
                              .update({
                            Dbkeys.hasSenderDeleted: true,
                            Dbkeys.deletedType:
                                DeletedType.peerHasAlreadyRead.index.toString()
                          });
                        } else if (chatroomDoc[this.peerUID!] is int) {
                          if (chatroomDoc[this.peerUID!] >=
                              mssgDoc[Dbkeys.timestamp]) {
                            await FirebaseFirestore.instance
                                .collection(
                                    DbPaths.collectionAgentIndividiualmessages)
                                .doc(chatId)
                                .collection(chatId!)
                                .doc('${mssgDoc[Dbkeys.timestamp]}')
                                .update({
                              Dbkeys.hasSenderDeleted: true,
                              Dbkeys.deletedType: DeletedType
                                  .peerHasAlreadyRead.index
                                  .toString()
                            });
                          } else {
                            await FirebaseFirestore.instance
                                .collection(
                                    DbPaths.collectionAgentIndividiualmessages)
                                .doc(chatId)
                                .collection(chatId!)
                                .doc('${mssgDoc[Dbkeys.timestamp]}')
                                .update({
                              Dbkeys.hasSenderDeleted: true,
                              Dbkeys.deletedType:
                                  DeletedType.peerHasNotReadYet.index.toString()
                            });
                          }
                        } else {
                          await FirebaseFirestore.instance
                              .collection(
                                  DbPaths.collectionAgentIndividiualmessages)
                              .doc(chatId)
                              .collection(chatId!)
                              .doc('${mssgDoc[Dbkeys.timestamp]}')
                              .update({
                            Dbkeys.hasSenderDeleted: true,
                            Dbkeys.deletedType:
                                DeletedType.peerHasNotReadYet.index.toString()
                          });
                        }
                      } else {
                        await FirebaseFirestore.instance
                            .collection(
                                DbPaths.collectionAgentIndividiualmessages)
                            .doc(chatId)
                            .collection(chatId!)
                            .doc('${mssgDoc[Dbkeys.timestamp]}')
                            .update({
                          Dbkeys.hasSenderDeleted: true,
                          Dbkeys.deletedType:
                              DeletedType.peerHasNotReadYet.index.toString()
                        });
                      }
                    } else {
                      ShowLoading()
                          .close(context: this.context, key: _keyLoader);
                      Utils.toast("Chatroom Does not exists");
                    }
                  }).then((v) async {
                    ShowLoading().close(context: this.context, key: _keyLoader);
                    Utils.toast(
                        "${getTranslatedForCurrentUser(this.context, 'xxmsgdeletedxx')}.  ${getTranslatedForCurrentUser(this.context, 'xxplsreloadxx')}");
                    Navigator.of(this.context).pop();
                  }).catchError((onError) {
                    ShowLoading().close(context: this.context, key: _keyLoader);
                    Utils.toast(
                        "${getTranslatedForCurrentUser(this.context, 'xxfailedxx')}  $onError");
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
            getTranslatedForCurrentUser(contextForDialog, 'xxcopyxx'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            Clipboard.setData(ClipboardData(text: mssgDoc[Dbkeys.content]));
            Navigator.pop(contextForDialog);
            hidekeyboard(contextForDialog);
            Utils.toast(
              getTranslatedForCurrentUser(contextForDialog, 'xxcopiedxx'),
            );
          }));
    }

    showDialog(
        context: contextForDialog,
        builder: (contextForDialog) {
          return SimpleDialog(children: tiles);
        });
  }

  Widget selectablelinkify(String? text, double? fontsize) {
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
              style: TextStyle(fontSize: fontsize, color: Colors.black87),
              text: text!,
              onOpen: (link) async {
                custom_url_launcher(link.url);
              },
            ),
            errorWidget: SelectableLinkify(
              style: TextStyle(fontSize: fontsize, color: Colors.black87),
              text: text,
              onOpen: (link) async {
                custom_url_launcher(link.url);
              },
            ),
            link: text,
            linkPreviewStyle: LinkPreviewStyle.large,
          );
  }

  Widget getTextMessage(bool isMe, Map<String, dynamic> doc, bool saved) {
    return doc.containsKey(Dbkeys.isReply) == true
        ? doc[Dbkeys.isReply] == true
            ? Column(
                crossAxisAlignment: isMe == true
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  replyAttachedWidget(this.context, doc[Dbkeys.replyToMsgDoc]),
                  SizedBox(
                    height: 10,
                  ),
                  selectablelinkify(doc[Dbkeys.content], 16),
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
                          selectablelinkify(doc[Dbkeys.content], 16),
                        ],
                      )
                    : selectablelinkify(doc[Dbkeys.content], 16)
                : selectablelinkify(doc[Dbkeys.content], 16)
        : selectablelinkify(doc[Dbkeys.content], 16);
  }

  Widget getLocationMessage(Map<String, dynamic> doc, String? message,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserID;
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
                    )
                  ],
                )
              : Image.asset(
                  'assets/images/mapview.jpg',
                )
          : Image.asset(
              'assets/images/mapview.jpg',
            ),
    );
  }

  Widget getAudiomessage(
      BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false, bool isMe = true}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      // width: 250,
      // height: 116,
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
      BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserID;
    return SizedBox(
      width: 220,
      height: 116,
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
                            getTranslatedForCurrentUser(
                                this.context, 'xxpreviewxx'),
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
                                this.context, 'xxdownloadxx'),
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
                      getTranslatedForCurrentUser(this.context, 'xxdownloadxx'),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.blue[400]))),
        ],
      ),
    );
  }

  Widget getImageMessage(Map<String, dynamic> doc, {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserID;
    return Container(
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
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
                    width: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                    height: doc[Dbkeys.content].contains('giphy') ? 102 : 200.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                )
              : CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueGrey[400]!),
                    ),
                    width: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                    height: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                    padding: EdgeInsets.all(80.0),
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
                          doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                      height:
                          doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                  imageUrl: doc[Dbkeys.content],
                  width: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                  height: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                  fit: BoxFit.cover,
                ),
        ],
      ),
    );
  }

  Widget getTempImageMessage({String? url}) {
    return url == null
        ? Container(
            child: Image.file(
              pickedFile!,
              width: url!.contains('giphy') ? 120 : 200.0,
              height: url.contains('giphy') ? 120 : 200.0,
              fit: BoxFit.cover,
            ),
          )
        : getImageMessage({Dbkeys.content: url});
  }

  Widget getVideoMessage(
      BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false}) {
    Map<dynamic, dynamic>? meta =
        jsonDecode((message.split('-BREAK-')[2]).toString());
    final bool isMe = doc[Dbkeys.from] == currentUserID;
    return InkWell(
      onTap: () {
        Navigator.push(
            this.context,
            new MaterialPageRoute(
                builder: (context) => new PreviewVideo(
                      isdownloadallowed: true,
                      filename: message.split('-BREAK-').length > 3
                          ? message.split('-BREAK-')[3]
                          : "Video-${DateTime.now().millisecondsSinceEpoch}.mp4",
                      id: null,
                      videourl: message.split('-BREAK-')[0],
                      aspectratio: meta!["width"] / meta["height"],
                    )));
      },
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
            height: 197,
            width: 197,
            child: Stack(
              children: [
                CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueGrey[400]!),
                    ),
                    width: 197,
                    height: 197,
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
                      width: 197,
                      height: 197,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(0.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                  imageUrl: message.split('-BREAK-')[1],
                  width: 197,
                  height: 197,
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black.withOpacity(0.4),
                  height: 197,
                  width: 197,
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
    );
  }

  Widget getContactMessage(
      BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserID;
    return SizedBox(
      width: 250,
      height: 130,
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
            leading: customCircleAvatar(url: null),
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
          Divider(
            height: 7,
          ),
        ],
      ),
    );
  }

  _onEmojiSelected(Emoji emoji) {
    textEditingController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
  }

  _onBackspacePressed() {
    textEditingController
      ..text = textEditingController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
  }

  Widget buildMessage(BuildContext context, Map<String, dynamic> doc,
      {bool saved = false, List<Message>? savedMsgs}) {
    final observer = Provider.of<Observer>(context, listen: false);
    final bool isMe = doc[Dbkeys.from] == currentUserID;
    bool isContinuing;
    if (savedMsgs == null)
      isContinuing =
          messages.isNotEmpty ? messages.last.from == doc[Dbkeys.from] : false;
    else {
      isContinuing = savedMsgs.isNotEmpty
          ? savedMsgs.last.from == doc[Dbkeys.from]
          : false;
    }
    bool isContainURL = false;
    try {
      isContainURL = Uri.tryParse(doc[Dbkeys.content]!) == null
          ? false
          : Uri.tryParse(doc[Dbkeys.content]!)!.isAbsolute;
    } on Exception catch (_) {
      isContainURL = false;
    }
    return SeenProvider(
        timestamp: doc[Dbkeys.timestamp].toString(),
        data: seenState,
        child: Bubble(
            isURLtext: doc[Dbkeys.messageType] == MessageType.text.index &&
                isContainURL == true,
            mssgDoc: doc,
            is24hrsFormat: observer.is24hrsTimeformat,
            isMssgDeleted: doc[Dbkeys.hasSenderDeleted],
            isBroadcastMssg: doc.containsKey(Dbkeys.isbroadcast) == true
                ? doc[Dbkeys.isbroadcast]
                : false,
            messagetype: doc[Dbkeys.messageType] == MessageType.text.index
                ? MessageType.text
                : doc[Dbkeys.messageType] == MessageType.contact.index
                    ? MessageType.contact
                    : doc[Dbkeys.messageType] == MessageType.location.index
                        ? MessageType.location
                        : doc[Dbkeys.messageType] == MessageType.image.index
                            ? MessageType.image
                            : doc[Dbkeys.messageType] == MessageType.video.index
                                ? MessageType.video
                                : doc[Dbkeys.messageType] ==
                                        MessageType.doc.index
                                    ? MessageType.doc
                                    : doc[Dbkeys.messageType] ==
                                            MessageType.audio.index
                                        ? MessageType.audio
                                        : MessageType.text,
            child: doc[Dbkeys.messageType] == MessageType.text.index
                ? getTextMessage(isMe, doc, saved)
                : doc[Dbkeys.messageType] == MessageType.location.index
                    ? getLocationMessage(doc, doc[Dbkeys.content], saved: false)
                    : doc[Dbkeys.messageType] == MessageType.doc.index
                        ? getDocmessage(context, doc, doc[Dbkeys.content],
                            saved: false)
                        : doc[Dbkeys.messageType] == MessageType.audio.index
                            ? getAudiomessage(context, doc, doc[Dbkeys.content],
                                isMe: isMe, saved: false)
                            : doc[Dbkeys.messageType] == MessageType.video.index
                                ? getVideoMessage(
                                    context, doc, doc[Dbkeys.content],
                                    saved: false)
                                : doc[Dbkeys.messageType] ==
                                        MessageType.contact.index
                                    ? getContactMessage(
                                        context, doc, doc[Dbkeys.content],
                                        saved: false)
                                    : getImageMessage(
                                        doc,
                                        saved: saved,
                                      ),
            isMe: isMe,
            timestamp: doc[Dbkeys.timestamp],
            delivered:
                _cachedModel.getMessageStatus(peerUID, doc[Dbkeys.timestamp]),
            isContinuing: isContinuing));
  }

  replyAttachedWidget(BuildContext context, var doc) {
    return Flexible(
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
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Row(children: [
                    Container(
                      decoration: BoxDecoration(
                        color: doc[Dbkeys.from] == currentUserID
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
                              doc[Dbkeys.from] == currentUserID
                                  ? getTranslatedForCurrentUser(
                                      this.context, 'xxyouxx')
                                  : Utils.getNickname(peer!)!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: doc[Dbkeys.from] == currentUserID
                                      ? Mycolors.agentPrimary
                                      : Colors.purple),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          doc[Dbkeys.messageType] == MessageType.text.index
                              ? Text(
                                  doc[Dbkeys.content],
                                  overflow: TextOverflow.ellipsis,
                                  // textAlign:  doc[Dbkeys.from] == currentUserID? TextAlign.end: TextAlign.start,
                                  maxLines: 1,
                                )
                              : doc[Dbkeys.messageType] == MessageType.doc.index
                                  ? Container(
                                      padding: const EdgeInsets.only(right: 70),
                                      child: Text(
                                        doc[Dbkeys.content].split('-BREAK-')[1],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    )
                                  : Text(
                                      getTranslatedForCurrentUser(
                                          this.context,
                                          doc[Dbkeys.messageType] ==
                                                  MessageType.image.index
                                              ? 'xxnimxx'
                                              : doc[Dbkeys.messageType] ==
                                                      MessageType.video.index
                                                  ? 'xxnvmxx'
                                                  : doc[Dbkeys.messageType] ==
                                                          MessageType
                                                              .audio.index
                                                      ? 'xxnamxx'
                                                      : doc[Dbkeys.messageType] ==
                                                              MessageType
                                                                  .contact.index
                                                          ? 'xxncmxx'
                                                          : doc[Dbkeys.messageType] ==
                                                                  MessageType
                                                                      .location
                                                                      .index
                                                              ? 'xxnlmxx'
                                                              : doc[Dbkeys.messageType] ==
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
              doc[Dbkeys.messageType] == MessageType.text.index ||
                      doc[Dbkeys.messageType] == MessageType.location.index
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
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Mycolors.loadingindicator),
                                  ),
                                  width: doc[Dbkeys.content].contains('giphy')
                                      ? 60
                                      : 60.0,
                                  height: doc[Dbkeys.content].contains('giphy')
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
                      : doc[Dbkeys.messageType] == MessageType.video.index
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
                                                          Mycolors
                                                              .loadingindicator),
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
                                              imageUrl: doc[Dbkeys.content]
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
                                          color: doc[Dbkeys.messageType] ==
                                                  MessageType.doc.index
                                              ? Colors.yellow[800]
                                              : doc[Dbkeys.messageType] ==
                                                      MessageType.audio.index
                                                  ? Colors.green[400]
                                                  : doc[Dbkeys.messageType] ==
                                                          MessageType
                                                              .location.index
                                                      ? Colors.red[700]
                                                      : doc[Dbkeys.messageType] ==
                                                              MessageType
                                                                  .contact.index
                                                          ? Colors.blue[400]
                                                          : Colors.cyan[700],
                                          height: 74,
                                          width: 74,
                                          child: Icon(
                                            doc[Dbkeys.messageType] ==
                                                    MessageType.doc.index
                                                ? Icons.insert_drive_file
                                                : doc[Dbkeys.messageType] ==
                                                        MessageType.audio.index
                                                    ? Icons.mic_rounded
                                                    : doc[Dbkeys.messageType] ==
                                                            MessageType
                                                                .location.index
                                                        ? Icons.location_on
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
    );
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
                        color: replyDoc![Dbkeys.from] == currentUserID
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
                              replyDoc![Dbkeys.from] == currentUserID
                                  ? getTranslatedForCurrentUser(
                                      this.context, 'xxyouxx')
                                  : Utils.getNickname(peer!)!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: replyDoc![Dbkeys.from] == currentUserID
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
                                      maxLines: 2,
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
                                                          Mycolors
                                                              .loadingindicator),
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
                                              ? Colors.yellow[800]
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

  Widget buildTempMessage(BuildContext context, MessageType type, content,
      timestamp, delivered, tempDoc) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    final bool isMe = true;
    bool isContainURL = false;
    try {
      isContainURL = Uri.tryParse(tempDoc[Dbkeys.tempcontent]!) == null
          ? false
          : Uri.tryParse(tempDoc[Dbkeys.tempcontent]!)!.isAbsolute;
    } on Exception catch (_) {
      isContainURL = false;
    }
    return SeenProvider(
        timestamp: timestamp.toString(),
        data: seenState,
        child: Bubble(
          isURLtext: tempDoc[Dbkeys.messageType] == MessageType.text.index &&
              isContainURL == true,
          mssgDoc: tempDoc,
          is24hrsFormat: observer.is24hrsTimeformat,
          isMssgDeleted: tempDoc[Dbkeys.hasSenderDeleted],
          isBroadcastMssg: false,
          messagetype: type,
          child: type == MessageType.text
              ? getTextMessage(isMe, tempDoc, false)
              : type == MessageType.location
                  ? getLocationMessage(tempDoc, content, saved: false)
                  : type == MessageType.doc
                      ? getDocmessage(context, tempDoc, content, saved: false)
                      : type == MessageType.audio
                          ? getAudiomessage(context, tempDoc, content,
                              saved: false, isMe: isMe)
                          : type == MessageType.video
                              ? getVideoMessage(this.context, tempDoc, content,
                                  saved: false)
                              : type == MessageType.contact
                                  ? getContactMessage(context, tempDoc, content,
                                      saved: false)
                                  : getTempImageMessage(url: content),
          isMe: isMe,
          timestamp: timestamp,
          delivered: delivered,
          isContinuing:
              messages.isNotEmpty && messages.last.from == currentUserID,
        ));
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
              color: Mycolors.white.withOpacity(0.6),
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
                                                    String finalUrl = url +
                                                        '-BREAK-' +
                                                        basename(pickedFile!
                                                                .path)
                                                            .toString();
                                                    onSendMessage(
                                                        this.context,
                                                        finalUrl,
                                                        MessageType.doc,
                                                        time);
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
                                                    onSendMessage(
                                                        this.context,
                                                        videoUrl +
                                                            '-BREAK-' +
                                                            thumnailUrl +
                                                            '-BREAK-' +
                                                            videometadata! +
                                                            '-BREAK-' +
                                                            videofileName,
                                                        MessageType.video,
                                                        timeStamp);

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
                                            if (observer
                                                    .checkIfCurrentUserIsDemo(
                                                        widget.currentUserID) ==
                                                true) {
                                              Utils.toast(
                                                  getTranslatedForCurrentUser(
                                                      context,
                                                      'xxxnotalwddemoxxaccountxx'));
                                            } else {
                                              setStatusBarColor();

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
                                                    this.context,
                                                    url,
                                                    MessageType.image,
                                                    timeStamp);
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
                                      onSendMessage(
                                          context,
                                          url +
                                              '-BREAK-' +
                                              uploadTimestamp.toString(),
                                          MessageType.audio,
                                          uploadTimestamp);
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
                                              this.context,
                                              locationstring,
                                              MessageType.location,
                                              DateTime.now()
                                                  .millisecondsSinceEpoch);
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

    Reference reference =
        FirebaseStorage.instance.ref("+00_CHAT_MEDIA/$chatId/").child(fileName);

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
                            onPressed: isMessageLoading == true
                                ? null
                                : () {
                                    refreshThisInput();
                                  },
                            icon: Icon(
                              Icons.emoji_emotions,
                              size: 23,
                              color: Mycolors.grey,
                            ),
                          ),
                        ),
                        Flexible(
                          child: TextField(
                            onTap: isMessageLoading == true
                                ? null
                                : () {
                                    if (isemojiShowing == true) {
                                    } else {
                                      keyboardFocusNode.requestFocus();
                                      setStateIfMounted(() {});
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
                                          onPressed: isMessageLoading == true
                                              ? null
                                              : observer.ismediamessagingallowed ==
                                                      false
                                                  ? () {
                                                      Utils.showRationale(
                                                          getTranslatedForCurrentUser(
                                                              this.context,
                                                              'xxmediamssgnotallowedxx'));
                                                    }
                                                  : chatStatus ==
                                                          ChatStatus
                                                              .blocked.index
                                                      ? () {
                                                          Utils.toast(
                                                              getTranslatedForCurrentUser(
                                                                  this.context,
                                                                  'unlck'));
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
                                          onPressed: isMessageLoading == true
                                              ? null
                                              : observer.ismediamessagingallowed ==
                                                      false
                                                  ? () {
                                                      Utils.showRationale(
                                                          getTranslatedForCurrentUser(
                                                              this.context,
                                                              'xxmediamssgnotallowedxx'));
                                                    }
                                                  : chatStatus ==
                                                          ChatStatus
                                                              .blocked.index
                                                      ? () {
                                                          Utils.toast(
                                                              getTranslatedForCurrentUser(
                                                                  this.context,
                                                                  'unlck'));
                                                        }
                                                      : () async {
                                                          hidekeyboard(context);
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
                                                                                      onSendMessage(this.context, videoUrl + '-BREAK-' + thumnailUrl + '-BREAK-' + videometadata! + '-BREAK-' + "$videofileName", MessageType.video, timeStamp);
                                                                                      await file.delete();
                                                                                      await thumnail.delete();
                                                                                    }
                                                                                  }
                                                                                } else {
                                                                                  String imageFileext = p.extension(file.path);
                                                                                  String imagefileName = 'IMG-$timeStamp$imageFileext';
                                                                                  String? url = await uploadSelectedLocalFileWithProgressIndicator(file, false, false, timeStamp, filenameoptional: imagefileName);
                                                                                  if (url != null) {
                                                                                    onSendMessage(this.context, url, MessageType.image, timeStamp);
                                                                                    await file.delete();
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
                                                                .currentUserID) ==
                                                    true
                                                ? () {
                                                    Utils.toast(
                                                        getTranslatedForCurrentUser(
                                                            context,
                                                            'xxxnotalwddemoxxaccountxx'));
                                                  }
                                                : isMessageLoading == true
                                                    ? null
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
                                                              lang:
                                                                  GiphyLanguage
                                                                      .english,
                                                            );
                                                            if (gif != null &&
                                                                mounted) {
                                                              onSendMessage(
                                                                  context,
                                                                  gif
                                                                      .images!
                                                                      .original!
                                                                      .url,
                                                                  MessageType
                                                                      .image,
                                                                  DateTime.now()
                                                                      .millisecondsSinceEpoch);
                                                              hidekeyboard(
                                                                  context);
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
                // Button send message
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
                        textEditingController.text.length == 0
                            ? Icons.mic
                            : Icons.send,
                        color: Mycolors.white.withOpacity(0.99),
                      ),
                      onPressed: observer.checkIfCurrentUserIsDemo(
                                  widget.currentUserID) ==
                              true
                          ? () {
                              Utils.toast(getTranslatedForCurrentUser(
                                  context, 'xxxnotalwddemoxxaccountxx'));
                            }
                          : isMessageLoading == true
                              ? null
                              : observer.ismediamessagingallowed == true
                                  ? textEditingController.text.length == 0
                                      ? () {
                                          hidekeyboard(context);

                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AudioRecord(
                                                        title:
                                                            getTranslatedForCurrentUser(
                                                                this.context,
                                                                'xxrecordxx'),
                                                        callback: getFileData,
                                                      ))).then((url) {
                                            if (url != null) {
                                              onSendMessage(
                                                  context,
                                                  url +
                                                      '-BREAK-' +
                                                      uploadTimestamp
                                                          .toString(),
                                                  MessageType.audio,
                                                  uploadTimestamp);
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
                                          : chatStatus ==
                                                  ChatStatus.blocked.index
                                              ? null
                                              : () => onSendMessage(
                                                  context,
                                                  textEditingController.text,
                                                  MessageType.text,
                                                  DateTime.now()
                                                      .millisecondsSinceEpoch)
                                  : () {
                                      Utils.showRationale(
                                          getTranslatedForCurrentUser(
                                              this.context,
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

  bool empty = true;

  loadMessagesAndListen() async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionAgentIndividiualmessages)
        .doc(chatId)
        .collection(chatId!)
        .orderBy(Dbkeys.timestamp)
        .get()
        .then((docs) {
      if (docs.docs.isNotEmpty) {
        empty = false;
        docs.docs.forEach((doc) {
          Map<String, dynamic> _doc = Map.from(doc.data());
          int? ts = _doc[Dbkeys.timestamp];

          messages.add(Message(buildMessage(this.context, _doc),
              onDismiss:
                  _doc[Dbkeys.content] == '' || _doc[Dbkeys.content] == null
                      ? () {}
                      : () {
                          setStateIfMounted(() {
                            isReplyKeyboard = true;
                            replyDoc = _doc;
                          });
                          HapticFeedback.heavyImpact();
                          keyboardFocusNode.requestFocus();
                        },
              onTap: (_doc[Dbkeys.from] == widget.currentUserID &&
                          _doc[Dbkeys.hasSenderDeleted] == true) ==
                      true
                  ? () {}
                  : _doc[Dbkeys.messageType] == MessageType.image.index
                      ? () {
                          Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                builder: (context) => PhotoViewWrapper(
                                  keyloader: _keyLoader,
                                  imageUrl: _doc[Dbkeys.content],
                                  message: _doc[Dbkeys.content],
                                  tag: ts.toString(),
                                  imageProvider: CachedNetworkImageProvider(
                                      _doc[Dbkeys.content]),
                                ),
                              ));
                        }
                      : null,
              onDoubleTap: _doc.containsKey(Dbkeys.broadcastID) ? () {} : () {},
              onLongPress: () {
            if ((_doc[Dbkeys.from] == widget.currentUserID &&
                    _doc[Dbkeys.hasSenderDeleted] == true) ==
                false) {
              //--Show Menu only if message is not deleted by current user already
              contextMenuNew(this.context, _doc, false);
            }
          }, from: _doc[Dbkeys.from], timestamp: ts));

          if (doc.data()[Dbkeys.timestamp] ==
              docs.docs.last.data()[Dbkeys.timestamp]) {
            setStateIfMounted(() {
              isMessageLoading = false;
              // print('All message loaded..........');
            });
          }
        });
      } else {
        setStateIfMounted(() {
          isMessageLoading = false;
          // print('All message loaded..........');
        });
      }
      if (mounted) {
        setStateIfMounted(() {
          messages = List.from(messages);
          isMessageLoading = false;
        });
      }
      msgSubscription = FirebaseFirestore.instance
          .collection(DbPaths.collectionAgentIndividiualmessages)
          .doc(chatId)
          .collection(chatId!)
          .where(Dbkeys.from, isEqualTo: peerUID)
          .snapshots()
          .listen((query) {
        if (empty == true || query.docs.length != query.docChanges.length) {
          //----below action triggers when peer new message arrives
          query.docChanges.where((doc) {
            return doc.oldIndex <= doc.newIndex &&
                doc.type == DocumentChangeType.added;

            //  &&
            //     query.docs[doc.oldIndex][Dbkeys.timestamp] !=
            //         query.docs[doc.newIndex][Dbkeys.timestamp];
          }).forEach((change) {
            Map<String, dynamic> _doc = Map.from(change.doc.data()!);
            int? ts = _doc[Dbkeys.timestamp];

            messages.add(Message(
              buildMessage(this.context, _doc),
              onDismiss:
                  _doc[Dbkeys.content] == '' || _doc[Dbkeys.content] == null
                      ? () {}
                      : () {
                          setStateIfMounted(() {
                            isReplyKeyboard = true;
                            replyDoc = _doc;
                          });
                          HapticFeedback.heavyImpact();
                          keyboardFocusNode.requestFocus();
                        },
              onLongPress: () {
                if ((_doc[Dbkeys.from] == widget.currentUserID &&
                        _doc[Dbkeys.hasSenderDeleted] == true) ==
                    false) {
                  //--Show Menu only if message is not deleted by current user already
                  contextMenuNew(this.context, _doc, false);
                }
              },
              onTap: (_doc[Dbkeys.from] == widget.currentUserID &&
                          _doc[Dbkeys.hasSenderDeleted] == true) ==
                      true
                  ? () {}
                  : _doc[Dbkeys.messageType] == MessageType.image.index
                      ? () {
                          Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                builder: (context) => PhotoViewWrapper(
                                  keyloader: _keyLoader,
                                  imageUrl: _doc[Dbkeys.content],
                                  message: _doc[Dbkeys.content],
                                  tag: ts.toString(),
                                  imageProvider: CachedNetworkImageProvider(
                                      _doc[Dbkeys.content]),
                                ),
                              ));
                        }
                      : null,
              onDoubleTap: _doc.containsKey(Dbkeys.broadcastID)
                  ? () {}
                  : () {
                      // save(_doc);
                    },
              from: _doc[Dbkeys.from],
              timestamp: ts,
            ));
          });
          //----below action triggers when peer message get deleted
          query.docChanges.where((doc) {
            return doc.type == DocumentChangeType.removed;
          }).forEach((change) {
            Map<String, dynamic> _doc = Map.from(change.doc.data()!);

            int i = messages.indexWhere(
                (element) => element.timestamp == _doc[Dbkeys.timestamp]);
            if (i >= 0) messages.removeAt(i);
            Save.deleteMessage(peerUID, _doc);
            _savedMessageDocs.removeWhere(
                (msg) => msg[Dbkeys.timestamp] == _doc[Dbkeys.timestamp]);
            setStateIfMounted(() {
              _savedMessageDocs = List.from(_savedMessageDocs);
            });
          }); //----below action triggers when peer message gets modified
          query.docChanges.where((doc) {
            return doc.type == DocumentChangeType.modified;
          }).forEach((change) {
            Map<String, dynamic> _doc = Map.from(change.doc.data()!);

            int i = messages.indexWhere(
                (element) => element.timestamp == _doc[Dbkeys.timestamp]);
            if (i >= 0) {
              messages.removeAt(i);
              setStateIfMounted(() {});
              int? ts = _doc[Dbkeys.timestamp];

              messages.insert(
                  i,
                  Message(
                    buildMessage(this.context, _doc),
                    onLongPress: () {
                      if ((_doc[Dbkeys.from] == widget.currentUserID &&
                              _doc[Dbkeys.hasSenderDeleted] == true) ==
                          false) {
                        //--Show Menu only if message is not deleted by current user already
                        contextMenuNew(this.context, _doc, false);
                      }
                    },
                    onTap: (_doc[Dbkeys.from] == widget.currentUserID &&
                                _doc[Dbkeys.hasSenderDeleted] == true) ==
                            true
                        ? () {}
                        : _doc[Dbkeys.messageType] == MessageType.image.index
                            ? () {
                                Navigator.push(
                                    this.context,
                                    MaterialPageRoute(
                                      builder: (context) => PhotoViewWrapper(
                                        keyloader: _keyLoader,
                                        imageUrl: _doc[Dbkeys.content],
                                        message: _doc[Dbkeys.content],
                                        tag: ts.toString(),
                                        imageProvider:
                                            CachedNetworkImageProvider(
                                                _doc[Dbkeys.content]),
                                      ),
                                    ));
                              }
                            : null,
                    onDoubleTap: _doc.containsKey(Dbkeys.broadcastID)
                        ? () {}
                        : () {
                            // save(_doc);
                          },
                    from: _doc[Dbkeys.from],
                    timestamp: ts,
                    onDismiss: _doc[Dbkeys.content] == '' ||
                            _doc[Dbkeys.content] == null
                        ? () {}
                        : () {
                            setStateIfMounted(() {
                              isReplyKeyboard = true;
                              replyDoc = _doc;
                            });
                            HapticFeedback.heavyImpact();
                            keyboardFocusNode.requestFocus();
                          },
                  ));
            }
          });
          if (mounted) {
            setStateIfMounted(() {
              messages = List.from(messages);
            });
          }
        }
      });

      //----sharing intent action:

      if (widget.isSharingIntentForwarded == true) {
        if (widget.sharedText != null) {
          onSendMessage(this.context, widget.sharedText!, MessageType.text,
              DateTime.now().millisecondsSinceEpoch);
        } else if (widget.sharedFiles != null) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = true;
          });
          uploadEach(0);
        }
      }
    });
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
          onSendMessage(this.context, finalUrl, type, messagetime);
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

  void loadSavedMessages() {
    if (_savedMessageDocs.isEmpty) {
      Save.getSavedMessages(peerUID).then((_msgDocs) {
        // ignore: unnecessary_null_comparison
        if (_msgDocs != null) {
          setStateIfMounted(() {
            _savedMessageDocs = _msgDocs;
          });
        }
      });
    }
  }

//-- GROUP BY DATE ---
  List<Widget> getGroupedMessages() {
    final observer = Provider.of<Observer>(this.context, listen: false);
    List<Widget> _groupedMessages = new List.from(<Widget>[
      Card(
        elevation: 0.5,
        color: Color(0xffFFF2BE),
        margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Container(
            padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2.5, right: 4),
                      child: Icon(
                        EvaIcons.bulb,
                        color: Color(0xff78754A),
                        size: 14,
                      ),
                    ),
                  ),
                  TextSpan(
                      text: observer.userAppSettingsDoc!
                                  .defaultMessageDeletingTimeForOneToOneChat ==
                              0
                          ? getTranslatedForCurrentUser(
                              this.context, 'xxchatroommonitoredxx')
                          : getTranslatedForCurrentUser(
                                  this.context, 'xxchatroommonitoredlongxx')
                              .replaceAll(
                                  '(####)',
                                  observer.userAppSettingsDoc!
                                      .defaultMessageDeletingTimeForOneToOneChat
                                      .toString()),
                      style: TextStyle(
                          color: Color(0xff78754A),
                          height: 1.3,
                          fontSize: 13,
                          fontWeight: FontWeight.w400)),
                ],
              ),
            )),
      ),
    ]);
    int count = 0;
    groupBy<Message, String>(messages, (msg) {
      // return getWhen(DateTime.fromMillisecondsSinceEpoch(msg.timestamp!));
      return "${DateTime.fromMillisecondsSinceEpoch(msg.timestamp!).year}-${DateTime.fromMillisecondsSinceEpoch(msg.timestamp!).month}-${DateTime.fromMillisecondsSinceEpoch(msg.timestamp!).day}";
    }).forEach((when, _actualMessages) {
      // print("whennnnn $when");
      List<String> li = when.split('-');
      var w = getWhen(DateTime(
          int.tryParse(li[0])!, int.tryParse(li[1])!, int.tryParse(li[2])!));
      _groupedMessages.add(Center(
          child: Chip(
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blue[50],
        label: Text(
          w,
          style: TextStyle(
              color: Colors.black54, fontWeight: FontWeight.w400, fontSize: 14),
        ),
      )));
      _actualMessages.forEach((msg) {
        count++;
        if (unread != 0 && (messages.length - count) == unread! - 1) {
          _groupedMessages.add(Center(
              child: Chip(
            backgroundColor: Colors.blueGrey[50],
            label: Text('$unread' +
                getTranslatedForCurrentUser(this.context, 'xxunreadxx')),
          )));
          unread = 0; // reset
        }
        _groupedMessages.add(msg.child);
      });
    });
    return _groupedMessages.reversed.toList();
  }

  Widget buildMessages(
    BuildContext context,
  ) {
    return Flexible(
        child: chatId == '' || messages.isEmpty
            ? ListView(
                children: <Widget>[
                  Card(),
                  Padding(
                      padding: EdgeInsets.only(top: 200.0),
                      child: isMessageLoading == true
                          ? Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Mycolors.loadingindicator)),
                            )
                          : Text(
                              getTranslatedForCurrentUser(
                                  this.context, 'xxsayhixx'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Mycolors.grey, fontSize: 18))),
                ],
                controller: realtime,
              )
            : ListView(
                padding: EdgeInsets.all(10.0),
                children: getGroupedMessages(),
                controller: realtime,
                reverse: true,
              ));
  }

  getWhen(date) {
    DateTime now = DateTime.now();
    String when;
    if (date.day == now.day)
      when = getTranslatedForCurrentUser(this.context, 'xxtodayxx');
    else if (date.day == now.subtract(Duration(days: 1)).day)
      when = getTranslatedForCurrentUser(this.context, 'xxyesterdayxx');
    else
      when = IsShowNativeTimDate == true
          ? getTranslatedForCurrentUser(
                  this.context, DateFormat.MMMM().format(date)) +
              ' ' +
              DateFormat.d().format(date)
          : when = DateFormat.MMMd().format(date);
    return when;
  }

  getPeerStatus(val) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    if (val is bool && val == true) {
      return getTranslatedForCurrentUser(this.context, 'xxonlinexx');
    } else if (val is int) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(val);
      String at = observer.is24hrsTimeformat == false
              ? DateFormat.jm().format(date)
              : DateFormat('HH:mm').format(date),
          when = getWhen(date);
      return getTranslatedForCurrentUser(this.context, 'xxlastseenxx') +
          ' $when, $at';
    } else if (val is String) {
      if (val == currentUserID)
        return getTranslatedForCurrentUser(this.context, 'xxtypingxx');
      return getTranslatedForCurrentUser(this.context, 'xxonlinexx');
    }
    return getTranslatedForCurrentUser(this.context, 'xxloadingxx');
  }

  bool isBlocked() {
    return chatStatus == ChatStatus.blocked.index;
  }

  call(BuildContext context, bool isvideocall, bool isShowNameAndPhotoToDialer,
      bool isShowNameAndPhotoToReciever) async {
    var mynickname = widget.prefs.getString(Dbkeys.nickname) ?? '';

    var myphotoUrl = widget.prefs.getString(Dbkeys.photoUrl) ?? '';

    CallUtils.dial(
        callSessionID: DateTime.now().millisecondsSinceEpoch.toString(),
        callSessionInitatedBy: widget.currentUserID,
        callTypeindex: CallTypeIndex.callToAgentFromAgentInPERSONAL.index,
        isShowCallernameAndPhotoToDialler: isShowNameAndPhotoToDialer,
        isShowCallernameAndPhotoToReciever: isShowNameAndPhotoToReciever,
        prefs: widget.prefs,
        currentUserID: widget.currentUserID,
        fromDp: myphotoUrl,
        fromUID: widget.currentUserID,
        fromFullname: mynickname,
        toUID: widget.peerUID,
        toFullname: peer![Dbkeys.nickname],
        context: context,
        isvideocall: isvideocall);
  }

  bool isemojiShowing = false;
  refreshInput() {
    setStateIfMounted(() {
      if (isemojiShowing == false) {
        // hidekeyboard(this.context);
        keyboardFocusNode.unfocus();
        isemojiShowing = true;
      } else {
        isemojiShowing = false;
        keyboardFocusNode.requestFocus();
      }
    });
  }

  showDialOptions(BuildContext context, bool isShowNameAndPhotoToDialer,
      bool isShowNameAndPhotoToReciever) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Consumer<Observer>(
              builder: (context, observer, _child) => Container(
                  padding: EdgeInsets.all(12),
                  height: 130,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        observer.userAppSettingsDoc!.callTypeForAgents ==
                                    CallType.audio.index ||
                                observer.userAppSettingsDoc!
                                        .callTypeForAgents ==
                                    CallType.both.index
                            ? InkWell(
                                onTap: observer.checkIfCurrentUserIsDemo(
                                            widget.currentUserID) ==
                                        true
                                    ? () {
                                        Utils.toast(getTranslatedForCurrentUser(
                                            context,
                                            'xxxnotalwddemoxxaccountxx'));
                                      }
                                    : hasPeerBlockedMe == true
                                        ? () {
                                            Navigator.of(this.context).pop();
                                            Utils.toast(
                                              getTranslatedForCurrentUser(
                                                  context,
                                                  'xxuserhasblockedxx'),
                                            );
                                          }
                                        : () async {
                                            final observer =
                                                Provider.of<Observer>(
                                                    this.context,
                                                    listen: false);
                                            if (IsInterstitialAdShow == true &&
                                                observer.isadmobshow == true) {}

                                            await Permissions
                                                    .cameraAndMicrophonePermissionsGranted()
                                                .then((isgranted) {
                                              if (isgranted == true) {
                                                Navigator.of(this.context)
                                                    .pop();
                                                call(
                                                    this.context,
                                                    false,
                                                    isShowNameAndPhotoToDialer,
                                                    isShowNameAndPhotoToReciever);
                                              } else {
                                                Navigator.of(this.context)
                                                    .pop();
                                                Utils.showRationale(
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxpmcxx'));
                                                Navigator.push(
                                                    context,
                                                    new MaterialPageRoute(
                                                        builder: (context) =>
                                                            OpenSettings()));
                                              }
                                            }).catchError((onError) {
                                              Utils.showRationale(
                                                  getTranslatedForCurrentUser(
                                                      this.context, 'xxpmcxx'));
                                              Navigator.push(
                                                  context,
                                                  new MaterialPageRoute(
                                                      builder: (context) =>
                                                          OpenSettings()));
                                            });
                                          },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 13),
                                      Icon(
                                        Icons.local_phone,
                                        size: 35,
                                        color: Mycolors.agentSecondary,
                                      ),
                                      SizedBox(height: 13),
                                      Text(
                                        getTranslatedForCurrentUser(
                                            context, 'xxaudiocallxx'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                            color: Mycolors.blackDynamic),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(),
                        observer.userAppSettingsDoc!.callTypeForAgents ==
                                    CallType.video.index ||
                                observer.userAppSettingsDoc!
                                        .callTypeForAgents ==
                                    CallType.both.index
                            ? InkWell(
                                onTap: observer.checkIfCurrentUserIsDemo(
                                            widget.currentUserID) ==
                                        true
                                    ? () {
                                        Utils.toast(getTranslatedForCurrentUser(
                                            context,
                                            'xxxnotalwddemoxxaccountxx'));
                                      }
                                    : hasPeerBlockedMe == true
                                        ? () {
                                            Navigator.of(this.context).pop();
                                            Utils.toast(
                                              getTranslatedForCurrentUser(
                                                  context,
                                                  'xxuserhasblockedxx'),
                                            );
                                          }
                                        : () async {
                                            final observer =
                                                Provider.of<Observer>(
                                                    this.context,
                                                    listen: false);

                                            if (IsInterstitialAdShow == true &&
                                                observer.isadmobshow == true) {}

                                            await Permissions
                                                    .cameraAndMicrophonePermissionsGranted()
                                                .then((isgranted) {
                                              if (isgranted == true) {
                                                Navigator.of(this.context)
                                                    .pop();
                                                call(
                                                    this.context,
                                                    true,
                                                    isShowNameAndPhotoToDialer,
                                                    isShowNameAndPhotoToReciever);
                                              } else {
                                                Navigator.of(this.context)
                                                    .pop();
                                                Utils.showRationale(
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxpmcxx'));
                                                Navigator.push(
                                                    context,
                                                    new MaterialPageRoute(
                                                        builder: (context) =>
                                                            OpenSettings()));
                                              }
                                            }).catchError((onError) {
                                              Utils.showRationale(
                                                  getTranslatedForCurrentUser(
                                                      this.context, 'xxpmcxx'));
                                              Navigator.push(
                                                  context,
                                                  new MaterialPageRoute(
                                                      builder: (context) =>
                                                          OpenSettings()));
                                            });
                                          },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 13),
                                      Icon(
                                        Icons.videocam,
                                        size: 39,
                                        color: Mycolors.agentSecondary,
                                      ),
                                      SizedBox(height: 13),
                                      Text(
                                        getTranslatedForCurrentUser(
                                            context, 'xxvideocallxx'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                            color: Mycolors.black),
                                      ),
                                    ],
                                  ),
                                ))
                            : SizedBox()
                      ])));
        });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    // final observer = Provider.of<Observer>(context, listen: true);
    var _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    // SpecialLiveConfigData? livedata =
    //     Provider.of<SpecialLiveConfigData?>(context, listen: true);
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
                      setState(() {
                        isemojiShowing = false;
                        keyboardFocusNode.unfocus();
                      });
                      return Future.value(false);
                    }
                  : () async {
                      setLastSeen();
                      WidgetsBinding.instance
                          .addPostFrameCallback((timeStamp) async {
                        var currentpeer = Provider.of<CurrentChatPeer>(
                            this.context,
                            listen: false);
                        currentpeer.setpeer('');
                        if (lastSeen == peerUID)
                          await FirebaseFirestore.instance
                              .collection(DbPaths.collectionagents)
                              .doc(currentUserID)
                              .update(
                            {Dbkeys.lastSeen: true},
                          );
                      });

                      return Future.value(true);
                    },
          child: ScopedModel<DataModel>(
              model: _cachedModel,
              child: ScopedModelDescendant<DataModel>(
                  builder: (context, child, _model) {
                _cachedModel = _model;
                updateLocalUserData(_model);
                final observer =
                    Provider.of<Observer>(this.context, listen: true);

                SpecialLiveConfigData? livedata =
                    Provider.of<SpecialLiveConfigData?>(context, listen: true);
                bool isShownamePhoto = observer.userAppSettingsDoc!
                            .agentcanseeagentnameandphoto! ==
                        true ||
                    (iAmSecondAdmin(
                                specialLiveConfigData: livedata,
                                currentuserid: currentUserID!,
                                context: context) ==
                            true &&
                        observer.userAppSettingsDoc!
                                .secondadmincanseeagentnameandphoto ==
                            true) ||
                    (iAmDepartmentManager(
                                currentuserid: currentUserID!,
                                context: context) ==
                            true &&
                        observer.userAppSettingsDoc!
                                .departmentmanagercanseeagentnameandphoto ==
                            true);
                return peer != null
                    ? Stack(
                        children: [
                          Scaffold(
                              key: _scaffold,
                              appBar: AppBar(
                                elevation: 0.4,
                                titleSpacing: -14,
                                leading: Container(
                                  margin: EdgeInsets.only(right: 0),
                                  width: 10,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.arrow_back_ios,
                                      size: 20,
                                      color: Mycolors.black,
                                    ),
                                    onPressed: () {
                                      if (isDeletedDoc == true) {
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                AppWrapper(
                                              loadAttempt: 0,
                                            ),
                                          ),
                                          (Route route) => false,
                                        );
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                ),
                                backgroundColor: Mycolors.white,
                                title: InkWell(
                                    onTap: () {
                                      // Navigator.push(
                                      //     context,
                                      //     PageRouteBuilder(
                                      //         opaque: false,
                                      //         pageBuilder: (context, a1, a2) =>
                                      //             ProfileView(
                                      //               peer!,
                                      //               widget.currentUserID,
                                      //               _cachedModel,
                                      //               widget.prefs,
                                      //             )));
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        isShownamePhoto == true
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 7, 0, 7),
                                                child: Utils.avatar(peer,
                                                    radius: 20),
                                              )
                                            : SizedBox(
                                                width: 5,
                                              ),
                                        SizedBox(
                                          width: 7,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(this.context)
                                                      .size
                                                      .width /
                                                  2.3,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    isShownamePhoto == true
                                                        ? Utils.getNickname(
                                                            peer!)!
                                                        : "${getTranslatedForCurrentUser(context, 'xxagentidxx')} $peerUID",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        color: Mycolors.black,
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  isCurrentUserMuted
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5.0),
                                                          child: Icon(
                                                            Icons.volume_off,
                                                            color: Mycolors
                                                                .black
                                                                .withOpacity(
                                                                    0.5),
                                                            size: 17,
                                                          ),
                                                        )
                                                      : SizedBox(),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            chatId != null
                                                ? Text(
                                                    getPeerStatus(
                                                        peer![Dbkeys.lastSeen]),
                                                    style: TextStyle(
                                                        color: Mycolors.grey,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  )
                                                : Text(
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxloadingxx'),
                                                    style: TextStyle(
                                                        color: Mycolors.grey,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                          ],
                                        ),
                                      ],
                                    )),
                                actions: [
                                  observer.userAppSettingsDoc!.iscallsallowed ==
                                          false
                                      ? SizedBox()
                                      : observer.userAppSettingsDoc!
                                                      .agentCanCallAgents! ==
                                                  true ||
                                              (iAmSecondAdmin(
                                                          specialLiveConfigData:
                                                              livedata,
                                                          currentuserid: widget
                                                              .currentUserID,
                                                          context: context) ==
                                                      true &&
                                                  observer.userAppSettingsDoc!
                                                          .secondadminCanCallAgents ==
                                                      true)
                                          ? SizedBox(
                                              width: 55,
                                              child: IconButton(
                                                  icon: Icon(
                                                    Icons.add_call,
                                                    color:
                                                        Mycolors.agentPrimary,
                                                  ),
                                                  onPressed:
                                                      hasPeerBlockedMe == true
                                                          ? () {
                                                              Utils.toast(
                                                                getTranslatedForCurrentUser(
                                                                    context,
                                                                    'xxuserhasblockedxx'),
                                                              );
                                                            }
                                                          : () async {
                                                              showDialOptions(
                                                                  this.context,
                                                                  observer.userAppSettingsDoc!
                                                                              .agentcanseeagentnameandphoto! ==
                                                                          true ||
                                                                      (iAmSecondAdmin(specialLiveConfigData: livedata, currentuserid: widget.currentUserID, context: context) == true &&
                                                                          observer.userAppSettingsDoc!.secondadmincanseeagentnameandphoto ==
                                                                              true) ||
                                                                      (iAmDepartmentManager(currentuserid: widget.currentUserID, context: context) ==
                                                                              true &&
                                                                          observer.userAppSettingsDoc!.departmentmanagercanseeagentnameandphoto ==
                                                                              true),
                                                                  observer.userAppSettingsDoc!
                                                                              .agentcanseeagentnameandphoto! ==
                                                                          true ||
                                                                      (iAmSecondAdmin(specialLiveConfigData: livedata, currentuserid: widget.peerUID, context: context) ==
                                                                              true &&
                                                                          observer.userAppSettingsDoc!.secondadmincanseeagentnameandphoto ==
                                                                              true) ||
                                                                      (iAmDepartmentManager(currentuserid: widget.peerUID, context: context) ==
                                                                              true &&
                                                                          observer.userAppSettingsDoc!.departmentmanagercanseeagentnameandphoto ==
                                                                              true));
                                                            }),
                                            )
                                          : SizedBox(),
                                  SizedBox(
                                    width: 25,
                                    child: PopupMenuButton(
                                        padding: EdgeInsets.all(0),
                                        icon: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 10),
                                          child: Icon(
                                            Icons.more_vert_outlined,
                                            color: Mycolors.black,
                                          ),
                                        ),
                                        color: Mycolors.white,
                                        onSelected: (dynamic val) {
                                          switch (val) {
                                            case 'report':
                                              showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  context: context,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                    25.0)),
                                                  ),
                                                  builder:
                                                      (BuildContext context) {
                                                    // return your layout
                                                    var w =
                                                        MediaQuery.of(context)
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
                                                              EdgeInsets.all(
                                                                  16),
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height /
                                                              2.6,
                                                          child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
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
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left: 7),
                                                                  child: Text(
                                                                    getTranslatedForCurrentUser(
                                                                        this.context,
                                                                        'reportshort'),
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
                                                                          top:
                                                                              10),
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  // height: 63,
                                                                  height: 63,
                                                                  width:
                                                                      w / 1.24,
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
                                                                    boxheight:
                                                                        50,
                                                                    hinttext: getTranslatedForCurrentUser(
                                                                        this.context,
                                                                        'reportdesc'),
                                                                    prefixIconbutton:
                                                                        Icon(
                                                                      Icons
                                                                          .message,
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.5),
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      w / 10,
                                                                ),
                                                                myElevatedButton(
                                                                    color: Mycolors
                                                                        .agentSecondary,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                          10,
                                                                          15,
                                                                          10,
                                                                          15),
                                                                      child:
                                                                          Text(
                                                                        getTranslatedForCurrentUser(
                                                                            context,
                                                                            'xxreportxx'),
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 18),
                                                                      ),
                                                                    ),
                                                                    onPressed: observer.checkIfCurrentUserIsDemo(widget.currentUserID) ==
                                                                            true
                                                                        ? () {
                                                                            Utils.toast(getTranslatedForCurrentUser(context,
                                                                                'xxxnotalwddemoxxaccountxx'));
                                                                          }
                                                                        : () async {
                                                                            Navigator.of(context).pop();

                                                                            DateTime
                                                                                time =
                                                                                DateTime.now();

                                                                            Map<String, dynamic>
                                                                                mapdata =
                                                                                {
                                                                              'title': 'New report by Agent',
                                                                              'desc': '${reportEditingController.text}',
                                                                              'phone': '${widget.currentUserID}',
                                                                              'type': 'Individual Agent Chat',
                                                                              'time': time.millisecondsSinceEpoch,
                                                                              'id': Utils.getChatId(currentUserID, peerUID),
                                                                            };

                                                                            await FirebaseFirestore.instance.collection('reports').doc(time.millisecondsSinceEpoch.toString()).set(mapdata).then((value) async {
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

                                            case 'mute':
                                              FirebaseFirestore.instance
                                                  .collection(DbPaths
                                                      .collectionAgentIndividiualmessages)
                                                  .doc(Utils.getChatId(
                                                      currentUserID, peerUID))
                                                  .update({
                                                "$currentUserID-muted":
                                                    !isCurrentUserMuted,
                                              });
                                              setStateIfMounted(() {
                                                isCurrentUserMuted =
                                                    !isCurrentUserMuted;
                                              });

                                              break;
                                            case 'unmute':
                                              FirebaseFirestore.instance
                                                  .collection(DbPaths
                                                      .collectionAgentIndividiualmessages)
                                                  .doc(Utils.getChatId(
                                                      currentUserID, peerUID))
                                                  .update({
                                                "$currentUserID-muted":
                                                    !isCurrentUserMuted,
                                              });
                                              setStateIfMounted(() {
                                                isCurrentUserMuted =
                                                    !isCurrentUserMuted;
                                              });
                                              break;

                                            case 'block':
                                              if (hasPeerBlockedMe == true) {
                                                Utils.toast(
                                                  getTranslatedForCurrentUser(
                                                      context,
                                                      'xxuserhasblockedxx'),
                                                );
                                              } else {
                                                ChatController.block(
                                                    currentUserID, peerUID);
                                              }
                                              break;
                                            case 'unblock':
                                              if (hasPeerBlockedMe == true) {
                                                Utils.toast(
                                                  getTranslatedForCurrentUser(
                                                      context,
                                                      'xxuserhasblockedxx'),
                                                );
                                              } else {
                                                ChatController.accept(
                                                    currentUserID, peerUID);
                                                Utils.toast(
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'unblocked'));
                                              }

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
                              body: Stack(
                                children: <Widget>[
                                  new Container(
                                    decoration: new BoxDecoration(
                                      color: Mycolors.chatbackground,
                                      image: new DecorationImage(
                                          image: peer![Dbkeys.wallpaper] == null
                                              ? AssetImage(
                                                  "assets/images/background.png")
                                              : Image.file(File(
                                                      peer![Dbkeys.wallpaper]))
                                                  .image,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  PageView(
                                    children: <Widget>[
                                      isDeletedDoc == true
                                          ? Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        15, 60, 15, 15),
                                                child: Text(
                                                    getTranslatedForCurrentUser(
                                                        this.context,
                                                        'xxchatdeletedxx'),
                                                    style: TextStyle(
                                                        color: Mycolors.grey)),
                                              ),
                                            )
                                          : Column(
                                              children: [
                                                // List of messages

                                                buildMessages(context),
                                                // Input content
                                                isBlocked()
                                                    ? AlertDialog(
                                                        backgroundColor:
                                                            Colors.white,
                                                        elevation: 10.0,
                                                        title: Text(
                                                          isShownamePhoto ==
                                                                  true
                                                              ? getTranslatedForCurrentUser(
                                                                      this
                                                                          .context,
                                                                      'unblock') +
                                                                  ' ${peer![Dbkeys.nickname]}?'
                                                              : getTranslatedForCurrentUser(
                                                                      this.context,
                                                                      'unblock') +
                                                                  ' ${getTranslatedForCurrentUser(context, 'xxagentxx')} ${peer![Dbkeys.id]}?',
                                                          style: TextStyle(
                                                              color: Mycolors
                                                                  .black),
                                                        ),
                                                        actions: <Widget>[
                                                          myElevatedButton(
                                                              color: Mycolors
                                                                  .white,
                                                              child: Text(
                                                                getTranslatedForCurrentUser(
                                                                    this.context,
                                                                    'xxcancelxx'),
                                                                style: TextStyle(
                                                                    color: Mycolors
                                                                        .black),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              }),
                                                          myElevatedButton(
                                                              color: Mycolors
                                                                  .agentSecondary,
                                                              child: Text(
                                                                getTranslatedForCurrentUser(
                                                                    this.context,
                                                                    'unblock'),
                                                                style: TextStyle(
                                                                    color: Mycolors
                                                                        .white),
                                                              ),
                                                              onPressed: () {
                                                                ChatController
                                                                    .accept(
                                                                        currentUserID,
                                                                        peerUID);
                                                                setStateIfMounted(
                                                                    () {
                                                                  chatStatus =
                                                                      ChatStatus
                                                                          .accepted
                                                                          .index;
                                                                });
                                                              })
                                                        ],
                                                      )
                                                    : hasPeerBlockedMe == true
                                                        ? Container(
                                                            alignment: Alignment
                                                                .center,
                                                            padding: EdgeInsets
                                                                .fromLTRB(14, 7,
                                                                    14, 7),
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.3),
                                                            height: 50,
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .error_outline_rounded,
                                                                    color: Colors
                                                                        .red),
                                                                SizedBox(
                                                                    width: 10),
                                                                Text(
                                                                  getTranslatedForCurrentUser(
                                                                      context,
                                                                      'xxuserhasblockedxx'),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      height:
                                                                          1.3),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        : buildInputAndroid(
                                                            context,
                                                            isemojiShowing,
                                                            refreshInput,
                                                            _keyboardVisible)
                                              ],
                                            ),
                                    ],
                                  ),
                                  // buildLoading()
                                ],
                              )),
                          buildLoadingThumbnail(),
                        ],
                      )
                    : Container();
              })))),
    );
  }
}
