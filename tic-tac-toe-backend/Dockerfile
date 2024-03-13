FROM openjdk:21-slim

ARG JAR_FILE=build/libs/tic-tac-toe-backend-0.0.1-SNAPSHOT.jar

COPY ${JAR_FILE} app.jar

EXPOSE 8081

ENTRYPOINT ["java", "-jar", "/app.jar"]