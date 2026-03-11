import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show Intl;
import 'package:intl/intl_standalone.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pvz_fusion_acc_manager/style/colors.dart';
import 'package:pvz_fusion_acc_manager/style/shadows.dart';
import 'package:pvz_fusion_acc_manager/views/main_page.dart';
import 'package:pvz_fusion_acc_manager/views/title_bar.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:window_manager/window_manager.dart';
import 'package:zentoast/zentoast.dart';

late final Logger errorLogger;
late final Logger infoLogger;
late final Logger debugLogger;

void main() async {
  timeago.setLocaleMessages('en', timeago.EnMessages());
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  errorLogger = await _buildFileLogger('errorLogs', 10);
  infoLogger = await _buildFileLogger('infoLogs', 4);
  debugLogger = await _buildConsoleLogger(Level.debug);

  WindowOptions windowOptions = const WindowOptions(
    size: Size(525, 800),
    maximumSize: Size(525, 800),
    minimumSize: Size(525, 440),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
    title: "PvzFusionAccountManager",
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  Intl.defaultLocale = await findSystemLocale();
  await initializeDateFormatting(Intl.defaultLocale, null);

  runApp(ProviderScope(child: ToastProvider.create(child: const App())));
}

Future<Logger> _buildFileLogger(
  final String fileName,
  final int methodCount,
) async {
  final logFilePath = join(
    (await getApplicationCacheDirectory()).path,
    'Logs',
    '$fileName.txt',
  );
  final logFile = File(logFilePath);
  if (!await logFile.exists()) {
    await logFile.create(recursive: true);
  }
  return Logger(
    printer: PrettyPrinter(
      colors: false,
      methodCount: methodCount,
      excludeBox: {Level.all: false},
      errorMethodCount: 15,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    output: FileOutput(file: logFile, overrideExisting: false),
  );
}

Future<Logger> _buildConsoleLogger(final Level level) async {
  return Logger(
    level: level,
    printer: PrettyPrinter(
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    output: ConsoleOutput(),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStatePropertyAll(appGreen),
          thickness: WidgetStatePropertyAll(8),
        ),
      ),
      debugShowCheckedModeBanner: false,

      builder: (context, child) {
        return ToastThemeProvider(
          data: ToastTheme(gap: 10, viewerPadding: EdgeInsets.all(10)),
          child: Material(
            child: Stack(
              children: [
                Positioned.fill(child: child ?? SizedBox()),
                Padding(
                  padding: EdgeInsetsGeometry.all(14),
                  child: ToastViewer(
                    alignment: Alignment.bottomLeft,
                    delay: Duration(seconds: 3),
                  ),
                ),
              ],
            ),
          ),
        );
      },

      home: Scaffold(
        body: Column(
          children: [
            TitleBar(),
            Expanded(child: PvzFusionAccountManager()),
          ],
        ),
      ),
    );
  }
}

class PvzFusionAccountManager extends StatelessWidget {
  const PvzFusionAccountManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: appGreen),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [mainShadow],
            borderRadius: BorderRadius.circular(20),
            gradient: RadialGradient(
              // TODO Create elliptical
              colors: [
                backgroundRadialStop60,
                backgroundRadialStop85,
                backgroundRadialStop100,
              ],
              stops: [0.6, 0.85, 1],
              radius: 0.65,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 5,
                left: 45,
                child: const Text(
                  'PVZ-FUSION',
                  style: TextStyle(color: appGreen, fontFamily: 'PvzHeader'),
                ),
              ),
              Positioned(
                bottom: 55,
                left: 20,
                child: SvgPicture.asset('resources/background/endoflame.svg'),
              ),
              Positioned.fill(child: MainPage()),
            ],
          ),
        ),
      ),
    );
  }
}
