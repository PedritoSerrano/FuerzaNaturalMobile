import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuerza_natural_login/core/models/finca_model.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/explorar/explorar_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/ui/detalle_finca_page.dart';
import 'package:flutter_fuerza_natural_login/features/ui/widgets/app_error_widget.dart';

class ExplorarPage extends StatelessWidget {
  const ExplorarPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    return const _ExplorarView();
  }
}

class _ExplorarView extends StatefulWidget {
  const _ExplorarView();

  @override
  State<_ExplorarView> createState() => _ExplorarViewState();
}

class _ExplorarViewState extends State<_ExplorarView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocBuilder<ExplorarBloc, ExplorarState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: const Color(0xFF1e5a3a),
            onRefresh: () async {
              context.read<ExplorarBloc>().add(const ExplorarLoadRequested());
              
              await context.read<ExplorarBloc>().stream.firstWhere(
                    (s) => s is! ExplorarLoading,
                  );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildHeader(context),
                if (state is ExplorarLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF1e5a3a)),
                    ),
                  )
                else if (state is ExplorarLoaded)
                  ..._buildContent(context, state)
                else if (state is ExplorarError)
                  SliverAppError(
                    mensaje: state.mensaje,
                    onRetry: () => context
                        .read<ExplorarBloc>()
                        .add(const ExplorarLoadRequested()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              'Fuerza Natural',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Explora las mejores fincas de caza',
              style: TextStyle(color: Color(0xFFB9F6CA), fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildSearchBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => context
                  .read<ExplorarBloc>()
                  .add(ExplorarSearchChanged(v)),
              decoration: const InputDecoration(
                hintText: 'Buscar fincas, ubicaciones, especies...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          
          BlocBuilder<ExplorarBloc, ExplorarState>(
            builder: (context, state) {
              final hayFiltros =
                  state is ExplorarLoaded && state.hayFiltros;
              return GestureDetector(
                onTap: () => _showFiltros(context, state),
                child: Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hayFiltros
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFF1e5a3a),
                    borderRadius: BorderRadius.circular(8),
                    border: hayFiltros
                        ? Border.all(color: const Color(0xFF1e5a3a), width: 2)
                        : null,
                  ),
                  child: Icon(
                    Icons.tune,
                    color: hayFiltros
                        ? const Color(0xFF1e5a3a)
                        : Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showFiltros(BuildContext context, ExplorarState state) {
    final loaded = state is ExplorarLoaded ? state : null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ExplorarBloc>(),
        child: _FiltrosSheet(
          initialProvincia: loaded?.filtroProvincias ?? '',
          initialMaxPrecio: loaded?.filtroMaxPrecio ?? 2000,
          initialMinSuperficie: loaded?.filtroMinSuperficie ?? 0,
        ),
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context, ExplorarLoaded state) {
    final fincas = state.mostradas;

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fincas disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${fincas.length} fincas',
                style: const TextStyle(color: Color(0xFF1e5a3a), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
      if (fincas.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, color: Colors.grey.shade300, size: 56),
                const SizedBox(height: 12),
                Text(
                  state.enBusqueda
                      ? state.hayFiltros && state.searchQuery.isEmpty
                          ? 'No hay fincas que coincidan con los filtros'
                          : 'No hay fincas que coincidan con la búsqueda'
                      : 'No hay fincas disponibles',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _FincaCardVertical(finca: fincas[i]),
              childCount: fincas.length,
            ),
          ),
        ),
    ];
  }
}

class _FincaCardVertical extends StatelessWidget {
  final FincaModel finca;

  const _FincaCardVertical({required this.finca});

  static const List<Color> _imgColors = [
    Color(0xFF5D8A5E),
    Color(0xFF4A6741),
    Color(0xFF7B9E7D),
    Color(0xFF3B5E3D),
  ];

  Color get _imgColor {
    final idx = int.tryParse(finca.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return _imgColors[idx % _imgColors.length];
  }

  static Widget _imgPlaceholder(Color color) => Container(
        color: color,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.landscape, size: 52,
                  color: Colors.white.withValues(alpha: 0.4)),
              const SizedBox(height: 4),
              Text('Sin foto',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6))),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetalleFincaPage(finca: finca),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: finca.imageUrl != null && finca.imageUrl!.isNotEmpty
                        ? Image.network(
                            finca.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _imgPlaceholder(_imgColor),
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                    ? child
                                    : _imgPlaceholder(_imgColor),
                          )
                        : _imgPlaceholder(_imgColor),
                  ),
                  if (finca.destacada)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Destacada',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
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
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 24, 14, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            finca.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                finca.ubicacion,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
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

            
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1e5a3a),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              finca.valoracion.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${finca.numeroResenas} reseñas)',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const Spacer(),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '€${finca.precioDia.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFF1e5a3a),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.crop_free,
                          size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        '${finca.superficie.toStringAsFixed(0)} hectáreas',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(width: 8),
                      const Text('•',
                          style: TextStyle(color: Colors.black38)),
                      const SizedBox(width: 8),
                      const Icon(Icons.pets, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        '${finca.especies.length} especies',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: finca.especies
                        .take(3)
                        .map((e) => _EspecieChip(label: e))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleFincaPage(finca: finca),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ver detalles',
                            style: TextStyle(
                              color: Color(0xFF1e5a3a),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right,
                              color: Color(0xFF1e5a3a), size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EspecieChip extends StatelessWidget {
  final String label;
  const _EspecieChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF81C784)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF1e5a3a),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _FiltrosSheet extends StatefulWidget {
  final String initialProvincia;
  final double initialMaxPrecio;
  final double initialMinSuperficie;

  const _FiltrosSheet({
    required this.initialProvincia,
    required this.initialMaxPrecio,
    required this.initialMinSuperficie,
  });

  @override
  State<_FiltrosSheet> createState() => _FiltrosSheetState();
}

class _FiltrosSheetState extends State<_FiltrosSheet> {
  late final TextEditingController _provinciaCtrl;
  late double _maxPrecio;
  late double _minSuperficie;

  static const double _maxPrecioLimit = 2000;
  static const double _maxSuperficieLimit = 1500;

  @override
  void initState() {
    super.initState();
    _provinciaCtrl = TextEditingController(text: widget.initialProvincia);
    _maxPrecio = widget.initialMaxPrecio.clamp(0, _maxPrecioLimit).toDouble();
    _minSuperficie =
        widget.initialMinSuperficie.clamp(0, _maxSuperficieLimit).toDouble();
  }

  @override
  void dispose() {
    _provinciaCtrl.dispose();
    super.dispose();
  }

  void _aplicar() {
    final p = _provinciaCtrl.text.trim();
    context.read<ExplorarBloc>().add(
          ExplorarFiltrosChanged(
            provincia: p.isEmpty ? null : p,
            maxPrecio: _maxPrecio >= _maxPrecioLimit ? null : _maxPrecio,
            minSuperficie: _minSuperficie <= 0 ? null : _minSuperficie,
          ),
        );
    Navigator.pop(context);
  }

  void _limpiar() {
    context.read<ExplorarBloc>().add(const ExplorarFiltrosChanged());
    Navigator.pop(context);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filtros',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: _limpiar,
                    child: const Text('Limpiar',
                        style: TextStyle(color: Color(0xFF1e5a3a))),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              
              const Text('Provincia',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _provinciaCtrl,
                decoration: InputDecoration(
                  hintText: 'Ej: Sevilla, Córdoba...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      color: Color(0xFF1e5a3a)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1e5a3a)),
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 20),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Precio máximo',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(
                    _maxPrecio >= _maxPrecioLimit
                        ? 'Sin límite'
                        : '€${_maxPrecio.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Color(0xFF1e5a3a),
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Slider(
                value: _maxPrecio,
                min: 0,
                max: _maxPrecioLimit,
                divisions: 40,
                activeColor: const Color(0xFF1e5a3a),
                inactiveColor: const Color(0xFFB9F6CA),
                onChanged: (v) => setState(() => _maxPrecio = v),
              ),
              const SizedBox(height: 12),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Superficie mínima',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(
                    _minSuperficie <= 0
                        ? 'Sin mínimo'
                        : '${_minSuperficie.toStringAsFixed(0)} ha',
                    style: const TextStyle(
                        color: Color(0xFF1e5a3a),
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Slider(
                value: _minSuperficie,
                min: 0,
                max: _maxSuperficieLimit,
                divisions: 50,
                activeColor: const Color(0xFF1e5a3a),
                inactiveColor: const Color(0xFFB9F6CA),
                onChanged: (v) => setState(() => _minSuperficie = v),
              ),
              const SizedBox(height: 20),

              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _aplicar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1e5a3a),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Aplicar filtros',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
