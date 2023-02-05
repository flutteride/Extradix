//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/agent_model.dart';
import 'package:thinkcreative_technologies/Models/customer_model.dart';
import 'package:thinkcreative_technologies/Models/user_registry_model.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/ticketWidget.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/callhistory.dart';
import 'package:thinkcreative_technologies/Services/Providers/liveListener.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/timeAgo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';

class AgentCard extends StatefulWidget {
  final AgentModel usermodel;
  final String currentuserid;
  final bool? isswitchshow;

  final bool isProfileFetchedFromProvider;
  final EdgeInsets? margin;
  final Function? onpressed;
  final Function(bool val)? onswitchchanged;
  AgentCard({
    required this.usermodel,
    required this.currentuserid,
    this.isswitchshow,
    this.margin,
    required this.isProfileFetchedFromProvider,
    this.onpressed,
    this.onswitchchanged,
  });
  @override
  _AgentCardState createState() => _AgentCardState();
}

class _AgentCardState extends State<AgentCard> {
  @override
  Widget build(BuildContext context) {
    SpecialLiveConfigData? livedata =
        Provider.of<SpecialLiveConfigData?>(context, listen: true);
    bool isready = livedata == null
        ? false
        : !livedata.docmap.containsKey(Dbkeys.secondadminID) ||
                livedata.docmap[Dbkeys.secondadminID] == '' ||
                livedata.docmap[Dbkeys.secondadminID] == null
            ? false
            : true;
    return InkWell(
      onTap: widget.onpressed == null
          ? () {}
          : () {
              widget.onpressed!();
            },
      child: Container(
          margin: widget.margin ?? EdgeInsets.all(7),
          decoration: boxDecoration(showShadow: true),
          child: Stack(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  widget.usermodel.accountstatus == Dbkeys.sTATUSblocked
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(13, 17, 8, 8),
                          child: customCircleAvatar(
                              url: widget.usermodel.photoUrl, radius: 27),
                        )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(13, 17, 8, 8),
                          child: customCircleAvatar(
                              url: widget.usermodel.photoUrl, radius: 27),
                        ),
                  Container(
                    width: widget.isswitchshow == false
                        ? MediaQuery.of(context).size.width / 1.5
                        : MediaQuery.of(context).size.width / 1.4,
                    padding: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 7.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onTap: widget.onpressed as void Function()? ?? () {},
                          child: MtCustomfontBoldSemi(
                            maxlines: 1,
                            color: Mycolors.black,
                            text: widget.usermodel.nickname,
                            fontsize: 15.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onpressed as void Function()? ?? () {},
                          child: Divider(),
                        ),
                        GestureDetector(
                          onTap: widget.onpressed as void Function()? ?? () {},
                          child: SizedBox(
                            height: 5.0,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 13,
                                  color: Mycolors.grey,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                    // width: 110,
                                    child: Text(
                                  '${getTranslatedForCurrentUser(context, 'xxidxx')} ${widget.usermodel.id} ',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                )),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                isready == true
                                    ?
                                    // livedata!.docmap[Dbkeys.secondadminID] ==
                                    //         widget.usermodel.id
                                    //     ? roleBasedSticker(
                                    //         Usertype.secondadmin.index)
                                    // :
                                    widget.usermodel.lastSeen == true
                                        ? SizedBox()
                                        : Container(
                                            alignment: Alignment.centerRight,
                                            width: 100,
                                            child: Text(
                                              "Active " +
                                                  timeAgo(
                                                      DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              widget.usermodel
                                                                  .lastSeen),
                                                      true),
                                              // DateTime.now()
                                              //             .difference(DateTime
                                              //                 .fromMillisecondsSinceEpoch(
                                              //                     widget
                                              //                         .usermodel
                                              //                         .joinedOn))
                                              //             .inDays <
                                              //         1
                                              //     ? 'joined today'
                                              //     : ' joined ${DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(widget.usermodel.joinedOn)).inDays}d ago',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 12.5,
                                                  color: Mycolors.greytext),
                                            ))
                                    : Container(
                                        width: 100,
                                        child: Text(
                                          DateTime.now()
                                                      .difference(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              widget.usermodel
                                                                  .joinedOn))
                                                      .inDays <
                                                  1
                                              ? 'joined today'
                                              : ' joined ${DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(widget.usermodel.joinedOn)).inDays}d ago',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12.5,
                                              color: Mycolors.greytext),
                                        )),
                              ],
                            ),
                            widget.isswitchshow == false
                                ? SizedBox()
                                : Container(
                                    margin: EdgeInsets.only(right: 10),
                                    width: 40.0,
                                    child: FlutterSwitch(
                                      inactiveText: '',
                                      width: 46.0,
                                      activeColor: Mycolors.greenbuttoncolor,
                                      inactiveColor: Mycolors.red,
                                      height: 18.0,
                                      valueFontSize: 12.0,
                                      toggleSize: 12.0,
                                      borderRadius: 25.0,
                                      padding: 3.0,
                                      showOnOff: true,
                                      activeText: '',
                                      value: widget.usermodel.accountstatus ==
                                              Dbkeys.sTATUSallowed
                                          ? true
                                          : widget.usermodel.accountstatus ==
                                                  Dbkeys.sTATUSblocked
                                              ? false
                                              : widget.usermodel
                                                          .accountstatus ==
                                                      Dbkeys.sTATUSpending
                                                  ? false
                                                  : true,
                                      onToggle: (value) {
                                        widget.onswitchchanged!(value);
                                      },
                                    ),
                                  ),
                          ],
                        ),
                        SizedBox(
                          height: 13,
                        ),
                        SizedBox(
                          height: 0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              widget.usermodel.accountstatus == Dbkeys.sTATUSblocked
                  ? Positioned(
                      top: 0.0,
                      right: 0.0,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                        decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(4),
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(4),
                              bottomRight: Radius.circular(0),
                            ) // green shaped
                            ),
                        child: Text(
                          '  BLOCKED ',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  : SizedBox(),
              widget.usermodel.accountstatus == Dbkeys.sTATUSpending
                  ? Positioned(
                      top: 0.0,
                      right: 0.0,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                        decoration: BoxDecoration(
                            color: Colors.yellow[300],
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(4),
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(4),
                              bottomRight: Radius.circular(0),
                            ) // green shaped
                            ),
                        child: Text(
                          ' WAITING FOR APPROVAL ',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  : SizedBox(),
              widget.usermodel.lastSeen != true
                  ? SizedBox(height: 0, width: 0)
                  : Positioned(
                      child: Container(
                        width: 30,
                        child: Icon(
                          Icons.circle,
                          color: Mycolors.onlinetag,
                          size: 16,
                        ),
                      ),
                      top: 16,
                      left: 43,
                    ),
            ],
          )),
    );
  }
}

