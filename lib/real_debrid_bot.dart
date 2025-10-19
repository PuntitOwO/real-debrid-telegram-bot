import 'package:real_debrid/real_debrid.dart';
import 'package:real_debrid/real_debrid_error.dart';
import 'package:televerse/televerse.dart';

class RealDebridBot {
  final Bot _bot;
  final RealDebrid _realDebrid;

  RealDebridBot({
    required String telegramBotToken,
    required String realDebridToken,
  }) : _bot = Bot(telegramBotToken),
       _realDebrid = RealDebrid(token: realDebridToken) {
    setupCommands();
  }

  void setupCommands() {
    _bot.command("start", startHandler);
    _bot.command("user", userHandler);
  }

  Future<void> start() => _bot.start();

  // -------------------------- HANDLERS --------------------------

  Future<void> startHandler(Context ctx) async {
    await ctx.reply("Hello world!");
  }

  Future<void> userHandler(Context ctx) async {
    try {
      await ctx.sendTyping();
      final user = await _realDebrid.user;
      final userPremiumMessage = user.type == RealDebridUserType.free
          ? "free, go to https://real-debrid.com/premium to buy premium"
          : "premium, expires on ${user.expirationDate} "
                "(approx ${user.premiumTimeLeft.inDays} days)";
      final userMessage =
          "User: ${user.username} (ID: ${user.id})\n"
          "Email: ${user.email}\n"
          "Fidelity points: ${user.points}\n"
          "Free or Premium: $userPremiumMessage";
      await ctx.reply(userMessage);
    } on RealDebridError catch (error) {
      final errorMessage = switch (error) {
        RealDebridError.badToken => "Error: bad token (expired or invalid)",
        RealDebridError.permissionDenied =>
          "Error: permission denied (account locked)",
      };
      await ctx.reply(errorMessage);
    }
  }
}
