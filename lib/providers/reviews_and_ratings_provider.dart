import 'package:flutter/material.dart';
import 'package:gogo_pharma/common/constants.dart';
import 'package:gogo_pharma/common/font_style.dart';
import 'package:gogo_pharma/models/reviews_and_ratings_models/pending_review_model.dart';
import 'package:gogo_pharma/services/provider_helper_class.dart';

import '../common/check_function.dart';

import '../common/route_generator.dart';
import '../models/reviews_and_ratings_models/customer_publish_review_model.dart';
import '../services/helpers.dart';

class ReviewsAndRatingsProvider with ChangeNotifier, ProviderHelperClass {
  ScrollController scrollController = ScrollController();
  bool status = false;
  TabController? pendPublishTabController;
  TextEditingController? titleNameController;

  TextEditingController? commentsController;

  double? ratingValue = 0;
  String? reviewStatus;
  TextStyle reviewTextStyle = TextStyle();
  List<GetUnratedProducts>? pendingReviewsList;
  Reviews? reviewsList;
  int pageCount = 1;
  bool paginationLoader = false;
  Reviews? reviewForProduct;

  @override
  void pageInit() {
    scrollController.addListener(pagination);
    loaderState = LoaderState.loading;
    pageCount = 1;
    paginationLoader = false;
    reviewsList = null;
    reviewStatus = "";
    reviewForProduct = null;
    titleNameController=TextEditingController();
    commentsController=TextEditingController();
    notifyListeners();
    super.pageInit();
  }

  ratingReviews(ratingValue) {
    if (ratingValue > 0) {
      switch (ratingValue) {
        case 1:
          {
            reviewStatus = "Very Bad";
            reviewTextStyle = FontStyle.redErr12RegularW300;
          }
          break;
        case 2:
          {
            reviewStatus = "Bad";
            reviewTextStyle = FontStyle.redErr12RegularW300;
          }
          break;
        case 3:
          {
            reviewStatus = "Good";
            reviewTextStyle = FontStyle.yellow12RegularW300;
          }
          break;
        case 4:
          {
            reviewStatus = "Great";
            reviewTextStyle = FontStyle.green12RegularW300;
          }
          break;
        case 5:
          {
            reviewStatus = "Excellent";
            reviewTextStyle = FontStyle.green12RegularW300;
          }
          break;
        default:
          0;
      }
    } else {
      reviewStatus = "";
    }
    notifyListeners();
  }

  Future<void> getPendingReviews({bool enableLoader=false}) async {
    if (enableLoader) updateLoadState(LoaderState.loading);

    final network = await Helpers.isInternetAvailable();
    if (network) {
      try {
        final _resp = await serviceConfig.getUnratedProducts();
        if (_resp["getUnratedProducts"] != null) {
          Data pendingReviewsModel = Data.fromJson(_resp);
          pendingReviewsList = pendingReviewsModel.getUnratedProducts;
          if (enableLoader) updateLoadState(LoaderState.loaded);
          updatePaginationLoader(false);
          getPublishedReviews();
        } else {
          getPublishedReviews();
          if (enableLoader) updateLoadState(LoaderState.loaded);
          updatePaginationLoader(false);
          Check.checkException(_resp, onError: (value) {
            if (value != null && value) {
              if (enableLoader) updateLoadState(LoaderState.error);
            }
          }, onAuthError: (value) {
            if (value) {
              if (enableLoader) updateLoadState(LoaderState.error);
            }
          });
        }
      } catch (e) {
        if (enableLoader) updateLoadState(LoaderState.error);
      }
    } else {
      if (enableLoader) updateLoadState(LoaderState.networkErr);
    }
    notifyListeners();
  }

  Future<void> getPublishedReviews() async {
    updateLoadState(LoaderState.loading);
    final network = await Helpers.isInternetAvailable();
    if (network) {
      try {
        final _resp = await serviceConfig.getCustomerPublishReviews(
            currentPage: pageCount);
        if (_resp["customer"]["reviews"] != null) {
          Reviews _reviewsList = Reviews.fromJson(_resp["customer"]["reviews"]);
          if (_reviewsList.items != null) {
            setPublishReviewList(_reviewsList);
            updateLoadState(LoaderState.loaded);
            updatePaginationLoader(false);
          }
        } else {
          updateLoadState(LoaderState.loaded);
          updatePaginationLoader(false);
          Check.checkException(_resp, onError: (value) {
            if (value != null && value) {
              updateLoadState(LoaderState.error);
            }
          }, onAuthError: (value) {
            if (value) {
              updateLoadState(LoaderState.error);
            }
          });
        }
      } catch (e) {
        updateLoadState(LoaderState.error);
      }
    } else {
      updateLoadState(LoaderState.networkErr);
    }
    notifyListeners();
  }

  Future<void> getCreateProductReviews({
    String? sku,
    String? nickname,
    String? summary,
    String? text,
    bool  isFromOrderPage= false,
    required String? value,BuildContext? context
  }) async {
    updateLoadState(LoaderState.loading);
    final network = await Helpers.isInternetAvailable();
    if (network) {
      try {
        final _resp = await serviceConfig.getCreateProductReviews(
            text: text,
            nickname: nickname,
            sku: sku,
            summary: summary,
            value: value);
        if (_resp["createProductReview"]["review"] != null) {
          reviewForProduct =
              Reviews.fromJson(_resp["createProductReview"]["review"]);
         Navigator.pop(context!);
         Navigator.pop(context);
         isFromOrderPage?
         Navigator.pushReplacementNamed(
              context, RouteGenerator.routeOrders):
         Navigator.pushReplacementNamed(
              context, RouteGenerator.routeMyReviewsAndRatings);
          updateLoadState(LoaderState.loaded);
        } else {
          updateLoadState(LoaderState.loaded);
          updatePaginationLoader(false);
          Check.checkException(_resp, onError: (value) {
            if (value != null && value) {
              updateLoadState(LoaderState.error);
            }
          }, onAuthError: (value) {
            if (value) {
              updateLoadState(LoaderState.error);
            }
          });
        }

      } catch (e) {
        updateLoadState(LoaderState.error);
      }
    } else {
      updateLoadState(LoaderState.networkErr);
    }
    notifyListeners();
  }

  void setPublishReviewList(Reviews? val) {
    List<Items>? reviewItemVal = val?.items;

    if (reviewItemVal != null && reviewItemVal.isNotEmpty) {
      if (pageCount == 1) {
        reviewsList = val;
      } else {
        Reviews? tempReviews = reviewsList;
        tempReviews?.items?.addAll(reviewItemVal);
        reviewsList = tempReviews;
      }
    }
    notifyListeners();
  }

  void updatePaginationLoader(bool val) {
    paginationLoader = val;
    notifyListeners();
  }

  void pagination() {
    if (scrollController.position.pixels >=
        (scrollController.position.maxScrollExtent / 2)) {
      if (reviewsList?.pageInfo?.totalPages != null &&
          pageCount < reviewsList!.pageInfo!.totalPages! &&
          loaderState != LoaderState.loading) {
        updatePageCount();
        updatePaginationLoader(true);
        getPublishedReviews();
      }
    }
  }

  void updatePageCount({int? count}) {
    pageCount = count ?? pageCount + 1;
    notifyListeners();
  }

  @override
  void updateLoadState(LoaderState state) {
    loaderState = state;
    notifyListeners();
  }
}
