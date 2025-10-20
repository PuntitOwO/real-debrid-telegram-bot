import 'package:televerse/televerse.dart';

class AllowListMiddleware<CTX extends Context> extends MiddlewarePlugin<CTX> {
  final List<int> allowedIDs;

  AllowListMiddleware(this.allowedIDs);

  @override
  String get name => 'allow-list';

  @override
  List<String> get dependencies => [];

  @override
  String? get description => 'Blocks messages from users not in allow list';

  @override
  Middleware<CTX> get middleware => (ctx, next) async {
    if (!allowedIDs.contains(ctx.from?.id)) {
      await ctx.reply("You are not in the allowed list");
      return;
    }
    await next();
  };

  @override
  void uninstall(Bot<CTX> bot) => bot.removeNamed(name);

  @override
  String get version => 'v1.0.0';
}
