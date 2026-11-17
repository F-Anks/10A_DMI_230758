import 'package:flutter/material.dart';

import 'package:cinemapedia/presentation/views/views.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  static const name = 'home-screen';
  final int pageIndex;

  const HomeScreen({
    super.key,
    required this.pageIndex,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

//* Este Mixin es necesario para mantener el estado en el PageView
class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      keepPage: true,
      initialPage: widget.pageIndex,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  final viewRoutes = const <Widget>[
    HomeView(),
    PopularView(),
    FavoritesView(),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (pageController.hasClients &&
        pageController.page?.round() != widget.pageIndex) {
      pageController.animateToPage(
        widget.pageIndex,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 250),
      );
    }

    return Scaffold(
      drawer: const SideMenu(),
      body: PageView(
        //* Esto evitará que rebote
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: viewRoutes,
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: widget.pageIndex,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
