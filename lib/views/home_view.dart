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

  // Lazy loading das tabs - carregadas sob demanda
  final Map<int, Widget> _cachedPages = {};

  late final List<({String label, IconData icon, int index})> _navItems = [
    (label: "Dashboard", icon: LucideIcons.layoutDashboard, index: 0),
    (label: "Eventos", icon: LucideIcons.ticket, index: 1),
    (label: "Pedidos", icon: LucideIcons.shoppingBag, index: 2),
    (label: "Configurações", icon: LucideIcons.settings, index: 3),
  ];

  @override
  void initState() {
    super.initState();
    // Pré-carregar apenas a primeira tab
    _cachedPages[0] = const DashboardTab();
  }

  /// Obtém a widget da tab, com lazy loading
  Widget _getTabWidget(int index) {
    if (!_cachedPages.containsKey(index)) {
      _cachedPages[index] = _buildTabWidget(index);
    }
    return _cachedPages[index]!;
  }

  /// Constrói a widget correta baseado no índice
  Widget _buildTabWidget(int index) {
    return switch (index) {
      0 => const DashboardTab(),
      1 => const EventosTab(),
      2 => const PedidosTab(),
      3 => const ConfigTab(),
      _ => const DashboardTab(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 900;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: isMobile
              ? AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: const Text(
                    'Busão do Rolê',
                    style: TextStyle(
                      fontFamily: 'TitanOne',
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
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
                RepaintBoundary(
                  child: Container(
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
                ),
              Expanded(
                child: Container(
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
                      child: _getTabWidget(_selectedIndex),
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
          SizedBox(
            height: 280,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Image.asset(
                isDark
                    ? 'assets/img/logo_branca.png'
                    : 'assets/img/logo_preta.png',
                width: 280,
                cacheWidth: 560,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
              bottom: 25,
              top: 0,
            ),
            child: Container(
              height: 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFFFF0000),
                    Color.fromARGB(255, 226, 7, 7),
                    Color.fromARGB(255, 197, 3, 3),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.2, 0.5, 0.8, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromARGB(255, 189, 1, 1).withOpacity(0.6),
                    blurRadius: 5,
                    spreadRadius: 0.3,
                  ),
                  BoxShadow(
                    color:
                        const Color.fromARGB(255, 128, 2, 2).withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 0.3,
                  ),
                ],
              ),
            ),
          ),
          ..._navItems.map((item) => _buildNavItem(
            label: item.label,
            icon: item.icon,
            index: item.index,
          )),
          const Spacer(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String label,
    required IconData icon,
    required int index,
  }) {
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
