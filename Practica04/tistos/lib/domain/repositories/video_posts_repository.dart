import 'package:tistos/domain/entities/video_post.dart';

abstract class VideoPostRepository {
  Future<List<VideoPost>> getTikTokVideos();
  Future<List<VideoPost>> getYouTubeShorts();
  Future<List<VideoPost>> getInstagramReels();
}