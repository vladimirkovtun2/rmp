import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'package:rmp_9plus/labs/lab_11/maps_urls.dart';
import 'package:rmp_9plus/main.dart';

Future<void> _openLab(WidgetTester tester, String title) async {
  await tester.pumpWidget(const LabsApp());
  await tester.tap(find.text(title));
  // pumpAndSettle нельзя: CircularProgressIndicator крутится бесконечно,
  // поэтому завершаем анимацию перехода явно
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

void main() {
  testWidgets('Главный экран показывает список лабораторных', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LabsApp());

    expect(find.text('Лабораторные работы'), findsOneWidget);
    expect(find.text('Лабораторная работа №9'), findsOneWidget);
    expect(find.text('Лабораторная работа №10'), findsOneWidget);
    expect(find.text('Лабораторная работа №11'), findsOneWidget);
  });

  testWidgets('Переход к лабораторной и обратно', (
    WidgetTester tester,
  ) async {
    await _openLab(tester, 'Лабораторная работа №11');

    // Кнопка «назад» появляется только на экране лабораторной
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    await tester.pageBack();
    await tester.pump();

    expect(find.text('Лабораторные работы'), findsOneWidget);
  });

  testWidgets('Лабораторная 11: режим адреса — одно поле, улицы недоступны', (
    WidgetTester tester,
  ) async {
    await _openLab(tester, 'Лабораторная работа №11');

    expect(find.byType(TextField), findsOneWidget);
    // «Адрес» — и сегмент переключателя, и подпись поля
    expect(find.text('Адрес'), findsNWidgets(2));

    await tester.tap(find.text('Просмотр улиц'));
    await tester.pump();
    expect(
      find.text('Просмотр улиц работает только в режиме координат'),
      findsWidgets,
    );
  });

  testWidgets('Лабораторная 11: режим координат — два поля и валидация', (
    WidgetTester tester,
  ) async {
    await _openLab(tester, 'Лабораторная работа №11');

    await tester.tap(find.text('Координаты'));
    await tester.pump();
    expect(find.byType(TextField), findsNWidgets(2));

    // Пустые поля — подсказка о вводе чисел
    await tester.tap(find.text('Показать на картах'));
    await tester.pump();
    expect(find.text('Введите широту и долготу числами'), findsWidgets);

    // Вне диапазона — подсказка о границах
    await tester.enterText(find.byType(TextField).at(0), '95');
    await tester.enterText(find.byType(TextField).at(1), '37.6');
    await tester.pump();
    await tester.tap(find.text('Показать на картах'));
    await tester.pump();
    expect(find.text('Широта должна быть от -90 до 90'), findsWidgets);

    // Корректные координаты (с запятой-разделителем) — уходит URL карт
    final fake = FakeUrlLauncher();
    final original = UrlLauncherPlatform.instance;
    UrlLauncherPlatform.instance = fake;
    try {
      await tester.enterText(find.byType(TextField).at(0), '55,7558');
      await tester.enterText(find.byType(TextField).at(1), '37.6173');
      await tester.pump();
      await tester.tap(find.text('Показать на картах'));
      await tester.pump();
      expect(fake.url, MapsUrls.searchByCoordinates(55.7558, 37.6173));

      await tester.tap(find.text('Просмотр улиц'));
      await tester.pump();
      expect(fake.url, MapsUrls.streetView(55.7558, 37.6173));
    } finally {
      UrlLauncherPlatform.instance = original;
    }
  });
}

/// Поддельная платформа url_launcher: запоминает переданный URL.
class FakeUrlLauncher extends UrlLauncherPlatform {
  String? url;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async {
    this.url = url;
    return true;
  }
}
