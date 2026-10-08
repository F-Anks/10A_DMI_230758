import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:tistos/config/theme/app_theme.dart';
import 'package:tistos/presentation/providers/feed_provider.dart';
import 'package:tistos/presentation/providers/playback_settings.dart';
import 'package:tistos/presentation/screens/splash/splash_screen.dart';

import 'package:tistos/infrastructure/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider( 
          lazy: false,
          create: (_) => FeedProvider()..loadAll() 
        ),
        ChangeNotifierProvider(
          create: (_) => PlaybackSettings(),
        ),
      ],
      child: MaterialApp(
        title: 'TokTik',
        debugShowCheckedModeBanner: false,
        theme: AppTheme().getTheme(),
        home: const SplashScreen()
      ),
    );
  }
}
