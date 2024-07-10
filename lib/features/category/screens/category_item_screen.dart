import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/cart_widget.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/veg_filter_widget.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/custom_image.dart';
import '../../../util/app_constants.dart';
import 'package:http/http.dart' as http;


class CategoryItemScreen extends StatefulWidget {
  final String? categoryID;
  final String categoryName;
  const CategoryItemScreen({super.key, required this.categoryID, required this.categoryName});

  @override
  CategoryItemScreenState createState() => CategoryItemScreenState();
}

class CategoryItemScreenState extends State<CategoryItemScreen> with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final ScrollController storeScrollController = ScrollController();
  TabController? _tabController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var brand_category_ids = [];
  int index_category = 0;
  int index_brand = -1;
  int pageindex = 0;
  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    Get.find<CategoryController>().getSubCategoryList(widget.categoryID);
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent
          && Get.find<CategoryController>().categoryItemList != null
          && !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().pageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          if (kDebugMode) {
            print('end of the page');
          }
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryItemList(
            Get.find<CategoryController>().subCategoryIndex == 0 ? widget.categoryID
                : Get.find<CategoryController>().subCategoryList![Get.find<CategoryController>().subCategoryIndex].id.toString(),
            Get.find<CategoryController>().offset+1, Get.find<CategoryController>().type, false,'${ brand_category_ids.isEmpty ||  index_brand == -1 ? "" :brand_category_ids[index_brand]['id']}'
          );
        }
      }
    });
    storeScrollController.addListener(() {
      if (storeScrollController.position.pixels == storeScrollController.position.maxScrollExtent
          && Get.find<CategoryController>().categoryStoreList != null
          && !Get.find<CategoryController>().isLoading) {
        int pageSize = (Get.find<CategoryController>().restPageSize! / 10).ceil();
        if (Get.find<CategoryController>().offset < pageSize) {
          if (kDebugMode) {
            print('end of the page');
          }
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryStoreList(
            Get.find<CategoryController>().subCategoryIndex == 0 ? widget.categoryID
                : Get.find<CategoryController>().subCategoryList![Get.find<CategoryController>().subCategoryIndex].id.toString(),
            Get.find<CategoryController>().offset+1, Get.find<CategoryController>().type, false,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (catController) {
      List<Item>? item;
      List<Store>? stores;
      if(catController.isSearching ? catController.searchItemList != null : catController.categoryItemList != null) {
        item = [];
        if (catController.isSearching) {
          item.addAll(catController.searchItemList!);
        } else {
          item.addAll(catController.categoryItemList!);
        }
      }
      if(catController.isSearching ? catController.searchStoreList != null : catController.categoryStoreList != null) {
        stores = [];
        if (catController.isSearching) {
          stores.addAll(catController.searchStoreList!);
        } else {
          stores.addAll(catController.categoryStoreList!);
        }
      }
      getBrandByCategoryList(String? categoryID ) async {
        // '${AppConstants.brandCategoryUri}/$categoryID'
        String url = "${AppConstants.baseUrl}${AppConstants.brandCategoryUri}/$categoryID";
        print("response categoryID1 =========> ${ categoryID }");
        final  response = await http.get(Uri.parse(url));
        print("response.statusCode =========> ${ response.statusCode }");

        if (response.statusCode == 200) {
          var sub_cat = jsonDecode(response.body);
          print("response 2222 =========> ${ sub_cat }");
          if(sub_cat['brands'] == 0){
            brand_category_ids = [];
          }else{
            print("brand_category_ids =========> ${ brand_category_ids }");
            setState(() {
              brand_category_ids = sub_cat['brands'];
            });

          }
          print("response 1111 =========> ${ sub_cat['brands'] }");
        }

      }
      return PopScope(
        canPop: true,
        onPopInvoked: (didPop) async {
          if(catController.isSearching) {
            catController.toggleSearch();
          }else {
            return;
          }
        },
        child: Scaffold(
          appBar: (ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : AppBar(
            title: catController.isSearching ? TextField(
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
              onSubmitted: (String query) {
                catController.searchData(
                  query, catController.subCategoryIndex == 0 ? widget.categoryID
                    : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
                  catController.type,
                );
              }
            ) : Text(widget.categoryName, style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color,
            )),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Theme.of(context).textTheme.bodyLarge!.color,
              onPressed: () {
                if(catController.isSearching) {
                  catController.toggleSearch();
                }else if(pageindex == 1){
                  setState(() {
                    pageindex = 0;
                    brand_category_ids = [];
                  });
                }
                else  {
                  Get.back();
                }
              },
            ),
            backgroundColor: Theme.of(context).cardColor,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () => catController.toggleSearch(),
                icon: Icon(
                  catController.isSearching ? Icons.close_sharp : Icons.search,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              IconButton(
                onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                icon: CartWidget(color: Theme.of(context).textTheme.bodyLarge!.color, size: 25),
              ),

              VegFilterWidget(type: catController.type, fromAppBar: true, onSelected: (String type) {
                if(catController.isSearching) {
                  catController.searchData(
                    catController.subCategoryIndex == 0 ? widget.categoryID
                        : catController.subCategoryList![catController.subCategoryIndex].id.toString(), '1', type,
                  );
                }else {
                  if(catController.isStore) {
                    catController.getCategoryStoreList(
                      catController.subCategoryIndex == 0 ? widget.categoryID
                          : catController.subCategoryList![catController.subCategoryIndex].id.toString(), 1, type, true,
                    );
                  }else {
                    catController.getCategoryItemList(
                      catController.subCategoryIndex == 0 ? widget.categoryID
                          : catController.subCategoryList![catController.subCategoryIndex].id.toString(), 1, type, true,""
                    );
                  }
                }
              }),
            ],
          )),
          endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
          body: Center(child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Column(children: [

              (catController.subCategoryList != null && !catController.isSearching && AppConstants.subcatimg && pageindex ==0 ) ? Center(child: Container(
              //  height: 40,
                width: Dimensions.webMaxWidth,
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                child:
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // number of items in each row
                    mainAxisSpacing:5, // spacing between rows
                    crossAxisSpacing: 0, // spacing between columns
                  ),
                  // physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  // scrollDirection: Axis.vertical,
                  itemCount: catController.subCategoryList!.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          index_category = index;
                          index_brand = -1;
                          pageindex = 1;
                        });

                        // if(index == 0){
                        //   brand_category_ids = [];
                        // }
                        print("sub img ========> ${index}");
                        var subcat = catController.GetsetSubCategoryIndex(index, widget.categoryID);

                        print("sub cat id ========> ${subcat}");
                       // Get.toNamed(RouteHelper.getBrandsItemScreenCat(454, "سسس","$subcat"));
                         catController.setSubCategoryIndex(index, widget.categoryID,"");
                        getBrandByCategoryList(subcat);
                         print("catController.setSubCategory ====> ${catController.GetsetSubCategoryIndex(index, widget.categoryID)}");


                      },
                      child:  Container(
                        //width: 100,
                        //height: 100,
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                        margin: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          color: index == catController.subCategoryIndex ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              // image
                              catController.subCategoryList![index].name != "all".tr? Expanded(
                                //flex: 1,
                                child: CustomImage(
                                  image: '${catController.subCategoryList![index].imageFullUrl}',
                                  //height: 90,
                                   //width: 75,
                                  // fit: BoxFit.cover,
                                ),
                              ) : Container(

                                  //child: Image.asset('assets/image/all_products.png'),
                              ),

                              catController.subCategoryList![index].name != "all".tr? Expanded(
                                flex: 1,
                                child: Text(

                                  catController.subCategoryList![index].name!,
                                  style: index == catController.subCategoryIndex
                                      ? robotoMedium.copyWith(fontSize: Dimensions.paddingSizeSmall, color: Theme.of(context).primaryColor)
                                      : robotoRegular.copyWith(fontSize: Dimensions.paddingSizeSmall),
                                ),
                              ) : const SizedBox(),

                            ]),
                      )
                    );

                  },
                )
              )) : const SizedBox(),

              brand_category_ids.length !=0 ?  Row(
                children: [
                  SizedBox(width: 8,),
                  Container(child: Text("الشركات"),),
                ],
              ): Container(),

              brand_category_ids.length !=0 ?  Center(child: Container(
                height: 100,
                width: Dimensions.webMaxWidth,
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                child: Row(
                  children: [
                    SizedBox(width: 5,),
                    InkWell(
                      onTap: (){
                        catController.setSubCategoryIndex(index_category, widget.categoryID,"");
                        index_brand = -1;
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blue,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(50))
                          ),
                          width: 50, height: 50,child: Text("كل الشركات",textAlign:TextAlign.center,style: TextStyle(color: Colors.blue,fontSize: 12),)),
                    ),
                    SizedBox(width: 5,),
                    Expanded(
                      child: ListView.builder(
                        key: scaffoldKey,
                        scrollDirection: Axis.horizontal,
                        itemCount: brand_category_ids!.length,
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              catController.setSubCategoryIndex(index_category, widget.categoryID,'${brand_category_ids[index]['id']}');
                              index_brand = index;
                            }
                            ,child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                              margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                color: index == index_brand ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                              ),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  child: CustomImage(
                                    image: '${AppConstants.baseUrl}/storage/app/public/brand/${brand_category_ids[index]['image']}',
                                    height: 40, width: 60, fit: BoxFit.cover,
                                  ),
                                ),
                                Text(
                                  '${brand_category_ids[index]['name']}',
                                  style: index == index_brand
                                      ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                                      : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                ),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )): Container(),
              (catController.subCategoryList != null && !catController.isSearching && AppConstants.subcatimg == false ) ? Center(child: Container(
                height: 40,
                width: Dimensions.webMaxWidth,
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                child: ListView.builder(
                  key: scaffoldKey,
                  scrollDirection: Axis.horizontal,
                  itemCount: catController.subCategoryList!.length,
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => catController.setSubCategoryIndex(index, widget.categoryID,""),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                        margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          color: index == catController.subCategoryIndex ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(
                            catController.subCategoryList![index].name!,
                            style: index == catController.subCategoryIndex
                                ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)
                                : robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              )) : const SizedBox(),
              // Center(child: Container(
              //   width: Dimensions.webMaxWidth,
              //   color: Theme.of(context).cardColor,
              //   child: TabBar(
              //     controller: _tabController,
              //     indicatorColor: Theme.of(context).primaryColor,
              //     indicatorWeight: 3,
              //     labelColor: Theme.of(context).primaryColor,
              //     unselectedLabelColor: Theme.of(context).disabledColor,
              //     unselectedLabelStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
              //     labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
              //     tabs: [
              //       Tab(text: 'item'.tr),
              //       Tab(text: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
              //           ? 'restaurants'.tr : 'stores'.tr),
              //     ],
              //   ),
              // )),


              pageindex== 1? Expanded(child: NotificationListener(
                onNotification: (dynamic scrollNotification) {
                  if (scrollNotification is ScrollEndNotification) {
                    if((_tabController!.index == 1 && !catController.isStore) || _tabController!.index == 0 && catController.isStore) {
                      catController.setRestaurant(_tabController!.index == 1);
                      if(catController.isSearching) {
                        catController.searchData(
                          catController.searchText, catController.subCategoryIndex == 0 ? widget.categoryID
                            : catController.subCategoryList![catController.subCategoryIndex].id.toString(), catController.type,
                        );
                      }else {
                        if(_tabController!.index == 1) {
                          catController.getCategoryStoreList(
                            catController.subCategoryIndex == 0 ? widget.categoryID
                                : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
                            1, catController.type, false,
                          );
                        }else {
                          catController.getCategoryItemList(
                            catController.subCategoryIndex == 0 ? widget.categoryID
                                : catController.subCategoryList![catController.subCategoryIndex].id.toString(),
                            1, catController.type, false,'${brand_category_ids[index_brand]['id']}'
                          );
                        }
                      }
                    }
                  }
                  return false;
                },
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SingleChildScrollView(
                      controller: scrollController,
                      child: ItemsView(
                        isStore: false, items: item, stores: null, noDataText: 'no_category_item_found'.tr,
                      ),
                    ),
                    SingleChildScrollView(
                      controller: storeScrollController,
                      child: ItemsView(
                        isStore: true, items: null, stores: stores,
                        noDataText: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                            ? 'no_category_restaurant_found'.tr : 'no_category_store_found'.tr,
                      ),
                    ),
                  ],
                ),
              )) : SizedBox(),

              catController.isLoading ? Center(child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
              )) : const SizedBox(),

            ]),
          )),
        ),
      );
    });
  }
}
