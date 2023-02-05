//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Configs/number_limits.dart';
import 'package:thinkcreative_technologies/Configs/optional_constants.dart';
import 'package:thinkcreative_technologies/Models/customer_model.dart';
import 'package:thinkcreative_technologies/Models/ticket_model.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/widgets/ticketStatus.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/callhistory.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Utils/getRolePermission.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/late_load.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/myinkwell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget ticketWidgetForAgents({
  required BuildContext context,
  required SharedPreferences prefs,
  required Function(String s, String uid) ontap,
  required TicketModel ticket,
  required var ticketdoc,
  required String currentUserID,
}) {
  var observer = Provider.of<Observer>(context, listen: true);
  var registry = Provider.of<UserRegistry>(context, listen: true);
  return myinkwell(
    onTap: () {
      ontap(ticket.ticketID, ticket.ticketcustomerID);
    },
    child: Stack(
      children: [
        Container(
            margin: EdgeInsets.fromLTRB(8, 5, 8, 5),
            decoration: boxDecoration(
              showShadow: false,
              radius: 10,
            ),
            child: Row(children: [
              Container(
                decoration: BoxDecoration(
                  color: ticket.ticketcustomerID == currentUserID
                      ? ticketStatusColorForCustomers(ticket.ticketStatus)
                      : ticketStatusColorForAgents(ticket.ticketStatus),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10)),
                ),
                height: 125,
                width: 5.9,
              ),
              Container(
                color:
                    (ticket.ticketStatus == TicketStatus.needsAttention.index &&
                                currentUserID != ticket.ticketcustomerID
                            ? Colors.yellow[200]
                            : Colors.white) ??
                        Colors.white,
                width: 0,
              ),
              Expanded(
                  child: Container(
                color:
                    (ticket.ticketStatus == TicketStatus.needsAttention.index &&
                                currentUserID != ticket.ticketcustomerID
                            ? Colors.yellow[200]
                            : Colors.white) ??
                        Colors.white,
                padding: EdgeInsets.fromLTRB(12, 8, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            child: ticket.ticketStatusShort !=
                                    TicketStatusShort.active.index
                                ? Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor:
                                            ticket.ticketcustomerID ==
                                                    currentUserID
                                                ? ticketStatusColorForCustomers(
                                                    ticket.ticketStatus)
                                                : ticketStatusColorForAgents(
                                                        ticket.ticketStatus)
                                                    .withOpacity(0.2),
                                        child: customCircleAvatar(
                                          radius: 14,
                                          url: iAmSecondAdmin(
                                                      currentuserid:
                                                          currentUserID,
                                                      context: context) ==
                                                  true
                                              ? observer.userAppSettingsDoc!
                                                      .secondadmincanseecustomernameandphoto!
                                                  ? registry
                                                      .getUserData(
                                                          context,
                                                          ticket
                                                              .ticketcustomerID)
                                                      .photourl
                                                  : iAmDepartmentManager(
                                                              currentuserid:
                                                                  currentUserID,
                                                              context:
                                                                  context) ==
                                                          true
                                                      ? observer
                                                              .userAppSettingsDoc!
                                                              .departmentmanagercanseecustomernameandphoto!
                                                          ? registry
                                                              .getUserData(
                                                                  context,
                                                                  ticket
                                                                      .ticketcustomerID)
                                                              .photourl
                                                          : observer
                                                                  .userAppSettingsDoc!
                                                                  .agentcanseecustomernameandphoto!
                                                              ? registry
                                                                  .getUserData(
                                                                      context,
                                                                      ticket
                                                                          .ticketcustomerID)
                                                                  .photourl
                                                              : ""
                                                      : ""
                                              : "",
                                        ),
                                      ),
                                      SizedBox(
                                        width: 13,
                                      ),
                                      Text(
                                          iAmSecondAdmin(
                                                      currentuserid:
                                                          currentUserID,
                                                      context: context) ==
                                                  true
                                              ? observer.userAppSettingsDoc!
                                                      .secondadmincanseecustomernameandphoto!
                                                  ? registry
                                                      .getUserData(
                                                          context,
                                                          ticket
                                                              .ticketcustomerID)
                                                      .fullname
                                                  : iAmDepartmentManager(
                                                              currentuserid:
                                                                  currentUserID,
                                                              context:
                                                                  context) ==
                                                          true
                                                      ? observer
                                                              .userAppSettingsDoc!
                                                              .departmentmanagercanseecustomernameandphoto!
                                                          ? registry
                                                              .getUserData(
                                                                  context,
                                                                  ticket
                                                                      .ticketcustomerID)
                                                              .fullname
                                                          : observer
                                                                  .userAppSettingsDoc!
                                                                  .agentcanseecustomernameandphoto!
                                                              ? registry
                                                                  .getUserData(
                                                                      context,
                                                                      ticket
                                                                          .ticketcustomerID)
                                                                  .fullname
                                                              : "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${ticket.ticketcustomerID}"
                                                      : "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${ticket.ticketcustomerID}"
                                              : "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${ticket.ticketcustomerID}",
                                          // registry
                                          //     .getUserData(
                                          //         context, ticket.ticketcustomerID)
                                          //     .fullname,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Mycolors.grey)),
                                    ],
                                  )
                                : streamLoad(
                                    stream: FirebaseFirestore.instance
                                        .collection(DbPaths.collectioncustomers)
                                        .doc(ticket.ticketcustomerID)
                                        .snapshots(),
                                    placeholder: Container(
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: ticket
                                                        .ticketcustomerID ==
                                                    currentUserID
                                                ? ticketStatusColorForCustomers(
                                                        ticket.ticketStatus)
                                                    .withOpacity(0.2)
                                                : ticketStatusColorForAgents(
                                                        ticket.ticketStatus)
                                                    .withOpacity(0.2),
                                            child: customCircleAvatar(
                                              radius: 14,
                                              url: iAmSecondAdmin(
                                                          currentuserid:
                                                              currentUserID,
                                                          context: context) ==
                                                      true
                                                  ? observer.userAppSettingsDoc!
                                                          .secondadmincanseecustomernameandphoto!
                                                      ? registry
                                                          .getUserData(
                                                              context,
                                                              ticket
                                                                  .ticketcustomerID)
                                                          .photourl
                                                      : iAmDepartmentManager(
                                                                  currentuserid:
                                                                      currentUserID,
                                                                  context:
                                                                      context) ==
                                                              true
                                                          ? observer
                                                                  .userAppSettingsDoc!
                                                                  .departmentmanagercanseecustomernameandphoto!
                                                              ? registry
                                                                  .getUserData(
                                                                      context,
                                                                      ticket
                                                                          .ticketcustomerID)
                                                                  .photourl
                                                              : observer
                                                                      .userAppSettingsDoc!
                                                                      .agentcanseecustomernameandphoto!
                                                                  ? registry
                                                                      .getUserData(
                                                                          context,
                                                                          ticket
                                                                              .ticketcustomerID)
                                                                      .photourl
                                                                  : ""
                                                          : ""
                                                  : "",
                                            ),
                                          ),
                                          SizedBox(
                                            width: 13,
                                          ),
                                          Text(
                                              iAmSecondAdmin(
                                                          currentuserid:
                                                              currentUserID,
                                                          context: context) ==
                                                      true
                                                  ? observer.userAppSettingsDoc!
                                                          .secondadmincanseecustomernameandphoto!
                                                      ? registry
                                                          .getUserData(
                                                              context,
                                                              ticket
                                                                  .ticketcustomerID)
                                                          .fullname
                                                      : iAmDepartmentManager(
                                                                  currentuserid:
                                                                      currentUserID,
                                                                  context:
                                                                      context) ==
                                                              true
                                                          ? observer
                                                                  .userAppSettingsDoc!
                                                                  .departmentmanagercanseecustomernameandphoto!
                                                              ? registry
                                                                  .getUserData(
                                                                      context,
                                                                      ticket
                                                                          .ticketcustomerID)
                                                                  .fullname
                                                              : observer
                                                                      .userAppSettingsDoc!
                                                                      .agentcanseecustomernameandphoto!
                                                                  ? registry
                                                                      .getUserData(
                                                                          context,
                                                                          ticket
                                                                              .ticketcustomerID)
                                                                      .fullname
                                                                  : "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${ticket.ticketcustomerID}"
                                                          : "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${ticket.ticketcustomerID}"
                                                  : "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${ticket.ticketcustomerID}",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Mycolors.grey)),
                                        ],
                                      ),
                                    ),
                                    onfetchdone: (map) {
                                      CustomerModel customer =
                                          CustomerModel.fromJson(map);
                                      return Container(
                                        child: Row(
                                          children: [
                                            Stack(
                                              children: [
                                                CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor: ticket
                                                              .ticketcustomerID ==
                                                          currentUserID
                                                      ? ticketStatusColorForCustomers(
                                                              ticket
                                                                  .ticketStatus)
                                                          .withOpacity(0.2)
                                                      : ticketStatusColorForAgents(
                                                              ticket
                                                                  .ticketStatus)
                                                          .withOpacity(0.2),
                                                  child: customCircleAvatar(
                                                    radius: 14,
                                                    url: iAmSecondAdmin(
                                                                currentuserid:
                                                                    currentUserID,
                                                                context:
                                                                    context) ==
                                                            true
                                                        ? observer
                                                                .userAppSettingsDoc!
                                                                .secondadmincanseecustomernameandphoto!
                                                            ? customer.photoUrl
                                                            : iAmDepartmentManager(
                                                                        currentuserid:
                                                                            currentUserID,
                                                                        context:
                                                                            context) ==
                                                                    true
                                                                ? observer
                                                                        .userAppSettingsDoc!
                                                                        .departmentmanagercanseecustomernameandphoto!
                                                                    ? customer
                                                                        .photoUrl
                                                                    : observer
                                                                            .userAppSettingsDoc!
                                                                            .agentcanseecustomernameandphoto!
                                                                        ? customer
                                                                            .photoUrl
                                                                        : ""
                                                                : ""
                                                        : "",
                                                  ),
                                                ),
                                                customer.lastSeen == true
                                                    ? Positioned(
                                                        top: 0,
                                                        left: 0,
                                                        child: CircleAvatar(
                                                          radius: 5,
                                                          backgroundColor:
                                                              Mycolors
                                                                  .onlinetag,
                                                        ))
                                                    : SizedBox(),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 13,
                                            ),
                                            Text(
                                                iAmSecondAdmin(
                                                            currentuserid:
                                                                currentUserID,
                                                            context: context) ==
                                                        true
                                                    ? observer
                                                            .userAppSettingsDoc!
                                                            .secondadmincanseecustomernameandphoto!
                                                        ? customer.nickname
                                                        : iAmDepartmentManager(
                                                                    currentuserid:
                                                                        currentUserID,
                                                                    context:
                                                                        context) ==
                                                                true
                                                            ? observer
                                                                    .userAppSettingsDoc!
                                                                    .departmentmanagercanseecustomernameandphoto!
                                                                ? customer
                                                                    .nickname
                                                                : observer
                                                                        .userAppSettingsDoc!
                                                                        .agentcanseecustomernameandphoto!
                                                                    ? customer
                                                                        .nickname
                                                                    : "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${ticket.ticketcustomerID}"
                                                            : "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${ticket.ticketcustomerID}"
                                                    : "${getTranslatedForCurrentUser(context, 'xxcustomeridxx')} ${ticket.ticketcustomerID}",
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Mycolors.grey)),
                                          ],
                                        ),
                                      );
                                    })),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ticketdoc.data().containsKey(currentUserID)
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                              ticketdoc[currentUserID])
                                          .isBefore(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  ticketdoc[Dbkeys
                                                      .ticketlatestTimestampForAgents]))
                                      ? Container(
                                          child: Badge(
                                            shape: BadgeShape.square,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            position: BadgePosition.topEnd(
                                                top: -12, end: -20),
                                            padding: EdgeInsets.all(2),
                                            badgeContent: Text(
                                              getTranslatedForCurrentUser(
                                                  context, 'xxnewxx'),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            child: Icon(
                                                Boxicons.bx_message_rounded,
                                                color: Mycolors.greylight),
                                          ),
                                        )
                                      : SizedBox()
                                  : SizedBox(),
                              SizedBox(
                                width: 30,
                              ),
                              Text(
                                getonlyTime(context,
                                    ticket.ticketlatestTimestampForAgents),
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 11,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MtCustomfontBoldSemi(
                          text: '${ticket.ticketTitle}',
                          fontsize: 14,
                        ),
                        Container(
                          height: 30,
                        )
                      ],
                    ),
                    Divider(
                      color: Colors.transparent,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        observer.userAppSettingsDoc!.departmentBasedContent ==
                                false
                            ? Container(
                                child: Row(
                                  children: [
                                    Icon(
                                      LineAwesomeIcons.user_friends,
                                      color: ticket.ticketcustomerID ==
                                              currentUserID
                                          ? ticketStatusColorForCustomers(
                                              ticket.ticketStatus)
                                          : ticketStatusColorForAgents(
                                              ticket.ticketStatus),
                                      size: 16,
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    MtCustomfontBoldSemi(
                                      fontsize: 13,
                                      lineheight: 1.4,
                                      color: Mycolors.black,
                                      text:
                                          '${ticket.tktMEMBERSactiveList.length}',
                                    )
                                  ],
                                ),
                              )
                            : Container(
                                child: Row(
                                  children: [
                                    Icon(
                                      LineAwesomeIcons.tag,
                                      color: ticket.ticketcustomerID ==
                                              currentUserID
                                          ? ticketStatusColorForCustomers(
                                              ticket.ticketStatus)
                                          : ticketStatusColorForAgents(
                                              ticket.ticketStatus),
                                      size: 16,
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text('${ticket.ticketDepartmentID}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                          color: Mycolors.getColor(
                                              prefs, Colortype.button.index),
                                        )),
                                  ],
                                ),
                              ),
                        Container(
                          width: 70,
                          child: Center(
                            child: Text(
                              ticket.ticketcustomerID == currentUserID
                                  ? ticketStatusTextShortForCustomers(
                                      context, ticket.ticketStatus)
                                  : ticketStatusTextShortForAgents(
                                      context, ticket.ticketStatus),
                              style: TextStyle(
                                  color:
                                      ticket.ticketcustomerID == currentUserID
                                          ? ticketStatusColorForCustomers(
                                              ticket.ticketStatus)
                                          : ticketStatusColorForAgents(
                                              ticket.ticketStatus),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: ticket.ticketcustomerID == currentUserID
                                ? ticketStatusColorForCustomers(
                                        ticket.ticketStatus)
                                    .withOpacity(0.2)
                                : ticketStatusColorForAgents(
                                        ticket.ticketStatus)
                                    .withOpacity(0.2),
                          ),
                          height: 20,
                        ),
                      ],
                    )
                  ],
                ),
              ))
            ])),
        ticket.tktMEMBERSactiveList.length == 0
            ? Positioned(
                top: 6,
                right: 10,
                child: Container(
                    padding: EdgeInsets.all(3),
                    color: Colors.pinkAccent,
                    child: Text(
                      " ${getTranslatedForCurrentUser(context, 'xxnoaggentsassignedxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxagentsxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxtktsxx'))} ",
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    )))
            : SizedBox()
      ],
    ),
  );
}

