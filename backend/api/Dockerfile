# Dockerfile pour le backend API LOGEST Planning
FROM node:18-alpine

WORKDIR /app

# Installer les dépendances système nécessaires
RUN apk add --no-cache python3 make g++

# Copier les fichiers de dépendances
COPY package*.json ./

# Installer les dépendances npm
RUN npm ci --only=production

# Copier le code source
COPY . .

# Créer le dossier uploads
RUN mkdir -p uploads

# Exposer le port
EXPOSE 3000

# Commande de démarrage
CMD ["node", "src/server.js"]
