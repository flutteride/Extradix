//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/ticket_model.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/TicketUtils/ticket_utils.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/ticket_chat_room_details.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/chat.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Utils/getRolePermission.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/widgets/CustomAlertDialog/CustomDialog.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/FormDialog.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/dynamic_modal_bottomsheet.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/page_navigator.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

onPressMenu(
    BuildContext context,
    String ticketcosmeticID,
    Observer observer,
    bool isCustomer,
    TicketModel liveticketData,
    String currentUserID,
    GlobalKey keyloader,
    String customerUID,
    String ticketID,
    TextEditingController attentionMessageController,
    SharedPreferences prefs) {
  ListTile changeStatusForOpened = ListTile(
    onTap: () {
      List<ListTile> changeStatusmenuItems = [];

      ListTile closedByCustomer = ListTile(
        onTap: observer.checkIfCurrentUserIsDemo(currentUserID) == true
            ? () {
                Utils.toast(getTranslatedForCurrentUser(
                    context, 'xxxnotalwddemoxxaccountxx'));
              }
            : () async {
                hidekeyboard(context);
                Navigator.of(context).pop();

                ShowLoading().open(key: keyloader, context: context);

                await TicketUtils.closeTicket(
                    ticketID: liveticketData.ticketID,
                    context: context,
                    isCustomer: isCustomer,
                    currentUserID: currentUserID,
                    liveTicketModel: liveticketData,
                    agents: liveticketData.tktMEMBERSactiveList);
                ShowLoading().close(key: keyloader, context: context);
              },
        contentPadding: EdgeInsets.all(10),
        title: MtCustomfontBoldSemi(
          text: getTranslatedForCurrentUser(context, 'xxclosexxxx').replaceAll(
              '(####)', getTranslatedForCurrentUser(context, 'xxtktsxx')),
          fontsize: 17,
        ),
        leading: Icon(
          EvaIcons.closeCircleOutline,
          size: 29,
          color: Mycolors.red,
        ),
      );
      ListTile closedByAgent = ListTile(
        onTap: observer.checkIfCurrentUserIsDemo(currentUserID) == true
            ? () {
                Utils.toast(getTranslatedForCurrentUser(
                    context, 'xxxnotalwddemoxxaccountxx'));
              }
            : () async {
                hidekeyboard(context);
                Navigator.of(context).pop();

                ShowLoading().open(key: keyloader, context: context);

                await TicketUtils.closeTicket(
                    ticketID: liveticketData.ticketID,
                    context: context,
                    isCustomer: false,
                    currentUserID: currentUserID,
                    liveTicketModel: liveticketData,
                    agents: liveticketData.tktMEMBERSactiveList);
                ShowLoading().close(key: keyloader, context: context);
              },
        contentPadding: EdgeInsets.all(10),
        title: MtCustomfontBoldSemi(
          text: getTranslatedForCurrentUser(context, 'xxclosexxxx').replaceAll(
              '(####)', getTranslatedForCurrentUser(context, 'xxtktsxx')),
          fontsize: 17,
        ),
        leading: Icon(
          EvaIcons.closeCircleOutline,
          size: 29,
          color: Mycolors.red,
        ),
      );
      ListTile closedBySecondAdmin = ListTile(
        onTap: observer.checkIfCurrentUserIsDemo(currentUserID) == true
            ? () {
                Utils.toast(getTranslatedForCurrentUser(
                    context, 'xxxnotalwddemoxxaccountxx'));
              }
            : () async {
                hidekeyboard(context);
                Navigator.of(context).pop();

                ShowLoading().open(key: keyloader, context: context);

                await TicketUtils.closeTicket(
                    ticketID: liveticketData.ticketID,
                    context: context,
                    isCustomer: false,
                    currentUserID: currentUserID,
                    liveTicketModel: liveticketData,
                    agents: liveticketData.tktMEMBERSactiveList);
                ShowLoading().close(key: keyloader, context: context);
              },
        contentPadding: EdgeInsets.all(10),
        title: MtCustomfontBoldSemi(
          text: getTranslatedForCurrentUser(context, 'xxclosexxxx').replaceAll(
              '(####)', getTranslatedForCurrentUser(context, 'xxtktsxx')),
          fontsize: 17,
        ),
        leading: Icon(
          EvaIcons.closeCircleOutline,
          size: 29,
          color: Mycolors.red,
        ),
      );
      ListTile closedByDepartmentManager = ListTile(
        onTap: observer.checkIfCurrentUserIsDemo(currentUserID) == true
            ? () {
                Utils.toast(getTranslatedForCurrentUser(
                    context, 'xxxnotalwddemoxxaccountxx'));
              }
            : () async {
                hidekeyboard(context);
                Navigator.of(context).pop();

                ShowLoading().open(key: keyloader, context: context);

                await TicketUtils.closeTicket(
                    ticketID: liveticketData.ticketID,
                    context: context,
                    isCustomer: false,
                    currentUserID: currentUserID,
                    liveTicketModel: liveticketData,
                    agents: liveticketData.tktMEMBERSactiveList);
                ShowLoading().close(key: keyloader, context: context);
              },
        contentPadding: EdgeInsets.all(10),
        title: MtCustomfontBoldSemi(
          text: getTranslatedForCurrentUser(context, 'xxclosexxxx').replaceAll(
              '(####)', getTranslatedForCurrentUser(context, 'xxtktsxx')),
          fontsize: 17,
        ),
        leading: Icon(
          EvaIcons.closeCircleOutline,
          size: 29,
          color: Mycolors.red,
        ),
      );

      ListTile needsAttention = ListTile(
        onTap: observer.checkIfCurrentUserIsDemo(currentUserID) == true
            ? () {
                Utils.toast(getTranslatedForCurrentUser(
                    context, 'xxxnotalwddemoxxaccountxx'));
              }
            : () async {
                hidekeyboard(context);
                Navigator.of(context).pop();

                ShowFormDialog().open(
                    inputFormatter: [],
                    iscapital: false,
                    controller: attentionMessageController,
                    maxlength: 500,
                    maxlines: 4,
                    minlines: 2,
                    iscentrealign: true,
                    context: context,
                    title: getTranslatedForCurrentUser(
                            context, 'xxreasonforadminxx')
                        .replaceAll('(####)',
                            getTranslatedForCurrentUser(context, 'xxagentsxx')),
                    onpressed:
                        observer.checkIfCurrentUserIsDemo(currentUserID) == true
                            ? () {
                                Utils.toast(getTranslatedForCurrentUser(
                                    context, 'xxxnotalwddemoxxaccountxx'));
                              }
                            : () async {
                                ShowLoading()
                                    .open(key: keyloader, context: context);

                                await TicketUtils.markNeedsAttention(
                                    ticketID: liveticketData.ticketID,
                                    context: context,
                                    attentionResaon:
                                        attentionMessageController.text.trim(),
                                    currentUserID: currentUserID,
                                    liveTicketModel: liveticketData,
                                    agents:
                                        liveticketData.tktMEMBERSactiveList);

                                ShowLoading()
                                    .close(key: keyloader, context: context);
                                hidekeyboard(context);
                                Navigator.of(context).pop();
                              },
                    buttontext: getTranslatedForCurrentUser(
                        context, 'xxupdatestatusxx'),
                    hinttext: getTranslatedForCurrentUser(
                        context, 'xxenterreasonxx'));
              },
        contentPadding: EdgeInsets.all(10),
        title: MtCustomfontBoldSemi(
          text: getTranslatedForCurrentUser(context, 'xxrmarkneedsattentionxx'),
          fontsize: 17,
        ),
        leading: Icon(
          EvaIcons.bulb,
          size: 29,
          color: Mycolors.yellow,
        ),
      );

      ListTile needsAttentionOFF = ListTile(
        onTap: observer.checkIfCurrentUserIsDemo(currentUserID) == true
            ? () {
                Utils.toast(getTranslatedForCurrentUser(
                    context, 'xxxnotalwddemoxxaccountxx'));
              }
            : () async {
                hidekeyboard(context);
                Navigator.of(context).pop();

                ShowLoading().open(key: keyloader, context: context);

                await TicketUtils.markNeedsAttentionOFF(
                    ticketID: liveticketData.ticketID,
                    context: context,
                    attentionResaon: attentionMessageController.text.trim(),
                    currentUserID: currentUserID,
                    liveTicketModel: liveticketData,
                    agents: liveticketData.tktMEMBERSactiveList);

                ShowLoading().close(key: keyloader, context: context);
                hidekeyboard(context);
              },
        contentPadding: EdgeInsets.all(10),
        title: MtCustomfontBoldSemi(
          text: getTranslatedForCurrentUser(context, 'xxremoveattentionmarkxx'),
          fontsize: 17,
        ),
        leading: Icon(
          EvaIcons.bulbOutline,
          size: 29,
          color: Mycolors.orange,
        ),
      );
      ListTile canWeCloseByAgent = ListTile(
        onTap: observer.checkIfCurrentUserIsDemo(currentUserID) == true
            ? () {
                Utils.toast(getTranslatedForCurrentUser(
                    context, 'xxxnotalwddemoxxaccountxx'));
              }
            : () async {
                hidekeyboard(context);
                Navigator.of(context).pop();

                ShowLoading().open(key: keyloader, context: context);

                await TicketUtils.askToClose(
                    ticketID: liveticketData.ticketID,
                    context: context,
                    isCustomer: false,
                    currentUserID: currentUserID,
                    liveTicketModel: liveticketData,
                    agents: liveticketData.tktMEMBERSactiveList);
                ShowLoading().close(key: keyloader, context: context);
              },
        contentPadding: EdgeInsets.all(10),
        title: MtCustomfontBoldSemi(
          text: getTranslatedForCurrentUser(context, 'xxrequestxx')
              .replaceAll('(####)',
                  getTranslatedForCurrentUser(context, 'xxcustomerxx'))
              .replaceAll(
                  '(###)', getTranslatedForCurrentUser(context, 'xxtktsxx')),
          fontsize: 17,
        ),
        leading: Icon(
          EvaIcons.questionMarkCircleOutline,
          size: 29,
          color: Mycolors.purple,
        ),
      );
      ListTile canWeCloseByCustomer = ListTile(
        onTap: observer.checkIfCurrentUserIsDemo(currentUserID) == true
            ? () {
                Utils.toast(getTranslatedForCurrentUser(
                    context, 'xxxnotalwddemoxxaccountxx'));
              }
            : () async {
                hidekeyboard(context);
                Navigator.of(context).pop();

                ShowLoading().open(key: keyloader, context: context);

                await TicketUtils.askToClose(
                    ticketID: liveticketData.ticketID,
                    context: context,
                    isCustomer: true,
                    currentUserID: currentUserID,
                    liveTicketModel: liveticketData,
                    agents: liveticketData.tktMEMBERSactiveList);
                ShowLoading().close(key: keyloader, context: context);
              },
        contentPadding: EdgeInsets.all(10),
        title: MtCustomfontBoldSemi(
          text: getTranslatedForCurrentUser(context, 'xxrequestxx')
              .replaceAll(
                  '(####)', getTranslatedForCurrentUser(context, 'xxagentxx'))
              .replaceAll(
                  '(###)', getTranslatedForCurrentUser(context, 'xxtktsxx')),
          fontsize: 17,
        ),
        leading: Icon(
          EvaIcons.questionMarkCircleOutline,
          size: 29,
          color: Mycolors.cyan,
        ),
      );

      if (isCustomer == true) {
        if (observer.userAppSettingsDoc!.customerCanCloseTicket! &&
            !changeStatusmenuItems.contains(closedByCustomer)) {
          changeStatusmenuItems.add(closedByCustomer);
        }
        if (observer.userAppSettingsDoc!.customerCanCloseTicket! &&
            !changeStatusmenuItems.contains(canWeCloseByCustomer)) {
          changeStatusmenuItems.add(canWeCloseByCustomer);
        }
      } else if (iAmSecondAdmin(
          currentuserid: currentUserID, context: context)) {
        if (observer.userAppSettingsDoc!.secondadminCanChangeTicketStatus! &&
            liveticketData.ticketStatus == TicketStatus.needsAttention.index &&
            !changeStatusmenuItems.contains(needsAttentionOFF)) {
          changeStatusmenuItems.add(needsAttentionOFF);
        }
        if (observer.userAppSettingsDoc!.secondAdminCanCloseTicket! &&
            !changeStatusmenuItems.contains(closedBySecondAdmin)) {
          changeStatusmenuItems.add(closedBySecondAdmin);
        }
        if (observer.userAppSettingsDoc!.secondAdminCanCloseTicket! &&
            !changeStatusmenuItems.contains(canWeCloseByAgent)) {
          changeStatusmenuItems.add(canWeCloseByAgent);
        }
        if (observer.userAppSettingsDoc!.secondadminCanChangeTicketStatus! &&
            !changeStatusmenuItems.contains(needsAttention) &&
            liveticketData.ticketStatus != TicketStatus.needsAttention.index) {
          changeStatusmenuItems.add(needsAttention);
        }
      } else if (iAmDepartmentManager(
          currentuserid: currentUserID, context: context)) {
        if (observer
                .userAppSettingsDoc!.departmentmanagerCanChangeTicketStatus! &&
            liveticketData.ticketStatus == TicketStatus.needsAttention.index &&
            !changeStatusmenuItems.contains(needsAttentionOFF)) {
          changeStatusmenuItems.add(needsAttentionOFF);
        }
        if (observer.userAppSettingsDoc!.departmentmanagerCanCloseTicket! &&
            !changeStatusmenuItems.contains(closedByDepartmentManager)) {
          changeStatusmenuItems.add(closedByDepartmentManager);
        }
        if (observer.userAppSettingsDoc!.secondAdminCanCloseTicket! &&
            !changeStatusmenuItems.contains(canWeCloseByAgent)) {
          changeStatusmenuItems.add(canWeCloseByAgent);
        }
        if (observer
                .userAppSettingsDoc!.departmentmanagerCanChangeTicketStatus! &&
            !changeStatusmenuItems.contains(needsAttention) &&
            liveticketData.ticketStatus != TicketStatus.needsAttention.index) {
          changeStatusmenuItems.add(needsAttention);
        }
      } else {
        if (observer.userAppSettingsDoc!.agentCanChangeTicketStatus! &&
            liveticketData.ticketStatus == TicketStatus.needsAttention.index &&
            !changeStatusmenuItems.contains(needsAttentionOFF)) {
          changeStatusmenuItems.add(needsAttentionOFF);
        }
        if (observer.userAppSettingsDoc!.agentCanCloseTicket! &&
            !changeStatusmenuItems.contains(closedByAgent)) {
          changeStatusmenuItems.add(closedByAgent);
        }
        if (observer.userAppSettingsDoc!.agentCanCloseTicket! &&
            !changeStatusmenuItems.contains(canWeCloseByAgent)) {
          changeStatusmenuItems.add(canWeCloseByAgent);
        }
        if (observer.userAppSettingsDoc!.agentCanChangeTicketStatus! &&
            !changeStatusmenuItems.contains(needsAttention) &&
            liveticketData.ticketStatus != TicketStatus.needsAttention.index) {
          changeStatusmenuItems.add(needsAttention);
        }
      }
      hidekeyboard(context);
      Navigator.of(context).pop();
      showDynamicModalBottomSheet(
          title: "", context: context, widgetList: changeStatusmenuItems);
    },
    title: MtCustomfontBoldSemi(
      text: getTranslatedForCurrentUser(context, 'xxchangexxstatusxx')
          .replaceAll(
              '(####)', getTranslatedForCurrentUser(context, 'xxtktsxx')),
      fontsize: 17,
    ),
    leading: Icon(
      LineAwesomeIcons.alternate_ticket,
      size: 33,
      color: Mycolors.pink,
    ),
  );
  ListTile changeStatusForReOpened = ListTile(
    onTap: observer.checkIfCurrentUserIsDemo(currentUserID) == true
        ? () {
            Utils.toast(getTranslatedForCurrentUser(
                context, 'xxxnotalwddemoxxaccountxx'));
          }
        : () {
            List<ListTile> reopenmenuItems = [];
            ListTile reOpened = ListTile(
              onTap: observer.checkIfCurrentUserIsDemo(currentUserID) == true
                  ? () {
                      Utils.toast(getTranslatedForCurrentUser(
                          context, 'xxxnotalwddemoxxaccountxx'));
                    }
                  : () async {
                      hidekeyboard(context);
                      Navigator.of(context).pop();

                      ShowLoading().open(key: keyloader, context: context);

                      await TicketUtils.reopenTicket(
                          ticketID: liveticketData.ticketID,
                          context: context,
                          isCustomer: isCustomer,
                          currentUserID: currentUserID,
                          liveTicketModel: liveticketData,
                          agents: liveticketData.tktMEMBERSactiveList);
                      ShowLoading().close(key: keyloader, context: context);
                    },
              contentPadding: EdgeInsets.all(10),
              title: MtCustomfontBoldSemi(
                text: getTranslatedForCurrentUser(context, 'xxreopenxx')
                    .replaceAll('(####)',
                        getTranslatedForCurrentUser(context, 'xxtktsxx')),
                fontsize: 17,
              ),
              leading: Icon(
                EvaIcons.refreshOutline,
                size: 29,
                color: Mycolors.red,
              ),
            );
            if (isCustomer) {
              if (observer.userAppSettingsDoc!.customerCanReopenTicket! &&
                  TicketUtils.isTimeOverToReopen(
                          closedOn: liveticketData.ticketClosedOn!,
                          context: context) ==
                      false &&
                  !reopenmenuItems.contains(reOpened)) {
                reopenmenuItems.add(reOpened);
              }
            } else if (iAmSecondAdmin(
                currentuserid: currentUserID, context: context)) {
              if (observer.userAppSettingsDoc!.secondadminCanReopenTicket! &&
                  TicketUtils.isTimeOverToReopen(
                          closedOn: liveticketData.ticketClosedOn!,
                          context: context) ==
                      false &&
                  !reopenmenuItems.contains(reOpened)) {
                reopenmenuItems.add(reOpened);
              }
            } else if (iAmDepartmentManager(
                currentuserid: currentUserID, context: context)) {
              if (observer
                      .userAppSettingsDoc!.departmentManagerCanReopenTicket! &&
                  TicketUtils.isTimeOverToReopen(
                          closedOn: liveticketData.ticketClosedOn!,
                          context: context) ==
                      false &&
                  !reopenmenuItems.contains(reOpened)) {
                reopenmenuItems.add(reOpened);
              }
            } else {
              if (observer.userAppSettingsDoc!.agentCanReopenTicket! &&
                  !reopenmenuItems.contains(reOpened) &&
                  TicketUtils.isTimeOverToReopen(
                          closedOn: liveticketData.ticketClosedOn!,
                          context: context) ==
                      false) {
                reopenmenuItems.add(reOpened);
              }
            }
            hidekeyboard(context);
            Navigator.of(context).pop();
            showDynamicModalBottomSheet(
                title: "", context: context, widgetList: reopenmenuItems);
          },
    title: MtCustomfontBoldSemi(
      text: getTranslatedForCurrentUser(context, 'xxreopenxx').replaceAll(
          '(####)', getTranslatedForCurrentUser(context, 'xxtktsxx')),
      fontsize: 17,
    ),
    leading: Icon(
      EvaIcons.refreshOutline,
      size: 33,
      color: Mycolors.pink,
    ),
  );

  List<ListTile> menuListMain = [];

  checkAndAddForOpened(ListTile m) {
    if (!menuListMain.contains(m)) {
      menuListMain.add(m);
    }
  }

  checkAndAddForReOpened(ListTile m) {
    if (!menuListMain.contains(m)) {
      menuListMain.add(m);
    }
  }

  if ((liveticketData.ticketStatusShort == TicketStatusShort.active.index ||
      liveticketData.ticketStatusShort == TicketStatusShort.notstarted.index)) {
    //when ticket is active || ticket is reopened by customer
    if (iAmSecondAdmin(currentuserid: currentUserID, context: context) ==
        true) {
      if ((observer.userAppSettingsDoc!.secondadminCanChangeTicketStatus ==
              true ||
          observer.userAppSettingsDoc!.secondAdminCanCloseTicket == true)) {
        checkAndAddForOpened(changeStatusForOpened);
      }
    } else if (iAmDepartmentManager(
            currentuserid: currentUserID, context: context) ==
        true) {
      if ((observer
                  .userAppSettingsDoc!.departmentmanagerCanChangeTicketStatus ==
              true ||
          observer.userAppSettingsDoc!.departmentmanagerCanCloseTicket ==
              true)) {
        checkAndAddForOpened(changeStatusForOpened);
      }
    } else if (isCustomer == true) {
      if ((observer.userAppSettingsDoc!.customerCanCloseTicket == true)) {
        checkAndAddForOpened(changeStatusForOpened);
      }
    } else {
      if ((observer.userAppSettingsDoc!.agentCanChangeTicketStatus == true ||
          observer.userAppSettingsDoc!.agentCanCloseTicket == true)) {
        checkAndAddForOpened(changeStatusForOpened);
      }
    }
  } else if (liveticketData.ticketStatusShort ==
      TicketStatusShort.close.index) {
    //when ticket is closed
    if (iAmSecondAdmin(currentuserid: currentUserID, context: context) ==
        true) {
      if ((observer.userAppSettingsDoc!.secondadminCanReopenTicket == true &&
          TicketUtils.isTimeOverToReopen(
                  closedOn: liveticketData.ticketClosedOn!, context: context) ==
              false)) {
        checkAndAddForReOpened(changeStatusForReOpened);
      }
    } else if (iAmDepartmentManager(
            currentuserid: currentUserID, context: context) ==
        true) {
      if ((observer.userAppSettingsDoc!.departmentManagerCanReopenTicket ==
              true &&
          TicketUtils.isTimeOverToReopen(
                  closedOn: liveticketData.ticketClosedOn!, context: context) ==
              false)) {
        checkAndAddForReOpened(changeStatusForReOpened);
      }
    } else if (isCustomer == true) {
      if ((observer.userAppSettingsDoc!.customerCanReopenTicket == true &&
          TicketUtils.isTimeOverToReopen(
                  closedOn: liveticketData.ticketClosedOn!, context: context) ==
              false)) {
        checkAndAddForReOpened(changeStatusForReOpened);
      }
    } else {
      if (observer.userAppSettingsDoc!.agentCanReopenTicket == true) {
        if (TicketUtils.isTimeOverToReopen(
                closedOn: liveticketData.ticketClosedOn!, context: context) ==
            false) {
          checkAndAddForReOpened(changeStatusForReOpened);
        }
      }
    }
  }

  checkAndAddForOpened(ListTile(
    onTap: () {
      hidekeyboard(context);
      Navigator.of(context).pop();
      pageNavigator(
          context,
          TicketDetails(
              prefs: prefs,
              isCustomerViewing: currentUserID == customerUID,
              ticketCosmeticID: ticketcosmeticID,
              ticketID: ticketID,
              currentuserid: currentUserID,
              onrefreshPreviousPage: () {}));
    },
    title: MtCustomfontBoldSemi(
      text: getTranslatedForCurrentUser(context, 'xxseetktdetailsxx')
          .replaceAll(
              '(####)', getTranslatedForCurrentUser(context, 'xxtktsxx')),
      fontsize: 17,
    ),
    leading: Icon(
      LineAwesomeIcons.clipboard_list,
      size: 35,
      color: Mycolors.orange,
    ),
  ));

  showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      builder: (BuildContext context) {
        // return your layout
        return Container(
            padding: EdgeInsets.all(12),
            height: 170,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: menuListMain));
      });
}
