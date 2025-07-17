import 'package:tailorapp/core/init/navigation/navigation_route.dart';
import 'package:tailorapp/view/_product/enum/route_enum.dart';
import 'package:flutter/material.dart';

// TODO bu kısıma anasayfa tasarlanır ve proje buradan başlar
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homepage"),
        actions: [
          IconButton(
            onPressed: () {
              NavigationRoute.goRouteNormal(RouteEnum.setting.rawValue);
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: const Center(child: Text("This is Home Page")),
    );
  }
}