class CustomerCard extends StatefulWidget {
  final CustomerModel usermodel;
  final String currentuserid;
  final bool? isswitchshow;

  final bool isProfileFetchedFromProvider;
  final EdgeInsets? margin;
  final Function? onpressed;
  final Function(bool val)? onswitchchanged;
  CustomerCard({
    required this.usermodel,
    required this.currentuserid,
    this.isswitchshow,
    this.margin,
    required this.isProfileFetchedFromProvider,
    this.onpressed,
    this.onswitchchanged,
  });
  @override
  _CustomerCardState createState() => _CustomerCardState();
}

class _CustomerCardState extends State<CustomerCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onpressed == null
          ? () {}
          : () {
              widget.onpressed!();
            },
      child: Container(
          margin: widget.margin ?? EdgeInsets.all(7),
          decoration: boxDecoration(showShadow: true),
          child: Stack(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  widget.usermodel.accountstatus == Dbkeys.sTATUSblocked
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(13, 17, 8, 8),
                          child: customCircleAvatar(
                              url: widget.usermodel.photoUrl, radius: 27),
                        )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(13, 17, 8, 8),
                          child: customCircleAvatar(
                              url: widget.usermodel.photoUrl, radius: 27),
                        ),
                  Container(
                    width: widget.isswitchshow == false
                        ? MediaQuery.of(context).size.width / 1.5
                        : MediaQuery.of(context).size.width / 1.4,
                    padding: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 7.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onTap: widget.onpressed as void Function()? ?? () {},
                          child: MtCustomfontBoldSemi(
                            maxlines: 1,
                            color: Mycolors.black,
                            text: widget.usermodel.nickname,
                            fontsize: 15.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onpressed as void Function()? ?? () {},
                          child: Divider(),
                        ),
                        GestureDetector(
                          onTap: widget.onpressed as void Function()? ?? () {},
                          child: SizedBox(
                            height: 5.0,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 13,
                                  color: Mycolors.grey,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                    // width: 110,
                                    child: Text(
                                  '${getTranslatedForCurrentUser(context, 'xxidxx')} ${widget.usermodel.id} ',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                )),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                    width: 100,
                                    child: Text(
                                      DateTime.now()
                                                  .difference(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          widget.usermodel
                                                              .joinedOn))
                                                  .inDays <
                                              1
                                          ? 'joined today'
                                          : ' joined ${DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(widget.usermodel.joinedOn)).inDays}d ago',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          color: Mycolors.greytext),
                                    )),
                              ],
                            ),
                            widget.isswitchshow == false
                                ? SizedBox()
                                : Container(
                                    margin: EdgeInsets.only(right: 10),
                                    width: 40.0,
                                    child: FlutterSwitch(
                                      inactiveText: '',
                                      width: 46.0,
                                      activeColor: Mycolors.greenbuttoncolor,
                                      inactiveColor: Mycolors.red,
                                      height: 18.0,
                                      valueFontSize: 12.0,
                                      toggleSize: 12.0,
                                      borderRadius: 25.0,
                                      padding: 3.0,
                                      showOnOff: true,
                                      activeText: '',
                                      value: widget.usermodel.accountstatus ==
                                              Dbkeys.sTATUSallowed
                                          ? true
                                          : widget.usermodel.accountstatus ==
                                                  Dbkeys.sTATUSblocked
                                              ? false
                                              : widget.usermodel
                                                          .accountstatus ==
                                                      Dbkeys.sTATUSpending
                                                  ? false
                                                  : true,
                                      onToggle: (value) {
                                        widget.onswitchchanged!(value);
                                      },
                                    ),
                                  ),
                          ],
                        ),
                        SizedBox(
                          height: 13,
                        ),
                        SizedBox(
                          height: 0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              widget.usermodel.accountstatus == Dbkeys.sTATUSblocked
                  ? Positioned(
                      top: 0.0,
                      right: 0.0,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                        decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(4),
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(4),
                              bottomRight: Radius.circular(0),
                            ) // green shaped
                            ),
                        child: Text(
                          '  BLOCKED ',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  : SizedBox(),
              widget.usermodel.accountstatus == Dbkeys.sTATUSpending
                  ? Positioned(
                      top: 0.0,
                      right: 0.0,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                        decoration: BoxDecoration(
                            color: Colors.yellow[300],
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(4),
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(4),
                              bottomRight: Radius.circular(0),
                            ) // green shaped
                            ),
                        child: Text(
                          ' WAITING FOR APPROVAL ',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  : SizedBox(),
              widget.usermodel.lastSeen != true
                  ? SizedBox(height: 0, width: 0)
                  : Positioned(
                      child: Container(
                        width: 30,
                        child: Icon(
                          Icons.circle,
                          color: Mycolors.onlinetag,
                          size: 16,
                        ),
                      ),
                      top: 16,
                      left: 43,
                    ),
            ],
          )),
    );
  }
}

