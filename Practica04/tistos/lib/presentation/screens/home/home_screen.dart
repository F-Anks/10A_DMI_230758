import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tistos/presentation/models/feed_section.dart';
import 'package:tistos/presentation/providers/feed_provider.dart';
import 'package:tistos/presentation/screens/discover/discover_screen.dart';
import 'package:tistos/presentation/screens/for_you/for_you_screen.dart';
import 'package:tistos/presentation/screens/near_you/near_you_screen.dart';
import 'package:tistos/presentation/widgets/glass/liquid_glass_tab_bar.dart';
import 'package:tistos/presentation/widgets/shared/hourglass_loading.dart';
import 'package:tistos/presentation/widgets/shared/animated_gradient_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0; // 0: For You, 1: Near You, 2: Discover

  // Controlador para deslizar horizontalmente entre secciones
  final PageController _pageController = PageController();

  // Evita que las páginas intermedias se activen al saltar con un tap
  // (ej. de For you a Discover pasando por Near you)
  bool _isAnimatingFromTap = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Cambia de sección al tocar una pestaña
  void _onTabTap(int index) {
    // Si selecciona la misma sección, refrescamos los videos
    if (index == _selectedTab) {
      context.read<FeedProvider>().refresh(FeedSection.values[index]);
      return;
    }

    setState(() => _selectedTab = index);

    _isAnimatingFromTap = true;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    ).then((_) {
      _isAnimatingFromTap = false;
    });
  }

  /// Se llama al deslizar con el dedo entre secciones
  void _onPageChanged(int index) {
    if (_isAnimatingFromTap) return;
    if (index != _selectedTab) setState(() => _selectedTab = index);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeedProvider>();

    if (provider.initialLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Vista principal: scroll horizontal entre secciones
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              // Mientras una sección se refresca, su video se pausa
              ForYouScreen(
                isActive: _selectedTab == 0 && !provider.feed(FeedSection.forYou).isRefreshing,
              ),
              NearYouScreen(
                isActive: _selectedTab == 1 && !provider.feed(FeedSection.nearYou).isRefreshing,
              ),
              DiscoverScreen(
                isActive: _selectedTab == 2 && !provider.feed(FeedSection.discover).isRefreshing,
              ),
            ],
          ),

          // Indicador de recarga de la sección actual
          if (provider.feed(FeedSection.values[_selectedTab]).isRefreshing)
            const AnimatedGradientBackground(
              child: Center(
                child: HourglassLoading(),
              ),
            ),

          // Barra de navegación superior líquida
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: LiquidGlassTabBar(
                  labels: FeedSection.values.map((s) => s.label).toList(),
                  controller: _pageController,
                  selectedIndex: _selectedTab,
                  onTap: _onTabTap,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

