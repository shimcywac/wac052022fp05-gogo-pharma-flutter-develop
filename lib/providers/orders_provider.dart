import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gogo_pharma/common/const.dart';
import 'package:gogo_pharma/common/constants.dart';
import 'package:gogo_pharma/common/route_generator.dart';
import 'package:gogo_pharma/common/route_generator.dart';
import 'package:gogo_pharma/models/myordersmodel/orderdetailsmodel.dart';
import 'package:gogo_pharma/models/myordersmodel/order_filter_model.dart';
import 'package:gogo_pharma/models/myordersmodel/orders_listing_model.dart';
import 'package:gogo_pharma/services/provider_helper_class.dart';

import '../common/check_function.dart';
import '../common/route_generator.dart';
import '../models/myordersmodel/order_filter_date_model.dart';
import '../models/myordersmodel/orders_buyagain_model.dart';
import '../services/helpers.dart';
import '../services/shared_preference_helper.dart';

class OrdersProvider extends ChangeNotifier with ProviderHelperClass {
  int selectRadioIndexProducts = 0;
  int selectRadioIndexCancelResponse = 0;
  double statusPercentage = 0.0;
  ScrollController scrollControllerBuyAgain = ScrollController();
  ScrollController scrollController = ScrollController();
  int pageCount = 1;
  int pageCountBuyAgain = 1;
  bool paginationLoader = false;
  Orders? yourOrders;
  BuyAgainProducts? yourBuyAgainOrders;
  OrdersDetails? yourOrdersDetails;
  bool statusCompleted = false;
  String? user; //to store User Email from SharedPreferences
  String? selectedReviewProductId = "";
  String? selectedCancelResponse = "";
  OrderFilterData? orderFilterLabel;
  OrderFilterDateModel? orderFilterDate;
  bool orderFilterCheck = false;
  bool orderFilterTimeCheck = false;
  int tabControllerIndex = 0;

  //for passing value from filters for label
  GetOrderStatusFilterInput? filterLabelPassValue;

  //for Passing value from filters for Time
  GetOrderDateFilterInput? filterTimePassValue;

  ///Cancel Order
  List<String>? cancellationReasonList = [];

  void updateRadioSelectIndex(
      {bool? check, GetOrderStatusFilterInput? filterLabelPassVal}) {
    orderFilterCheck = check!;
    filterLabelPassValue = filterLabelPassVal;

    notifyListeners();
  }

  void getTabIndex(int index) {
    tabControllerIndex = index;
    notifyListeners();
  }

  ///2nd Filter Item using time
  void updateRadioTimeIndex(
      {bool? timeCheck, GetOrderDateFilterInput? filterTimePassVal}) {
    orderFilterTimeCheck = timeCheck!;
    filterTimePassValue = filterTimePassVal;

    notifyListeners();
  }

  void updateRadioSelectIndexProduct(index, {String? reviewId}) {
    selectRadioIndexProducts = index;
    selectedReviewProductId = reviewId;
    notifyListeners();
  }

  void updateRadioSelectCancelReviewProduct(index, {String? cancelResponse}) {
    selectRadioIndexCancelResponse = index;
    selectedCancelResponse = cancelResponse;

    notifyListeners();
  }

  @override
  void pageInit() {
    scrollController.addListener(pagination);
    scrollControllerBuyAgain.addListener(paginationBuyAgain);
    loaderState = LoaderState.loading;
    pageCount = 1;
    pageCountBuyAgain = 1;
    paginationLoader = false;
    orderFilterCheck = false;
    cancellationReasonList=[];
    getYourOrderFilterLabel();
    getOrderDateFilterInput();
    notifyListeners();
    super.pageInit();
  }

  getUserEmail() async {
    return user = await SharedPreferencesHelper.getEmail();
  }

  void updateStatusPercentage(String status, BuildContext context) {

      if (status == Const.ordered) {
        statusPercentage = 0.0;
        statusCompleted = true;
      } else if (status == Const.dispatched) {
        statusPercentage = 0.5;
        statusCompleted = true;
      } else if (status == Const.delivery || status == Const.cancelled ) {
        statusPercentage = 1;
        statusCompleted = true;
      }
         notifyListeners();
  }

