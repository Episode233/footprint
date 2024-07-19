import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/constants.dart';

enum CanUsePlatform {
  mobile,
  desktop,
  web,
}

class SelectiveCardWidget extends StatelessWidget {
  SelectiveCardWidget(this.link, this.name, this.author, this.icon,
      this.introduce, this.canUsePlatform,
      {super.key});
  String link;
  String author;
  String name;
  IconData icon;
  String introduce;
  List<CanUsePlatform> canUsePlatform;
  @override
  Widget build(BuildContext context) {
    List<Widget> canUseIcons = [];
    for (var i in canUsePlatform) {
      if (i == CanUsePlatform.web) {
        canUseIcons.add(Icon(Icons.web_rounded,
            size: Theme.of(context).textTheme.bodyMedium!.fontSize,
            color: Theme.of(context).colorScheme.secondary));
      }
      if (i == CanUsePlatform.mobile) {
        canUseIcons.add(Icon(Icons.phone_android_rounded,
            size: Theme.of(context).textTheme.bodyMedium!.fontSize,
            color: Theme.of(context).colorScheme.secondary));
      }
      if (i == CanUsePlatform.desktop) {
        canUseIcons.add(Icon(Icons.desktop_windows_rounded,
            size: Theme.of(context).textTheme.bodyMedium!.fontSize,
            color: Theme.of(context).colorScheme.secondary));
      }
    }
    return InkWell(
      borderRadius:
          const BorderRadius.all(Radius.circular(defaultBorderRadius)),
      onTap: () => handlerTap(),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding, vertical: defaultPadding / 1.5),
        decoration: BoxDecoration(
          borderRadius:
              const BorderRadius.all(Radius.circular(defaultBorderRadius)),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon,
                    size: 50, color: Theme.of(context).colorScheme.primary),
                Text(
                  '开发者:$author',
                  style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                Row(
                  children: [
                    Text(
                      '支持:',
                      style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize:
                              Theme.of(context).textTheme.bodySmall!.fontSize,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    ...canUseIcons
                  ],
                ),
              ],
            ),
            const SizedBox(
              width: defaultPadding,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize:
                              Theme.of(context).textTheme.titleMedium!.fontSize,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary)),
                  Text(
                    introduce,
                    maxLines: 3,
                    style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium!.fontSize,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  handlerTap() {
    for (var i in canUsePlatform) {
      if (i == CanUsePlatform.web && GetPlatform.isWeb) {
        Get.toNamed(link);
      } else if (i == CanUsePlatform.mobile && GetPlatform.isMobile) {
        Get.toNamed(link);
      } else if (i == CanUsePlatform.desktop && GetPlatform.isDesktop) {
        Get.toNamed(link);
      } else {
        Get.snackbar('提示', '这个功能不适用于你的设备');
      }
    }
  }
}
