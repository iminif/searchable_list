import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'app_bar_painter.dart';
import 'bloc/search_bar.dart';
import 'search_widget.dart';

class SearchBar<T> extends StatefulWidget {
  const SearchBar({
    Key? key,
    required this.title,
    this.iconTheme,
    this.searchBackgroundColor = Colors.white,
    this.searchElementsColor,
    this.hintText = 'Search for something...',
    this.centerTitle = false,
    this.flattenOnSearch = false,
    this.capitalization = TextCapitalization.none,
    this.actions = const <Widget>[],
    this.preferredSize = const Size.fromHeight(56.0),
    required this.onSearchModeChange,
    this.leading,

    ///
    /// ( Error!!! ) this.borderStatus = BorderRadius.circular(8.0)
    ///
    this.borderStatus = const BorderRadius.all(Radius.circular(8.0)),
  }) : super(key: key);

  final Widget? title, leading;
  final IconThemeData? iconTheme;
  final Color? searchBackgroundColor, searchElementsColor;
  final String hintText;
  final bool centerTitle, flattenOnSearch;
  final TextCapitalization capitalization;
  final List<Widget> actions;
  final Size preferredSize;
  final BorderRadius borderStatus;
  final Function(bool) onSearchModeChange;

  @override
  _SearchBarState<T> createState() => _SearchBarState<T>();
}

class _SearchBarState<T> extends State<SearchBar<T>>
    with SingleTickerProviderStateMixin<SearchBar<T>> {
  late Animation _animation;
  late AnimationController _animCtrl;
  late double _rippleStartX = 0, _rippleStartY = 0;
  double _elevation = 4.0;
  bool _isGetSizePlaned = false;
  static const EdgeInsets _padding = EdgeInsets.all(16.0);

  // const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0);

  late SearchBarBloc<T> _searchBarBloc;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _searchBarBloc.topDistanceNotifier,
      builder: (_, topDistance, nonUpdateChild) {
        return AnimatedPositioned(
          top: topDistance as double,
          left: 0,
          right: 0,
          duration: const Duration(milliseconds: 240),
          child: nonUpdateChild!,
        );
      },
      child: _buildAppBar(context),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _searchBarBloc = Provider.of<SearchBarBloc<T>>(context, listen: false);

    if (!_isGetSizePlaned) {
      WidgetsBinding.instance!.addPostFrameCallback((duration) {
        _sizing(duration, context);
      });

      _isGetSizePlaned = true;
    }
  }

  @override
  void initState() {
    super.initState();

    _isGetSizePlaned = false;

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _animCtrl.addStatusListener(_onAnimationStatusChange);

    _animation = Tween(begin: 0.0, end: 1.0).animate(_animCtrl);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: _padding,
      child: SafeArea(
        child: Container(
          height: kToolbarHeight,
          decoration: _preferredDecoration(context),
          child: ClipRRect(
            clipBehavior: Clip.antiAlias,
            borderRadius: widget.borderStatus,
            child: _buildSearchBar(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return GestureDetector(
      child: IconButton(
        onPressed: null,
        icon: Icon(
          Icons.search,
          color: widget.iconTheme?.color ?? Theme.of(context).iconTheme.color,
        ),
      ),
      onTapUp: _onSearchTapUp,
    );
  }

  Widget _buildSearchBar(context) {
    return ValueListenableBuilder(
      valueListenable: _searchBarBloc.isInSearchModeNotifier,
      builder: (_, bool isInSearchMode, animationChild) {
        return WillPopScope(
          onWillPop: () => _onWillPop(isInSearchMode),
          child: Stack(
            children: [
              _buildFrontAppBar(context),
              animationChild!,
              Positioned.fill(
                child: _buildSearcher(isInSearchMode, context),
              ),
            ],
          ),
        );
      },
      child: _buildAnimation(context),
    );
  }

  PreferredSizeWidget _buildFrontAppBar(BuildContext context) {
    final searchButton = _buildSearchButton(context);
    final increasedActions = <Widget>[];
    increasedActions.add(searchButton);
    increasedActions.addAll(widget.actions);

    return AppBar(
      leading: widget.leading,
      title: widget.title,
      elevation: _elevation,
      actions: increasedActions,
      centerTitle: widget.centerTitle,
      iconTheme: widget.iconTheme ?? Theme.of(context).iconTheme,
      backgroundColor: widget.searchBackgroundColor,
    );
  }

  AnimatedBuilder _buildAnimation(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: AppBarPainter(
            context: context,
            containerHeight: widget.preferredSize.height,
            center: Offset(_rippleStartX, _rippleStartY),
            // increase radius in % from 0% to 100% of screenWidth
            radius: _animation.value * screenWidth,
            color: widget.searchBackgroundColor ?? Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildSearcher(bool isInSearchMode, BuildContext context) {
    return isInSearchMode
        ? SearchWidget<T>(
            searchBarBloc: _searchBarBloc,
            hintText: widget.hintText,
            color: widget.searchElementsColor ?? Theme.of(context).primaryColor,
            textCapitalization: widget.capitalization,
            onCancelSearch: _cancelSearch,
          )
        : Container();
  }

  BoxDecoration _preferredDecoration(BuildContext context) {
    return BoxDecoration(
      borderRadius: widget.borderStatus,
      border: Border.all(
        width: 2.0,
        style: BorderStyle.solid,
        color: Theme.of(context).primaryColor,
      ),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Theme.of(context).primaryColor.withAlpha(127),
          offset: const Offset(0.0, 2.0),
          blurRadius: 10.0,
        ),
      ],
    );
  }

  Future<bool> _onWillPop(bool isInSearchMode) async {
    if (isInSearchMode) {
      _cancelSearch();
    }
    return !isInSearchMode;
  }

  void _onAnimationStatusChange(AnimationStatus animationStatus) {
    if (animationStatus == AnimationStatus.completed) {
      _searchBarBloc.onSearchModeChange(true);
      if (widget.flattenOnSearch) _elevation = 0.0;
    }
  }

  void _onSearchTapUp(TapUpDetails details) {
    _rippleStartX = details.globalPosition.dx;
    _rippleStartY = details.globalPosition.dy;
    _animCtrl.forward();
    _searchBarBloc.onSearchModeChange(true);
    widget.onSearchModeChange(true);
  }

  void _cancelSearch() {
    _searchBarBloc.onClearSearchQuery();
    _elevation = 4.0;
    _animCtrl.reverse();
    _searchBarBloc.onSearchModeChange(false);
    _searchBarBloc.toggle(false);
    widget.onSearchModeChange(false);
  }

  void _sizing(Duration duration, BuildContext context) {
    if (!mounted) return;
    Size? paintSize = context.findRenderObject()?.paintBounds.size;

    ///
    /// Notify widget size change
    ///
    if (paintSize != null) _searchBarBloc.onSizeChange(paintSize);
  }
}
