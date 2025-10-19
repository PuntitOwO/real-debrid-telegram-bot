import 'package:televerse/televerse.dart';

class RealDebridBot {
  final String telegramBotToken;
  final String realDebridToken;
  final Bot _bot;
  // final RealDebrid realDebrid;

  RealDebridBot({required this.telegramBotToken, required this.realDebridToken})
    : _bot = Bot(telegramBotToken) {
    setupCommands();
  }

  void setupCommands() {
    _bot.command("start", startHandler);
    _bot.command("hosts", hostsHandler);
  }

  Future<void> start() => _bot.start();

  // -------------------------- HANDLERS --------------------------

  Future<void> startHandler(Context ctx) async {
    await ctx.reply("Hello world!");
  }

  Future<void> hostsHandler(Context ctx) async {
    await ctx.reply("Hello world!");
  }
}
