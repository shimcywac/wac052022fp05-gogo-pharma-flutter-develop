import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gogo_pharma/common/extensions.dart';
import 'package:gogo_pharma/common/font_style.dart';
import 'package:gogo_pharma/providers/address_provider.dart';
import 'package:gogo_pharma/providers/order_summary_provider.dart';
import 'package:gogo_pharma/providers/payment_provider.dart';
import 'package:gogo_pharma/services/app_config.dart';
import 'package:gogo_pharma/views/checkout/payment_method.dart';
import 'package:gogo_pharma/views/checkout/summary_tab_tile.dart';
import 'package:gogo_pharma/widgets/reusable_widgets.dart';
import 'package:provider/provider.dart';
import '../../common/constants.dart';
import '../../providers/cart_provider.dart';
import '../../utils/color_palette.dart';
import '../../widgets/common_app_bar.dart';
import '../cart/cart_bottom_tile.dart';
import 'order_add_address_widget.dart';
import 'order_address_list_widget.dart';
import 'order_summary.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({Key? key}) : super(key: key);

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  final PageController pageCtrl = PageController();

  List<String> _pageTitles = [];

  @override
  void initState() {
    pageCtrl.addListener(pageViewListener);
    Future.microtask(() => context.read<OrderSummaryProvider>().pageInit());
    Future.microtask(() => context.read<PaymentProvider>().getUserEmail());
    _getData(0);

    super.initState();
  }

  @override
  void dispose() {
    pageCtrl.dispose();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrderSummaryProvider>().disposeCtrl();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pageTitles = [
      context.loc.address,
      context.loc.orderSummary,
      context.loc.paymentMethod
    ];
    return Scaffold(
      backgroundColor: HexColor('#F4F7F7'),
      appBar: CommonAppBar(
        titleWidget: Consumer<OrderSummaryProvider>(
            builder: (_, model, __) => Text(
                  _pageTitles[model.pageIndex],
                  style: FontStyle.black15Medium,
                )),
        actionList: const [],
      ),
      body: SafeArea(
          child: Consumer<OrderSummaryProvider>(builder: (__, model, _) {
        return WillPopScope(
          onWillPop: () => _onWillPop(model.pageIndex, model.addressPageIndex),
          child: Column(
            children: [
              SizedBox(
                height: 3.h,
              ),
              SummaryTabTile(
                pageViewIndex: model.pageIndex,
              ),
              Expanded(
                  child: PageView(
                controller: pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  PageView(
                    controller: model.addressCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const OrderAddressListWidget(),
                      OrderAddAddress(
                          addAddressArgument: model.addAddressArgument)
                    ],
                  ),
                  OrderSummary(
                    onAddressTap: () {
                      switchTab(0);
                    },
                  ),
                  const PaymentMethod()
                ],
              )),
              Consumer3<CartProvider, AddressProvider, PaymentProvider>(builder:
                  (_, cartProvider, addressProvider, paymentProvider, __) {
                return (model.addressPageIndex == 1
                    ? const SizedBox()
                    : CartBottomTile(
                        grandTotal: cartProvider.cartModel?.prices?.grandTotal,
                        btnText: model.pageIndex != 2
                            ? context.loc.continueTxt
                            : paymentProvider.selectedCode == 'cashondelivery'
                                ? context.loc.placeOrderTxt
                                : context.loc.payNowTxt,
                        onTap:
                            addressProvider.address == null || model.disableBtn
                                ? null
                                : () => buttonHandler(model.pageIndex),
                      ))
                  ..animatedSwitch(
                      curvesIn: Curves.easeInCubic,
                      curvesOut: Curves.easeOutCubic);
              })
            ],
          ),
        );
      })),
    );
  }

  void moveToNext() {
    int _index = (pageCtrl.page ?? 0.0).round();
    if (_index != 2) {
      switchTab(_index + 1);
    }
  }

  void switchTab(int val) {
    pageCtrl.animateToPage(val,
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  void pageViewListener() {
    int index = (pageCtrl.page ?? 0.0).round();
    final provider = context.read<OrderSummaryProvider>();
    if (provider.pageIndex != index) {
      provider.updatePageIndex(index);
      _getData(index);
    }
  }

  void buttonHandler(int index) async {
    switch (index) {
      case 0:
        ReusableWidgets.customCircularLoader(context);
        disableBtn(true);
        final res = await context.read<AddressProvider>().proceedToCheckOut();
        if (res) {
          context.rootPop();
          disableBtn(false);
          moveToNext();
        } else {
          context.rootPop();
          disableBtn(false);
        }
        break;
      case 1:
        ReusableWidgets.customCircularLoader(context);
        disableBtn(true);
        final res = await context
            .read<PaymentProvider>()
            .getAvailablePaymentMethod(context);
        if (res) {
          context.rootPop();
          moveToNext();
        } else {
          context.rootPop();
          disableBtn(false);
        }
        break;
      case 2:
        ReusableWidgets.customCircularLoader(context);
        disableBtn(true);
        await context.read<PaymentProvider>().startOrdering(context);
        break;
      default:
        moveToNext();
    }
  }

  void _getData(int index) {
    switch (index) {
      case 0:
        Future.microtask(() => context.read<AddressProvider>()
          ..pageInit()
          ..getAddressList(context));
        break;
    }
  }

  void disableBtn(val) {
    context.read<OrderSummaryProvider>().updateDisableBtn(val);
  }

  Future<bool> _onWillPop(int index, int addressPageIndex) async {
    if (index != 0) {
      context.read<OrderSummaryProvider>().updateDisableBtn(false);
      switchTab(index - 1);
      return false;
    } else if (index == 0 && addressPageIndex == 1) {
      context.read<OrderSummaryProvider>().switchAddressPage(0);
      return false;
    } else {
      return true;
    }
  }
}
