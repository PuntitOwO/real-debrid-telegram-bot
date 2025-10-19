enum RealDebridError {
  badToken(401),
  permissionDenied(403);

  final int code;

  const RealDebridError(this.code);
}
