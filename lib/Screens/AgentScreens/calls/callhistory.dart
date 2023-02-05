//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Configs/optional_constants.dart';
import 'package:thinkcreative_technologies/Services/Admob/admob.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Services/Providers/call_history_provider.dart';
import 'package:thinkcreative_technologies/Services/Providers/liveListener.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/Utils/custom_tiles.dart';
import 'package:thinkcreative_technologies/Utils/getRolePermission.dart';
import 'package:thinkcreative_technologies/Utils/infinitelistview.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkcreative_technologies/widgets/WarningWidgets/warning_tile.dart';

class CallHistoryForAgents extends StatefulWidget {
  final String? userphone;
  final SharedPreferences prefs;

  CallHistoryForAgents({required this.userphone, required this.prefs});
  @override
  _CallHistoryForAgentsState createState() => _CallHistoryForAgentsState();
}

class _CallHistoryForAgentsState extends State<CallHistoryForAgents> {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
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
    Utils.internetLookUp();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = Provider.of<Observer>(this.context, listen: false);
      if (IsBannerAdShow == true && observer.isadmobshow == true) {
        myBanner.load();
        adWidget = AdWidget(ad: myBanner);
        setState(() {});
      }
    });
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
    final observer = Provider.of<Observer>(this.context, listen: false);
    SpecialLiveConfigData? livedata =
        Provider.of<SpecialLiveConfigData?>(this.context, listen: true);
    bool isShownamePhoto =
        observer.userAppSettingsDoc!.agentcanseeagentnameandphoto! == true ||
            (iAmSecondAdmin(
                        specialLiveConfigData: livedata,
                        currentuserid: widget.userphone!,
                        context: this.context) ==
                    true &&
                observer.userAppSettingsDoc!
                        .secondadmincanseeagentnameandphoto ==
                    true) ||
            (iAmDepartmentManager(
                        currentuserid: widget.userphone!,
                        context: this.context) ==
                    true &&
                observer.userAppSettingsDoc!
                        .departmentmanagercanseeagentnameandphoto ==
                    true);
    return Consumer<FirestoreDataProviderCALLHISTORY>(
      builder: (context, firestoreDataProvider, _) => Scaffold(
        appBar: AppBar(
          elevation: 0.4,
          backgroundColor:
              Mycolors.getColor(widget.prefs, Colortype.primary.index),
          title: Text(
            getTranslatedForCurrentUser(context, 'xxcallhistoryxx'),
            style: TextStyle(fontSize: 17),
          ),
          titleSpacing: 15,
        ),
        key: _scaffold,
        backgroundColor: Colors.white,
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
        body: InfiniteListView(
          firestoreDataProviderCALLHISTORY: firestoreDataProvider,
          datatype: 'CALLHISTORY',
          refdata: FirebaseFirestore.instance
              .collection(DbPaths.collectionagents)
              .doc(widget.userphone)
              .collection(DbPaths.collectioncallhistory)
              .orderBy('TIME', descending: true)
              .limit(14),
          list: ListView.builder(
              padding: EdgeInsets.only(bottom: 150),
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: firestoreDataProvider.recievedDocs.length,
              itemBuilder: (BuildContext context, int i) {
                var dc = firestoreDataProvider.recievedDocs[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Consumer<UserRegistry>(
                          builder: (context, registry, _child) {
                        return ListTile(
                          onLongPress: isShownamePhoto == true
                              ? () {
                                  Utils.toast(
                                    registry
                                                .getUserData(
                                                    context, dc['PEER'])
                                                .usertype ==
                                            Usertype.agent.index
                                        ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${dc['PEER']}"
                                        : "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${dc['PEER']}",
                                  );
                                }
                              : null,
                          isThreeLine: false,
                          leading: Stack(
                            children: [
                              isShownamePhoto == true
                                  ? customCircleAvatar(
                                      radius: 22,
                                      url: registry
                                          .getUserData(context, dc['PEER'])
                                          .photourl)
                                  : SizedBox(
                                      width: 9,
                                      height: 8,
                                    ),
                              dc['STARTED'] == null || dc['ENDED'] == null
                                  ? SizedBox(
                                      height: 0,
                                      width: 0,
                                    )
                                  : Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(6, 2, 6, 2),
                                        decoration: BoxDecoration(
                                            color: Mycolors.secondary,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        child: Text(
                                          dc['ENDED']
                                                      .toDate()
                                                      .difference(dc['STARTED']
                                                          .toDate())
                                                      .inMinutes <
                                                  1
                                              ? dc['ENDED']
                                                      .toDate()
                                                      .difference(dc['STARTED']
                                                          .toDate())
                                                      .inSeconds
                                                      .toString() +
                                                  's'
                                              : dc['ENDED']
                                                      .toDate()
                                                      .difference(dc['STARTED']
                                                          .toDate())
                                                      .inMinutes
                                                      .toString() +
                                                  'm',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10),
                                        ),
                                      ))
                            ],
                          ),
                          title: Text(
                            isShownamePhoto == true
                                ? registry
                                    .getUserData(context, dc['PEER'])
                                    .fullname
                                : registry
                                            .getUserData(context, dc['PEER'])
                                            .usertype ==
                                        Usertype.agent.index
                                    ? "${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${dc['PEER']}"
                                    : "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${dc['PEER']}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                height: 1.4, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Row(
                              children: <Widget>[
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
                                Text(Jiffy(DateTime.fromMillisecondsSinceEpoch(
                                            dc["TIME"]))
                                        .MMMMd
                                        .toString() +
                                    ', ' +
                                    Jiffy(DateTime.fromMillisecondsSinceEpoch(
                                            dc["TIME"]))
                                        .Hm
                                        .toString()),
                                SizedBox(
                                  width: 17,
                                ),
                                eachhorizontaltile(
                                    title: registry
                                                .getUserData(
                                                    context, dc['PEER'])
                                                .usertype ==
                                            Usertype.agent.index
                                        ? getTranslatedForCurrentUser(
                                            context, 'xxagentxx')
                                        : getTranslatedForCurrentUser(
                                            context,
                                            getTranslatedForCurrentUser(
                                                context, 'xxcustomerxx')),
                                    color: registry
                                                .getUserData(
                                                    context, dc['PEER'])
                                                .usertype ==
                                            Usertype.agent.index
                                        ? Colors.purple[300]
                                        : Colors.pink[300],
                                    tilewidth:
                                        MediaQuery.of(context).size.width / 4)
                                // Text(time)
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    dc['TICKET_ID'] == null
                        ? SizedBox()
                        : warningTile(
                            marginnarrow: true,
                            title:
                                "${getTranslatedForCurrentUser(context, 'xxticketidxx')} ${dc['TICKET_ID']}",
                            warningTypeIndex: WarningType.alert.index),
                    dc['TICKET_ID'] == null
                        ? SizedBox(
                            height: 0,
                          )
                        : SizedBox(
                            height: 7,
                          ),
                    Divider(
                      height: 0,
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}

Widget customCircleAvatar({String? url, double? radius}) {
  if (url == null || url == '') {
    return CircleAvatar(
      backgroundColor: Mycolors.greylight,
      radius: radius ?? 30,
      child: Icon(
        Icons.person,
        size: radius != null ? radius / 0.7 : 20,
        color: Colors.white,
      ),
    );
  } else {
    return CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => CircleAvatar(
              backgroundColor: Mycolors.greylight,
              radius: radius ?? 30,
              backgroundImage: NetworkImage('$url'),
            ),
        placeholder: (context, url) => CircleAvatar(
              backgroundColor: Mycolors.greylight,
              radius: radius ?? 30,
              child: Icon(
                Icons.person,
                size: radius != null ? radius / 0.7 : 20,
                color: Colors.white,
              ),
            ),
        errorWidget: (context, url, error) => CircleAvatar(
              backgroundColor: Mycolors.greylight,
              radius: radius ?? 30,
              child: Icon(
                Icons.person,
                size: radius != null ? radius / 0.7 : 20,
                color: Colors.white,
              ),
            ));
  }
}

Widget customCircleAvatarGroup({String? url, double? radius}) {
  if (url == null || url == '') {
    return CircleAvatar(
      backgroundColor: Mycolors.greylight,
      radius: radius ?? 30,
      child: Icon(
        Icons.people,
        color: Colors.white,
      ),
    );
  } else {
    return CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => CircleAvatar(
              backgroundColor: Mycolors.greylight,
              radius: radius ?? 30,
              backgroundImage: NetworkImage('$url'),
            ),
        placeholder: (context, url) => CircleAvatar(
              backgroundColor: Mycolors.greylight,
              radius: radius ?? 30,
              child: Icon(
                Icons.people,
                color: Colors.white,
              ),
            ),
        errorWidget: (context, url, error) => CircleAvatar(
              backgroundColor: Mycolors.greylight,
              radius: radius ?? 30,
              child: Icon(
                Icons.people,
                color: Colors.white,
              ),
            ));
  }
}

Widget customCircleAvatarBroadcast({String? url, double? radius}) {
  if (url == null || url == '') {
    return CircleAvatar(
      backgroundColor: Mycolors.greylight,
      radius: radius ?? 30,
      child: Icon(
        Icons.campaign_sharp,
        color: Colors.white,
      ),
    );
  } else {
    return CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => CircleAvatar(
              backgroundColor: Mycolors.greylight,
              radius: radius ?? 30,
              backgroundImage: NetworkImage('$url'),
            ),
        placeholder: (context, url) => CircleAvatar(
              backgroundColor: Mycolors.greylight,
              radius: radius ?? 30,
              child: Icon(
                Icons.campaign_sharp,
                color: Colors.white,
              ),
            ),
        errorWidget: (context, url, error) => CircleAvatar(
              backgroundColor: Mycolors.greylight,
              radius: radius ?? 30,
              child: Icon(
                Icons.campaign_sharp,
                color: Colors.white,
              ),
            ));
  }
}
