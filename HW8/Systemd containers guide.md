# Systemd Containers & Virtualization Guide

### 🏗️ 1. Provisioning & Image Management

<details>
<summary><b>sudo apt install systemd-container bridge-utils debootstrap -y</b> — Infrastructure Setup</summary>

* **Навіщо і коли:** Виконується один раз на основному хості перед початком роботи з ізольованими контейнерами, щоб розгорнути всі необхідні утиліти віртуалізації та збірки ОС.
* **Що робить:** Встановлює компоненти керування вбудованими контейнерами (`systemd-nspawn`, `machinectl`), утиліти для створення мережевих мостів та інструмент завантаження чистих дистрибутивів.
* **Що побачимо:** Стандартний лог пакетного менеджера `apt` про успішне скачування та розгортання пакетів.
* **Short Description:** *Installs `systemd-container` structures and leverages network utilities to prepare the host environment for container operating systems.*
</details>

<details>
<summary><b>sudo debootstrap --arch=amd64 noble /var/lib/machines/noble1</b> — Provision Clean OS RootFS</summary>

* **Навіщо і коли:** Коли потрібно створити абсолютно новий, чистий та ізольований контейнер Ubuntu 24.04 (Noble) з нуля без використання Docker чи LXC.
* **Що робить:** Скачує офіційні базові пакети операційної системи з репозиторію дзеркала і розгортає чисту кореневу файлову систему у системну директорію `/var/lib/machines/`.
* **Що побачимо:** Потоковий довгий лог скачування, перевірки та розпакування сотні базових утиліт (генерація файлової структури rootfs).
* **Short Description:** *Downloads and provisions a clean Ubuntu Noble rootfs deployment under the managed machines system directory.*
</details>

<details>
<summary><b>machinectl list-images</b> — Inspect Available OS Images</summary>

