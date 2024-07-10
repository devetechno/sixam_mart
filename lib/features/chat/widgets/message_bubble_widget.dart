import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart/features/chat/domain/models/chat_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/chat/widgets/image_dialog_widget.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Message message;
  final User? user;
  final String userType;
  const MessageBubbleWidget({super.key, required this.message, required this.user, required this.userType});

  @override
  Widget build(BuildContext context) {
    bool isReply = message.senderId != Get.find<ProfileController>().userInfoModel!.userInfo!.id;

    return (isReply) ? Container(
      margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: CustomImage(
              fit: BoxFit.cover, width: 40, height: 40,
              image: '${user != null ? user!.imageFullUrl : ''}',
            ),
          ),
          const SizedBox(width: 10),

          Flexible(
            child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

              if(message.message != null) Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(.10),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(Dimensions.radiusDefault),
                      topRight: Radius.circular(Dimensions.radiusDefault),
                      bottomLeft: Radius.circular(Dimensions.radiusDefault),
                    ),
                  ),
                  padding: EdgeInsets.all(message.message != null ? Dimensions.paddingSizeDefault : 0),
                  child: Text(message.message ?? '', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color, fontSize: Dimensions.fontSizeSmall)),
                ),
              ),
              const SizedBox(height: 8.0),

              (message.fileFullUrl != null && message.fileFullUrl!.isNotEmpty) ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1,
                    crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 5,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: message.fileFullUrl!.length,
                  itemBuilder: (BuildContext context, index) {
                    return  message.fileFullUrl!.isNotEmpty ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        onTap: () => showDialog(context: context, builder: (context) {
                          return ImageDialogWidget(
                            imageUrl: message.fileFullUrl![index],
                          );
                        }),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                          child: CustomImage(
                            height: 100, width: 100, fit: BoxFit.cover,
                            image: message.fileFullUrl![index],
                          ),
                        ),
                      ),
                    ) : const SizedBox();

                  }) : const SizedBox(),

            ]),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),

        Text(
          DateConverter.convertTodayYesterdayFormat(message.createdAt!),
          style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
        ),
      ]),
    ) : Container(
      padding: const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeDefault),
      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
      child: GetBuilder<ProfileController>(builder: (profileController) {

        return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [


          Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [

            Flexible(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [

                (message.message != null && message.message!.isNotEmpty) ? Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(Dimensions.radiusDefault),
                        bottomRight: Radius.circular(Dimensions.radiusDefault),
                        bottomLeft: Radius.circular(Dimensions.radiusDefault),
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(message.message != null ? Dimensions.paddingSizeDefault : 0),
                      child: Text(message.message ?? '', style: robotoRegular.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeSmall),),
                    ),
                  ),
                ) : const SizedBox(),

                (message.fileFullUrl != null && message.fileFullUrl!.isNotEmpty) ? Directionality(
                  textDirection: TextDirection.rtl,
                  child: GridView.builder(
                      reverse: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1,
                        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 5,
                      ),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: message.fileFullUrl!.length,
                      itemBuilder: (BuildContext context, index){
                        return  message.fileFullUrl!.isNotEmpty ?
                        InkWell(
                          onTap: () => showDialog(context: context, builder: (context) {
                            return ImageDialogWidget(
                              imageUrl: message.fileFullUrl![index],
                            );
                          }),
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: Dimensions.paddingSizeSmall , right:  0,
                                top: (message.message != null && message.message!.isNotEmpty) ? Dimensions.paddingSizeSmall : 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: CustomImage(
                                height: 100, width: 100, fit: BoxFit.cover,
                                image: message.fileFullUrl![index],
                              ),
                            ),
                          ),
                        ) : const SizedBox();
                      }),
                ) : const SizedBox(),
              ]),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: CustomImage(
                fit: BoxFit.cover, width: 40, height: 40,
                image: profileController.userInfoModel != null ? '${profileController.userInfoModel!.imageFullUrl}' : '',
              ),
            ),

          ]),

          Icon(
            message.isSeen == 1 ? Icons.done_all : Icons.check,
            size: 12,
            color: message.isSeen == 1 ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(
            DateConverter.convertTodayYesterdayFormat(message.createdAt!),
            style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

        ]);
      }),
    );
  }
}
