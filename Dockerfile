# syntax=docker/dockerfile:1

# ---------- Estágio 1: build ----------
FROM maven:3.9-eclipse-temurin-25 AS build
WORKDIR /build

# Copia só o pom primeiro: se as dependências não mudarem, essa camada vem do cache
COPY pom.xml .
RUN mvn -B dependency:go-offline

COPY src ./src
RUN mvn -B clean package -DskipTests

# ---------- Estágio 2: runtime ----------
FROM tomcat:10.1-jre25-temurin-noble

# Remove apps padrão, faz o Tomcat ler a porta de uma propriedade
# (o Render injeta a variável PORT) e cria um usuário sem privilégios
RUN rm -rf /usr/local/tomcat/webapps/* \
 && sed -i 's/port="8080"/port="${port.http}"/' /usr/local/tomcat/conf/server.xml \
 && groupadd -r app && useradd -r -g app app

# Publica o WAR como ROOT.war para a aplicação responder em "/"
COPY --from=build /build/target/*.war /usr/local/tomcat/webapps/ROOT.war

# O Tomcat precisa escrever nestas pastas
RUN chown -R app:app /usr/local/tomcat/logs /usr/local/tomcat/temp \
                     /usr/local/tomcat/work /usr/local/tomcat/webapps
USER app

# Heap limitado a 60% da RAM do container (importante nos 512 MB do Render free)
ENV JAVA_OPTS="-XX:MaxRAMPercentage=60 -XX:+UseSerialGC"

EXPOSE 10000
CMD ["sh", "-c", "export CATALINA_OPTS=\"-Dport.http=${PORT:-10000}\" && exec catalina.sh run"]