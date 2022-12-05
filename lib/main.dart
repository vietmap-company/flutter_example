import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vietmap_sample_api/providers/routings.dart';
import 'package:vietmap_sample_api/providers/search_map.dart';
import 'package:vietmap_sample_api/screens/home_screen.dart';
import 'package:vietmap_sample_api/screens/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Routes(),
        ),
        ChangeNotifierProvider.value(
          value: SearchApi(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeScreen(),
        routes: {
          HomeScreen.routeName: (ctx) => const HomeScreen(),
          SearchScreen.routeName: (ctx) => const SearchScreen(),
        },
      ),
    );
  }
}
