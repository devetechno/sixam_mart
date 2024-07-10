import 'package:get/get.dart';
import 'package:sixam_mart/features/business/domain/models/business_plan_body.dart';
import 'package:sixam_mart/features/business/domain/models/package_model.dart';
import 'package:sixam_mart/features/business/domain/services/business_service_interface.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class BusinessController extends GetxController implements GetxService {
  final BusinessServiceInterface businessServiceInterface;
  BusinessController({required this.businessServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _businessIndex = 0;
  int get businessIndex => _businessIndex;

  int _activeSubscriptionIndex = 0;
  int get activeSubscriptionIndex => _activeSubscriptionIndex;

  String _businessPlanStatus = 'business';
  String get businessPlanStatus => _businessPlanStatus;

  int _paymentIndex = 0;
  int get paymentIndex => _paymentIndex;

  // bool _isFirstTime = true;
  // bool get isFirstTime => _isFirstTime;

  String? _digitalPaymentName;
  String? get digitalPaymentName => _digitalPaymentName;

  PackageModel? _packageModel;
  PackageModel? get packageModel => _packageModel;

  // void changeFirstTimeStatus() {
  //   _isFirstTime = !_isFirstTime;
  // }

  void resetBusiness(){
    _businessIndex = Get.find<SplashController>().configModel!.commissionBusinessModel == 0 ? 1 : 0;
    _activeSubscriptionIndex = 0;
    _businessPlanStatus = 'business';
    // _isFirstTime = true;
    _paymentIndex = Get.find<SplashController>().configModel!.subscriptionFreeTrialStatus??false ? 1 : 0;
  }

  Future<void> getPackageList({bool isUpdate = true}) async {
    _packageModel = await businessServiceInterface.getPackageList();
    if(isUpdate) {
      update();
    }
  }

  void changeDigitalPaymentName(String? name, {bool canUpdate = true}){
    _digitalPaymentName = name;
    if(canUpdate) {
      update();
    }
  }

  void setPaymentIndex(int index){
    _paymentIndex = index;
    update();
  }

  void setBusiness(int business){
    _activeSubscriptionIndex = 0;
    _businessIndex = business;
    update();
  }

  void setBusinessStatus(String status){
    _businessPlanStatus = status;
    update();
  }

  void selectSubscriptionCard(int index){
    _activeSubscriptionIndex = index;
    update();
  }

  Future<void> submitBusinessPlan({required int storeId, required int? packageId})async {
    _isLoading = true;
    update();

    if(packageId != null) {
      _businessPlanStatus = 'payment';
      _businessPlanStatus = await businessServiceInterface.processesBusinessPlan(_businessPlanStatus, _paymentIndex, storeId, _packageModel, _digitalPaymentName, packageId);
    } else {
      String businessPlan = 'commission';
      await businessServiceInterface.setUpBusinessPlan(BusinessPlanBody(businessPlan: businessPlan, storeId: storeId.toString()), _digitalPaymentName, businessPlanStatus, storeId);
    }

    _isLoading = false;
    update();
  }

}