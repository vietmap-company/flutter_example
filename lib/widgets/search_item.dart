import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../providers/search_map.dart';

class SearchItem extends StatelessWidget {
  const SearchItem({Key? key, required this.future}) : super(key: key);
  final Feature future;
  @override
  Widget build(BuildContext context) {
    var text = future.properties?.label ?? '0';
    return GestureDetector(
      child: Card(
        margin: EdgeInsets.all(2.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            utf8.decode(latin1.encode(text), allowMalformed: true),
            textAlign: TextAlign.start,
          ),
        ),
      ),
      onTap: () {
        Navigator.pop(context, future.geometry?.coordinates);
      },
    );
  }
}
