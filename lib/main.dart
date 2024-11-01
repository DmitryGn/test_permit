import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:render/render.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final RenderController renderController = RenderController();

  Future<void> saveRenderedImage() async {
    // Запрашиваем разрешение на доступ к хранилищу
    // var status = await Permission.storage.request();
    // if (!status.isGranted) {
    //   showOpenSettingsDialog();
    //   return;
    // }

    // Захватываем изображение из Render и сохраняем его
    try {
      final result = await renderController.captureImage(
        format: ImageFormat.png,
        settings: const ImageSettings(pixelRatio: 3.0),
      );
      if (result.output.existsSync()) {
        final bytes = await result.output.readAsBytes();
        await ImageGallerySaver.saveImage(
          bytes,
          quality: 100,
          name: "rendered_image_${DateTime.now().millisecondsSinceEpoch}",
        );
        //debugPrint('Результат сохранения: $saveResult');
      }
    } catch (e) {
      //debugPrint('Ошибка при сохранении изображения: $e');
    }
  }

  void showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Требуется доступ к медиатеке'),
        content: const Text(
          'Пожалуйста, предоставьте доступ к медиатеке в настройках приложения.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Открыть настройки'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Render(
                  controller: renderController,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    color: Colors.blue,
                    child: const Center(
                      child: Text(
                        'A Flutter plugin for finding commonly used locations on the filesystem. Supports Android, iOS, Linux, macOS and Windows. Not all methods are supported on all platforms.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: saveRenderedImage,
                child: Container(
                  height: 50,
                  color: Colors.black,
                  child: const Center(
                    child: Text(
                      'Save Image',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
