import 'package:dio/dio.dart';

import '../core/errors/api_exception.dart';
import '../models/room_model.dart';
import '../services/api_client.dart';

/// Rooms data source (Sprint 2 controlled scope: list + detail).
class RoomRepository {
  final ApiClient _api;

  RoomRepository(this._api);

  /// GET /rooms/
  Future<List<RoomModel>> fetchAll() async {
    try {
      final res = await _api.dio.get('/rooms/');
      final list = res.data as List<dynamic>;
      return list
          .map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /rooms/{id}/
  Future<RoomModel> fetchById(int id) async {
    try {
      final res = await _api.dio.get('/rooms/$id/');
      return RoomModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
