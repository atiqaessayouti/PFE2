# Application mobile – Gestion de maintenance de véhicules 🚗🛠️

## Description  
Cette application mobile, développée avec **Flutter** et **Firebase**, vise à faciliter la gestion de la maintenance des véhicules. Elle permet aux utilisateurs (administrateurs, clients ou garagistes) de suivre l’état des véhicules, planifier les entretiens et garder un historique clair des opérations.  

Le projet offre une interface intuitive et un système de rôles pour garantir une gestion sécurisée et adaptée aux différents profils d’utilisateurs.

## Fonctionnalités principales  
- ✅ Gestion des véhicules : ajout, modification, suppression  
- ✅ Authentification sécurisée via Firebase Authentication  
- ✅ Stockage et synchronisation des données en temps réel via Firestore  
- ✅ Système de rôles utilisateur : Admin / Client / Garagiste  
- ✅ Suivi des opérations de maintenance : historique, dates, détails  
- ✅ Notifications pour rappels d’entretien  
- ✅ Interface multiplateforme (Android / iOS / Web) grâce à Flutter  

## Technologies utilisées  
- **Dart & Flutter** — pour le développement mobile multiplateforme  
- **Firebase Firestore** — base de données cloud en temps réel  
- **Firebase Authentication** — gestion sécurisée des utilisateurs  
- **Git / GitHub** — gestion du versionning de code
- ## 📊 Diagrammes UML

### 🔹 Diagramme de cas d'utilisation (Use Case)

Ce diagramme représente les interactions entre les différents acteurs (Admin, Client, Garagiste) et le système.

<img width="533" height="323" alt="Capture d’écran 2026-04-13 110918" src="https://github.com/user-attachments/assets/171e7683-5e56-4361-b864-22ec90d0ce13" />


---

### 🔹 Diagramme de classes

Ce diagramme illustre la structure du système, incluant les classes principales comme User, Vehicule, Maintenance, et leurs relations.

<img width="533" height="323" alt="Capture d’écran 2026-04-13 110918" src="https://github.com/user-attachments/assets/90ee7eb7-58de-4903-995d-b2620bc6a318" />
## 🎥 Vidéo de démonstration

Vous pouvez télécharger ou visionner la vidéo de démonstration ici :  


https://github.com/user-attachments/assets/fa9bbab7-4a5a-4d84-8f86-a3089225f996


## Installation & Lancement (pour développement)  

```bash
# 1. Cloner le dépôt
git clone https://github.com/atiqaessayouti/PFE2.git

# 2. Naviguer dans le dossier du projet
cd PFE2


# 3. Installer les dépendances Flutter
flutter pub get

# 4. Configurer Firebase 
#    - Crée ton projet Firebase
#    - Ajoute les fichiers de configuration (google-services.json / GoogleService-Info.plist)
#    - Active Authentication + Firestore



# 5. Lancer l’app
flutter run
