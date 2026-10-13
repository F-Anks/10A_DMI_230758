import 'package:tistos/domain/datasources/video_posts_datasource.dart';
import 'package:tistos/domain/entities/video_post.dart';
import 'package:tistos/infrastructure/models/local_video_model.dart';
import 'package:tistos/shared/data/local_video_post.dart';

/// Datasource local (videos de Drive). Se usa sin conexión a RapidAPI.
class LocalVideoDatasource implements VideoPostDatasource {

  Future<List<VideoPost>> _loadLocalVideos() async {
    await Future.delayed( const Duration(milliseconds: 500) );

    final List<VideoPost> newVideos = videoPosts.map( 
      ( video ) => LocalVideoModel.fromJson(video).toVideoPostEntity()
    ).toList();

    return newVideos;
  }

  @override
  Future<List<VideoPost>> getTikTokVideos() => _loadLocalVideos();

  @override
  Future<List<VideoPost>> getInstagramReels() => _loadLocalVideos();

  @override
  Future<List<VideoPost>> getYouTubeShorts() => _loadLocalVideos();

}