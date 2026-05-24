import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/room_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/room_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';

/// HU21 — Simple room detail (numero, tipo, capacidad, precio, estado).
class RoomDetailScreen extends StatefulWidget {
  final int roomId;

  const RoomDetailScreen({super.key, required this.roomId});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late Future<RoomModel> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<RoomProvider>().getRoom(widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de habitación')),
      body: FutureBuilder<RoomModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return EmptyState(
              icon: Icons.cloud_off,
              title: 'No se pudo cargar',
              message: '${snapshot.error ?? 'Habitación no encontrada'}',
            );
          }
          return _content(snapshot.data!);
        },
      ),
    );
  }

  Widget _content(RoomModel room) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _hero(room),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(room.nombre,
                        style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  StatusBadge(status: room.estado),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${room.tipoLabel} · Nº ${room.numero}',
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              _specsGrid(room),
              const SizedBox(height: 20),
              if (room.descripcion.isNotEmpty) ...[
                Text('Descripción',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  room.descripcion,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              _actions(isAdmin),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hero(RoomModel room) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.chocolate, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: room.imagen.isNotEmpty
          ? Image.network(
              room.imagen,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _heroIcon(),
            )
          : _heroIcon(),
    );
  }

  Widget _heroIcon() => const Center(
        child: Icon(Icons.king_bed_outlined, color: Colors.white70, size: 64),
      );

  Widget _specsGrid(RoomModel room) {
    final specs = <(IconData, String, String)>[
      (Icons.people_outline, 'Capacidad', '${room.capacidad} personas'),
      (Icons.bed_outlined, 'Camas', room.camas.isEmpty ? '—' : room.camas),
      (
        Icons.straighten,
        'Tamaño',
        room.sizeM2 == null ? '—' : '${room.sizeM2} m²'
      ),
      (
        Icons.payments_outlined,
        'Precio base',
        '\$${room.precioBase.toStringAsFixed(2)} / noche'
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.6,
      children: [
        for (final s in specs)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(s.$1, color: AppColors.chocolate, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(s.$2,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 11)),
                      Text(s.$3,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Placeholder actions (Sprint 2 controlled scope: visual only).
  Widget _actions(bool isAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () => _notImplemented('Reservar'),
          icon: const Icon(Icons.event_available, size: 18),
          label: const Text('Reservar (próximamente)'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        if (isAdmin) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _notImplemented('Cambiar estado'),
            icon: const Icon(Icons.build_outlined, size: 18),
            label: const Text('Cambiar estado (admin · próximamente)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.chocolate,
              side: const BorderSide(color: AppColors.chocolate),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _notImplemented(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$action" se habilita en próximos sprints.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
