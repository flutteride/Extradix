//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/ticket_message.dart';
import 'package:thinkcreative_technologies/Models/ticket_model.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/TicketUtils/ticket_utils.dart';
import 'package:thinkcreative_technologies/Services/FirebaseServices/firebase_api.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget closeTicketAction(
    {required BuildContext context,
    required Observer observer,
    required bool isActionShownToCustomer,
    required String currentUserID,
    required String ticketID,
    required TicketModel liveTicketModel}) {
  return Card(
      margin: EdgeInsets.all(15),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            MtCustomfontBoldSemi(
              text: getTranslatedForCurrentUser(context, 'xxclosexxxx')
                  .replaceAll('(####)',
                      getTranslatedForCurrentUser(context, 'xxtktsxx')),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: MtCustomfontRegular(
                lineheight: 1.4,
                color: Mycolors.greytext,
                fontsize: 13,
                textalign: TextAlign.center,
                text: currentUserID == liveTicketModel.ticketcustomerID
                    ? observer.userAppSettingsDoc!.customerCanReopenTicket! &&
                            observer.userAppSettingsDoc!.reopenTicketTillDays! >
                                0
                        ? "${getTranslatedForCurrentUser(context, 'xxshallweclosexx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxtktsxx'))} ${getTranslatedForCurrentUser(context, 'xxreopentillxx').replaceAll('(#####)', getTranslatedForCurrentUser(context, 'xxyouxx')).replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxtktsxx')).replaceAll('(###)', observer.userAppSettingsDoc!.reopenTicketTillDays!.toString())}"
                        : observer.userAppSettingsDoc!.customerCanCreateTicket!
                            ? "${getTranslatedForCurrentUser(context, 'xxshallweclosexx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxtktsxx'))} ${getTranslatedForCurrentUser(context, 'xxincasecustomerxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxyouxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxsupporttktxx'))}"
                            : "${getTranslatedForCurrentUser(context, 'xxshallweclosexx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxtktsxx'))} ${getTranslatedForCurrentUser(context, 'xxincasecustomerxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxagentsxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxsupporttktxx'))}"
                    : observer.userAppSettingsDoc!.customerCanReopenTicket! &&
                            observer.userAppSettingsDoc!.reopenTicketTillDays! >
                                0
                        ? "${getTranslatedForCurrentUser(context, 'xxrequestedxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxcustomerxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxtktsxx'))}. ${getTranslatedForCurrentUser(context, 'xxreopentillxx').replaceAll('(#####)', getTranslatedForCurrentUser(context, 'xxyouxx')).replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxtktsxx')).replaceAll('(###)', observer.userAppSettingsDoc!.reopenTicketTillDays!.toString())}"
                        : observer.userAppSettingsDoc!.customerCanCreateTicket!
                            ? "${getTranslatedForCurrentUser(context, 'xxrequestedxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxcustomerxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxtktsxx'))}.  ${getTranslatedForCurrentUser(context, 'xxincasecustomerxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxcustomerxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxsupporttktxx'))}"
                            : getTranslatedForCurrentUser(
                                    context, 'xxrequestedxx')
                                .replaceAll(
                                    '(####)',
                                    getTranslatedForCurrentUser(
                                        context, 'xxcustomerxx'))
                                .replaceAll(
                                    '(###)',
                                    getTranslatedForCurrentUser(
                                        context, 'xxtktsxx')),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MySimpleButton(
                  onpressed: observer.checkIfCurrentUserIsDemo(currentUserID) ==
                          true
                      ? () {
                          Utils.toast(getTranslatedForCurrentUser(
                              context, 'xxxnotalwddemoxxaccountxx'));
                        }
                      : () async {
                          var registry =
                              Provider.of<UserRegistry>(context, listen: false);
                          var observer =
                              Provider.of<Observer>(context, listen: false);
                          int timestamp = DateTime.now().millisecondsSinceEpoch;

                          await FirebaseFirestore.instance
                              .collection(DbPaths.collectiontickets)
                              .doc(ticketID)
                              .update({
                            Dbkeys.ticketlatestTimestampForAgents:
                                DateTime.now().millisecondsSinceEpoch,
                            Dbkeys.ticketlatestTimestampForCustomer:
                                DateTime.now().millisecondsSinceEpoch,
                            Dbkeys.ticketStatus: isActionShownToCustomer == true
                                ? TicketStatus.active.index
                                : TicketStatus.active.index,
                            Dbkeys.ticketStatusShort:
                                TicketStatusShort.active.index,
                          });
                          await FirebaseFirestore.instance
                              .collection(DbPaths.collectiontickets)
                              .doc(ticketID)
                              .collection(DbPaths.collectionticketChats)
                              .doc(timestamp.toString() + '--' + currentUserID)
                              .set(
                                  TicketMessage(
                                    tktMsgCUSTOMERID:
                                        liveTicketModel.ticketcustomerID,
                                    tktMssgCONTENT:
                                        "${getTranslatedForCurrentUser(context, 'xxclosingdeniedxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxtktsxx'))}",
                                    tktMssgISDELETED: false,
                                    tktMssgTIME:
                                        DateTime.now().millisecondsSinceEpoch,
                                    tktMssgSENDBY: currentUserID,
                                    tktMssgTYPE: isActionShownToCustomer
                                        ? MessageType
                                            .rROBOTclosingDeniedByCustomer.index
                                        : MessageType
                                            .rROBOTclosingDeniedByAgent.index,
                                    tktMssgSENDERNAME: registry
                                        .getUserData(context, currentUserID)
                                        .fullname,
                                    tktMssgISREPLY: false,
                                    tktMssgISFORWARD: false,
                                    tktMssgREPLYTOMSSGDOC: {},
                                    tktMssgTicketName:
                                        liveTicketModel.ticketTitle,
                                    tktMssgTicketIDflitered:
                                        liveTicketModel.ticketidFiltered,
                                    tktMssgSENDFOR: isActionShownToCustomer
                                        ? [
                                            // MssgSendFor.agent.index,
                                            MssgSendFor.agent.index,
                                            MssgSendFor.customer.index,
                                          ]
                                        : [
                                            MssgSendFor.agent.index,
                                            MssgSendFor.customer.index,
                                          ],
                                    tktMsgSenderIndex: isActionShownToCustomer
                                        ? Usertype.customer.index
                                        : Usertype.agent.index,
                                    tktMsgInt2: 0,
                                    isShowSenderNameInNotification: true,
                                    tktMsgBool2: true,
                                    notificationActiveList: observer
                                                .userAppSettingsDoc!
                                                .departmentBasedContent ==
                                            true
                                        ? [
                                            liveTicketModel.ticketDepartmentID,
                                          ]
                                        : [],
                                    tktMssgLISToptional: [],
                                    tktMsgList2: [],
                                    tktMsgList3: [],
                                    tktMsgMap1: {},
                                    tktMsgMap2: {},
                                    tktMsgDELETEDby: '',
                                    tktMsgDELETEREASON: '',
                                    tktMsgString4: '',
                                    tktMsgString5: '',
                                    ttktMsgString3: '',
                                  ).toMap(),
                                  SetOptions(merge: true));

                          FirebaseApi.runTransactionRecordActivity(
                            parentid: "TICKET--$ticketID",
                            title: "Ticket Closing request Denied",
                            postedbyID: currentUserID,
                            onErrorFn: (e) {},
                            onSuccessFn: () {},
                            plainDesc: isActionShownToCustomer
                                ? "Customer ID: $currentUserID denied Closing request by Agent for the Ticket ${liveTicketModel.ticketTitle} (ID: $ticketID)"
                                : "Agent ID: $currentUserID denied Closing request by Customer for the  Ticket ${liveTicketModel.ticketTitle} (ID: $ticketID)",
                          );
                        },
                  buttoncolor: Mycolors.black,
                  buttontext:
                      getTranslatedForCurrentUser(context, 'xxnotnowxx'),
                  width: MediaQuery.of(context).size.width / 2.6,
                ),
                MySimpleButton(
                  onpressed:
                      observer.checkIfCurrentUserIsDemo(currentUserID) == true
                          ? () {
                              Utils.toast(getTranslatedForCurrentUser(
                                  context, 'xxxnotalwddemoxxaccountxx'));
                            }
                          : () async {
                              await TicketUtils.closeTicket(
                                  ticketID: ticketID,
                                  context: context,
                                  isCustomer: isActionShownToCustomer,
                                  currentUserID: currentUserID,
                                  liveTicketModel: liveTicketModel,
                                  agents: liveTicketModel.tktMEMBERSactiveList);
                            },
                  buttoncolor: Mycolors.orange,
                  buttontext: getTranslatedForCurrentUser(context, 'xxclosexx'),
                  width: MediaQuery.of(context).size.width / 2.6,
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ));
}
