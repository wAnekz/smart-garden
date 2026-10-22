# Smart Garden (JasylJer)

A prototype system that automates watering of the green areas at Specialized Lyceum No. 165 (Almaty, Kazakhstan). Built for the national "Taza Kazakhstan" eco-initiative.

Soil-moisture sensors connected to an ESP32 report how dry the soil is. A Flutter app shows the data and lets the caretaker start watering remotely.

## What the app does

- Live dashboard of sensor readings and the weather
- Watering modes and schedules that skip watering when rain is forecast
- Digital map of the school's planting zones
- History of sensor readings
- AI agronomist chat (Llama 3.3 via the Groq API) that gives plant-care advice based on the current sensor readings
- Email sign-up and sign-in (Firebase Auth)

## Stack

Flutter (Dart), Firebase, Groq API (Llama 3.3), ESP32 + soil-moisture sensors.

## Status

Prototype, work in progress. I had never worked with microcontrollers before this project and learned the hardware side while building it.

## Run it

The Flutter project lives in `Academix/` (the app grew out of my earlier Flutter project of that name).

```bash
cd Academix
cp lib/secrets.example.dart lib/secrets.dart   # then paste your Groq API key
flutter pub get
flutter run
```

Author: Dilan Abkanov
