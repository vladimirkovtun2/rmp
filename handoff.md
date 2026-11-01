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

## Лабораторная №2.3 «Адаптеры»

`lib/labs/lab_2_3/lab_23_screen.dart` — магазин по методичке: модель
`Product` (название, цена, иконка, остаток, количество в корзине),
список на `ListView.builder`, «адаптер» — метод `buildProductItem`
(ListTile с иконкой, ценой, остатком и кнопками +/−), в AppBar —
сумма и количество корзины. Кнопки +/− меняют остаток и не дают
уйти в минус. По п. 4 задания каталог изменён: 7 товаров со своими
ценами и остатками (пицца, кофе, мороженое, бургер, лимонад, суши,
чизкейк).

## Лабораторная №2.4 «Future»

`lib/labs/lab_2_4/lab_24_screen.dart` — асинхронный пример по методичке:
кнопка «Загрузить данные» запускает `_loadData()`: включается
`CircularProgressIndicator`, после `Future.delayed` состояние меняется
на результат. По п. 4 задания длительность задачи случайна (1–5 с,
`1 + Random().nextInt(5)`), фактическое время показывается под
результатом («Время выполнения: N с»).

## Лабораторная №2.5 «Фрагменты»

Минимальная демка формулировки методички «виджеты можно динамически
добавлять, изменять или удалять»:

- `lib/labs/lab_2_5/lab25_fragment.dart` — «фрагмент»: переиспользуемый
  виджет Lab25Fragment в отдельном файле (аналог фрагмента Android);
- `lib/labs/lab_2_5/lab_25_screen.dart` — экран с кнопками
  «Добавить/убрать фрагмент», вставляющими виджеты в дерево.

## Лабораторная №2.6 «Мультимедиа»

`lib/labs/lab_2_6/lab_26_screen.dart` — аудиоплеер по методичке:
play/pause/stop с ключами play_button / pause_button / stop_button,
ползунок позиции (seek), выбор трека на устройстве (`file_selector`,
audio/* → `DeviceFileSource`).

Плеер вынесен в `lib/labs/lab_2_6/lab_audio_handler.dart` — обёртка
AudioPlayer в MediaSession через пакет `audio_service`: система сама
рисует плеер в шторке уведомлений (на HyperOS — музыкальная шторка),
на экране блокировки и на кнопках гарнитуры; UI этого не требуется.

Два обязательных требования audio_service (иначе падает инициализация):
1. `AudioService.init` вызывается ОДИН РАЗ при старте приложения —
   глобальный хендлер создаётся в `main()` (`lib/main.dart`) до runApp;
2. MainActivity наследует `AudioServiceActivity` вместо `FlutterActivity`
   (иначе PlatformException «activity... has not provided the correct
   FlutterEngine»).

Манифест для шторки: разрешения FOREGROUND_SERVICE и
FOREGROUND_SERVICE_MEDIA_PLAYBACK, сервис `com.ryanheise.audioservice
.AudioService` (mediaPlayback) и `MediaButtonReceiver`.

Особенность: «стоп» везде реализован как `pause()` + `seek(0)`, а не
`player.stop()` — в audioplayers stop() освобождает источник, и после
него resume() играть нечего (трек пришлось бы выбирать заново).

## Лабораторная №2.7 «Работа с файлами»

`lib/labs/lab_2_7/lab_27_screen.dart` — демо file_picker по методичке:
секция Configuration (Dialog Title, Initial Directory, Default File
Name, тип файла, при FileType.custom — расширения), Actions
(Pick file / Pick folder / Save file / Clear temporary files), секция
результата (индикатор / «User has aborted the dialog» / путь к папке /
имя и путь файла / список выбранных файлов), ошибки — SnackBar.

Сниппеты методички написаны под file_picker 8.x; в проекте 13.3.0,
где API изменился: нет множественного выбора и lockParentWindow,
`pickFiles` возвращает `List<PlatformFile>` (отмена — пустой список),
`saveFile` требует байты (сохраняем текстовый файл, имя из поля
конфигурации) и возвращает `Uri?`, `clearTemporaryFiles` — void.
Зависимость: `file_picker`.

## Лабораторная №2.8 «SQLite»

`lib/labs/lab_2_8/db_service.dart` — синглтон DBService по методичке:
ленивая инициализация `MyDatabase.db`, таблица `MyTable (id, name)`;
методы `addRecord`, `updateRecord`, `deleteRecord`, `getAllRecords`,
`getSortedRecords` (orderBy name DESC). Если sqflite недоступен (тесты,
десктоп), прозрачно включается резервный режим «в памяти» — API и
поведение не меняются; на устройстве работает настоящий SQLite.

`lib/labs/lab_2_8/lab_28_screen.dart` — экран по методичке: поле ввода,
«Добавить запись», «Сортировка по имени», список записей с кнопками
редактирования (диалог «Редактировать запись») и удаления.
Зависимости: `sqflite`, `path`.

## Лабораторная №2.9 «Сервисы»

`lib/labs/lab_2_9/random_number_service.dart` — сервис по методичке:
`RandomNumberService.generateRandomNumber(min, max)` (dart:math), логика
отделена от UI.

`lib/labs/lab_2_9/lab_29_screen.dart` — экран: сервис получается через
`context.read<RandomNumberService>()` (пакет `provider`), кнопка
генерирует число 1–100. В отдельном приложении Provider стоял бы в
main() (MultiProvider, как в методичке); здесь обёртка на уровне экрана,
чтобы лаборатории не зависели друг от друга. Важно: `context.read`
вызывается от контекста под Provider (через Builder), контекст самого
State находится выше Provider и сервиса не видит.

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

- Главный экран: список из 16 работ — весь комплект: №2, 6, 7, 8, 9,
  10, 11 и 2.1–2.9 по методичке «ЛР 2 Flutter РМП 090304 2024».
- Лабораторные №2, 6, 7, 8 перенесены из `labs_cut/` и работают в общем
  приложении (для №8 добавлены POST_NOTIFICATIONS и desugaring).
- Лабораторные №9, 10, 11 реализованы в проекте (см. разделы выше).
- №2.1 — диалоги; №2.2 — нативный виджет рабочего стола; №2.3 — список
  товаров с «адаптером»; №2.4 — Future со случайной длительностью;
  №2.5 — демка фрагментов; №2.6 — аудиоплеер с шторкой (audio_service,
  MainActivity extends AudioServiceActivity, init в main);
  №2.7 — работа с файлами (file_picker 13.x); №2.8 — SQLite CRUD
  (sqflite + резервный режим в памяти); №2.9 — сервис через Provider.
- 25 тестов зелёные: список, переходы, смоук-сценарии лаб 2/6/7/8,
  сценарии лаб 2.1–2.9 и 11, юнит-тесты URL.
- Папку `labs_cut/` можно удалить — это архивная копия исходников.
- Файл `_lr2_text.txt` в корне — извлечённый текст методички (рабочий).
