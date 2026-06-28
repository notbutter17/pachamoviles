import 'package:dio/dio.dart';

import '../core/errors/api_exception.dart';
import '../models/parking_record_model.dart';
import '../models/parking_space_model.dart';
import '../models/reservation_model.dart';
import '../services/api_client.dart';

class GuestRepository {
  final ApiClient _apiClient;

  GuestRepository(this._apiClient);

  Future<ReservationModel> getMyReservation() async {
    try {
      final response = await _apiClient.dio.get('/reservas/mi-reserva');

      final data = response.data;
      if (data == null || (data is List && data.isEmpty)) {
        throw const ApiException('No tienes una reserva activa');
      }

      final reservationData = data is List ? data.first : data;
      return ReservationModel.fromJson(reservationData);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } catch (e) {
      throw ApiException('Error inesperado al cargar tu reserva: $e');
    }
  }

  Future<ParkingRecordModel?> getMyParkingRecord() async {
    try {
      final response =
          await _apiClient.dio.get('/cochera/guest/mis-registros');

      final data = response.data;
      if (data == null || (data is List && data.isEmpty)) return null;

      final recordData = data is List ? data.first : data;
      return ParkingRecordModel.fromJson(recordData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) {
        return null;
      }
      throw ApiException.fromDio(e);
    } catch (e) {
      throw ApiException('Error inesperado al cargar el registro de cochera: $e');
    }
  }

  Future<List<ParkingSpaceModel>> getAvailableSpaces() async {
    try {
      final response =
          await _apiClient.dio.get('/cochera/guest/espacios-disponibles');

      final data = response.data as List<dynamic>;
      return data
          .map((e) => ParkingSpaceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } catch (e) {
      throw ApiException('Error inesperado al cargar espacios disponibles: $e');
    }
  }

  Future<ParkingRecordModel> registerVehicle({
    required String placa,
    required String marca,
    required String modelo,
    required int espacioId,
    String? color,
    String? observacion,
  }) async {
    try {
      final body = {
        'placa': placa,
        'marca': marca,
        'modelo': modelo,
        'color': color,
        'observacion': observacion,
        'tipo': 'AUTO',
        'espacioId': espacioId,
      };

      final response = await _apiClient.dio.post(
        '/cochera/guest/ingreso',
        data: body,
      );

      return ParkingRecordModel.fromJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } catch (e) {
      throw ApiException('Error inesperado al registrar tu vehículo: $e');
    }
  }
}
