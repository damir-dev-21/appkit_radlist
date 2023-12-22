class HttpMethod {
  final String name;

  const HttpMethod._(this.name);

  static const GET = HttpMethod._('GET');
  static const POST = HttpMethod._('POST');
  static const PUT = HttpMethod._('PUT');
  static const PATCH = HttpMethod._('PATCH');
  static const DELETE = HttpMethod._('DELETE');

  /// True if an endpoint with this method can be requested multiple
  /// times without changing the outcome.
  bool get isRepeatable => this != POST && this != DELETE;
}