BoxDecoration boxDecoration(
    {double radius = 2,
    Color color = Colors.grey,
    Color bgColor = Colors.white,
    var showShadow = false}) {
  return BoxDecoration(
      color: bgColor,
      //gradient: LinearGradient(colors: [bgColor, whiteColor]),
      boxShadow: showShadow == true
          ? [
              BoxShadow(
                  color: Color(0xfff1f4fb).withOpacity(0.4),
                  blurRadius: 0.5,
                  spreadRadius: 1)
            ]
          : [BoxShadow(color: bgColor)],
      border: showShadow == true
          ? Border.all(
              color: Color(0xfff1f4fb).withOpacity(0.99),
              style: BorderStyle.solid,
              width: 0)
          : null,
      borderRadius: BorderRadius.all(Radius.circular(radius)));
}

getonlyTime(BuildContext context, int millisecondsepoch) {
  final observer = Provider.of<Observer>(context, listen: false);
  DateTime now = DateTime.now();
  DateTime date = DateTime.fromMillisecondsSinceEpoch(millisecondsepoch);
  String when;
  if (date.day == now.day)
    // when = getTranslatedForCurrentUser(context, 'xxtodayxx');
    when = observer.userAppSettingsDoc!.is24hrsTimeformat == true
        ? Jiffy(date).Hm.toString()
        : DateFormat("h:mm a").format(date).toString();
  else if (date.day == now.subtract(Duration(days: 1)).day)
    when = getTranslatedForCurrentUser(context, 'xxyesterdayxx');
  else
    when = IsShowNativeTimDate == true
        ? getTranslatedForCurrentUser(context, DateFormat.MMMM().format(date)) +
            ' ' +
            DateFormat.d().format(date)
        : when = DateFormat.MMMd().format(date);
  return when;
}

