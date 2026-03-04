import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuerza_natural_login/core/models/reserva_model.dart';
import 'package:flutter_fuerza_natural_login/core/services/auth_repository.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/reservas/mis_reservas_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/ui/widgets/app_error_widget.dart';

class ReservasPage extends StatelessWidget {
  const ReservasPage({super.key});

  @override
  Widget build(BuildContext context) {
    // MisReservasBloc is provided by MainShell
    return const _ReservasView();
  }
}

class _ReservasView extends StatelessWidget {
  const _ReservasView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocBuilder<MisReservasBloc, MisReservasState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: const Color(0xFF1e5a3a),
            onRefresh: () async {
              context
                  .read<MisReservasBloc>()
                  .add(const MisReservasLoadRequested());
              // Espera a que el estado cambie de loading a otro
              await Future.delayed(const Duration(milliseconds: 600));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildHeader(context, state),
                if (state is MisReservasLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF1e5a3a)),
                    ),
                  )
                else if (state is MisReservasLoaded) ...[
                  _buildFiltros(context, state),
                  _buildLista(state),
                ] else if (state is MisReservasError)
                  SliverAppError(
                    mensaje: state.mensaje,
                    onRetry: () => context
                        .read<MisReservasBloc>()
                        .add(const MisReservasLoadRequested()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MisReservasState state) {
    int activas = 0, completadas = 0;
    if (state is MisReservasLoaded) {
      activas = state.totalActivas;
      completadas = state.totalCompletadas;
    }

    return SliverToBoxAdapter(
      child: Container(
        color: const Color(0xFF1e5a3a),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mis Reservas',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Gestiona tus reservas de caza',
              style: TextStyle(color: Color(0xFFB9F6CA), fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    value: activas.toString(),
                    label: 'Activas',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBox(
                    value: completadas.toString(),
                    label: 'Completadas',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltros(BuildContext context, MisReservasLoaded state) {
    final filtros = [
      ('todas', 'Todas', state.todas.length),
      ('activas', 'Activas', state.totalActivas),
      ('pasadas', 'Pasadas', state.totalCompletadas),
    ];

    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: filtros.map((f) {
            final isSelected = state.filtroActivo == f.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => context
                    .read<MisReservasBloc>()
                    .add(MisReservasFiltrarPorEstado(f.$1)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1e5a3a)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1e5a3a)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    '${f.$2} ${f.$3}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLista(MisReservasLoaded state) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => _ReservaCard(
            key: ValueKey(state.mostradas[i].id),
            reserva: state.mostradas[i],
          ),
          childCount: state.mostradas.length,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFFB9F6CA), fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── Reserva Card ─────────────────────────────────────────────
class _ReservaCard extends StatefulWidget {
  final ReservaModel reserva;
  const _ReservaCard({super.key, required this.reserva});

  @override
  State<_ReservaCard> createState() => _ReservaCardState();
}

class _ReservaCardState extends State<_ReservaCard> {
  late bool _tieneValoracion;

  @override
  void initState() {
    super.initState();
    _tieneValoracion = widget.reserva.tieneValoracion;
  }

  ReservaModel get reserva => widget.reserva;

  static const List<Color> _colors = [
    Color(0xFF5D8A5E),
    Color(0xFF4A6741),
    Color(0xFF7B9E7D),
    Color(0xFF3B5E3D),
  ];

  bool get _puedeResenar =>
      reserva.estado == EstadoReserva.completada;

  Color get _imgColor {
    final idx = int.tryParse(
            reserva.fincaId.replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
    return _colors[idx % _colors.length];
  }

  Color get _estadoColor {
    switch (reserva.estado) {
      case EstadoReserva.confirmada:
        return Colors.green;
      case EstadoReserva.pendiente:
        return Colors.orange;
      case EstadoReserva.completada:
        return Colors.blueGrey;
      case EstadoReserva.cancelada:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get _estadoLabel {
    switch (reserva.estado) {
      case EstadoReserva.confirmada:
        return 'Confirmada';
      case EstadoReserva.pendiente:
        return 'Pendiente';
      case EstadoReserva.completada:
        return 'Completada';
      case EstadoReserva.cancelada:
        return 'Cancelada';
      default:
        return 'Desconocido';
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day} ${_month(d.month)} ${d.year}';

  String _month(int m) {
    const months = [
      '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return months[m];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Top row: image + info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with status badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: _imgColor,
                        child: Center(
                          child: Icon(Icons.landscape,
                              size: 30,
                              color: Colors.white.withValues(alpha: 0.4)),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: _estadoColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          _estadoLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reserva.fincaNombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 13, color: Colors.grey),
                          Text(
                            reserva.ubicacion,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 13, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(reserva.fechaInicio),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.group,
                              size: 13, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            '${reserva.numeroPersonas} personas',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                          if (reserva.tipoReserva != null) ...
                            [
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  ReservaModel.tipoLabel(
                                      reserva.tipoReserva),
                                  style: const TextStyle(
                                    color: Color(0xFF1e5a3a),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total pagado',
                        style:
                            TextStyle(color: Colors.grey, fontSize: 11)),
                    Text(
                      '€${reserva.precioTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF1e5a3a),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (_puedeResenar)
                  _tieneValoracion
                      ? const Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green, size: 16),
                            SizedBox(width: 4),
                            Text('Reseñado',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        )
                      : GestureDetector(
                          onTap: () => _mostrarSheetResena(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1e5a3a),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_border,
                                    color: Colors.white, size: 15),
                                SizedBox(width: 5),
                                Text('Dejar reseña',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        )
                else
                  GestureDetector(
                    onTap: () {},
                    child: const Row(
                      children: [
                        Text('Ver detalles',
                            style: TextStyle(
                                color: Color(0xFF1e5a3a),
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        Icon(Icons.chevron_right,
                            color: Color(0xFF1e5a3a), size: 18),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarSheetResena(BuildContext context) {
    final bloc = context.read<MisReservasBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DejarResenaSheet(
        reservaId: reserva.id,
        fincaNombre: reserva.fincaNombre,
        onGuardado: () {
          setState(() => _tieneValoracion = true);
          bloc.add(const MisReservasLoadRequested());
        },
      ),
    );
  }}

// ─── Sheet: Dejar Reseña ──────────────────────────────────────
class _DejarResenaSheet extends StatefulWidget {
  final String reservaId;
  final String fincaNombre;
  final VoidCallback onGuardado;

  const _DejarResenaSheet({
    required this.reservaId,
    required this.fincaNombre,
    required this.onGuardado,
  });

  @override
  State<_DejarResenaSheet> createState() => _DejarResenaSheetState();
}

class _DejarResenaSheetState extends State<_DejarResenaSheet> {
  final _auth = AuthRepository();
  final _comentarioCtrl = TextEditingController();
  int _puntuacion = 0;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_puntuacion == 0) {
      setState(() => _error = 'Selecciona una puntuación');
      return;
    }
    setState(() { _cargando = true; _error = null; });
    try {
      await _auth.crearValoracion(
        idReserva: widget.reservaId,
        puntuacion: _puntuacion,
        comentario: _comentarioCtrl.text.trim().isEmpty
            ? null
            : _comentarioCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onGuardado();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reseña enviada. ¡Gracias!'),
            backgroundColor: Color(0xFF1e5a3a),
          ),
        );
      }
    } catch (e) {
      setState(() { _cargando = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Text('Dejar reseña',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.fincaNombre,
                style: const TextStyle(
                    color: Color(0xFF1e5a3a),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            // Estrellas
            const Text('Puntuación',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (i) => GestureDetector(
                  onTap: () => setState(() => _puntuacion = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      i < _puntuacion ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFC107),
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Comentario
            const Text('Comentario (opcional)',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54)),
            const SizedBox(height: 8),
            TextField(
              controller: _comentarioCtrl,
              maxLines: 3,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: 'Cuéntanos tu experiencia...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
              ),
            ),
            if (_error != null) ...
              [
                const SizedBox(height: 8),
                Text(_error!,
                    style: const TextStyle(
                        color: Colors.red, fontSize: 13)),
              ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _cargando ? null : _enviar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1e5a3a),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _cargando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Enviar reseña',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}