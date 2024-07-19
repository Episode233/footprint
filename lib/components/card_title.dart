import 'package:flutter/material.dart';

class CardTitle extends StatelessWidget {
  const CardTitle(this.title, {Key? key, this.watchMore = true})
      : super(key: key);
  final String title;
  final bool watchMore;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                  fontWeight: FontWeight.bold),
            ),
            watchMore
                ? SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        Text("查看更多",
                            style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .fontSize,
                              color: Theme.of(context).colorScheme.outline,
                            )),
                        Icon(
                          Icons.keyboard_arrow_right,
                          color: Theme.of(context).colorScheme.outline,
                        )
                      ],
                    ),
                  )
                : const SizedBox()
          ],
        ))
      ],
    );
  }
}