Widget ticketWidgetForCustomers(
    {required BuildContext context,
    required SharedPreferences prefs,
    required Function(String s, String uid) ontap,
    required TicketModel ticket,
    required var ticketdoc,
    required String currentUserID,
    required bool customerCanAgentOnline}) {
  return myinkwell(
    onTap: () {
      ontap(ticket.ticketID, ticket.ticketcustomerID);
    },
    child: Stack(
      children: [
        Container(
            margin: EdgeInsets.fromLTRB(8, 5, 8, 5),
            decoration: boxDecoration(
              showShadow: false,
              radius: 10,
            ),
            child: Row(children: [
              Container(
                decoration: BoxDecoration(
                  color: ticket.ticketcustomerID == currentUserID
                      ? ticketStatusColorForCustomers(ticket.ticketStatus)
                      : ticketStatusColorForAgents(ticket.ticketStatus),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10)),
                ),
                height: 125,
                width: 5.9,
              ),
              Container(
                color:
                    (ticket.ticketStatus == TicketStatus.needsAttention.index &&
                                currentUserID != ticket.ticketcustomerID
                            ? Colors.yellow[200]
                            : Colors.white) ??
                        Colors.white,
                width: 0,
              ),
              Expanded(
                  child: Container(
                color:
                    (ticket.ticketStatus == TicketStatus.needsAttention.index &&
                                currentUserID != ticket.ticketcustomerID
                            ? Colors.yellow[200]
                            : Colors.white) ??
                        Colors.white,
                padding: EdgeInsets.fromLTRB(12, 8, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            child: Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      ticket.ticketcustomerID == currentUserID
                                          ? ticketStatusColorForCustomers(
                                                  ticket.ticketStatus)
                                              .withOpacity(0.2)
                                          : ticketStatusColorForAgents(
                                                  ticket.ticketStatus)
                                              .withOpacity(0.2),
                                  child: Icon(
                                    LineAwesomeIcons.alternate_ticket,
                                    size: 14,
                                    color:
                                        ticket.ticketcustomerID == currentUserID
                                            ? ticketStatusColorForCustomers(
                                                ticket.ticketStatus)
                                            : ticketStatusColorForAgents(
                                                ticket.ticketStatus),
                                  ),
                                ),
                                ticket.liveAgentID == "" ||
                                        ticket.liveAgentLastonline == 0 ||
                                        // customerCanAgentOnline == false ||
                                        ticket.ticketStatusShort ==
                                            TicketStatusShort.close.index ||
                                        ticket.ticketStatusShort ==
                                            TicketStatusShort.expired.index ||
                                        ticket.ticketStatusShort ==
                                            TicketStatusShort.notstarted.index
                                    ? SizedBox()
                                    : DateTime.now()
                                                .difference(DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        ticket
                                                            .liveAgentLastonline!))
                                                .inMinutes >
                                            Numberlimits
                                                .maxOnlineDurationShowForAgent
                                        ? SizedBox()
                                        : streamLoad(
                                            stream: FirebaseFirestore.instance
                                                .collection(
                                                    DbPaths.collectionagents)
                                                .doc(ticket.liveAgentID!.trim())
                                                .snapshots(),
                                            placeholder: SizedBox(),
                                            onfetchdone: (m) {
                                              if (m[Dbkeys.lastSeen] == true) {
                                                return Positioned(
                                                    left: 0,
                                                    top: 0,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Mycolors.onlinetag,
                                                      radius: 5,
                                                    ));
                                              }
                                            }),
                              ],
                            ),
                            SizedBox(
                              width: 13,
                            ),
                            Text(
                                '${getTranslatedForCurrentUser(context, 'xxidxx')} ${ticket.ticketcosmeticID}',
                                style: TextStyle(
                                    fontSize: 11, color: Mycolors.grey)),
                          ],
                        )),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Stack(
                              //   children: [
                              //     // Icon(Boxicons.bx_message_rounded,
                              //     //     color: Mycolors.greylight),
                              //     // Positioned(
                              //     //   right: 0,
                              //     //   top: 0,
                              //     //   child: CircleAvatar(
                              //     //     radius: 5,
                              //     //     backgroundColor: Mycolors.red,
                              //     //   ),
                              //     // )
                              //   ],
                              // ),
                              ticketdoc.data().containsKey(currentUserID)
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                              ticketdoc[currentUserID])
                                          .isBefore(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  ticketdoc[Dbkeys
                                                      .ticketlatestTimestampForCustomer]))
                                      ? Container(
                                          child: Badge(
                                            shape: BadgeShape.square,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            position: BadgePosition.topEnd(
                                                top: -12, end: -20),
                                            padding: EdgeInsets.all(2),
                                            badgeContent: Text(
                                              getTranslatedForCurrentUser(
                                                  context, 'xxnewxx'),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            child: Icon(
                                                Boxicons.bx_message_rounded,
                                                color: Mycolors.greylight),
                                          ),
                                        )
                                      : SizedBox()
                                  : SizedBox(),
                              SizedBox(
                                width: 30,
                              ),
                              Text(
                                getonlyTime(context,
                                    ticket.ticketlatestTimestampForCustomer),
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 11,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MtCustomfontBoldSemi(
                          text: '${ticket.ticketTitle}',
                          fontsize: 14,
                        ),
                        Container(
                          height: 30,
                        )
                      ],
                    ),
                    Divider(
                      color: Colors.transparent,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Icon(
                                LineAwesomeIcons.tag,
                                color: ticket.ticketcustomerID == currentUserID
                                    ? ticketStatusColorForCustomers(
                                        ticket.ticketStatus)
                                    : ticketStatusColorForAgents(
                                        ticket.ticketStatus),
                                size: 16,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text('${ticket.ticketDepartmentID}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    color: Mycolors.getColor(
                                        prefs, Colortype.button.index),
                                  )),
                            ],
                          ),
                        ),
                        ticket.ticketStatusShort ==
                                    TicketStatusShort.close.index &&
                                ticket.rating != 0
                            ? Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    MtCustomfontBoldSemi(
                                        fontsize: 14,
                                        text: ticket.rating.toString()),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: Mycolors.yellow,
                                      size: 15,
                                    )
                                  ],
                                ),
                              )
                            : SizedBox(),
                        Container(
                          width: 70,
                          child: Center(
                            child: Text(
                              ticket.ticketcustomerID == currentUserID
                                  ? ticketStatusTextShortForCustomers(
                                      context, ticket.ticketStatus)
                                  : ticketStatusTextShortForAgents(
                                      context, ticket.ticketStatus),
                              style: TextStyle(
                                  color:
                                      ticket.ticketcustomerID == currentUserID
                                          ? ticketStatusColorForCustomers(
                                              ticket.ticketStatus)
                                          : ticketStatusColorForAgents(
                                              ticket.ticketStatus),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: ticket.ticketcustomerID == currentUserID
                                ? ticketStatusColorForCustomers(
                                        ticket.ticketStatus)
                                    .withOpacity(0.2)
                                : ticketStatusColorForAgents(
                                        ticket.ticketStatus)
                                    .withOpacity(0.2),
                          ),
                          height: 20,
                        ),
                      ],
                    )
                  ],
                ),
              ))
            ])),
        ticket.tktMEMBERSactiveList.length == 0
            ? Positioned(
                top: 6,
                right: 10,
                child: Container(
                    padding: EdgeInsets.all(3),
                    color: Colors.pinkAccent,
                    child: Text(
                      " ${getTranslatedForCurrentUser(context, 'xxnoaggentsassignedxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxagentsxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxtktsxx'))} ",
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    )))
            : SizedBox()
      ],
    ),
  );
}
