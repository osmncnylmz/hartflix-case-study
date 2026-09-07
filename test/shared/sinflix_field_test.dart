import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sinflix/src/shared/widgets/sinflix_fields.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: Material(child: child)),
);

void main() {
  group('SinflixField', () {
    testWidgets('renders the hint and the leading icon', (tester) async {
      await tester.pumpWidget(
        _host(
          SinflixField(
            controller: TextEditingController(),
            hint: 'E-Posta',
            icon: Icons.mail_outline_rounded,
          ),
        ),
      );

      expect(find.text('E-Posta'), findsOneWidget);
      expect(find.byIcon(Icons.mail_outline_rounded), findsOneWidget);
    });

    testWidgets('surfaces the validator message when the form is validated', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        _host(
          Form(
            key: formKey,
            child: SinflixField(
              controller: TextEditingController(text: 'nope'),
              hint: 'E-Posta',
              icon: Icons.mail_outline_rounded,
              validator: (v) =>
                  (v != null && v.contains('@')) ? null : 'Geçersiz e-posta',
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Geçersiz e-posta'), findsOneWidget);
    });

    testWidgets('shows the reveal toggle only when onToggle is supplied', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SinflixField(
            controller: TextEditingController(),
            hint: 'Şifre',
            icon: Icons.lock_outline_rounded,
            obscure: true,
          ),
        ),
      );
      expect(find.byIcon(Icons.visibility_off), findsNothing);

      var toggled = false;
      await tester.pumpWidget(
        _host(
          SinflixField(
            controller: TextEditingController(),
            hint: 'Şifre',
            icon: Icons.lock_outline_rounded,
            obscure: true,
            onToggle: () => toggled = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility_off));
      expect(toggled, isTrue);
    });
  });

  group('SocialButton', () {
    testWidgets('reports the tap to its callback', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        _host(SocialButton(icon: Icons.apple, onTap: () => taps++)),
      );

      await tester.tap(find.byIcon(Icons.apple));
      expect(taps, 1);
    });
  });
}
