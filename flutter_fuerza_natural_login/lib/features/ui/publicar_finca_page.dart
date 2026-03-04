import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuerza_natural_login/core/services/mock_data_service.dart';
import 'package:flutter_fuerza_natural_login/features/bloc/publicar_finca/publicar_finca_bloc.dart';
import 'package:image_picker/image_picker.dart';

class PublicarFincaPage extends StatelessWidget {
  const PublicarFincaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PublicarFincaBloc(),
      child: const _PublicarFincaView(),
    );
  }
}

class _PublicarFincaView extends StatelessWidget {
  const _PublicarFincaView();

  static const _pasoLabels = [
    'Básico',
    'Detalles',
    'Especies',
    'Servicios',
    'Normas',
    'Fotos',
  ];

  static const _pasoIcons = [
    Icons.info_outline,
    Icons.euro_outlined,
    Icons.pets_outlined,
    Icons.handyman_outlined,
    Icons.rule_outlined,
    Icons.photo_library_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PublicarFincaBloc, PublicarFincaState>(
      listener: (context, state) {
        if (state.publicada) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('¡Finca publicada con éxito!'),
                backgroundColor: Color(0xFF1e5a3a)),
          );
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red.shade700),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              _buildHeader(context, state),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildPasoActual(context, state),
                ),
              ),
              _buildBottomBar(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, PublicarFincaState state) {
    return Container(
      color: const Color(0xFF1e5a3a),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => state.paso > 0
                    ? context
                        .read<PublicarFincaBloc>()
                        .add(const PublicarFincaAnteriorPaso())
                    : Navigator.pop(context),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Publicar Finca',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Paso ${state.paso + 1} de ${PublicarFincaState.totalPasos}',
                      style: const TextStyle(
                          color: Color(0xFFB9F6CA), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(PublicarFincaState.totalPasos, (i) {
              final done = i < state.paso;
              final active = i == state.paso;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: done
                            ? Colors.white
                            : active
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: active
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      child: Icon(
                        done ? Icons.check : _pasoIcons[i],
                        size: 16,
                        color: done || active
                            ? const Color(0xFF1e5a3a)
                            : Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _pasoLabels[i],
                      style: TextStyle(
                        color: (done || active)
                            ? Colors.white
                            : Colors.white54,
                        fontSize: 10,
                        fontWeight: active
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPasoActual(
      BuildContext context, PublicarFincaState state) {
    switch (state.paso) {
      case 0:
        return _PasoBasico(state: state);
      case 1:
        return _PasoDetalles(state: state);
      case 2:
        return _PasoEspecies(state: state);
      case 3:
        return _PasoServicios(state: state);
      case 4:
        return _PasoNormas(state: state);
      case 5:
        return _PasoFotos(state: state);
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomBar(
      BuildContext context, PublicarFincaState state) {
    final isLastStep =
        state.paso == PublicarFincaState.totalPasos - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: state.pasoValido
              ? () {
                  if (isLastStep) {
                    context
                        .read<PublicarFincaBloc>()
                        .add(const PublicarFincaPublicar());
                  } else {
                    context
                        .read<PublicarFincaBloc>()
                        .add(const PublicarFincaSiguientePaso());
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1e5a3a),
            disabledBackgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: state.publicando
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastStep ? 'Publicar finca' : 'Continuar',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                        isLastStep
                            ? Icons.check
                            : Icons.chevron_right,
                        size: 20),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Paso 1: Básico ───────────────────────────────────────────
class _PasoBasico extends StatefulWidget {
  final PublicarFincaState state;
  const _PasoBasico({required this.state});

  @override
  State<_PasoBasico> createState() => _PasoBasicoState();
}

class _PasoBasicoState extends State<_PasoBasico> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _localidadCtrl;
  late final TextEditingController _descCtrl;
  String? _provincia;

  @override
  void initState() {
    super.initState();
    _nombreCtrl =
        TextEditingController(text: widget.state.nombre);
    _localidadCtrl =
        TextEditingController(text: widget.state.localidad);
    _descCtrl =
        TextEditingController(text: widget.state.descripcion);
    _provincia = widget.state.provincia.isNotEmpty
        ? widget.state.provincia
        : null;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _localidadCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _update() {
    context.read<PublicarFincaBloc>().add(
          PublicarFincaActualizarBasico(
            nombre: _nombreCtrl.text,
            provincia: _provincia ?? '',
            localidad: _localidadCtrl.text,
            descripcion: _descCtrl.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información básica',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text('Cuéntanos sobre tu finca',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 24),
        _FieldLabel(text: 'Nombre de la finca', required: true),
        const SizedBox(height: 6),
        _InputField(
          controller: _nombreCtrl,
          hint: 'Ej: Finca El Robledal',
          onChanged: (_) => _update(),
        ),
        const SizedBox(height: 18),
        _FieldLabel(text: 'Provincia', required: true),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _provincia,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
          ),
          hint: const Text('Selecciona una provincia'),
          items: MockDataService.provincias
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (v) {
            setState(() => _provincia = v);
            _update();
          },
        ),
        const SizedBox(height: 18),
        Row(
          children: const [
            Icon(Icons.location_on,
                size: 16, color: Colors.grey),
            SizedBox(width: 4),
            Text('Localidad / Paraje',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        _InputField(
          controller: _localidadCtrl,
          hint: 'Ej: Sierra de Gredos, Ávila',
          onChanged: (_) => _update(),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _FieldLabel(text: 'Descripción', required: true),
            BlocBuilder<PublicarFincaBloc, PublicarFincaState>(
              builder: (_, st) => Text(
                '${st.descripcion.length} / 500 caracteres',
                style: const TextStyle(
                    color: Colors.grey, fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _descCtrl,
          maxLines: 5,
          maxLength: 500,
          onChanged: (_) => _update(),
          decoration: InputDecoration(
            hintText:
                'Describe tu finca, el terreno, la vegetación, la experiencia que ofreces... (mínimo 20 caracteres)',
            hintStyle:
                const TextStyle(color: Colors.grey, fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            counterText: '',
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }
}

// ─── Paso 2: Detalles ─────────────────────────────────────────
class _PasoDetalles extends StatefulWidget {
  final PublicarFincaState state;
  const _PasoDetalles({required this.state});

  @override
  State<_PasoDetalles> createState() => _PasoDetallesState();
}

class _PasoDetallesState extends State<_PasoDetalles> {
  late final TextEditingController _supCtrl;
  late final TextEditingController _precioCtrl;
  late final TextEditingController _capCtrl;

  @override
  void initState() {
    super.initState();
    _supCtrl = TextEditingController(
        text: widget.state.superficie > 0
            ? widget.state.superficie.toStringAsFixed(0)
            : '');
    _precioCtrl = TextEditingController(
        text: widget.state.precioDia > 0
            ? widget.state.precioDia.toStringAsFixed(0)
            : '');
    _capCtrl = TextEditingController(
        text: widget.state.capacidad > 0
            ? widget.state.capacidad.toString()
            : '');
  }

  @override
  void dispose() {
    _supCtrl.dispose();
    _precioCtrl.dispose();
    _capCtrl.dispose();
    super.dispose();
  }

  void _update() {
    context.read<PublicarFincaBloc>().add(
          PublicarFincaActualizarDetalles(
            superficie: double.tryParse(_supCtrl.text) ?? 0,
            precioDia: double.tryParse(_precioCtrl.text) ?? 0,
            capacidad: int.tryParse(_capCtrl.text) ?? 0,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Detalles de la finca',
            style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Precios y características',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 24),
        _FieldLabel(text: 'Superficie (hectáreas)', required: true),
        const SizedBox(height: 6),
        _InputField(
          controller: _supCtrl,
          hint: 'Ej: 500',
          keyboardType: TextInputType.number,
          onChanged: (_) => _update(),
        ),
        const SizedBox(height: 18),
        _FieldLabel(text: 'Precio por día (€)', required: true),
        const SizedBox(height: 6),
        _InputField(
          controller: _precioCtrl,
          hint: 'Ej: 350',
          keyboardType: TextInputType.number,
          onChanged: (_) => _update(),
        ),
        const SizedBox(height: 18),
        _FieldLabel(text: 'Capacidad máxima (cazadores)'),
        const SizedBox(height: 6),
        _InputField(
          controller: _capCtrl,
          hint: 'Ej: 8',
          keyboardType: TextInputType.number,
          onChanged: (_) => _update(),
        ),
      ],
    );
  }
}

// ─── Paso 3: Especies ─────────────────────────────────────────
class _PasoEspecies extends StatelessWidget {
  final PublicarFincaState state;
  const _PasoEspecies({required this.state});

  static const _especiesDisponibles = [
    'Ciervo', 'Jabalí', 'Corzo', 'Gamo', 'Rebeco',
    'Muflón', 'Perdiz', 'Codorniz', 'Pato', 'Becada',
    'Conejo', 'Liebre', 'Oso', 'Lobo',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Especies de caza',
            style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Selecciona las especies disponibles',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _especiesDisponibles
              .map((e) {
                final selected = state.especies.contains(e);
                return GestureDetector(
                  onTap: () {
                    final newList = List<String>.from(state.especies);
                    if (selected) {
                      newList.remove(e);
                    } else {
                      newList.add(e);
                    }
                    context
                        .read<PublicarFincaBloc>()
                        .add(PublicarFincaActualizarEspecies(newList));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF1e5a3a)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF1e5a3a)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pets, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          e,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })
              .toList(),
        ),
      ],
    );
  }
}

// ─── Paso 4: Servicios ────────────────────────────────────────
class _PasoServicios extends StatelessWidget {
  final PublicarFincaState state;
  const _PasoServicios({required this.state});

  static const _serviciosDisponibles = [
    ('Alojamiento', Icons.bed),
    ('Guía de caza', Icons.person),
    ('Transporte', Icons.directions_car),
    ('Comidas incluidas', Icons.restaurant),
    ('Perros de caza', Icons.pets),
    ('Equipamiento', Icons.build),
    ('Fotografía', Icons.photo_camera),
    ('Procesado de piezas', Icons.straighten),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Servicios incluidos',
            style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('¿Qué ofreces a tus clientes?',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 24),
        ..._serviciosDisponibles.map((s) {
          final selected = state.servicios.contains(s.$1);
          return CheckboxListTile(
            value: selected,
            onChanged: (_) {
              final newList = List<String>.from(state.servicios);
              if (selected) {
                newList.remove(s.$1);
              } else {
                newList.add(s.$1);
              }
              context
                  .read<PublicarFincaBloc>()
                  .add(PublicarFincaActualizarServicios(newList));
            },
            title: Text(s.$1),
            secondary: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFE8F5E9)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(s.$2,
                  size: 20,
                  color: selected
                      ? const Color(0xFF1e5a3a)
                      : Colors.grey),
            ),
            activeColor: const Color(0xFF1e5a3a),
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }
}

// ─── Paso 5: Normas ────────────────────────────────────────────
class _PasoNormas extends StatefulWidget {
  final PublicarFincaState state;
  const _PasoNormas({required this.state});

  @override
  State<_PasoNormas> createState() => _PasoNormasState();
}

class _PasoNormasState extends State<_PasoNormas> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.state.normas);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Normas de la finca',
            style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text(
            'Escribe las normas y condiciones para los cazadores',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 24),
        TextField(
          controller: _ctrl,
          maxLines: 8,
          onChanged: (v) => context
              .read<PublicarFincaBloc>()
              .add(PublicarFincaActualizarNormas(v)),
          decoration: InputDecoration(
            hintText:
                'Ej: No disparar desde vehículos\nRespetar vedas\nLicencia obligatoria\n...',
            hintStyle:
                const TextStyle(color: Colors.grey, fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }
}

// ─── Paso 6: Fotos ─────────────────────────────────────────────
class _PasoFotos extends StatelessWidget {
  final PublicarFincaState state;
  const _PasoFotos({required this.state});

  static final _picker = ImagePicker();

  Future<void> _pickImages(BuildContext context) async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 80);
      if (picked.isEmpty) return;
      final current = List<String>.from(state.fotos);
      for (final x in picked) {
        if (!current.contains(x.path)) current.add(x.path);
      }
      if (context.mounted) {
        context.read<PublicarFincaBloc>().add(PublicarFincaActualizarFotos(current));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo acceder a la galería')),
        );
      }
    }
  }

  void _removePhoto(BuildContext context, int index) {
    final updated = List<String>.from(state.fotos)..removeAt(index);
    context.read<PublicarFincaBloc>().add(PublicarFincaActualizarFotos(updated));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fotos de la finca',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Añade fotos atractivas para captar cazadores',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 24),

        // Grid of selected photos
        if (state.fotos.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: state.fotos.length + 1, // +1 for "add more" button
            itemBuilder: (context, i) {
              if (i == state.fotos.length) {
                // "Add more" tile
                return GestureDetector(
                  onTap: () => _pickImages(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 28, color: Color(0xFF1e5a3a)),
                        SizedBox(height: 4),
                        Text('Añadir',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF1e5a3a))),
                      ],
                    ),
                  ),
                );
              }
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(state.fotos[i]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removePhoto(context, i),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            '${state.fotos.length} foto${state.fotos.length == 1 ? '' : 's'} seleccionada${state.fotos.length == 1 ? '' : 's'}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
        ] else ...[
          // Empty state — tap to add
          GestureDetector(
            onTap: () => _pickImages(context),
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    style: BorderStyle.solid),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 48, color: Color(0xFF1e5a3a)),
                  SizedBox(height: 12),
                  Text('Toca para añadir fotos',
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 4),
                  Text('PNG, JPG hasta 10MB',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        const Text('Consejos para mejores resultados:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 10),
        ...[
          'Usa fotos tomadas durante el día con buena luz',
          'Incluye fotos del terreno, alojamiento y accesos',
          'Mínimo 3 fotos para mejor visibilidad',
          'Resolución mínima recomendada: 1200x800px',
        ].map((tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 16, color: Color(0xFF1e5a3a)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(tip,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54)),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

// ─── Shared widgets ────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const _FieldLabel({required this.text, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
        if (required)
          const Text(' *',
              style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1e5a3a)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
