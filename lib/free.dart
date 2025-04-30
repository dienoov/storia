import 'package:flutter/material.dart';
import 'package:storia/flavor.dart';
import 'package:storia/storia.dart';

void main() {
  FlavorConfig(
    flavor: FlavorType.free,
    values: const FlavorValues(title: 'Storia'),
  );

  runApp(storiaApp());
}
