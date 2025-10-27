// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giai_doan_5/screens/login_screen.dart';

void main() {
  testWidgets('Login screen renders pixel UI and actions', (WidgetTester tester) async {
    // Build LoginScreen within a MaterialApp to provide Navigator and theme.
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // Verify key pixel UI elements exist.
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Đăng ký tài khoản'), findsOneWidget);

    // Username/password labels should be present.
    expect(find.text('Tài khoản:'), findsOneWidget);
    expect(find.text('Mật khẩu:'), findsOneWidget);
  });
}
