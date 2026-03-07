# --------------------------------------------------
# Stage 1 — Build the application
# --------------------------------------------------
FROM eclipse-temurin:21-jdk-alpine AS build

WORKDIR /app

# Copy Maven wrapper and configuration first (better Docker caching)
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Download dependencies (cached layer)
RUN chmod +x mvnw && ./mvnw -B dependency:go-offline

# Copy source code
COPY src src

# Build the application
RUN ./mvnw clean package -DskipTests -B


# --------------------------------------------------
# Stage 2 — Runtime image
# --------------------------------------------------
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Apply latest security patches
RUN apk upgrade --no-cache

# Create non-root user for security
RUN addgroup -S devsecops && adduser -S devsecops -G devsecops

# Switch to non-root user
USER devsecops

# Copy the built jar from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose application port
EXPOSE 8080

# JVM optimizations for containers
ENTRYPOINT ["java","-XX:+UseContainerSupport","-XX:MaxRAMPercentage=75.0","-jar","app.jar"]
