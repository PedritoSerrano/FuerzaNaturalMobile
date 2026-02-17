import 'package:flutter/material.dart';import 'package:flutter_fuerza_natural_login/ui/dashboard_view.dart';
import 'package:flutter_fuerza_natural_login/ui/gestion_fincas_view.dart';
import 'package:flutter_fuerza_natural_login/ui/gestion_reservas_view.dart';
import 'package:flutter_fuerza_natural_login/ui/gestion_usuarios_view.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _currentView = 'dashboard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: _renderView(),
      bottomNavigationBar: _buildMobileNav(),
    );
  }

  Widget _renderView() {
    switch (_currentView) {
      case 'dashboard':
        return const DashboardView();
      case 'fincas':
        return const GestionFincasView();
      case 'reservas':
        return const GestionReservasView();
      case 'usuarios':
        return const GestionUsuariosView();
      default:
        return const DashboardView();
    }
  }

  Widget _buildMobileNav() {
    final navItems = [
      _NavItem(
        id: 'dashboard',
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard',
      ),
      _NavItem(
        id: 'fincas',
        icon: Icons.landscape_outlined,
        activeIcon: Icons.landscape,
        label: 'Fincas',
      ),
      _NavItem(
        id: 'reservas',
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month,
        label: 'Reservas',
      ),
      _NavItem(
        id: 'usuarios',
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        label: 'Usuarios',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(242),
        border: const Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.map((item) {
              final isActive = _currentView == item.id;
              return _buildNavButton(item, isActive);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(_NavItem item, bool isActive) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentView = item.id;
          });
        },
        child: AnimatedScale(
          scale: isActive ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 48 : 0,
                height: isActive ? 4 : 0,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1e5a3a), Color(0xFF2d7a54)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFF1e5a3a).withAlpha(77),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? const LinearGradient(
                          colors: [Color(0xFF1e5a3a), Color(0xFF2d7a54)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isActive ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFF1e5a3a).withAlpha(77),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  size: 24,
                  color: isActive ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF1e5a3a)
                      : const Color(0xFF6B7280),
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String id;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({
    required this.id,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

