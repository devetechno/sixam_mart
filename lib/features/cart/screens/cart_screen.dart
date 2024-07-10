import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/cart/widgets/extra_packaging_widget.dart';
import 'package:sixam_mart/features/cart/widgets/not_available_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/cart/domain/models/cart_model.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/item_widget.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/common/widgets/web_constrained_box.dart';
import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';
import 'package:sixam_mart/features/cart/widgets/cart_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/cart/widgets/web_cart_items_widget.dart';
import 'package:sixam_mart/features/cart/widgets/web_suggested_item_view_widget.dart';
import 'package:sixam_mart/features/home/screens/home_screen.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';

import '../../../helper/auth_helper.dart';
import '../../../helper/date_converter.dart';
import '../../address/domain/models/address_model.dart';
import '../../checkout/controllers/checkout_controller.dart';
import '../../location/domain/models/zone_response_model.dart';

class CartScreen extends StatefulWidget {
  final bool fromNav;
  const CartScreen({super.key, required this.fromNav});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ScrollController scrollController = ScrollController();
  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();
  @override
  void initState() {
    super.initState();

    initCall();

  }

  Future<void> initCall() async {
    if(Get.find<CartController>().cartList.isEmpty) {
      await Get.find<CartController>().getCartDataOnline();
    }
    if(Get.find<CartController>().cartList.isNotEmpty){
      if (kDebugMode) {
        print('----cart item : ${Get.find<CartController>().cartList[0].toJson()}');
      }
      if(Get.find<CartController>().addCutlery){
        Get.find<CartController>().updateCutlery(willUpdate: false);
      }
      if(Get.find<CartController>().needExtraPackage){
        Get.find<CartController>().toggleExtraPackage(willUpdate: false);
      }
      print('====here ====1 calling====');
      Get.find<CartController>().setAvailableIndex(-1, willUpdate: false);
      Get.find<StoreController>().getCartStoreSuggestedItemList(Get.find<CartController>().cartList[0].item!.storeId);
      Get.find<StoreController>().getStoreDetails(Store(id: Get.find<CartController>().cartList[0].item!.storeId, name: null), false, fromCart: true);
      Get.find<CartController>().calculationCart();
      showReferAndEarnSnackBar();
    }
  }

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: CustomAppBar(title: 'my_cart'.tr, backButton: (ResponsiveHelper.isDesktop(context) || !widget.fromNav)),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<StoreController>(builder: (storeController) {
        return GetBuilder<CartController>(builder: (cartController) {
          final List<CartModel?>? _cartList = cartController.cartList;
          double price = _calculatePrice(store: storeController.store, cartList: _cartList);
          double addOns = _calculateAddonsPrice(store: storeController.store, cartList: _cartList);
          double variations = _calculateVariationPrice(store: storeController.store, cartList: _cartList, calculateWithoutDiscount: true);
          double? discount = _calculateDiscount(
            store: storeController.store, cartList: _cartList, price: price, addOns: addOns,
          );
          double couponDiscount = PriceConverter.toFixed(Get.find<CouponController>().discount!);

          double subTotal = _calculateSubTotal(price: price, addOns: addOns, variations: variations, cartList: _cartList);

          double referralDiscount = _calculateReferralDiscount(subTotal, discount, couponDiscount);

          double orderAmount = _calculateOrderAmount(
            price: price, variations: variations, discount: discount, addOns: addOns,
            couponDiscount: couponDiscount, cartList: _cartList, referralDiscount: referralDiscount,
          );
          return cartController.cartList.isNotEmpty ? Column(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: cartController.cartList.length < (storeController.store?.minimumOrderQty ?? 1)?25:0,
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: 3),
              color: Theme.of(context).secondaryHeaderColor,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: RichText(
                  text: TextSpan(
                    style: robotoMedium.copyWith(color: Colors.white),
                    children: [
                      TextSpan(text: '${'minimum_order_qty_is'.tr} ${storeController.store?.minimumOrderQty ?? 1} , '),
                      TextSpan(text: 'remaining'.tr),
                      TextSpan(text: ' ${(storeController.store?.minimumOrderQty ?? 1) - cartController.cartList.length} '),
                    ]
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: orderAmount < (storeController.store?.minimumOrder ?? 0)?25:0,
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: 3),
              color: Theme.of(context).secondaryHeaderColor,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: RichText(
                  text: TextSpan(
                    style: robotoMedium.copyWith(color: Colors.white),
                    children: [
                      TextSpan(text: '${'minimum_order_amount_is'.tr} ${storeController.store?.minimumOrder ?? 0} , '),
                      TextSpan(text: 'remaining'.tr),
                      TextSpan(text: ' ${(storeController.store?.minimumOrder ?? 0) - orderAmount} '),
                    
                    ]
                  ),
                ),
              ),
            ),
            Expanded(
              child: ExpandableBottomSheet(
                key: key,
                persistentHeader: isDesktop ? const SizedBox() : InkWell(
                  onTap: (){
                    if(cartController.isExpanded){
                      cartController.setExpanded(false);
                      setState(() {
                        key.currentState!.contract();
                      });

                    } else {
                      cartController.setExpanded(true);
                      setState(() {
                        key.currentState!.expand();
                      });
                    }
                  },
                  child: Container(
                    color: Theme.of(context).cardColor,
                    child: Container(
                      constraints: const BoxConstraints.expand(height: 30),
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                      ),
                      child: Icon(Icons.drag_handle, color: Theme.of(context).hintColor, size: 25),
                    ),
                  ),
                ),

                background: Column(children: [

                  WebScreenTitleWidget(title: 'cart_list'.tr),

                   Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.only(
                        top: Dimensions.paddingSizeSmall,
                      ) : EdgeInsets.zero,
                      child: FooterView(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: Column(children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ResponsiveHelper.isDesktop(context) ? WebCardItemsWidget(cartList: cartController.cartList) :
                                Expanded(
                                  flex: 7,
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                    WebConstrainedBox(
                                      dataLength: cartController.cartList.length, minLength: 5, minHeight: 0.6,
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        ListView.builder(
                                          physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: cartController.cartList.length,
                                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                                          itemBuilder: (context, index) {
                                            return CartItemWidget(cart: cartController.cartList[index], cartIndex: index, addOns: cartController.addOnsList[index], isAvailable: cartController.availableList[index]);
                                          },
                                        ),

                                        const Divider(thickness: 0.5, height: 5),

                                        Padding(
                                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                                          child: TextButton.icon(
                                            onPressed: (){
                                              cartController.forcefullySetModule(cartController.cartList[0].item!.moduleId!);
                                              Get.toNamed(
                                                RouteHelper.getStoreRoute(id: cartController.cartList[0].item!.storeId, page: 'item'),
                                                arguments: StoreScreen(store: Store(id: cartController.cartList[0].item!.storeId), fromModule: false),
                                              );
                                            },
                                            icon: Icon(Icons.add_circle_outline_sharp, color: Theme.of(context).primaryColor),
                                            label: Text('add_more_items'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault)),
                                          ),
                                        ),

                                        ExtraPackagingWidget(cartController: cartController),

                                        !ResponsiveHelper.isDesktop(context) ? suggestedItemView(cartController.cartList) : const SizedBox(),

                                      ]),
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeSmall),

                                    !ResponsiveHelper.isDesktop(context) ? pricingView(cartController, cartController.cartList[0].item!,orderAmount) : const SizedBox(),

                                  ]),
                                ),
                                ResponsiveHelper.isDesktop(context) ? const SizedBox(width: Dimensions.paddingSizeSmall) : const SizedBox(),

                                ResponsiveHelper.isDesktop(context) ? Expanded(flex: 4, child: pricingView(cartController, cartController.cartList[0].item!,orderAmount)) : const SizedBox(),
                              ],
                            ),

                            ResponsiveHelper.isDesktop(context) ? WebSuggestedItemViewWidget(cartList: cartController.cartList) : const SizedBox(),
                          ]),
                        ),
                      ),
                    ),
                  ),

                ]),

                expandableContent: isDesktop ? const SizedBox() : Container(
                  width: context.width,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                  ),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.only(
                        left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusDefault), topRight: Radius.circular(Dimensions.radiusDefault)),
                      ),
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('item_price'.tr, style: robotoRegular),
                          PriceConverter.convertAnimationPrice(cartController.itemPrice, textStyle: robotoRegular),
                        ]),
                        SizedBox(height: cartController.variationPrice > 0 ? Dimensions.paddingSizeSmall : 0),

                        cartController.variationPrice > 0 ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('variations'.tr, style: robotoRegular),
                            Text('(+) ${PriceConverter.convertPrice(cartController.variationPrice)}', style: robotoRegular, textDirection: TextDirection.ltr),
                          ],
                        ) : const SizedBox(),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('discount'.tr, style: robotoRegular),
                          storeController.store != null ? Row(children: [
                            Text('(-)', style: robotoRegular),
                            PriceConverter.convertAnimationPrice(cartController.itemDiscountPrice, textStyle: robotoRegular),
                          ]) : Text('calculating'.tr, style: robotoRegular),
                        ]),
                        SizedBox(height: Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? Dimensions.paddingSizeSmall : 0),

                        Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('addons'.tr, style: robotoRegular),
                            Row(children: [
                              Text('(+)', style: robotoRegular),
                              PriceConverter.convertAnimationPrice(cartController.addOns, textStyle: robotoRegular),
                            ]),
                          ],
                        ) : const SizedBox(),

                      ]),
                    ),

                  ]),
                ),

              ),
            ),

            ResponsiveHelper.isDesktop(context) ? const SizedBox.shrink() : CheckoutButton(cartController: cartController, availableList: cartController.availableList,orderAmount: orderAmount),

          ]) : const NoDataScreen(isCart: true, text: '', showFooter: true);
        });
      }),
    );
  }

    double _calculatePrice({required Store? store, required List<CartModel?>? cartList}) {
    double price = 0;
    if(cartList != null) {
      for (var cartModel in cartList) {
        if(Get.find<SplashController>().getModuleConfig(cartModel!.item!.moduleType).newVariation!){
          price = price + (cartModel.item!.price! * cartModel.quantity!);
        } else {
          price = _calculateVariationPrice(store: store, cartList: cartList);
        }
      }
    }
    return PriceConverter.toFixed(price);
  }

  double _calculateAddonsPrice({required Store? store, required List<CartModel?>? cartList}) {
    double addOns = 0;
    if(store != null && cartList != null) {
      for (var cartModel in cartList) {
        List<AddOns> addOnList = [];
        for (var addOnId in cartModel!.addOnIds!) {
          for (AddOns addOns in cartModel.item!.addOns!) {
            if (addOns.id == addOnId.id) {
              addOnList.add(addOns);
              break;
            }
          }
        }
        for (int index = 0; index < addOnList.length; index++) {
          addOns = addOns + (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
        }
      }
    }
    return PriceConverter.toFixed(addOns);
  }

  double _calculateVariationPrice({required Store? store, required List<CartModel?>? cartList, bool calculateDiscount = false, bool calculateWithoutDiscount = false}) {
    double variationPrice = 0;
    double variationDiscount = 0;
    if(store != null && cartList != null) {
      for (var cartModel in cartList) {
        double? discount = cartModel!.item!.storeDiscount == 0 ? cartModel.item!.discount : cartModel.item!.storeDiscount;
        String? discountType = cartModel.item!.storeDiscount == 0 ? cartModel.item!.discountType : 'percent';

        if(Get.find<SplashController>().getModuleConfig(cartModel.item!.moduleType).newVariation!) {
          for(int index = 0; index< cartModel.item!.foodVariations!.length; index++) {
            for(int i=0; i<cartModel.item!.foodVariations![index].variationValues!.length; i++) {
              if(cartModel.foodVariations![index][i]!) {
                variationPrice += (PriceConverter.convertWithDiscount(cartModel.item!.foodVariations![index].variationValues![i].optionPrice!, discount, discountType, isFoodVariation: true)! * cartModel.quantity!);
                variationDiscount += (cartModel.item!.foodVariations![index].variationValues![i].optionPrice! * cartModel.quantity!);
              }
            }
          }
        } else {

          String variationType = '';
          for(int i=0; i<cartModel.variation!.length; i++) {
            variationType = cartModel.variation![i].type!;
          }

          if(cartModel.item!.variations!.isNotEmpty) {
            for (Variation variation in cartModel.item!.variations!) {
              if (variation.type == variationType) {
                variationPrice += (variation.price! * cartModel.quantity!);
                break;
              }
            }
          } else {
            variationDiscount += (PriceConverter.convertWithDiscount(cartModel.item!.price!, discount, discountType)! * cartModel.quantity!);
            variationPrice += (cartModel.item!.price! * cartModel.quantity!);
          }

        }
      }
    }
    if(calculateDiscount) {
      return (variationDiscount - variationPrice);
    } else if(calculateWithoutDiscount) {
      return variationDiscount;
    } else {
      return variationPrice;
    }
  }

  double _calculateDiscount({required Store? store, required List<CartModel?>? cartList, required double price, required double addOns}) {
    double discount = 0;
    if (store != null && cartList != null) {
      for (var cartModel in cartList) {
        double? dis = (store.discount != null
            && DateConverter.isAvailable(store.discount!.startTime, store.discount!.endTime))
            && cartModel!.item!.flashSale != 1
            ? store.discount!.discount : cartModel!.item!.discount;
        String? disType = (store.discount != null
            && DateConverter.isAvailable(store.discount!.startTime, store.discount!.endTime))
            && cartModel.item!.flashSale != 1
            ? 'percent' : cartModel.item!.discountType;
        if(Get.find<SplashController>().getModuleConfig(cartModel.item!.moduleType).newVariation!) {
          double d = ((cartModel.item!.price! - PriceConverter.convertWithDiscount(cartModel.item!.price!, dis, disType)!) * cartModel.quantity!);
          discount = discount + d;
          if(disType == 'percent' && discount != 0) {
            discount = discount + _calculateFoodVariationDiscount(cartModel: cartModel);
          }
        } else {
          String variationType = '';
          double variationPrice = 0;
          double variationWithoutDiscountPrice = 0;
          for(int i=0; i<cartModel.variation!.length; i++) {
            variationType = cartModel.variation![i].type!;
          }
          if(cartModel.item!.variations!.isNotEmpty){
            for (Variation variation in cartModel.item!.variations!) {
              if (variation.type == variationType) {
                variationPrice += (PriceConverter.convertWithDiscount(variation.price!, dis, disType)! * cartModel.quantity!);
                variationWithoutDiscountPrice += (variation.price! * cartModel.quantity!);
                break;
              }
            }
            discount = discount + (variationWithoutDiscountPrice - variationPrice);

          } else {
            double d = ((cartModel.item!.price! - PriceConverter.convertWithDiscount(cartModel.item!.price!, dis, disType)!) * cartModel.quantity!);
            discount = discount + d;
          }

        }
      }
    }

    if (store != null && store.discount != null) {
      if (store.discount!.maxDiscount != 0 && store.discount!.maxDiscount! < discount) {
        discount = store.discount!.maxDiscount!;
      }
      if (store.discount!.minPurchase != 0 && store.discount!.minPurchase! > (price + addOns)) {
        discount = 0;
      }
    }
    return PriceConverter.toFixed(discount);
  }

  double _calculateFoodVariationDiscount({required CartModel? cartModel}) {
    double variationPrice = 0;
    double variationDiscount = 0;
    if(cartModel != null) {
      double? discount = cartModel.item!.storeDiscount == 0 ? cartModel.item!.discount : cartModel.item!.storeDiscount;
      String? discountType = cartModel.item!.storeDiscount == 0 ? cartModel.item!.discountType : 'percent';
      for (int index = 0; index < cartModel.item!.foodVariations!.length; index++) {
        for (int i = 0; i < cartModel.item!.foodVariations![index].variationValues!.length; i++) {
          if (cartModel.foodVariations![index][i]!) {
            variationPrice += (PriceConverter.convertWithDiscount(
                cartModel.item!.foodVariations![index].variationValues![i].optionPrice!, discount, discountType,
                isFoodVariation: true)! * cartModel.quantity!);
            variationDiscount +=
            (cartModel.item!.foodVariations![index].variationValues![i].optionPrice! * cartModel.quantity!);
          }
        }
      }
    }
    return (variationDiscount - variationPrice);
  }

  double _calculateOrderAmount({required double price, required double variations, required double discount, required double addOns, required double couponDiscount, required List<CartModel?>? cartList, required double referralDiscount}) {
    double orderAmount = 0;
    double variationPrice = 0;
    if(cartList != null && cartList.isNotEmpty && Get.find<SplashController>().getModuleConfig(cartList[0]?.item?.moduleType).newVariation!){
      variationPrice = variations;
    }
    orderAmount = (price + variationPrice - discount) + addOns - couponDiscount - referralDiscount;
    return PriceConverter.toFixed(orderAmount);
  }

  double _calculateSubTotal({required double price, required double addOns, required double variations, required List<CartModel?>? cartList}) {
    double subTotal = 0;
    bool isFoodVariation = false;

    if(cartList != null && cartList.isNotEmpty) {
      isFoodVariation = Get.find<SplashController>().getModuleConfig(cartList[0]!.item!.moduleType).newVariation!;
    }
    if(isFoodVariation){
      subTotal = price + addOns + variations;
    } else {
      subTotal = price;
    }

    return subTotal;
  }

  double _calculateOriginalDeliveryCharge({required Store? store, required AddressModel address, required double? distance, required double? extraCharge}) {
    double deliveryCharge = -1;

    Pivot? moduleData;
    ZoneData? zoneData;
    if(store != null) {
      for(ZoneData zData in address.zoneData!) {

        for(Modules m in zData.modules!) {
          if(m.id == Get.find<SplashController>().module!.id && m.pivot!.zoneId == store.zoneId) {
            moduleData = m.pivot;
            break;
          }
        }

        if(zData.id == store.zoneId) {
          zoneData = zData;
        }
      }
    }
    double perKmCharge = 0;
    double minimumCharge = 0;
    double? maximumCharge = 0;
    if(store != null && distance != null && distance != -1 && store.selfDeliverySystem == 1) {
      perKmCharge = store.perKmShippingCharge!;
      minimumCharge = store.minimumShippingCharge!;
      maximumCharge = store.maximumShippingCharge;
    }else if(store != null && distance != null && distance != -1 && moduleData != null) {
      perKmCharge = moduleData.perKmShippingCharge!;
      minimumCharge = moduleData.minimumShippingCharge!;
      maximumCharge = moduleData.maximumShippingCharge;
    }
    if(store != null && distance != null) {
      deliveryCharge = distance * perKmCharge;

      if(deliveryCharge < minimumCharge) {
        deliveryCharge = minimumCharge;
      }else if(maximumCharge != null && deliveryCharge > maximumCharge) {
        deliveryCharge = maximumCharge;
      }
    }

    if(store != null && store.selfDeliverySystem == 0 && extraCharge != null) {
      deliveryCharge = deliveryCharge + extraCharge;
    }

    if(store != null && store.selfDeliverySystem == 0 && zoneData!.increaseDeliveryFeeStatus == 1) {
      deliveryCharge = deliveryCharge + (deliveryCharge * (zoneData.increaseDeliveryFee!/100));
    }

    return deliveryCharge;
  }

  double _calculateDeliveryCharge({required Store? store, required AddressModel address, required double? distance, required double? extraCharge, required double orderAmount, required String orderType}) {
    double deliveryCharge = _calculateOriginalDeliveryCharge(store: store, address: address, distance: distance, extraCharge: extraCharge);

    if (orderType == 'take_away' || (store != null && store.freeDelivery!)
        || (Get.find<SplashController>().configModel!.freeDeliveryOver != null && orderAmount
            >= Get.find<SplashController>().configModel!.freeDeliveryOver!)
        || Get.find<CouponController>().freeDelivery || (AuthHelper.isGuestLoggedIn() && (Get.find<CheckoutController>().guestAddress == null && Get.find<CheckoutController>().orderType != 'take_away'))) {
      deliveryCharge = 0;
    }

    return PriceConverter.toFixed(deliveryCharge);
  }

  double _calculateTotal({
    required double subTotal, required double deliveryCharge, required double discount,
    required double couponDiscount, required bool taxIncluded, required double tax,
    required String orderType, required double tips, required double additionalCharge, required double extraPackagingCharge,
  }) {

    return PriceConverter.toFixed(
        subTotal + deliveryCharge - discount- couponDiscount + (taxIncluded ? 0 : tax)
            + ((orderType != 'take_away' && Get.find<SplashController>().configModel!.dmTipsStatus == 1) ? tips : 0)
            + additionalCharge + extraPackagingCharge
    );
  }

  double _calculateReferralDiscount(double subTotal, double discount, double couponDiscount) {
    double referralDiscount = 0;
    if(Get.find<ProfileController>().userInfoModel != null &&  Get.find<ProfileController>().userInfoModel!.isValidForDiscount!) {
      if (Get.find<ProfileController>().userInfoModel!.discountAmountType! == "percentage") {
        referralDiscount = (Get.find<ProfileController>().userInfoModel!.discountAmount! / 100) * (subTotal - discount - couponDiscount);
      } else {
        referralDiscount = Get.find<ProfileController>().userInfoModel!.discountAmount!;
      }
    }
    return PriceConverter.toFixed(referralDiscount);
  }



  Widget pricingView(CartController cartController, Item item, double orderAmount){
    return Container(
      decoration: ResponsiveHelper.isDesktop(context) ? BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular( ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : Dimensions.radiusSmall),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ) : null,
      child: GetBuilder<StoreController>(
        builder: (storeController) {
          return Column(children: [

            ResponsiveHelper.isDesktop(context) ? ExtraPackagingWidget(cartController: cartController) : const SizedBox(),

            ResponsiveHelper.isDesktop(context) ? Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                child: Text('order_summary'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              ),
            ) : const SizedBox(),

            !ResponsiveHelper.isDesktop(context) && Get.find<SplashController>().getModuleConfig(item.moduleType).newVariation!
            && (storeController.store != null && storeController.store!.cutlery!) ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Image.asset(Images.cutlery, height: 18, width: 18),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('add_cutlery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text('do_not_have_cutlery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                  ]),
                ),

                Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    value: cartController.addCutlery,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: (bool? value) {
                      cartController.updateCutlery();
                    },
                    trackColor: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                )

              ]),
            ) : const SizedBox(),

            ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(color: Theme.of(context).primaryColor, width: 0.5),
              ),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              margin: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall) : EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: (){
                      if(ResponsiveHelper.isDesktop(context)) {
                        Get.dialog(const Dialog(child: NotAvailableBottomSheetWidget()));
                      } else {
                        showModalBottomSheet(
                          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                          builder: (con) => const NotAvailableBottomSheetWidget(),
                        );
                      }
                    },
                    child: Row(children: [
                      Expanded(child: Text('if_any_product_is_not_available'.tr, style: robotoMedium, maxLines: 2, overflow: TextOverflow.ellipsis)),
                      const Icon(Icons.arrow_forward_ios_sharp, size: 18),
                    ]),
                  ),

                  cartController.notAvailableIndex != -1 ? Row(children: [
                    Text(cartController.notAvailableList[cartController.notAvailableIndex].tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),

                    IconButton(
                      onPressed: ()=> cartController.setAvailableIndex(-1),
                      icon: const Icon(Icons.clear, size: 18),
                    )
                  ]) : const SizedBox(),
                ],
              ),
            ),
            ResponsiveHelper.isDesktop(context) ? const SizedBox() : const SizedBox(height: Dimensions.paddingSizeSmall),

            // Total
            ResponsiveHelper.isDesktop(context) ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('item_price'.tr, style: robotoRegular),
                  PriceConverter.convertAnimationPrice(cartController.itemPrice, textStyle: robotoRegular),
                ]),
                SizedBox(height: cartController.variationPrice > 0 ? Dimensions.paddingSizeSmall : 0),

                Get.find<SplashController>().getModuleConfig(item.moduleType).newVariation! && cartController.variationPrice > 0 ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('variations'.tr, style: robotoRegular),
                    Text('(+) ${PriceConverter.convertPrice(cartController.variationPrice)}', style: robotoRegular, textDirection: TextDirection.ltr),
                  ],
                ) : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('discount'.tr, style: robotoRegular),
                  storeController.store != null ? Row(children: [
                    Text('(-)', style: robotoRegular),
                    PriceConverter.convertAnimationPrice(cartController.itemDiscountPrice, textStyle: robotoRegular),
                  ]) : Text('calculating'.tr, style: robotoRegular),
                  // Text('(-) ${PriceConverter.convertPrice(cartController.itemDiscountPrice)}', style: robotoRegular, textDirection: TextDirection.ltr),
                ]),
                SizedBox(height: Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? 10 : 0),

                Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('addons'.tr, style: robotoRegular),
                    Text('(+) ${PriceConverter.convertPrice(cartController.addOns)}', style: robotoRegular, textDirection: TextDirection.ltr),
                  ],
                ) : const SizedBox(),
              ]),
            ) : const SizedBox(),

            ResponsiveHelper.isDesktop(context) ? CheckoutButton(cartController: cartController, availableList: cartController.availableList,orderAmount: orderAmount) : const SizedBox.shrink(),

          ]);
        }
      ),
    );
  }

  Widget suggestedItemView(List<CartModel> cartList){
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      width: double.infinity,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        GetBuilder<StoreController>(builder: (storeController) {
          List<Item>? suggestedItems;
          if(storeController.cartSuggestItemModel != null){
            suggestedItems = [];
            List<int> cartIds = [];
            for (CartModel cartItem in cartList) {
              cartIds.add(cartItem.item!.id!);
            }
            for (Item item in storeController.cartSuggestItemModel!.items!) {
              if(!cartIds.contains(item.id)){
                suggestedItems.add(item);
              }
            }
          }
          return storeController.cartSuggestItemModel != null && suggestedItems!.isNotEmpty ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                child: Text('you_may_also_like'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
              ),

              SizedBox(
                height: ResponsiveHelper.isDesktop(context) ? 160 : 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: suggestedItems.length,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(left: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(vertical: 20) : const EdgeInsets.symmetric(vertical: 10) ,
                      child: Container(
                        width: ResponsiveHelper.isDesktop(context) ? 500 : 300,
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeExtraSmall),
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: ItemWidget(
                          isStore: false, item: suggestedItems![index], fromCartSuggestion: true,
                          store: null, index: index, length: null, isCampaign: false, inStore: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ) : const SizedBox();
        }),
      ]),
    );
  }

  Future<void> showReferAndEarnSnackBar() async {
    String text = 'your_referral_discount_added_on_your_first_order'.tr;
    if(Get.find<ProfileController>().userInfoModel != null &&  Get.find<ProfileController>().userInfoModel!.isValidForDiscount!) {
      showCustomSnackBar(text, isError: false);
    }
  }

}

