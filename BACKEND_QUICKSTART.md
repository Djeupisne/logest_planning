# ⚡ Démarrage Rapide du Backend

## Option Ultra-Rapide avec Docker (5 minutes)

```bash
cd /workspace/backend

# 1. Copier la config
cp api/.env.example api/.env

# 2. Modifier le mot de passe dans .env (optionnel pour dev local)
nano api/.env

# 3. Lancer tout le stack
docker-compose up -d

# 4. Vérifier que ça tourne
docker-compose ps

# 5. Tester l'API
curl http://localhost:3000/api/missions
```

**Services démarrés:**
- 🐘 PostgreSQL+PostGIS : `localhost:5432`
- 🚀 API Node.js : `localhost:3000`
- 🔧 Adminer (UI DB) : `localhost:8081`

**Comptes de test créés automatiquement:**
| Email | Mot de passe | Rôle |
|-------|-------------|------|
| consultant1@logest.td | password123 | Consultant |
| planner1@logest.td | password123 | Planificateur |
| director1@logest.td | password123 | Directeur |

---

## Sans Docker (15 minutes)

### 1. Installer PostgreSQL

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib postgis

# macOS (avec Homebrew)
brew install postgresql postgis
```

### 2. Créer la base de données

```bash
sudo -u postgres psql

CREATE DATABASE logest_planning;
CREATE EXTENSION postgis;
\q
```

### 3. Importer le schéma

```bash
psql -U postgres -d logest_planning -f backend/scripts/migrate.sql
```

### 4. Installer et lancer le backend

```bash
cd backend/api

npm install

cp .env.example .env
# Éditer .env si besoin

npm start
```

### 5. Tester

```bash
# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"consultant1@logest.td","password":"password123"}'

# Récupérer missions (avec token)
curl http://localhost:3000/api/missions \
  -H "Authorization: Bearer VOTRE_TOKEN"
```

---

## Prochaines étapes

1. ✅ Backend fonctionnel en local
2. ➡️ Configurer Firebase (voir `FIREBASE_SETUP.md`)
3. ➡️ Mettre à jour l'app Flutter avec l'URL API
4. ➡️ Tester le pilote avec 5-10 consultants

---

## Dépannage

### Erreur: "database does not exist"
```bash
psql -U postgres -c "CREATE DATABASE logest_planning;"
psql -U postgres -d logest_planning -c "CREATE EXTENSION postgis;"
```

### Erreur: "port already in use"
```bash
# Trouver le process
lsof -i :3000

# Tuer le process
kill -9 <PID>
```

### Logs du backend
```bash
# Docker
docker-compose logs -f api

# Manuel
cd backend/api && npm start 2>&1 | tee logs.txt
```
