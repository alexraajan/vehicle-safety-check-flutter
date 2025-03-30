// services/log_service.dart

import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class FileLogOutput extends LogOutput {
  late File _logFile;
  bool _initialized = false;

  Future<void> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    _logFile = File('${dir.path}/app_logs.txt');
    print('${dir.path}/app_logs.txt');
    _initialized = true;
  }

  @override
  void output(OutputEvent event) async {
    if (!_initialized) await _init();
    final content = event.lines.join('\n') + '\n';
    await _logFile.writeAsString(content, mode: FileMode.append, flush: true);
  }
}

class LogService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(),
    output: FileLogOutput(),
  );

  static void d(String message) => logger.d(message);
  static void i(String message) => logger.i(message);
  static void w(String message) => logger.w(message);
  static void e(String message) => logger.e(message);
}
