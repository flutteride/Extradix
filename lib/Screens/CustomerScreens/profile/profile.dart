//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/ticketWidget.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/callhistory.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:thinkcreative_technologies/Screens/initialization/initialization_constant.dart';
import 'package:thinkcreative_technologies/Screens/notifications/user_notifications.dart';
import 'package:thinkcreative_technologies/Screens/privacypolicy&TnC/PdfViewFromCachedUrl.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Utils/custom_url_launcher.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custom_tiles.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/page_navigator.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/userrole_based_sticker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerProfile extends StatefulWidget {
  final bool biometricEnabled;
  final AuthenticationType type;
  final String currentUserID;
  final Function onTapEditProfile;
  final Function onTapLogout;
  final SharedPreferences prefs;
  const CustomerProfile(
      {Key? key,
      required this.biometricEnabled,
      required this.prefs,
      required this.currentUserID,
      required this.onTapEditProfile,
      required this.onTapLogout,
      required this.type})
      : super(key: key);

  @override
  _CustomerProfileState createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<CustomerProfile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    final observer = Provider.of<Observer>(context, listen: false);
    // var currentUser =
    //     Provider.of<FirestoreDataProviderAGENT>(context, listen: true);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor:
          Mycolors.backgroundcolor, //or set color with: Color(0xFF0000FF)
    ));

    return PickupLayout(
        curentUserID: widget.currentUserID,
        prefs: widget.prefs,
        scaffold: Utils.getNTPWrappedWidget(Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: MtCustomfontBold(
              text: getTranslatedForCurrentUser(context, 'xxmyacccountxx'),
              fontsize: 18,
              color: Mycolors.blackDynamic,
            ),
            backgroundColor: Mycolors.backgroundcolor,
            elevation: 0,
          ),
          backgroundColor: Mycolors.backgroundcolor,
          body: ListView(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
            children: [
              Container(
                decoration:
                    boxDecoration(showShadow: false, bgColor: Colors.white),
                padding: EdgeInsets.fromLTRB(7, 9, 7, 9),
                child: Container(
                  width: w,
                  child: ListTile(
                    trailing: Icon(Boxicons.bx_edit_alt,
                        size: 20, color: Mycolors.grey),
                    tileColor: Colors.red,
                    contentPadding: EdgeInsets.fromLTRB(7, 3, 20, 3),
                    onTap: () {
                      widget.onTapEditProfile();
                    },
                    leading: customCircleAvatar(
                      radius: 30,
                      url: widget.prefs.getString(Dbkeys.photoUrl) ?? '',
                    ),
                    title: MtCustomfontBold(
                      text: widget.prefs.getString(Dbkeys.nickname) ??
                          'name not found',
                      fontsize: 18.6,
                      lineheight: 1.4,
                      color: Mycolors.blackDynamic,
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        MtCustomfontBoldSemi(
                          text: widget.prefs.getString(Dbkeys.phone) ?? '',
                          lineheight: 1.4,
                          fontsize: 14.6,
                          color: Mycolors.grey,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        roleBasedSticker(context, Usertype.customer.index)
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: MtCustomfontBoldSemi(
                    text:
                        "${getTranslatedForCurrentUser(context, 'xxaccountidxx')}  ${widget.currentUserID}",
                    color: Mycolors.grey.withOpacity(0.7),
                    fontsize: 12,
                  ),
                ),
              ),
              observer.checkIfCurrentUserIsDemo(widget.currentUserID) == true
                  ? Chip(
                      label: Text(
                        getTranslatedForCurrentUser(
                            context, 'xxxdemoxxaccountxx'),
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Mycolors.orange,
                    )
                  : SizedBox(),
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 20),
                child: Column(
                  children: [
                    profileTile(
                      title: getTranslatedForCurrentUser(
                          context, 'xxeditprofilexx'),
                      subtitle:
                          getTranslatedForCurrentUser(context, 'xxchangednpxx'),
                      ontap: () {
                        widget.onTapEditProfile();
                      },
                      iconsize: 23,
                      leadingicondata: Boxicons.bx_user,
                      margin: 0,
                    ),
                    profileTile(
                      title: getTranslatedForCurrentUser(context, 'xxtncxx'),
                      subtitle: getTranslatedForCurrentUser(
                          context, 'xxabiderulesxx'),
                      ontap: () {
                        final observer =
                            Provider.of<Observer>(context, listen: false);
                        if (observer.basicSettingDoc!.tncTYPE == 'url') {
                          if (observer.basicSettingDoc!.tnc == null) {
                            Utils.toast("TNC URL is not valid");
                          } else {
                            custom_url_launcher(observer.basicSettingDoc!.tnc!);
                          }
                        } else if (observer.basicSettingDoc!.tncTYPE ==
                            'file') {
                          Navigator.push(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (_) => PDFViewerCachedFromUrl(
                                currentUserID: widget.currentUserID,
                                prefs: widget.prefs,
                                title: getTranslatedForCurrentUser(
                                    context, 'xxtncxx'),
                                url: observer.basicSettingDoc!.tnc,
                                isregistered: true,
                              ),
                            ),
                          );
                        }
                      },
                      iconsize: 23,
                      leadingicondata: Boxicons.bx_book,
                      margin: 0,
                    ),
                    profileTile(
                      title: getTranslatedForCurrentUser(context, 'xxppxx'),
                      subtitle: getTranslatedForCurrentUser(
                          context, 'xxprocessdataxx'),
                      ontap: () {
                        final observer =
                            Provider.of<Observer>(context, listen: false);

                        if (observer.basicSettingDoc!.privacypolicyTYPE ==
                            'url') {
                          if (observer.basicSettingDoc!.privacypolicy == null) {
                            Utils.toast("Privacy policy URL is not valid");
                          } else {
                            custom_url_launcher(
                                observer.basicSettingDoc!.privacypolicy!);
                          }
                        } else if (observer
                                .basicSettingDoc!.privacypolicyTYPE ==
                            'file') {
                          Navigator.push(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (_) => PDFViewerCachedFromUrl(
                                currentUserID: widget.currentUserID,
                                prefs: widget.prefs,
                                title: getTranslatedForCurrentUser(
                                    context, 'xxppxx'),
                                url: observer.basicSettingDoc!.privacypolicy,
                                isregistered: true,
                              ),
                            ),
                          );
                        }
                      },
                      iconsize: 23,
                      leadingicondata: Boxicons.bx_lock,
                      margin: 0,
                    ),
                    // profileTile(
                    //   title: getTranslatedForCurrentUser(context, 'xxratexx'),
                    //   subtitle: getTranslatedForCurrentUser(context, 'xxleavereviewxx'),
                    //   ontap: () {
                    //     onTapRateApp();
                    //   },
                    //   iconsize: 23,
                    //   leadingicondata: Boxicons.bx_star,
                    //   margin: 0,
                    // ),
                    profileTile(
                      title: getTranslatedForCurrentUser(
                          context, 'xxallnotificationsxx'),
                      subtitle:
                          getTranslatedForCurrentUser(context, 'xxpmteventsxx'),
                      ontap: () {
                        pageNavigator(
                            context,
                            UsersNotifiaction(
                                docRef1: FirebaseFirestore.instance
                                    .collection(DbPaths.collectioncustomers)
                                    .doc(widget.currentUserID)
                                    .collection(DbPaths.customernotifications)
                                    .doc(DbPaths.customernotifications),
                                docRef2: FirebaseFirestore.instance
                                    .collection(DbPaths.userapp)
                                    .doc(DbPaths.customernotifications),
                                isbackbuttonhide: false));
                      },
                      iconsize: 23,
                      leadingicondata: Boxicons.bx_bell,
                      margin: 0,
                    ),
                    profileTile(
                      title:
                          getTranslatedForCurrentUser(context, 'xxfeedbackxx'),
                      subtitle: getTranslatedForCurrentUser(
                          context, 'xxgivesuggestionsxx'),
                      ontap: () async {
                        if (observer.userAppSettingsDoc!.feedbackEmail!
                            .contains('@')) {
                          final Uri emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: observer.userAppSettingsDoc!.feedbackEmail,
                          );

                          await launchUrl(emailLaunchUri,
                              mode: LaunchMode.platformDefault);
                        } else {
                          custom_url_launcher(
                              observer.userAppSettingsDoc!.feedbackEmail!);
                        }
                      },
                      iconsize: 23,
                      leadingicondata: Boxicons.bx_comment_add,
                      margin: 0,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MySimpleButtonWithIcon(
                  iconData: EvaIcons.powerOutline,
                  buttontext:
                      getTranslatedForCurrentUser(context, 'xxlogoutxx'),
                  onpressed: () {
                    widget.onTapLogout();
                  },
                  buttoncolor: Mycolors.red,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(25),
                child: MtCustomfontBoldSemi(
                    color: Mycolors.grey.withOpacity(0.7),
                    textalign: TextAlign.center,
                    fontsize: 13.7,
                    text:
                        '${getTranslatedForCurrentUser(context, 'xxappversionxx')} ' +
                            (widget.prefs.getString('app_version') ?? "") +
                            '  |  Build v${InitializationConstant.k4}'),
              ),
            ],
          ),
        )));
  }

  onTapRateApp() {
    final observer = Provider.of<Observer>(context, listen: false);
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              ListTile(
                  contentPadding: EdgeInsets.only(top: 20),
                  subtitle: Padding(padding: EdgeInsets.only(top: 10.0)),
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          size: 40,
                          color: Mycolors.black.withOpacity(0.56),
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: Mycolors.black.withOpacity(0.56),
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: Mycolors.black.withOpacity(0.56),
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: Mycolors.black.withOpacity(0.56),
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: Mycolors.black.withOpacity(0.56),
                        ),
                      ]),
                  onTap: () {
                    Navigator.of(context).pop();
                    Platform.isAndroid
                        ? custom_url_launcher(
                            observer.basicSettingDoc!.newapplinkandroid!)
                        : custom_url_launcher(
                            observer.basicSettingDoc!.newapplinkios!);
                  }),
              Divider(),
              Padding(
                  child: Text(
                    getTranslatedForCurrentUser(context, 'xxlovedxx'),
                    style: TextStyle(fontSize: 14, color: Mycolors.black),
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
              Center(
                  child: myElevatedButton(
                      color: Mycolors.primary,
                      child: Text(
                        getTranslatedForCurrentUser(context, 'xxratexx'),
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Platform.isAndroid
                            ? custom_url_launcher(
                                observer.basicSettingDoc!.newapplinkandroid!)
                            : custom_url_launcher(
                                observer.basicSettingDoc!.newapplinkios!);
                      }))
            ],
          );
        });
  }
}
