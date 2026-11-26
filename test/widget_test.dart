import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:futsal_app/shared/widgets/app_text_field.dart';

void main() {
  testWidgets('AppTextField shows label and validation message',
      (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            child: AppTextField(
              controller: controller,
              label: 'Ground name',
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Required' : null,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Ground name'), findsOneWidget);

    expect(tester.state<FormState>(find.byType(Form)).validate(), isFalse);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
  });
}
