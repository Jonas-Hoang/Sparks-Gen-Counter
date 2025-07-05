<p align="center">
  <img src="Sparks Gen Counter/Logo/app-icon.png" width="180" alt="Sparks Gen Counter Icon" />
</p>

<h1 align="center">Sparks Gen Counter</h1>

<p align="center">
  🎮 A strategic macOS utility to calculate SPARK gains over time and counter every opponent effectively.
</p>

---

## 📘 About

**Sparks Gen Counter** is a macOS app designed to help players manage SPARK generation logic in tick-based matches. It assists players in tracking SPARK progression over time based on opponent types, boost conditions, and tick phases.

---

## ⚙️ Features

- 🔢 Central SPARK counter starting at 6 (or based on opponent)
- ⏱ Tick system:
  - **Normal phase**: 16 ticks, 8 seconds each
  - **Fast phase**: after 16 ticks, ticks become 6 seconds
- 🎯 Opponent-based starting/limit SPARK values:
  - **Meren**: Start 5, Max 5
  - **Dravos**: Start 6, Max 8
  - **CFK (Chira Frio + Karshar)**: Start 6, Max 12
  - **Default**: Start 6, Max 10
- ⚡ SPARK gain per tick:
  - Normal: +2 SPARK
  - After activating **Spark Gen**, gain is boosted:
    - 1 Spark Gen → +3 per tick (5 ticks)
    - 2 Spark Gen → +4 per tick (5 ticks)
    - 3 Spark Gen → +5 per tick (5 ticks)
- 💚 Health system: using Spark Gen costs 1 HP (start at 5)
- ⏹ All buttons auto-disable when SPARK is insufficient
- 🛑 Stop button resets all counters

---

## 🖥️ Platform

- macOS (Swift + SwiftUI)

---

## 📦 Installation

1. Clone the repo:
   ```bash
   git clone https://github.com/Jonas-Hoang/Sparks-Gen-Counter.git
