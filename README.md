# 🤖 AI Assistant Mobile App (Flutter)

An intelligent AI-powered mobile assistant application built using **Flutter**, designed to provide real-time conversational support through API integration. The app enables users to interact with an AI system via a clean chat interface while ensuring secure access using Firebase Authentication.

---

## 📱 Overview

This application acts as a **personal AI assistant**, allowing users to ask questions, get instant responses, and interact naturally using a chat-based interface. It combines modern mobile development with AI services to deliver a smooth and responsive user experience.

---

## 🚀 Key Features

* 💬 **Real-Time Chat Interface**
  Interactive chat UI with user and AI message bubbles

* 🤖 **AI Integration (API-Based)**
  Sends user queries to an external AI API and displays intelligent responses

* 🔐 **Firebase Authentication**
  Secure login and registration system

* ⚡ **State Management (Provider)**
  Efficient handling of chat messages and UI updates

* 🎨 **Modern UI Design**
  Clean, responsive, and user-friendly interface

---

## 🛠️ Technologies Used

* **Flutter** – UI framework for cross-platform development
* **Dart** – Programming language
* **Provider** – State management
* **REST API** – AI communication
* **HTTP Package** – API requests
* **Firebase Authentication** – User management

---

## 🏗️ System Architecture

The application follows a **layered architecture**:

* 📱 **Presentation Layer** → Screens & Widgets
* 🧠 **State Management Layer** → Provider
* 🔌 **Service Layer** → API Service
* 📦 **Data Layer** → Models

---

## 🔄 API Flow

User Input → Chat Provider → API Service → AI API → Response → UI Update

---

## 📂 Project Structure

```
lib/
 ├── screens/        # UI screens (Login, Chat, Home)
 ├── widgets/        # Reusable UI components
 ├── providers/      # State management (Provider)
 ├── services/       # API integration
 ├── models/         # Data models
```

---

## 🔧 Setup Instructions

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/your-username/ai-assistant-app.git
cd ai-assistant-app
```

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

### 3️⃣ Firebase Setup

* Create a Firebase project
* Download `google-services.json`
* Place it inside:

  ```
  android/app/
  ```

### 4️⃣ Run the Application

```bash
flutter run
```

---

## 📸 Screenshots (Add your images here)

* Login Screen
* Register Screen
* Chat Interface
* Home Screen

---

## 🎯 Use Case

This app is designed to:

* Provide instant AI-based assistance
* Improve user productivity
* Demonstrate integration of AI in mobile apps

---

## 🔮 Future Enhancements

* 🎤 Voice Input Integration
* 🌐 Multi-language Support
* 💾 Chat History Storage
* 🧠 Personalized AI Responses
* 🌙 Dark/Light Mode Toggle

---

## 👩‍💻 Author

**Divya Basana**
B.Tech - Computer Science & Information Technology

---

## ⭐ Acknowledgements

* Flutter SDK by Google
* Firebase Services
* AI API Provider

---

## 📌 License

This project is developed for educational and academic purposes.
