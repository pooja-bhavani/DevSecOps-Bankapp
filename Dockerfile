# ----------------------
# Build Stage
# ----------------------
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app

# Cache Maven dependencies by copying pom.xml first
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
RUN ./mvnw dependency:go-offline -B

# Copy source and build
COPY src ./src
RUN ./mvnw clean package -DskipTests -B

# ----------------------
# Run Stage (Distroless for maximum security)
# ----------------------
# 'nonroot' tag provides a pre-configured non-root user
FROM gcr.io/distroless/java21-debian12:nonroot
WORKDIR /app

# Copy the built artifact from the build stage
COPY --from=build /app/target/*.jar app.jar

# Distroless images run as 'nonroot' user by default
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
