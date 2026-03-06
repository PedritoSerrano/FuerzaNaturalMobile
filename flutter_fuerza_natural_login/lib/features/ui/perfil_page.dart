import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuerza_natural_login/core/models/user_model.dart';
import 'package:flutter_fuerza_natural_login/core/services/auth_repository.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/auth/auth_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/perfil/perfil_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/ui/mis_fincas_page.dart';
import 'package:flutter_fuerza_natural_login/features/ui/mis_resenas_page.dart';
import 'package:flutter_fuerza_natural_login/features/ui/widgets/app_error_widget.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PerfilBloc()..add(const PerfilLoadRequested()),
      child: const _PerfilView(),
    );
  }
}

class _PerfilView extends StatelessWidget {
  const _PerfilView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PerfilBloc, PerfilState>(
      builder: (context, state) {
        if (state is PerfilLoading || state is PerfilInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1e5a3a)),
            ),
          );
        }
        if (state is PerfilLoaded) {
          return _buildLoaded(context, state);
        }
        final mensaje = state is PerfilError ? state.mensaje : 'No se pudo cargar el perfil.';
        return Scaffold(
          body: AppErrorWidget(
            mensaje: mensaje,
            onRetry: () =>
                context.read<PerfilBloc>().add(const PerfilLoadRequested()),
          ),
        );
      },
    );
  }

  Widget _buildLoaded(BuildContext context, PerfilLoaded state) {
    final user = state.user;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFF1e5a3a),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Mi Perfil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gestiona tu cuenta y preferencias',
                    style: TextStyle(
                        color: Color(0xFFB9F6CA), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      
                      Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor:
                                    const Color(0xFFE8F5E9),
                                child: Text(
                                  user.nombre[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1e5a3a),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.nombreCompleto,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 13,
                                      color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Miembro desde ${_formatMonth(user.fechaRegistro)}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      
                      _ContactRow(
                          icon: Icons.email_outlined,
                          text: user.email),
                      if (user.telefono != null)
                        _ContactRow(
                            icon: Icons.phone_outlined,
                            text: user.telefono!),
                      if (user.ubicacion != null)
                        _ContactRow(
                            icon: Icons.location_on_outlined,
                            text: user.ubicacion!),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileStatBox(
                              value: user.reservasRealizadas
                                  .toString(),
                              label: 'Reservas realizadas',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ProfileStatBox(
                              value: user.fincasCount.toString(),
                              label: 'Mis fincas',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                
                _SectionHeader(title: 'Mi Cuenta'),
                const SizedBox(height: 8),
                _MenuCard(items: [
                  _MenuItem(
                    icon: Icons.person_outline,
                    label: 'Editar perfil',
                    onTap: () => _showEditarPerfil(context, user),
                  ),
                  _MenuItem(
                    icon: Icons.rate_review_outlined,
                    label: 'Mis reseñas',
                    badge: user.valoracionesCount > 0
                        ? user.valoracionesCount.toString()
                        : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MisResenasPage()),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),

                
                _SectionHeader(title: 'Mi Finca'),
                const SizedBox(height: 8),
                _MenuCard(items: [
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Gestionar mis fincas',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MisFincasPage(),
                        ),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 24),

                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context
                          .read<AuthBloc>()
                          .add(const AuthLogoutRequested());
                    },
                    icon: const Icon(Icons.logout,
                        color: Colors.red),
                    label: const Text(
                      'Cerrar sesión',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditarPerfil(BuildContext context, UserModel user) {
    final bloc = context.read<PerfilBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _EditarPerfilSheet(user: user),
      ),
    );
  }

  String _formatMonth(DateTime d) {
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${months[d.month]} ${d.year}';
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1e5a3a)),
          const SizedBox(width: 10),
          Text(text,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }
}

class _ProfileStatBox extends StatelessWidget {
  final String value;
  final String label;
  const _ProfileStatBox(
      {required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1e5a3a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFFB9F6CA), fontSize: 12),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black54));
  }
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              InkWell(
                onTap: e.value.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(e.value.icon,
                            size: 20,
                            color: const Color(0xFF1e5a3a)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(e.value.label,
                            style: const TextStyle(fontSize: 15)),
                      ),
                      if (e.value.badge != null)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1e5a3a),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            e.value.badge!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      const Icon(Icons.chevron_right,
                          color: Colors.grey, size: 20),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Divider(height: 1, indent: 64),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon,
      required this.label,
      this.badge,
      required this.onTap});
}

class _EditarPerfilSheet extends StatefulWidget {
  final UserModel user;
  const _EditarPerfilSheet({required this.user});

  @override
  State<_EditarPerfilSheet> createState() => _EditarPerfilSheetState();
}

class _EditarPerfilSheetState extends State<_EditarPerfilSheet> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _apellidosCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _ubicacionCtrl;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nombreCtrl   = TextEditingController(text: widget.user.nombre);
    _apellidosCtrl= TextEditingController(text: widget.user.apellidos ?? '');
    _telefonoCtrl = TextEditingController(text: widget.user.telefono ?? '');
    _ubicacionCtrl= TextEditingController(text: widget.user.ubicacion ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _telefonoCtrl.dispose();
    _ubicacionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      setState(() => _error = 'El nombre no puede estar vacío.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await AuthRepository().updateMiPerfil(
        nombre:    nombre,
        apellidos: _apellidosCtrl.text.trim().isNotEmpty ? _apellidosCtrl.text.trim() : null,
        telefono:  _telefonoCtrl.text.trim().isNotEmpty  ? _telefonoCtrl.text.trim()  : null,
        ubicacion: _ubicacionCtrl.text.trim().isNotEmpty ? _ubicacionCtrl.text.trim() : null,
      );
      if (mounted) {
        context.read<PerfilBloc>().add(const PerfilLoadRequested());
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Color(0xFF1e5a3a),
          ),
        );
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Editar perfil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _Field(label: 'Nombre *', controller: _nombreCtrl),
            const SizedBox(height: 14),
            _Field(label: 'Apellidos', controller: _apellidosCtrl),
            const SizedBox(height: 14),
            _Field(label: 'Teléfono', controller: _telefonoCtrl,
                keyboard: TextInputType.phone),
            const SizedBox(height: 14),
            _Field(label: 'Ubicación / Ciudad', controller: _ubicacionCtrl),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1e5a3a),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Guardar cambios',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboard;
  const _Field({
    required this.label,
    required this.controller,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF1e5a3a), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
