//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Definition attached with source code. *********************

class BatchWriteComponent {
  var ref;
  var map;

  BatchWriteComponent({
    required this.ref,
    required this.map,
  });

  Map<String, dynamic> toMap() {
    return {'ref': this.ref, 'map': this.map};
  }
}
