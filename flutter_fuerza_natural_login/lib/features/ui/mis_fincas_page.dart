import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuerza_natural_login/core/models/finca_model.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/fincas/mis_fincas_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/ui/publicar_finca_page.dart';
import 'package:flutter_fuerza_natural_login/features/ui/widgets/app_error_widget.dart';
import 'package:image_picker/image_picker.dart';

class MisFincasPage extends StatelessWidget {
  const MisFincasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MisFincasBloc()..add(const MisFincasLoadRequested()),
      child: const _MisFincasView(),
    );
  }
}

class _MisFincasView extends StatelessWidget {
  const _MisFincasView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocBuilder<MisFincasBloc, MisFincasState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildHeader(context, state),
              if (state is MisFincasLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1e5a3a)),
                  ),
                )
              else if (state is MisFincasLoaded) ...[
                _buildStats(state),
                _buildFincasList(context, state),
                _buildPublicarBtn(context),
              ] else if (state is MisFincasError)
                SliverAppError(
                  mensaje: state.mensaje,
                  onRetry: () => context
                      .read<MisFincasBloc>()
                      .add(const MisFincasLoadRequested()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MisFincasState state) {
    return SliverToBoxAdapter(
      child: Container(
        color: const Color(0xFF1e5a3a),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          bottom: 20,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis Fincas',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'Gestiona tus propiedades',
                  style: TextStyle(
                      color: Color(0xFFB9F6CA), fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(MisFincasLoaded state) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            _MiniStat(
                value: state.totalFincas.toString(),
                label: 'Fincas'),
            _MiniStat(
                value: state.fincasActivas.toString(),
                label: 'Activas'),
            _MiniStat(
                value: state.totalReservas.toString(),
                label: 'Reservas'),
          ],
        ),
      ),
    );
  }

  Widget _buildFincasList(
      BuildContext context, MisFincasLoaded state) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => _MiFincaCard(finca: state.fincas[i]),
          childCount: state.fincas.length,
        ),
      ),
    );
  }

  Widget _buildPublicarBtn(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PublicarFincaPage(),
            ),
          ),
          icon: const Icon(Icons.add),
          label: const Text(
            '+ Publicar nueva finca',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1e5a3a),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

// ─── Mini stat ─────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ─── Mi Finca Card ─────────────────────────────────────────────
class _MiFincaCard extends StatelessWidget {
  final FincaModel finca;
  const _MiFincaCard({required this.finca});

  static const List<Color> _imgColors = [
    Color(0xFF5D8A5E),
    Color(0xFF4A6741),
    Color(0xFF7B9E7D),
  ];

