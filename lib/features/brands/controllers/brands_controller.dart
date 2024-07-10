import 'package:get/get.dart';
import 'package:sixam_mart/features/brands/domain/models/brands_model.dart';
import 'package:sixam_mart/features/brands/domain/services/brands_service_interface.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';

class BrandsController extends GetxController implements GetxService {
  final BrandsServiceInterface brandsServiceInterface;
  BrandsController({required this.brandsServiceInterface});

  List<BrandModel>? _brandList;
  List<BrandModel>? get brandList => _brandList;

  ItemModel? _brandItemModel;
  ItemModel? get brandItemModel => _brandItemModel;

  Future<void> getBrandList() async {
    List<BrandModel>? brandList = await brandsServiceInterface.getBrandList();
    if (brandList != null) {
      _brandList = [];
      _brandList!.addAll(brandList);
    }
    update();
  }

  Future<void> getBrandItemList(int brandId, int offset, bool notify) async {
    if(offset == 1 || _brandItemModel == null) {
      _brandItemModel = null;
      if(notify) {
        update();
      }
    }
    ItemModel? brandItemModel = await brandsServiceInterface.getBrandItemList(brandId: brandId, offset: offset);
    if (brandItemModel != null) {
      if (offset == 1) {
        _brandItemModel = brandItemModel;
      }else {
        _brandItemModel!.items!.addAll(brandItemModel.items!);
        _brandItemModel!.totalSize = brandItemModel.totalSize;
        _brandItemModel!.offset = brandItemModel.offset;
      }
    }
    update();
  }
  Future<void> getBrandItemListCat(int brandId, int offset, bool notify, String cat_id) async {
    if(offset == 1 || _brandItemModel == null) {
      _brandItemModel = null;
      if(notify) {
        update();
      }
    }
    ItemModel? brandItemModel = await brandsServiceInterface.getBrandItemList(brandId: brandId, offset: offset,);
    if (brandItemModel != null) {
      if (offset == 1) {
        _brandItemModel = brandItemModel;
      }else {
        _brandItemModel!.items!.addAll(brandItemModel.items!);
        _brandItemModel!.totalSize = brandItemModel.totalSize;
        _brandItemModel!.offset = brandItemModel.offset;
      }
    }
    update();
  }
}