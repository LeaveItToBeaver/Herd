class NavigationService {
  DateTime _lastNavigationTime = DateTime.fromMillisecondsSinceEpoch(0);

  bool get canNavigate {
    final now = DateTime.now();
    if (now.difference(_lastNavigationTime).inMilliseconds > 300) {
      _lastNavigationTime = now;
      return true;
    }
    return false;
  }
}
