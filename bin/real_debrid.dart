import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:real_debrid/real_debrid.dart';
import 'package:real_debrid/real_debrid_bot.dart';
import 'package:yaml/yaml.dart';

void main(List<String> arguments) async {
  final executablePath = Platform.script;
  final workingDirectory = path.dirname(executablePath.toFilePath());
  final configFilePath = path.join(workingDirectory, "config.yaml");
  final file = File(configFilePath);
  final Map yaml = loadYaml(file.readAsStringSync());
  final String telegramBotToken = yaml["bot"]["token"];
  // final List<String> allowedUsers = yaml["bot"]["allowed_users"];
  final String realDebridToken = yaml["real_debrid"]["token"];
  final realDebridBot = RealDebridBot(
    telegramBotToken: telegramBotToken,
    realDebridToken: realDebridToken,
  );
  await realDebridBot.start();
  // final realDebrid = RealDebrid(token: realDebridToken);
  // print(await realDebrid.user);
}
