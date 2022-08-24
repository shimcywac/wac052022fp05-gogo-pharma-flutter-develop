import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gogo_pharma/common/constants.dart';
import 'package:gogo_pharma/common/extensions.dart';
import 'package:gogo_pharma/models/product_detail_model.dart';
import 'package:gogo_pharma/services/provider_helper_class.dart';

import '../common/check_function.dart';
import '../models/product_listing_model.dart';
import '../services/helpers.dart';

class ProductDetailProvider extends ChangeNotifier with ProviderHelperClass {
  Item? productDetailData;
  Item? initialProductDetailData;
  List<Item>? relatedProducts;
  Map<String, int> selectedOptions = {};

  Future<void> getProductDetailData(String sku,
      {Function(Item?)? onSuccess}) async {
    updateLoadState(LoaderState.loading);
    final network = await Helpers.isInternetAvailable();
    if (network) {
      try {
        final _resp = await serviceConfig.getProductDetailData(sku);
        if (_resp['products'] != null) {
          ProductDetailModel? _productDetailModel =
              ProductDetailModel.fromJson(_resp['products']);
          if (_productDetailModel.items != null &&
              _productDetailModel.items!.isNotEmpty) {
            setProductDetailModel(_productDetailModel.items?.first,
                initial: true);
            setDefaultVariant();
            updateLoadState(LoaderState.loaded);
            if (onSuccess != null) onSuccess(productDetailData);
          } else {
            setProductDetailModel([]);
            updateLoadState(LoaderState.loaded);
          }
        } else {
          Check.checkException(_resp);
          updateLoadState(LoaderState.error);
        }
      } catch (e) {
        updateLoadState(LoaderState.error);
      }
    } else {
      updateLoadState(LoaderState.networkErr);
    }
  }

  Future<void> getSimilarProductData(String sku) async {
    final network = await Helpers.isInternetAvailable();
    if (network) {
      try {
        final _resp = await serviceConfig.getSimilarProductData(sku);
        if (_resp['products'] != null) {
          ProductDetailModel? _relatedDetailModel =
              ProductDetailModel.fromJson(_resp['products']);
          if (_relatedDetailModel.items != null &&
              _relatedDetailModel.items!.isNotEmpty) {
            setRelatedProductModel(
                _relatedDetailModel.items!.first.relatedProducts);
          } else {
            setRelatedProductModel(null);
          }
        } else {
          setRelatedProductModel(null);
          Check.checkException(_resp);
          print(_resp);
        }
      } catch (e) {
        setRelatedProductModel(null);
        'Error on $e'.log(name: 'Related product detail');
      }
    } else {
      setRelatedProductModel(null);
    }
  }

  void setDefaultVariant() {
    if (productDetailData?.selectedVariantOptions != null &&
        (productDetailData?.typename ?? '').toLowerCase() ==
            Constants.configurableProduct) {
      for (SelectedVariantOption? selectedVariantOption
          in productDetailData!.selectedVariantOptions!) {
        updateSelectedOptions(selectedVariantOption?.code ?? '',
            selectedVariantOption?.valueIndex ?? -1);
      }
      validateConfigurableProduct(productDetailData?.variants ?? []);
    }
  }

  void validateConfigurableProduct(List<Variant> variants) {
    Item? _product;
    for (Variant? _variant in variants) {
      if (_variant?.attributes != null && _product == null) {
        for (VariantAttribute? element in _variant!.attributes!) {
          selectedOptions.forEach((key, value) {
            if ((element?.code ?? '') == key &&
                (element?.valueIndex ?? '') == value) {
              _product = _variant.product;
            }
          });
        }
      }
    }
    if (_product != null) {
      Item? pct = _product!.copyWith(previousItem: initialProductDetailData);
      setProductDetailModel(pct);
    }
  }

  void setProductDetailModel(val, {bool initial = false}) {
    productDetailData = val;
    if (initial) initialProductDetailData = val;
    notifyListeners();
  }

  void setRelatedProductModel(val) {
    relatedProducts = val;
    notifyListeners();
  }

  @override
  void pageInit() {
    loaderState = LoaderState.loading;
    productDetailData = null;
    initialProductDetailData = null;
    selectedOptions = {};
    notifyListeners();
    super.pageInit();
  }

  void updateSelectedOptions(String key, int value) {
    selectedOptions[key] = value;
    notifyListeners();
  }

  @override
  void updateLoadState(LoaderState state) {
    loaderState = state;
    notifyListeners();
  }
}
