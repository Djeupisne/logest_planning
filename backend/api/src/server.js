/**
 * Backend API - LOGEST Planning
 * Stack: Node.js + Express + PostgreSQL
 * 
 * Ce fichier est un exemple complet d'implémentation du serveur API
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'votre-secret-jwt-tres-securise';
const JWT_EXPIRES_IN = '15m';
const REFRESH_TOKEN_EXPIRES_IN = '7d';

// Configuration de la base de données PostgreSQL
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'logest_planning',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Middleware de sécurité
app.use(helmet()); // En-têtes HTTP sécurisés
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:8080'],
  credentials: true,
}));
app.use(express.json({ limit: '10mb' }));

// Rate limiting pour protéger contre le brute force
const limiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 100, // 100 requêtes par minute
  message: { error: 'Trop de requêtes, veuillez réessayer plus tard' },
});
app.use('/api/', limiter);

// Middleware d'authentification JWT
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Token d\'authentification requis' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Token invalide ou expiré' });
    }
    req.user = user;
    next();
  });
};

// Middleware de vérification des rôles
const authorizeRole = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Accès non autorisé' });
    }
    next();
  };
};

// ==================== AUTHENTIFICATION ====================

// Login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email et mot de passe requis' });
    }

    const result = await pool.query(
      'SELECT * FROM users WHERE email = $1 AND is_active = true',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
    }

    const user = result.rows[0];
    const validPassword = await bcrypt.compare(password, user.password_hash);

    if (!validPassword) {
      return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
    }

    // Générer les tokens
    const accessToken = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    const refreshToken = jwt.sign(
      { id: user.id },
      JWT_SECRET,
      { expiresIn: REFRESH_TOKEN_EXPIRES_IN }
    );

    // Stocker le refresh token en base (optionnel mais recommandé)
    await pool.query(
      'UPDATE users SET refresh_token = $1 WHERE id = $2',
      [refreshToken, user.id]
    );

    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          email: user.email,
          full_name: user.full_name,
          role: user.role,
          phone: user.phone,
        },
        accessToken,
        refreshToken,
        expiresIn: 900, // 15 minutes en secondes
      },
    });
  } catch (error) {
    console.error('Erreur login:', error);
    res.status(500).json({ error: 'Erreur serveur lors de la connexion' });
  }
});

// Refresh token
app.post('/api/auth/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ error: 'Refresh token requis' });
    }

    jwt.verify(refreshToken, JWT_SECRET, async (err, decoded) => {
      if (err) {
        return res.status(403).json({ error: 'Refresh token invalide' });
      }

      const result = await pool.query(
        'SELECT * FROM users WHERE id = $1 AND refresh_token = $2',
        [decoded.id, refreshToken]
      );

      if (result.rows.length === 0) {
        return res.status(403).json({ error: 'Refresh token invalide' });
      }

      const user = result.rows[0];
      const newAccessToken = jwt.sign(
        { id: user.id, email: user.email, role: user.role },
        JWT_SECRET,
        { expiresIn: JWT_EXPIRES_IN }
      );

      res.json({
        success: true,
        data: {
          accessToken: newAccessToken,
          expiresIn: 900,
        },
      });
    });
  } catch (error) {
    console.error('Erreur refresh token:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Logout
app.post('/api/auth/logout', authenticateToken, async (req, res) => {
  try {
    await pool.query(
      'UPDATE users SET refresh_token = NULL WHERE id = $1',
      [req.user.id]
    );

    res.json({ success: true, message: 'Déconnexion réussie' });
  } catch (error) {
    console.error('Erreur logout:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ==================== UTILISATEURS ====================

// Profil utilisateur connecté
app.get('/api/users/profile', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, email, full_name, role, phone, created_at FROM users WHERE id = $1',
      [req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }

    res.json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error('Erreur profil:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ==================== MISSIONS ====================

// Liste des missions (avec filtres)
app.get('/api/missions', authenticateToken, async (req, res) => {
  try {
    const { status, date, consultant_id, type } = req.query;
    
    let query = `
      SELECT m.*, c.full_name as consultant_name, cl.name as client_name
      FROM missions m
      LEFT JOIN consultants co ON m.consultant_id = co.user_id
      LEFT JOIN users c ON co.user_id = c.id
      LEFT JOIN clients cl ON m.client_id = cl.id
      WHERE 1=1
    `;
    
    const params = [];
    let paramIndex = 1;

    if (status) {
      params.push(status);
      query += ` AND m.status = $${paramIndex++}`;
    }

    if (date) {
      params.push(date);
      query += ` AND DATE(m.scheduled_start) = $${paramIndex++}`;
    }

    if (consultant_id) {
      params.push(consultant_id);
      query += ` AND m.consultant_id = $${paramIndex++}`;
    }

    if (type) {
      params.push(type);
      query += ` AND m.type = $${paramIndex++}`;
    }

    // Filtrage par rôle
    if (req.user.role === 'consultant') {
      params.push(req.user.id);
      query += ` AND m.consultant_id = $${paramIndex++}`;
    }

    query += ' ORDER BY m.scheduled_start ASC';

    const result = await pool.query(query, params);

    res.json({ success: true, data: result.rows, count: result.rows.length });
  } catch (error) {
    console.error('Erreur liste missions:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Détails d'une mission
app.get('/api/missions/:id', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT m.*, c.full_name as consultant_name, cl.name as client_name, cl.phone as client_phone, cl.address as client_address
       FROM missions m
       LEFT JOIN consultants co ON m.consultant_id = co.user_id
       LEFT JOIN users c ON co.user_id = c.id
       LEFT JOIN clients cl ON m.client_id = cl.id
       WHERE m.id = $1`,
      [req.params.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Mission non trouvée' });
    }

    // Vérifier les permissions
    const mission = result.rows[0];
    if (req.user.role === 'consultant' && mission.consultant_id !== req.user.id) {
      return res.status(403).json({ error: 'Accès non autorisé' });
    }

    res.json({ success: true, data: mission });
  } catch (error) {
    console.error('Erreur détails mission:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Créer une mission (planificateur uniquement)
app.post('/api/missions', authenticateToken, authorizeRole('planner', 'director'), async (req, res) => {
  try {
    const {
      title, description, client_id, consultant_id,
      scheduled_start, scheduled_end, location_address,
      location_latitude, location_longitude, priority, type
    } = req.body;

    // Validation basique
    if (!title || !scheduled_start || !scheduled_end) {
      return res.status(400).json({ error: 'Titre, date de début et fin requis' });
    }

    const result = await pool.query(
      `INSERT INTO missions (
        title, description, client_id, consultant_id, planner_id,
        scheduled_start, scheduled_end, location_address,
        location_latitude, location_longitude, priority, type
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
      RETURNING *`,
      [
        title,
        description || null,
        client_id || null,
        consultant_id || null,
        req.user.id,
        scheduled_start,
        scheduled_end,
        location_address || null,
        location_latitude || null,
        location_longitude || null,
        priority || 'normal',
        type || 'mission',
      ]
    );

    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error('Erreur création mission:', error);
    res.status(500).json({ error: 'Erreur serveur lors de la création' });
  }
});

// Mettre à jour le statut d'une mission
app.patch('/api/missions/:id/status', authenticateToken, async (req, res) => {
  try {
    const { status, actual_start, actual_end } = req.body;
    const missionId = req.params.id;

    // Vérifier que le consultant est bien assigné à cette mission
    if (req.user.role === 'consultant') {
      const checkResult = await pool.query(
        'SELECT consultant_id FROM missions WHERE id = $1',
        [missionId]
      );

      if (checkResult.rows.length === 0 || checkResult.rows[0].consultant_id !== req.user.id) {
        return res.status(403).json({ error: 'Vous n\'êtes pas assigné à cette mission' });
      }
    }

    const updates = ['updated_at = CURRENT_TIMESTAMP'];
    const params = [];
    let paramIndex = 1;

    if (status) {
      updates.push(`status = $${paramIndex++}`);
      params.push(status);
    }

    if (actual_start) {
      updates.push(`actual_start = $${paramIndex++}`);
      params.push(actual_start);
    }

    if (actual_end) {
      updates.push(`actual_end = $${paramIndex++}`);
      params.push(actual_end);
    }

    params.push(missionId);

    const result = await pool.query(
      `UPDATE missions SET ${updates.join(', ')} WHERE id = $${paramIndex} RETURNING *`,
      params
    );

    res.json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error('Erreur update statut:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ==================== CONSULTANTS ====================

// Liste des consultants (planner/director uniquement)
app.get('/api/consultants', authenticateToken, authorizeRole('planner', 'director'), async (req, res) => {
  try {
    const { available, skills } = req.query;

    let query = `
      SELECT c.user_id, u.full_name, u.email, u.phone, c.skills, c.is_available,
             c.current_location, c.last_location_update, c.consent_tracking
      FROM consultants c
      JOIN users u ON c.user_id = u.id
      WHERE u.is_active = true
    `;

    const params = [];
    let paramIndex = 1;

    if (available !== undefined) {
      params.push(available === 'true');
      query += ` AND c.is_available = $${paramIndex++}`;
    }

    const result = await pool.query(query, params);

    res.json({ success: true, data: result.rows, count: result.rows.length });
  } catch (error) {
    console.error('Erreur liste consultants:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Position GPS d'un consultant (temps réel)
app.get('/api/consultants/:id/location', authenticateToken, async (req, res) => {
  try {
    // Seul le consultant lui-même ou un planner/director peut voir la position
    if (req.user.role === 'consultant' && req.params.id !== req.user.id) {
      return res.status(403).json({ error: 'Accès non autorisé' });
    }

    const result = await pool.query(
      `SELECT c.current_location, c.last_location_update, c.consent_tracking, u.full_name
       FROM consultants c
       JOIN users u ON c.user_id = u.id
       WHERE c.user_id = $1`,
      [req.params.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Consultant non trouvé' });
    }

    const consultant = result.rows[0];

    // Vérifier le consentement et les heures de travail
    if (!consultant.consent_tracking) {
      return res.status(403).json({ error: 'Le consultant n'a pas consenti au tracking' });
    }

    const now = new Date();
    const hour = now.getHours();
    const isWorkHour = hour >= 8 && hour <= 18; // Heures de travail 8h-18h

    if (!isWorkHour && req.user.role !== 'consultant') {
      return res.status(403).json({ error: 'Tracking uniquement pendant les heures de travail' });
    }

    res.json({ success: true, data: consultant });
  } catch (error) {
    console.error('Erreur position GPS:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Mettre à jour la position GPS (appelé par l'app mobile)
app.post('/api/consultants/location', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'consultant') {
      return res.status(403).json({ error: 'Seuls les consultants peuvent mettre à jour leur position' });
    }

    const { latitude, longitude } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'Latitude et longitude requises' });
    }

    // Vérifier les heures de travail
    const now = new Date();
    const hour = now.getHours();
    const isWorkHour = hour >= 8 && hour <= 18;

    if (!isWorkHour) {
      return res.status(403).json({ error: 'Mise à jour position uniquement pendant les heures de travail' });
    }

    await pool.query(
      `UPDATE consultants 
       SET current_location = ST_SetSRID(ST_MakePoint($1, $2), 4326),
           last_location_update = CURRENT_TIMESTAMP
       WHERE user_id = $3`,
      [longitude, latitude, req.user.id]
    );

    res.json({ success: true, message: 'Position mise à jour' });
  } catch (error) {
    console.error('Erreur update position:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ==================== RAPPORTS ====================

// Créer un rapport d'intervention
app.post('/api/reports', authenticateToken, async (req, res) => {
  try {
    if (req.user.role !== 'consultant') {
      return res.status(403).json({ error: 'Seuls les consultants peuvent créer des rapports' });
    }

    const { mission_id, content, photos, client_signature, is_billable } = req.body;

    if (!mission_id || !content) {
      return res.status(400).json({ error: 'Mission ID et contenu requis' });
    }

    // Vérifier que le consultant est assigné à la mission
    const missionCheck = await pool.query(
      'SELECT consultant_id FROM missions WHERE id = $1',
      [mission_id]
    );

    if (missionCheck.rows.length === 0 || missionCheck.rows[0].consultant_id !== req.user.id) {
      return res.status(403).json({ error: 'Vous n\'êtes pas assigné à cette mission' });
    }

    const result = await pool.query(
      `INSERT INTO reports (mission_id, consultant_id, content, photos, client_signature, is_billable)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [
        mission_id,
        req.user.id,
        content,
        JSON.stringify(photos || []),
        client_signature || null,
        is_billable !== undefined ? is_billable : true,
      ]
    );

    // Mettre à jour le statut de la mission à "completed"
    await pool.query(
      `UPDATE missions 
       SET status = 'completed', actual_end = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
       WHERE id = $1`,
      [mission_id]
    );

    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (error) {
    console.error('Erreur création rapport:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ==================== SYNCHRONISATION ====================

// Push des données offline vers le serveur
app.post('/api/sync/push', authenticateToken, async (req, res) => {
  try {
    const { operations } = req.body;

    if (!Array.isArray(operations)) {
      return res.status(400).json({ error: 'Operations doit être un tableau' });
    }

    const results = [];

    for (const op of operations) {
      try {
        // Traiter chaque opération selon son type
        switch (op.endpoint) {
          case '/api/missions/:id/status':
            // Mettre à jour le statut d'une mission
            await pool.query(
              `UPDATE missions SET status = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2`,
              [op.payload.status, op.params.id]
            );
            results.push({ id: op.id, success: true });
            break;

          case '/api/reports':
            // Créer un rapport
            await pool.query(
              `INSERT INTO reports (mission_id, consultant_id, content, photos, submitted_at)
               VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP)`,
              [
                op.payload.mission_id,
                req.user.id,
                op.payload.content,
                JSON.stringify(op.payload.photos || []),
              ]
            );
            results.push({ id: op.id, success: true });
            break;

          default:
            results.push({ id: op.id, success: false, error: 'Endpoint non supporté' });
        }
      } catch (error) {
        console.error('Erreur sync operation:', error);
        results.push({ id: op.id, success: false, error: error.message });
      }
    }

    res.json({ success: true, results });
  } catch (error) {
    console.error('Erreur sync push:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Pull des données mises à jour depuis le serveur
app.get('/api/sync/pull', authenticateToken, async (req, res) => {
  try {
    const { last_sync } = req.query;

    let query = `
      SELECT * FROM (
        SELECT m.*, 'mission' as type, updated_at FROM missions
        WHERE consultant_id = $1 OR planner_id = $1
        UNION ALL
        SELECT r.*, 'report' as type, submitted_at as updated_at FROM reports r
        WHERE r.consultant_id = $1
      ) AS combined
      WHERE updated_at > $2
      ORDER BY updated_at DESC
    `;

    const result = await pool.query(
      query,
      [req.user.id, last_sync || '1970-01-01']
    );

    res.json({
      success: true,
      data: result.rows,
      sync_timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Erreur sync pull:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ==================== ANALYTICS / DIRECTION ====================

// KPIs globaux
app.get('/api/analytics/kpis', authenticateToken, authorizeRole('director', 'planner'), async (req, res) => {
  try {
    const { start_date, end_date } = req.query;

    const dateFilter = start_date && end_date
      ? `WHERE scheduled_start BETWEEN '${start_date}' AND '${end_date}'`
      : '';

    // Nombre total de missions
    const totalMissions = await pool.query(
      `SELECT COUNT(*) as count FROM missions ${dateFilter}`
    );

    // Missions par statut
    const byStatus = await pool.query(
      `SELECT status, COUNT(*) as count FROM missions ${dateFilter} GROUP BY status`
    );

    // Taux d'utilisation des consultants
    const utilizationRate = await pool.query(
      `SELECT 
         COUNT(DISTINCT consultant_id) FILTER (WHERE status IN ('completed', 'in_progress'))::float / 
         NULLIF(COUNT(DISTINCT consultant_id), 0) * 100 as rate
       FROM missions ${dateFilter}`
    );

    // Temps moyen par mission
    const avgDuration = await pool.query(
      `SELECT AVG(EXTRACT(EPOCH FROM (actual_end - actual_start))/60) as avg_minutes
       FROM missions 
       WHERE actual_end IS NOT NULL AND actual_start IS NOT NULL ${dateFilter ? `AND scheduled_start BETWEEN '${start_date}' AND '${end_date}'` : ''}`
    );

    res.json({
      success: true,
      data: {
        total_missions: parseInt(totalMissions.rows[0].count),
        by_status: byStatus.rows.reduce((acc, row) => ({ ...acc, [row.status]: parseInt(row.count) }), {}),
        utilization_rate: utilizationRate.rows[0].rate || 0,
        avg_duration_minutes: parseFloat(avgDuration.rows[0].avg_minutes) || 0,
      },
    });
  } catch (error) {
    console.error('Erreur analytics:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Export des données (CSV)
app.get('/api/analytics/export', authenticateToken, authorizeRole('director', 'planner'), async (req, res) => {
  try {
    const { start_date, end_date } = req.query;

    const result = await pool.query(
      `SELECT 
         m.id, m.title, m.status, m.type, m.scheduled_start, m.scheduled_end,
         m.actual_start, m.actual_end,
         u.full_name as consultant,
         cl.name as client
       FROM missions m
       LEFT JOIN users u ON m.consultant_id = u.id
       LEFT JOIN clients cl ON m.client_id = cl.id
       WHERE m.scheduled_start BETWEEN $1 AND $2
       ORDER BY m.scheduled_start DESC`,
      [start_date || '2020-01-01', end_date || new Date()]
    );

    // Convertir en CSV
    const csvRows = [];
    csvRows.push(['ID', 'Titre', 'Statut', 'Type', 'Début prévu', 'Fin prévue', 'Début réel', 'Fin réel', 'Consultant', 'Client']);

    for (const row of result.rows) {
      csvRows.push([
        row.id,
        row.title,
        row.status,
        row.type,
        row.scheduled_start,
        row.scheduled_end,
        row.actual_start || '',
        row.actual_end || '',
        row.consultant || '',
        row.client || '',
      ]);
    }

    const csv = csvRows.map(e => e.join(',')).join('\n');

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', `attachment; filename="logest_export_${new Date().toISOString().split('T')[0]}.csv"`);
    res.send(csv);
  } catch (error) {
    console.error('Erreur export:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ==================== DÉMARRAGE DU SERVEUR ====================

app.listen(PORT, () => {
  console.log(`🚀 Serveur API LOGEST démarré sur le port ${PORT}`);
  console.log(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = app;
