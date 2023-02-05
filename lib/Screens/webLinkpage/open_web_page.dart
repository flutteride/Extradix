import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';
import 'package:thinkcreative_technologies/Screens/AgentScreens/calls/pickup_layout.dart';
import 'package:thinkcreative_technologies/Screens/webLinkpage/open_web_page_additional.dart';
import 'package:thinkcreative_technologies/Utils/custom_url_launcher.dart';
import 'package:thinkcreative_technologies/widgets/OtherCustomWidgets/page_navigator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class OpenWebPage extends StatefulWidget {
  String currentUserID;
  SharedPreferences prefs;
  String url = '';
  bool hideHeader = false;
  bool hideFooter = false;
  bool flag = true;
  OpenWebPage(
      {required this.url,
      required this.currentUserID,
      required this.prefs,
      required this.flag,
      required this.hideHeader,
      required this.hideFooter});

  @override
  _OpenWebPageState createState() => _OpenWebPageState();
}

class _OpenWebPageState extends State<OpenWebPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? _webViewController;
  late PullToRefreshController _pullToRefreshController;
  CookieManager cookieManager = CookieManager.instance();
  double checkingloadingprogress = 999;
  double progress = 0;
  int _previousScrollY = 0;
  bool isLoading = false;
  bool showErrorPage = false;
  bool slowInternetPage = false;
  bool noInternet = false;
  late AnimationController animationController;
  late Animation<double> animation;
  final expiresDate =
      DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch;
  // String _connectionStatus = 'ConnectivityResult.none';
  // final Connectivity _connectivity = Connectivity();
  // late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  var browserOptions;

  @override
  void initState() {
    super.initState();

    // InternetConnectionCheck.initConnectivity().then((value) => setState(() {
    //       _connectionStatus = value;
    //     }));
    // _connectivitySubscription =
    //     _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
    //   InternetConnectionCheck.updateConnectionStatus(result)
    //       .then((value) => setState(() {
    //             _connectionStatus = value;
    //             if (_connectionStatus != 'ConnectivityResult.none') {
    //               if (_webViewController != null) {
    //                 Future.delayed(Duration.zero).then((value) =>
    //                     _webViewController!.loadUrl(
    //                         urlRequest:
    //                             URLRequest(url: Uri.parse(widget.url))));
    //               }
    //               noInternet = false;
    //             } else {
    //               noInternet = true;
    //             }
    //           }));
    // });
    try {
      _pullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(
          color: Mycolors.loadingindicator,
        ),
        onRefresh: () async {
          if (Platform.isAndroid) {
            _webViewController!.reload();
          } else if (Platform.isIOS) {
            _webViewController!.loadUrl(
                urlRequest:
                    URLRequest(url: await _webViewController!.getUrl()));
          }
        },
      );
    } on Exception catch (e) {
      print(e);
    }

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat();
    animation = Tween(begin: 0.0, end: 1.0).animate(animationController)
      ..addListener(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    // _connectivitySubscription.cancel();
    animationController.dispose();
    super.dispose();
  }

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
          useOnDownloadStart: true,
          javaScriptEnabled: true,
          cacheEnabled: true,
          userAgent:
              "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36",
          verticalScrollBarEnabled: false,
          horizontalScrollBarEnabled: false,
          transparentBackground: true),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
        thirdPartyCookiesEnabled: true,
        allowFileAccess: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  // GlobalKey<State> _keyLoader735 =
  //     new GlobalKey<State>(debugLabel: 'qqqeqeqsseaafdafdsqeqe');
  List<String> baseUrllist = [];
  @override
  Widget build(BuildContext context) {
    bool _validURL = Uri.parse(widget.url).host == '' ? false : true;

    return WillPopScope(
        onWillPop: () => _exitApp(context),
        child: PickupLayout(
            prefs: widget.prefs,
            curentUserID: widget.currentUserID,
            scaffold: SafeArea(
                child: widget.flag == false
                    ? Scaffold(
                        backgroundColor: Mycolors.backgroundcolor,
                        body: Container(
                          color: Colors.transparent,
                          child: InAppWebView(
                            key: webViewKey,
                            initialData: InAppWebViewInitialData(
                                data: widget.url,
                                mimeType: 'text/html',
                                encoding: "utf8"),
                            initialOptions: InAppWebViewGroupOptions(
                                crossPlatform: InAppWebViewOptions(
                                    useShouldOverrideUrlLoading: true,
                                    mediaPlaybackRequiresUserGesture: true,
                                    useOnDownloadStart: true,
                                    cacheEnabled: true,
                                    userAgent:
                                        "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36",
                                    javaScriptEnabled: true,
                                    transparentBackground: true),
                                android: AndroidInAppWebViewOptions(
                                    useHybridComposition: true,
                                    defaultFontSize: 22),
                                ios: IOSInAppWebViewOptions(
                                  allowsInlineMediaPlayback: true,
                                )),
                            pullToRefreshController: _pullToRefreshController,
                            gestureRecognizers: <
                                Factory<OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            },
                            onWebViewCreated: (controller) {
                              _webViewController = controller;
                            },
                            onScrollChanged: (controller, x, y) async {
                              int currentScrollY = y;

                              if (currentScrollY > _previousScrollY) {
                                _previousScrollY = currentScrollY;
                                // if (!context
                                //     .read<NavigationBarProvider>()
                                //     .animationController
                                //     .isAnimating) {
                                //   context
                                //       .read<NavigationBarProvider>()
                                //       .animationController
                                //       .forward();
                                // }
                              } else {
                                _previousScrollY = currentScrollY;

                                // if (!context
                                //     .read<NavigationBarProvider>()
                                //     .animationController
                                //     .isAnimating) {
                                //   context
                                //       .read<NavigationBarProvider>()
                                //       .animationController
                                //       .reverse();
                                // }
                              }
                            },
                            onLoadStart: (controller, url) {},
                            onLoadStop: (controller, url) async {
                              _pullToRefreshController.endRefreshing();
                              //  _webViewController!
                              //      _webViewController!.injectCSSFileFromUrl(urlFile: urlFile)
                            },
                            onLoadError: (controller, url, code, message) {
                              _pullToRefreshController.endRefreshing();

                              setState(() {
                                slowInternetPage = true;
                              });
                            },
                            onLoadHttpError:
                                (controller, url, statusCode, description) {
                              setState(() {
                                showErrorPage = true;
                              });
                            },
                            onProgressChanged: (controller, progress) {
                              if (progress == 100) {
                                _pullToRefreshController.endRefreshing();
                              }
                              setState(() {
                                this.progress = progress / 100;
                                // urlController.text = this.url;
                              });
                            },
                            shouldOverrideUrlLoading:
                                (controller, navigationAction) async {
                              return NavigationActionPolicy.ALLOW;
                            },
                          ),
                        ))
                    : Scaffold(
                        backgroundColor: Mycolors.backgroundcolor,
                        body: Stack(
                          children: [
                            _validURL
                                ? InAppWebView(
                                    key: webViewKey,
                                    // initialFile: 'assets/icons/test.html',

                                    initialUrlRequest:
                                        URLRequest(url: Uri.parse(widget.url)),
                                    initialOptions: options,
                                    pullToRefreshController:
                                        _pullToRefreshController,
                                    gestureRecognizers: <
                                        Factory<OneSequenceGestureRecognizer>>{
                                      Factory<OneSequenceGestureRecognizer>(
                                        () => EagerGestureRecognizer(),
                                      ),
                                    },
                                    onWebViewCreated: (controller) async {
                                      _webViewController = controller;

                                      await cookieManager.setCookie(
                                        url: Uri.parse(widget.url),
                                        name: "myCookie",
                                        value: "myValue",
                                        // domain: ".flutter.dev",
                                        expiresDate: expiresDate,
                                        isHttpOnly: false,
                                        isSecure: true,
                                      );
                                    },
                                    onScrollChanged: (controller, x, y) async {
                                      // int currentScrollY = y;
                                      // if (currentScrollY > _previousScrollY) {
                                      //   _previousScrollY = currentScrollY;
                                      //   if (!context
                                      //       .read<NavigationBarProvider>()
                                      //       .animationController
                                      //       .isAnimating) {
                                      //     context
                                      //         .read<NavigationBarProvider>()
                                      //         .animationController
                                      //         .forward();
                                      //   }
                                      // } else {
                                      //   _previousScrollY = currentScrollY;

                                      //   if (!context
                                      //       .read<NavigationBarProvider>()
                                      //       .animationController
                                      //       .isAnimating) {
                                      //     context
                                      //         .read<NavigationBarProvider>()
                                      //         .animationController
                                      //         .reverse();
                                      //   }
                                      // }
                                    },

                                    onLoadStart: (controller, url) async {
                                      if (baseUrllist.length == 0 ||
                                          baseUrllist.contains(
                                              url.toString().trim()) ||
                                          widget.url.trim() ==
                                              url.toString().trim()) {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        if (Platform.isAndroid) {
                                          List<Cookie> cookies =
                                              await cookieManager.getCookies(
                                                  url: url!);
                                          print(
                                              '---android cookies---$cookies');
                                        }
                                        if (Platform.isIOS) {
                                          List<Cookie> iosCookies =
                                              await cookieManager.ios
                                                  .getAllCookies();
                                          print('---ios cookies---$iosCookies');
                                        }
                                      } else {
                                        print(
                                            '----loadstart 1 ${widget.url}---- ${widget.url.trim().length}');
                                        print(
                                            '----loadstart 2 ${url.toString()}---- ${url.toString().length}');

                                        // if (1 == 2) {
                                        _webViewController!.stopLoading();

                                        pageNavigator(
                                            context,
                                            OpenWebPageAdditional(
                                                onBackPress: () async {
                                                  setState(() {
                                                    baseUrllist.clear();
                                                  });
                                                  showErrorPage = false;
                                                  noInternet = false;
                                                  slowInternetPage = false;
                                                  _webViewController!.loadUrl(
                                                      urlRequest: URLRequest(
                                                          url: Uri.parse(
                                                              widget.url)));
                                                },
                                                currentUserID:
                                                    widget.currentUserID,
                                                prefs: widget.prefs,
                                                url: url.toString(),
                                                flag: true,
                                                hideHeader: widget.hideHeader,
                                                hideFooter: widget.hideFooter));

                                        // } else {}
                                      }
                                    },

                                    onLoadStop: (controller, url) async {
                                      _pullToRefreshController.endRefreshing();
                                      if (baseUrllist.length < 2) {
                                        baseUrllist.add(url.toString());
                                      }
                                      setState(() {
                                        isLoading = false;
                                      });

                                      // Removes header and footer from page
                                      if (widget.hideHeader == true) {
                                        _webViewController!
                                            .evaluateJavascript(
                                                source: "javascript:(function() { " +
                                                    "var head = document.getElementsByTagName('header')[0];" +
                                                    "head.parentNode.removeChild(head);" +
                                                    "})()")
                                            .then((value) => debugPrint(
                                                'Page finished loading Javascript'))
                                            .catchError((onError) =>
                                                debugPrint('$onError'));
                                      }
                                      if (widget.hideFooter == true) {
                                        _webViewController!
                                            .evaluateJavascript(
                                                source: "javascript:(function() { " +
                                                    "var footer = document.getElementsByTagName('footer')[0];" +
                                                    "footer.parentNode.removeChild(footer);" +
                                                    "})()")
                                            .then((value) => debugPrint(
                                                'Page finished loading Javascript'))
                                            .catchError((onError) =>
                                                debugPrint('$onError'));
                                      }
                                    },
                                    onLoadError:
                                        (controller, url, code, message) async {
                                      _pullToRefreshController.endRefreshing();
                                      print('---load error----$url');
                                      print('---load error----$code');

                                      setState(() {
                                        if (code != 102) {
                                          slowInternetPage = true;
                                        }
                                        isLoading = false;
                                      });
                                    },

                                    onLoadHttpError: (controller, url,
                                        statusCode, description) {
                                      _pullToRefreshController.endRefreshing();
                                      print(
                                          '---load http error----$description');

                                      setState(() {
                                        showErrorPage = true;
                                        isLoading = false;
                                      });
                                    },
                                    androidOnGeolocationPermissionsShowPrompt:
                                        (controller, origin) async {
                                      await Permission.location.request();
                                      return null;
                                    },
                                    androidOnPermissionRequest:
                                        (controller, origin, resources) async {
                                      if (resources.contains(
                                          'android.webkit.resource.AUDIO_CAPTURE')) {
                                        await Permission.microphone.request();
                                      }
                                      if (resources.contains(
                                          'android.webkit.resource.VIDEO_CAPTURE')) {
                                        await Permission.camera.request();
                                      }

                                      return PermissionRequestResponse(
                                          resources: resources,
                                          action:
                                              PermissionRequestResponseAction
                                                  .GRANT);
                                    },

                                    onProgressChanged: (controller, progress) {
                                      if (progress == 100) {
                                        _pullToRefreshController
                                            .endRefreshing();
                                      }
                                      setState(() {
                                        this.progress = progress / 100;
                                      });
                                    },
                                    shouldOverrideUrlLoading:
                                        (controller, navigationAction) async {
                                      var url = navigationAction.request.url
                                          .toString();
                                      var uri = Uri.parse(url);

                                      if (Platform.isIOS &&
                                          url.contains("geo")) {
                                        var newUrl = url.replaceFirst(
                                            'geo://', 'http://maps.apple.com/');

                                        if (await canLaunchUrl(
                                            Uri.parse(newUrl))) {
                                          custom_url_launcher(newUrl);
                                          return NavigationActionPolicy.CANCEL;
                                        } else {
                                          throw 'Could not launch $newUrl';
                                        }
                                      } else if (url.contains("tel:") ||
                                          url.contains("mailto:") ||
                                          url.contains("play.google.com") ||
                                          url.contains("maps") ||
                                          url.contains("messenger.com")) {
                                        url = Uri.encodeFull(url);
                                        try {
                                          if (await canLaunchUrl(uri)) {
                                            launchUrl(uri,
                                                mode: LaunchMode
                                                    .externalApplication);
                                          } else {
                                            launchUrl(uri,
                                                mode: LaunchMode
                                                    .externalApplication);
                                          }
                                          return NavigationActionPolicy.CANCEL;
                                        } catch (e) {
                                          launchUrl(uri);
                                          return NavigationActionPolicy.CANCEL;
                                        }
                                      } else if (![
                                        "http",
                                        "https",
                                        "file",
                                        "chrome",
                                        "data",
                                        "javascript",
                                        "about"
                                      ].contains(uri.scheme)) {
                                        if (await canLaunchUrl(uri)) {
                                          // Launch the App
                                          await launchUrl(uri,
                                              mode: LaunchMode
                                                  .externalApplication);
                                          // and cancel the request
                                          return NavigationActionPolicy.CANCEL;
                                        }
                                      }

                                      return NavigationActionPolicy.ALLOW;
                                    },

                                    onDownloadStartRequest: (controller,
                                        downloadStartRrquest) async {
                                      if (1 == 1) {
                                        //This process is recommended for all file type download.
                                        String downloadUrl =
                                            downloadStartRrquest.url.toString();
                                        custom_url_launcher(downloadUrl);
                                      } else {
                                        // String downloadUrl =
                                        //     downloadStartRrquest.url.toString();
                                        // Utils.toast("URLlll $downloadUrl");
                                        // await MobileDownloadService().download(
                                        //     url: downloadUrl,
                                        //     fileName:
                                        //         "${DateTime.now().millisecondsSinceEpoch}.zip",
                                        //     context: context,
                                        //     keyloader: _keyLoader735,
                                        //     isOpenAfterDownload: true);

                                        requestPermission()
                                            .then((status) async {
                                          String url = downloadStartRrquest.url
                                              .toString();
                                          if (status == true) {
                                            try {
                                              Dio dio = Dio();
                                              // File file = File(url.toString());
                                              String fileName = url
                                                  .toString()
                                                  .substring(
                                                      url
                                                              .toString()
                                                              .lastIndexOf(
                                                                  '/') +
                                                          1,
                                                      url
                                                          .toString()
                                                          .lastIndexOf('?'));

                                              String savePath =
                                                  await getFilePath(fileName);
                                              print(savePath);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: const Text(
                                                    'Downloading file..'),
                                              ));
                                              await dio.download(
                                                  url.toString(), savePath,
                                                  onReceiveProgress:
                                                      (rec, total) {
                                                // _bottomSheetController.setState!(() {
                                                //   downloading = true;
                                                //   progress = (rec / total);
                                                //   downloadingStr = downloadingStartString;
                                                // });
                                              });

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: const Text(
                                                    'Download Complete'),
                                              ));
                                            } on Exception catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Downloading failed $e'),
                                              ));
                                            }
                                            // if (await canLaunchUrl(url)) {
                                            //   // Launch the App
                                            //   await launchUrl(url,
                                            //       mode: LaunchMode.platformDefault);

                                            //   // and cancel the request
                                            // }
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content: const Text(
                                                  'Permision denied'),
                                            ));
                                          }
                                        });
                                      }
                                    },
                                    onUpdateVisitedHistory: (controller, url,
                                        androidIsReload) async {
                                      print(
                                          '--from onUpdateVisitedHistory--$url');

                                      // if (vistedUrl.length == 0
                                      //     ? 1 == 1
                                      //     : vistedUrl.last.trim() ==
                                      //         url.toString().trim()) {
                                      // } else {
                                      //   // if (1 == 2) {
                                      //   // _webViewController!.stopLoading();

                                      //   pageNavigator(
                                      //       context,
                                      //       OpenWebPageAdditional(
                                      //           onBackPress: () async {
                                      //             vistedUrl.remove(
                                      //                 url.toString().trim());
                                      //             _webViewController!.loadUrl(
                                      //                 urlRequest: URLRequest(
                                      //                     url: Uri.parse(
                                      //                         widget.url)));
                                      //           },
                                      //           currentUserID:
                                      //               widget.currentUserID,
                                      //           prefs: widget.prefs,
                                      //           url: url.toString(),
                                      //           flag: true,
                                      //           hideHeader: widget.hideHeader,
                                      //           hideFooter: widget.hideFooter));

                                      //   // } else {}
                                      // }
                                    },
                                    onCloseWindow: (controller) async {
                                      //   _webViewController!.evaluateJavascript(source:'document.cookie = "token=$token"');
                                    },
                                    onConsoleMessage: (controller, message) {
                                      print('---console---$message');
                                    },
                                  )
                                : Center(
                                    child: Text('Url is not valid',
                                        style: TextStyle(color: Colors.black))),
                            isLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Mycolors.loadingindicator)),
                                  )
                                : SizedBox(height: 0, width: 0),
                            noInternet
                                ? Center(
                                    child: Text('No internet',
                                        style: TextStyle(color: Colors.black)))
                                : SizedBox(height: 0, width: 0),
                            showErrorPage
                                ? Center(
                                    child: Text('Web page not found',
                                        style: TextStyle(color: Colors.black)))
                                : SizedBox(height: 0, width: 0),
                            slowInternetPage
                                ? Center(
                                    child: Text('Web page not found',
                                        style: TextStyle(color: Colors.black)))
                                : SizedBox(height: 0, width: 0),
                            progress < 1.0
                                ? SizeTransition(
                                    sizeFactor: animation,
                                    axis: Axis.horizontal,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 5.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: Mycolors.webviewLoaderColor,
                                          stops: const [0.1, 1.0, 0.1],
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    height: 0,
                                  ),
                          ],
                        ),
                      ))));
  }

  Future<bool> _exitApp(BuildContext context) async {
    // if (mounted) {
    //   if (!context
    //       .read<NavigationBarProvider>()
    //       .animationController
    //       .isAnimating) {
    //     context.read<NavigationBarProvider>().animationController.reverse();
    //   }
    // }
    if (await _webViewController!.canGoBack()) {
      _webViewController!.goBack();
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  Future<bool> requestPermission() async {
    final status = await Permission.storage.status;

    if (status == PermissionStatus.granted) {
      return true;
    } else if (status != PermissionStatus.granted) {
      //
      final result = await Permission.storage.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        // await openAppSettings();
        return false;
      }
    }
    return true;
  }

  Future<String> getFilePath(uniqueFileName) async {
    String path = '';
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = '/storage/emulated/0/Download';
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    print(path);
    path = '$externalStorageDirPath/$uniqueFileName';
    return path;
  }
}
