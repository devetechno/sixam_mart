import 'package:card_swiper/card_swiper.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';
import 'package:sixam_mart/features/auth/widgets/web_registration_stepper_widget.dart';
import 'package:sixam_mart/features/business/controllers/business_controller.dart';
import 'package:sixam_mart/features/business/widgets/package_card_widget.dart';
import 'package:sixam_mart/features/business/widgets/web_business_plan_widget.dart';
import 'package:sixam_mart/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/business/widgets/base_card_widget.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BusinessPlanScreen extends StatefulWidget {
  final int? storeId;
  const BusinessPlanScreen({super.key, this.storeId});

  @override
  State<BusinessPlanScreen> createState() => _BusinessPlanScreenState();
}

class _BusinessPlanScreenState extends State<BusinessPlanScreen> {
  final bool _canBack = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    super.initState();

    Get.find<BusinessController>().resetBusiness();
    Get.find<BusinessController>().getPackageList(isUpdate: false);
    Get.find<BusinessController>().changeDigitalPaymentName(null, canUpdate: false);
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return GetBuilder<BusinessController>(builder: (businessController) {
      return PopScope(
        canPop: false,
        onPopInvoked: (val) async{
          if(_canBack) {
          }else {
            _showBackPressedDialogue('your_business_plan_not_setup_yet'.tr);
          }
        },
        child: Scaffold(
          appBar: isDesktop ? CustomAppBar(title: 'business_plan'.tr, backButton: false) : null,
          endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,

          body: Column(children: [

            WebScreenTitleWidget(title: 'join_as_store'.tr),

            const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

            isDesktop ? SizedBox(
              width: Dimensions.webMaxWidth,
              child: RegistrationStepperWidget(status: businessController.businessPlanStatus),
            ) : Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical:  Dimensions.paddingSizeSmall),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text(
                  'store_registration'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),

                Text(
                  'you_are_one_step_away_choose_your_business_plan'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                ),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                LinearProgressIndicator(
                  backgroundColor: Theme.of(context).disabledColor, minHeight: 2,
                  value: 0.75,
                ),
              ]),
            ),
            SizedBox(height: isDesktop ? Dimensions.paddingSizeDefault : 0),

            Expanded(
              child: SingleChildScrollView(
                child: FooterView(
                  minHeight: 0.5,
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: isDesktop ? WebBusinessPlanWidget(storeId: widget.storeId) : Column(children: [

                      Padding(
                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeExtremeLarge),
                        child: Center(child: Text('choose_your_business_plan'.tr, style: robotoBold)),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                        child: Row(children: [

                          Get.find<SplashController>().configModel!.commissionBusinessModel != 0 ? Expanded(
                            child: BaseCardWidget(businessController: businessController, title: 'commission_base'.tr,
                              index: 0, onTap: ()=> businessController.setBusiness(0),
                            ),
                          ) : const SizedBox(),
                          SizedBox(width: Get.find<SplashController>().configModel!.commissionBusinessModel != 0 ? Dimensions.paddingSizeDefault : 0),

                          Get.find<SplashController>().configModel!.subscriptionBusinessModel != 0 ? Expanded(
                            child: BaseCardWidget(businessController: businessController, title: 'subscription_base'.tr,
                              index: 1, onTap: ()=> businessController.setBusiness(1),
                            ),
                          ) : const SizedBox(),

                        ]),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      businessController.businessIndex == 0 ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                        child: Text(
                          "${'store_will_pay'.tr} ${Get.find<SplashController>().configModel!.adminCommission}% ${'commission_to'.tr} ${Get.find<SplashController>().configModel!.businessName} ${'from_each_order_You_will_get_access_of_all'.tr}",
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7)), textAlign: TextAlign.justify, textScaler: const TextScaler.linear(1.1),
                        ),
                      ) : Column(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                          child: Text(
                            'run_store_by_purchasing_subscription_packages'.tr,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7)), textAlign: TextAlign.justify, textScaler: const TextScaler.linear(1.1),
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        businessController.packageModel != null ? SizedBox(
                          height: 420,
                          child: businessController.packageModel!.packages!.isNotEmpty ? Swiper(
                            itemCount: businessController.packageModel!.packages!.length,
                            viewportFraction: 0.60,
                            itemBuilder: (context, index) {
                              return PackageCardWidget(
                                canSelect: businessController.activeSubscriptionIndex == index,
                                packages: businessController.packageModel!.packages![index],
                              );
                            },
                            onIndexChanged: (index) {
                              businessController.selectSubscriptionCard(index);
                            },

                          ) : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(Images.emptyBox, height: 150),
                                const SizedBox(height: Dimensions.paddingSizeLarge),
                                Text('no_package_available'.tr, style: robotoMedium),
                              ]),
                          ),
                        ) : const CircularProgressIndicator(),

                      ]),

                    ]),
                  ),
                ),
              ),
            ),

            !isDesktop ? Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: const [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
              child: CustomButton(
                buttonText: businessController.businessIndex == 0 ? 'complete'.tr : 'next'.tr,
                onPressed: (businessController.businessIndex == 1 && businessController.packageModel == null && businessController.packageModel!.packages!.isEmpty) ? null : () {
                  if(businessController.businessIndex == 0) {
                    businessController.submitBusinessPlan(storeId: widget.storeId!, packageId: null);
                  } else {
                    Get.toNamed(RouteHelper.getSubscriptionPaymentRoute(
                      storeId: widget.storeId,
                      packageId: businessController.packageModel!.packages![businessController.activeSubscriptionIndex].id,
                    ));
                  }
                },
              ),
            ) : const SizedBox(),

          ]),
        ),
      );
    });
  }

  void _showBackPressedDialogue(String title){
    Get.dialog(ConfirmationDialog(icon: Images.support,
      title: title,
      description: 'are_you_sure_to_go_back'.tr, isLogOut: true,
      onYesPressed: () =>  Get.off(() => const DashboardScreen(pageIndex: 4)),
    ), useSafeArea: false);
  }
}
