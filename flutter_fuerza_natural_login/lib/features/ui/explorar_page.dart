import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuerza_natural_login/core/models/finca_model.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/explorar/explorar_bloc.dart';
import 'package:flutter_fuerza_natural_login/features/ui/detalle_finca_page.dart';

class ExplorarPage extends StatelessWidget {
  const ExplorarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExplorarBloc()..add(const ExplorarLoadRequested()),
      child: const _ExplorarView(),
    );
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
          return CustomScrollView(
            slivers: [
              _buildHeader(context),
              if (state is ExplorarLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  ),
                )
              else if (state is ExplorarLoaded)
                ..._buildContent(context, state)
              else if (state is ExplorarError)
                SliverFillRemaining(
                  child: Center(child: Text(state.mensaje)),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.tune, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context, ExplorarLoaded state) {
    if (state.enBusqueda) {
      return [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _FincaCardVertical(finca: state.resultadosBusqueda[i]),
              childCount: state.resultadosBusqueda.length,
            ),
          ),
        ),
      ];
    }

    return [
      // Destacadas
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: const [
              Icon(Icons.star, color: Color(0xFFFFA000), size: 22),
              SizedBox(width: 8),
              Text(
                'Destacadas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => _FincaCardVertical(
              finca: state.destacadas[i],
              destacada: true,
            ),
            childCount: state.destacadas.length,
          ),
        ),
      ),

      // Todas las fincas
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Todas las fincas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${state.todas.length} disponibles',
                style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => _FincaCardVertical(finca: state.todas[i]),
            childCount: state.todas.length,
          ),
        ),
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────
// Finca Card
// ─────────────────────────────────────────────────────────────
class _FincaCardVertical extends StatelessWidget {
  final FincaModel finca;
  final bool destacada;

  const _FincaCardVertical({required this.finca, this.destacada = false});

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
              color: Colors.black.withOpacity(0.08),
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
                  Container(
                    height: 180,
                    width: double.infinity,
                    color: _imgColor,
                    child: Center(
                      child: Icon(Icons.landscape,
                          size: 60,
                          color: Colors.white.withOpacity(0.3)),
                    ),
                  ),
                  if (destacada || finca.destacada)
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
                  // Finca name over image
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
                            Colors.black.withOpacity(0.7),
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

            // Details
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
                          color: const Color(0xFF2E7D32),
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
                                color: Color(0xFF2E7D32),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: '\npor día',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11),
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
                              color: Color(0xFF2E7D32),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right,
                              color: Color(0xFF2E7D32), size: 18),
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
          color: Color(0xFF2E7D32),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
