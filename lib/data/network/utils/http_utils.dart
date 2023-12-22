import 'package:appkit/common/util/serialize.dart';
import 'package:dio/dio.dart';

abstract class HttpUtils {
  /// Return true if the given response is has a successful status code.
  static bool isSuccessful(Response response) {
    final statusCode = response.statusCode;
    if (statusCode != null)
      return statusCode >= 200 && statusCode < 300;
    else
      return false;
  }

  /// Format the given map as a HTTP query string, with the initial question mark.
  static String formatQueryString(Map<String, dynamic> query) {
    return _encodeAsUrl(query, true);
  }

  /// Format the given map as a URL-encoded string.
  static String urlencoded(Map<String, dynamic> map) {
    return _encodeAsUrl(map, false);
  }

  static String _encodeAsUrl(Map<String, dynamic> map, bool prependQuestionMark) {
    final result = StringBuffer();
    map.forEach((key, value) {
      if (value != null) {
        if (value is Iterable) {
          value.forEach((element) {
            result.write('&$key[]=${_formatQueryComponent(element)}');
          });
        } else {
          result.write('&$key=${_formatQueryComponent(value)}');
        }
      }
    });

    if (result.isNotEmpty) {
      if (prependQuestionMark) {
        return '?' + result.toString().substring(1);
      } else {
        return result.toString().substring(1);
      }
    }
    return '';
  }

  static String _formatQueryComponent(dynamic value) {
    // FIXME: not sure how to send null query param, should we? Need to ask our backend.
    // '%00' means null, but im not sure.
    return Uri.encodeQueryComponent(Serialize.value(value) ?? '%00');
  }
}
