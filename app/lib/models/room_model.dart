import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

enum RoomStatus {
  disponible,
  ocupada,
  mantenimiento,
  unknown;

  static RoomStatus fromApi(String? value) {
    switch (value) {
      case 'disponible':
        return RoomStatus.disponible;
      case 'ocupada':
        return RoomStatus.ocupada;
      case 'mantenimiento':
        return RoomStatus.mantenimiento;
      default:
        return RoomStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case RoomStatus.disponible:
        return 'Disponible';
      case RoomStatus.ocupada:
        return 'Ocupada';
      case RoomStatus.mantenimiento:
        return 'Mantenimiento';
      case RoomStatus.unknown:
        return 'Desconocido';
    }
  }

  Color get color {
    switch (this) {
      case RoomStatus.disponible:
        return AppColors.success;
      case RoomStatus.ocupada:
        return AppColors.danger;
      case RoomStatus.mantenimiento:
        return AppColors.warning;
      case RoomStatus.unknown:
        return AppColors.textMuted;
    }
  }

  IconData get icon {
    switch (this) {
      case RoomStatus.disponible:
        return Icons.check_circle_outline;
      case RoomStatus.ocupada:
        return Icons.person_outline;
      case RoomStatus.mantenimiento:
        return Icons.build_outlined;
      case RoomStatus.unknown:
        return Icons.help_outline;
    }
  }
}

/// Hotel room. Field names follow the existing web backend conventions.
class RoomModel {
  final int id;
  final String numero;
  final String nombre;
  final String tipo;
  final int capacidad;
  final double precioBase;
  final int? sizeM2;
  final String camas;
  final RoomStatus estado;
  final String descripcion;
  final String imagen;

  const RoomModel({
    required this.id,
    required this.numero,
    required this.nombre,
    required this.tipo,
    required this.capacidad,
    required this.precioBase,
    required this.sizeM2,
    required this.camas,
    required this.estado,
    required this.descripcion,
    required this.imagen,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as int,
      numero: (json['numero'] ?? '') as String,
      nombre: (json['nombre'] ?? '') as String,
      tipo: (json['tipo'] ?? '') as String,
      capacidad: (json['capacidad'] ?? 0) as int,
      precioBase: double.tryParse('${json['precioBase']}') ?? 0,
      sizeM2: json['sizeM2'] as int?,
      camas: (json['camas'] ?? '') as String,
      estado: RoomStatus.fromApi(json['estado'] as String?),
      descripcion: (json['descripcion'] ?? '') as String,
      imagen: (json['imagen'] ?? '') as String,
    );
  }

  String get tipoLabel =>
      tipo.isEmpty ? '' : tipo[0].toUpperCase() + tipo.substring(1);
}
