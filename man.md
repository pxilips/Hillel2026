# 🛠️ Systemd Diagnostic Cheat Sheet (Part 1)

> **Quick Navigation:** Click on any command below to expand its manual, use cases, and expected outputs.

---

### 📈 Boot Time & Process Analysis

<details>
<summary><b>1. ps xawf</b> — Process Tree Diagram</summary>

* **Why & When:** Use it to find stuck processes or understand system hierarchy.
* **What it does:** Displays a complete, visual tree of all active processes.
* **What you see:** A nested diagram showing that **`systemd` (PID 1)** is the root parent of everything.
</details>

<details>
<summary><b>2. systemd-analyze</b> — Boot Time Benchmark</summary>

* **Why & When:** Run it as a quick check after system changes to see if boot speed dropped.
* **What it does:** Measures the total time spent during the system startup.
* **What you see:** A single line breaking down time into: *Kernel* ➔ *Initrd* ➔ *Userspace*.
</details>

<details>
<summary><b>3. systemd-analyze blame</b> — Service Boot Times</summary>

* **Why & When:** Use it when the machine takes too long to show the login screen to find the slowest service.
* **What it does:** Lists all initialized services, sorted from slowest to fastest.
* **What you see:** A simple text list with time values (e.g., `5.2s networkd.service`) at the top.
</details>

<details>
<summary><b>4. systemd-analyze critical-chain</b> — Critical Boot Path</summary>

* **Why & When:** Use it when `blame` isn't enough. It shows *only* the services that actually delayed the final boot milestone.
* **What it does:** Builds a time-dependency tree of services that had to wait for one another.
* **What you see:** A tree structure with `@` timestamps highlighting the exact chain of bottlenecks.
</details>

---

### 📊 Visualizing Dependencies (Graphviz)

<details>
<summary><b>5. sudo apt install graphviz</b> — Graphic Engine Setup</summary>

* **Why & When:** Run this once before generating visual dependency charts.
* **What it does:** Installs tools (like `dot`) to convert structural text logs into clean vector graphics (`.svg`).
* **What you see:** Standard package manager installation logs.
</details>

<details>
<summary><b>6. systemd-analyze plot > bootup.svg</b> — Graphical Boot Timeline</summary>

* **Why & When:** Excellent for documentation, deep visual analysis, or presentation.
* **What it does:** Generates an interactive vector graphic timeline of the boot process.
* **What you see:** A colorful chart where the X-axis is time and the Y-axis lists when each service started and finished.
</details>

<details>
<summary><b>7. systemd-analyze dot ... | dot -Tsvg > targets.svg</b> — Target Flowchart</summary>

* **Why & When:** Use it to understand the core architectural stages of Linux boot milestones (Targets).
* **What it does:** Filters out thousands of separate services and maps relationships only between `.target` units.
* **What you see:** A clean flowchart with arrows showing the order of boot phases (e.g., *Basic* ➔ *Network* ➔ *Multi-user*).
</details>

---
