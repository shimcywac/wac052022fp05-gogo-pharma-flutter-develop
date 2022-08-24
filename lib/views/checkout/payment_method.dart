import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gogo_pharma/common/constants.dart';
import 'package:gogo_pharma/common/extensions.dart';
import 'package:gogo_pharma/common/font_style.dart';
import 'package:gogo_pharma/providers/order_summary_provider.dart';
import 'package:gogo_pharma/providers/payment_provider.dart';
import 'package:gogo_pharma/services/helpers.dart';
import 'package:gogo_pharma/utils/color_palette.dart';
import 'package:gogo_pharma/widgets/custom_expansion_tile.dart';
import 'package:gogo_pharma/widgets/reusable_widgets.dart';
import 'package:provider/provider.dart';

import '../../generated/assets.dart';
import '../../models/payment_method_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/custom_radio.dart';
import '../cart/cart_bottom_detail_tile.dart';
import 'order_summary_product_list.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({Key? key}) : super(key: key);

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  final ValueNotifier<bool> isExpanded = ValueNotifier(false);

  @override
  void initState() {
    Future.microtask(() => context.read<PaymentProvider>().pageInit());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ReusableWidgets.divider(height: 5.h),
        orderExpansionTile(),
        ReusableWidgets.divider(height: 5.h),
        _paymentOptions(),
        ReusableWidgets.divider(height: 8.h),
        Consumer<CartProvider>(builder: (context, model, _) {
          return CartBottomDetailTile(
            cartModel: model.cartModel,
            fromCartPage: false,
          );
        })
      ],
    );
  }

  Widget _paymentOptions() {
    return Container(
      color: Colors.white,
      child: Consumer<PaymentProvider>(builder: (context, model, _) {
        return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (cxt, index) {
              return _paymentOptionTile(
                  model.paymentMethodModel?.availablePaymentMethods?[index],
                  model.selectedCode);
            },
            separatorBuilder: (_, __) {
              return ReusableWidgets.divider(
                  height: 1.h,
                  color: HexColor('#E9EBEB'),
                  margin: EdgeInsets.symmetric(horizontal: 16.w));
            },
            itemCount:
                model.paymentMethodModel?.availablePaymentMethods?.length ?? 0);
      }),
    );
  }

  Widget _paymentOptionTile(
      AvailablePaymentMethods? availablePaymentMethods, String? selectedCode) {
    return InkWell(
      onTap: () {
        context.read<PaymentProvider>()
          ..updateSelectedCode(availablePaymentMethods?.code ?? '',
              availablePaymentMethods?.title ?? '')
          ..setPaymentMethodOnCart(context, availablePaymentMethods?.code ?? '',
              availablePaymentMethods?.title ?? '');
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 19.h),
        child: Row(
          children: [
            CustomRadio(
              enable: (availablePaymentMethods?.code ?? '') == selectedCode,
            ),
            SizedBox(
              width: 10.w,
            ),
            Text(
              availablePaymentMethods?.title ?? '',
              style: FontStyle.black14Medium,
            )
          ],
        ),
      ),
    );
  }

  Widget orderExpansionTile() {
    return CustomExpansionTile(
      backgroundColor: Colors.white,
      tilePadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      title: ValueListenableBuilder<bool>(
          valueListenable: isExpanded,
          builder: (cxt, value, _) {
            return Row(
              children: [
                SvgPicture.asset(
                  Assets.iconsShoppingCart,
                  width: 19.w,
                  height: 18.h,
                ),
                SizedBox(
                  width: 11.w,
                ),
                Text(
                  value
                      ? context.loc.hideOrderSummary
                      : context.loc.showOrderSummary,
                  style: FontStyle.primary14Medium.copyWith(height: 1.2.h),
                ).avoidOverFlow().animatedSwitch(),
                SizedBox(
                  width: 11.w,
                ),
                RotationTransition(
                  turns: value
                      ? const AlwaysStoppedAnimation(180 / 360)
                      : const AlwaysStoppedAnimation(0 / 360),
                  child: SvgPicture.asset(
                    Assets.iconsChevronRight,
                    width: 8.w,
                    height: 4.h,
                  ),
                )
              ],
            );
          }),
      onExpansionChanged: (bool val) {
        isExpanded.value = val;
      },
      trailing: Consumer<CartProvider>(builder: (context, model, _) {
        return Text(
          Helpers.alignPrice(model.cartModel?.prices?.grandTotal?.currency,
              model.cartModel?.prices?.grandTotal),
          style: FontStyle.black15Medium,
        );
      }),
      children: [
        ReusableWidgets.divider(height: 1.h),
        const OrderSummaryProductList()
      ],
    );
  }
}


