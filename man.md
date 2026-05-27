# Systemd Diagnostic Cheat Sheet

### 📊 Boot Time & Process Analysis

<details>
<summary><b>ps xawf</b> — Process Tree Diagram</summary>

* [cite_start]**Навіщо і коли:** Щоб знайти завислий процес або зрозуміти ієрархію системи[cite: 2].
* [cite_start]**Що робить:** Показує повне візуальне дерево всіх активних процесів[cite: 2].
* **Що побачимо:** Вкладену діаграму, де чітко видно, що **`systemd` (PID 1)** є кореневим предком для всього іншого.
</details>

<details>
<summary><b>systemd-analyze</b> — Boot Time Benchmark</summary>

* [cite_start]**Навіщо і коли:** Швидка перевірка після змін у системі, щоб дізнатися, чи не впала швидкість завантаження[cite: 3].
* [cite_start]**Що робить:** Вимірює загальний час, витрачений на старт системи[cite: 3].
* [cite_start]**Що побачимо:** Один рядок із розбивкою часу на: *Kernel* (ядро) ➔ *Initrd* (початковий диск у пам'яті) ➔ *Userspace* (простір користувача)[cite: 3].
</details>

<details>
<summary><b>systemd-analyze blame</b> — Service Boot Times</summary>

* [cite_start]**Навіщо і коли:** Коли машина завантажується занадто довго і потрібно знайти найповільніший сервіс[cite: 4].
* [cite_start]**Що робить:** Виводить список усіх ініціалізованих служб, відсортованих від найповільнішої до найшвидшої[cite: 4].
* [cite_start]**Що побачимо:** Текстовий список із мітками часу (наприклад, `5.2s networkd.service`) вгорі[cite: 4].
</details>

<details>
<summary><b>systemd-analyze critical-chain</b> — Critical Boot Path</summary>

* **Навіщо і коли:** Коли інформації з `blame` недостатньо. [cite_start]Показує лише ті сервіси, які реально затримали фінальний етап завантаження[cite: 5].
* [cite_start]**Що робить:** Будує дерево залежностей служб, які змушені були чекати одна на одну при старті[cite: 5].
* [cite_start]**Що побачимо:** Деревоподібну структуру з тимчасовими мітками `@`, яка підсвічує конкретний ланцюжок "вузьких місць"[cite: 5].
</details>

---

### 🎨 Visualizing Dependencies (Graphviz)

<details>
<summary><b>sudo apt install graphviz</b> — Graphic Engine Setup</summary>

* [cite_start]**Навіщо і коли:** Виконується один раз перед генерацією графічних діаграм залежностей[cite: 6].
* [cite_start]**Що робить:** Встановлює набір утилити (включаючи `dot`), необхідних для конвертації текстових логів у векторну графіку (`.svg`)[cite: 6, 10].
* [cite_start]**Що побачимо:** Стандартні логи інсталяції пакетного менеджера `apt`[cite: 6].
</details>

<details>
<summary><b>systemd-analyze plot > bootup.svg</b> — Graphical Boot Timeline</summary>

* [cite_start]**Навіщо і коли:** Чудово підходить для документації, детального візуального аналізу або звіту[cite: 7].
* [cite_start]**Що робить:** Генерує інтерактивний векторний графік часової шкали всього процесу завантаження[cite: 7].
* **Що побачимо:** Кольорову діаграмму, де по осі X йде час, а по осі Y — список сервісів із смугами, які показують, коли кожен з них стартував і фінішував.
</details>

<details>
<summary><b>systemd-analyze dot --to-pattern='*.target' --from-pattern='*.target' | dot -Tsvg > targets.svg</b> — Target Flowchart</summary>

* [cite_start]**Навіщо і коли:** Щоб розібратися в архітектурних етапах (Targets) завантаження Linux[cite: 8, 9, 10].
* [cite_start]**Що робить:** Фільтрує тисячі окремих сервісів і мапує зв'язки виключно між юнітами типу `.target`[cite: 8, 9, 10].
* **Що побачимо:** Чисту блок-схему зі стрілками, яка показує послідовність етапів завантаження (наприклад, *Basic* ➔ *Network* ➔ *Multi-user*).
</details>

---

### 🔍 Inspecting Environment & Service Properties

<details>
<summary><b>systemctl show-environment</b> — Global Systemd Variables</summary>

* [cite_start]**Навіщо і коли:** Коли сервіс не бачить потрібний шлях (PATH) або системну змінну[cite: 12].
* [cite_start]**Що робить:** Виводить список змінних оточення, які `systemd` передає всім процесам, що запускає[cite: 12].
* **Що побачимо:** Список форматі `KEY=VALUE`, схожий на вивід команди `env`.
</details>

<details>
<summary><b>systemctl cat ssh.service</b> — View Unit File Configuration</summary>

* [cite_start]**Навіщо і коли:** Швидко глянути, як налаштований сервіс, без пошуку його файлу в `/lib/...` чи `/etc/...`[cite: 13].
* [cite_start]**Що робить:** Виводить повний вміст файлу конфігурації юніта, а також всі його drop-in файли розширення (overrides)[cite: 13, 28].
* [cite_start]**Що побачимо:** Текст конфігурації з секціями `[Unit]`, `[Service]` та `[Install]`[cite: 13, 61, 71, 75].
</details>

<details>
<summary><b>systemctl show ssh.service [-p ExecMainPID [--value]]</b> — Inspect Low-Level Properties</summary>

* [cite_start]**Навіщо і коли:** Для парсингу всередині bash-скриптів, коли потрібно дізнатися PID або параметри живого сервісу[cite: 14, 15, 16].
* [cite_start]**Що робить:** Показує внутрішні низькорівневі параметри `systemd` для конкретного юніта[cite: 14]. [cite_start]Прапорець `-p` фільтрує конкретну властивість, а `--value` прибирає назву параметра, залишаючи тільки чисте значення[cite: 15, 16].
* [cite_start]**Що побачимо:** Лише конкретне число (наприклад, актуальний PID процесу)[cite: 16].
</details>

---

### ⚙️ Managing Services & Control Directory

<details>
<summary><b>systemctl status / stop / start cups</b> — Basic Service Control</summary>

* [cite_start]**Навіщо і коли:** Повсякденне адміністрування та перезапуск служб при зміні конфігів[cite: 19, 20, 21].
* [cite_start]**Що робить:** Перевіряє стан, зупиняє або запускає вибрану службу (у прикладі — сервіс друку CUPS)[cite: 18, 19, 20, 21].
* [cite_start]**Що побачимо:** Інтерактивний статус (Active/Inactive), PID та останні рядки логів юніта[cite: 19].
</details>

<details>
<summary><b>sudo systemctl set-property cups MemoryMax=2G</b> — Runtime Resource Limits</summary>

* [cite_start]**Навіщо і коли:** Коли сервіс починає "прожирати" пам'ять і потрібно обмежити його апетити без ручного редагування файлів[cite: 24].
* [cite_start]**Що робить:** На льоту створює динамічне обмеження ресурсів (cgroups) для сервісу[cite: 24]. [cite_start]Налаштування зберігаються у тимчасовій папці `/etc/systemd/system.control/`[cite: 28].
* [cite_start]**Що побачимо:** Команда виконується мовчки, але перевірити результат можна через `systemctl show cups -p MemoryMax`[cite: 26].
</details>

<details>
<summary><b>sudo rm -rf /etc/systemd/system.control/cups.service.d && systemctl daemon-reload</b> — Clean Dynamic Limits</summary>

* [cite_start]**Навіщо і коли:** Коли потрібно скасувати ліміти, задані через `set-property`[cite: 24, 28].
* [cite_start]**Що робить:** Видаляє папку згенерованих конфігів та повністю перечитує конфігурацію `systemd` з диска[cite: 28, 29].
* [cite_start]**Що побачимо:** Сервіс повертається до своїх заводських налаштувань лімітів пам'яті[cite: 31, 32].
</details>

---

### 🗺️ Working with systemd Targets (Runlevels)

<details>
<summary><b>runlevel / systemctl get-default</b> — Check Current Runlevel</summary>

* [cite_start]**Навіщо і коли:** Щоб дізнатися, в якому режимі завантажилась система — консольному чи графічному[cite: 34, 35].
* [cite_start]**Що робить:** Показує старий лігасі runlevel (наприклад, `N 5`) та поточний таргет за замовчуванням (наприклад, `graphical.target`)[cite: 34, 35].
* [cite_start]**Що побачимо:** Назву цільового юніта, який визначає фінальний стан завантаження ОС[cite: 35].
</details>

<details>
<summary><b>sudo systemctl set-default multi-user.target</b> — Change Default Boot Target</summary>

* [cite_start]**Навіщо і коли:** Використовується для серверів для економії оперативної пам'яті (щоб не запускати важку графічну оболонку)[cite: 36].
* [cite_start]**Що робить:** Назавжди перемикає дефолтне завантаження системи в текстовий багатокористувацький режим із мережею[cite: 36].
* **Що побачимо:** Створення симлінку у директорії `/etc/systemd/system/`.
</details>

<details>
<summary><b>sudo systemctl isolate basic.target</b> — Switch Target on the Fly</summary>

* [cite_start]**Навіщо і коли:** Потрібно для аварійних робіт чи обслуговування дискової системи, коли треба "викинути" всіх користувачів та зупинити мережу[cite: 41].
* [cite_start]**Що робить:** Зупиняє всі сервіси поточного таргету і миттєво перемикає систему на вказаний (мінімальний базовий етап)[cite: 41].
* **Що побачимо:** Закриття консолей, зупинку мережевих служб і перехід у мінімалістичний режим роботи.
</details>

<details>
<summary><b>ls -l /sbin/{halt, poweroff, reboot, shutdown}</b> — System Power Management Links</summary>

* [cite_start]**Навіщо і коли:** Розуміння архітектури Linux: як працюють класичні команди вимкнення ПК[cite: 45].
* [cite_start]**Що робить:** Показує, куди ведуть бінарні файли керування живленням[cite: 45].
* [cite_start]**Що побачимо:** Всі ці команди є звичайними симлінками (symlinks), які вказують на єдиний головний інструмент — `/bin/systemctl`[cite: 45].
</details>

---

### 📁 Structure of Unit Directories

<details>
<summary><b>ls -l /lib/systemd/system | /run/systemd/system | /etc/systemd/system</b> — Unit Hierarchy</summary>

* [cite_start]**Навіщо і коли:** Для пошуку файлів конфігурації та розуміння пріоритетів їх завантаження[cite: 49, 50, 52].
* [cite_start]**Що робить:** Відображає вміст трьох головних шарів конфігурації `systemd`[cite: 49, 50, 52]:
  1. [cite_start]`/lib/...` — заводські конфіги, встановлені пакетами (не можна редагувати руками)[cite: 49].
  2. [cite_start]`/run/...` — динамічні юніти, створені під час поточної сесії в пам'яті[cite: 50].
  3. [cite_start]`/etc/...` — адміністраторські файли конфігурацій (мають найвищий пріоритет)[cite: 52].
* [cite_start]**Що побачимо:** Списки `.service`, `.target`, `.timer` файлів та кастомні папки конфігурації[cite: 13, 36, 55].
</details>

---

### ⏱️ Configuring systemd Timers (Cron Alternative)

<details>
<summary><b>systemctl list-timers</b> — View Active Scheduled Tasks</summary>

* [cite_start]**Навіщо і коли:** Перевірити, які фонові таски (очищення логів, fstrim, бекапи) зараз заплановані та коли вони відпрацюють[cite: 55].
* [cite_start]**Що робить:** Виводить список усіх активних таймерів у системі[cite: 55].
* [cite_start]**Що побачимо:** Таблицю з колонками: коли таймер спрацює наступного разу, скільки часу залишилось, і який саме сервіс він запустить[cite: 55, 56].
</details>

<details>
<summary><b>systemd-analyze calendar "Mon..Fri *-*-* 09..17:00/5"</b> — Parse Calendar Events</summary>

* [cite_start]**Навіщо і коли:** Перед написанням свого таймера, щоб перевірити, чи правильно ти склав розклад[cite: 57, 58].
* [cite_start]**Що робить:** Аналізує рядок розкладу (OnCalendar) та вираховує точний час наступних запусків[cite: 57, 58, 64].
* [cite_start]**Що побачимо:** Валідацію синтаксису і точні дати майбутніх 5 запусків (наприклад: робочі дні з 9 до 17 кожні 5 секунд)[cite: 58].
</details>

<details>
<summary><b>sudo systemctl edit --full --force blahwoof.timer / .service</b> — Create Custom Timer</summary>

* [cite_start]**Навіщо і коли:** Створення власних скриптів автоматизації без використання старого `crontab`[cite: 60, 68].
* [cite_start]**Що робить:** Створює з нуля нову пару файлів: `.timer` (задає розклад запусків) та однойменний `.service` (описує, який скрипт запустити при спрацьовуванні)[cite: 60, 64, 68, 74].
* [cite_start]**Що побачимо:** Текстовий редактор для заповнення секцій на кшталт `[Timer]` з параметром `OnCalendar=`[cite: 63, 64].
</details>

---

### 📜 Configuring systemd Journaling (Log Analysis)

<details>
<summary><b>sudo journalctl --list-boots / -b 0</b> — Boot Session Logs</summary>

* [cite_start]**Навіщо і коли:** Коли після перезавантаження впав сервіс і потрібно прочитати логи конкретно поточної або минулої сесії ОС[cite: 88, 89].
* [cite_start]**Що робить:** `--list-boots` виводить список усіх збережених циклів увімкнення системи[cite: 88]. [cite_start]Прапорець `-b 0` відкриває логи поточної сесії, а `-b -1` — попередньої[cite: 89].
* **Що побачимо:** Список індексів завантажень або стрічку системних повідомлень від ядра та сервісів за вибраний проміжок.
</details>

<details>
<summary><b>sudo journalctl -u dbus.service --follow</b> — Live Service Monitoring</summary>

* [cite_start]**Навіщо і коли:** Дебаг конкретного сервісу в реальному часі під час тестів[cite: 92].
* [cite_start]**Що робить:** Фільтрує логи лише по одному юніту (`-u`) та тримає сесію відкритою, дописуючи нові рядки на екран (`--follow`)[cite: 91, 92].
* **Що побачимо:** Постійно оновлюваний потік повідомлень від вказаної служби.
</details>

<details>
<summary><b>sudo journalctl --since=-5m / --since=today</b> — Time-Based Filtering</summary>

* [cite_start]**Навіщо і коли:** Пошук інцидентів, які сталися щойно або протягом поточної доби[cite: 95, 96].
* [cite_start]**Що робить:** Обрізає вивід логів за заданий часовий проміжок (наприклад, за останні 5 хвилин чи з початку дня)[cite: 95, 96].
* **Що побачимо:** Тільки ті системні події, які потрапили у цей таймфрейм.
</details>

<details>
<summary><b>sudo journalctl _UID=1000 / _SYSTEMD_CGROUP=...</b> — Metadata Logging Filters</summary>

* [cite_start]**Навіщо і коли:** Глибокий розбір інцидентів, коли потрібно побачити дії конкретного користувача або процесу в cgroup[cite: 94, 101].
* [cite_start]**Що робить:** Фільтрує логи за внутрішніми системними метаданими та системними параметрами Linux[cite: 94, 101].
* [cite_start]**Що побачимо:** Чистий лог дій, згенерований виключно вказаним UID чи scope-контекстом[cite: 94, 101].
</details>

<details>
<summary><b>journalctl -x / --disk-usage / --vacuum-size=500M</b> — Log Catalog & Maintenance</summary>

* [cite_start]**Навіщо і коли:** Коли логи займають занадто багато місця на диску і забивають систему[cite: 106, 108].
* [cite_start]**Що робить:** `-x` додає до помилок розшифровку з системного каталогу рішень[cite: 104]; [cite_start]`--disk-usage` показує об'єм файлів логів на диску[cite: 106]; [cite_start]`--vacuum-size` безпечно видаляє найстаріші логи, залишаючи лише вказаний об'єм (наприклад, 500 мегабайт)[cite: 108].
* [cite_start]**Що побачимо:** Статистику використання диска або підтвердження про видалення застарілих журналів логування[cite: 106, 108].
</details>

---

### 📦 Using systemd Containers (nspawn & machinectl)

<details>
<summary><b>sudo debootstrap --arch=amd64 trixie /var/lib/machines/trixie1</b> — Pull OS Image</summary>

* [cite_start]**Навіщо і коли:** Створення легковагого ізольованого оточення (контейнера) без використання Docker[cite: 110].
* [cite_start]**Що робить:** Розгортає мінімальну чисту кореневу файлову систему Debian/Ubuntu у вказану папку[cite: 110].
* [cite_start]**Що побачимо:** Завантаження та розпакування базових системних пакетів ОС у цільову директорію[cite: 110].
</details>

<details>
<summary><b>sudo systemd-nspawn -D /var/lib/machines/trixie1 [-b]</b> — Spawn & Boot Container</summary>

* [cite_start]**Навіщо і коли:** Запуск контейнера для налаштування всередині нього (наприклад, зміни паролів чи встановлення софту)[cite: 111].
* **Що робить:** Запускає ізольований простір імен для папки. [cite_start]Параметр `-b` робить повноцінне завантаження (boot) віртуальної ОС із запуском власного `systemd` всередині контейнера[cite: 111, 112].
* [cite_start]**Що побачимо:** Миттєвий перехід у консоль контейнера або запуск повноцінного логу завантаження гостьової системи[cite: 111]. [cite_start]Выхід — трикратне натискання `Ctrl + ]`[cite: 111].
</details>

<details>
<summary><b>sudo machinectl start / status / login / stop trixie1</b> — Manage Active Containers</summary>

* [cite_start]**Навіщо і коли:** Основний інструмент адміністратора для керування життєвим циклом локальних контейнерів[cite: 111].
* [cite_start]**Що робить:** Запускає контейнер у фоновому режимі, перевіряє його статус, підключається до консолі сесії або повністю зупиняє роботу[cite: 111].
* [cite_start]**Що побачимо:** Статус контейнера, дерево його внутрішніх процесів та інтерфейс авторизації[cite: 111].
</details>

---

### 🛡️ Resource Management via cgroups v2

<details>
<summary><b>systemd-cgtop</b> — Real-time CGroup Resource Monitor</summary>

* [cite_start]**Навіщо і коли:** Коли сервер гальмує і треба зрозуміти, яка саме група служб (або контейнер) утилізує процесор чи пам'ять[cite: 113].
* [cite_start]**Що робить:** Аналог класичного `top`, але сортує споживання ресурсів не за окремими PID, а за контрольними групами (cgroups)[cite: 113].
* [cite_start]**Що побачимо:** Інтерактивну таблицю з розподілом CPU, Memory та кількості процесів за слайсами та сервісами (наприклад, `system.slice`, `user.slice`)[cite: 94, 113].
</details>

<details>
<summary><b>MemoryHigh=512M / MemoryMax=768M</b> — Memory Regulation</summary>

* [cite_start]**Навіщо і коли:** Захист хост-системи від витоків пам'яті у додатках[cite: 114].
* [cite_start]**Що робить:** Параметри всередині файлу сервісу `[Service]`[cite: 113, 114]:
  * `MemoryHigh` — м'який ліміт; [cite_start]при перевищенні systemd починає throttling та забирає у процесу зайві сторінки[cite: 114].
  * `MemoryMax` — жорсткий ліміт; [cite_start]якщо процес досягає його, він миттєво завершується через ядро системи (OOM Kill)[cite: 114, 118].
* [cite_start]**Що побачимо:** Рядки конфігурації у файлі юніта, які застосовуються після `systemctl daemon-reload`[cite: 114].
</details>

<details>
<summary><b>CPUWeight=100 / CPUWeight=300</b> — CPU Proportional Shares</summary>

* [cite_start]**Навіщо і коли:** Налаштування пріоритетів обчислень між сервісами в умовах високого навантаження на процесор[cite: 116].
* [cite_start]**Що робить:** Задає відносну "вагу" процесорного часу для контрольної групи (за замовчуванням у всіх 100)[cite: 116]. [cite_start]Сервіс із вагою 300 отримає у 3 рази більше тактів CPU, ніж сервіс із вагою 100, якщо процесор завантажений на 100%[cite: 116].
* **Що побачимо:** Рівномірний та справедливий поділ потужностей процесора відповідно до виділених коефіцієнтів.
</details>

---

### 🚨 Out-Of-Memory Guard (systemd-oomd)

<details>
<summary><b>oomctl / journalctl -u systemd-oomd</b> — Userspace OOM Daemon Control</summary>

* [cite_start]**Навіщо і коли:** Моніторинг та налаштування сучасного захисту системи від повного зависання через брак ОЗУ[cite: 118].
* [cite_start]**Що робить:** Керує демоном `systemd-oomd`, який діє на випередження на основі показників тиску на ресурси (PSI)[cite: 118, 119]. [cite_start]На відміну від стандартного Kernel OOM, він вбиває конкретний cgroup, що порушив ліміт, раніше, ніж хост-система впаде в ступор[cite: 118].
* [cite_start]**Що побачимо:** `oomctl` виведе поточні налаштовані ліміти тиску пам'яті (наприклад, `ManagedOOMMemoryPressureLimit=80%`), а журнал покаже історію того, які саме сервіси були завершені для порятунку сервера[cite: 118].
</details>

---
