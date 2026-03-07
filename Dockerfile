# ----------------------
# Build Stage
# ----------------------
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app
COPY . .
RUN chmod +x mvnw && ./mvnw clean package -DskipTests -B

# ----------------------
# Run Stage
# ----------------------
# Use Alpine 3.28+ to reduce CVEs, or consider debian-slim for critical fixes
FROM eclipse-temurin:21-jre-alpine3.28
WORKDIR /app

# Update OS packages and apply latest security patches
RUN apk update && apk upgrade --no-cache

# Create a non-root user for security
RUN addgroup -S devsecops && adduser -S -G devsecops devsecops
USER devsecops

# Copy only the built artifact
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
