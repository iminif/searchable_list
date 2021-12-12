import 'package:diacritic/diacritic.dart';

typedef Filter<T, E> = bool Function(T test, E query);

class Filters {
  /// returns if [test] starts with the given [query],
  /// disregarding lower/upper case and diacritics.
  static bool startsWith(String test, String query) {
    final realTest = _prepareString(test);
    final realQuery = _prepareString(query);
    return realTest.startsWith(realQuery);
  }

  /// returns if [test] is exactly the same as [query],
  /// disregarding lower/upper case and diacritics.
  static bool equals(test, query) {
    final realTest = _prepareString(test);
    final realQuery = _prepareString(query);
    return realTest == realQuery;
  }

  /// returns if [test] contains the given [query],
  /// disregarding lower/upper case and diacritics.
  static bool contains(test, query) {
    final realTest = _prepareString(test);
    final realQuery = _prepareString(query);
    return realTest.contains(realQuery);
  }

  static String _prepareString(String string) =>
      removeDiacritics(string).toLowerCase();
}
