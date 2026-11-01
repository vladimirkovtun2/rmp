import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'package:rmp_9plus/labs/lab_06/calculator_screen.dart';
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
    for (final n in ['2', '6', '7', '8', '9', '10', '11']) {
      expect(find.text('Лабораторная работа №$n'), findsOneWidget);
    }
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

  testWidgets('Лабораторная 2: пятнашки', (WidgetTester tester) async {
    await _openLab(tester, 'Лабораторная работа №2');

    expect(find.text('Пятнашки'), findsOneWidget);
    expect(find.text('Ходов: 0'), findsOneWidget);

    await tester.tap(find.text('Перемешать'));
    await tester.pump();
    expect(find.text('Ходов: 0'), findsOneWidget);
  });

  testWidgets('Лабораторная 6: калькулятор считает', (
    WidgetTester tester,
  ) async {
    await _openLab(tester, 'Лабораторная работа №6');

    // Поиск ограничиваем экраном лабораторной: на главном экране
    // под ним в списке тоже есть тексты «7», «10» и т.п. (аватары номеров)
    final lab = find.byType(Scaffold).last;

    await tester.tap(find.descendant(of: lab, matching: find.text('7')));
    await tester.pump();
    await tester.tap(find.descendant(of: lab, matching: find.text('+')));
    await tester.pump();
    await tester.tap(find.descendant(of: lab, matching: find.text('3')));
    await tester.pump();
    await tester.tap(find.descendant(of: lab, matching: find.text('=')));
    await tester.pump();

    expect(
      find.descendant(of: lab, matching: find.text('10')),
      findsOneWidget,
    );
  });

  testWidgets('Лабораторная 6: экран настроек применяется', (
    WidgetTester tester,
  ) async {
    await _openLab(tester, 'Лабораторная работа №6');

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Настройки'), findsOneWidget);

    // ListView строит элементы лениво — скроллим к нужным.
    // Последний Scrollable в дереве — из верхнего маршрута (настройки)
    final scrollable = find.byType(Scrollable).last;

    // Меняем заголовок главного экрана
    await tester.scrollUntilVisible(
      find.text('Заголовок главного экрана'),
      80,
      scrollable: scrollable,
    );
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Супер-калькулятор');

    await tester.scrollUntilVisible(
      find.text('Применить'),
      80,
      scrollable: scrollable,
    );
    await tester.pump();
    await tester.tap(find.text('Применить'));
    // Несколько кадров: анимация pop 300 мс + кадр на удаление маршрута
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Вернулись на калькулятор с новым заголовком — pop с результатом.
    // Проверяем внутри экрана калькулятора: в тестовом дереве маршруты
    // могут «догорать» пару кадров после pop
    final calculator = find.byType(CalculatorScreen);
    expect(calculator, findsOneWidget);
    expect(
      find.descendant(of: calculator, matching: find.text('Супер-калькулятор')),
      findsOneWidget,
    );
  });

  testWidgets('Лабораторная 7: создание матрицы', (
    WidgetTester tester,
  ) async {
    await _openLab(tester, 'Лабораторная работа №7');

    // По умолчанию 3×4
    await tester.tap(find.text('Создать'));
    await tester.pump();

    expect(find.text('Исходная матрица K(3×4)'), findsOneWidget);
  });

  testWidgets('Лабораторная 8: экран напоминалки', (
    WidgetTester tester,
  ) async {
    await _openLab(tester, 'Лабораторная работа №8');

    // Даём асинхронной инициализации плагина отработать (в тесте она
    // падает с MissingPluginException, которая обрабатывается экраном).
    // Интерфейс не ждёт инициализации и должен быть виден сразу.
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    expect(find.text('Напоминалка'), findsOneWidget);

    // Кнопки внизу списка — прокручиваем, чтобы ListView построил элементы.
    // ListView ищем внутри экрана лабораторной: на главном экране
    // под ним тоже есть ListView
    final lab = find.byType(Scaffold).last;
    final labList = find.descendant(
      of: lab,
      matching: find.byType(ListView),
    );
    await tester.drag(labList, const Offset(0, -600));
    await tester.pump();
    expect(find.text('С кнопками'), findsOneWidget);

    // Без картинки «Большая картинка» показывает подсказку,
    // не обращаясь к плагину
    await tester.tap(find.text('Большая картинка'));
    await tester.pump();
    expect(find.text('Сначала выберите картинку — или используйте другой тип'),
        findsWidgets);
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
