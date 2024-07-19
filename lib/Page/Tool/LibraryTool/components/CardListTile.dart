import 'package:flutter/material.dart';

import '../../../../constants.dart';

class CardListTile extends StatefulWidget {
  CardListTile(this.info, {super.key, this.mode = 0});
  int mode = 0;
  String info;
  @override
  State<CardListTile> createState() => _CardListTileState();
}

class _CardListTileState extends State<CardListTile> {
  @override
  Widget build(BuildContext context) {
    Color primaryColor;
    Color containerColor;
    Widget leftWidget;
    if (widget.mode == 0) {
      primaryColor = Theme.of(context).colorScheme.error;
      containerColor = Theme.of(context).colorScheme.errorContainer;
      leftWidget = Icon(
        Icons.close_rounded,
        color: primaryColor,
      );
    } else if (widget.mode == 1) {
      primaryColor = Theme.of(context).colorScheme.primary;
      containerColor = Theme.of(context).colorScheme.primaryContainer;
      leftWidget = Icon(
        Icons.done_rounded,
        color: primaryColor,
      );
    } else {
      primaryColor = Theme.of(context).colorScheme.tertiary;
      containerColor = Theme.of(context).colorScheme.tertiaryContainer;
      leftWidget = CircularProgressIndicator(
        color: primaryColor,
      );
    }
    return Card(
        color: containerColor,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            children: [
              leftWidget,
              const SizedBox(
                width: defaultPadding,
              ),
              Expanded(
                child: Text(
                  widget.info,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
