import 'package:flutter_test/flutter_test.dart';
import 'package:sanaa_offers_app/core/utils/input_validators.dart';

void main() {
  group('InputValidators Tests', () {
    test('validateEmail returns error for empty or invalid email', () {
      expect(InputValidators.validateEmail(''), isNotNull);
      expect(InputValidators.validateEmail('invalid-email'), isNotNull);
      expect(InputValidators.validateEmail('test@example.com'), isNull);
    });

    test('validatePassword returns error for password under 6 chars', () {
      expect(InputValidators.validatePassword('12345'), isNotNull);
      expect(InputValidators.validatePassword('123456'), isNull);
    });

    test('validateFullName returns error for short or empty name', () {
      expect(InputValidators.validateFullName('a'), isNotNull);
      expect(InputValidators.validateFullName('علي المحمدي'), isNull);
    });

    test('validateStoreName returns error for empty store name', () {
      expect(InputValidators.validateStoreName(''), isNotNull);
      expect(InputValidators.validateStoreName('سوبر ماركت الجندول'), isNull);
    });
  });
}
