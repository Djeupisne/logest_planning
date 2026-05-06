# Backend API - LOGEST Planning

## Architecture du Backend

Ce dossier contient l'implémentation du backend API REST pour l'application LOGEST Planning.

### Stack Technique Recommandée

**Option 1: Node.js + Express (Recommandé)**
- Framework: Express.js ou NestJS
- Base de données: PostgreSQL
- Authentification: JWT + bcrypt
- Validation: Joi ou Zod

**Option 2: Python + FastAPI**
- Framework: FastAPI
- Base de données: PostgreSQL avec SQLAlchemy
- Authentification: JWT + passlib
- Validation: Pydantic

**Option 3: PHP + Laravel**
- Framework: Laravel
- Base de données: MySQL/PostgreSQL
- Authentification: Sanctum/JWT
- Validation: Built-in

### Structure des Fichiers

```
backend/
├── api/                    # Code source de l'API
│   ├── src/
│   │   ├── controllers/    # Gestion des requêtes HTTP
│   │   ├── models/         # Modèles de données
│   │   ├── routes/         # Définition des endpoints
│   │   ├── middleware/     # Auth, validation, logging
│   │   ├── services/       # Logique métier
│   │   └── utils/          # Helpers, encryption
│   ├── tests/              # Tests unitaires et d'intégration
│   └── config/             # Configuration DB, JWT, etc.
├── scripts/                # Scripts de déploiement et migration
├── docker-compose.yml      # Conteneurisation
└── README.md               # Documentation API
```

### Endpoints API Requis

#### Authentification
- `POST /api/auth/login` - Connexion utilisateur
- `POST /api/auth/logout` - Déconnexion
- `POST /api/auth/refresh` - Rafraîchir token JWT
- `POST /api/auth/forgot-password` - Réinitialisation mot de passe

#### Utilisateurs
- `GET /api/users/profile` - Profil utilisateur connecté
- `PUT /api/users/profile` - Mise à jour profil
- `GET /api/users/:id` - Détails utilisateur (admin)
- `PUT /api/users/:id` - Modification utilisateur (admin)

#### Missions
- `GET /api/missions` - Liste des missions (filtrable)
- `GET /api/missions/:id` - Détails mission
- `POST /api/missions` - Créer mission (planificateur)
- `PUT /api/missions/:id` - Modifier mission
- `DELETE /api/missions/:id` - Supprimer mission
- `PATCH /api/missions/:id/status` - Mettre à jour statut
- `GET /api/missions/consultant/:id` - Missions d'un consultant
- `GET /api/missions/daily/:date` - Missions du jour

#### Consultants
- `GET /api/consultants` - Liste consultants
- `GET /api/consultants/:id` - Détails consultant
- `GET /api/consultants/:id/location` - Position GPS (temps réel)
- `GET /api/consultants/available` - Consultants disponibles
- `PUT /api/consultants/:id/skills` - Gérer compétences

#### Planning
- `GET /api/planning/weekly` - Planning hebdomadaire
- `GET /api/planning/consultant/:id` - Planning par consultant
- `POST /api/planning/assign` - Assigner mission
- `DELETE /api/planning/assign/:id` - Désassigner mission

#### Rapports & Incidents
- `GET /api/reports` - Liste rapports
- `GET /api/reports/:id` - Détails rapport
- `POST /api/reports` - Créer rapport (consultant)
- `POST /api/incidents` - Signaler incident
- `GET /api/incidents` - Liste incidents

#### Direction / Reporting
- `GET /api/analytics/usage` - Taux utilisation consultants
- `GET /api/analytics/comparison` - Estimé vs Réel
- `GET /api/analytics/kpis` - KPIs globaux
- `GET /api/analytics/export` - Export données (CSV/PDF)

#### Synchronisation
- `POST /api/sync/push` - Envoyer données offline
- `GET /api/sync/pull` - Récupérer données mises à jour
- `GET /api/sync/status` - Statut synchronisation

### Modèle de Données (PostgreSQL)

```sql
-- Utilisateurs
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('consultant', 'planner', 'director')),
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Consultants (extension de users)
CREATE TABLE consultants (
    user_id UUID PRIMARY KEY REFERENCES users(id),
    skills JSONB, -- ['audit', 'formation', 'conseil']
    is_available BOOLEAN DEFAULT true,
    current_location GEOGRAPHY(POINT),
    last_location_update TIMESTAMP,
    consent_tracking BOOLEAN DEFAULT false
);

-- Clients
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Missions
CREATE TABLE missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    client_id UUID REFERENCES clients(id),
    consultant_id UUID REFERENCES consultants(user_id),
    planner_id UUID REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'planned' CHECK (status IN ('planned', 'en_route', 'arrived', 'in_progress', 'completed', 'problem', 'cancelled')),
    scheduled_start TIMESTAMP NOT NULL,
    scheduled_end TIMESTAMP NOT NULL,
    actual_start TIMESTAMP,
    actual_end TIMESTAMP,
    estimated_duration INTEGER, -- en minutes
    actual_duration INTEGER,
    location_address TEXT,
    location_latitude DECIMAL(10, 8),
    location_longitude DECIMAL(11, 8),
    priority VARCHAR(20) DEFAULT 'normal',
    type VARCHAR(50) DEFAULT 'mission' CHECK (type IN ('mission', 'inter_contract', 'leave', 'training')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Rapports d'intervention
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mission_id UUID REFERENCES missions(id),
    consultant_id UUID REFERENCES consultants(user_id),
    content TEXT NOT NULL,
    photos JSONB, -- URLs des photos
    client_signature TEXT, -- Signature numérique
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_billable BOOLEAN DEFAULT true
);

-- Incidents
CREATE TABLE incidents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mission_id UUID REFERENCES missions(id),
    consultant_id UUID REFERENCES consultants(user_id),
    type VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    severity VARCHAR(20) DEFAULT 'medium',
    photos JSONB,
    reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    resolution_notes TEXT
);

-- Synchronisation offline
CREATE TABLE sync_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    operation_type VARCHAR(50) NOT NULL,
    endpoint VARCHAR(255) NOT NULL,
    payload JSONB NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP
);

-- Index pour performances
CREATE INDEX idx_missions_consultant ON missions(consultant_id);
CREATE INDEX idx_missions_status ON missions(status);
CREATE INDEX idx_missions_date ON missions(scheduled_start);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_sync_queue_user ON sync_queue(user_id, status);
```

### Sécurité

1. **Authentification JWT**
   - Tokens avec expiration (15 min access, 7 days refresh)
   - Stockage sécurisé côté client (flutter_secure_storage)
   - Rotation des tokens

2. **Hashage Mots de Passe**
   - bcrypt avec salt rounds = 12
   - Jamais de mots de passe en clair

3. **HTTPS Obligatoire**
   - Certificat SSL/TLS
   - HSTS enabled

4. **Rate Limiting**
   - 100 req/min par utilisateur
   - Protection contre brute force

5. **Validation des Inputs**
   - Sanitization de toutes les entrées
   - Protection SQL injection
   - XSS prevention

### Exemple d'Implémentation (Node.js/Express)

Voir le fichier `backend/api/src/server.js` pour un exemple complet.

### Prochaines Étapes

1. Choisir la stack technique
2. Initialiser le projet backend
3. Implémenter l'authentification
4. Développer les endpoints CRUD
5. Configurer la base de données
6. Tester avec Postman/Insomnia
7. Déployer sur serveur (VPS, AWS, Heroku)
8. Configurer HTTPS
9. Connecter l'app Flutter au backend
