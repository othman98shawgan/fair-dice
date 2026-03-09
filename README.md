# FairDice 🎲

A mathematically proven, physics-driven dice roller built with Flutter. 

Most dice apps are fundamentally flawed for tabletop gaming. They rely on raw `math.Random()`, which mathematically allows for streaks of identical numbers that human psychology perceives as "broken" or "rigged." 

FairDice solves this using a custom **Permutation Bag Engine**, ensuring perfect statistical distribution while maintaining a premium, tactile user experience.

## 🧠 The Architecture

### 1. The FairDiceEngine (Permutation Bag)
Instead of rolling a random number every time, the engine calculates every possible permutation for the selected number of dice (e.g., 36 permutations for 2 dice). These permutations are shuffled into a "bag." 
* A roll pulls a result from the bag.
* Once the bag is empty, a new perfect set is generated and shuffled.
* **The Result:** Guaranteed perfect distribution. You will never roll five 12s in a row.

### 2. Real-Time Visual Proof (`fl_chart`)
Users don't trust algorithms they can't see. The app features a dedicated real-time statistics dashboard that ingests the engine's ledger and renders a live bar chart. As the user rolls, they watch the data physically form a flawless bell curve, proving the algorithm's integrity.

### 3. Hardware-Level Haptics (`vibration`)
Standard UI vibrations feel cheap. FairDice bypasses standard UI haptics to communicate directly with the device's linear actuator.
* **The Tumble:** A carefully sequenced `for` loop of 50ms micro-bursts synced to a custom deceleration easing curve.
* **The Slam:** A heavy 100ms, 128-amplitude physical impact when the final result locks in.

### 4. Floating Glassmorphism UI
* Completely custom floating pill navigation (`google_nav_bar`) utilizing `extendBody` for a seamless glassmorphism effect.
* Responsive scaling canvas that adapts to any screen size without clipping.
* Fully persistent user preferences (Theme, Dice Count, Haptics) via `shared_preferences`.

## 🛠 Tech Stack
* **Framework:** Flutter / Dart
* **State Management:** Native `ValueNotifier` & `setState` (Zero-bloat architecture)
* **Data Visualization:** `fl_chart`
* **Local Storage:** `shared_preferences`
* **Hardware:** `vibration` (Direct motor amplitude control)

## 🚀 Getting Started

To compile this project, you need the Flutter SDK installed.

1. Clone the repository:
   ```bash
   git clone https://github.com/othman98shawgan/fair-dice.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

   Note: Android requires <uses-permission android:name="android.permission.VIBRATE"/> in the manifest for the custom physics engine to fire.