* **Навіщо і коли:** Щоб перевірити, які саме контейнери або завантажені образи систем зараз фізично присутні та доступні на диску хост-машини.
* **Що робить:** Опитує директорію зберігання образів контейнерів і виводить їх структурований список із метаданими.
* **Що побачимо:** Таблицю зі стовпчиками: NAME (ім'я контейнера), TYPE (subvolume/raw), RO (доступ лише на читання), USAGE (розмір на диску) та DATE.
* **Short Description:** *Queries the local system image repository via machinectl to verify physical disk allocation and storage types.*
</details>

---

### 🛠️ 2. Interactive Configuration & First Login

<details>
<summary><b>sudo systemd-nspawn -D /var/lib/machines/noble1 --machine noble1</b> — Interactive Container Shell</summary>

* **Навіщо і коли:** Для первинної ручної настройки контейнера (наприклад, встановлення локальних паролів, пакетів, створення користувачів) одразу після розгортання файлової системи rootfs.
* **Що робить:** Запускає ізольований простір імен (namespaces) для вказаної директорії, замінюючи корінь системи (chroot-like режим) та відкриваючи інтерактивну bash-сесію всередині.
* **Що побачимо:** Приглашення колірного вводу консолі, де ми знаходимося вже всередині контейнера з правами суперкористувача `root`.
> ⚠️ **КРИТИЧНО ВАЖЛИВО:** Першим ділом всередині контейнера введи команду `passwd`, щоб задати пароль суперкористувача. Без цього ти не зможеш надалі залогінитися у фоновий контейнер через текстову консоль авторизації!
> 
> **ЯК ВИЙТИ З КОНТЕЙНЕРА:** Щоб розірвати сесію nspawn та повернутися на хост, натисніть комбінацію клавіш **`Ctrl + ]` три рази поспіль**.
* **Short Description:** *Spawns an interactive chroot-isolated namespace layer inside the target directory using systemd-nspawn.*
</details>

<details>
<summary><b>sudo systemd-nspawn -D /var/lib/machines/noble1 --machine noble1 -b</b> — Test Boot Sequence</summary>

* **Навіщо і коли:** Для перевірки того, як контейнер поводиться при повноцінній емуляції старту віртуальної машини з ініціалізацією системних служб.
* **Що робить:** Запускає контейнер у режимі завантаження (флаг `-b`), передаючи керування внутрішньому процесу PID 1 (`systemd` всередині самого контейнера).
* **Що побачимо:** Повноцінний лог завантаження операційної системи Linux (зелені рядки `[ OK ]`), який завершиться стандартним запрошенням ввести логін та встановлений пароль (Login Prompt).
* **Short Description:** *Triggers a full guest init boot sequences (`-b`) inside the container sandbox to simulate bare-metal startup operational states.*
</details>

---

### 📊 3. Container Orchestration (machinectl)

<details>
<summary><b>sudo machinectl start noble1</b> — Start Container in Background</summary>

* **Навіщо і коли:** Постійний запуск контейнера у фоновому (автономному) режимі для безперебійної роботи його внутрішніх служб (веб-сервери, бази даних).
* **Що робить:** Запускає контейнер у фоні, автоматично пакуючи його в системну інфраструктурну службу хоста `systemd-nspawn@noble1.service`.
* **Що побачимо:** Команда виконується миттєво і без виводу тексту, повертаючи керування стандартному терміналу хост-машини.
* **Short Description:** *Orchestrates container background activation by registering the running machine state inside the initialization manager.*
</details>

<details>
<summary><b>machinectl status noble1</b> — View Container Status & Processes</summary>

* **Навіщо і коли:** Коли потрібно дізнатися час безперервної роботи контейнера (аптайм), його IP-адреси, навантаження та повний список процесів, запущенних всередині нього.
* **Що робить:** Запитує у системної служби `systemd-machined` детальні runtime-параметри живого працюючого контейнера.
* **Що побачимо:** Блок структурованої інформації: ім'я, статус (running), версія ОС, шлях до директорії, поточне використання оперативної пам'яті та дерево процесів (CGroup Tree).
* **Short Description:** *Requests real-time operational diagnostics and structural cgroup tree metadata for the targeted running container.*
</details>

<details>
<summary><b>systemctl status systemd-nspawn@noble1.service</b> — Inspect Unit Wrapper State</summary>

* **Навіщо і коли:** Коли контейнер не запускається через команду `machinectl`, і потрібно подивитися логи помилок самого процесу nspawn з боку хост-системи.
* **Що робить:** Показує стан шаблонного системного сервісу, який керує ізоляцією та параметрами запуску цього контейнера.
* **Що побачимо:** Стандартний вивід команди `systemctl status` з останніми логами journald, які пояснюють поведінку процесу nspawn.
* **Short Description:** *Audits the underlying template systemd service unit responsible for launching and supervising the nspawn environment.*
</details>

<details>
<summary><b>sudo machinectl login noble1</b> — Open Container Console Session</summary>

* **Навіщо і коли:** Безпечне та захищене підключення до консолі керування фоновим контейнером для проведення адміністрування.
* **Що робить:** Відкриває через системну шину D-Bus захищений термінальний віртуальний TTY-канал зв'язку з текстовим запрошенням введення гостьової ОС.
* **Що побачимо:** Рядок вигляду `noble1 login:`. Після введення імені `root` та пароля (який ми задали раніше) ти отримуєш повноцінний шелл. Вихід із сесії — команда `exit`.
* **Short Description:** *Establishes a virtual TTY loopback terminal connection to request authenticated guest console access.*
</details>

---

### ⚙️ 4. Permanent Services, Tuning & Custom Limits

<details>
<summary><b>sudo systemctl edit --full --force noble1.service</b> — Create Permanent Container Unit</summary>

* **Навіщо і коли:** Щоб перетворити контейнер на постійну службу, яка автоматично стартує при включенні сервера, має чіткі ліміти ресурсів та кастомну мережеву конфігурацію.
* **Що робить:** Створює новий незалежний файл конфігурації системного юніта в папці `/etc/systemd/system/` та відкриває текстовий редактор.
* **Що побачимо:** Екран редактора конфігурацій, куди ми вставляємо фінальні параметри (ліміти файлів, параметри віртуальної мережі):
```ini
[Unit]
Description=My Production Ubuntu Container
After=network.target

[Service]
LimitNOFILE=100000
ExecStart=/usr/bin/systemd-nspawn --machine=noble1 --directory=/var/lib/machines/noble1/ -b --network-ipvlan=eth0
Restart=always

[Install]
Also=dbus.service
WantedBy=multi-user.target