class ErrorCode {
  static const int NoTextError = 0;
  static const int FormatError = 1;
  static const int FileLoadError = 2;
  static const int DuplicateLangError = 3;
  static const int NeedLoadProfileError = 4;
  static const int CantDetectError = 5;
  static const int CantOpenTrainData = 6;
  static const int TrainDataFormatError = 7;
  static const int InitParamError = 8;
}

class LangDetectException implements Exception {
  final int code;
  final String message;

  LangDetectException(this.code, this.message);

  int getCode() {
    return code;
  }

  @override
  String toString() {
    return 'LangDetectException: $message (code: $code)';
  }
}
