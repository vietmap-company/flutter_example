import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vietmap_sample_api/providers/search_map.dart';

import '../widgets/search_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);
  static const String routeName = '/search-screen';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _textSearch = TextEditingController();

  @override
  void initState() {
    Future.delayed(Duration.zero).then(
      (value) {
        clearData();
      },
    );
    // TODO: implement initState
    super.initState();
  }

  Future<void> clearData() async {
    await Provider.of<SearchApi>(context, listen: false).clearSearchItem();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _textSearch.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchData = Provider.of<SearchApi>(context);
    return Scaffold(
        appBar: AppBar(
          title: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: Center(
                child: TextField(
                  controller: _textSearch,
                  onSubmitted: (value) async {
                    await searchData.fetchAndSetFeatureSearch(value);
                    print(value);
                  },
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          await searchData
                              .fetchAndSetFeatureSearch(_textSearch.text);
                        }),
                    hintText: 'Tìm Kiếm',
                    border: InputBorder.none,
                  ),
                  autofocus: true,
                ),
              ),
            ),
          ),
        ),
        body: ListView.builder(
          itemCount: searchData.featureItem.length,
          itemBuilder: (ctx, i) =>
              SearchItem(future: searchData.featureItem[i]),
        ));
  }
}
