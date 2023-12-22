import 'package:appkit/common/extension/string.extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should correctly capitalize a string', () {
    expect(''.capitalize(), '');
    expect('a'.capitalize(), 'A');
    expect('ц'.capitalize(), 'Ц');
    expect('A'.capitalize(), 'A');
    expect('text'.capitalize(), 'Text');
    expect('Text'.capitalize(), 'Text');
    expect('longer text'.capitalize(), 'Longer text');
    expect('Longer Text'.capitalize(), 'Longer Text');
  });

  test('should correctly convert snake_case to camelCase', () {
    expect(''.snakeCaseToCamelCase(), '');
    expect('word'.snakeCaseToCamelCase(), 'word');
    expect('snake_case'.snakeCaseToCamelCase(), 'snakeCase');
    expect('a_lot_more_snake_case'.snakeCaseToCamelCase(), 'aLotMoreSnakeCase');
  });
}