  Future<void> getYourOrdersListData(
      {bool enableLoader = false,
      String? timeValFrom,
      String? timeValTo,
      String? labelVal}) async {
    Orders? _orderListingModelsProducts;
    if (enableLoader) updateLoadState(LoaderState.loading);
    final network = await Helpers.isInternetAvailable();
    if (network) {
      try {
        final _resp = await serviceConfig.getCustomerOrderListing(
            currentPage: pageCount,
            labelVal: labelVal,
            timeValFrom: timeValFrom,
            timeValTo: timeValTo);

        if (_resp['customer']["orders"] != null) {
          _orderListingModelsProducts =
              Orders.fromJson(_resp['customer']['orders']);
          updateOrderListModel(_orderListingModelsProducts);
          if (enableLoader) updateLoadState(LoaderState.loaded);
          updatePaginationLoader(false);
        } else {
          if (enableLoader) updateLoadState(LoaderState.loaded);
          updatePaginationLoader(false);
          Check.checkException(_resp, noCustomer: (value) {
            if (value != null && value) {
              if (enableLoader) updateLoadState(LoaderState.error);
              updatePaginationLoader(false);
            }
          }, onError: (value) {
            if (value != null && value) {
              if (enableLoader) updateLoadState(LoaderState.error);
              updatePaginationLoader(false);
            }
          }, onAuthError: (value) {
            if (value) {
              if (enableLoader) updateLoadState(LoaderState.error);
              updatePaginationLoader(false);
            }
          });
        }
      } catch (onError) {
        updateLoadState(LoaderState.error);
      }
    } else {
      updateLoadState(LoaderState.networkErr);
    }
    notifyListeners();
  }

  ///for get the list orders buy again
  Future<void> getOrdersBuyAgainListData({bool enableLoader = false}) async {
    BuyAgainProducts? _buyAgainProducts;
    if (enableLoader) updateLoadState(LoaderState.loading);
    final network = await Helpers.isInternetAvailable();
    if (network) {
      try {
        final _resp = await serviceConfig.getOrderBuyAgainListing(
            currentPage: pageCountBuyAgain);
        if (_resp["buyAgainProducts"]["items"] != null) {
          _buyAgainProducts =
              BuyAgainProducts.fromJson(_resp["buyAgainProducts"]);
          updateOrderBuyAgainListModel(_buyAgainProducts);
          if (enableLoader) updateLoadState(LoaderState.loaded);
          updateBuyAgainPaginationLoader(false);
        } else {
          if (enableLoader) updateLoadState(LoaderState.loaded);
          updateBuyAgainPaginationLoader(false);
          Check.checkException(_resp, noCustomer: (value) {
            if (value != null && value) {
              if (enableLoader) updateLoadState(LoaderState.error);
              updateBuyAgainPaginationLoader(false);
            }
          }, onError: (value) {
            if (value != null && value) {
              if (enableLoader) updateLoadState(LoaderState.error);
              updateBuyAgainPaginationLoader(false);
            }
          }, onAuthError: (value) {
            if (value) {
              if (enableLoader) updateLoadState(LoaderState.error);
              updateBuyAgainPaginationLoader(false);
            }
          });
        }
      } catch (onError) {
        if (enableLoader) updateLoadState(LoaderState.error);
      }
    } else {
      if (enableLoader) updateLoadState(LoaderState.networkErr);
    }
    notifyListeners();
  }

  ///For Order Details Screen Using Increment ID Form Order Listing API
  Future<void> getYourOrdersDetailsListData(
      {bool enableLoader = false, String? incrementID}) async {
    OrdersDetails? _orderDetailsListingModelsProducts;
    if (enableLoader) updateLoadState(LoaderState.loading);
    final network = await Helpers.isInternetAvailable();
    if (network) {
      try {
        final _resp = await serviceConfig.getCustomerOrderDetailsList(
            incrementId: incrementID);
        if (_resp['customer']["orders"] != null) {
          _orderDetailsListingModelsProducts =
              OrdersDetails.fromJson(_resp['customer']['orders']);
          yourOrdersDetails = _orderDetailsListingModelsProducts;
          updateLoadState(LoaderState.loaded);
        } else {
          updateLoadState(LoaderState.loaded);
          updatePaginationLoader(false);
          Check.checkException(_resp, noCustomer: (value) {
            if (value != null && value) {
              updateLoadState(LoaderState.error);
            }
          }, onError: (value) {
            if (value != null && value) {
              updateLoadState(LoaderState.error);
            }
          }, onAuthError: (value) {
            if (value) {
              updateLoadState(LoaderState.error);
            }
          });
        }
      } catch (onError) {
        if (enableLoader) updateLoadState(LoaderState.error);
      }
    } else {
      if (enableLoader) updateLoadState(LoaderState.networkErr);
    }
    notifyListeners();
  }

  ///For OrderLabel Searching In OrderList
  Future<void> getYourOrderFilterLabel() async {
    final network = await Helpers.isInternetAvailable();
    if (network) {
      OrderFilterData? _orderFilterLabel;
      try {
        final _resp = await serviceConfig.getOrderStatusFilterInput();
        if (_resp != null) {
          _orderFilterLabel = OrderFilterData.fromJson(_resp);
          orderFilterLabel = _orderFilterLabel;
        }
      } catch (onError) {
        updateLoadState(LoaderState.networkErr);
      }
    }
    notifyListeners();
  }

