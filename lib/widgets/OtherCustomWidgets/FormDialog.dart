//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Configs/number_limits.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/CustomAlertDialog.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custominput.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShowFormDialog {
  open(
      {required BuildContext context,
      String? title,
      String? subtitle,
      bool? iscentrealign,
      String? hinttext,
      int? maxlength,
      int? maxlines,
      int? minlines,
      Function? onpressed,
      String? rightbtntext,
      bool? iscapital,
      TextEditingController? controller,
      List<TextInputFormatter>? inputFormatter,
      String? leftbtntext,
      String? buttontext,
      TextInputType? keyboardtype,
      Function? leftbtnonpress,
      Function? rightbtnonpress}) {
    showGeneralDialog(
      barrierLabel: getTranslatedForCurrentUser(context, 'xxclosexx'),
      barrierDismissible: true,
      context: context,
      barrierColor: Colors.black54, // space around dialog
      transitionDuration: Duration(milliseconds: 300),
      transitionBuilder: (context, a1, a2, child) {
        return ScaleTransition(
            scale: CurvedAnimation(
                parent: a1,
                curve: Curves.fastLinearToSlowEaseIn,
                reverseCurve: Curves.easeOutBack),
            child: CustomAlertDialog(
              content: Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  width: MediaQuery.of(context).size.width / 1.3,
                  height: minlines == null
                      ? MediaQuery.of(context).size.height / 3.5
                      : minlines >= 2
                          ? MediaQuery.of(context).size.height / 2.8
                          : minlines >= 3
                              ? MediaQuery.of(context).size.height / 1.8
                              : MediaQuery.of(context).size.height / 1.3,
                  decoration: new BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: const Color(0xFFFFFF),
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(32.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MtCustomfontBold(
                        textalign: iscentrealign == true
                            ? TextAlign.center
                            : TextAlign.left,
                        text: title ?? 'Confirm ',
                        fontsize: 18,
                        color: Mycolors.grey,
                      ),
                      subtitle == null
                          ? SizedBox()
                          : MtCustomfontLight(
                              textalign: iscentrealign == true
                                  ? TextAlign.center
                                  : TextAlign.left,
                              text: subtitle,
                              fontsize: 12.7,
                              color: Mycolors.grey,
                            ),
                      InpuTextBox(
                        maxLines: maxlines,
                        minLines: minlines,
                        controller: controller,
                        keyboardtype: keyboardtype,
                        maxcharacters: maxlength ?? Numberlimits.maxtitledigits,
                        textCapitalization: iscapital == true
                            ? TextCapitalization.characters
                            : TextCapitalization.sentences,
                        inputFormatter: inputFormatter ?? [],
                        hinttext: hinttext ?? '',
                        leftrightmargin: 0,
                        title: '',
                        fontsize: 17,
                      ),
                      MySimpleButton(
                        buttoncolor: Mycolors.black,
                        height: 45,
                        onpressed: onpressed ??
                            () {
                              Navigator.pop(context);
                            },
                        buttontext: buttontext ??
                            getTranslatedForCurrentUser(context, 'xxsubmitxx'),
                      )
                    ],
                  ) //Contents here
                  ),
            ));
      },
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        return SizedBox();
      },
    );
  }
}
