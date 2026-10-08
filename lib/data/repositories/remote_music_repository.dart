/// Remote music repository — connects to backend via ApiClient.
library;

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../data/models/models.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

class RemoteMusicRepository implements MusicRepository {
  RemoteMusicRepository(this._client);

  final ApiClient _client;

  @override
  Future<SearchPage> search(
    String query, {
    int page = 1,
    String? cursor,
  }) async {
    try {
      final data = await _client.get(
        '/search',
        queryParameters: {
          'q': query,
          'page': page,
          if (cursor != null) 'cursor': cursor,
        },
      ) as Map<String, dynamic>;

      final results = (data['results'] as List<dynamic>)
          .map((e) => SearchResultModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();

      final pagination = data['pagination'] as Map<String, dynamic>?;
      return SearchPage(
        results: results,
        hasNextPage: pagination?['hasNextPage'] as bool? ?? false,
        nextCursor: pagination?['nextCursor'] as String?,
        page: page,
      );
    } on DioException catch (e) {
      throw ApiException(e.error?.toString() ?? 'Search failed');
    }
  }

  @override
  Future<Track> getTrack(String sourceId) async {
    try {
      final data = await _client.get('/tracks/$sourceId') as Map<String, dynamic>;
      return TrackModel.fromJson(data).toEntity();
    } on DioException catch (e) {
      throw ApiException(e.error?.toString() ?? 'Failed to load track');
    }
  }

  @override
  Future<String> resolveStreamUrl(String sourceId) async {
    try {
      final data = await _client.get(
        '/tracks/$sourceId/stream',
      ) as Map<String, dynamic>;
      return data['url'] as String;
    } on DioException catch (e) {
      throw ApiException(e.error?.toString() ?? 'Stream unavailable');
    }
  }

  @override
  Future<List<SearchResult>> getTrending() async {
    try {
      final data = await _client.get('/trending') as List<dynamic>;
      return data
          .map((e) => SearchResultModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
    } on DioException catch (e) {
      throw ApiException(e.error?.toString() ?? 'Failed to load trending');
    }
  }
}
