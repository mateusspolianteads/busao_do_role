import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'tabs/dashboard_tab.dart';
import 'tabs/eventos_tab.dart';
import 'tabs/pedidos_tab.dart';

import '../services/auth_service.dart';
import '../theme_controller.dart';
import 'login_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<int, Widget> _cachedPages = {};

  final List<({String label, IconData icon, int index})> _navItems = [
    (label: "Dashboard", icon: LucideIcons.layoutDashboard, index: 0),
    (label: "Eventos", icon: LucideIcons.ticket, index: 1),
    (label: "Pedidos", icon: LucideIcons.shoppingBag, index: 2),
  ];

  @override
  void initState() {
    super.initState();
    _cachedPages[0] = const DashboardTab();
  }

  Widget _getTabWidget(int index) {
    if (!_cachedPages.containsKey(index)) {
      _cachedPages[index] = _buildTabWidget(index);
    }
    return _cachedPages[index]!;
  }

  Widget _buildTabWidget(int index) {
    return switch (index) {
      0 => const DashboardTab(),
      1 => const EventosTab(),
      2 => const PedidosTab(),
      _ => const DashboardTab(),
    };
  }

  Future<void> _handleLogout() async {
    debugPrint("====== INICIANDO LOGOUT ======");
    await AuthService.logout();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sessão encerrada com segurança!'),
        backgroundColor: Colors.blueGrey,
      ),
    );

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginView()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Passa a usar o estado reativo do ThemeController centralizado
    final isDark = ThemeController.isDarkMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 900;

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
                  child: RepaintBoundary(
                    child: _buildMenuContent(
                      isMobile: true,
                      isDark: isDark,
                    ),
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
                  child: KeyedSubtree(
                    key: ValueKey(_selectedIndex),
                    child: _getTabWidget(_selectedIndex),
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
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? const Color(0xFFA0A0A0) : Colors.grey[600];

    return Container(
      color: isMobile ? Theme.of(context).cardColor : Colors.transparent,
      child: Column(
        children: [
          SizedBox(
            height: 148,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 35, bottom: 5, left: 24, right: 24),
              child: Image.asset(
                isDark
                    ? 'assets/img/logo_branca.png'
                    : 'assets/img/logo_preta.png',
                cacheWidth: 440,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 30, right: 30, bottom: 25, top: 35),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              height: 1.2,
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
                    color: const Color(0xFFFF0000).withValues(alpha: 0.8),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: const Color(0xFFFF0000).withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                return _buildNavItem(
                  label: item.label,
                  icon: item.icon,
                  index: item.index,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.black.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isDark ? LucideIcons.moon : LucideIcons.sun,
                            color: isDark
                                ? const Color(0xFFFFD700)
                                : Colors.orange,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isDark ? "Modo Escuro" : "Modo Claro",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: isDark,
                          activeThumbColor: const Color(0xFFB30000),
                          activeTrackColor:
                              const Color(0xFFB30000).withValues(alpha: 0.3),
                          // 💡 Agora aciona diretamente o ThemeController sem lag
                          onChanged: (value) {
                            ThemeController.toggleTheme(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _handleLogout,
                    hoverColor: Colors.red.withValues(alpha: 0.08),
                    splashColor: Colors.red.withValues(alpha: 0.15),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.logOut,
                            color: Color(0xFFFF4D4D),
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Sair da Conta",
                                  style: TextStyle(
                                    color: Color(0xFFFF4D4D),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Encerrar sessão",
                                  style: TextStyle(
                                    color:
                                        subtitleColor?.withValues(alpha: 0.7),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String label,
    required IconData icon,
    required int index,
  }) {
    final bool isActive = _selectedIndex == index;
    final bool isDark = ThemeController.isDarkMode;

    final Color hoverColor =
        isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04);
    final Color splashColor =
        isActive ? Colors.white12 : (isDark ? Colors.white10 : Colors.black12);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? const Color(0xFFB30000) : Colors.transparent,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            hoverColor: hoverColor,
            splashColor: splashColor,
            onTap: () {
              if (_selectedIndex == index) return;

              setState(() {
                _selectedIndex = index;
              });

              if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                Navigator.pop(context);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isActive
                        ? Colors.white
                        : (isDark ? const Color(0xFFA0A0A0) : Colors.black54),
                    size: 20,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : (isDark
                                ? const Color(0xFFA0A0A0)
                                : Colors.black87),
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (isActive)
                    Container(
                      width: 3,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}