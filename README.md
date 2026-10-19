# Inside the Machine Mind

**An interactive Android app that takes you on a journey through how large language models (LLMs) are built: the hardware they live on, how they're trained, and how they answer.**

Your guide is **Bit**, a small robot, and you follow one question all the way through the machine: *"Why is the sky blue?"*

<!-- SCREENSHOTS -->

## The journey

| | Section | What you'll do |
|---|---|---|
| 1 | **Where the Mind Lives** (hardware) | Race a hard drive against NVMe SSDs, stream model weights through different kinds of memory, fill in a matrix multiplication yourself, watch CPU "chefs" race a GPU "army", then zoom out to a 100,000-GPU datacenter and build your own: power, cooling, water. |
| 2 | **How the Mind Grew** (training) | Translate engineer-speak into plain English, see where the data comes from and how it's cleaned, play the tokenizer merge game, **train a real tiny neural network on your phone**, roll a ball down a loss landscape, follow one training step through the hardware, and see why bigger models get smarter, and how small ones are made. |
| 3 | **The Mind Answers** (inference) | Watch your question turn into tokens and coordinates, step through **a toy transformer with real numbers** until it says "blue", play with temperature, find out what runs at home (gaming PCs, Macs, DGX Spark), zoom into a frontier model, then travel from AlphaGo to robots, AlphaFold and coding agents. |

Every engineering term comes with an everyday translation: *parameters* are **knobs**, *loss* is a **wrongness score**, the *KV cache* is **notes so it doesn't re-read**. There are 77 terms in the built-in glossary.

**Facts you can check.** Every number in the app comes from a cited source (spec sheets, papers, official announcements), checked in October 2026. Tap ⓘ on any fact card, or open *Sources* on the home screen.

**Also inside:** a quiz for each section, progress tracking, light and dark themes, reduce-motion support, "Bit reads aloud" (your phone's own voice), phone and tablet layouts, and two secrets hidden on the home screen. 🥚

## Install

Download the APK from the [latest release](https://github.com/levoniust/inside-the-machine-mind/releases/latest) and open it on your Android phone (Android 7.0+). You may need to allow installing apps from your browser. The app is fully offline: no internet, no accounts, no tracking.

## Build it yourself

```bash
flutter pub get
flutter test                    # unit + widget tests (every lesson renders cleanly in dark/light at large text)
flutter build apk --release     # without android/key.properties the release build is signed with the debug key
```
Integration test of the full journey on a device or emulator: `flutter test integration_test/journey_test.dart -d <device>`.

## How this app was made

This app was built as an experiment (and a stress test of a homelab): a team of AI models, mostly running locally, designed, wrote, tested and illustrated it in one long overnight session.

- **Claude (Opus 5.5)** orchestrated: planned, wrote the trickiest screens, fact-checked every number, and reviewed everything.
- **Qwen3.8-Flash-Next** (2× RTX 3090) worked as a coding agent.
- **Mirai, a Qwen3.8-27B model** (RTX 5060 Ti), drafted the script, quizzes and research notes, and coded screens.
- **Qwen-Image 2.1** (RTX 3060) painted the hidden gallery.

Find the secret logbook in the app for the details.

## Credits & licenses

- Code: MIT, see [LICENSE](LICENSE).
- Gallery images: generated with Qwen-Image 2.1 ([Qwen Research License](https://huggingface.co/Qwen), non-commercial).
- Facts: see the in-app Sources page (69 sources).
- Built with [Flutter](https://flutter.dev).
