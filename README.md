# 🦷 Clinic-Dentist Substitute App

A Flutter + Firebase mobile application that connects **clinics** with **dentists** for temporary or part-time engagements.
This project was built as part of my MCA coursework and serves as a **basic working model (MVP)**.

---

## 🚀 Features

### 🔑 Authentication

* Role-based signup & login (Clinic / Dentist / Admin)
* Firebase Authentication integration

### 🏥 Clinic Side

* Post job openings (department, date, experience required)
* View & manage own postings
* Accept / reject dentist requests for openings
* Engagement history with accepted dentists

### 🦷 Dentist Side

* View available clinic openings
* Send requests to clinics
* Chat with clinics (real-time chat)
* View accepted work engagements

### 🛠 Admin Side

* Approve/reject new users
* Monitor clinics and dentists
* Manage posted openings

### 💬 Chat

* One-to-one chat between clinic and dentist
* Real-time messages stored in Firestore

---

## 🗂 Firestore Collections

* **users** → stores user profiles (role, name, email, etc.)
* **clinic_posts** → clinic job postings (open/closed, details, assigned dentist)
* **requests** → requests from dentists to clinics (pending/accepted/rejected)
* **chats** → unique chatrooms with subcollection `messages`

---

## 🛠 Tech Stack

* **Frontend** → Flutter (Dart)
* **Backend** → Firebase (Authentication, Firestore, Storage)
* **Other** → StreamBuilder for real-time UI updates

---

## ▶️ Running the App

1. Clone this repo:

   ```bash
   git clone https://github.com/muhammedfariz2002-maker/SUBDENT.git
   cd SUBDENT
   ```

2. Get packages:

   ```bash
   flutter pub get
   ```

3. **connect to firebase**:

  I used firebase CLI to connect with firebase, please refer youtube video for the same, it's much easier than manually doing the process

4. Run the app:

   ```bash
   flutter run
   ```

---

