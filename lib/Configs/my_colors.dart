//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Mycolors {
  //---- CHANGE THE BELOW COLOURS FOR YOUR OWN THEME --------
  static final Color agentSecondary = Colors.cyan;
  static final Color agentPrimary = Color(0xff00b8ff);
  static final Color agentButton = Colors.black;
  static final Color customerPrimary = Color(0xff6a78f5);
  static final Color customerSecondary = Colors.orange;
  static final Color customerButton = Colors.black;
  static final Color chatMessageBubbleBackgroundColor = Color(0xFFeefcf8);
  static final Color bottomnavbariconcolor = Mycolors.grey.withOpacity(0.8);
  static final Color chatbackground =
      new Color(0xffdde6ea); //color behind chat background image
  static final Color splashBackgroundSolidColor = Color(0xFFFFFFFF);
  static final Color statusBarColor = Colors.white;
  static final bool isdarkIconsInStatusBar = true;

  //:::---------- Below are All other color values that need not change neccessarily unless you are a developer-----
  static final Color onlinetag = Color(0xff6BD438);
  static final Color notificationdotcolor = Colors.green;
  static final Color primary = agentPrimary;
  static final Color secondary = agentSecondary;
  static final Color loadingindicator = agentSecondary;
  static final Color textboxbordercolor = Color(0xff74798b).withOpacity(0.1);
  static final Color textboxbgcolor = Color(0xfff8f9fe).withOpacity(0.8);
  static final Color backgroundcolor = Color(0xfff8f9fe);
  static final Color whiteDynamic = Colors.white;
  static final Color blackDynamic = Color(0xff353a4b);
  static final Color black = Color(0xff353a4b);
  static final Color green = Colors.green;
  static final Color grey = Color(0xff7c84aa);
  static final Color greylight = Color(0xff7c84aa).withOpacity(0.3);
  static final Color red = Color(0xffdd5865);
  static final Color cyan = Colors.cyan;
  static final Color appbar = Colors.white;
  static final Color appbartexticon = Color(0xFF242425);
  static final Color greylightcolor = Color(0xfff1f4fb);
  static final Color greytext = Color(0xff88889b);
  static final Color greydark = Color(0xffd3d5df);
  static final Color mask = Colors.black;
  static final Color greenbuttoncolor = Color(0xff5DBB7C);
  static final Color ordercard = Color(0xff727791);
  static final Color greensqaush = Color(0xff33C177);
  static final Color pink = Color(0xffff2f74);
  static final Color yellow = Color(0xfff6ba49);
  static final Color blue = Color(0xff54a3f1);
  static final Color purple = Color(0xff596ad6);
  static final Color scaffoldbcg = Color(0xffF6F7FA);
  static final Color white = Color(0xFFffffff);
  static final Color whitelight = Color(0xffF6F6F6);
  static final Color orange = Color(0xffefa031);
  static final Color favoritedotcolor = Colors.cyan;
  static final Color whitedim = Colors.white.withOpacity(0.87);
  static final Color ratingcolorbcg = Color(0xFF59AC05);
  static final List<Color> webviewLoaderColor = [
    Colors.green,
    Colors.yellow,
    Colors.purple,
  ]; // there must be 3 colors

  static Color getColor(SharedPreferences prefs, int colortypeindex) {
    if (prefs.getInt(Dbkeys.userLoginType) == null) {
      if (colortypeindex == Colortype.primary.index) {
        return customerPrimary;
      } else if (colortypeindex == Colortype.secondary.index) {
        return customerSecondary;
      } else if (colortypeindex == Colortype.button.index) {
        return customerButton;
      }
    } else if (prefs.getInt(Dbkeys.userLoginType) == Usertype.customer.index) {
      if (colortypeindex == Colortype.primary.index) {
        return customerPrimary;
      } else if (colortypeindex == Colortype.secondary.index) {
        return customerSecondary;
      } else if (colortypeindex == Colortype.button.index) {
        return customerButton;
      }
    } else if (prefs.getInt(Dbkeys.userLoginType) == Usertype.agent.index) {
      if (colortypeindex == Colortype.primary.index) {
        return agentPrimary;
      } else if (colortypeindex == Colortype.secondary.index) {
        return agentSecondary;
      } else if (colortypeindex == Colortype.button.index) {
        return agentButton;
      }
    } else if (prefs.getInt(Dbkeys.userLoginType) ==
        Usertype.secondadmin.index) {
      if (colortypeindex == Colortype.primary.index) {
        return agentPrimary;
      } else if (colortypeindex == Colortype.secondary.index) {
        return agentSecondary;
      } else if (colortypeindex == Colortype.button.index) {
        return agentButton;
      }
    }
    return customerPrimary;
  }
}
