import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vcommunity_flutter/constants.dart';

class AuthorCard extends StatelessWidget {
  const AuthorCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            '开发者',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            'episode',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: defaultPadding / 2,
          ),
          Text(
            '联系我',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            '邮箱:admin@episode.icu',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: defaultPadding / 2,
          ),
          Text(
            '本工具仅供跳过打开微信公众号，任何数据仅存储在本地，任何数据都不会分享给第三方或服务器',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ]),
      ),
    );
  }
}
