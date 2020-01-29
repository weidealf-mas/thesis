FROM openjdk:8-jdk-alpine
#FROM java:8
VOLUME /tmp
#ARG JAR_FILE
#COPY target/${JAR_FILE} app.jar
ADD target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
