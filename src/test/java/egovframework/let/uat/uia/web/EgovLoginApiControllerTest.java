package egovframework.let.uat.uia.web;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import egovframework.let.utl.sim.service.EgovFileScrty;

/**
 * 로그인 API 통합 테스트 — SPA 인증 계약(HttpOnly 쿠키)을 검증한다.
 *
 * <p>이 백엔드는 로그인 성공 시 JWT 를 <b>응답 본문이 아니라 {@code ACCESS_TOKEN} HttpOnly 쿠키</b>로
 * 발급한다. 본문에는 화면 표시용 최소 정보(id/name/userSe/uniqId)만 담긴다. 토큰이 본문에 실리면
 * 프론트의 JS 가 읽을 수 있게 되어 XSS 로 탈취 가능해지므로, 본문에 토큰이 <b>없다</b>는 것도 함께 검증한다.</p>
 */
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class EgovLoginApiControllerTest {

    private static final String ACCESS_TOKEN_COOKIE = "ACCESS_TOKEN";

    @Value("${server.servlet.context-path}")
    private String contextPath;

    @LocalServerPort
    private int port;

    private final TestRestTemplate rest = new TestRestTemplate();

    private String url(String path) {
        String base = contextPath.endsWith("/") ? contextPath.substring(0, contextPath.length() - 1) : contextPath;
        return String.format("http://localhost:%d%s%s", port, base, path);
    }

    @Test
    @DisplayName("로그인 성공 시 ACCESS_TOKEN 쿠키가 발급되고, 응답 본문에는 토큰이 없다")
    void loginIssuesHttpOnlyCookie() {
        ResponseEntity<HashMap> response = login("admin", "1");

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);

        Map<String, Object> body = response.getBody();
        assertThat(body).isNotNull();
        assertThat(body.get("resultCode")).isEqualTo("200");

        // 본문에 토큰이 실리지 않아야 한다 (XSS 탈취 방지)
        assertThat(body).doesNotContainKeys("jToken", "token", "accessToken");

        @SuppressWarnings("unchecked")
        Map<String, Object> userInfo = (Map<String, Object>) body.get("resultVO");
        assertThat(userInfo).isNotNull();
        assertThat(userInfo.get("id")).isEqualTo("admin");
        assertThat(userInfo).doesNotContainKey("password");

        // HttpOnly 쿠키로 발급되어야 한다
        String setCookie = firstAccessTokenCookie(response.getHeaders());
        assertThat(setCookie).isNotNull();
        assertThat(setCookie).contains("HttpOnly");
        assertThat(setCookie).contains("Path=/");
    }

    @Test
    @DisplayName("발급받은 쿠키로 /auth/me 를 호출하면 사용자 정보와 권한이 반환된다")
    void meWithCookieReturnsUser() {
        String cookie = accessTokenCookieValue(login("admin", "1"));

        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.COOKIE, ACCESS_TOKEN_COOKIE + "=" + cookie);

        ResponseEntity<HashMap> response = rest.exchange(
                url("/auth/me"), HttpMethod.GET, new HttpEntity<>(headers), HashMap.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        Map<String, Object> body = response.getBody();
        assertThat(body).isNotNull();
        assertThat(body.get("resultCode")).isEqualTo("200");

        @SuppressWarnings("unchecked")
        Map<String, Object> userInfo = (Map<String, Object>) body.get("resultVO");
        assertThat(userInfo.get("id")).isEqualTo("admin");
        @SuppressWarnings("unchecked")
        List<String> roles = (List<String>) userInfo.get("roles");
        assertThat(roles).contains("ROLE_ADMIN");
    }

    @Test
    @DisplayName("쿠키 없이 /auth/me 를 호출하면 401 코드를 반환한다")
    void meWithoutCookieReturnsUnauthorizedCode() {
        ResponseEntity<HashMap> response = rest.getForEntity(url("/auth/me"), HashMap.class);

        // /auth/me 는 permitAll 이며 컨트롤러가 본문에 401 을 담아 응답한다
        // (프론트가 '로그인 안 됨'과 '서버 오류'를 구분할 수 있어야 한다)
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody().get("resultCode")).isEqualTo("401");
        assertThat(response.getBody()).doesNotContainKey("resultVO");
    }

    @Test
    @DisplayName("위조된 토큰 쿠키로 보호된 API 를 호출하면 401 이다")
    void forgedCookieIsRejected() {
        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.COOKIE, ACCESS_TOKEN_COOKIE + "=123123123123123T&*#$SDF123");

        ResponseEntity<String> response = rest.exchange(
                url("/mypage"), HttpMethod.GET, new HttpEntity<>(headers), String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
    }

    @Test
    @DisplayName("인증 없이 보호된 API 를 호출하면 401 이다")
    void protectedApiWithoutAuthIsUnauthorized() {
        ResponseEntity<String> response = rest.getForEntity(url("/mypage"), String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
    }

    @Test
    @DisplayName("잘못된 비밀번호로 로그인하면 300 코드를 반환하고 쿠키를 발급하지 않는다")
    void loginWithWrongPasswordIssuesNoCookie() {
        ResponseEntity<HashMap> response = login("admin", "wrong-password");

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody().get("resultCode")).isEqualTo("300");
        assertThat(firstAccessTokenCookie(response.getHeaders())).isNull();
    }

    @Test
    @DisplayName("로그아웃하면 ACCESS_TOKEN 쿠키가 만료된다")
    void logoutExpiresCookie() {
        String cookie = accessTokenCookieValue(login("admin", "1"));

        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.COOKIE, ACCESS_TOKEN_COOKIE + "=" + cookie);

        ResponseEntity<HashMap> response = rest.exchange(
                url("/auth/logout"), HttpMethod.GET, new HttpEntity<>(headers), HashMap.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        String setCookie = firstAccessTokenCookie(response.getHeaders());
        assertThat(setCookie).isNotNull();
        assertThat(setCookie).contains("Max-Age=0");
    }

    // ---------------------------------------------------------------- helpers

    /**
     * 로그인 요청.
     *
     * <p><b>비밀번호는 평문으로 보내지 않는다.</b> 클라이언트가 {@code Base64(SHA-256(id || password))} 로
     * 1차 해싱한 값을 보내고, 서버가 한 번 더 해싱해 저장값(이중해시)과 비교한다. 프론트(React/Vue)도
     * 동일하게 Web Crypto 로 1차 해시를 만들어 전송해야 한다.</p>
     */
    private ResponseEntity<HashMap> login(String id, String plainPassword) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        params.put("password", clientSideHash(id, plainPassword));
        params.put("userSe", "USR");

        return rest.exchange(url("/auth/login-jwt"), HttpMethod.POST,
                new HttpEntity<>(params, headers), HashMap.class);
    }

    /** 프론트엔드가 수행하는 1차 해시와 동일한 계산 */
    private String clientSideHash(String id, String plainPassword) {
        try {
            return EgovFileScrty.encryptPassword(plainPassword, id);
        } catch (Exception e) {
            throw new IllegalStateException("비밀번호 해시 계산 실패", e);
        }
    }

    /** 응답 헤더에서 ACCESS_TOKEN 쿠키의 Set-Cookie 원문을 찾는다. 없으면 null. */
    private String firstAccessTokenCookie(HttpHeaders headers) {
        List<String> cookies = headers.get(HttpHeaders.SET_COOKIE);
        if (cookies == null) {
            return null;
        }
        return cookies.stream()
                .filter(c -> c.startsWith(ACCESS_TOKEN_COOKIE + "="))
                .findFirst()
                .orElse(null);
    }

    /** ACCESS_TOKEN 쿠키의 값(토큰 문자열)만 추출한다. */
    private String accessTokenCookieValue(ResponseEntity<HashMap> loginResponse) {
        String setCookie = firstAccessTokenCookie(loginResponse.getHeaders());
        assertThat(setCookie).as("로그인 응답에 ACCESS_TOKEN 쿠키가 있어야 한다").isNotNull();
        String withoutName = setCookie.substring((ACCESS_TOKEN_COOKIE + "=").length());
        int end = withoutName.indexOf(';');
        return (end >= 0) ? withoutName.substring(0, end) : withoutName;
    }
}
