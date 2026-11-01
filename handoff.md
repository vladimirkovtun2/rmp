# Handoff — rmp_9plus

Одно Flutter-приложение, в котором собираются лабораторные работы по РМП.
Каждая работа живёт в отдельной папке и ничего не знает про остальные;
на главном экране есть список всех работ, из которого открывается нужная.

В проекте 8 работ: №2, 6, 7, 8 (перенесены из отдельных проектов в папке
`labs_cut/`), №9, 10, 11 (сделаны в этом проекте) и №2.1 (по методичке
«ЛР 2 Flutter РМП 090304 2024.docx»). Демо-счётчик из шаблона удалён.

## Структура

```
lib/
├── main.dart                        # Точка входа: LabsApp (MaterialApp)
├── home/
│   └── home_screen.dart             # Главный экран со списком лабораторных
└── labs/
    ├── labs.dart                    # Реестр работ: список labs с LabInfo
    ├── lab_02/
    │   └── fifteen_puzzle_screen.dart   # Пятнашки 4×4 (FifteenPuzzleScreen)
    ├── lab_06/
    │   └── calculator_screen.dart       # Калькулятор + настройки (CalculatorScreen,
    │                                    #   SettingsScreen, AppSettings)
    ├── lab_07/
    │   └── matrix_screen.dart           # Матрица K(m,n) (MatrixScreen)
    ├── lab_08/
    │   └── notifications_screen.dart    # Локальные уведомления (NotifyScreen)
    ├── lab_09/
    │   ├── lab_09_screen.dart           # Экран: грузит ассет, держит CustomPaint
    │   └── star_sky_painter.dart        # StarSkyPainter (статика)
    ├── lab_10/
    │   ├── lab_10_screen.dart           # Экран: контроллеры + AnimatedBuilder
    │   └── star_sky_animated_painter.dart # StarSkyAnimatedPainter (анимации)
    └── lab_11/
        ├── lab_11_screen.dart           # Экран: режимы ввода + кнопки
        └── maps_urls.dart               # MapsUrls: URL Google Maps/Street View

assets/
└── images/
    ├── spaceship.png                # Корабль (ассет из ресурсов)
    └── cuckoo.png                   # Кукушка (сгенерирована, 240×240)

labs_cut/                            # Исходные проекты лаб 2/6/7/8 (архив,
                                     # в сборку не входит, исключён из анализа)
```

Методичка второго семестра: «ЛР 2 Flutter РМП 090304 2024.docx» в корне
(лабы 2.1, 2.2, … — продолжают нумерацию после №11).

## Лабораторная №2 «Пятнашки»

Поле 4×4, плитки двигаются кликом в пустую ячейку (подсветка доступных
ходов и последнего хода). Перемешивание — 200 случайных допустимых ходов
из собранного состояния (гарантия решаемости). Своя конфигурация — ввод
16 чисел через запятую с валидацией. Перенесено из `labs_cut/rmp2`
без изменений логики (удалены только отдельные main/MyApp).

## Лабораторная №6 «Калькулятор»

Обычный четырёхдействийный калькулятор (цепочки операций, процент,
смена знака, диалог при делении на ноль) + экран настроек:
цвет фона, цвет текста дисплея, заголовок. Возврат результата —
`Navigator.push/pop(result)` (аналог startActivityForResult).
Радиокнопки на новом API (`RadioGroup` ancestor — `groupValue/onChanged`
у RadioListTile deprecated с Flutter 3.32). Перенесено из `labs_cut/rmp6`.

## Лабораторная №7 «Матрица K(m,n)»

Задание: найти максимум в каждой строке и заменить заданным числом.
Ввод размеров (1–30), ручной ввод ячеек или случайное заполнение,
разметка под ориентацию через `OrientationBuilder` (портрет/ландшафт).
Перенесено из `labs_cut/rmp7`.

## Лабораторная №8 «Напоминалка»

