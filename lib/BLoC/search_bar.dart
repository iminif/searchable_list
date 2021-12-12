import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../filter.dart';
import '../searcher.dart';

class SearchBarBloc<T> with ChangeNotifier {
  SearchBarBloc({required this.searcher, Filter<T, String>? filter}) {
    ///
    /// Configure filter
    ///
    if (T == String) {
      this.filter = _defaultFilter;
    } else if (filter != null) {
      this.filter = filter;
    } else {
      throw Exception(
        'A filter function is required since the filter type is not String!',
      );
    }

    _searchQueryCtrl.stream.listen((String query) {
      final List<T> filtered = searcher.data.where((T test) {
        return filter!(test, query);
      }).toList();

      searcher.onDataFiltered(filtered);
    });
  }

  final _searchQueryCtrl = BehaviorSubject<String>();
  final Searcher<T> searcher;
  Filter<T, String>? filter;
  static bool _visible = false;
  Size _searchBarSize = const Size(0, 0);

  Size get searchBarSize => _searchBarSize;
  final ValueNotifier<double> _topDistanceNotifier = ValueNotifier(0.0);
  final ValueNotifier<bool> _isInSearchModeNotifier = ValueNotifier(false);

  ValueNotifier<double> get topDistanceNotifier => _topDistanceNotifier;

  ValueNotifier<bool> get isInSearchModeNotifier => _isInSearchModeNotifier;

  Stream<String> get searchQueryStream => _searchQueryCtrl.stream;

  Function(String) get onSearchQueryChanged => (String input) {};

  Function(String) get onSearchQuerySubmitted => _searchQueryCtrl.add;

  Function get onClearSearchQuery => () => onSearchQuerySubmitted('');

  Function(bool) get onSearchModeChange => (isInSearchMode) {
        _isInSearchModeNotifier.value = isInSearchMode;
      };

  bool get isInSearchMode => _isInSearchModeNotifier.value;

  void toggle(bool visible) {
    if (visible != _visible) {
      _updateTopDistance(visible ? 0 : -_searchBarSize.height);
    }
    _visible = visible;
  }

  void onSizeChange(Size size) {
    if (size != _searchBarSize && size.height > 0) {
      _searchBarSize = size;
      _updateTopDistance(-_searchBarSize.height);
    }
  }

  void _updateTopDistance(double distance) {
    _topDistanceNotifier.value = distance;
  }

  Filter<T, String> get _defaultFilter =>
      Filters.startsWith as Filter<T, String>;

  @override
  void dispose() {
    _searchQueryCtrl.close();
    super.dispose();
  }
}
