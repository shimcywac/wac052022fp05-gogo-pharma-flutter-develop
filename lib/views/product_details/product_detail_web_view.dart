import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gogo_pharma/widgets/reusable_widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/color_palette.dart';
import '../../widgets/common_app_bar.dart';

class ProductDetailWebView extends StatelessWidget {
  final String? url;
  const ProductDetailWebView({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F4F7F7'),
      appBar: CommonAppBar(
        pageTitle: '',
        elevationVal: 0,
        buildContext: context,
      ),
      body: SafeArea(
          child: Container(
        margin: EdgeInsets.only(top: 3.h),
        child: WebView(
          initialUrl:
              Uri.parse(url ?? '').isAbsolute ? url : 'https://google.com',
          onPageStarted: (val) {
            ReusableWidgets.customCircularLoader(context);
          },
          onPageFinished: (val) {
            Navigator.pop(context);
          },
        ),
      )),
    );
  }
}
