//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'package:device_info/device_info.dart';
import 'package:thinkcreative_technologies/Configs/MyRegisteredFonts.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Configs/optional_constants.dart';
import 'package:thinkcreative_technologies/Models/basic_settings_model_userapp.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/auth/reset_password.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/auth/verify_email.dart';
import 'package:thinkcreative_technologies/Screens/CustomerScreens/auth/verify_email.dart';
import 'package:thinkcreative_technologies/Screens/CustomerScreens/auth/verify_phone.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/chat.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/auth/verify_phone.dart';
import 'package:thinkcreative_technologies/Screens/chat_screen/utils/audioPlayback.dart';
import 'package:thinkcreative_technologies/Screens/privacypolicy&TnC/PdfViewFromCachedUrl.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/liveListener.dart';
import 'package:thinkcreative_technologies/Utils/custom_url_launcher.dart';
import 'package:thinkcreative_technologies/Utils/error_codes.dart';
import 'package:thinkcreative_technologies/widgets/CustomAlertDialog/CustomDialog.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custom_buttons.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/custominput.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/dynamic_modal_bottomsheet.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/myinkwell.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/page_navigator.dart';
import 'package:thinkcreative_technologies/widgets/PhoneField/intl_phone_field.dart';
import 'package:thinkcreative_technologies/widgets/PhoneField/phone_number.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Localization/language.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/main.dart';
import 'package:thinkcreative_technologies/Utils/utils.dart';
import 'package:thinkcreative_technologies/widgets/WarningWidgets/warning_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';

class LoginLanding extends StatefulWidget {
  LoginLanding(
      {Key? key,
      // this.title,
      required this.isaccountapprovalbyadminneeded,
      required this.accountApprovalMessage,
      required this.prefs,
      required this.basicsettings,
      required this.isblocknewlogins})
      : super(key: key);

  // final String? title;

  final bool? isblocknewlogins;
  final bool? isaccountapprovalbyadminneeded;
  final String? accountApprovalMessage;
  final SharedPreferences prefs;
  final BasicSettingModelUserApp basicsettings;
  @override
  LoginLandingState createState() => new LoginLandingState();
}

