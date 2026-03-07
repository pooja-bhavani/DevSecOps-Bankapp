# ----------------------
# Build Stage
# ----------------------
FROM eclipse-temurin:21-jdk-alpine AS build

WORKDIR /app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

RUN chmod +x mvnw && ./mvnw -B dependency:go-offline

COPY src src

RUN ./mvnw clean package -DskipTests -B


# ----------------------
# Run Stage
# ----------------------
FROM eclipse-temurin:21-jre-alpine3.28

WORKDIR /app

# Apply latest OS security patches
RUN apk upgrade --no-cache

# Create non-root user
RUN addgroup -S devsecops && adduser -S devsecops -G devsecops

USER devsecops

# Copy built artifact
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-XX:+UseContainerSupport","-XX:MaxRAMPercentage=75.0","-jar","app.jar"]
