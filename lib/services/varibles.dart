import 'package:flutter/material.dart';

final double bottomPadding = WidgetsBinding.instance.platformDispatcher.views.first.viewPadding.bottom;
final double navigationHeight = bottomPadding > 0 ? 80.0 : 50.0;
