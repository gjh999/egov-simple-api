# egov-simple-api

전자정부표준프레임워크(eGovFrame) 5.0 기반 **심플 홈페이지**의 REST API 백엔드입니다.
서버 렌더링(Thymeleaf/JSP)은 포함하지 않습니다 — 화면은 별도 저장소의 프론트엔드가 담당합니다.

## 함께 쓰는 저장소

| 저장소 | 역할 | 개발 포트 |
|---|---|---|
| **egov-simple-api** (이 저장소) | REST API | 8080 (`/api`) |
| [egov-simple-react](https://github.com/gjh999/egov-simple-react) | React 19 프론트 | 5173 |
| [egov-simple-vue](https://github.com/gjh999/egov-simple-vue) | Vue 3 프론트 | 5174 |

두 프론트는 이 백엔드 하나를 함께 사용하며 기능이 서로 대등합니다.

> ⚠️ **이 저장소의 API 를 바꾸면 프론트 두 곳을 함께 고쳐야 합니다.**
> 엔드포인트 경로·응답 필드·인증 규칙을 바꿀 때는 두 프론트의 `src/api/` 를 같이 수정하세요.
> 계약 내용은 각 프론트 저장소의 `src/api/CONTRACT.md` 에 정리돼 있습니다.

---

## 1. 빠른 시작

| 도구 | 버전 |
|---|---|
| JDK | 17 |
| Maven | 3.9.x |

```bash
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dfile.encoding=UTF-8"
```

**내장 HSQLDB**로 뜨므로 별도 DB 설치가 필요 없습니다.
스키마와 시드 데이터는 `src/main/resources/db/shtdb.sql` 이 기동 시 적재합니다.

API 문서(Swagger UI): <http://localhost:8080/api/swagger-ui.html>

### 테스트 계정

| 계정 | ID | 비밀번호 | 권한 |
|---|---|---|---|
| 관리자 | `admin` | `1` | ROLE_ADMIN |
| 사용자 | `user` | `user` | ROLE_USER |

---

## 2. API 규약

### 2-1. 기준 경로

모든 엔드포인트는 `/api` 아래에 있습니다 (`server.servlet.context-path=/api`).
예) 게시물 목록 = `GET http://localhost:8080/api/board`

### 2-2. 인증 — JWT + HttpOnly 쿠키

```
POST /api/auth/login-jwt   → Set-Cookie: ACCESS_TOKEN=...; HttpOnly; Path=/; SameSite=Lax
GET  /api/auth/logout      → 쿠키 만료
GET  /api/auth/me          → 로그인 사용자 + roles (비로그인이면 resultCode 401)
```

**토큰은 응답 본문에 실리지 않습니다.** JS 가 읽을 수 없는 HttpOnly 쿠키로만 전달되므로
XSS 로 토큰을 탈취할 수 없습니다. 프론트는 모든 요청에 `credentials: 'include'` 를 붙여야 합니다.

미인증·만료 시 리다이렉트하지 않고 항상 **401 JSON** 을 반환합니다(이 백엔드에는 로그인 화면이 없습니다).

### 2-3. 비밀번호 규칙 — API 마다 다릅니다 ⚠️

| API | 클라이언트가 보내는 값 | 서버가 하는 일 |
|---|---|---|
| 로그인 `POST /auth/login-jwt` | `Base64(SHA-256(id ‖ password))` **1차 해시** | 한 번 더 해싱해 저장값(이중해시)과 비교 |
| 회원가입 `POST /etc/member_insert` | **1차 해시** | 한 번 더 해싱해 저장 |
| 관리자 비밀번호 변경 `PATCH /admin/password` | **평문** | `encryptPasswordTwice` 로 이중 해시를 직접 생성 |

세 번째만 규칙이 다릅니다. 여기서 미리 해싱해 보내면 서버가 또 이중 해시해 **절대 맞지 않습니다.**

1차 해시는 `EgovFileScrty.encryptPassword(password, id)` 와 바이트 단위로 같아야 합니다
(MessageDigest 에 salt 로 id 를 update 한 뒤 password 를 digest).

### 2-4. 응답 형태

```jsonc
// A) IntermediateResultVO — 대부분의 조회 API
{ "resultCode": 200, "resultMessage": "성공했습니다.", "result": { ... } }

// B) 구형 컨트롤러 — 로그인 등
{ "resultCode": "200", "resultMessage": "성공 !!!", "resultVO": { ... } }
```

`resultCode` 는 HTTP 상태와 **별개**입니다. HTTP 200 이어도 401/403/900 일 수 있습니다.

| resultCode | 뜻 |
|---|---|
| 200 | 성공 |
| 300 | 로그인 실패 |
| 401 | 미인증 |
| 403 | 권한 없음 |
| 700 / 800 | 삭제 / 저장 중 내부 오류 |
| 900 | 입력값 검증 실패 |

### 2-5. 엔드포인트

| 기능 | 메서드·경로 | 권한 |
|---|---|---|
| 메인 요약 | `GET /mainPage` | 공개 |
| 게시물 목록 | `GET /board?bbsId=&pageIndex=&searchCnd=&searchWrd=` | 공개 |
| 게시물 상세 | `GET /board/{bbsId}/{nttId}` | 공개 |
| 게시판 첨부 정책 | `GET /boardFileAtch/{bbsId}` | 공개 |
| 게시물 등록 | `POST /board` (multipart) | 로그인 |
| 게시물 수정 | `PUT /board/{nttId}` (multipart) | 작성자·관리자 |
| 게시물 삭제 | `PATCH /board/{bbsId}/{nttId}` | 작성자·관리자 |
| 답변 등록 | `POST /boardReply` (multipart) | 로그인 |
| 첨부 다운로드 | `GET /file?atchFileId=&fileSn=` | 로그인 |
| 일정(월/일/주) | `GET /schedule/{month\|daily\|week}?year=&month=&date=` | 로그인 |
| 일정 CRUD | `POST /schedule`, `PUT·DELETE /schedule/{schdulId}` | 로그인 |
| 내 정보 | `GET /mypage`, `PUT /mypage/update` | 로그인 |
| 회원가입 | `POST /etc/member_insert` | 공개 |
| 아이디 중복확인 | `GET /etc/member_checkid/{id}` | 공개 |
| 회원 목록·수정 | `GET /members`, `PUT /members/update` | 관리자 |
| 게시판 마스터 | `GET·POST /bbsMaster`, `PUT·PATCH /bbsMaster/{bbsId}` | 관리자 |
| 게시판 사용정보 | `GET·POST /bbsUseInf`, `PUT /bbsUseInf/{bbsId}` | 관리자 |
| 관리자 비밀번호 | `PATCH /admin/password` | 관리자 |
| 다국어 번들 | `GET /i18n/{ko\|en}` | 공개 |

> **일정 API 의 `month` 는 0-based 입니다**(1월=0, 8월=7). `java.util.Calendar` 규약을 그대로 노출하며,
> JavaScript `Date#getMonth()` 와 같은 기준이라 프론트는 변환 없이 넘깁니다.

### 2-6. 다국어

화면 문구의 원본은 이 저장소의 `src/main/resources/egovframework/message/message-ui_{ko,en}.properties` 입니다.
`GET /i18n/{lang}` 이 이를 JSON 으로 내려주고, **두 프론트가 같은 번들을 받아 씁니다** —
문구를 프론트에 박아 두면 두 화면이 갈라집니다.

ko/en 은 **키 집합이 같아야** 합니다. 한쪽에만 키를 추가하면 다른 언어에서 키 문자열이 그대로 노출됩니다.

---

## 3. 배포

```bash
mvn clean package
java -jar target/egov-simple-api-1.0.0.jar
```

운영 배포 시 **반드시** 환경변수로 교체할 값:

| 환경변수 | 기본값(개발용) | 설명 |
|---|---|---|
| `EGOV_JWT_SECRET` | placeholder | JWT 서명 키 (32자 이상 무작위) |
| `EGOV_CRYPTO_KEY` | `egovframe` | 암호화 서비스 키 |
| `JWT_COOKIE_SECURE` | `false` | HTTPS 배포 시 `true` |
| `JWT_COOKIE_SAMESITE` | `Lax` | 프론트와 API 의 등록도메인이 다르면 `None` (+ Secure) |
| `EGOV_ALLOW_ORIGIN` | `localhost:5173,5174` | 실제 프론트 도메인 (와일드카드 금지) |
| `EGOV_FRONT_URL` | `localhost:5173` | 서버가 프론트로 돌려보낼 때 쓰는 기준 URL |

### CORS 와 쿠키

프론트와 API 를 **같은 도메인**에 두고 `/api` 를 프록시하면 쿠키 문제가 생기지 않습니다.
도메인을 분리한다면 `JWT_COOKIE_SAMESITE=None` + `JWT_COOKIE_SECURE=true`(HTTPS) +
`EGOV_ALLOW_ORIGIN` 화이트리스트가 **모두** 필요합니다.

### DB 전환

기본은 내장 HSQLDB 입니다. `src/main/resources/application.properties` 의 `Globals.DbType` 을 변경하고
`DATABASE/` 의 해당 DBMS DDL·DML 을 적재합니다.

지원: `hsql` · `postgresql` · `mysql` · `oracle` · `altibase` · `tibero` · `cubrid`

---

## 4. 테스트

```bash
mvn test    # JUnit 20건
```

| 무엇을 지키는가 |
|---|
| JWT 생성·검증·위조 거부 |
| 쿠키 인증 계약 — 로그인 응답 **본문에 토큰이 없을 것** |
| 권한별 접근 제어 (관리자 API 401/403) |
| 게시판 조회·게시판 마스터 검색 |

> 테스트는 랜덤 포트로 앱을 띄웁니다. **8080 에서 개발 서버가 떠 있으면 내장 HSQLDB 파일 락이 충돌해
> 500 이 납니다** — 테스트 전에 개발 서버를 내려 주세요.

---

## 5. 프로젝트 구조

```
src/main/java/egovframework/
├── com/                     공통
│   ├── cmm/                 공통 VO·서비스·유틸
│   │   └── web/             파일 다운로드, 이미지, 다국어 번들, 전역 예외 처리
│   ├── config/              Java @Configuration (데이터소스·매퍼·트랜잭션·메시지 등)
│   ├── jwt/                 JWT 유틸·필터·인증 진입점
│   └── security/            SecurityConfig, WebMvcConfig
└── let/                     업무
    ├── cop/bbs/             게시판 · 게시판 마스터
    ├── cop/com/             게시판 사용정보
    ├── cop/smt/sim/         일정관리
    ├── main/                메인 요약
    ├── uat/uia/             로그인
    ├── uat/esm/             사이트 관리
    ├── uss/umt/             회원관리
    └── utl/                 유틸(암호화·파일·문자열)

src/main/resources/
├── egovframework/mapper/    MyBatis XML (DBMS 별 분리)
├── egovframework/message/   다국어 메시지 (ko/en) — 프론트도 이 파일을 씁니다
├── egovframework/validator/ 검증 규칙
└── db/shtdb.sql             HSQLDB 초기 스키마 + 시드

DATABASE/                    DBMS 별 DDL·DML (배포용)
```

---

## 6. 알아두면 좋은 것

- **`/mypage` 는 일반회원(GNR) 전용입니다.** 관리자(`admin`)처럼 업무사용자(USR) 계정으로 호출하면
  "회원 정보를 찾을 수 없습니다"가 돌아옵니다 — 오류가 아니라 계정 종류의 차이입니다.
- **존재하지 않는 경로는 404 가 아니라 401 이 날 수 있습니다.** Spring Security 가 인증 검사를 먼저
  수행하기 때문입니다. 인증된 상태에서는 404 JSON 이 돌아옵니다.
- **게시판 본문은 `HTMLTagFilter` 가 escape 합니다.** 프론트도 텍스트로 렌더링해 XSS 경로를 만들지 않습니다.
- 이 백엔드에는 **JSP·Thymeleaf 관련 의존성과 코드가 없습니다.** 서버 렌더링 화면을 추가하려는 시도는
  이 프로젝트의 전제와 맞지 않습니다.
- **영속 계층은 MyBatis 하나**입니다 (JPA/QueryDSL 미포함).

---

## 라이선스

Apache License 2.0 — [LICENSE](LICENSE)

전자정부표준프레임워크 공통컴포넌트를 기반으로 합니다.
