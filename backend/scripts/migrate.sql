-- Script de migration de la base de données PostgreSQL
-- LOGEST Planning - Schéma complet

-- Extension pour les types géographiques (PostGIS)
CREATE EXTENSION IF NOT EXISTS postgis;

-- Supprimer les tables si elles existent (pour reset)
DROP TABLE IF EXISTS sync_queue CASCADE;
DROP TABLE IF EXISTS incidents CASCADE;
DROP TABLE IF EXISTS reports CASCADE;
DROP TABLE IF EXISTS missions CASCADE;
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS consultants CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ==================== UTILISATEURS ====================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('consultant', 'planner', 'director')),
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    refresh_token TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour performances
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(is_active);

-- ==================== CONSULTANTS (extension de users) ====================
CREATE TABLE consultants (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    skills JSONB DEFAULT '[]'::jsonb, -- ['audit', 'formation', 'conseil']
    is_available BOOLEAN DEFAULT true,
    current_location GEOGRAPHY(POINT),
    last_location_update TIMESTAMP,
    consent_tracking BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_consultants_available ON consultants(is_available);
CREATE INDEX idx_consultants_consent ON consultants(consent_tracking);

-- ==================== CLIENTS ====================
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_clients_name ON clients(name);

-- ==================== MISSIONS ====================
CREATE TABLE missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    consultant_id UUID REFERENCES consultants(user_id) ON DELETE SET NULL,
    planner_id UUID REFERENCES users(id) ON DELETE SET NULL,
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
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    type VARCHAR(50) DEFAULT 'mission' CHECK (type IN ('mission', 'inter_contract', 'leave', 'training')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour performances
CREATE INDEX idx_missions_consultant ON missions(consultant_id);
CREATE INDEX idx_missions_status ON missions(status);
CREATE INDEX idx_missions_date ON missions(scheduled_start);
CREATE INDEX idx_missions_type ON missions(type);
CREATE INDEX idx_missions_planner ON missions(planner_id);

-- ==================== RAPPORTS D'INTERVENTION ====================
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mission_id UUID REFERENCES missions(id) ON DELETE CASCADE,
    consultant_id UUID REFERENCES consultants(user_id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    photos JSONB DEFAULT '[]'::jsonb, -- URLs des photos
    client_signature TEXT, -- Signature numérique (base64 ou URL)
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_billable BOOLEAN DEFAULT true
);

CREATE INDEX idx_reports_mission ON reports(mission_id);
CREATE INDEX idx_reports_consultant ON reports(consultant_id);
CREATE INDEX idx_reports_submitted ON reports(submitted_at);

-- ==================== INCIDENTS ====================
CREATE TABLE incidents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mission_id UUID REFERENCES missions(id) ON DELETE CASCADE,
    consultant_id UUID REFERENCES consultants(user_id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    severity VARCHAR(20) DEFAULT 'medium' CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    photos JSONB DEFAULT '[]'::jsonb,
    reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    resolution_notes TEXT
);

CREATE INDEX idx_incidents_mission ON incidents(mission_id);
CREATE INDEX idx_incidents_consultant ON incidents(consultant_id);
CREATE INDEX idx_incidents_severity ON incidents(severity);

-- ==================== SYNCHRONISATION OFFLINE ====================
CREATE TABLE sync_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    operation_type VARCHAR(50) NOT NULL,
    endpoint VARCHAR(255) NOT NULL,
    payload JSONB NOT NULL,
    params JSONB DEFAULT '{}'::jsonb,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP,
    retry_count INTEGER DEFAULT 0
);

CREATE INDEX idx_sync_queue_user ON sync_queue(user_id, status);
CREATE INDEX idx_sync_queue_status ON sync_queue(status);
CREATE INDEX idx_sync_queue_created ON sync_queue(created_at);

-- ==================== DONNÉES DE TEST ====================

-- Utilisateurs (mot de passe: password123 hashé avec bcrypt)
INSERT INTO users (email, password_hash, full_name, role, phone) VALUES
('consultant1@logest.td', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYzS3MebAJu', 'Ahmat Mahamat', 'consultant', '+235 66 12 34 56'),
('consultant2@logest.td', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYzS3MebAJu', 'Fatime Abderaman', 'consultant', '+235 65 23 45 67'),
('planner1@logest.td', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYzS3MebAJu', 'Jean-Marc Kebre', 'planner', '+235 64 34 56 78'),
('director1@logest.td', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYzS3MebAJu', 'Marie Nguema', 'director', '+235 63 45 67 89');

-- Consultants
INSERT INTO consultants (user_id, skills, is_available, consent_tracking) VALUES
((SELECT id FROM users WHERE email = 'consultant1@logest.td'), '["audit", "conseil"]'::jsonb, true, true),
((SELECT id FROM users WHERE email = 'consultant2@logest.td'), '["formation", "conseil"]'::jsonb, true, true);

-- Clients
INSERT INTO clients (name, contact_name, phone, email, address, latitude, longitude) VALUES
('Société Générale Tchad', 'M. Ibrahim', '+235 66 00 00 01', 'contact@sg-tchad.com', 'Avenue Charles de Gaulle, N''Djamena', 12.1067, 15.0444),
('Ministère de l''Économie', 'Mme. Kadija', '+235 66 00 00 02', 'contact@economie.td', 'Place de la Nation, N''Djamena', 12.1100, 15.0500),
('Orange Tchad', 'M. Brahim', '+235 66 00 00 03', 'pro@orange.td', 'Rue du Commerce, N''Djamena', 12.1050, 15.0400);

-- Missions de test
INSERT INTO missions (title, description, client_id, consultant_id, planner_id, status, scheduled_start, scheduled_end, type, priority, location_address) VALUES
('Audit financier Q1', 'Audit des comptes du premier trimestre', 
 (SELECT id FROM clients WHERE name = 'Société Générale Tchad'),
 (SELECT user_id FROM consultants WHERE user_id = (SELECT id FROM users WHERE email = 'consultant1@logest.td')),
 (SELECT id FROM users WHERE email = 'planner1@logest.td'),
 'planned',
 NOW() + INTERVAL '1 day',
 NOW() + INTERVAL '1 day 4 hours',
 'mission',
 'high',
 'Avenue Charles de Gaulle, N''Djamena'),

('Formation équipe RH', 'Session de formation sur la gestion des talents',
 (SELECT id FROM clients WHERE name = 'Ministère de l''Économie'),
 (SELECT user_id FROM consultants WHERE user_id = (SELECT id FROM users WHERE email = 'consultant2@logest.td')),
 (SELECT id FROM users WHERE email = 'planner1@logest.td'),
 'planned',
 NOW() + INTERVAL '2 days',
 NOW() + INTERVAL '2 days 3 hours',
 'formation',
 'normal',
 'Place de la Nation, N''Djamena'),

('Conseil stratégique', 'Accompagnement transformation digitale',
 (SELECT id FROM clients WHERE name = 'Orange Tchad'),
 (SELECT user_id FROM consultants WHERE user_id = (SELECT id FROM users WHERE email = 'consultant1@logest.td')),
 (SELECT id FROM users WHERE email = 'planner1@logest.td'),
 'planned',
 NOW() + INTERVAL '3 days',
 NOW() + INTERVAL '3 days 5 hours',
 'mission',
 'normal',
 'Rue du Commerce, N''Djamena');

-- Trigger pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON clients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_missions_updated_at BEFORE UPDATE ON missions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE users IS 'Utilisateurs de l''application (consultants, planificateurs, direction)';
COMMENT ON TABLE consultants IS 'Profil étendu des consultants avec compétences et localisation';
COMMENT ON TABLE clients IS 'Clients de LOGEST pour lesquels les missions sont réalisées';
COMMENT ON TABLE missions IS 'Missions assignées aux consultants avec statuts et planning';
COMMENT ON TABLE reports IS 'Rapports d''intervention rédigés par les consultants';
COMMENT ON TABLE incidents IS 'Incidents signalés pendant les missions';
COMMENT ON TABLE sync_queue IS 'File d''attente pour la synchronisation offline/online';
