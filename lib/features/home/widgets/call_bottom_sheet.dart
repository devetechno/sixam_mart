import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CallBottomSheetWidget extends StatelessWidget {
  final bool fromDialog;
  const CallBottomSheetWidget({super.key, this.fromDialog = false});

  @override
  Widget build(BuildContext context) {
    if(Get.find<AddressController>().addressList == null){
      Get.find<AddressController>().getAddressList();
    }
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius : BorderRadius.only(
          topLeft: Radius.circular(fromDialog ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeExtraLarge),
          topRight : Radius.circular(fromDialog ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeExtraLarge),
          bottomLeft: Radius.circular(fromDialog ? Dimensions.paddingSizeDefault : 0),
          bottomRight: Radius.circular(fromDialog ? Dimensions.paddingSizeDefault : 0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,

        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
              height: 3, width: 40,
              decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor,
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
              ),
            ),
          ),
          // const Text("Call Us",style: TextStyle(fontSize: 20),),
          const SizedBox(height: 50 ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
            [
              Container(

                width: 90,
                  height: 90,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: IconButton(
                      onPressed: () async {
                        if(await canLaunchUrlString('tel:${Get.find<SplashController>().configModel!.phone}')) {
                          launchUrlString('tel:${Get.find<SplashController>().configModel!.phone}');
                        }else {
                          showCustomSnackBar('${'can_not_launch'.tr} ${Get.find<SplashController>().configModel!.phone}');
                        }
                      },
                      icon: Image.asset('assets/image/call_icon1.png',
                      )
                  )
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraOverLarge ),

              Container(

                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: IconButton(
                      onPressed: () async {
                        launchUrlString('https://api.whatsapp.com/send/?phone=+201500000000&text=Hello%21&type=phone_number&app_absent=0');
                        // if(await canLaunchUrlString('whatsapp://send?phone=+201080510517')) {
                        //   launchUrlString('whatsapp://send?phone=+201080510517');
                        // }else {
                        // }
                      },
                      icon:Image.asset('assets/image/whats_icon.png',
                      )
                  )
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraOverLarge ),

              Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: IconButton(
                      onPressed: () {
                        Get.toNamed(RouteHelper.getConversationRoute());
                      },
                      icon: Image.asset('assets/image/chat_icon1.png',
                      )
                  )
              ),
            ],
          ),
        ],
      ),
    );
  }
}
