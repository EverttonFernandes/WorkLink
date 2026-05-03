FROM maven:3.9.9-eclipse-temurin-21 AS build

WORKDIR /workspace/worklink-api

COPY worklink-api/pom.xml ./pom.xml
RUN mvn -B -q dependency:go-offline

COPY worklink-api/src ./src
RUN mvn -B -q package -DskipTests

FROM eclipse-temurin:21-jre-alpine AS runtime

WORKDIR /app

RUN addgroup -S worklink && adduser -S worklink -G worklink

COPY --from=build /workspace/worklink-api/target/worklink-api-*.jar /app/worklink-api.jar

ENV JAVA_OPTS=""
ENV SPRING_PROFILES_ACTIVE=local

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health || exit 1

USER worklink

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/worklink-api.jar"]
