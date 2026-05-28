# Systemd Advanced Configuration & Diagnostic Cheat Sheet

Глобальна шпаргалка з адміністрування, моніторингу ресурсів, керування часом та глибокого аудиту логів за допомогою інструментів екосистеми `systemd`.

---

## 📊 1. Boot Time & Process Analysis

<details>
<summary><b>ps xawf</b> — Process Tree Diagram</summary>

* **Навіщо і коли:** Щоб знайти завислий процес, розібратися в структурі запущених служб або зрозуміти ієрархію системи.
* **Що робить:** Виводить повне інтерактивне дерево всіх активних процесів у системі.
* **Що побачимо:** Вкладену діаграму, де чітко видно, що **`systemd` (PID 1)** є кореневим предком для всього іншого софту в ОС.
* **Short Description:** *Profiles system boot components speed metrics and lists units sorted by execution delay times via `systemd-analyze blame` parsing.*
</details>

<details>
<summary><b>systemd-analyze</b> — Boot Time Benchmark</summary>

* **Навіщо і коли:** Швидка перевірка після змін у конфігах чи оновлень системи, щоб дізнатися, чи не впала швидкість завантаження.
* **Що робить:** Вимірює загальний час, витрачений на старт ядра та простору користувача.
* **Що побачимо:** Один рядок із розбивкою часу на: *Kernel* (ядро) ➔ *Initrd* (початковий диск у пам'яті) ➔ *Userspace* (простір користувача).
* **Short Description:** *Profiles system boot performance, generating execution breakdowns and mapping dependency hierarchies.*
</details>

<details>
<summary><b>systemd-analyze blame</b> — Service Boot Times</summary>

* **Навіщо і коли:** Коли машина завантажується занадто довго і потрібно знайти конкретний найповільніший сервіс-винуватець.
* **Що робить:** Виводить список усіх ініціалізованих служб, відсортованих від найповільнішої до найшвидшої.
* **Що побачимо:** Текстовий список із мітками часу (наприклад, `5.2s networkd.service`) на самому початку виводу.
* **Short Description:** *Lists running service units sorted by their initialization execution delay times during the bootstrap sequence.*
</details>

<details>
<summary><b>systemd-analyze critical-chain</b> — Critical Boot Path</summary>

* **Навіщо і коли:** Коли інформації з `blame` недостатньо. Показує лише ті сервіси, які реально затримали фінальний етап завантаження (критичний шлях).
* **Що робить:** Будує дерево залежностей служб, які змушені були чекати одна на одну при старті.
* **Що побачимо:** Деревоподібну структуру з тимчасовими мітками `@`, яка підсвічує конкретний ланцюжок "вузьких місць".
* **Short Description:** *Constructs the critical dependency chain path highlighting units that directly delayed the final multi-user milestone.*
</details>

---

## 🎨 2. Visualizing Dependencies (Graphviz)

<details>
<summary><b>sudo apt install graphviz -y</b> — Graphic Engine Setup</summary>

* **Навіщо і коли:** Виконується один раз перед генерацією графічних діаграм залежностей системних юнітів.
* **Що робить:** Встановлює набір утиліт (включаючи компилятор `dot`), необхідних для конвертації текстових логів у векторну графіку (`.svg`).
* **Що побачимо:** Стандартний лог інсталяції пакетного менеджера `apt`.
* **Short Description:** *Installs the Graphviz dot rendering package to enable automated generation of visual system charts.*
</details>

<details>
<summary><b>systemd-analyze plot > bootup.svg</b> — Graphical Boot Timeline</summary>

* **Навіщо і коли:** Чудово підходить для документації, детального візуального аналізу або звіту з лабораторної.
* **Що робить:** Генерує інтерактивний векторний графік часової шкали всього процесу завантаження системи.
* **Що побачимо:** Кольорову діаграму, де по осі X йде час, а по осі Y — список сервісів із смугами, які показують, коли кожен з них стартував і фінішував.
* **Short Description:** *Generates a detailed, visual SVG timeline graph mapping out start and runtime durations for every boot workload.*
</details>

<details>
<summary><b>systemd-analyze dot --to-pattern='*.target' --from-pattern='*.target' | dot -Tsvg > targets.svg</b> — Target Flowchart</summary>

* **Навіщо і коли:** Щоб розібратися в архітектурних етапах (Targets) завантаження Linux та їх взаємозв'язках.
* **Що робить:** Фільтрує тисячі окремих сервісів і мапує зв'язки виключно між юнітами типу `.target`.
* **Що побачимо:** Чисту блок-схему зі стрілками, яка показує послідовність етапів завантаження (наприклад, *Basic* ➔ *Network* ➔ *Multi-user*).
* **Short Description:** *Compiles an internal target dependency flowchart utilizing piped Graphviz engines into a vector format.*
</details>

---

## 🔍 3. Inspecting Environment & Service Properties

<details>
<summary><b>systemctl show-environment</b> — Global Systemd Variables</summary>

* **Навіщо і коли:** Коли твій кастомний сервіс чи скрипт не бачить потрібний шлях (`PATH`) або системну змінну.
* **Що робить:** Виводить список змінних оточення, які менеджер `systemd` передає всім процесам, які він запускає.
* **Що побачимо:** Список у форматі `KEY=VALUE`, схожий на вивід класичної команди `env`.
* **Short Description:** *Exposes global systemd environment configuration block allocations managed by PID 1.*
</details>

<details>
<summary><b>systemctl cat ssh.service</b> — View Unit File Configuration</summary>

* **Навіщо і коли:** Швидко глянути, як налаштований сервіс, які прапорці запуску прописані, без пошуку його файлу в системних папках.
* **Що робить:** Виводить повний вміст файлу конфігурації юніта, а також всі його drop-in файли розширення (overrides).
* **Що побачимо:** Текст конфігурації з секціями `[Unit]`, `[Service]` та `[Install]`.
* **Short Description:** *Outputs the raw, unedited master unit layout alongside all configured drop-in directory extension layers.*
</details>

<details>
<summary><b>systemctl show ssh.service</b> — Inspect All Low-Level Properties</summary>

* **Навіщо і коли:** Глибокий аналіз стану сервісу: перевірка встановлених лімітів, тайм-аутів та внутрішніх прапорів systemd.
* **Що робить:** Виводить абсолютно всі низькорівневі внутрішні параметри та змінні стану, які системний менеджер зберігає для цього юніта.
* **Що побачимо:** Величезний текстовий список параметрів у форматі `Property=Value` (наприклад, `Type=notify`, `Restart=on-failure`).
* **Short Description:** *Queries and displays comprehensive low-level runtime engine parameters associated with the target unit.*
</details>

<details>
<summary><b>systemctl show ssh.service -p ExecMainPID [--value]</b> — Filter Granular Metadata</summary>

* **Навіщо і коли:** Для використання всередині bash-скриптів автоматизації, коли потрібно дізнатися чіткий параметр (наприклад, PID) без зайвого тексту.
* **Що робить:** Фільтрує вивід `show`, залишаючи лише вказану властивість (`-p`). Прапорець `--value` прибирає назву параметра, повертаючи тільки чисте значення.
* **Що побачимо:** Залежно від прапорців: або рядок `ExecMainPID=1234`, або просто чисте число `1234`.
* **Short Description:** *Extracts verified scalar internal unit metadata using explicit single-property and raw value filtering switches.*
</details>

---

## ⚙️ 4. Managing Services & Resource Limits (cgroups v2)

<details>
<summary><b>systemctl status / stop / start cups</b> — Basic Service Control</summary>

* **Навіщо і коли:** Повсякденне адміністрування, запуск, зупинка служб та діагностика їх первинного стану.
* **Що робить:** Змінює стан або перевіряє працездатність конкретної служби (у прикладі — сервіс друку CUPS).
* **Що побачимо:** Інтерактивний статус (Active/Inactive), PID головного процесу, дерево cgroup та останні рядки логів юніта з journald.
* **Short Description:** *Controls active unit operating states and requests immediate status diagnostics reports from the initialization manager.*
</details>

<details>
<summary><b>sudo systemctl set-property cups MemoryMax=2G</b> — Dynamic Runtime Resource Limits</summary>

* **Навіщо і коли:** Коли сервіс починає неконтрольовано споживати ресурси, і треба обмежити його ліміти пам'яті прямо зараз, без перезапуску та без редагування конфігів.
* **Що робить:** На льоту створює динамічне обмеження ресурсів (cgroups v2) для сервісу. Зміни записуються у спеціальну папку `/etc/systemd/system.control/`.
* **Що побачимо:** Команда виконується мовчки, а результат миттєво застосовується до живого процесу.
* **Short Description:** *Mutates resource control limits in real-time utilizing live `set-property` assignments within cgroups v2 configuration layers.*
</details>

<details>
<summary><b>sudo rm -rf /etc/systemd/system.control/cups.service.d && systemctl daemon-reload</b> — Purge Runtime Limits</summary>

* **Навіщо і коли:** Коли експеримент закінчено і потрібно повернути сервіс до його первинних заводських лімітів, видаливши все, що зробила команда `set-property`.
* **Що робить:** Повністю очищає папку згенерованих на льоту налаштувань контролю ресурсів і змушує systemd перечитати стан з диска.
* **Що побачимо:** Сервіс скидає динамічні обмеження і повертається до конфігурації за замовчуванням.
* **Short Description:** *Purges transient control drop-in trees from the system control directory and triggers a complete daemon architecture reload.*
</details>

---

## 🗺️ 5. Working with systemd Targets (Runlevels)

<details>
<summary><b>runlevel</b> — Legacy Runlevel Verification</summary>

* **Навіщо і коли:** Для сумісності, коли потрібно дізнатися поточний стан системи у термінах старого SysVinit.
* **Що робить:** Зчитує поточний та попередній рівні виконання операційної системи.
* **Що побачимо:** Два символи, наприклад `N 5` (де N — попередній рівень був відсутній, 5 — поточний повноцінний графічний режим).
* **Short Description:** *Queries the system backend to return the legacy SysV runlevel status mapping table data.*
</details>

<details>
<summary><b>systemctl get-default</b> — Inspect Default Boot Milestone</summary>

* **Навіщо і коли:** Перевірка перед перезавантаженням сервера, щоб переконатися, що він завантажиться у правильному режимі (текстовому чи графічному).
* **Що робить:** Показує таргет, який призначено головною метою під час запуску системи.
* **Що побачимо:** Назву цільового юніта (наприклад, `multi-user.target` або `graphical.target`).
* **Short Description:** *Identifies and outputs the active target profile set as the persistent default initialization layer.*
</details>

<details>
<summary><b>sudo systemctl set-default multi-user.target</b> — Change Default Runlevel</summary>

* **Навіщо і коли:** Стандартний крок при налаштуванні серверів задля економії ресурсів (ОЗУ та CPU), щоб вимкнути запуск важкої графічної оболонки.
* **Що робить:** Назавжди встановлює текстовий багатокористувацький режим із мережею як дефолтний етап завантаження.
* **Що побачимо:** Повідомлення про видалення старого та створення нового системного симлінку (symlink) у папці `/etc/systemd/system/default.target`.
* **Short Description:** *Modifies the core bootstrap target configurations, switching the default operational runlevel permanently.*
</details>

<details>
<summary><b>sudo systemctl isolate basic.target</b> — Switch Active Target on the Fly</summary>

* **Навіщо і коли:** Для проведення небезпечних технічних робіт, обслуговування дисків чи баз даних, коли потрібно миттєво зупинити всі зайві сервіси та мережу.
* **Що робить:** Зупиняє всі сервіси поточного таргету, які не потрібні для вказаного цільового таргету, та ізолює систему на базовому кроці.
* **Що побачимо:** Масове закриття фонових служб, консолей користувачів та перехід ОС у мінімалістичний режим роботи.
* **Short Description:** *Forces a hot swap of the running environment by isolating the initialization target state and halting non-essential processes.*
</details>

<details>
<summary><b>systemctl list-units -t target [--all]</b> — List System Milestones</summary>

* **Навіщо і коли:** Перевірка доступних у системі "етапів" завантаження, пошук потрібного таргета для залежностей.
* **Що робить:** Виводить список усіх завантажених або взагалі наявних (`--all`) таргет-юнітів у системі.
* **Що побачимо:** Таблицю з назвами `.target` файлів, їх описом та поточним станом (active/inactive).
* **Short Description:** *Lists running or dormant target units inside systemd memory state parameters to audit structural targets.*
</details>

<details>
<summary><b>ls -l /sbin/{halt, poweroff, reboot, shutdown}</b> — Verify Power Tool Symlinks</summary>

* **Навіщо і коли:** Розуміння архітектури сучасного Linux: доказ того, що всі процеси живлення тепер контролює один інструмент.
* **Що робить:** Перевіряє файли класичних утиліт вимкнення та перезавантаження комп'ютера.
* **Що побачимо:** Вивід покаже, що всі ці файли є звичайними симлінками, які вказують на єдиний головний бінарник `/bin/systemctl`.
* **Short Description:** *Exposes binary environment routing, showing that legacy system power utilities are symlinks pointing directly to systemctl.*
</details>

---

## 📁 6. Inspecting Configuration Directories

<details>
<summary><b>ls -l /lib/systemd/system | /run/systemd/system | /etc/systemd/system</b> — Audit File Hierarchy</summary>

* **Навіщо і коли:** Для точного розуміння, звідки завантажується конфіг сервісу і який файл має найвищий пріоритет при перевантаженні налаштувань.
* **Що робить:** Показує вміст трьох головних шарів ієрархії:
  1. `/lib/...` (або `/usr/lib/...`) — заводські конфіги від розробників пакетів (руками не чіпаємо).
  2. `/run/...` — тимчасові юніти, створені в пам'яті під час поточної сесії.
  3. `/etc/...` — конфіги адміністратора, які мають **найвищий пріоритет** і перевизначають усе.
* **Що побачимо:** Списки файлів конфігурацій та сервісних директорій.
* **Short Description:** *Inspects file system arrays to audit the execution priority hierarchy between vendor, runtime, and local administrator configurations.*
</details>

---

## ⏱️ 7. Setting Up Calendars & Timers (Cron Alternative)

<details>
<summary><b>systemctl list-timers</b> — Monitor Automated Schedules</summary>

* **Навіщо і коли:** Перевірити працездатність планувальника задач: які таски (бекапи, очищення логів, fstrim) зараз активні та коли вони запустяться.
* **Що робить:** Виводить детальну таблицю всіх активованих в системі таймерів.
* **Що побачимо:** Стовпчики: *NEXT* (коли наступний запуск), *LEFT* (скільки залишилось чекати), *LAST* (коли був минулий запуск), і який саме сервіс-виконавець прикріплено.
* **Short Description:** *Displays an active matrix of all operational cron-alternative timer units, tracking exact next execution countdowns.*
</details>

<details>
<summary><b>systemd-analyze calendar "Mon..Fri *-*-* 09..17:00/5"</b> — Parse & Validate Calendar Rules</summary>

* **Навіщо і коли:** Тестування та перевірка синтаксису виразу розкладу (`OnCalendar`) **перед** тим, як прописувати його в реальний файл таймера.
* **Що робить:** Проганяє рядок через синтаксичний аналізатор systemd та розраховує точний час майбутніх запусків.
* **Що побачимо:** Підтвердження валідності або опис помилки, а також точні дати та секунди наступних 5 реальних спрацьовувань правила.
* **Short Description:** *Validates automation calendar expressions through systemd temporal parser engines to preview targeted schedules.*
</details>

<details>
<summary><b>sudo systemctl edit --full --force blahwoof.timer</b> — Create Custom Scheduled Automation</summary>

* **Навіщо і коли:** Створення власної задачі за розкладом. Повністю замінює старий негнучкий `crontab`.
* **Що робить:** Створює новий чистий файл `.timer` у папці `/etc/systemd/system/` та відкриває текстовий редактор.
* **Що побачимо:** Редактор конфігурації, куди ми вносимо секцію `[Timer]` (наприклад, параметр `OnCalendar=*-*-* *:*:0/5` для запуску кожні 5 секунд та `AccuracySec=1s` для високої точності).
* **Short Description:** *Deploys a precision scheduling unit file wrapper directly targeting custom system tasks automation logs.*
</details>

---

## 📜 8. Advanced Logging & Auditing (journalctl)

<details>
<summary><b>sudo journalctl --list-boots</b> — Boot Sessions Archive</summary>

* **Навіщо і коли:** Коли сервер неочікувано перезавантажився або впав у Kernel Panic в минулому, і потрібно знайти унікальний ID тієї сесії для аналізу логів.
* **Що робить:** Виводить хронологічний список усіх зафіксованих циклів увімкнення/вимкнення цього сервера, які збереглися на диску.
* **Що побачимо:** Таблицю з індексами (наприклад, `0` — поточна сесія, `-1` — попередня сесія, `-2` — подекуди минула) та точними мітками дати й часу.
* **Short Description:** *Compiles and lists historical operating system boot logs sessions saved within persistent journal storage layers.*
</details>

<details>
<summary><b>sudo journalctl -b 0 / -b -1</b> — Filter Logs by Boot Session</summary>

* **Навіщо і коли:** Ізоляція логів від зайвого сміття. Читання повідомлень суворо за поточний аптайм або за минулий (до того, як сервер ребутнули).
* **Що робить:** Обрізає вивід логу, показуючи повідомлення лише обраної сесії за її індексом.
* **Що побачимо:** Чистий потік системних повідомлень, що починається з моменту ініціалізації ядра обраного завантаження.
* **Short Description:** *Queries the journal database filtering entries strictly bounded by custom boot lifecycle generation indexes.*
</details>

<details>
<summary><b>sudo journalctl -u dbus.service --follow</b> — Real-time Service Log Stream</summary>

* **Навіщо і коли:** Активний дебаг та моніторинг конкретного сервісу під час проведення тестів чи виправлення конфігів у реальному часі.
* **Що робить:** Фільтрує записи виключно по одному вказаному юніту (`-u`) та тримає термінал відкритим, миттєво дописуючи нові рядки подій (`--follow`).
* **Що побачимо:** Живий оновлюваний текст логів обраної служби.
* **Short Description:** *Initiates active output tracking for a target unit daemon stream, appending incoming records live.*
</details>

<details>
<summary><b>sudo journalctl --since=-5m / --since="2026-05-28 12:00" --until now</b> — Time-Window Filtering</summary>

* **Навіщо і коли:** Коли відомо точний час аварії сервісу, і потрібно відсікти мільйони попередніх рядків логів.
* **Що робить:** Обмежеє пошукову видачу повідомлень суворо в межах заданого таймфрейму (відносного, наприклад, останні 5 хвилин, або абсолютного за датою).
* **Що побачимо:** Логи подій, які відбулися суворо у зазначений проміжок часу.
* **Short Description:** *Executes advanced query parsing to return system events matched strictly against custom time window boundaries.*
</details>

<details>
<summary><b>sudo journalctl _UID=1001 / _SYSTEMD_CGROUP=...</b> — Internal Metadata Filtering</summary>

* **Навіщо і коли:** Розслідування інцидентів безпеки або глибокий дебаг, коли треба побачити лог дій конкретного користувача (за його UID) або процесів у конкретній cgroup.
* **Що робить:** Здійснює вибірку логів за внутрішніми системними прапорами-метаданими Linux.
* **Що побачимо:** Тільки ті записи, які були згенеровані процесами з відповідними низькорівневими атрибутами.
* **Short Description:** *Audits internal journal metadata fields, returning entries isolated by verified system owner identity or execution cgroup scope paths.*
</details>

<details>
<summary><b>journalctl -x</b> — Log Catalog Explanations</summary>

* **Навіщо і коли:** Коли сервіс видає незрозумілу коротку помилку старт-ап коду, і потрібна розшифровка, що саме пішло не так.
* **Що робить:** Додає до стандартних повідомлень про помилки розлогі пояснювальні довідки із вбудованої бази значень systemd (Catalog).
* **Що побачимо:** Додаткові блоки тексту під помилками з аналізом причин та посиланнями на документацію.
* **Short Description:** *Augments logged system failure notices with descriptive structural metadata articles extracted from the text catalog database.*
</details>

<details>
<summary><b>journalctl --disk-usage</b> — Audit Log Storage Footprint</summary>

* **Навіщо і коли:** Перевірка вільного місця на сервері, оцінка того, наскільки сильно розрослися файли журналів journald.
* **Що робить:** Опитує дискову підсистему та видає сумарний фізичний розмір усіх бінарних логів у системі.
* **Що побачимо:** Один інформаційний рядок виду: `Archived and active journals take up 420.0M in the file system.`
* **Short Description:** *Measures and prints total physical space consumed by active and archived journal data allocations across storage mounts.*
</details>

<details>
<summary><b>sudo journalctl --vacuum-size=500M</b> — Manual Log Space Retention Cleanup</summary>

* **Навіщо і коли:** Коли диски забиті логами, і потрібно терміново звільнити гігабайти простору, видаливши старе сміття, але зберігши найсвіжіші записи.
* **Що робить:** Послідовно видаляє найстаріші файли журналів, доки сумарний об'єм логів на диску не зменшиться до чітко вказаного ліміту (наприклад, 500 МБ).
* **Що побачимо:** Звіт про те, скільки файлів логів було видалено та скільки місця звільнено.
* **Short Description:** *Triggers immediate physical data retention maintenance routines, purging oldest files down to a specific storage quota limit.*
</details>

---

## 🚨 9. Resource Stress Monitoring (cgroups & PSI)

<details>
<summary><b>systemd-cgtop</b> — Real-time CGroup Resource Monitor</summary>

* **Навіщо і коли:** Сервер раптово почав гальмувати, і звичайний `top` показує купу PID, але не дає зрозуміти, яка саме група служб, зріз чи контейнер утилізує ресурси.
* **Що робить:** Інтерактивний монітор, який агрегує та сортує споживання CPU, Memory та I/O не за процесами, а за контрольними групами (cgroups).
* **Що побачимо:** Живу таблицю, де видно відсоток навантаження окремо по слайсах (`system.slice`, `user.slice`) та кожній конкретній службі.
* **Short Description:** *Provides a real-time interactive performance monitor mapping operational metrics directly to cgroup tree structures.*
</details>

<details>
<summary><b>cat /proc/pressure/memory</b> — Check Memory Resource Starvation</summary>

* **Навіщо і коли:** Діагностика прихованих затримок та "свопінгу": чи вистачає системі оперативної пам'яті для поточних задач.
* **Що робить:** Виводить ядерні метрики PSI (Pressure Stall Information), що показують час простою процесів через очікування виділення сторінок пам'яті.
* **Що побачимо:** Метрики типів `some` та `full` із середнім значення за останні 10, 60 та 300 секунд. Якщо цифри вищі за нуль — система відчуває голод по пам'яті.
* **Short Description:** *Parses kernel PSI interface files to extract task execution stall ratios induced by memory subsystem resource saturation.*
</details>

<details>
<summary><b>cat /proc/pressure/io</b> — Check Storage Throughput Pressures</summary>

* **Навіщо і коли:** Коли є підозра, що повільний диск або забитий дисковий масив стає «вузьким горлышком» (bottleneck), що гальмує роботу софту.
* **Що робить:** Показує відсоток часу, протягом якого хоча б один процес (`some`) або взагалі всі готові до роботи процеси (`full`) стояли і нічого не робили, чекаючи на відповідь від дискових накопичувачів.
* **Що побачимо:** Статистику PSI затримок введення-виведення. Нулі означають повну свободу дискової підсистеми.
* **Short Description:** *Evaluates storage subsystem resource starvation levels using kernel PSI metrics to find disk throughput performance bottlenecks.*
</details>

<details>
<summary><b>oomctl</b> — Inspect Monitored CGroup Pressure Boundaries</summary>

* **Навіщо і коли:** Перевірка працездатності превентивного захисту системи. Контроль того, які сервіси зараз перебувають під наглядом розумного Userspace OOM Killer.
* **Що робить:** Опитує демона `systemd-oomd` та виводить дерево контрольованих груп із встановленими для них лімітами тиску на ресурси.
* **Що побачимо:** Список cgroups, поточні показники Memory Pressure та встановлені жорсткі ліміти (наприклад, скидання cgroup при перевищенні тиску у 80%).
* **Short Description:** *Executes tools logic to examine active systemd-oomd configurations and track monitored cgroup memory boundaries mappings.*
</details>
