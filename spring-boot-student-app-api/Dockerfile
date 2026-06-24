# syntax=docker/dockerfile:1.7
# ============================================================
# Stage 1: build with Maven (cache pom.xml layer separately)
# ============================================================
FROM maven:3.9.9-eclipse-temurin-11 AS build
WORKDIR /build

# Copy pom first so dependency layer is cached across code-only changes
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B -e -ntp dependency:go-offline

# Now copy source and build (skip tests in image build — tests run in CI)
COPY src ./src
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B -e -ntp -DskipTests clean package

# ============================================================
# Stage 2: minimal JRE runtime, non-root user, healthcheck
# ============================================================
FROM eclipse-temurin:11-jre-alpine

# wget for HEALTHCHECK against Spring Boot Actuator
RUN apk add --no-cache wget \
    && addgroup -S app && adduser -S app -G app

WORKDIR /usr/share/myservice
COPY --from=build /build/target/student-app-api-0.0.1-SNAPSHOT.jar app.jar
RUN chown -R app:app /usr/share/myservice
USER app

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --retries=3 --start-period=40s \
    CMD wget -qO- http://localhost:8080/actuator/health | grep -q '"status":"UP"' || exit 1

ENTRYPOINT ["java", \
    "-XX:+UseG1GC", \
    "-XX:MaxRAMPercentage=75.0", \
    "-Djava.security.egd=file:/dev/./urandom", \
    "-jar", "/usr/share/myservice/app.jar"]