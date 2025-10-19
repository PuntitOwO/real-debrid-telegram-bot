enum RealDebridError {
  badToken(401),
  permissionDenied(403),
  serviceUnavailable(503);

  final int code;

  const RealDebridError(this.code);
}
