import 'package:flutter/material.dart';
import 'package:gogo_pharma/common/constants.dart';
import 'package:gogo_pharma/common/extensions.dart';
import 'package:gogo_pharma/common/route_generator.dart';
import 'package:gogo_pharma/models/cart_model.dart';
import 'package:gogo_pharma/models/wish_list_models/wishlist_model.dart';
import 'package:gogo_pharma/providers/auth_provider.dart';
import 'package:gogo_pharma/providers/cart_provider.dart';
import 'package:gogo_pharma/providers/wishlist_provider.dart';
import 'package:gogo_pharma/services/provider_helper_class.dart';
import 'package:provider/provider.dart';

import '../common/nav_routes.dart';
import '../models/local_products.dart';
import '../models/url_resolver.dart';
import '../services/helpers.dart';
import '../widgets/reusable_widgets.dart';

class AppDataProvider extends ChangeNotifier with ProviderHelperClass {
  List<Items> wishListItems = <Items>[];
  List<CartItems> cartItemList = <CartItems>[];
  Map<String, LocalProducts> appProductData = <String, LocalProducts>{};

  bool isValidated = false;

  ///Url resolver -------------------------------------

  Future<void> navByDeepLink(
      {required BuildContext context, required String url}) async {
    if (url.contains('/')) {
      String urlPath = url.split('/').last;
      ReusableWidgets.customCircularLoader(context);
      final network = await Helpers.isInternetAvailable();
      if (network) {
        try {
          final _resp = await serviceConfig.urlResolver(urlPath);
          if (_resp['urlResolver'] != null) {
            UrlResolver? urlResolver =
                UrlResolver.fromJson(_resp['urlResolver']);
            if (urlResolver.type != null) {
              context.rootPop();
              NavRoutes.navByType(context,
                  type: urlResolver.type!.toLowerCase(),
                  id: urlResolver.type!.toLowerCase() == 'product'
                      ? urlResolver.productSku ?? ''
                      : '${urlResolver.id ?? ''}',
                  title: '');
            }
          } else {
            context.rootPop();
          }
        } catch (_) {
          context.rootPop();
        }
      } else {
        context.rootPop();
      }
    }
  }

  ///Cart
  Future<bool> fetchCartData(BuildContext context) async {
    bool respFlag = false;
    try {
      clearData();
      updateIsValidated();
      final _cartRes = await context
          .read<CartProvider>()
          .getCartData(context, isFromAppData: true);
      if (_cartRes != null && _cartRes is CartModel) {
        CartModel? _cartModel = _cartRes;
        if (_cartModel.items != null) {
          updateCartData(_cartModel);
        } else {
          context.read<CartProvider>().setCartCount(0);
        }
        final _fetchWishListId =
            await context.read<WishListProvider>().fetchWishListId();
        if (_fetchWishListId) {
          WishListModels? wishListModels =
              await context.read<WishListProvider>().getWishListData();
          if (wishListModels != null) {
            updateWishListModel(wishListModels);
          }
        }
        respFlag = true;
        return respFlag;
      } else {
        Helpers.successToast(context.loc.unExpectedError);
        context.read<AuthProvider>().disableTouch(false);
      }
    } catch (e) {
      'Error $e'.log(name: 'AppDataProvider');
      respFlag = false;
    }
    return respFlag;
  }

  Future<void> updateCartData(CartModel? _cartModel) async {
    List<CartItems>? _items = _cartModel?.items;
    if (_items != null && _items.isNotEmpty) {
      for (var element in _items) {
        String? sku = element.variationData?.sku ?? element.product?.sku;
        if (sku != null) {
          if (appProductData.containsKey(sku)) {
            LocalProducts _localProducts = appProductData[sku]!;
            LocalProducts localProducts = LocalProducts()
              ..isFavourite = _localProducts.isFavourite
              ..quantity = element.quantity
              ..sku = sku
              ..itemId = _localProducts.itemId;
            appProductData[sku] = localProducts;
          } else {
            LocalProducts localProducts = LocalProducts()
              ..quantity = element.quantity
              ..cartItemId = int.parse('${element.id}')
              ..sku = sku;
            appProductData[sku] = localProducts;
          }
        }
      }
    }
    notifyListeners();
  }

