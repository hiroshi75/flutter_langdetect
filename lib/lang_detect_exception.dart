enum ErrorCode {
  noTextError,
  formatError,
  fileLoadError,
  duplicateLangError,
  needLoadProfileError,
  cantDetectError,
  cantOpenTrainData,
  trainDataFormatError,
  initParamError,
}

/// LangDetectException is the exception class of LangDetect.
class LangDetectException implements Exception {
  final ErrorCode code;
  final String message;

  LangDetectException(this.code, this.message);

  ErrorCode getCode() {
    return code;
  }

  @override
  String toString() {
    return 'LangDetectException: $message (code: $code)';
  }
}
