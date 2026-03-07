# Run stage
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Upgrade Alpine & install minimal packages
RUN apk update && \
    apk upgrade --no-cache && \
    rm -rf /var/cache/apk/*

# Create a non-root user
RUN addgroup -S devsecops && adduser -S -G devsecops devsecops
USER devsecops

# Copy only the built artifact
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
