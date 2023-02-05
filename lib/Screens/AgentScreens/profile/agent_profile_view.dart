//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'dart:io';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Models/DataModel.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/callhistory.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:thinkcreative_technologies/Services/Admob/admob.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Utils/call_utilities.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkcreative_technologies/Configs/optional_constants.dart';

class AgentProfileView extends StatefulWidget {
  final Map<String, dynamic> user;
  final String currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  final DocumentSnapshot<Map<String, dynamic>>? firestoreUserDoc;
  AgentProfileView(this.user, this.currentUserNo, this.model, this.prefs,
      {this.firestoreUserDoc});

  @override
  State<AgentProfileView> createState() => _AgentProfileViewState();
}

class _AgentProfileViewState extends State<AgentProfileView> {
  call(BuildContext context, bool isvideocall, bool isShowNameAndPhotoToDialer,
      bool isShowNameAndPhotoToReciever) async {
    var mynickname = widget.prefs.getString(Dbkeys.nickname) ?? '';

    var myphotoUrl = widget.prefs.getString(Dbkeys.photoUrl) ?? '';

    CallUtils.dial(
        callSessionID: DateTime.now().millisecondsSinceEpoch.toString(),
        callSessionInitatedBy: widget.currentUserNo,
        callTypeindex: CallTypeIndex.callToAgentFromAgentInPERSONAL.index,
        isShowCallernameAndPhotoToDialler: isShowNameAndPhotoToDialer,
        isShowCallernameAndPhotoToReciever: isShowNameAndPhotoToReciever,
        prefs: widget.prefs,
        currentUserID: widget.currentUserNo,
        fromDp: myphotoUrl,
        toDp: widget.user[Dbkeys.photoUrl],
        fromUID: widget.currentUserNo,
        fromFullname: mynickname,
        toUID: widget.user[Dbkeys.id],
        toFullname: widget.user[Dbkeys.nickname],
        context: context,
        isvideocall: isvideocall);
  }

  final BannerAd myBanner = BannerAd(
    adUnitId: getBannerAdUnitId()!,
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  AdWidget? adWidget;
  StreamSubscription? chatStatusSubscriptionForPeer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = Provider.of<Observer>(this.context, listen: false);
      listenToBlock();
      if (IsBannerAdShow == true && observer.isadmobshow == true) {
        myBanner.load();
        adWidget = AdWidget(ad: myBanner);
        setState(() {});
      }
    });
  }

  bool hasPeerBlockedMe = false;
  listenToBlock() {
    chatStatusSubscriptionForPeer = FirebaseFirestore.instance
        .collection(DbPaths.collectionagents)
        .doc(widget.user[Dbkeys.phone])
        .collection(Dbkeys.chatsWith)
        .doc(Dbkeys.chatsWith)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        if (doc.data()!.containsKey(widget.currentUserNo)) {
          if (doc.data()![widget.currentUserNo] == 0) {
            hasPeerBlockedMe = true;
            setState(() {});
          } else if (doc.data()![widget.currentUserNo] == 3) {
            hasPeerBlockedMe = false;
            setState(() {});
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    chatStatusSubscriptionForPeer?.cancel();
    if (IsBannerAdShow == true) {
      myBanner.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(context, listen: false);
    // SpecialLiveConfigData? livedata =
    //     Provider.of<SpecialLiveConfigData?>(context, listen: true);
    return PickupLayout(
        curentUserID: widget.currentUserNo,
        prefs: widget.prefs,
        scaffold: Utils.getNTPWrappedWidget(Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Mycolors.black,
              ),
            ),
          ),
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
          backgroundColor: Colors.white,
          body: ListView(
            padding: EdgeInsets.only(top: 10),
            children: [
              Column(
                children: [
                  customCircleAvatar(
                    radius: 45,
                    url: widget.user[Dbkeys.photoUrl],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.user[Dbkeys.nickname],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 17,
                        color: Mycolors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 55,
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.only(bottom: 18, top: 8),
                color: Colors.white,
                // height: 30,
                child: ListTile(
                  title: Text(
                    getTranslatedForCurrentUser(
                        context, 'xxchatcallmonitoredxx'),
                    style: TextStyle(
                        color: Mycolors.grey, height: 1.3, fontSize: 15),
                  ),
                  trailing: Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Icon(
                      Icons.lock,
                      color: Mycolors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: IsBannerAdShow == true &&
                        observer.isadmobshow == true &&
                        adWidget != null
                    ? 90
                    : 20,
              ),
            ],
          ),
        )));
  }
}
