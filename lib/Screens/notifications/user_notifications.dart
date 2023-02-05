//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/ticketWidget.dart';
import 'package:thinkcreative_technologies/Screens/notifications/NotificationViewer.dart';
import 'package:thinkcreative_technologies/Utils/color_light_dark.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custom_time_formatter.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/loadingDialog.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/myinkwell.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/myscaffold.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/nodata_widget.dart';
import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart';

class UsersNotifiaction extends StatefulWidget {
  final DocumentReference docRef1;
  final DocumentReference docRef2;
  final bool isbackbuttonhide;
  const UsersNotifiaction(
      {Key? key,
      required this.docRef1,
      required this.docRef2,
      required this.isbackbuttonhide})
      : super(key: key);

  @override
  _UsersNotifiactionState createState() => _UsersNotifiactionState();
}

class _UsersNotifiactionState extends State<UsersNotifiaction> {
  List<dynamic> list1 = [];
  List<dynamic> list2 = [];
  List<dynamic> finalList = [];
  String error = "";
  bool isloading = true;
  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  loadNotifications() async {
    await widget.docRef1.get().then((doc1) async {
      if (doc1.exists) {
        await widget.docRef2.get().then((doc2) {
          if (doc2.exists) {
            error = "";
            list1 = doc1[Dbkeys.list]
                .reversed
                .toList()
                .where((element) =>
                    element.containsKey(Dbkeys.nOTIFICATIONxxtitle) == true)
                .toList();

            list2 = doc2[Dbkeys.list]
                .reversed
                .toList()
                .where((element) =>
                    element.containsKey(Dbkeys.nOTIFICATIONxxtitle) == true)
                .toList();

            list1.addAll(list2);
            finalList = list1;

            finalList.sort((a, b) {
              var adate = a[Dbkeys
                  .nOTIFICATIONxxlastupdateepoch]; //before -> var adate = a.expiry;
              var bdate = b[Dbkeys
                  .nOTIFICATIONxxlastupdateepoch]; //before -> var bdate = b.expiry;
              return adate.compareTo(
                  bdate); //to get the order other way just switch `adate & bdate`
            });
            finalList = finalList.reversed.toList();
            setState(() {
              isloading = false;
            });
          } else {
            error =
                "Doc2 does not exists. Installation is not completed properly";
            setState(() {});
          }
        });
      } else {
        error = "Doc1 does not exists. Installation is not completed properly";
        setState(() {});
      }
    }).catchError((err) {
      error = "Error fetching Admin notification doc $err";
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      isforcehideback: widget.isbackbuttonhide,
      icon1press: () {
        setState(() {
          isloading = true;
        });
        this.loadNotifications();
      },
      icondata1: Icons.refresh,
      title: finalList.length == 0
          ? getTranslatedForCurrentUser(context, 'xxnotificationalertsxx')
          : "${finalList.length} ${getTranslatedForCurrentUser(context, 'xxnotificationalertsxx')}",
      body: error != ""
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  error,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : isloading == true
              ? circularProgress()
              : finalList.length == 0
                  ? noDataWidget(
                      context: context,
                      title: getTranslatedForCurrentUser(
                          context, 'xxnonotificationsxx'),
                      iconData: Icons.notifications,
                      subtitle:
                          getTranslatedForCurrentUser(context, 'xxallalertsxx'))
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(7, 7, 7, 7),
                      itemCount: finalList.length,
                      itemBuilder: (BuildContext context, int i) {
                        return notificationcard(
                          doc: finalList[i],
                        );
                      }),
    );
  }

