import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'bloc/display_list.dart';
import 'bloc/search_bar.dart';
import 'filter.dart';
import 'search_bar.dart';
import 'searcher.dart';

class SearchableList<T> extends StatefulWidget {
  final SearchBar<T> searchBar;
  final Searcher<T> searcher;
  final Filter<T, String> filter;

  final Widget? sliverBody, extra;
  final Widget? Function(BuildContext, int)? itemBuilder;
  final int? itemCount;

  const SearchableList({
    Key? key,
    required this.searchBar,
    required this.searcher,
    required this.filter,
    this.sliverBody,
    this.itemBuilder,
    this.itemCount,
    this.extra,
  }) : super(key: key);

  @override
  _SearchableListState<T> createState() => _SearchableListState<T>();
}

class _SearchableListState<T> extends State<SearchableList<T>> {
  late DisplayListBloc _displayListBloc;
  late SearchBarBloc<T> _searchBarBloc;
  late ScrollController _scrollCtrl;

  static bool _isScrollReachTop = true;
  static double _viewportHeight = 0;

  @override
  Widget build(BuildContext context) {
    _getViewportMetrics(context);

    final List<Widget> slivers = [];

    slivers.add(_containerWithChangingHeight);

    slivers.add(widget.sliverBody ?? _buildSliverList());

    final List<Widget> children = <Widget>[
      CustomScrollView(
        controller: _scrollCtrl,
        slivers: slivers,
      ),
    ];

    children.add(widget.searchBar);

    if (widget.extra != null) {
      children.add(widget.extra!);
    }

    children.add(_backTopButton);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _searchBarBloc),
        Provider.value(value: _displayListBloc),
      ],
      child: Stack(children: children),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _searchBarBloc = SearchBarBloc<T>(
      searcher: widget.searcher,
      filter: widget.filter,
    );

    _displayListBloc = DisplayListBloc(_scrollCtrl);
  }

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  Widget get _containerWithChangingHeight => SliverToBoxAdapter(
        child: StreamBuilder(
          stream: widget.searcher.filteredDataStream,
          builder: (context, snapshot) {
            final data = snapshot.data;
            final Color? color = data != null
                ? widget.searchBar.searchBackgroundColor
                : Colors.transparent;

            double height = 0;
            if (_searchBarBloc.isInSearchMode && !_isScrollReachTop) {
              height = _searchBarBloc.searchBarSize.height;

              ///
              /// Enable this if you think it is necessary!!!
              ///
              // _autoScrollTop();
            }

            return Container(color: color, height: height);
          },
        ),
      );

  SliverList _buildSliverList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        widget.itemBuilder!,
        childCount: widget.itemCount,
      ),
    );
  }

  Widget get _backTopButton => ValueListenableBuilder(
        valueListenable: _displayListBloc.backTopButtonVisibilityNotifier,
        builder: (context, bool visible, child) {
          return AnimatedPositioned(
            child: child!,
            right: 16.0,
            bottom: visible ? 16.0 : -128.0,
            duration: const Duration(milliseconds: 160),
          );
        },
        child: FloatingActionButton(
          mini: true,
          child: const Icon(Icons.arrow_upward),

          ///
          /// child: IconButton(
          ///   icon: Icon(Icons.arrow_upward),
          ///   onPressed: _displayListBloc.scrollTop,
          /// ),
          ///
          /// [ WARNING! ]
          /// This won't work while a child IconButton.onPressed was set!
          ///
          onPressed: _displayListBloc.scrollTop,
          tooltip: 'Back to top',
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          shape: const CircleBorder(),
        ),
      );

  void _getViewportMetrics(BuildContext context) {
    if (!mounted) return;
    _viewportHeight = MediaQuery.of(context).size.height;
  }

  void _onScroll() {
    ///
    /// Keep default scroll behaviors in search mode
    ///
    if (_searchBarBloc.isInSearchMode) {
      return;
    }

    switch (_scrollCtrl.position.userScrollDirection) {
      case ScrollDirection.reverse:
        _displayListBloc.hideBackTopButton();
        _searchBarBloc.toggle(false);
        break;

      case ScrollDirection.forward:
        bool _visible = _viewportHeight > 0 &&
            _scrollCtrl.position.pixels > _viewportHeight;

        _visible
            ? _displayListBloc.showBackTopButton()
            : _displayListBloc.hideBackTopButton();

        _searchBarBloc.toggle(true);
        break;

      default:
        break;
    }

    _isScrollReachTop = _scrollCtrl.position.pixels == 0;
    if (_isScrollReachTop) {
      _displayListBloc.hideBackTopButton();
      _searchBarBloc.toggle(false);
    }
  }

// void _autoScrollTop() {
//   _displayListBloc.scrollTo(0);
// }
}
