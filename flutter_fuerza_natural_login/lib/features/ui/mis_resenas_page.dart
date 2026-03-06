import 'package:flutter/material.dart';
import 'package:flutter_fuerza_natural_login/core/config/api_config.dart';
import 'package:flutter_fuerza_natural_login/core/services/api_service.dart';

class MisResenasPage extends StatefulWidget {
  const MisResenasPage({super.key});

  @override
  State<MisResenasPage> createState() => _MisResenasPageState();
}

class _MisResenasPageState extends State<MisResenasPage> {
  final _api = ApiService();
  late Future<List<_ResenaData>> _future;

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  Future<List<_ResenaData>> _cargar() async {
    final response = await _api.get(ApiConfig.misValoraciones);
    final raw = response.data;
    final list = raw is List
        ? raw
        : (raw is Map ? (raw['data'] ?? raw['valoraciones'] ?? []) : []);
    return (list as List)
        .map((e) => _ResenaData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1e5a3a),
        foregroundColor: Colors.white,
        title: const Text('Mis Rese\u00f1as',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<_ResenaData>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1e5a3a)),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(snap.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => _future = _cargar()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          final resenas = snap.data ?? [];
          if (resenas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.rate_review_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'A\u00fan no has escrito ninguna rese\u00f1a',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: resenas.length,
            itemBuilder: (_, i) => _ResenaCard(resena: resenas[i]),
          );
        },
      ),
    );
  }
}

class _ResenaData {
  final int puntuacion;
  final String? comentario;
  final String fincaNombre;
  final DateTime fecha;

  const _ResenaData({
    required this.puntuacion,
    this.comentario,
    required this.fincaNombre,
    required this.fecha,
  });

  factory _ResenaData.fromJson(Map<String, dynamic> json) {
    final reserva = json['reserva'] as Map<String, dynamic>?;
    final evento  = reserva?['evento'] as Map<String, dynamic>?;
    final finca   = evento?['finca']   as Map<String, dynamic>?;

    final fechaRaw = json['fecha_valoracion'] ?? json['created_at'];
    return _ResenaData(
      puntuacion:  (json['puntuacion'] as num?)?.toInt() ?? 0,
      comentario:  json['comentario'] as String?,
      fincaNombre: (finca?['nombre'] ?? json['finca_nombre'] ?? 'Finca desconocida').toString(),
      fecha: fechaRaw != null
          ? DateTime.tryParse(fechaRaw.toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class _ResenaCard extends StatelessWidget {
  final _ResenaData resena;
  const _ResenaCard({required this.resena});

  String _fmtDate(DateTime d) {
    const months = ['', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
        'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  resena.fincaNombre,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              ...List.generate(
                5,
                (i) => Icon(
                  i < resena.puntuacion ? Icons.star : Icons.star_border,
                  color: const Color(0xFFFFC107),
                  size: 18,
                ),
              ),
            ],
          ),
          if (resena.comentario != null && resena.comentario!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              resena.comentario!,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                _fmtDate(resena.fecha),
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
