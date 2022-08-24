import 'package:gogo_pharma/models/product_listing_model.dart';

class ReusableFunctions {
  static bool checkDiscount(MaximumPrice? maximumPrice) {
    bool res = true;
    if ((maximumPrice?.discount?.percentOff ?? 0) == 0) {
      res = false;
    }
    return res;
  }
}