  Color get _imgColor {
    final idx = int.tryParse(
            finca.id.replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
    return _imgColors[idx % _imgColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final activa = finca.estado == EstadoFinca.activa;
    final inactiva = finca.estado == EstadoFinca.inactiva;
    final estadoColor = activa
        ? Colors.green
        : inactiva
            ? Colors.red
            : Colors.grey;
    final estadoLabel = activa
        ? 'Activa'
        : inactiva
            ? 'Inactiva'
            : 'Pausada';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: finca.imageUrl != null
                      ? Image.network(
                          finca.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: _imgColor,
                            child: Center(
                              child: Icon(Icons.landscape,
                                  size: 50,
                                  color: Colors.white.withValues(alpha: 0.3)),
                            ),
                          ),
                        )
                      : Container(
                          color: _imgColor,
                          child: Center(
                            child: Icon(Icons.landscape,
                                size: 50,
                                color: Colors.white.withValues(alpha: 0.3)),
                          ),
                        ),
                ),
                // Estado badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: estadoColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          estadoLabel,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                // Reservas pendientes badge
                if (finca.reservasPendientes > 0)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time,
                              color: Colors.white, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            '${finca.reservasPendientes} pendientes',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Name over image
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                    padding:
                        const EdgeInsets.fromLTRB(14, 20, 14, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          finca.nombre,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white70, size: 13),
                            Text(
                              finca.ubicacion,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Row(
              children: [
                Text(
                  '${finca.superficie.toStringAsFixed(0)} ha',
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black54),
                ),
                const Text(' • ',
                    style: TextStyle(color: Colors.black38)),
                Text(
                  '€${finca.precioDia.toStringAsFixed(0)}/día',
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black54),
                ),
                const Text(' • ',
                    style: TextStyle(color: Colors.black38)),
                const Icon(Icons.star,
                    size: 14, color: Color(0xFFFFA000)),
                Text(
                  ' ${finca.valoracion.toStringAsFixed(1)}',
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black54),
                ),
                const Spacer(),
                Text(
                  '${finca.totalReservas} reservas',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: Row(
              children: [
                _ActionBtn(
                  icon: inactiva
                      ? Icons.play_circle_outline
                      : Icons.pause_circle_outline,
                  label: inactiva ? 'Habilitar' : 'Inhabilitar',
                  color: const Color(0xFF1e5a3a),
                  onTap: () {
                    final bloc = context.read<MisFincasBloc>();
                    if (inactiva) {
                      bloc.add(MisFincasActivarFinca(finca.id));
                    } else {
                      bloc.add(MisFincasInactivarFinca(finca.id));
                    }
                  },
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  icon: Icons.photo_library_outlined,
                  label: 'Fotos',
                  color: const Color(0xFF1e5a3a),
                  onTap: () {
                    final bloc = context.read<MisFincasBloc>();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => BlocProvider.value(
                        value: bloc,
                        child: _GestionFotosSheet(finca: finca),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _ActionBtn(
                  icon: Icons.visibility_outlined,
                  label: 'Ver',
                  color: const Color(0xFF1e5a3a),
                  onTap: () {},
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _confirmDelete(context, finca),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, FincaModel finca) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar finca'),
        content: Text(
            '¿Estás seguro de que quieres eliminar "${finca.nombre}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              context
                  .read<MisFincasBloc>()
                  .add(MisFincasEliminarFinca(finca.id));
              Navigator.pop(context);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─── Gestión de fotos sheet ────────────────────────────────────────────────
class _GestionFotosSheet extends StatefulWidget {
  final FincaModel finca;
  const _GestionFotosSheet({required this.finca});

  @override
  State<_GestionFotosSheet> createState() => _GestionFotosSheetState();
}

class _GestionFotosSheetState extends State<_GestionFotosSheet> {
  static final _picker = ImagePicker();
  final List<String> _nuevasFotos = [];
  bool _subiendo = false;

  Future<void> _pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 80);
      if (picked.isEmpty) return;
      setState(() {
        for (final x in picked) {
          if (!_nuevasFotos.contains(x.path)) _nuevasFotos.add(x.path);
        }
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo acceder a la galería')),
        );
      }
    }
  }

  Future<void> _guardar() async {
    if (_nuevasFotos.isEmpty) return;
    setState(() => _subiendo = true);
    context.read<MisFincasBloc>().add(
          MisFincasActualizarFotos(widget.finca.id, List.from(_nuevasFotos)),
        );
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final existentes = widget.finca.imagenes;
    final totalFotos = existentes.length + _nuevasFotos.length;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  const Icon(Icons.photo_library_outlined,
                      color: Color(0xFF1e5a3a)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Fotos de ${widget.finca.nombre}',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (totalFotos == 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(Icons.photo_camera_back_outlined,
                        size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Esta finca no tiene fotos todavía',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: totalFotos,
                  itemBuilder: (_, i) {
                    final isExistente = i < existentes.length;
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: isExistente
                                ? Image.network(
                                    existentes[i],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Container(color: Colors.grey[200]),
                                  )
                                : Image.file(
                                    File(_nuevasFotos[i - existentes.length]),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        if (!isExistente)
                          Positioned(
                            top: 4,
                            right: 14,
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _nuevasFotos
                                    .removeAt(i - existentes.length);
                              }),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 13, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _subiendo ? null : _pickImages,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('Añadir fotos'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1e5a3a),
                        side: const BorderSide(color: Color(0xFF1e5a3a)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  if (_nuevasFotos.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _subiendo ? null : _guardar,
                        icon: _subiendo
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.cloud_upload_outlined),
                        label: Text(_subiendo ? 'Subiendo…' : 'Guardar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1e5a3a),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
