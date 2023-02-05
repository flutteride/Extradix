import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/agent_model.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/ticketWidget.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/chat.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Utils/color_light_dark.dart';
import 'package:thinkcreative_technologies/Utils/custom_url_launcher.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custominput.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/loadingDialog.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/myinkwell.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/myscaffold.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/nodata_widget.dart';

class QuickReplies extends StatefulWidget {
  final String currentuserid;
  final SharedPreferences prefs;
  final Function(String value) onreplyselect;
  const QuickReplies(
      {Key? key,
      required this.currentuserid,
      required this.prefs,
      required this.onreplyselect})
      : super(key: key);

  @override
  State<QuickReplies> createState() => _QuickRepliesState();
}

class _QuickRepliesState extends State<QuickReplies> {
  String err = "";
  bool isloading = true;
  List<dynamic> myQuickReplies = [];
  List<dynamic> searchresults = [];
  final TextEditingController _textEditingController =
      new TextEditingController();
  final TextEditingController _searchController = new TextEditingController();
  @override
  void initState() {
    super.initState();
    fetch();
  }

  fetch() async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionagents)
        .doc(widget.currentuserid)
        .get()
        .then((value) {
      if (value.exists) {
        AgentModel agent = AgentModel.fromSnapshot(value);
        myQuickReplies = agent.quickReplies;
        searchresults.clear();
        isloading = false;
        setState(() {});
      } else {
        isloading = false;
        setState(() {
          err = "Agent doc does not exists. Please contact Admin";
        });
      }
    }).catchError((e) {
      isloading = false;
      setState(() {
        err = "unable to fetch Doc. ERROR_34: $e";
      });
    });
  }

  bool isaddnew = false;
  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(context, listen: true);
    return PickupLayout(
        curentUserID: widget.currentuserid,
        prefs: widget.prefs,
        scaffold: Utils.getNTPWrappedWidget(MyScaffold(
            backgroundColor: Mycolors.white,
            title: getTranslatedForCurrentUser(context, 'xxquickrepliesxx'),
            icondata1: isaddnew == false ? Icons.add : Icons.close,
            icon1press: err != "" || isloading == true
                ? () {}
                : isaddnew == true
                    ? () {
                        setState(() {
                          isaddnew = false;
                        });
                        _textEditingController.clear();
                        _searchController.clear();
                      }
                    : () {
                        setState(() {
                          isaddnew = true;
                        });
                      },
            body: Padding(
                padding: EdgeInsets.all(10),
                child: err != ""
                    ? Center(
                        child: Text(
                          err,
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : isloading == true
                        ? Center(
                            child: circularProgress(),
                          )
                        : myQuickReplies.length == 0 && isaddnew == false
                            ? Center(
                                child: noDataWidget(
                                    iconData: Icons.quickreply,
                                    context: context,
                                    title: getTranslatedForCurrentUser(
                                            context, 'xxnoxxavailabletoaddxx')
                                        .replaceAll(
                                            '(####)',
                                            getTranslatedForCurrentUser(
                                                context, 'xxquickrepliesxx')),
                                    subtitle: getTranslatedForCurrentUser(
                                        context, 'xxpresetreplyxx')),
                              )
                            : new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  isaddnew == true
                                      ? Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              child: InpuTextBox(
                                                controller:
                                                    _textEditingController,
                                                focuscolor: Mycolors.secondary,
                                                minLines: 7,
                                                maxLines: 15,
                                                maxcharacters: 1500,
                                                hinttext:
                                                    getTranslatedForCurrentUser(
                                                        context,
                                                        'xxxwriteatemplatexxx'),
                                              ),
                                            ),
                                            MySimpleButton(
                                              buttontext:
                                                  getTranslatedForCurrentUser(
                                                          context, 'xxsavexx')
                                                      .toUpperCase(),
                                              onpressed: observer
                                                          .checkIfCurrentUserIsDemo(
                                                              widget
                                                                  .currentuserid) ==
                                                      true
                                                  ? () {
                                                      Utils.toast(
                                                          getTranslatedForCurrentUser(
                                                              context,
                                                              'xxxnotalwddemoxxaccountxx'));
                                                    }
                                                  : () {
                                                      if (_textEditingController
                                                              .text
                                                              .trim()
                                                              .length ==
                                                          0) {
                                                      } else if (myQuickReplies
                                                          .contains(
                                                              _textEditingController
                                                                  .text
                                                                  .trim())) {
                                                        Utils.toast(
                                                            getTranslatedForCurrentUser(
                                                                context,
                                                                'xxxalreadyexistsxxx'));
                                                      } else {
                                                        String text =
                                                            _textEditingController
                                                                .text
                                                                .trim();
                                                        myQuickReplies.insert(
                                                            0, text);
                                                        setState(() {});
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(DbPaths
                                                                .collectionagents)
                                                            .doc(widget
                                                                .currentuserid)
                                                            .update({
                                                          Dbkeys.quickReplies:
                                                              FieldValue
                                                                  .arrayUnion(
                                                                      [text])
                                                        }).then((value) {
                                                          Utils.toast(
                                                              getTranslatedForCurrentUser(
                                                                  context,
                                                                  'xxsavedxx'));
                                                          setState(() {
                                                            isloading = false;
                                                            isaddnew = false;
                                                            _textEditingController
                                                                .clear();
                                                            _searchController
                                                                .clear();
                                                          });
                                                        }).catchError(
                                                                (onError) {
                                                          myQuickReplies
                                                              .remove(text);
                                                          setState(() {});
                                                          Utils.toast(getTranslatedForCurrentUser(
                                                                  context,
                                                                  'xxfailedxx') +
                                                              "  ERROR: $onError ");
                                                        });
                                                      }
                                                    },
                                            ),
                                          ],
                                        )
                                      : Container(
                                          child: InpuTextBox(
                                            onchanged: (v) {
                                              if (v.length < 1) {
                                                searchresults.clear();
                                                setState(() {});
                                              } else {
                                                var a = myQuickReplies;
                                                searchresults = a;
                                                searchresults = myQuickReplies
                                                    .where((element) =>
                                                        element.contains(v))
                                                    .toList();
                                                setState(() {});
                                              }
                                            },
                                            controller: _searchController,
                                            focuscolor: Mycolors.secondary,
                                            sufficIconbutton: IconButton(
                                              icon: Icon(
                                                Icons.close,
                                                color: Mycolors.greylight,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  isloading = true;
                                                });
                                                fetch();
                                              },
                                            ),
                                            hinttext:
                                                "  ${getTranslatedForCurrentUser(context, 'xxxsearchtemplatesxxx')}",
                                          ),
                                        ),
                                  isaddnew == true
                                      ? SizedBox()
                                      : _searchController.text.trim().length > 0
                                          ? searchresults.length == 0
                                              ? MtCustomfontRegular(
                                                  color: Mycolors.red,
                                                  text:
                                                      getTranslatedForCurrentUser(
                                                          context,
                                                          'xxxnotemplatesxxx'),
                                                )
                                              : MtCustomfontRegular(
                                                  color: Mycolors.green,
                                                  text:
                                                      '${searchresults.length} ${getTranslatedForCurrentUser(context, 'xxxtemplatesfoundxxx')}',
                                                )
                                          : SizedBox(),
                                  isaddnew == true
                                      ? SizedBox()
                                      : new Expanded(
                                          child: searchresults.length != 0
                                              ? ListView.builder(
                                                  itemCount:
                                                      searchresults.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int i) {
                                                    String searchresultstring =
                                                        searchresults[i];
                                                    return card(
                                                        context,
                                                        searchresultstring,
                                                        i,
                                                        true);
                                                  })
                                              : ListView.builder(
                                                  itemCount:
                                                      myQuickReplies.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int i) {
                                                    String templateString =
                                                        myQuickReplies[i];
                                                    return card(
                                                        context,
                                                        templateString,
                                                        i,
                                                        false);
                                                  }))
                                ],
                              )))));
  }

  card(BuildContext context, String templateString, int i, bool issearched) {
    final observer = Provider.of<Observer>(context, listen: false);
    return Stack(
      children: [
        Container(
            decoration: boxDecoration(
                radius: 6,
                bgColor: issearched
                    ? lighten(Colors.green, 0.45)
                    : Mycolors.greylightcolor),
            padding: EdgeInsets.all(7),
            margin: EdgeInsets.all(7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 1.8,
                  child: SelectableLinkify(
                    maxLines: 7,
                    minLines: 1,
                    style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 16,
                        color: Colors.black87),
                    text: templateString,
                    onOpen: (link) async {
                      custom_url_launcher(link.url);
                    },
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onreplyselect(templateString);
                        },
                        icon: Icon(
                          Icons.arrow_circle_right_rounded,
                          color: Mycolors.secondary,
                        )),
                    IconButton(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: templateString));

                          hidekeyboard(context);
                          Utils.toast(
                            getTranslatedForCurrentUser(context, 'xxcopiedxx'),
                          );
                        },
                        icon: Icon(
                          Icons.copy,
                          size: 15,
                          color: Mycolors.secondary,
                        )),
                  ],
                )
              ],
            )),
        Positioned(
            top: 7,
            right: 7,
            child: myinkwell(
              onTap: observer.checkIfCurrentUserIsDemo(widget.currentuserid) ==
                      true
                  ? () {
                      Utils.toast(getTranslatedForCurrentUser(
                          context, 'xxxnotalwddemoxxaccountxx'));
                    }
                  : () {
                      myQuickReplies.remove(templateString);
                      searchresults.remove(templateString);
                      setState(() {});
                      FirebaseFirestore.instance
                          .collection(DbPaths.collectionagents)
                          .doc(widget.currentuserid)
                          .update({
                        Dbkeys.quickReplies:
                            FieldValue.arrayRemove([templateString])
                      }).then((value) {
                        Utils.toast(getTranslatedForCurrentUser(
                            context, 'xxdeletedxx'));
                        setState(() {
                          isloading = false;
                          isaddnew = false;
                          _textEditingController.clear();
                          // _searchController.clear();
                        });
                      }).catchError((onError) {
                        setState(() {});
                        Utils.toast(
                            getTranslatedForCurrentUser(context, 'xxfailedxx') +
                                "  ERROR: $onError ");
                      });
                    },
              child: Container(
                decoration: boxDecoration(bgColor: Mycolors.white),
                child: Icon(
                  Icons.close,
                  size: 15,
                  color: Colors.red,
                ),
              ),
            ))
      ],
    );
  }
}
