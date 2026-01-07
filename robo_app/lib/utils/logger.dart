import 'package:logger/logger.dart';

// 전역에서 사용할 로거 인스턴스
var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1, // 에러 발생 시 몇 단계의 스택트레이스를 보여줄지 (0~2 추천)
    errorMethodCount: 8, // 에러 발생 시 보여줄 스택트레이스 깊이
    lineLength: 120, // 로그 한 줄의 길이
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.dateAndTime, // 시간 표시
  ),
);

/*
  사용법:
    logger.d("디버그 로그"); // 개발 중 확인용 (회색)
    logger.i("정보 로그");   // 일반적인 정보 (파란색)
    logger.w("경고 로그");   // 잠재적 문제 (주황색)
    logger.e("에러 로그");   // 심각한 오류 (빨간색)
*/