  Future<void> addToCartLocal(String sku,
      {required int? cartItemId, int? qty}) async {
    if (appProductData.containsKey(sku)) {
      LocalProducts _localProducts = appProductData[sku]!;
      LocalProducts localProducts = LocalProducts()
        ..isFavourite = _localProducts.isFavourite
        ..quantity = qty ?? (_localProducts.quantity! + 1)
        ..sku = sku
        ..cartItemId = cartItemId
        ..itemId = _localProducts.itemId;
      appProductData[sku] = localProducts;
    } else {
      LocalProducts localProducts = LocalProducts()
        ..quantity = qty ?? 1
        ..cartItemId = cartItemId
        ..sku = sku;
      appProductData[sku] = localProducts;
    }
    notifyListeners();
  }

  Future<void> removeFromCartLocal(String sku, BuildContext context) async {
    if (appProductData.containsKey(sku)) {
      LocalProducts _localProducts = appProductData[sku]!;
      LocalProducts localProducts = LocalProducts()
        ..isFavourite = _localProducts.isFavourite
        ..sku = sku
        ..itemId = _localProducts.itemId;
      appProductData[sku] = localProducts;
    } else {
      appProductData.remove(sku);
    }
    Helpers.successToast(context.loc.removedSuccessfully);
    notifyListeners();
  }

  Future<void> updateWishListModel(val) async {
    WishListModels _wishListModel = val;
    List<Wishlists>? wishlists = _wishListModel.customer?.wishlists;
    List<Items>? items = wishlists != null && wishlists.isNotEmpty
        ? wishlists.first.itemsV2?.items
        : null;
    updateWishListItem(items);
    if (items != null && items.isNotEmpty) {
      for (var element in items) {
        if (element.product?.sku != null) {
          LocalProducts localProducts = LocalProducts()
            ..isFavourite = true
            ..sku = element.product?.sku
            ..itemId = int.tryParse(element.id ?? '');
          appProductData[element.product!.sku!] = localProducts;
        }
      }
    }
    notifyListeners();
  }

  Future<void> addToWishListLocal(String sku, {required int itemId}) async {
    if (appProductData.containsKey(sku)) {
      LocalProducts _localProducts = appProductData[sku]!;
      LocalProducts localProducts = LocalProducts()
        ..isFavourite = true
        ..quantity = _localProducts.quantity
        ..sku = sku
        ..cartItemId = _localProducts.cartItemId
        ..itemId = itemId;
      appProductData[sku] = localProducts;
    } else {
      LocalProducts localProducts = LocalProducts()
        ..isFavourite = true
        ..sku = sku
        ..itemId = itemId;
      appProductData[sku] = localProducts;
    }
    notifyListeners();
  }

  Future<void> removeFromWishListLocal(String sku, BuildContext context,
      {bool fromWishList = false}) async {
    if (appProductData.containsKey(sku)) {
      LocalProducts _localProducts = appProductData[sku]!;
      LocalProducts localProducts = LocalProducts()
        ..isFavourite = false
        ..quantity = _localProducts.quantity
        ..cartItemId = _localProducts.cartItemId
        ..sku = sku
        ..itemId = null;
      appProductData[sku] = localProducts;
    } else {
      appProductData.remove(sku);
    }
    context.rootPop();
    if (fromWishList) {
      context.read<WishListProvider>().getWishListData();
    }
    notifyListeners();
  }

  Future<void> clearCartFromLocal(List<String> skuList) async {
    for (var sku in skuList) {
      if (appProductData.containsKey(sku)) {
        LocalProducts _localProducts = appProductData[sku]!;
        LocalProducts localProducts = LocalProducts()
          ..isFavourite = _localProducts.isFavourite
          ..sku = sku
          ..itemId = _localProducts.itemId;
        appProductData[sku] = localProducts;
      }
    }
  }

  void updateWishListItem(val) {
    wishListItems = val;
    notifyListeners();
  }

  void updateIsValidated() {
    isValidated = true;
    notifyListeners();
  }

  Future<void> clearData() async {
    wishListItems = <Items>[];
    cartItemList = <CartItems>[];
    appProductData = <String, LocalProducts>{};
    notifyListeners();
  }

  @override
  void updateLoadState(LoaderState state) {}
}
