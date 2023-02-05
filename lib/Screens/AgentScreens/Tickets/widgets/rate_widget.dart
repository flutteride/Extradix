//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Models/ticket_model.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/Tickets/TicketUtils/ticket_utils.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/widgets/CustomAlertDialog/CustomDialog.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custominput.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:thinkcreative_technologies/widgets/WarningWidgets/warning_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

Widget rateTicketByCustomer(
    {required BuildContext context,
    required String currentUserID,
    required String customerUID,
    required Observer observer,
    required TicketModel liveTicketData,
    required Function(int rating) onUpdaterating,
    required TextEditingController textEditingController,
    required GlobalKey keyloader,
    required int finalrating,
    required String ticketID}) {
  return currentUserID == customerUID
      ? observer.userAppSettingsDoc!.customerCanRateTicket == true &&
              liveTicketData.rating == 0
          ? Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(14, 40, 14, 20),
              color: Colors.white,
              // height: MediaQuery.of(
              //             context)
              //         .size
              //         .height /
              //     1.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MtCustomfontBold(
                      fontsize: 25,
                      text: getTranslatedForCurrentUser(
                          context, 'xxrateyourexperiencexx')),
                  SizedBox(
                    height: 10,
                  ),
                  MtCustomfontRegular(
                      text: getTranslatedForCurrentUser(
                          context, 'xxhelpusservexx')),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 15,
                  ),
                  buildratingWidget(
                      initialRating: 0,
                      isRatingBarStars: true,
                      onupdate: (rating) {
                        if (rating.toInt() < 1) {
                          onUpdaterating(rating.toInt());
                        } else if (rating.toInt() >= 1) {
                          onUpdaterating(rating.toInt());
                        }
                      }),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: InpuTextBox(
                      controller: textEditingController,
                      maxLines: 5,
                      hinttext: getTranslatedForCurrentUser(
                          context, 'xxdescribethroughtsxx'),
                      maxcharacters: 200,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 20,
                  ),
                  finalrating == 0
                      ? SizedBox(
                          height: 50,
                        )
                      : MySimpleButton(
                          onpressed: observer.checkIfCurrentUserIsDemo(
                                      currentUserID) ==
                                  true
                              ? () {
                                  Utils.toast(getTranslatedForCurrentUser(
                                      context, 'xxxnotalwddemoxxaccountxx'));
                                }
                              : () async {
                                  ShowLoading()
                                      .open(key: keyloader, context: context);
                                  await TicketUtils.submitRating(
                                      ticketID: ticketID,
                                      feedback:
                                          "${textEditingController.text.trim()}",
                                      rating: finalrating,
                                      customeruid: customerUID);

                                  ShowLoading()
                                      .close(key: keyloader, context: context);

                                  Utils.toast(getTranslatedForCurrentUser(
                                      context, 'xxthanksfeedbackxx'));
                                },
                          buttontext: getTranslatedForCurrentUser(
                              context, 'xxsubmitxx'),
                          buttoncolor: Mycolors.black,
                        ),
                ],
              ),
            )
          : TicketUtils.isTimeOverToReopen(
                      closedOn: liveTicketData.ticketClosedOn!,
                      context: context) ==
                  true
              ? SizedBox()
              : Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(14, 7, 14, 7),
                  color: Colors.white,
                  height: 120,
                  width: MediaQuery.of(context).size.width,
                  child: warningTile(
                      isstyledtext: true,
                      title:
                          // "Ticket is <bold>Closed</bold>. You can reopen the ticket till <bold>${TicketUtils.totalReopenDays(context)}${TicketUtils.totalReopenDays(context) < 2 ? " Day" : " Days"}</bold> after Closing.",
                          getTranslatedForCurrentUser(
                                  context, 'xxtktclosedreopentillxx')
                              .replaceAll(
                                  '(####)',
                                  getTranslatedForCurrentUser(
                                      context, 'xxtktsxx'))
                              .replaceAll(
                                  '(###)',
                                  TicketUtils.totalReopenDays(context)
                                      .toString()),
                      warningTypeIndex: WarningType.alert.index))
      : SizedBox();
}

buildratingWidget(
    {Function(double r)? onupdate,
    double? initialRating,
    required bool isRatingBarStars,
    bool? isOnlyShow = false}) {
  if (isRatingBarStars == true) {
    return isOnlyShow == false
        ? RatingBar.builder(
            unratedColor: Mycolors.greylight,
            initialRating: initialRating!,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              print(rating);
              if (onupdate == null) {
              } else {
                onupdate(rating);
              }
            },
          )
        : RatingBarIndicator(
            unratedColor: Mycolors.greylight,
            rating: initialRating!,
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            itemCount: 5,
            itemSize: 50.0,
            direction: Axis.vertical,
          );
  } else {
    return RatingBar.builder(
      unratedColor: Mycolors.greylight,
      initialRating: initialRating ?? 5,
      itemPadding: EdgeInsets.all(6),
      itemCount: 5,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Icon(
            Icons.sentiment_very_dissatisfied,
            color: Colors.red,
          );
        } else if (index == 1) {
          return Icon(
            Icons.sentiment_dissatisfied,
            color: Colors.orange[700],
          );
        } else if (index == 2) {
          return Icon(
            Icons.sentiment_satisfied,
            color: Colors.yellow[700],
          );
        } else if (index == 3) {
          return Icon(
            Icons.sentiment_satisfied_alt,
            color: Colors.lightGreen,
          );
        } else if (index == 4) {
          return Icon(
            Icons.sentiment_very_satisfied,
            color: Colors.green,
          );
        } else {
          return Icon(
            Icons.sentiment_very_satisfied,
            color: Colors.green,
          );
        }
      },
      onRatingUpdate: (rating) {
        print(rating);
        if (onupdate == null) {
        } else {
          onupdate(rating);
        }
      },
    );
  }
}
