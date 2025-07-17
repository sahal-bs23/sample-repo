# Development Dockerfile for Spring Boot Backend
FROM openjdk:17-jdk-alpine

# Set working directory
WORKDIR /app

# Install Maven
RUN apk add --no-cache maven

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Create logs and uploads directories
RUN mkdir -p logs uploads

# Expose port
EXPOSE 8080

# Start application in development mode
CMD ["mvn", "spring-boot:run", "-Dspring-boot.run.profiles=development"]

