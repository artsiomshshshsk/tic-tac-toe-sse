FROM gradle:8.6.0-jdk21 as builder

WORKDIR /app

COPY . /app

RUN gradle build --no-daemon

FROM openjdk:21-slim

WORKDIR /app

COPY --from=builder /app/build/libs/tic-tac-toe-backend-0.0.1-SNAPSHOT.jar /app/app.jar
EXPOSE 8081

ENTRYPOINT ["java", "-jar", "/app/app.jar"]