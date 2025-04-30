import 'package:flutter/material.dart';
import 'package:storia/flavor.dart';
import 'package:storia/storia.dart';

void main() {
  FlavorConfig(
    flavor: FlavorType.paid,
    values: const FlavorValues(title: 'Storia Premio'),
  );

  runApp(storiaApp());
}
