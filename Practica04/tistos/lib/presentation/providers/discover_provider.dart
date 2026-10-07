import 'package:flutter/material.dart';
import 'package:tistos/domain/entities/video_post.dart';
import 'package:tistos/infrastructure/models/local_video_model.dart';

import 'package:tistos/shared/data/local_video_post.dart';



class DiscoverProvider extends ChangeNotifier {

  // TODO: Repository, DataSource

  bool initialLoading = true;
  List<VideoPost> forYouVideos = [];
  List<VideoPost> nearYouVideos = [];
  List<VideoPost> discoverVideos = [];

  Future<void> loadNextPage() async {
    final List<VideoPost> allVideos = videoPosts.map( 
      ( video ) => LocalVideoModel.fromJson(video).toVideoPostEntity()
    ).toList();
    
    // Dividiendo en 3, 3 y 2
    forYouVideos = allVideos.sublist(0, 3);
    nearYouVideos = allVideos.sublist(3, 6);
    discoverVideos = allVideos.sublist(6, 8);

    initialLoading = false;
    notifyListeners();
  }


}
