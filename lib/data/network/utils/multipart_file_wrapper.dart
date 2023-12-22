import 'package:dio/dio.dart';

/// A wrapper class for MultipartFile that also keeps the [filePath], [bytes] and
/// [filename] fields, which can be used to clone the MultipartFile.
///
/// This is done to work around the issue where the same MultipartFile cannot be
/// reused for multiple requests, and must be recreated. This requires
/// retaining access to the arguments used to construct the initial MultipartFile.
class MultipartFileWrapper {
  final MultipartFile multipartFile;
  final String? filePath;
  final List<int>? bytes;
  final String? filename;

  MultipartFileWrapper._({
    required this.multipartFile,
    this.filePath,
    this.bytes,
    this.filename,
  });

  factory MultipartFileWrapper.fromFile(String filePath) {
    return MultipartFileWrapper._(
      multipartFile: MultipartFile.fromFileSync(filePath),
      filePath: filePath,
    );
  }

  factory MultipartFileWrapper.fromBytes(List<int> bytes, {String? filename}) {
    return MultipartFileWrapper._(
      multipartFile: MultipartFile.fromBytes(bytes, filename: filename),
      filename: filename,
    );
  }

  MultipartFileWrapper? clone() {
    final filePath = this.filePath;
    final bytes = this.bytes;
    if (filePath != null) {
      return MultipartFileWrapper.fromFile(filePath);
    } else if (bytes != null) {
      return MultipartFileWrapper.fromBytes(bytes, filename: filename);
    } else {
      return null;
    }
  }
}
