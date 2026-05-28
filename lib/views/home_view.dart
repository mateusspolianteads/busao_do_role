import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'tabs/dashboard_tab.dart';
import 'tabs/eventos_tab.dart';
import 'tabs/pedidos_tab.dart';
import 'tabs/config_tab.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _pages = [
    const DashboardTab(),
    const EventosTab(),
    const PedidosTab(),
    const ConfigTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 900;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,

          // No arquivo home_view.dart
          appBar: isMobile
              ? AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'Busão do Rolê',
                    style: TextStyle(
                      fontFamily:
                          'TitanOne', // 👈 AQUI: Define a fonte deste texto
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  centerTitle: true,
                )
              : null,

          drawer: isMobile
              ? Drawer(
                  child: _buildMenuContent(
                    isMobile: true,
                    isDark: isDark,
                  ),
                )
              : null,

          body: Row(
            children: [
              if (!isMobile)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 280,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      right: BorderSide(
                        color: isDark
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFFE5E5E5),
                      ),
                    ),
                  ),
                  child: _buildMenuContent(
                    isMobile: false,
                    isDark: isDark,
                  ),
                ),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? const RadialGradient(
                            center: Alignment(0, -1.2),
                            radius: 1.2,
                            colors: [
                              Color(0xFF2A0000),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.6],
                          )
                        : null,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: KeyedSubtree(
                      key: ValueKey(_selectedIndex),
                      child: _pages[_selectedIndex],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuContent({
    required bool isMobile,
    required bool isDark,
  }) {
    return Container(
      color: isMobile ? Theme.of(context).cardColor : Colors.transparent,
      child: Column(
        children: [
          // MANTIDO: Logo maximizada para compensar as bordas transparentes do asset
          Padding(
            padding:
                const EdgeInsets.only(top: 25, bottom: 20, left: 5, right: 5),
            child: Image.asset(
              isDark
                  ? 'assets/img/logo_branca.png'
                  : 'assets/img/logo_preta.png',
              width: 260,
              fit: BoxFit.contain,
            ),
          ),

          _buildNavItem("Dashboard", LucideIcons.layoutDashboard, 0),
          _buildNavItem("Eventos", LucideIcons.ticket, 1),
          _buildNavItem("Pedidos", LucideIcons.shoppingBag, 2),

          const Spacer(),

          _buildNavItem("Configurações", LucideIcons.settings, 3),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, int index) {
    bool isActive = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? const Color(0xFFB30000) : Colors.transparent,
        ),
        child: ListTile(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
              Navigator.pop(context);
            }
          },
          leading: Icon(
            icon,
            color: isActive
                ? Colors.white
                : (isDark ? const Color(0xFFA0A0A0) : Colors.black54),
            size: 20,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : (isDark ? const Color(0xFFA0A0A0) : Colors.black87),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
