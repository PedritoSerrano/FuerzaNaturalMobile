import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fuerza_natural_login/core/config/api_config.dart';
import 'package:flutter_fuerza_natural_login/core/models/finca_model.dart';
import 'package:flutter_fuerza_natural_login/core/services/api_service.dart';
import 'package:flutter_fuerza_natural_login/core/services/reservas_repository.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class DetalleFincaPage extends StatefulWidget {
  final FincaModel finca;
  const DetalleFincaPage({super.key, required this.finca});

  @override
  State<DetalleFincaPage> createState() => _DetalleFincaPageState();
}

class _DetalleFincaPageState extends State<DetalleFincaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<Color> _imgColors = [
    Color(0xFF5D8A5E),
    Color(0xFF4A6741),
    Color(0xFF7B9E7D),
    Color(0xFF3B5E3D),
  ];

  Color get _imgColor {
    final idx = int.tryParse(
            widget.finca.id.replaceAll(RegExp(r'[^0-9]'), '')) ??
        0;
    return _imgColors[idx % _imgColors.length];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finca = widget.finca;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(context, finca),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildInfoCard(finca),
                    _buildTabs(finca),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, FincaModel finca) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Colors.white,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black38,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
        ),
      ),
      title: Text(
        finca.nombre,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _FincaCarousel(
          imagenes: finca.imagenes.isNotEmpty
              ? finca.imagenes
              : (finca.imageUrl != null && finca.imageUrl!.isNotEmpty
                  ? [finca.imageUrl!]
                  : []),
          color: _imgColor,
        ),
      ),
    );
  }

  Widget _buildInfoCard(FincaModel finca) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      finca.nombre,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          finca.ubicacion,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1e5a3a),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      finca.valoracion.toStringAsFixed(1),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatItem(
                  value: '${finca.superficie.toStringAsFixed(0)} ha',
                  label: ''),
              const Text(' • ', style: TextStyle(color: Colors.grey)),
              _StatItem(
                  value: '${finca.numeroResenas}',
                  label: ' reseñas'),
              const Text(' • ', style: TextStyle(color: Colors.grey)),
              _StatItem(
                  value: '${finca.especies.length}',
                  label: ' especies'),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text:
                      '€${finca.precioDia.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(FincaModel finca) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: const Color(0xFF1e5a3a),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1e5a3a),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(
              child: Row(children: [
                Icon(Icons.info_outline, size: 16),
                SizedBox(width: 4),
                Text('Info'),
              ]),
            ),
            Tab(
              child: Row(children: [
                Icon(Icons.pets, size: 16),
                SizedBox(width: 4),
                Text('Especies'),
              ]),
            ),
            Tab(
              child: Row(children: [
                Icon(Icons.handyman_outlined, size: 16),
                SizedBox(width: 4),
                Text('Servicios'),
              ]),
            ),
            Tab(
              child: Row(children: [
                Icon(Icons.rule, size: 16),
                SizedBox(width: 4),
                Text('Normas'),
              ]),
            ),
            Tab(
              child: Row(children: [
                Icon(Icons.map_outlined, size: 16),
                SizedBox(width: 4),
                Text('Mapa'),
              ]),
            ),
            Tab(
              child: Row(children: [
                Icon(Icons.star_outline, size: 16),
                SizedBox(width: 4),
                Text('Reseñas'),
              ]),
            ),
          ],
        ),
        SizedBox(
          height: 300,
          child: TabBarView(
            controller: _tabController,
            children: [
              _InfoTab(finca: finca),
              _EspeciesTab(finca: finca),
              _ServiciosTab(finca: finca),
              _NormasTab(finca: finca),
              _MapaTab(finca: finca),
              _ResenasTab(finca: finca),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    final finca = widget.finca;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        color: Colors.white,
        child: ElevatedButton.icon(
          onPressed: () => _showReservaSheet(context, finca),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1e5a3a),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.calendar_today),
          label: const Text(
            'Reservar jornada',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void _showReservaSheet(BuildContext context, FincaModel finca) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReservaSheet(finca: finca),
    );
  }
}

