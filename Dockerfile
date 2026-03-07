# Build stage
FROM eclipse-temurin:21-jdk-alpine3.26 AS build
WORKDIR /app
COPY . .
RUN chmod +x mvnw && ./mvnw clean package -DskipTests -B

# Run stage
FROM eclipse-temurin:21-jre-alpine3.26
WORKDIR /app

# Pull latest security patches
RUN apk update && apk upgrade --no-cache

# Create non-root user
RUN addgroup -S devsecops && adduser -S -G devsecops devsecops
USER devsecops

# Copy only the built artifact
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