class LoginLandingState extends State<LoginLanding>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final _phoneNo = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  int currentStatus = 0;
  String? phoneCode = DEFAULT_COUNTTRYCODE_NUMBER;
  final storage = new FlutterSecureStorage();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  int attempt = 1;
  String? verificationId;
  bool isShowCompletedLoading = false;
  bool isVerifyingCode = false;
  bool isCodeSent = false;
  dynamic isLoggedIn = false;
  User? currentUser;
  String? deviceid;
  var mapDeviceInfo = {};
  late TabController _tabController;
  GlobalKey<State> _keyLoader444444 =
      new GlobalKey<State>(debugLabel: 'qqqeqeqsseaadsqeqe4444');
  GlobalKey<State> _keyLoader44444466 =
      new GlobalKey<State>(debugLabel: 'qqqeqeqsseaadsqeqe444466');
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);

    _tabController.addListener(_handleTabSelection);

    seletedlanguage = Language.languageList()
        .where((element) => element.languageCode == 'en')
        .toList()[0];
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {});
    });
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,1000}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          ShowLoading().open(context: context, key: _keyLoader444444);
          widget.prefs
              .setInt(Dbkeys.userLoginType, Usertype.customer.index)
              .then((value) {
            _phoneNo.clear();
            setState(() {});
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {});
              ShowLoading().close(context: context, key: _keyLoader444444);
            });
          }).catchError(((onError) {
            ShowLoading().close(context: context, key: _keyLoader444444);
            showERRORSheet(context, "L03",
                message: "Please restart the App to LOGIN. $OnError");
          }));

          break;
        case 1:
          ShowLoading().open(context: context, key: _keyLoader44444466);
          widget.prefs
              .setInt(Dbkeys.userLoginType, Usertype.agent.index)
              .then((value) {
            _phoneNo.clear();
            setState(() {});
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {});
              ShowLoading().close(context: context, key: _keyLoader44444466);
            });
          }).catchError((onError) {
            ShowLoading().close(context: context, key: _keyLoader44444466);
            showERRORSheet(context, "L04",
                message: "Please restart the App to LOGIN. $OnError");
          });

          break;
      }
    }
  }

  // ignore: unused_element
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocaleForUsers(language.languageCode);
    AppWrapper.setLocale(this.context, _locale);
    setState(() {
      seletedlanguage = language;
    });

    await widget.prefs.setBool('islanguageselected', true);
  }

  Language? seletedlanguage;
  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
    _phoneNo.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(this.context).size.width;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor:
          Mycolors.whiteDynamic, //or set color with: Color(0xFF0000FF)
    ));
    return Utils.getNTPWrappedWidget(new DefaultTabController(
      length: 2,
      child: new Consumer<Observer>(
        builder: (context, observer, _) => Scaffold(
          backgroundColor: Mycolors.whiteDynamic,
          appBar: new AppBar(
            backgroundColor: Mycolors.whiteDynamic,
            elevation: 0.4,
            flexibleSpace: new Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                new TabBar(
                  isScrollable: false,
                  controller: _tabController,
                  indicatorWeight: 0.8,
                  unselectedLabelColor: Mycolors.blackDynamic,
                  labelColor:
                      Mycolors.getColor(widget.prefs, Colortype.primary.index),
                  indicatorColor:
                      Mycolors.getColor(widget.prefs, Colortype.primary.index),
                  tabs: [
                    new Tab(
                        icon: MtCustomfontBold(
                      isNullColor: true,
                      text:
                          getTranslatedForCurrentUser(context, 'xxcustomerxx'),
                      fontsize: 16,
                    )),
                    new Tab(
                        icon: MtCustomfontBold(
                      isNullColor: true,
                      text: getTranslatedForCurrentUser(context, 'xxagentxx'),
                      fontsize: 16,
                    )),
                  ],
                ),
              ],
            ),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              Container(
                color: Mycolors.backgroundcolor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        color: Mycolors.whiteDynamic,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                AppLogoPath,
                                width: w / 1.6,
                              ),
                              widget.basicsettings.loginTypeUserApp ==
                                      "Email/Password"
                                  ? SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          32, 2, 32, 8),
                                      child: MtCustomfontRegular(
                                        fontsize: 16,
                                        lineheight: 1.3,
                                        textalign: TextAlign.center,
                                        text: AppTagline,
                                      ),
                                    )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                        child: sendverfWidget()),
                  ],
                ),
              ),
              Container(
                color: Mycolors.backgroundcolor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        color: Mycolors.whiteDynamic,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                AppLogoPath,
                                width: w / 1.6,
                              ),
                              widget.basicsettings.loginTypeUserApp ==
                                      "Email/Password"
                                  ? SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          32, 2, 32, 8),
                                      child: MtCustomfontRegular(
                                        fontsize: 16,
                                        lineheight: 1.3,
                                        textalign: TextAlign.center,
                                        text: AppTagline,
                                      ),
                                    )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                        child: sendverfWidget()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  bool isCustomDomainMatched(String domains, String email) {
    var splitag = domains.trim().toLowerCase().split(",");
    String emailext = email.split("@").length == 2 ? email.split("@")[1] : "";

    if (email == "" || emailext == "") {
      return false;
    } else if (splitag.contains(emailext.toLowerCase().trim())) {
      return true;
    } else {
      return false;
    }
  }

  Widget sendverfWidget() {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    SpecialLiveConfigData? livedata =
        Provider.of<SpecialLiveConfigData?>(context, listen: true);
    // bool isready = _tabController.index == 0
    //     ? livedata == null
    //         ? false
    //         : !livedata.docmap.containsKey(Dbkeys.secondadminID) ||
    //                 livedata.docmap[Dbkeys.secondadminID] == '' ||
    //                 livedata.docmap[Dbkeys.secondadminID] == null
    //             ? false
    //             : true
    //     : true;
    bool isready = _tabController.index == 0
        ? livedata == null
            ? false
            : !livedata.docmap.containsKey(Dbkeys.secondadminID)
                ? false
                : livedata.docmap[Dbkeys.secondadminID] != ''
                    ? true
                    : false
        : true;
    return Consumer<Observer>(builder: (context, observer, _) {
      return FutureBuilder(
          future: Future.delayed(Duration(seconds: 1)),
          builder: (c, s) => s.connectionState == ConnectionState.done
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: isready == false
                      ? notReadyWidget()
                      : enterMobileWidget(w, h))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: enterMobileWidget(w, h)));
    });
  }

  notReadyWidget() {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 100, 0, 65),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            warningTile(
                isstyledtext: true,
                isbold: false,
                title: getTranslatedForCurrentUser(
                        context, 'xxtheappdoesnothavexx')
                    .replaceAll('(####)',
                        getTranslatedForCurrentUser(context, 'xxsecondadminxx'))
                    .replaceAll('(###)',
                        getTranslatedForCurrentUser(context, 'xxagentsxx')),
                // 'This App does not have any <bold>Second Admin</bold> assigned.\n\nPlease Ask Admin to Assign a Second Admin from the <bold>Admin App.</bold>\n\nTill then <bold>only Agents</bold> can Login in into this app.',
                warningTypeIndex: WarningType.alert.index),
            SizedBox(
              height: 15,
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                side: BorderSide(width: 2, color: Mycolors.agentPrimary),
              ),
              onPressed: () async {
                _tabController.index = 1;
                await widget.prefs
                    .setInt(Dbkeys.userLoginType, Usertype.agent.index);
                setState(() {});
                Future.delayed(const Duration(milliseconds: 300), () {
                  setState(() {});
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    '${getTranslatedForCurrentUser(context, 'xxagentxx')} ${getTranslatedForCurrentUser(context, 'xxloginxx')}',
                    style: TextStyle(color: Mycolors.agentPrimary),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Icon(Icons.arrow_forward,
                      size: 18, color: Mycolors.agentPrimary),
                ],
              ),
            )
          ],
        ),
      )
    ];
  }

  enterMobileWidget(w, h) {
    return [
      Divider(
        height: 6,
      ),
      SizedBox(
        height: 30,
      ),
      MtCustomfontBold(
        textalign: TextAlign.center,
        fontsize: 20,
        text: getTranslatedForCurrentUser(context, 'xxsignintoxx'),
        color: Mycolors.blackDynamic,
      ),
      SizedBox(
        height: 4,
      ),
      MtCustomfontBoldSemi(
        textalign: TextAlign.center,
        text: widget.prefs.getInt(Dbkeys.userLoginType) ==
                    Usertype.agent.index &&
                _tabController.index == 1
            ? getTranslatedForCurrentUser(context, 'xxwelcomexx').replaceAll(
                    '(####)',
                    getTranslatedForCurrentUser(context, 'xxagentxx')) +
                " ${getTranslatedForCurrentUser(context, 'xxaccountxx')}"
            : getTranslatedForCurrentUser(context, 'xxwelcomexx').replaceAll(
                    '(####)',
                    getTranslatedForCurrentUser(context, 'xxcustomerxx')) +
                " ${getTranslatedForCurrentUser(context, 'xxaccountxx')}",
        color: Mycolors.grey,
        fontsize: 13.4,
      ),
      SizedBox(
        height: h / 60,
      ),
      widget.basicsettings.loginTypeUserApp == "" ||
              widget.basicsettings.loginTypeUserApp == "Phone"
          ? Container(
              margin: EdgeInsets.only(top: 0),
              height: 63,
              width: w / 1.24,
              child: Form(
                child: Column(
                  children: [
                    MobileInputWithOutline(
                      buttonhintTextColor: Mycolors.grey,
                      borderColor: Mycolors.textboxbordercolor,
                      controller: _phoneNo,
                      initialCountryCode: DEFAULT_COUNTTRYCODE_ISO,
                      onSaved: (phone) {
                        setState(() {
                          phoneCode = phone!.countryCode;
                        });
                      },
                    )
                  ],
                ),
              ),
            )
          : widget.basicsettings.loginTypeUserApp == "Email/Password"
              ? Container(
                  margin: EdgeInsets.only(top: 0),
                  height: 210,
                  width: w / 1.24,
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InpuTextBox(
                          controller: _email,
                          hinttext:
                              getTranslatedForCurrentUser(context, 'xxemailxx'),
                          title:
                              getTranslatedForCurrentUser(context, 'xxemailxx'),
                        ),
                        InpuTextBox(
                          controller: _password,
                          hinttext: getTranslatedForCurrentUser(
                              context, 'xxpasswordxx'),
                          title: getTranslatedForCurrentUser(
                              context, 'xxpasswordxx'),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        InkWell(
                          onTap: () async {
                            pageNavigator(
                                context,
                                Resetpassword(
                                  prefs: widget.prefs,
                                ));
                          },
                          child: MtCustomfontBoldSemi(
                            text: getTranslatedForCurrentUser(
                                context, 'xxforgotpasswordxx'),
                            color: Mycolors.black,
                            fontsize: 15,
                          ),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(),
      SizedBox(height: 10),
      MySimpleButtonWithIcon(
        buttoncolor: Mycolors.getColor(widget.prefs, Colortype.primary.index),
        onpressed: widget.basicsettings.loginTypeUserApp == "" ||
                widget.basicsettings.loginTypeUserApp == "Phone"
            ? _phoneNo.text.isEmpty
                ? () {
                    print(
                        "Agent login enabled- ${widget.basicsettings.agentRegistartionEnabled}");
                    Utils.toast(
                      getTranslatedForCurrentUser(
                          this.context, 'xxentervalidmobxx'),
                    );
                  }
                : () {
                    hidekeyboard(context);
                    widget.prefs.getInt(Dbkeys.userLoginType) ==
                                Usertype.agent.index &&
                            _tabController.index == 1
                        ? pageNavigator(
                            context,
                            VerifyPhoneForAgents(
                              basicsettings: widget.basicsettings,
                              issecutitysetupdone: true,
                              onlyPhone: _phoneNo.text.trim().toString(),
                              onlyCode: phoneCode!,
                              prefs: widget.prefs,
                              onError: (title, desc, error) {
                                ShowCustomAlertDialog().open(
                                    context: this.context,
                                    dialogtype: 'error',
                                    title: title,
                                    errorlog: '${error.toString()}',
                                    description: desc,
                                    isshowerrorlog:
                                        error.toString() == '' ? false : true);
                              },
                            ))
                        : pageNavigator(
                            context,
                            VerifyPhoneForCustomers(
                              basicsettings: widget.basicsettings,
                              issecutitysetupdone: true,
                              onlyPhone: _phoneNo.text.trim().toString(),
                              onlyCode: phoneCode!,
                              prefs: widget.prefs,
                              onError: (title, desc, error) {
                                ShowCustomAlertDialog().open(
                                    context: this.context,
                                    dialogtype: 'error',
                                    title: title,
                                    errorlog: '${error.toString()}',
                                    description: desc,
                                    isshowerrorlog:
                                        error.toString() == '' ? false : true);
                              },
                            ));
                  }
            : widget.basicsettings.loginTypeUserApp == "Email/Password"
                ? () {
                    if (!_email.text.trim().contains('@') ||
                        !_email.text.trim().contains('.') ||
                        _email.text.trim().endsWith('.') ||
                        _email.text.trim().startsWith('@')) {
                      Utils.toast(getTranslatedForCurrentUser(
                          context, 'xxvalidemailxx'));
                    } else if (_password.text.trim().length < 6) {
                      Utils.toast(getTranslatedForCurrentUser(
                          context, 'xxpwdcharactersxx'));
                    } else if (_password.text.trim().length > 20) {
                      Utils.toast(getTranslatedForCurrentUser(
                          context, 'xxpwdcharactersxx'));
                    } else if (Utils.isValidPassword(_password.text.trim()) ==
                        false) {
                      Utils.toast(getTranslatedForCurrentUser(
                          context, 'xxpwdcharactersxx'));
                    } else if ((widget.basicsettings.isCustomDomainsOnly ==
                                true &&
                            widget.basicsettings.customDomainslist != "") &&
                        isCustomDomainMatched(
                                widget.basicsettings.customDomainslist ?? "",
                                _email.text.trim()) ==
                            false) {
                      Utils.toast(getTranslatedForCurrentUser(
                              context, 'xxxnotmatchedcustomdomainxxx')
                          .replaceAll('(####)',
                              "[ ${widget.basicsettings.customDomainslist.toString().toLowerCase()} ]"));
                    } else {
                      if (widget.prefs.getInt(Dbkeys.userLoginType) ==
                              Usertype.agent.index &&
                          _tabController.index == 1) {
                        String myEmail = _email.text.trim().toLowerCase();
                        String myPassWord = _password.text.trim();
                        hidekeyboard(context);
                        _email.clear();
                        _password.clear();
                        pageNavigator(
                            context,
                            VerifyEmailForAgents(
                              basicSettings: widget.basicsettings,
                              password: myPassWord,
                              email: myEmail,
                              prefs: widget.prefs,
                              onError: (title, desc, error) {
                                ShowCustomAlertDialog().open(
                                    context: this.context,
                                    dialogtype: 'error',
                                    title: title,
                                    errorlog: '${error.toString()}',
                                    description: desc,
                                    isshowerrorlog:
                                        error.toString() == '' ? false : true);
                              },
                            ));
                      } else {
                        String myEmail = _email.text.trim().toLowerCase();
                        String myPassWord = _password.text.trim();
                        hidekeyboard(context);
                        _email.clear();
                        _password.clear();
                        pageNavigator(
                            context,
                            VerifyEmailForCustomers(
                              onError: (title, desc, error) {
                                ShowCustomAlertDialog().open(
                                    context: this.context,
                                    dialogtype: 'error',
                                    title: title,
                                    errorlog: '${error.toString()}',
                                    description: desc,
                                    isshowerrorlog:
                                        error.toString() == '' ? false : true);
                              },
                              basicSettings: widget.basicsettings,
                              password: myPassWord,
                              email: myEmail,
                              prefs: widget.prefs,
                            ));
                      }
                    }
                  }
                : () {
                    Utils.toast("Please restart the app.");
                  },
        buttontext: widget.prefs.getInt(Dbkeys.userLoginType) ==
                    Usertype.agent.index &&
                _tabController.index == 1
            ? "${getTranslatedForCurrentUser(context, 'xxagentxx')} ${getTranslatedForCurrentUser(context, 'xxloginxx')}"
            : "${getTranslatedForCurrentUser(context, 'xxcustomerxx')} ${getTranslatedForCurrentUser(context, 'xxloginxx')}",
      ),
      SizedBox(
        height: h / 40,
      ),
      Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        width: w * 0.95,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                  text:
                      '${getTranslatedForCurrentUser(this.context, 'xxagreexx')} \n',
                  style: TextStyle(
                      color: Mycolors.grey,
                      fontFamily: MyRegisteredFonts.regular,
                      fontWeight: FontWeight.w400,
                      fontSize: 14.0,
                      height: 1.7)),
              TextSpan(
                  text: getTranslatedForCurrentUser(this.context, 'xxtncxx'),
                  style: TextStyle(
                      height: 1.7,
                      fontFamily: MyRegisteredFonts.bold,
                      color: Mycolors.getColor(
                          widget.prefs, Colortype.primary.index),
                      fontWeight: FontWeight.w700,
                      fontSize: 14.8),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (widget.basicsettings.tncTYPE == 'url') {
                        if (widget.basicsettings.tnc == null) {
                          Utils.toast("TNC URL is not valid");
                        } else {
                          custom_url_launcher(widget.basicsettings.tnc!);
                        }
                      } else if (widget.basicsettings.tncTYPE == 'file') {
                        Navigator.push(
                            this.context,
                            MaterialPageRoute(
                              builder: (context) => PDFViewerCachedFromUrl(
                                currentUserID: null,
                                prefs: widget.prefs,
                                title: getTranslatedForCurrentUser(
                                    this.context, 'xxtncxx'),
                                url: widget.basicsettings.tnc,
                                isregistered: false,
                              ),
                            ));
                      }
                    }),
              TextSpan(
                  text: '  ○  ',
                  style: TextStyle(
                      height: 1.7,
                      color: Mycolors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 11.8)),
              TextSpan(
                  text: getTranslatedForCurrentUser(this.context, 'xxppxx'),
                  style: TextStyle(
                      height: 1.7,
                      fontFamily: MyRegisteredFonts.bold,
                      color: Mycolors.getColor(
                          widget.prefs, Colortype.primary.index),
                      fontWeight: FontWeight.w700,
                      fontSize: 14.8),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (widget.basicsettings.privacypolicyTYPE == 'url') {
                        if (widget.basicsettings.privacypolicy == null) {
                          Utils.toast("Privacy Policy URL is not valid");
                        } else {
                          custom_url_launcher(
                              widget.basicsettings.privacypolicy!);
                        }
                      } else if (widget.basicsettings.privacypolicyTYPE ==
                          'file') {
                        Navigator.push(
                            this.context,
                            MaterialPageRoute(
                              builder: (context) => PDFViewerCachedFromUrl(
                                currentUserID: null,
                                prefs: widget.prefs,
                                title: getTranslatedForCurrentUser(
                                    this.context, 'xxppxx'),
                                url: widget.basicsettings.privacypolicy,
                                isregistered: false,
                              ),
                            ));
                      }
                    }),
            ],
          ),
        ),
      ),
      SizedBox(
        height: h / 30,
      ),
      myinkwell(
        onTap: Language.languageList().length < 2
            ? () {}
            : () {
                showDynamicModalBottomSheet(
                    context: context,
                    widgetList: Language.languageList()
                        .map(
                          (e) => myinkwell(
                            onTap: () {
                              Navigator.of(context).pop();
                              _changeLanguage(e);
                            },
                            child: Container(
                              margin: EdgeInsets.all(14),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    IsShowLanguageNameInNativeLanguage == true
                                        ? e.flag + ' ' + '    ' + e.name
                                        : e.flag +
                                            ' ' +
                                            '    ' +
                                            e.languageNameInEnglish,
                                    style: TextStyle(
                                        color: Mycolors.black,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  Language.languageList().length < 2
                                      ? SizedBox()
                                      : Icon(
                                          Icons.done,
                                          color: e.languageCode ==
                                                  widget.prefs
                                                      .getString(LAGUAGE_CODE)
                                              ? Mycolors.green
                                              : Colors.transparent,
                                        )
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    title: "");
              },
        child: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MtCustomfontBoldSemi(
                color: Mycolors.black,
                textalign: TextAlign.center,
                text: IsShowLanguageNameInNativeLanguage == true
                    ? widget.prefs.getString(LAGUAGE_CODE) == null
                        ? Language.languageList()[Language.languageList().indexWhere((element) => element.languageCode == DefaulLANGUAGEfileCodeForCURRENTuser)]
                                .flag
                                .toString() +
                            '  ' +
                            Language.languageList()[Language.languageList().indexWhere((element) => element.languageCode == DefaulLANGUAGEfileCodeForCURRENTuser)]
                                .name
                                .toString()
                        : Language.languageList()[Language.languageList().indexWhere((element) => element.languageCode == widget.prefs.getString(LAGUAGE_CODE))]
                                .flag
                                .toString() +
                            '  ' +
                            Language.languageList()[Language.languageList().indexWhere((element) => element.languageCode == widget.prefs.getString(LAGUAGE_CODE))]
                                .name
                                .toString()
                    : widget.prefs.getString(LAGUAGE_CODE) == null
                        ? Language.languageList()[Language.languageList().indexWhere((element) => element.languageCode == DefaulLANGUAGEfileCodeForCURRENTuser)]
                                .flag
                                .toString() +
                            '  ' +
                            Language.languageList()[Language.languageList().indexWhere((element) => element.languageCode == DefaulLANGUAGEfileCodeForCURRENTuser)]
                                .languageNameInEnglish
                                .toString()
                        : Language.languageList()[Language.languageList().indexWhere((element) => element.languageCode == widget.prefs.getString(LAGUAGE_CODE))]
                                .flag
                                .toString() +
                            '  ' +
                            Language.languageList()[Language.languageList()
                                    .indexWhere((element) =>
                                        element.languageCode ==
                                        widget.prefs.getString(LAGUAGE_CODE))]
                                .languageNameInEnglish
                                .toString(),
                fontsize: 14,
              ),
              SizedBox(
                width: 2,
              ),
              Language.languageList().length < 2
                  ? SizedBox()
                  : SizedBox(
                      width: 15,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Mycolors.getColor(
                            widget.prefs, Colortype.primary.index),
                        size: 27,
                      ),
                    )
            ],
          ),
        ),
      ),
      SizedBox(
        height: h / 20,
      ),
    ];
  }
}

