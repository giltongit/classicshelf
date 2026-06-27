/// GPS 좌표로 도서관정보나루 지역코드 반환.
/// 매칭 실패 시 null 반환.
String? regionCodeFromLatLng(double lat, double lng) {
  if (lat >= 37.4 && lat <= 37.7 && lng >= 126.7 && lng <= 127.2) return '11'; // 서울
  if (lat >= 35.0 && lat <= 35.3 && lng >= 128.9 && lng <= 129.3) return '21'; // 부산
  if (lat >= 35.7 && lat <= 36.0 && lng >= 128.4 && lng <= 128.8) return '22'; // 대구
  if (lat >= 37.3 && lat <= 37.6 && lng >= 126.4 && lng <= 126.8) return '23'; // 인천
  if (lat >= 35.1 && lat <= 35.3 && lng >= 126.7 && lng <= 127.0) return '24'; // 광주
  if (lat >= 36.2 && lat <= 36.5 && lng >= 127.3 && lng <= 127.5) return '25'; // 대전
  if (lat >= 35.4 && lat <= 35.6 && lng >= 129.2 && lng <= 129.4) return '26'; // 울산
  if (lat >= 36.4 && lat <= 36.6 && lng >= 127.2 && lng <= 127.4) return '29'; // 세종
  if (lat >= 37.0 && lat <= 38.3 && lng >= 126.6 && lng <= 127.9) return '31'; // 경기
  if (lat >= 37.0 && lat <= 38.6 && lng >= 127.9 && lng <= 129.4) return '32'; // 강원
  if (lat >= 36.4 && lat <= 37.2 && lng >= 127.4 && lng <= 128.2) return '33'; // 충북
  if (lat >= 36.0 && lat <= 37.0 && lng >= 126.3 && lng <= 127.4) return '34'; // 충남
  if (lat >= 35.4 && lat <= 36.2 && lng >= 126.4 && lng <= 127.7) return '35'; // 전북
  if (lat >= 34.2 && lat <= 35.5 && lng >= 126.1 && lng <= 127.6) return '36'; // 전남
  if (lat >= 35.6 && lat <= 37.1 && lng >= 128.1 && lng <= 129.5) return '37'; // 경북
  if (lat >= 34.6 && lat <= 35.7 && lng >= 127.6 && lng <= 129.2) return '38'; // 경남
  if (lat >= 33.1 && lat <= 33.6 && lng >= 126.1 && lng <= 126.9) return '39'; // 제주
  return null;
}

/// 지역코드 → 지역명
String regionName(String code) {
  return const {
    '11': '서울', '21': '부산', '22': '대구', '23': '인천',
    '24': '광주', '25': '대전', '26': '울산', '29': '세종',
    '31': '경기', '32': '강원', '33': '충북', '34': '충남',
    '35': '전북', '36': '전남', '37': '경북', '38': '경남',
    '39': '제주',
  }[code] ?? '알 수 없음';
}
