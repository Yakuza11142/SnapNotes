# SnapNotes

**SnapNotes** is a production-ready mobile study and capture application built with **Flutter (Dart)** and **native/local processing** to turn photographed notes, whiteboards, textbook pages, or typed study material into structured bullet summaries, active-recall flashcards, and audio recaps—built for fast execution, offline access, and lean mobile data usage.

---

## Core Capabilities

* **Camera & Gallery Capture + On-Device OCR:** Capture textbook pages, whiteboards, or handwritten sheets directly from the camera or device gallery and extract text locally using on-device optical character recognition (e.g., `google_mlkit_text_recognition` / `sprintocr`).
* **Instant Study Output Generation:** Convert raw extracted or typed text into:
  * Concise bullet-point summaries
  * Question-and-answer flashcards for rapid review
  * Audio readouts via Text-to-Speech (TTS) and voice capture via Speech-to-Text (`speech_to_text`)
* **Offline-First Local Storage:** Persist captured notes, summaries, and flashcards locally on the device so students can review material without re-downloading data on every session.
* **Data-Conscious & Low-Overhead Design:** Built to minimize unnecessary network round-trips, cache generated study sets locally, and run smoothly across everyday Android devices.

---

## Project Architecture

```text
snapnotes/
├── android/                  # Android platform runner, permissions & Gradle release config
├── ios/                      # iOS platform runner & Info.plist usage descriptions
├── lib/
│   ├── main.dart             # Application entry point & theme initialization
│   ├── models/               # Note, flashcard, and summary data structures + serialization
│   ├── services/             # Camera/image pickers, OCR extraction, TTS/STT & local storage
│   ├── controllers/          # State management & study session flow
│   └── screens/              # Capture/home view, study sheet view & flashcard review view
├── test/                     # Unit and widget verification tests
├── pubspec.yaml              # Dart/Flutter dependencies & asset declarations
└── README.md
