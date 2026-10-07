import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tistos/presentation/providers/discover_provider.dart';
import 'package:tistos/presentation/screens/discover/discover_screen.dart';
import 'package:tistos/presentation/screens/for_you/for_you_screen.dart';
import 'package:tistos/presentation/screens/near_you/near_you_screen.dart';

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
  Future<void> _onTabTap(int index) async {
    // Si selecciona la misma sección, no hace nada
    if (index == _selectedTab) return;

    setState(() => _selectedTab = index);

    _isAnimatingFromTap = true;
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
    _isAnimatingFromTap = false;
  }

  /// Se llama al deslizar con el dedo entre secciones
  void _onPageChanged(int index) {
    if (_isAnimatingFromTap) return;
    if (index != _selectedTab) setState(() => _selectedTab = index);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscoverProvider>();

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
              ForYouScreen(isActive: _selectedTab == 0),
              NearYouScreen(isActive: _selectedTab == 1),
              DiscoverScreen(isActive: _selectedTab == 2),
            ],
          ),

          // Barra de navegación superior
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TabButton(
                    title: 'For you',
                    isSelected: _selectedTab == 0,
                    onTap: () => _onTabTap(0),
                  ),
                  _TabButton(
                    title: 'Near you',
                    isSelected: _selectedTab == 1,
                    onTap: () => _onTabTap(1),
                  ),
                  _TabButton(
                    title: 'Discover',
                    isSelected: _selectedTab == 2,
                    onTap: () => _onTabTap(2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // Asegura que toda el área sea táctil
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: isSelected ? 18 : 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  )
                ],
              ),
              child: Text(title),
            ),
            const SizedBox(height: 4),
            // Indicador de la sección seleccionada
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              height: 3,
              width: isSelected ? 24 : 0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