  //widget to show name in card
  Widget notificationcard(
      {bool? isSent,
      required Map<String, dynamic> doc,
      bool isForAdmin = true}) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        myinkwell(
          onTap: () {
            notificationViwer(
              context,
              doc[Dbkeys.nOTIFICATIONxxdesc],
              doc[Dbkeys.nOTIFICATIONxxtitle],
              doc[Dbkeys.nOTIFICATIONxxauthor],
              doc[Dbkeys.nOTIFICATIONxximageurl],
              formatTimeDateCOMLPETEString(
                isdateTime: true,
                datetimetargetTime: DateTime.fromMillisecondsSinceEpoch(
                    doc[Dbkeys.nOTIFICATIONxxlastupdateepoch]),
              ),
            );
          },
          child: h > w == true
              ? Container(
                  margin: EdgeInsets.fromLTRB(0, 3, 0, 4),
                  decoration: boxDecoration(showShadow: true),
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(3, 5, 8, 9),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: lighten(Colors.yellow, 0.2),
                              radius: 13,
                              child: Icon(
                                Icons.notifications,
                                size: 13,
                                color: Mycolors.yellow,
                              ),
                            ),
                            MtCustomfontLight(
                              text: formatTimeDateCOMLPETEString(
                                  isdateTime: true,
                                  datetimetargetTime:
                                      DateTime.fromMillisecondsSinceEpoch(doc[
                                          Dbkeys
                                              .nOTIFICATIONxxlastupdateepoch])),
                              textalign: TextAlign.right,
                              fontsize: 11,
                              color: Mycolors.greytext,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height:
                            doc[Dbkeys.nOTIFICATIONxximageurl] == "" ? 5 : 10,
                      ),
                      doc[Dbkeys.nOTIFICATIONxximageurl] == ""
                          ? SizedBox()
                          : Container(
                              height: 190,
                              width: double.infinity,
                              color: Mycolors.greylightcolor,
                              child: doc[Dbkeys.nOTIFICATIONxximageurl] == ""
                                  ? Center(
                                      child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '  NO IMAGE  ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Mycolors.greytext
                                                .withOpacity(0.5)),
                                      ),
                                    ))
                                  : Image.network(
                                      doc[Dbkeys.nOTIFICATIONxximageurl],
                                      height: 80,
                                      width: 70,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                      SizedBox(
                        height:
                            doc[Dbkeys.nOTIFICATIONxximageurl] == "" ? 5 : 10,
                      ),
                      MtCustomfontBoldSemi(
                        text: doc[Dbkeys.nOTIFICATIONxxtitle] ?? '',
                        textalign: TextAlign.left,
                        color: Mycolors.black,
                        maxlines: 1,
                        overflow: TextOverflow.ellipsis,
                        lineheight: 1.25,
                        fontsize: 15,
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      StyledText(
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Mycolors.grey,
                          height: 1.3,
                        ),
                        text: doc[Dbkeys.nOTIFICATIONxxdesc] ?? '',
                        tags: {
                          'bold': StyledTextTag(
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Mycolors.grey,
                                  fontSize: 12,
                                  height: 1.3)),
                        },
                      ),
                      // MtCustomfontLight(
                      //   text: doc[Dbkeys.nOTIFICATIONxxdesc] ??
                      //       'Hello test notifcations description',
                      //   textalign: TextAlign.left,
                      //   color: Mycolors.grey,
                      //   maxlines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      //   lineheight: 1.25,
                      //   fontsize: 13,
                      // )
                    ],
                  ))
              : Container(
                  margin: EdgeInsets.fromLTRB(0, 6, 0, 6),
                  decoration: boxDecoration(showShadow: true),
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 40),
                        height: 90,
                        width: 110,
                        color: Mycolors.greylightcolor,
                        child: doc[Dbkeys.nOTIFICATIONxximageurl] == ""
                            ? Center(
                                child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '  NO IMAGE  ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Mycolors.greytext.withOpacity(0.5)),
                                ),
                              ))
                            : Image.network(
                                doc[Dbkeys.nOTIFICATIONxximageurl],
                                height: 80,
                                width: 70,
                                fit: BoxFit.contain,
                              ),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(3, 5, 8, 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  backgroundColor: lighten(Colors.yellow, 0.2),
                                  radius: 13,
                                  child: Icon(
                                    Icons.notifications,
                                    size: 13,
                                    color: Mycolors.yellow,
                                  ),
                                ),
                                // isSent == false
                                //     ? SizedBox(
                                //         height: 0,
                                //         width: 0,
                                //       )
                                //     : Container(
                                //         width: 80,
                                //         height: 20,
                                //         child: Row(
                                //           crossAxisAlignment:
                                //               CrossAxisAlignment.center,
                                //           children: [
                                //             Icon(
                                //               Icons.check_circle_outline_rounded,
                                //               size: 18,
                                //               color: Mycolors.green,
                                //             ),
                                //             SizedBox(
                                //               width: 7,
                                //             ),
                                //             MtCustomfontMedium(
                                //               text: 'Sent',
                                //               fontsize: 13,
                                //               color: Mycolors.green,
                                //             )
                                //           ],
                                //         ),
                                //       ),
                                MtCustomfontLight(
                                  text: formatTimeDateCOMLPETEString(
                                      isdateTime: true,
                                      datetimetargetTime: DateTime
                                          .fromMillisecondsSinceEpoch(doc[Dbkeys
                                              .nOTIFICATIONxxlastupdateepoch])),
                                  textalign: TextAlign.right,
                                  color: Mycolors.greytext,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          MtCustomfontBold(
                            text: doc[Dbkeys.nOTIFICATIONxxtitle] ?? ' ',
                            textalign: TextAlign.left,
                            color: Mycolors.black,
                            maxlines: 1,
                            overflow: TextOverflow.ellipsis,
                            lineheight: 1.25,
                            fontsize: 15,
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          StyledText(
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Mycolors.grey,
                              height: 1.3,
                            ),
                            text: doc[Dbkeys.nOTIFICATIONxxdesc] ?? '',
                            tags: {
                              'bold': StyledTextTag(
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Mycolors.grey,
                                      height: 1.3)),
                            },
                          ),
                        ],
                      ))
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
