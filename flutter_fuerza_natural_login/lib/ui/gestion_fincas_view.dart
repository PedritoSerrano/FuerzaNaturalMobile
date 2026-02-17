import 'package:flutter/material.dart';

class GestionFincasView extends StatefulWidget {
  const GestionFincasView({super.key});

  @override
  State<GestionFincasView> createState() => _GestionFincasViewState();
}

class _GestionFincasViewState extends State<GestionFincasView> {
  String _selectedFilter = 'Todas';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildStatsCards(),
          _buildFilters(),
          _buildFincasList(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1e5a3a), Color(0xFF2d7a54)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Fincas',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gestiona tus propiedades',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(204),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF1e5a3a)),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar fincas...',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Total',
              value: '23',
              subtitle: '+2 este mes',
              icon: Icons.landscape,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Hectáreas',
              value: '5.4K',
              subtitle: 'Total',
              icon: Icons.straighten,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Ingresos',
              value: '€24K',
              subtitle: 'Este mes',
              icon: Icons.euro,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF1e5a3a),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e5a3a),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [
      'Todas',
      'Activas',
      'Mantenimiento',
      'Caza mayor',
      'Caza menor',
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF1e5a3a),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF1e5a3a)
                      : const Color(0xFFE5E7EB),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFincasList() {
    final fincas = [
      {
        'name': 'Finca El Roble',
        'location': 'Extremadura, España',
        'status': 'Activa',
        'rating': 4.8,
        'type': 'Caza Mayor',
        'area': '250 ha',
        'reservas': 12,
        'ingresos': 3200,
        'proxima': '15 feb',
      },
      {
        'name': 'Monte Verde',
        'location': 'Castilla y León',
        'status': 'Activa',
        'rating': 4.6,
        'type': 'Caza Menor',
        'area': '180 ha',
        'reservas': 8,
        'ingresos': 2400,
        'proxima': '18 feb',
      },
      {
        'name': 'Sierra Alta',
        'location': 'Andalucía, España',
        'status': 'Activa',
        'rating': 4.9,
        'type': 'Caza Mayor',
        'area': '320 ha',
        'reservas': 15,
        'ingresos': 4100,
        'proxima': '12 feb',
      },
      {
        'name': 'Valle Escondido',
        'location': 'Aragón, España',
        'status': 'Mantenimiento',
        'rating': 4.5,
        'type': 'Mixta',
        'area': '150 ha',
        'reservas': 3,
        'ingresos': 1200,
        'proxima': '1 mar',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: fincas.map((finca) => _buildFincaCard(finca)).toList(),
      ),
    );
  }

  Widget _buildFincaCard(Map<String, dynamic> finca) {
    final isActive = finca['status'] == 'Activa';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withAlpha(26)
                      : Colors.orange.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  finca['status'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 16,
                    color: Color(0xFFFBBF24),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    finca['rating'].toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            finca['name'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e5a3a),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 14,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                finca['location'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tipo de Caza',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      finca['type'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Extensión',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      finca['area'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFincaStat('Reservas', finca['reservas'].toString()),
              Container(
                width: 1,
                height: 30,
                color: const Color(0xFFE5E7EB),
              ),
              _buildFincaStat('Ingresos', '€${finca['ingresos']}'),
              Container(
                width: 1,
                height: 30,
                color: const Color(0xFFE5E7EB),
              ),
              _buildFincaStat('Próxima', finca['proxima']),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.remove_red_eye, size: 18),
                  label: const Text('Ver Detalles'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1e5a3a),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1e5a3a),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: Color(0xFF1e5a3a),
                      width: 2,
                    ),
                  ),
                ),
                child: const Icon(Icons.location_on, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFincaStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e5a3a),
          ),
        ),
      ],
    );
  }
}
