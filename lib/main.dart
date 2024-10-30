import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:ui';

import 'package:flutter/services.dart';
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
  final GlobalKey _renderKey = GlobalKey();

  Future<void> requestMediaLibraryPermission() async {
    PermissionStatus status = await Permission.mediaLibrary.status;

    if (status.isDenied) {
      // Пользователь еще не давал разрешение или ранее отказал
      // Запрашиваем разрешение
      PermissionStatus result = await Permission.mediaLibrary.request();

      if (result.isGranted) {
        // Разрешение предоставлено, продолжаем работу с медиатекой
      } else if (result.isPermanentlyDenied || result.isDenied) {
        // Разрешение отклонено навсегда или повторно
        // Отображаем кнопку для перехода в настройки
        showOpenSettingsDialog();
      } else {
        // Разрешение отклонено, обработайте соответствующим образом
      }
    } else if (status.isGranted) {
      // Разрешение уже предоставлено, продолжаем работу с медиатекой
    } else if (status.isPermanentlyDenied) {
      // Разрешение отклонено навсегда
      // Отображаем кнопку для перехода в настройки
      showOpenSettingsDialog();
    } else if (status.isRestricted) {
      // Разрешение ограничено, обработайте соответствующим образом
    }
  }

  void showOpenSettingsDialog() {
    // Здесь вы можете отобразить диалоговое окно или экран с кнопкой перехода в настройки
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Требуется доступ к медиатеке'),
        content: const Text(
            'Пожалуйста, предоставьте доступ к медиатеке в настройках приложения.'),
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

  Future<void> _saveImage() async {
    await requestMediaLibraryPermission();

    try {
      // Получаем RenderRepaintBoundary с обработкой null
      RenderRepaintBoundary? boundary = _renderKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('Не удалось получить RenderRepaintBoundary');
        return;
      }

      // Захватываем изображение
      var image = await boundary.toImage(pixelRatio: 3.0);

      // Получаем ByteData с обработкой null
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) {
        debugPrint('Не удалось получить данные изображения');
        return;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      // Сохраняем изображение в фотоальбом
      final result = await ImageGallerySaver.saveImage(
        pngBytes,
        quality: 100,
        name: "image_${DateTime.now().millisecondsSinceEpoch}",
      );
      debugPrint('Результат сохранения: $result');
    } catch (e) {
      debugPrint('Ошибка при сохранении изображения: $e');
    }
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
                  key: _renderKey,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    color: const Color(0xFFf5f5f5),
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
                onTap: () {
                  _saveImage();
                },
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
