String gsu(String url) {
  try {
    final uri = Uri.parse(url);
    // This creates a new URI with only the scheme, host, and path,
    // effectively removing all query parameters.
    return uri.replace(queryParameters: {}).toString();
  } catch (e) {
    // If parsing fails for any reason, return the original URL.
    return url;
  }
}
