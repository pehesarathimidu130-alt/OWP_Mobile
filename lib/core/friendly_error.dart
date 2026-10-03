/// Helper to map various network/API errors into user-friendly messages.
String friendlyErrorMessage(dynamic error) {
  if (error == null) {
    return 'Could not reach the server. Please check your connection.';
  }
  
  final raw = error.toString();
  if (raw.trim().isEmpty) {
    return 'Could not reach the server. Please check your connection.';
  }
  
  final lower = raw.toLowerCase();
  if (lower.contains('401') || lower.contains('unauthorized') || lower.contains('session')) {
    return 'Your session has expired. Please sign in again.';
  }
  if (lower.contains('500') ||
      lower.contains('502') ||
      lower.contains('503') ||
      lower.contains('504') ||
      lower.contains('server error')) {
    return 'Server error. Please try again later.';
  }
  if (lower.contains('network') ||
      lower.contains('socket') ||
      lower.contains('connection') ||
      lower.contains('timed out') ||
      lower.contains('cannot reach') ||
      lower.contains('failed host lookup') ||
      lower.contains('unreachable')) {
    return 'Could not reach the server. Please check your connection.';
  }
  
  return raw;
}
