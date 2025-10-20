import 'package:real_debrid/allow_list_middleware.dart';
import 'package:real_debrid/raw_api_extensions.dart';
import 'package:real_debrid/real_debrid.dart';
import 'package:real_debrid/real_debrid_error.dart';
import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

class RealDebridBot {
  final Bot _bot;
  final RealDebrid _realDebrid;
  final AllowListMiddleware _allowListMiddleware;

  RealDebridBot({
    required String telegramBotToken,
    required String realDebridToken,
    List<int> allowedIDs = const <int>[],
  }) : _bot = Bot(telegramBotToken),
       _realDebrid = RealDebrid(token: realDebridToken),
       _allowListMiddleware = AllowListMiddleware(allowedIDs) {
    setupBot();
  }

  void setupBot() {
    if (_allowListMiddleware.allowedIDs.isNotEmpty) {
      _bot.plugin(_allowListMiddleware);
    }
    _bot.command("start", startHandler);
    _bot.command("user", userHandler);
    _bot.command("convertPoints", pointsHandler);
    _bot.command("download", downloadHandler);
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
        _ => "Unknown error (${error.code})",
      };
      await ctx.reply(errorMessage);
    }
  }

  Future<void> pointsHandler(Context ctx) async {
    try {
      await ctx.sendTyping();
      await _realDebrid.convertPoints();
      await ctx.reply("Done! check your new expiration date using /user");
    } on RealDebridError catch (error) {
      final errorMessage = switch (error) {
        RealDebridError.badToken => "Error: bad token (expired or invalid)",
        RealDebridError.permissionDenied =>
          "Error: permission denied (account locked)",
        RealDebridError.serviceUnavailable => "Error: not enough points",
        // _ => "Unknown error (${error.code})",
      };
      await ctx.reply(errorMessage);
    }
  }

  Future<void> downloadHandler(Context ctx) async {
    try {
      final args = ctx.args;
      if (args.isEmpty) {
        _downloadInfoHandler(ctx);
        return;
      }
      String link = args.first;
      String pass = "";
      if (args.last.startsWith("pass:")) {
        pass = args.last.replaceFirst("pass:", "");
      }
      final downloadLink = await _realDebrid.download(link, pass);
      final parsedSize = downloadLink.filesize == 0
          ? "unknown size"
          : "${downloadLink.filesize ~/ 1000000}MB";
      final message =
          "${downloadLink.mimeType} file ready:\n"
          "${downloadLink.filename} ($parsedSize)\n"
          "Original host: ${downloadLink.host}";
      ctx.reply(
        message,
        replyMarkup: InlineKeyboard().url("download", downloadLink.download),
      );
    } on RealDebridError catch (error) {
      final errorMessage = switch (error) {
        RealDebridError.badToken => "Error: bad token (expired or invalid)",
        RealDebridError.permissionDenied =>
          "Error: permission denied (account locked)",
        _ => "Unknown error (${error.code})",
      };
      await ctx.reply(errorMessage);
    }
  }

  Future<void> _downloadInfoHandler(Context ctx) async {
    final message =
        "Use /download to generate an unrestricted link for valid hosters\n"
        "Usage:\n"
        " \\* `/download`: show this message and get supported hosts list\n"
        " \\* `/download <link\\> [pass:password]`: generate an unrestricted link\n"
        " If file has password, add pass:<password\\> as a second parameter\n";
    await ctx.reply(message, parseMode: ParseMode.markdownV2);
    final hosts = await _realDebrid.hosts;
    hosts.sort((a, b) => a.name.compareTo(b.name));
    final hostsMessage = StringBuffer("Available hosts:\n");
    hostsMessage.writeAll(hosts.map((h) => "* ${h.name}"), "\n");
    ctx.api.sendLongMessage(ctx.id, hostsMessage.toString());
  }
}
