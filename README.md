# Samsung Galaxy A15 4G Kernel Source (`SM-A155F`)

Dieses Repository enthält die modifizierten Kernelquellen für das **Samsung Galaxy A15 4G**  
(Modell: **SM-A155F**), basierend auf dem Android 5.10 Kernel aus dem offiziellen Samsung Open Source Release A155FXXS5BYC1.

---

## ✨ Ziel des Projekts

Ich arbeite daran, den Samsung-Kernel so zu erweitern, dass er Root durch folgende Features unterstützt:

- **[KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next/releases)**  
  → Ein Fork von KernelSU mit zusätzlichen Fixes und weiterentwickelter Root-Unterstützung
- **[SusFS für KernelSU](https://gitlab.com/simonpunk/susfs4ksu/-/tree/gki-android12-5.10?ref_type=heads)**  
  → Virtuelles Dateisystem zur Kernelspace-Userspace-Interaktion, optimiert für KernelSU

---

## 🧱 Struktur

Der Samsung Kernelcode befindet sich nun im Unterordner `Kernel/` für mehr Übersichtlichkeit.

---

## 🙏 Acknowledgements

Ich möchte mich besonders bei den Entwicklern der folgenden Projekte bedanken:

- **[KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next/releases)**  
  → Vielen Dank für die großartige Arbeit an **KernelSU-Next** und die einfache Implementierungsmöglichkeit. Das hat die Integration dieses Features in diesem Kernel enorm vereinfacht.

- **[SusFS für KernelSU](https://gitlab.com/simonpunk/susfs4ksu/-/tree/gki-android12-5.10?ref_type=heads)**  
  → Ein riesiges Dankeschön an die Entwickler von **SusFS**, deren Arbeit es mir ermöglicht hat, **SusFS** einfach durch Patchdateien zu integrieren. Das hat den Implementierungsprozess sehr viel effizienter gemacht.

Ein großes Dankeschön geht an **[WildPlusKernel](https://github.com/WildPlusKernel/GKI_KernelSU_SUSFS)** –  
seine Arbeit an einem GKI-kompatiblen Kernel mit integriertem **KernelSU/-next/MKSU + SusFS** war eine wichtige Referenz für mich.  
Seiner GitHub Workflows waren grundlegend, um Verständnis für 5.10 Kernel zu erlangen.  
Danke für deinen Beitrag zur Open-Source-Kernel-Community!

---

## 📜 Lizenz

Dieses Projekt steht unter der **GNU General Public License Version 2 (GPLv2)**.  
Weitere Informationen findest du in der [LICENSE](./LICENSE)-Datei.

---

## 🧪 Projektstatus

Dieses Repository befindet sich in aktiver Entwicklung.  
Ziel ist es, einen **rootfähigen, stabilen und entwicklerfreundlichen Kernel für das Galaxy A15 4G** bereitzustellen.

Pull Requests, Vorschläge und Diskussionen sind herzlich willkommen!
