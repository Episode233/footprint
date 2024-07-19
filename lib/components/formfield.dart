import 'package:flutter/material.dart';

import '../constants.dart';

class MyFormField {
  InputDecoration getTextFieldDecoration(
      String hintText, BuildContext context, IconData icon) {
    return InputDecoration(
      hintText: hintText,
      border: InputBorder.none,
      fillColor: Theme.of(context).colorScheme.background,
      filled: true,
      enabledBorder: const OutlineInputBorder(
          /*边角*/
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          ),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        /*边角*/
        borderRadius: const BorderRadius.all(
          Radius.circular(50),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1, //边线宽度为2
        ),
      ),
      errorBorder: OutlineInputBorder(
        /*边角*/
        borderRadius: const BorderRadius.all(
          Radius.circular(50),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
          width: 1, //边线宽度为2
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        /*边角*/
        borderRadius: const BorderRadius.all(
          Radius.circular(50),
        ),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.errorContainer,
          width: 1, //边线宽度为2
        ),
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Icon(icon),
      ),
    );
  }
}
