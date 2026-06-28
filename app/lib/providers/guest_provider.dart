import 'package:flutter/material.dart';
import '../models/parking_record_model.dart';
import '../models/parking_space_model.dart';
import '../models/reservation_model.dart';
import '../repositories/guest_repository.dart';

enum GuestStatus { idle, loading, success, error }

class GuestProvider extends ChangeNotifier {
  final GuestRepository _repository;

  GuestProvider(this._repository);

  GuestStatus _status = GuestStatus.idle;
  String? _error;
  ReservationModel? _activeReservation;
  ParkingRecordModel? _activeParkingRecord;
  List<ParkingSpaceModel> _availableSpaces = [];

  GuestStatus get status => _status;
  String? get error => _error;
  ReservationModel? get activeReservation => _activeReservation;
  ParkingRecordModel? get activeParkingRecord => _activeParkingRecord;
  List<ParkingSpaceModel> get availableSpaces => _availableSpaces;
  bool get isLoading => _status == GuestStatus.loading;
  bool get hasActiveReservation => _activeReservation != null;

  Future<void> loadGuestData() async {
    _status = GuestStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _activeReservation = await _repository.getMyReservation();
      _activeParkingRecord = await _repository.getMyParkingRecord();
      _status = GuestStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = GuestStatus.error;
    }
    notifyListeners();
  }

  Future<List<ParkingSpaceModel>> loadAvailableSpaces() async {
    try {
      _availableSpaces = await _repository.getAvailableSpaces();
    } catch (_) {
      _availableSpaces = [];
    }
    notifyListeners();
    return _availableSpaces;
  }

  Future<bool> registerVehicle({
    required String placa,
    required String marca,
    required String modelo,
    required int espacioId,
    String? color,
    String? observacion,
  }) async {
    try {
      final record = await _repository.registerVehicle(
        placa: placa,
        marca: marca,
        modelo: modelo,
        espacioId: espacioId,
        color: color,
        observacion: observacion,
      );
      _activeParkingRecord = record;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshData() async {
    await loadGuestData();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
