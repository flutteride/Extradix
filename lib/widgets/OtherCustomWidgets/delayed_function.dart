//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

delayedFunction({Function? setstatefn, int? durationmilliseconds}) {
  Future.delayed(Duration(milliseconds: durationmilliseconds ?? 2000), () {
    setstatefn!();
  });
}
