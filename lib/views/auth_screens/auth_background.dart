// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:gogo_pharma/common/extensions.dart';
// import 'package:gogo_pharma/generated/assets.dart';
// import 'package:gogo_pharma/utils/color_palette.dart';

// class AuthBackground extends StatelessWidget {
//   final Widget? child;
//   const AuthBackground({Key? key, this.child}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//         backgroundColor: ColorPalette.primaryColor,
//         body: Stack(
//           children: [
//             SizedBox(
//               height: 168.h,
//               width: context.sw(),
//               child: Center(
//                 child: Padding(
//                   padding: EdgeInsets.only(
//                     top: 60.14.h,
//                   ),
//                   child: SizedBox(
//                       child: SvgPicture.asset(
//                     Assets.iconsLogo,
//                     width: 120.29.w,
//                     height: 44.76.h,
//                   )),
//                 ),
//               ),
//             ),
//             Container(
//               margin: EdgeInsets.only(top: 168.h),
//               decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(14.r),
//                       topRight: Radius.circular(14.r))),
//               child: child,
//             )
//           ],
//         ));
//   }
// }
