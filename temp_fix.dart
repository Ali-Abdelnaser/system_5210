import 'dart:io';

void main() {
  final dir = Directory('lib/features/nutrition_scan');
  int totalChanges = 0;

  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      String content = entity.readAsStringSync();
      if (content.contains('withOpacity')) {
        final originalContent = content;
        content = content.replaceAllMapped(
          RegExp(r'\.withOpacity\(([^)]+)\)'),
          (match) => '.withValues(alpha: ${match.group(1)})',
        );
        if (content != originalContent) {
          entity.writeAsStringSync(content);
          print('Updated ${entity.path}');
          totalChanges++;
        }
      }
    }
  }
  print('Total files updated: $totalChanges');
}