Локальные уведомления (`flutter_local_notifications`): 4 типа — с кнопкой,
длинный текст (BigTextStyle), большая картинка (BigPictureStyle, файл
из галереи через `image_picker`), InboxStyle. Звук/вибрация/LED — через
отдельные каналы под каждую комбинацию. Отличие от оригинала
(`labs_cut/rmp8`): инициализация плагина перенесена из `main()` в
`initState` экрана (в фоне, не блокирует UI, ошибки плагина гасятся).

Настройки Android для этой лабораторной:
- `AndroidManifest.xml`: разрешение `POST_NOTIFICATIONS` (Android 13+);
- `android/app/build.gradle.kts`: core library desugaring
  (`isCoreLibraryDesugaringEnabled` + `desugar_jdk_libs:2.1.4`) —
  требование flutter_local_notifications v19.

## Лабораторная №9 «Звёздное небо»

Всё рисование — в `paint(Canvas canvas, Size size)` класса `StarSkyPainter`
(`lib/labs/lab_09/star_sky_painter.dart`):

- ночное небо — `drawRect` с линейным градиентом;
- ~140 звёзд — `drawCircle` разного радиуса, оттенка и прозрачности,
  у крупных — свечение через `MaskFilter.blur`; расположение фиксировано
  (seeded `Random(9)`), чтобы небо не прыгало между перерисовками;
- месяц-серп — полный круг, из которого вторым пересекающимся кругом
  с `BlendMode.dstOut` через `canvas.saveLayer` вырезается «тень»;
  (evenOdd с двумя частично пересекающимися кругами тут не подходит —
  внешняя часть вырезающего круга тоже закрасилась бы);
- корабль — PNG из assets через `drawImageRect` с наклоном
  (`canvas.save/translate/rotate/restore`).

## Лабораторная №10 «Звёздное небо — анимации»

Копия №9 (`lib/labs/lab_10/`), все анимации через AnimationController +
AnimatedBuilder (значения контроллеров передаются в painter):

- `_space` — общий «космический» контроллер: 60 с, repeat. Всё в сцене
  построено на целых делителях 60 с, поэтому цикл стыкуется без рывков.
- Мерцание звёзд — каждая звезда пульсирует по альфе со своим числом
  оборотов за 60 с (период 7.5–60 с) и своей фазой.
- Фазы луны — вырезающий круг ездит через диск (cos с периодом 12 с):
  полнолуние → убывание → новолуние → рост.
- Корабль — летит слева направо по синусоиде (проход 20 с), нос повёрнут
  по курсу через atan наклона траектории.
- Аналоговые часы — циферблат, засечки, минутная стрелка (оборот за 60 с,
  тонкая длинная) и часовая (в 12 раз медленнее, толстая короткая);
  pivot — центр циферблата.
- Кукушка — отдельный контроллер `_cuckoo` (4 с), fade in/out через
  saveLayer с альфой; запускается `_watchHourHand`, когда значение `_space`
  перескакивает назад — часовая стрелка прошла «12» (раз в минуту).
- `TickerProviderStateMixin` — контроллеров два.

## Лабораторная №11 «Поиск места на картах»

`lib/labs/lab_11/`: место задаётся адресом (одно поле) или парой
«широта + долгота» (два поля), переключение — `SegmentedButton`.

- «Показать на картах» — `url_launcher.launchUrl` с универсальными URL
  Google Maps (`lib/labs/lab_11/maps_urls.dart`): `search/?api=1&query=...`
  (адрес кодируется через `Uri.encodeComponent`, координаты — `lat,lng`).
  Ссылки https открываются в приложении Google Maps, если оно установлено,
  иначе в браузере (на Android можно выбрать Яндекс.Карты и т.п.).
- «Просмотр улиц» — Street View: `@?api=1&map_action=pano&viewpoint=lat,lng`.
  Работает только в режиме координат: API панорам принимает только
  координаты (геокодинг адреса без ключа недоступен) — в режиме адреса
  кнопка показывает подсказку.
- Валидация: пустые поля, числа с запятой-разделителем, широта ±90,
  долгота ±180 — ошибки через SnackBar.
- В `android/app/src/main/AndroidManifest.xml` добавлен `<queries>` для
  схемы https (package visibility Android 11+), без него launchUrl падает.
