###############################################
# 1. Build frontend (React + Vite)
###############################################
FROM node:20 AS frontend-builder
WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm install

COPY frontend .
RUN npm run build


###############################################
# 2. Build backend (Spring Boot + Gradle)
###############################################
FROM gradle:8.5-jdk21 AS backend-builder
WORKDIR /app

COPY backend .

# Copy frontend build into Spring Boot static directory
COPY --from=frontend-builder /app/frontend/dist ./src/main/resources/static/

RUN gradle clean bootJar --no-daemon


###############################################
# 3. Final runtime image
###############################################
FROM eclipse-temurin:21-jdk
WORKDIR /app

EXPOSE 8080

COPY --from=backend-builder /app/build/libs/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]