// ─── Reusable finca hero image ───────────────────────────────
// ─── Carousel ────────────────────────────────────────────────
class _FincaCarousel extends StatefulWidget {
  final List<String> imagenes;
  final Color color;
  const _FincaCarousel({required this.imagenes, required this.color});

  @override
  State<_FincaCarousel> createState() => _FincaCarouselState();
}

class _FincaCarouselState extends State<_FincaCarousel> {
  late final PageController _pageCtrl;
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    if (widget.imagenes.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted) return;
        final next = (_current + 1) % widget.imagenes.length;
        _pageCtrl.animateToPage(
          next,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagenes.isEmpty) return _placeholder(widget.color);

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageCtrl,
          itemCount: widget.imagenes.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (_, i) {
            final url = widget.imagenes[i];
            return Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => _placeholder(widget.color),
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Stack(fit: StackFit.expand, children: [
                  _placeholder(widget.color),
                  const Center(
                    child: CircularProgressIndicator(
                        color: Colors.white54, strokeWidth: 2),
                  ),
                ]);
              },
            );
          },
        ),
        // Dot indicators (only if more than 1 image)
        if (widget.imagenes.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imagenes.length, (i) {
                final active = i == _current;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  static Widget _placeholder(Color color) => Container(
        color: color,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.landscape,
                  size: 64, color: Colors.white.withValues(alpha: 0.5)),
              const SizedBox(height: 8),
              Text(
                'Sin foto disponible',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13),
              ),
            ],
          ),
        ),
      );
}

// ─── Stat item ────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}