  Future<void> getOrderDateFilterInput() async {
    final network = await Helpers.isInternetAvailable();
    if (network) {
      OrderFilterDateModel? _orderFilterDate;
      try {
        final _resp = await serviceConfig.getOrderDateFilterInput();
        if (_resp != null) {
          _orderFilterDate = OrderFilterDateModel.fromJson(_resp);
          orderFilterDate = _orderFilterDate;
        }
      } catch (onError) {
        updateLoadState(LoaderState.networkErr);
      }
    }
    notifyListeners();
  }

  ///Cancel Order..............
  Future<List<String>?> getCancellationReasons() async {
    updateLoadState(LoaderState.loading);
    final network = await Helpers.isInternetAvailable();
    if (network) {
      try {
        final _resp = await serviceConfig.cancellationReasons();
        if (_resp['cancellation_reasons_drop_down_app'] != null &&
            _resp['cancellation_reasons_drop_down_app'].isNotEmpty) {
          cancellationReasonList =
             List.from(_resp['cancellation_reasons_drop_down_app']);
          updateLoadState(LoaderState.loaded);
        } else {
          if (_resp != null && _resp["status"] == "error") {
            Helpers.errorToast(_resp["message"]);
            updateLoadState(LoaderState.loaded);
          }
        }
      } catch (e) {
        updateLoadState(LoaderState.error);
      }
    } else {
      updateLoadState(LoaderState.networkErr);
    }
    return cancellationReasonList;
  }

  Future<dynamic> getCancellationOrders(
      {required String? incrementID,
      required String? orderId,
      required BuildContext context,
      String? itemId,
      String? reasonCancellation}) async {
    updateLoadState(LoaderState.loading);
    final network = await Helpers.isInternetAvailable();
    if (network) {
      try {
        final _resp = await serviceConfig.cancellationOrderProduct(
            orderId: orderId,
            itemId: itemId ?? "",
            reasonCancellation: selectedCancelResponse);
        if (_resp['cancelOrder'] != null && _resp['cancelOrder']['status']) {
          await getYourOrdersDetailsListData(
            enableLoader: true,
            incrementID: incrementID ?? "",
          );
          Navigator.of(context).pop();
          Navigator.of(context)
              .pushReplacementNamed(RouteGenerator.routeOrders);
          updateLoadState(LoaderState.loaded);
        } else {
          if (_resp != null && _resp["status"] == "error") {
            Helpers.errorToast(_resp["message"]);
            updateLoadState(LoaderState.loaded);
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        updateLoadState(LoaderState.error);
      }
    } else {
      updateLoadState(LoaderState.networkErr);
    }
  }

  void updateOrderListModel(val) {
    Orders? _ordersModel = val;
    if (_ordersModel != null) {
      if (_ordersModel.items != null && pageCount != 1) {
        yourOrders?.copyWith(orderList: _ordersModel.items);
      } else {
        yourOrders = val;
      }
    }
    notifyListeners();
  }

  void updateOrderBuyAgainListModel(val) {
    BuyAgainProducts? _buyAgainModel = val;
    if (_buyAgainModel != null) {
      if (_buyAgainModel.items != null && pageCountBuyAgain != 1) {
        yourBuyAgainOrders?.copyWith(buyAgain: _buyAgainModel.items);
      } else {
        yourBuyAgainOrders = val;
      }
    }
    notifyListeners();
  }

  void updatePaginationLoader(bool val) {
    paginationLoader = val;
    notifyListeners();
  }

  void updateBuyAgainPaginationLoader(bool val) {
    paginationLoader = val;
    notifyListeners();
  }

  void updatePageCount({int? count}) {
    pageCount = count ?? pageCount + 1;
    notifyListeners();
  }

  void updatePageBuyAgainCount({int? count}) {
    pageCountBuyAgain = count ?? pageCountBuyAgain + 1;
    notifyListeners();
  }

  void pagination() {
    if (scrollController.position.pixels >=
        (scrollController.position.maxScrollExtent / 2)) {
      int? count = yourOrders?.totalCount ?? 0;
      if (yourOrders?.totalCount != null && (pageCount * 10) < count) {
        updatePageCount();
        updatePaginationLoader(true);
        getYourOrdersListData();
      }
    }
    notifyListeners();
  }

  void paginationBuyAgain() {
    if (scrollControllerBuyAgain.position.pixels >=
        (scrollControllerBuyAgain.position.maxScrollExtent / 2)) {
      int? count = yourBuyAgainOrders?.totalCount ?? 0;
      if (yourBuyAgainOrders?.totalCount != null &&
          (pageCountBuyAgain * 10) < count) {
        updatePageBuyAgainCount();
        updateBuyAgainPaginationLoader(true);
        getOrdersBuyAgainListData();
      }
    }
    notifyListeners();
  }
  @override
  void updateLoadState(LoaderState state) {
    loaderState = state;
    notifyListeners();
  }

  void clearCancelReason() {
    selectedCancelResponse = null;
    cancellationReasonList!.clear();
    notifyListeners();
  }

  void clearData() {
    statusPercentage=0.0;
    statusCompleted=false;
    yourOrdersDetails = null;
    notifyListeners();
  }
}
