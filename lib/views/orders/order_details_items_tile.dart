import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gogo_pharma/common/extensions.dart';
import 'package:gogo_pharma/common/font_style.dart';
import 'package:gogo_pharma/models/myordersmodel/orderdetailsmodel.dart';
import 'package:gogo_pharma/models/route_arguments.dart';
import 'package:gogo_pharma/providers/orders_provider.dart';
import 'package:gogo_pharma/widgets/common_button.dart';
import 'package:gogo_pharma/widgets/common_image_view.dart';
import 'package:gogo_pharma/widgets/reusable_widgets.dart';
import 'package:provider/provider.dart';

import '../../common/const.dart';
import '../../common/custom_radio_btn.dart';
import '../../common/route_generator.dart';
import '../../utils/color_palette.dart';

class OrderDetailsItemsTile extends StatelessWidget {
  const OrderDetailsItemsTile({
    Key? key,
    this.items,
  }) : super(key: key);
  final OrderDetailsItems? items;

  @override
  Widget build(BuildContext context) {
    return Consumer<OrdersProvider>(
      builder: (context, modelValue, child) {
        return ListView.separated(
          itemCount: items?.items?.length ?? 0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, RouteGenerator.routeProductDetails,
                    arguments: RouteArguments(sku: items?.productSku));
              },
              child: Container(
                color: Colors.white,
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(children: [
                          CommonImageView(
                            height: 61.24.h,
                            width: 61.24.w,
                            image: items?.items?[index].productImageApp ?? '',
                          ),
                          ReusableWidgets.emptyBox(
                            height: 17.h,
                          )
                        ]),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Padding(
                                          padding:
                                              EdgeInsets.only(right: 36.5.w),
                                          child: _productName(
                                              items: items, index: index))),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    //this column is for order status in order tile
                                    children: [
                                      Text(
                                        Const.ordered,
                                        overflow: TextOverflow.ellipsis,
                                        style: FontStyle.primary11Medium,
                                      ),
                                      Text(
                                        items?.orderPlaced?.date.toString() ??
                                            "",
                                        overflow: TextOverflow.ellipsis,
                                        style: FontStyle.grey11Medium_556879,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 5.h, bottom: 8.h),
                                child: Text(
                                  " ${items?.items?[index].productSalePrice?.currency ?? ""}"
                                  " ${items?.items?[index].productSalePrice?.value.toString()}",
                                  overflow: TextOverflow.ellipsis,
                                  style: FontStyle.black13bold,
                                ).avoidOverFlow(maxLine: 3),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "QTY  ${items?.items?[index].quantityOrdered}",
                                    overflow: TextOverflow.ellipsis,
                                    style: FontStyle.grey12Medium_556879,
                                  ).avoidOverFlow(maxLine: 3),
                                  (items?.items?[index].isItemCanCancel != null)
                                      ? InkWell(
                                          onTap: () async {
                                            modelValue.getCancellationReasons();

                                            (modelValue.cancellationReasonList!
                                                    .isNotEmpty)
                                                ? showCancelReason(
                                                    context: context,
                                                    reasonStrings: modelValue
                                                        .cancellationReasonList,
                                                    itemIndex: index,
                                                  )
                                                : null;
                                          },
                                          child: Text(
                                            Const.cancelItem,
                                            overflow: TextOverflow.ellipsis,
                                            style: FontStyle.regular11RedFF5,
                                          ).avoidOverFlow(maxLine: 3),
                                        )
                                      : ReusableWidgets.emptyBox()
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return ReusableWidgets.emptyBox(height: 8.h);
          },
        );
      },
    );
  }

  Widget _productName({OrderDetailsItems? items, int? index}) {
    return Text(
      items?.items?[index ?? 0].productName ?? "",
      overflow: TextOverflow.ellipsis,
      style: FontStyle.black13Medium,
    ).avoidOverFlow(maxLine: 3);
  }

  void showCancelReason(
      {required BuildContext context,
      List<String>? reasonStrings,
      int? orderIndex,
      int? itemIndex}) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.r))),
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Consumer<OrdersProvider>(
          builder: (context, modelValue, child) => Container(
            margin: EdgeInsets.symmetric(horizontal: 26.w, vertical: 32.h),
            child: Column(
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Const.cancelItem,
                        style: FontStyle.black18SemiBold,
                      ),
                      SizedBox(height: 25.h),
                      Text(
                        Const.reasonForCancel,
                        style: FontStyle.grey15Regular69696,
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        separatorBuilder: (context, index) =>
                            ReusableWidgets.emptyBox(),
                        itemCount: reasonStrings?.length ?? 0,
                        itemBuilder: (context, index) => InkWell(
                          onTap: () => modelValue
                              .updateRadioSelectCancelReviewProduct(index,
                                  cancelResponse: reasonStrings?[index]),
                          child: Row(
                            children: [
                              CustomRadioBtn(
                                value: index,
                                focusColor: HexColor('#C5C5C5'),
                                groupValue:
                                    modelValue.selectRadioIndexCancelResponse,
                                activeColor: ColorPalette.primaryColor,
                                onChanged: (int? index) {
                                  modelValue
                                      .updateRadioSelectCancelReviewProduct(
                                          index,
                                          cancelResponse:
                                              reasonStrings?[index ?? 0]);
                                },
                              ),
                              Text(
                                reasonStrings![index].isNotEmpty
                                    ? reasonStrings[index]
                                    : "",
                                style: FontStyle.black13Regular,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CommonButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    buttonText: Const.close,
                  ),
                ),
                Expanded(
                  child: TextButton(
                      onPressed: () {
                        modelValue.getCancellationOrders(
                            context: context,
                            reasonCancellation:
                                modelValue.selectedCancelResponse,
                            incrementID: items?.incrementId,
                            orderId: items?.id,
                            itemId: items?.items?[itemIndex ?? 0].id ?? "");
                      },
                      child: Text(
                        Const.cancelOrder,
                        style: FontStyle.primary15SemiBold,
                      )),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