class RegistryUserCard extends StatefulWidget {
  final UserRegistryModel usermodel;
  final String currentuserid;

  final EdgeInsets? margin;
  final Function? onpressed;
  RegistryUserCard({
    required this.usermodel,
    required this.currentuserid,
    this.margin,
    this.onpressed,
  });
  @override
  _RegistryUserCardState createState() => _RegistryUserCardState();
}

class _RegistryUserCardState extends State<RegistryUserCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onpressed == null
          ? () {}
          : () {
              widget.onpressed!();
            },
      child: Container(
          margin: widget.margin ?? EdgeInsets.all(7),
          decoration: boxDecoration(showShadow: true),
          child: Stack(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(13, 17, 8, 8),
                    child: customCircleAvatar(
                        url: widget.usermodel.photourl, radius: 27),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    padding: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 7.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onTap: widget.onpressed as void Function()? ?? () {},
                          child: MtCustomfontBoldSemi(
                            maxlines: 1,
                            color: Mycolors.black,
                            text: widget.usermodel.fullname,
                            fontsize: 15.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onpressed as void Function()? ?? () {},
                          child: Divider(),
                        ),
                        GestureDetector(
                          onTap: widget.onpressed as void Function()? ?? () {},
                          child: SizedBox(
                            height: 5.0,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 13,
                                  color: Mycolors.grey,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                    // width: 110,
                                    child: Text(
                                  '${getTranslatedForCurrentUser(context, 'xxidxx')} ${widget.usermodel.id} ',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                )),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 13,
                        ),
                        SizedBox(
                          height: 0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
