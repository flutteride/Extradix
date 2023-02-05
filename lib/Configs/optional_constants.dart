//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

int maxChatMessageDocsLoadAtOnce = 20; //Minimum Value should be 15.
int maxAdFailedLoadAttempts = 3; //Minimum Value should be 3.
const IsShowNativeTimDate =
    true; // Show Date Time in the user selected langauge, works only if your app has multi-language enabled
const int timeOutSeconds = 50; // Default phone Auth Code auto retrival timeout

const int ImageQualityCompress =
    50; // This is compress the chat image size in percent while uploading to firesbase storage
const int DpImageQualityCompress =
    34; // This is compress the user display picture  size in percent while uploading to firesbase storage

const bool IsVideoQualityCompress =
    true; // This is compress the video size  to medium qulaity while uploading to firesbase storage

const IsShowLanguageNameInNativeLanguage =
    false; // works only if your app has multi-language enabled

//*--Admob Configurations- (By default Test Ad Units pasted)- IT IS UNDER DEVELOPMEWNT---------
const IsBannerAdShow =
    false; // Set this to 'true' if you want to show Banner ads throughout the app
const Admob_BannerAdUnitID_Android =
    'ca-app-pub-3940256099942544/6300978111'; // Test Id: 'ca-app-pub-3940256099942544/6300978111'
const Admob_BannerAdUnitID_Ios =
    'ca-app-pub-3940256099942544/2934735716'; // Test Id: 'ca-app-pub-3940256099942544/2934735716'
const IsInterstitialAdShow =
    false; // Set this to 'true' if you want to show Interstitial ads throughout the app
const Admob_InterstitialAdUnitID_Android =
    'ca-app-pub-3940256099942544/1033173712'; // Test Id:  'ca-app-pub-3940256099942544/1033173712'
const Admob_InterstitialAdUnitID_Ios =
    'ca-app-pub-3940256099942544/4411468910'; // Test Id: 'ca-app-pub-3940256099942544/4411468910'
const IsVideoAdShow =
    false; // Set this to 'true' if you want to show Video ads throughout the app
const Admob_RewardedAdUnitID_Android =
    'ca-app-pub-3940256099942544/5224354917'; // Test Id: 'ca-app-pub-3940256099942544/5224354917'
const Admob_RewardedAdUnitID_Ios =
    'ca-app-pub-3940256099942544/1712485313'; // Test Id: 'ca-app-pub-3940256099942544/1712485313'
//Also don't forget to Change the Admob App Id in "fiberchat/android/app/src/main/AndroidManifest.xml" & "fiberchat/ios/Runner/Info.plist"
const Defaultprofilepicfromnetworklink =
    'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png';