// ─── Info Tab ─────────────────────────────────────────────────
class _InfoTab extends StatelessWidget {
  final FincaModel finca;
  const _InfoTab({required this.finca});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Descripción',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            finca.descripcion,
            style: const TextStyle(
                color: Colors.black87, height: 1.5, fontSize: 14),
          ),
          if (finca.localidad != null) ...[
            const SizedBox(height: 16),
            const Text('Ubicación',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 16, color: Color(0xFF1e5a3a)),
                const SizedBox(width: 6),
                Text(
                  '${finca.localidad}, ${finca.provincia}, ${finca.pais}',
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Especies Tab ─────────────────────────────────────────────
class _EspeciesTab extends StatelessWidget {
  final FincaModel finca;
  const _EspeciesTab({required this.finca});

  @override
  Widget build(BuildContext context) {
    if (finca.especies.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets_outlined, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text('No hay especies registradas',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: finca.especies.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.pets,
              color: Color(0xFF1e5a3a), size: 20),
        ),
        title: Text(finca.especies[i],
            style: const TextStyle(fontWeight: FontWeight.w500)),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

// ─── Servicios Tab ────────────────────────────────────────────
class _ServiciosTab extends StatelessWidget {
  final FincaModel finca;
  const _ServiciosTab({required this.finca});

  static const _icons = {
    'Alojamiento': Icons.bed,
    'Guía': Icons.person,
    'Guía de caza': Icons.person,
    'Transporte': Icons.directions_car,
    'Comidas': Icons.restaurant,
    'Comidas incluidas': Icons.restaurant,
    'Perros de caza': Icons.pets,
    'Equipamiento': Icons.build,
    'Fotografía': Icons.photo_camera,
    'Procesado de piezas': Icons.straighten,
  };

  @override
  Widget build(BuildContext context) {
    if (finca.servicios.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.handyman_outlined, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text('No hay servicios registrados',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return GridView.count(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      childAspectRatio: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: finca.servicios
          .map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(_icons[s] ?? Icons.check,
                        size: 18, color: const Color(0xFF1e5a3a)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(s,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1e5a3a),
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// ─── Normas Tab ────────────────────────────────────────────────
class _NormasTab extends StatelessWidget {
  final FincaModel finca;
  const _NormasTab({required this.finca});

  @override
  Widget build(BuildContext context) {
    if (finca.normas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rule_outlined, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text('Sin normas especificadas',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: finca.normas.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => ListTile(
        leading: const Icon(Icons.rule_outlined,
            color: Color(0xFF1e5a3a), size: 20),
        title: Text(finca.normas[i],
            style: const TextStyle(fontSize: 14)),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

// ─── Mapa Tab ──────────────────────────────────────────────────
class _MapaTab extends StatefulWidget {
  final FincaModel finca;
  const _MapaTab({required this.finca});

  @override
  State<_MapaTab> createState() => _MapaTabState();
}

class _MapaTabState extends State<_MapaTab>
    with AutomaticKeepAliveClientMixin {
  LatLng? _coord;
  bool _loading = true;
  String? _displayName;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _geocode();
  }

  Future<void> _geocode() async {
    final parts = [
      widget.finca.localidad,
      widget.finca.provincia,
      widget.finca.pais.isNotEmpty ? widget.finca.pais : 'España',
    ].where((e) => e != null && e.isNotEmpty).cast<String>().toList();

    if (parts.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    try {
      final response = await Dio().get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': parts.join(', '),
          'format': 'json',
          'limit': 1,
        },
        options: Options(headers: {'User-Agent': 'FuerzaNaturalApp/1.0'}),
      );
      final data = response.data as List;
      if (data.isNotEmpty && mounted) {
        setState(() {
          _coord = LatLng(
            double.parse(data[0]['lat'] as String),
            double.parse(data[0]['lon'] as String),
          );
          _displayName = data[0]['display_name'] as String?;
          _loading = false;
        });
      } else if (mounted) {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openInMaps() async {
    final query = Uri.encodeComponent(
      [widget.finca.localidad, widget.finca.provincia]
          .where((e) => e != null && e.isNotEmpty)
          .cast<String>()
          .join(', '),
    );
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF1e5a3a)),
            SizedBox(height: 12),
            Text('Cargando mapa...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_coord == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            const Text('Ubicación no disponible',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _openInMaps,
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Abrir en Google Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1e5a3a),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: _coord!,
            initialZoom: 12,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName:
                  'com.example.flutter_fuerza_natural_login',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _coord!,
                  child: const Icon(
                    Icons.location_pin,
                    color: Color(0xFF1e5a3a),
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Address chip at the bottom
        Positioned(
          bottom: 12,
          left: 12,
          right: 12,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: _openInMaps,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Color(0xFF1e5a3a), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _displayName ?? widget.finca.ubicacion,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.open_in_new,
                        size: 14, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Booking bottom sheet ──────────────────────────────────────
class _ReservaSheet extends StatefulWidget {
  final FincaModel finca;
  const _ReservaSheet({required this.finca});

  @override
  State<_ReservaSheet> createState() => _ReservaSheetState();
}

class _ReservaSheetState extends State<_ReservaSheet> {
  DateTime? _fecha;
  String _tipo = 'rececho';   // monteria | rececho | visita
  int _personas = 1;
  bool _loading = false;
  String? _error;

  static const _tipos = [
    ('monteria', 'Montería', Icons.forest),
    ('rececho',  'Rececho',  Icons.person_search),
    ('visita',   'Visita',   Icons.visibility_outlined),
  ];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Selecciona la fecha de la jornada',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1e5a3a),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _confirmar() async {
    if (_fecha == null) {
      setState(() => _error = 'Elige una fecha para la jornada.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ReservasRepository().crearReserva(
        fincaId: widget.finca.id,
        fecha: _fecha!,
        tipoReserva: _tipo,
        numeroPersonas: _personas,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva creada correctamente'),
            backgroundColor: Color(0xFF1e5a3a),
          ),
        );
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _fmtDate(DateTime d) {
    const months = ['', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
        'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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
          const Text(
            'Reservar jornada',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.finca.nombre,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // ── Fecha ──
          const Text('Fecha de la jornada',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _fecha != null
                      ? const Color(0xFF1e5a3a)
                      : Colors.grey.shade300,
                  width: _fecha != null ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 18, color: Color(0xFF1e5a3a)),
                  const SizedBox(width: 10),
                  Text(
                    _fecha != null ? _fmtDate(_fecha!) : 'Selecciona una fecha',
                    style: TextStyle(
                      fontSize: 15,
                      color: _fecha != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Tipo de jornada ──
          const Text('Tipo de jornada',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: _tipos.map((t) {
              final selected = _tipo == t.$1;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _tipo = t.$1),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF1e5a3a)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF1e5a3a)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(t.$3,
                            size: 22,
                            color: selected ? Colors.white : Colors.black54),
                        const SizedBox(height: 4),
                        Text(
                          t.$2,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Personas ──
          const Text('Número de personas',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              _CounterBtn(
                icon: Icons.remove,
                onTap: () { if (_personas > 1) setState(() => _personas--); },
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$_personas',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              _CounterBtn(
                icon: Icons.add,
                onTap: () { if (_personas < 30) setState(() => _personas++); },
              ),
            ],
          ),

          // Error
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],

          const SizedBox(height: 20),

          // ── Precio estimado ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Precio estimado',
                    style: TextStyle(color: Colors.black54, fontSize: 13)),
                Text(
                  '€${(widget.finca.precioDia * _personas).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1e5a3a),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Confirmar ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _confirmar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1e5a3a),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Confirmar reserva',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CounterBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF1e5a3a)),
      ),
    );
  }
}

// ── Reseñas tab ──────────────────────────────────────────────────────────────

class _Resena {
  final int puntuacion;
  final String? comentario;
  final String usuarioNombre;
  final String fecha;

  const _Resena({
    required this.puntuacion,
    required this.comentario,
    required this.usuarioNombre,
    required this.fecha,
  });

  factory _Resena.fromJson(Map<String, dynamic> j) {
    final rawFecha = j['fecha_valoracion'] ?? j['created_at'] ?? '';
    String fecha = '';
    try {
      fecha = DateTime.parse(rawFecha.toString()).toLocal().toString().split(' ')[0];
    } catch (_) {
      fecha = rawFecha.toString();
    }
    return _Resena(
      puntuacion: (j['puntuacion'] as num?)?.toInt() ?? 0,
      comentario: j['comentario']?.toString(),
      usuarioNombre: j['usuario_nombre']?.toString() ?? 'Anónimo',
      fecha: fecha,
    );
  }
}

class _ResenasTab extends StatefulWidget {
  final FincaModel finca;
  const _ResenasTab({required this.finca});

  @override
  State<_ResenasTab> createState() => _ResenasTabState();
}

class _ResenasTabState extends State<_ResenasTab>
    with AutomaticKeepAliveClientMixin {
  final _api = ApiService();
  late Future<List<_Resena>> _future;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _future = _loadResenas();
  }

  Future<List<_Resena>> _loadResenas() async {
    final response = await _api.get(ApiConfig.fincaResenas(widget.finca.id));
    final raw = response.data;
    final list = raw is List ? raw : (raw is Map ? (raw['data'] ?? []) : []);
    return (list as List)
        .map((e) => _Resena.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<_Resena>>(
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
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.grey, size: 40),
                const SizedBox(height: 8),
                Text('No se pudieron cargar las reseñas',
                    style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() { _future = _loadResenas(); }),
                  child: const Text('Reintentar',
                      style: TextStyle(color: Color(0xFF1e5a3a))),
                ),
              ],
            ),
          );
        }

        final resenas = snap.data ?? [];
        if (resenas.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.rate_review_outlined,
                    color: Colors.grey.shade300, size: 56),
                const SizedBox(height: 12),
                Text('Aún no hay reseñas para esta finca',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: resenas.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final r = resenas[i];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF1e5a3a),
                        child: Text(
                          r.usuarioNombre.isNotEmpty
                              ? r.usuarioNombre[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.usuarioNombre,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            Text(r.fecha,
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      Row(
                        children: List.generate(5, (s) => Icon(
                          s < r.puntuacion ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFC107),
                          size: 16,
                        )),
                      ),
                    ],
                  ),
                  if (r.comentario != null && r.comentario!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(r.comentario!,
                        style: const TextStyle(fontSize: 13, height: 1.4)),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
