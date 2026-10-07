import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    headers: {
      'x-rapidapi-key': 'c6764fb278msh6250c4bd32fd291p10f4f4jsn142893c7ce3e',
    },
  ));

  try {
    final response = await dio.get(
      'https://tiktok-video-no-watermark2.p.rapidapi.com/feed/list',
      options: Options(headers: {
        'x-rapidapi-host': 'tiktok-video-no-watermark2.p.rapidapi.com',
      }),
      queryParameters: {'region': 'US', 'count': 5},
    );
    print('SUCCESS');
    print(response.data);
  } catch (e) {
    if (e is DioException) {
      print('Status: \${e.response?.statusCode}');
      print('Data: \${e.response?.data}');
    }
  }
}
