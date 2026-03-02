import 'package:flutter/material.dart';
import 'package:flutter_fuerza_natural_login/core/models/finca_model.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
        background: Container(
          color: _imgColor,
          child: Center(
            child: Icon(Icons.landscape,
                size: 80, color: Colors.white.withOpacity(0.3)),
          ),
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
            color: Colors.black.withOpacity(0.08),
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
                  color: const Color(0xFF2E7D32),
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
                const TextSpan(
                  text: ' por día',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
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
          labelColor: const Color(0xFF2E7D32),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2E7D32),
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        color: Colors.white,
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Selección de fechas próximamente')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.calendar_today),
          label: const Text(
            'Seleccionar fechas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
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
                    size: 16, color: Color(0xFF2E7D32)),
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
    return ListView.separated(
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
              color: Color(0xFF2E7D32), size: 20),
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
    'Transporte': Icons.directions_car,
    'Comidas': Icons.restaurant,
    'Perros de caza': Icons.pets,
  };

  @override
  Widget build(BuildContext context) {
    return GridView.count(
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
                        size: 18, color: const Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(s,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF2E7D32),
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
      return const Center(child: Text('Sin normas especificadas'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: finca.normas.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => ListTile(
        leading: const Icon(Icons.rule_outlined,
            color: Color(0xFF2E7D32), size: 20),
        title: Text(finca.normas[i],
            style: const TextStyle(fontSize: 14)),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
