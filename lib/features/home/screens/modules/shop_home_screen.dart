import 'package:flutter/material.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/features/flash_sale/widgets/flash_sale_view_widget.dart';
import 'package:sixam_mart/features/home/widgets/bad_weather_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:sixam_mart/features/home/widgets/views/most_popular_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/visit_again_view.dart';
import 'package:sixam_mart/features/home/widgets/banner_view.dart';

import '../../widgets/views/category_view_grid.dart';

class ShopHomeScreen extends StatelessWidget {
  const ShopHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Images.shopModuleBannerBg),
            fit: BoxFit.cover,
          ),
        ),
        child: const Column(
          children: [
            BadWeatherWidget(),

            BannerView(isFeatured: false),
            SizedBox(height: 12),
          ],
        ),
      ),

      //const CategoryView(),
      const CategoryViewGrid(),
      // isLoggedIn ? const VisitAgainView() : const SizedBox(),
      const FlashSaleViewWidget(),
      const JustForYouView(),
      const MostPopularItemView(isFood: false, isShop: true),
      // const MiddleSectionBannerView(),
      // const PopularStoreView(),
      // const BrandsViewWidget(),
      // const SpecialOfferView(isFood: false, isShop: true),
      // const ProductWithCategoriesView(fromShop: true),
      // const FeaturedCategoriesView(),
      // const StoreWiseBannerView(),
      // const ItemThatYouLoveView(forShop: true,),
      // const NewOnMartView(isShop: true,isPharmacy: false),
      // const PromotionalBannerView(),
    ]);
  }
}
