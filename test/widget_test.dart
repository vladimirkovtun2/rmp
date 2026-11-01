import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'package:rmp_9plus/labs/lab_06/calculator_screen.dart';
import 'package:rmp_9plus/labs/lab_11/maps_urls.dart';
import 'package:rmp_9plus/main.dart';

Future<void> _openLab(WidgetTester tester, String title) async {
  await tester.pumpWidget(const LabsApp());
  // Элемент может быть ниже видимой области — докручиваем
  await tester.scrollUntilVisible(
    find.text(title),
    80,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
  await tester.tap(find.text(title));
  // pumpAndSettle нельзя: CircularProgressIndicator крутится бесконечно,
  // поэтому завершаем анимацию перехода явно
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

/// Несколько кадров: закрывающийся маршрут/диалог удаляется из дерева
/// не сразу после анимации, а на следующем кадре
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('Главный экран показывает список лабораторных', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LabsApp());

    expect(find.text('Лабораторные работы'), findsOneWidget);
    // Верх списка
    for (final n in ['2', '6', '7']) {
      expect(find.text('Лабораторная работа №$n'), findsOneWidget);
    }
    // Список длиннее экрана — докручиваем до последних работ
    await tester.scrollUntilVisible(
      find.text('Лабораторная работа №2.7'),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    // Низ списка
    for (final n in ['11', '2.1', '2.2', '2.3', '2.4', '2.5', '2.6', '2.7']) {
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

  testWidgets('Лабораторная 2.1: диалог выхода', (WidgetTester tester) async {
    await _openLab(tester, 'Лабораторная работа №2.1');

    await tester.tap(find.text('AlertDialog: Да / Нет / Отмена'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Выход'), findsOneWidget);
    expect(find.text('Да'), findsOneWidget);
    expect(find.text('Нет'), findsOneWidget);
    expect(find.text('Отмена'), findsOneWidget);

    await tester.tap(find.text('Отмена'));
    await _settle(tester);
    expect(find.text('Выход'), findsNothing);
  });

  testWidgets('Лабораторная 2.1: список элементов', (
    WidgetTester tester,
  ) async {
    await _openLab(tester, 'Лабораторная работа №2.1');

    await tester.tap(find.text('AlertDialog со списком'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Пункт 2'), findsOneWidget);

    await tester.tap(find.text('Пункт 2'));
    await _settle(tester);
    expect(find.text('Вы выбрали: Пункт 2'), findsWidgets);
  });

  testWidgets('Лабораторная 2.1: множественный выбор', (
    WidgetTester tester,
  ) async {
    await _openLab(tester, 'Лабораторная работа №2.1');

    await tester.tap(find.text('AlertDialog: множественный выбор'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tap(find.text('Пункт 1'));
    await tester.pump();
    await tester.tap(find.text('Пункт 3'));
    await tester.pump();
    await tester.tap(find.text('Да'));
    await _settle(tester);

    expect(find.text('Вы выбрали: Пункт 1, Пункт 3'), findsWidgets);
  });

  testWidgets('Лабораторная 2.1: пользовательский ввод', (
    WidgetTester tester,
  ) async {
    await _openLab(tester, 'Лабораторная работа №2.1');

    await tester.tap(find.text('Пользовательский диалог'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await tester.enterText(find.byType(TextField), 'Привет, диалог');
    await tester.pump();
    await tester.tap(find.text('Да'));
    await _settle(tester);

    expect(find.text('Вы ввели: Привет, диалог'), findsWidgets);
  });

  testWidgets('Лабораторная 2.1: пикеры открываются', (
    WidgetTester tester,
  ) async {
    await _openLab(tester, 'Лабораторная работа №2.1');

    // TimePicker
    await tester.tap(find.text('TimePickerDialog'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(TimePickerDialog), findsOneWidget);
    // Закрываем тапом по барьеру
    await tester.tapAt(const Offset(5, 5));
    await _settle(tester);

    // DatePicker
    await tester.tap(find.text('DatePickerDialog'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(CalendarDatePicker), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await _settle(tester);
  });

  testWidgets('Лабораторная 2.2: превью меняет цвет по нажатию', (
    WidgetTester tester,
  ) async {
    await _openLab(tester, 'Лабораторная работа №2.2');

    expect(find.text('Hello, Widget!'), findsOneWidget);
    expect(find.textContaining('Цвет фона: Голубой'), findsOneWidget);

    await tester.tap(find.text('Hello, Widget!'));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.textContaining('Цвет фона: Фиолетовый'), findsOneWidget);
  });

  testWidgets('Лабораторная 2.3: корзина считается', (
    WidgetTester tester,
  ) async {
    await _openLab(tester, 'Лабораторная работа №2.3');

    expect(find.text('Товары'), findsOneWidget);
    expect(find.text('Сумма: 0.00 ₽'), findsOneWidget);
    expect(find.text('Товары: 0'), findsOneWidget);

    // Добавляем пиццу (890 ₽)
    await tester.tap(find.byIcon(Icons.add_circle).first);
    await tester.pump();
    expect(find.text('Товары: 1'), findsOneWidget);
    expect(find.text('Сумма: 890.00 ₽'), findsOneWidget);

    // Ещё одна пицца
    await tester.tap(find.byIcon(Icons.add_circle).first);
    await tester.pump();
    expect(find.text('Товары: 2'), findsOneWidget);
    expect(find.text('Сумма: 1780.00 ₽'), findsOneWidget);

    // Убираем одну
    await tester.tap(find.byIcon(Icons.remove_circle).first);
    await tester.pump();
    expect(find.text('Товары: 1'), findsOneWidget);
    expect(find.text('Сумма: 890.00 ₽'), findsOneWidget);
  });

  testWidgets('Лабораторная 2.4: Future с случайной длительностью', (
    WidgetTester tester,
  ) async {
    await _openLab(tester, 'Лабораторная работа №2.4');

    expect(find.text('Нажмите на кнопку для загрузки данных.'), findsOneWidget);

    await tester.tap(find.text('Загрузить данные'));
    await tester.pump();
    // Индикатор загрузки показывается, пока Future не завершён
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Задача длится случайно 1–5 с — прокручиваем fake-время на максимум
    await tester.pump(const Duration(seconds: 6));
    expect(find.text('Данные успешно загружены!'), findsOneWidget);
    expect(find.textContaining('Время выполнения:'), findsOneWidget);

    // Повторный запуск снова показывает индикатор
    await tester.tap(find.text('Загрузить данные'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
    expect(find.text('Данные успешно загружены!'), findsOneWidget);
  });

  testWidgets('Лабораторная 2.5: фрагменты добавляются и удаляются', (
    WidgetTester tester,
  ) async {
    await _openLab(tester, 'Лабораторная работа №2.5');

    expect(find.text('Фрагмент №1'), findsNothing);

    await tester.tap(find.text('Добавить фрагмент'));
    await tester.pump();
    expect(find.text('Фрагмент №1'), findsOneWidget);

    await tester.tap(find.text('Добавить фрагмент'));
    await tester.pump();
    expect(find.text('Фрагмент №2'), findsOneWidget);

    await tester.tap(find.text('Убрать фрагмент'));
    await tester.pump();
    expect(find.text('Фрагмент №2'), findsNothing);
    expect(find.text('Фрагмент №1'), findsOneWidget);
  });

  testWidgets('Лабораторная 2.6: плеер в исходном состоянии', (
    WidgetTester tester,
  ) async {
    await _openLab(tester, 'Лабораторная работа №2.6');

    expect(find.text('Трек не выбран'), findsOneWidget);
    expect(find.text('Выбрать трек на устройстве'), findsOneWidget);
    expect(find.byKey(const Key('play_button')), findsOneWidget);

    // Пока нет трека и не идёт воспроизведение — пауза и стоп выключены
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('pause_button')))
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('stop_button')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('Лабораторная 2.7: экран файлов и обработка ошибок', (
    WidgetTester tester,
  ) async {
    await _openLab(tester, 'Лабораторная работа №2.7');

    // Конфигурация и действия на месте
    expect(find.text('Dialog Title'), findsOneWidget);
    expect(find.text('Pick file'), findsOneWidget);
    expect(find.text('Pick folder'), findsOneWidget);
    expect(find.text('Save file'), findsOneWidget);
    expect(find.text('Clear temporary files'), findsOneWidget);

    // В тесте нативный плагин недоступен (UnimplementedError ловится
    // общим catch и уходит в SnackBar)
    await tester.tap(find.text('Pick file'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SnackBar), findsWidgets);
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
