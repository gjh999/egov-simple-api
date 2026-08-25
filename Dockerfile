# syntax=docker/dockerfile:1.7
# egov-simple-api 컨테이너 이미지.
#   1단계: Maven 으로 실행 가능한 Spring Boot jar 를 만든다.
#   2단계: Temurin JRE 17 위에서 비루트 사용자로 실행한다.
#
# 기본 프로필은 내장 HSQLDB 라 별도 DB 컨테이너 없이 이 이미지 하나로 뜬다.
# 운영에서는 Globals.DbType 과 접속 정보를 환경변수로 덮어쓴다.

# ---------- Build ----------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace

# 의존성을 먼저 받아 두면 소스만 바뀔 때 이 레이어를 재사용한다.
COPY pom.xml ./
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B -ntp dependency:go-offline

COPY src ./src
# 이미지 빌드 중에는 테스트를 돌리지 않는다 — 내장 HSQLDB 파일 락이 빌드 환경에서 충돌한다.
# 테스트는 CI 나 로컬에서 `mvn test` 로 따로 돌린다.
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B -ntp -DskipTests package && \
    cp target/*.jar /workspace/app.jar

# ---------- Runtime ----------
FROM eclipse-temurin:17-jre-alpine AS runtime

RUN addgroup -S app && adduser -S -G app app
WORKDIR /app
COPY --from=build --chown=app:app /workspace/app.jar /app/app.jar
USER app:app

# 컨테이너에 주어진 메모리에 맞춰 힙을 잡는다.
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75 -XX:+ExitOnOutOfMemoryError -Dfile.encoding=UTF-8"

# 운영 배포 시 반드시 덮어쓸 값 — 기본값은 개발 편의를 위한 자리표시자다.
ENV EGOV_JWT_SECRET="" \
    EGOV_ALLOW_ORIGIN="http://localhost:3000,http://localhost:3001" \
    JWT_COOKIE_SECURE=false \
    JWT_COOKIE_SAMESITE=Lax

EXPOSE 8090

# 인증 없이 열려 있는 가벼운 엔드포인트로 살아있는지 확인한다.
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8090/api/i18n/ko >/dev/null || exit 1

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/app.jar"]
