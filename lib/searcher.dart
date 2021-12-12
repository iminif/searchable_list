import 'dart:core';

abstract class Searcher<T> {
  Function(List<T>) get onDataFiltered;

  Stream<List<T>> get filteredDataStream;

  List<T> get data;
}
