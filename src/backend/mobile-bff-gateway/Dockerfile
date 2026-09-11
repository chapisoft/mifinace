# ====================================================================================
# MULTI-STAGE DOCKERFILE CHO MOBILE BFF GATEWAY (JAVA 21 LTS & SPRING BOOT 3.3+)
# HỆ THỐNG: ERP Microfinance BMF Myanmar
# TÁC VỤ: TASK-SEC-03.1
# ====================================================================================

# ------------------------------------------------------------------------------------
# Stage 1: Build & Package ứng dụng với Maven & Eclipse Temurin JDK 21
# ------------------------------------------------------------------------------------
FROM maven:3.9.8-eclipse-temurin-21-alpine AS builder

WORKDIR /app

# Sao chép pom.xml các module để tận dụng Docker Layer Cache
COPY pom.xml ./
COPY bmf-domain/pom.xml ./bmf-domain/
COPY bmf-app/pom.xml ./bmf-app/
COPY bmf-infra/pom.xml ./bmf-infra/
COPY bmf-api/pom.xml ./bmf-api/

# Tải trước các dependencies
RUN mvn dependency:go-offline -B

# Sao chép toàn bộ mã nguồn
COPY bmf-domain/src ./bmf-domain/src
COPY bmf-app/src ./bmf-app/src
COPY bmf-infra/src ./bmf-infra/src
COPY bmf-api/src ./bmf-api/src

# Biên dịch, chạy kiểm thử tự động và đóng gói JAR
RUN mvn clean package -DskipTests=false -B

# ------------------------------------------------------------------------------------
# Stage 2: Runtime Image tối ưu dung lượng và bảo mật (Alpine JRE 21 Non-Root)
# ------------------------------------------------------------------------------------
FROM eclipse-temurin:21-jre-alpine

LABEL maintainer="BMF Engineering Team <dev@bmf.mm>"
LABEL description="BMF Mobile Backend-For-Frontend Gateway Container"

# Cài đặt tzdata và đặt múi giờ Asia/Yangon (UTC+06:30) cho thị trường Myanmar
RUN apk add --no-cache tzdata curl && \
    cp /usr/share/zoneinfo/Asia/Yangon /etc/localtime && \
    echo "Asia/Yangon" > /etc/timezone

# Tạo group và user phi đặc quyền (Non-Root User)
RUN addgroup -g 10001 bmfgroup && \
    adduser -u 10001 -G bmfgroup -s /bin/sh -D bmfuser

WORKDIR /app

# Sao chép tệp JAR từ Stage 1
COPY --from=builder /app/bmf-api/target/bmf-api-1.0.0-SNAPSHOT.jar ./app.jar

# Phân quyền cho user bmfuser
RUN chown -R bmfuser:bmfgroup /app

# Chuyển sang non-root user
USER bmfuser

# Khai báo các biến môi trường cấu hình JVM tối ưu cho Java 21 Virtual Threads & ZGC
ENV JAVA_OPTS="-XX:+UseZGC -XX:+ZGenerational -XX:InitialRAMPercentage=50.0 -XX:MaxRAMPercentage=75.0 -Duser.timezone=Asia/Yangon -Dfile.encoding=UTF-8"
ENV SERVER_PORT=8080

EXPOSE 8080

# Health check qua Spring Boot Actuator
HEALTHCHECK --interval=15s --timeout=3s --retries=3 --start-period=30s \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