class CheckoutButton extends StatelessWidget {
  final CartController cartController;
  final double orderAmount;
  final List<bool> availableList;
  const CheckoutButton({super.key, required this.cartController, required this.availableList, required this.orderAmount});

  @override
  Widget build(BuildContext context) {
    double percentage = 0;

    return Container(
      width: Dimensions.webMaxWidth,
      padding:  const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(ResponsiveHelper.isDesktop(context) ? Dimensions.radiusDefault : 0),
      ),
      child: GetBuilder<StoreController>(
        builder: (storeController) {
          if(Get.find<StoreController>().store != null && !Get.find<StoreController>().store!.freeDelivery! && Get.find<SplashController>().configModel!.freeDeliveryOver != null){
            percentage = cartController.subTotal/Get.find<SplashController>().configModel!.freeDeliveryOver!;
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              (storeController.store != null && !storeController.store!.freeDelivery! && Get.find<SplashController>().configModel!.freeDeliveryOver != null && percentage < 1)
              ? Column(children: [
                  Row(children: [
                    Image.asset(Images.percentTag, height: 20, width: 20),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text(
                      PriceConverter.convertPrice(Get.find<SplashController>().configModel!.freeDeliveryOver! - cartController.subTotal),
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                    Text('more_for_free_delivery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                  ]),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                LinearProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  value: percentage,
                ),
              ]) : const SizedBox(),

              ResponsiveHelper.isDesktop(context) ? const Divider(height: 1) : const SizedBox(),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('subtotal'.tr, style: robotoMedium.copyWith(color:  ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).primaryColor)),
                    PriceConverter.convertAnimationPrice(cartController.subTotal, textStyle: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
                    // Text(
                    //   PriceConverter.convertPrice(cartController.subTotal),
                    //   style: robotoMedium.copyWith(color: ResponsiveHelper.isDesktop(context) ? Theme.of(context).textTheme.bodyLarge!.color : Theme.of(context).primaryColor), textDirection: TextDirection.ltr,
                    // ),
                  ],
                ),
              ),

              ResponsiveHelper.isDesktop(context) && Get.find<SplashController>().getModuleConfig(cartController.cartList[0].item!.moduleType).newVariation!
              && (storeController.store != null && storeController.store!.cutlery!) ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Image.asset(Images.cutlery, height: 18, width: 18),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('add_cutlery'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Text('do_not_have_cutlery'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                    ]),
                  ),

                  Transform.scale(
                    scale: 0.7,
                    child: CupertinoSwitch(
                      value: cartController.addCutlery,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (bool? value) {
                        cartController.updateCutlery();
                      },
                      trackColor: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                  )
                ]),
              ) : const SizedBox(),
              ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

              !ResponsiveHelper.isDesktop(context) ? const SizedBox() :
              Container(
                width: Dimensions.webMaxWidth,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: Theme.of(context).primaryColor, width: 0.5)),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                //margin: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall) : EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: (){
                          showModalBottomSheet(
                            context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                            builder: (con) => const NotAvailableBottomSheetWidget(),
                          );
                      },
                      child: Row(children: [
                        Expanded(child: Text('if_any_product_is_not_available'.tr, style: robotoMedium, maxLines: 2, overflow: TextOverflow.ellipsis)),
                        const Icon(Icons.keyboard_arrow_down, size: 18),
                      ]),
                    ),

                    cartController.notAvailableIndex != -1 ? Row(children: [
                      Text(cartController.notAvailableList[cartController.notAvailableIndex].tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),

                      IconButton(
                        onPressed: ()=> cartController.setAvailableIndex(-1),
                        icon: const Icon(Icons.clear, size: 18),
                      )
                    ]) : const SizedBox(),
                  ],
                ),
              ),
              ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),

              SafeArea(
                child: CustomButton(
                  buttonText: 'proceed_to_checkout'.tr,
                  fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : Dimensions.fontSizeLarge,
                  isBold:  ResponsiveHelper.isDesktop(context) ? false : true,
                  radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSmall : Dimensions.radiusDefault,
                  onPressed: () {
                    print('====fff===> ${cartController.notAvailableIndex}');
                  if(!cartController.cartList.first.item!.scheduleOrder! && availableList.contains(false)) {
                    showCustomSnackBar('one_or_more_product_unavailable'.tr);
                  }else if(orderAmount < storeController.store!.minimumOrder!){
                    showCustomSnackBar('${'minimum_order_amount_is'.tr} ${storeController.store!.minimumOrder}');
                  }else if(cartController.cartList.length < storeController.store!.minimumOrderQty!){
                    showCustomSnackBar('${'minimum_order_qty_is'.tr} ${storeController.store!.minimumOrderQty}');
                  }
                  /*else if(AuthHelper.isGuestLoggedIn() && !Get.find<SplashController>().configModel!.guestCheckoutStatus!) {
                    showCustomSnackBar('currently_your_zone_have_no_permission_to_place_any_order'.tr);
                  }*/ else {
                    if(Get.find<SplashController>().module == null) {
                      int i = 0;
                      for(i = 0; i < Get.find<SplashController>().moduleList!.length; i++){
                        if(cartController.cartList[0].item!.moduleId == Get.find<SplashController>().moduleList![i].id){
                          break;
                        }
                      }
                      Get.find<SplashController>().setModule(Get.find<SplashController>().moduleList![i]);
                      HomeScreen.loadData(true);
                    }
                    Get.find<CouponController>().removeCouponData(false);

                    Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
                  }
                }),
              ),
            ],
          );
        }
      ),
    );
  }
}