class MobileInputWithOutline extends StatefulWidget {
  final String? initialCountryCode;
  final String? hintText;
  final double? height;
  final double? width;
  final TextEditingController? controller;
  final Color? borderColor;
  final Color? buttonTextColor;
  final Color? buttonhintTextColor;
  final TextStyle? hintStyle;
  final String? buttonText;
  final Function(PhoneNumber? phone)? onSaved;

  MobileInputWithOutline(
      {this.height,
      this.width,
      this.borderColor,
      this.buttonhintTextColor,
      this.hintStyle,
      this.buttonTextColor,
      this.onSaved,
      this.hintText,
      this.controller,
      this.initialCountryCode,
      this.buttonText});
  @override
  _MobileInputWithOutlineState createState() => _MobileInputWithOutlineState();
}

class _MobileInputWithOutlineState extends State<MobileInputWithOutline> {
  BoxDecoration boxDecoration(
      {double radius = 5,
      Color bgColor = Colors.white,
      var showShadow = false}) {
    return BoxDecoration(
        color: bgColor,
        boxShadow: showShadow
            ? [
                BoxShadow(
                    color: Mycolors.primary, blurRadius: 10, spreadRadius: 2)
              ]
            : [BoxShadow(color: Colors.transparent)],
        border:
            Border.all(color: widget.borderColor ?? Mycolors.grey, width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(radius)));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsetsDirectional.only(bottom: 7, top: 5),
          height: widget.height ?? 50,
          width: widget.width ?? MediaQuery.of(this.context).size.width,
          decoration: boxDecoration(bgColor: Mycolors.textboxbgcolor),
          child: IntlPhoneField(
              dropDownArrowColor:
                  widget.buttonhintTextColor ?? Mycolors.greylight,
              textAlign: TextAlign.left,
              initialCountryCode: widget.initialCountryCode,
              controller: widget.controller,
              style: TextStyle(
                  height: 1.35,
                  letterSpacing: 1,
                  fontSize: 16.0,
                  color: widget.buttonTextColor ?? Colors.black87,
                  fontWeight: FontWeight.bold),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(3, 15, 8, 0),
                  hintText: widget.hintText ??
                      getTranslatedForCurrentUser(
                          this.context, 'xxenter_mobilenumberxx'),
                  hintStyle: widget.hintStyle ??
                      TextStyle(
                          letterSpacing: 1,
                          height: 0.0,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w400,
                          color: Mycolors.greylight),
                  fillColor: Mycolors.textboxbgcolor,
                  filled: true,
                  border: new OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    borderSide: BorderSide.none,
                  )),
              onChanged: (phone) {
                widget.onSaved!(phone);
              },
              validator: (v) {
                return null;
              },
              onSaved: widget.onSaved),
        ),
        // Positioned(
        //     left: 110,
        //     child: Container(
        //       width: 1.5,
        //       height: widget.height ?? 48,
        //       color: widget.borderColor ??Mycolors.grey,
        //     ))
      ],
    );
  }
}
