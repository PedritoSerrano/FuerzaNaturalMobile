import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuerza_natural_login/core/models/reserva_model.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/reservas/mis_reservas_bloc.dart';

class ReservasPage extends StatelessWidget {
  const ReservasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MisReservasBloc()..add(const MisReservasLoadRequested()),
      child: const _ReservasView(),
    );
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
          return CustomScrollView(
            slivers: [
              _buildHeader(context, state),
              if (state is MisReservasLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF2E7D32)),
                  ),
                )
              else if (state is MisReservasLoaded) ...[
                _buildFiltros(context, state),
                _buildLista(state),
              ] else if (state is MisReservasError)
                SliverFillRemaining(
                    child: Center(child: Text(state.mensaje))),
            ],
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
        color: const Color(0xFF2E7D32),
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
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2E7D32)
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
          (_, i) => _ReservaCard(reserva: state.mostradas[i]),
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
        color: Colors.white.withOpacity(0.15),
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
class _ReservaCard extends StatelessWidget {
  final ReservaModel reserva;
  const _ReservaCard({required this.reserva});

  static const List<Color> _colors = [
    Color(0xFF5D8A5E),
    Color(0xFF4A6741),
    Color(0xFF7B9E7D),
    Color(0xFF3B5E3D),
  ];

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
            color: Colors.black.withOpacity(0.06),
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
                              color: Colors.white.withOpacity(0.4)),
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
                            '${_formatDate(reserva.fechaInicio)} - ${_formatDate(reserva.fechaFin)} ${reserva.fechaFin.year}',
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
                          const SizedBox(width: 8),
                          const Text('•',
                              style: TextStyle(color: Colors.black38)),
                          const SizedBox(width: 8),
                          const Icon(Icons.access_time,
                              size: 13, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            '${reserva.numeroDias} días',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
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
                        color: Color(0xFF2E7D32),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Row(
                    children: [
                      Text(
                        'Ver detalles',
                        style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                      Icon(Icons.chevron_right,
                          color: Color(0xFF2E7D32), size: 18),
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
}
