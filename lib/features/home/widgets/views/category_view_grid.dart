import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/home/widgets/category_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';

class CategoryViewGrid extends StatelessWidget {
  const CategoryViewGrid({super.key});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();

    return GetBuilder<SplashController>(builder: (splashController) {
      bool isPharmacy = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.pharmacy;
      bool isFood = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.food;

      return GetBuilder<CategoryController>(builder: (categoryController) {
        return (categoryController.categoryList != null && categoryController.categoryList!.isEmpty)
        ? const SizedBox()  : Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    //height: 158,
                    child: categoryController.categoryList != null ? GridView.builder(
                      //controller: scrollController,
                      itemCount: categoryController.categoryList!.length > 10 ? 10 : categoryController.categoryList!.length,
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeDefault),
                      physics: const NeverScrollableScrollPhysics(),
                      //scrollDirection: Axis.horizontal,
                      //primary: true,
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: Dimensions.paddingSizeLarge,
                        mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.01,
                        childAspectRatio: ResponsiveHelper.isDesktop(context) ?  1.1 : 0.9 ,
                        crossAxisCount: ResponsiveHelper.isMobile(context) ? 3 :  4,
                      ),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeDefault),
                          child: InkWell(
                            onTap: () {
                              if(index == 9 && categoryController.categoryList!.length > 10) {
                                Get.toNamed(RouteHelper.getCategoryRoute());
                              } else {
                                Get.toNamed(RouteHelper.getCategoryItemRoute(
                                  categoryController.categoryList![index].id, categoryController.categoryList![index].name!,
                                ));
                              }
                            },
                            child: Container(
                              color: Colors.white,
                              child: SizedBox(
                                width: 80,
                                child: Column(children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: index == 0 ? Dimensions.paddingSizeExtraSmall : 0),
                                    child: Text(
                                      (index == 9 && categoryController.categoryList!.length > 10) ? 'see_all'.tr : categoryController.categoryList![index].name!,
                                      style: robotoMedium.copyWith(fontSize: 11, color: (index == 9 && categoryController.categoryList!.length > 10) ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color),
                                      maxLines: Get.find<LocalizationController>().isLtr ? 2 : 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 65, width: 65,
                                    child: Stack(children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        child: CustomImage(
                                          image: '${categoryController.categoryList![index].imageFullUrl}',
                                          height: 75, width: 75, fit: BoxFit.fitWidth,
                                        ),
                                      ),

                                      // (index == 9 && categoryController.categoryList!.length > 10) ? Positioned(
                                      //   right: 0, left: 0, top: 0, bottom: 0,
                                      //   child: Container(
                                      //     decoration: BoxDecoration(
                                      //       borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      //       gradient: LinearGradient(
                                      //         begin: Alignment.topCenter,
                                      //         end: Alignment.bottomCenter,
                                      //         colors: [
                                      //           Theme.of(context).primaryColor.withOpacity(0.4),
                                      //           Theme.of(context).primaryColor.withOpacity(0.6),
                                      //           Theme.of(context).primaryColor.withOpacity(0.4),
                                      //         ],
                                      //       ),
                                      //     ),
                                      //     child: Center(
                                      //       child: Text(
                                      //         '+${categoryController.categoryList!.length - 10}',
                                      //         style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor),
                                      //         maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                                      //       ),
                                      //     )
                                      //   ),
                                      // ) : const SizedBox(),

                                    ]),
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                  // Padding(
                                  //   padding: EdgeInsets.only(right: index == 0 ? Dimensions.paddingSizeExtraSmall : 0),
                                  //   child: Text(
                                  //     (index == 9 && categoryController.categoryList!.length > 10) ? 'see_all'.tr : categoryController.categoryList![index].name!,
                                  //     style: robotoMedium.copyWith(fontSize: 11, color: (index == 9 && categoryController.categoryList!.length > 10) ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color),
                                  //     maxLines: Get.find<LocalizationController>().isLtr ? 2 : 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                                  //   ),
                                  // ),

                                ]),
                              ),
                            ),
                          ),
                        );
                      },
                    ) : CategoryShimmer(categoryController: categoryController),
                  ),
                ),

                ResponsiveHelper.isMobile(context) ? const SizedBox() : categoryController.categoryList != null ? Column(
                  children: [
                    InkWell(
                      onTap: (){
                        showDialog(context: context, builder: (con) => Dialog(child: SizedBox(height: 550, width: 600, child: CategoryPopUp(
                          categoryController: categoryController,
                        ))));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text('view_all'.tr, style: TextStyle(fontSize: Dimensions.paddingSizeDefault, color: Theme.of(context).cardColor)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,)
                  ],
                ): CategoryShimmer(categoryController: categoryController),
              ],
            ),

          ],
        );
      });
    }
    );
  }
}

