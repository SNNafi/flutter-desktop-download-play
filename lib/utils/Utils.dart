import 'package:intl/intl.dart';

Iterable<int> get positiveIntegers sync* {
  int i = 0;
  while (true) yield i++;
}

NumberFormat numberFormatter = NumberFormat("000");
