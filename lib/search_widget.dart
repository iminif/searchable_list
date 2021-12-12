import 'package:flutter/material.dart';

import 'bloc/search_bar.dart';

class SearchWidget<T> extends StatelessWidget implements PreferredSizeWidget {
  final Color color;
  final VoidCallback onCancelSearch;
  final TextCapitalization textCapitalization;
  final String hintText;
  final SearchBarBloc<T> searchBarBloc;

  const SearchWidget({
    Key? key,
    required this.searchBarBloc,
    required this.onCancelSearch,
    required this.color,
    required this.hintText,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(36.0);

  @override
  Widget build(BuildContext context) {
    ///
    /// to handle notches properly
    ///
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(7.0),
        color: Colors.transparent,
        child: GestureDetector(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor.withAlpha(32),
              ),
              color: Theme.of(context).primaryColor.withAlpha(16),
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _backButton,
                _textField,
                _clearButton,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _clearButton => StreamBuilder(
        stream: searchBarBloc.searchQueryStream,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          }

          return IconButton(
            icon: Icon(Icons.close, color: color),
            onPressed: () => searchBarBloc.onClearSearchQuery(),
          );
        },
      );

  Widget get _textField => Expanded(
        child: StreamBuilder(
          stream: searchBarBloc.searchQueryStream,
          builder: (context, snapshot) {
            TextEditingController controller = _getController(snapshot);
            return TextField(
              autofocus: true,
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
//              contentPadding: EdgeInsets.only(top: 2.0),
              ),
              textCapitalization: textCapitalization,
              style: const TextStyle(fontSize: 16.0),
              // onChanged: (q) => searchBarBloc.onSearchQueryChanged(q),
              onSubmitted: (q) => searchBarBloc.onSearchQuerySubmitted(q),
            );
          },
        ),
      );

  Widget get _backButton => IconButton(
        icon: Icon(Icons.arrow_back, color: color),
        onPressed: onCancelSearch,
      );

  TextEditingController _getController(AsyncSnapshot snapshot) {
    final controller = TextEditingController();
    controller.value = TextEditingValue(text: snapshot.data ?? '');
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    return controller;
  }
}
