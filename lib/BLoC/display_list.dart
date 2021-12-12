import 'package:flutter/material.dart';

class DisplayListBloc {
  final ScrollController scrollController;

  DisplayListBloc(this.scrollController);

  void scrollTo(double position) {
    scrollController.animateTo(
      position,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
    );
  }

  void scrollTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  ///
  /// Back top button BLoC
  ///
  final ValueNotifier<bool> _btbVisibleNotifier = ValueNotifier(false);

  ValueNotifier<bool> get backTopButtonVisibilityNotifier =>
      _btbVisibleNotifier;

  Function get showBackTopButton => () {
        _btbVisibleNotifier.value = true;
      };

  Function get hideBackTopButton => () {
        _btbVisibleNotifier.value = false;
      };
}
