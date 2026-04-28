List<String> tokenize(String text) {
  final cleaned = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
  return cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
}
