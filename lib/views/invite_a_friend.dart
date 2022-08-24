import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gogo_pharma/common/constants.dart';
import 'package:gogo_pharma/common/extensions.dart';
import 'package:gogo_pharma/common/font_style.dart';
import 'package:gogo_pharma/generated/assets.dart';
import 'package:gogo_pharma/utils/color_palette.dart';
import 'package:gogo_pharma/widgets/common_textformfield.dart';
import 'package:gogo_pharma/widgets/reusable_widgets.dart';

import '../widgets/common_app_bar.dart';

class InviteAFriend extends StatefulWidget {
  const InviteAFriend({Key? key}) : super(key: key);

  @override
  State<InviteAFriend> createState() => _InviteAFriendState();
}

class _InviteAFriendState extends State<InviteAFriend> {
  final FocusNode _focus = FocusNode();
  final TextEditingController couponCtrl = TextEditingController();

  final socialIcons = const [
    Assets.iconsWhatsapp,
    Assets.iconsTwitter,
    Assets.iconsFacebook,
    Assets.iconsMessage
  ];

  List<String>? socialTitles;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    socialTitles ??= [
      context.loc.whatsapp,
      context.loc.twitter,
      context.loc.facebook,
      context.loc.message
    ];
  }

  Widget _topContainer() {
    return Container(
      color: HexColor('#CFFCF9'),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 21.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(
                context.loc.inviteAFriendDesc,
                style: FontStyle.black16SemiBold,
              )),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Image.asset(
                  Assets.imagesInviteCoins,
                  height: 105.h,
                  width: 105.w,
                ),
              )
            ],
          ),
          Text(
            context.loc.yourReferralLink,
            style: FontStyle.black14Medium.copyWith(color: HexColor('#5CAAA6')),
          ),
          ReusableWidgets.emptyBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 14.h),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(0.0, 3.0),
                      blurRadius: 1.0.r,
                      spreadRadius: -2.0.r,
                      color: HexColor('#A1E9E5')),
                  BoxShadow(
                      offset: const Offset(0.0, 2.0),
                      blurRadius: 2.0.r,
                      color: HexColor('#A1E9E5')),
                  BoxShadow(
                      offset: const Offset(0.0, 1.0),
                      blurRadius: 2.0.r,
                      color: HexColor('#A1E9E5')),
                ]),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'https://gogo23qwertyuert456',
                    style: FontStyle.black14Regular
                        .copyWith(color: HexColor('#2B2B2B')),
                  ).avoidOverFlow(),
                ),
                SvgPicture.asset(
                  Assets.iconsContentCopy,
                  width: 14.w,
                  height: 16.h,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _inviteByEmailTile() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.loc.inviteByEmail,
            style: FontStyle.black14SemiBold,
          ),
          SizedBox(
            height: 15.h,
          ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48.h,
                  child: CommonTextFormField(
                    hintText: context.loc.enterFriendsEmail,
                    hintFontStyle: FontStyle.lightGreyBlack14Regular,
                    controller: couponCtrl,
                    focusNode: _focus,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                  ),
                ),
              ),
              SizedBox(
                width: 8.w,
              ),
              Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 30.w),
                decoration: BoxDecoration(
                    color: ColorPalette.primaryColor,
                    borderRadius: BorderRadius.circular(8.r)),
                child: Text(
                  context.loc.send,
                  style: FontStyle.white15MediumW600,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 28.h,
          ),
          ReusableWidgets.divider(height: 0.5.h, color: HexColor('#D9E3E3'))
        ],
      ),
    );
  }

  Widget _socialIconTile({required int index}) {
    return Expanded(
      child: LayoutBuilder(builder: (cxt, constraints) {
        double _size =
            constraints.maxWidth >= 35.w ? 35.w : constraints.maxWidth;
        _size.toString().log();
        return Column(
          children: [
            SvgPicture.asset(
              socialIcons[index],
              height: _size,
              width: _size,
            ),
            SizedBox(
              height: 7.h,
            ),
            Text(
              socialTitles![index],
              style: FontStyle.litegrey11Regular
                  .copyWith(color: HexColor('#696969')),
            )
          ],
        );
      }),
    );
  }

  Widget _inviteBySocialMedia() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.loc.inviteBySocialMedia,
            style: FontStyle.black14SemiBold,
          ),
          SizedBox(
            height: 25.h,
          ),
          Row(
            children: List.generate(
                socialIcons.length, (index) => _socialIconTile(index: index)),
          ),
          SizedBox(
            height: 28.h,
          ),
          ReusableWidgets.divider(height: 0.5.h, color: HexColor('#D9E3E3'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        pageTitle: context.loc.inviteAFriend,
        actionList: const [],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ReusableWidgets.divider(height: 3.h),
            _topContainer(),
            ReusableWidgets.divider(height: 10.h),
            _inviteByEmailTile(),
            _inviteBySocialMedia()
          ],
        ),
      ),
    );
  }
}
