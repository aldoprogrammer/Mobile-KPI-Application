
import 'package:flutter_test/flutter_test.dart';
import 'package:kpi_mobile_app/core/utils/validators.dart';

void main() {
  group('Validators.requiredField', () {
    test('returns error when value is null or empty', () {
      expect(Validators.requiredField(null, fieldName: 'Field'), 'Field is required');
      expect(Validators.requiredField('   ', fieldName: 'Field'), 'Field is required');
    });

    test('returns null when value is present', () {
      expect(Validators.requiredField('hello', fieldName: 'Field'), isNull);
    });
  });

  group('Validators.email', () {
    test('returns required message for empty values', () {
      expect(Validators.email(null), 'Email is required');
      expect(Validators.email('  '), 'Email is required');
    });

    test('returns validation message for invalid emails', () {
      expect(Validators.email('invalid'), 'Enter a valid email');
      expect(Validators.email('foo@bar'), 'Enter a valid email');
    });

    test('returns null for valid emails', () {
      expect(Validators.email('user@example.com'), isNull);
    });
  });

  group('Validators.minLength', () {
    test('returns error when value is too short', () {
      expect(Validators.minLength(null, 6, fieldName: 'Field'), 'Field must be at least 6 characters long');
      expect(Validators.minLength('123', 6, fieldName: 'Password'),
          'Password must be at least 6 characters long');
    });

    test('returns null when value is long enough', () {
      expect(Validators.minLength('123456', 6, fieldName: 'Field'), isNull);
    });
  });
}