- Тесты: `test/maps_urls_test.dart` (юнит, сборка URL) и виджет-тесты
  с `FakeUrlLauncher` (проверка URL, уходящего в launchUrl через UI).

## Зависимости

- `url_launcher` (лаба 11), dev: `url_launcher_platform_interface` (тесты);
- `flutter_local_notifications` + `image_picker` (лаба 8).
- Папка `labs_cut/` исключена из анализа в `analysis_options.yaml`.

## Лабораторная №2.1 «Диалоги»

`lib/labs/lab_2_1/lab_21_screen.dart` — все виды диалогов из методички,
каждый открывается своей кнопкой:

1. AlertDialog с кнопками «Да / Нет / Отмена» (выход с сохранением);
2. AlertDialog со списком ListTile — выбор элемента → SnackBar;
3. AlertDialog с одиночным выбором (RadioListTile + RadioGroup —
   deprecated groupValue/onChanged не используются);
4. AlertDialog с множественным выбором (CheckboxListTile);
5. Пользовательский диалог с TextField (контроллер — поле State, чтобы
   не диспозить его, пока TextField перестраивается при закрытии);
6. TimePickerDialog — `showTimePicker`, результат HH:mm через SnackBar;
7. DatePickerDialog — `showDatePicker` (2000–2101), результат д/м/г.

## Лабораторная №2.2 «Виджет рабочего стола»

Нативный Android-компонент (виджет домашнего экрана), а не экран
приложения — в рамках общего приложения реализовано без конфликтов:
нативная часть живёт в `android/app/src/main`, в списке лаб — экран-
превью `lib/labs/lab_2_2/lab_22_screen.dart` с тем же поведением
(тап переключает цвет фона по палитре) и инструкцией по добавлению.

Нативная часть:

- `kotlin/com/example/rmp_9plus/Lab22Widget.kt` — `AppWidgetProvider`:
  статичный текст «Hello, Widget!», по нажатию фон переключается по
  палитре из 4 цветов (голубой/фиолетовый/бирюзовый/оранжевый),
  индекс цвета хранится в SharedPreferences; смена цвета — через
  `PendingIntent.getBroadcast` на сам receiver;
- `res/layout/lab22_widget_layout.xml` — макет (LinearLayout + TextView);
- `res/xml/lab22_widget_info.xml` — параметры виджета
  (initialLayout, updatePeriodMillis=0, widgetCategory=home_screen —
  в методичке опечатка: appWidgetCategory, правильный атрибут
  android:widgetCategory, иначе AAPT не линкует ресурс);
- `AndroidManifest.xml` — `<receiver android:name=".Lab22Widget"
  android:exported="false">` с intent-filter APPWIDGET_UPDATE
  (exported обязателен с Android 12, в методичке отсутствует).

## Как добавить новую лабораторную

1. Создать папку `lib/labs/lab_NN/` и в ней экран (со своим `Scaffold`).
2. Добавить запись в список `labs` в `lib/labs/labs.dart`.
3. Готово — работа появится на главном экране. Другие файлы трогать не нужно.

## Как запустить

```bash
flutter run          # запуск на подключённом устройстве/эмуляторе
flutter analyze      # проверка линтером
flutter test         # тесты (юнит + виджет)
flutter build apk --debug   # проверка сборки под Android
```

## Текущее состояние

- Главный экран: список из 9 работ (№2, 6, 7, 8, 9, 10, 11, 2.1, 2.2).
- Лабораторные №2, 6, 7, 8 перенесены из `labs_cut/` и работают в общем
  приложении (для №8 добавлены POST_NOTIFICATIONS и desugaring).
- Лабораторные №9, 10, 11 реализованы в проекте (см. разделы выше).
- Лабораторная №2.1 реализована по методичке: все 7 видов диалогов.
- Лабораторная №2.2 — нативный виджет рабочего стола (AppWidgetProvider,
  Kotlin) + экран-превью в приложении.
- 18 тестов зелёные: список, переходы, смоук-сценарии лаб 2/6/7/8,
  сценарии лаб 2.1 (все диалоги), 2.2 (превью) и 11, юнит-тесты URL.
- Папку `labs_cut/` можно удалить — это архивная копия исходников.
