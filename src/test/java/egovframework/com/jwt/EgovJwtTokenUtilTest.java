package egovframework.com.jwt;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import egovframework.com.cmm.LoginVO;

/**
 * JWT 토큰 생성·파싱 단위 테스트.
 *
 * <p>{@link EgovJwtTokenUtil} 의 서명 키는 {@code @Value("${Globals.jwt.secret}")} 로 주입된다.
 * 스프링 컨텍스트 없이 {@code new} 로 만들면 키가 {@code null} 이라 서명 단계에서 NPE 가 난다.
 * 컨텍스트 전체를 띄우는 대신 테스트용 키를 리플렉션으로 주입해 단위 테스트 속도를 유지한다.</p>
 */
class EgovJwtTokenUtilTest {

    /** HS256 서명에 필요한 최소 길이(32바이트)를 충족하는 테스트 전용 키 */
    private static final String TEST_SECRET = "test-secret-key-for-unit-test-only-32bytes+";

    private EgovJwtTokenUtil jwtTokenUtil;

    @BeforeEach
    void setUp() {
        jwtTokenUtil = new EgovJwtTokenUtil();
        ReflectionTestUtils.setField(jwtTokenUtil, "secretKeyString", TEST_SECRET);
    }

    @DisplayName("올바른 토큰을 입력했을 때, LoginVO 객체를 반환한다.")
    @Test
    void testValidTokenReturnsLoginVO() {
        // given
        LoginVO loginVO = new LoginVO();
        loginVO.setId("testUser");
        loginVO.setName("Test User");
        loginVO.setUserSe("USER");
        loginVO.setOrgnztId("testOrg");
        loginVO.setUniqId("testUniqId");
        loginVO.setGroupNm("ROLE_USER");

        String token = jwtTokenUtil.generateToken(loginVO);

        // when
        LoginVO result = jwtTokenUtil.getLoginVOFromToken(token);

        // then
        assertNotNull(result);
        assertEquals("testUser", result.getId());
        assertEquals("Test User", result.getName());
        assertEquals("USER", result.getUserSe());
        assertEquals("testOrg", result.getOrgnztId());
        assertEquals("testUniqId", result.getUniqId());
        assertEquals("ROLE_USER", result.getGroupNm());
    }

    @DisplayName("잘못된 토큰을 입력했을 때, InvalidJwtException 예외가 발생한다.")
    @Test
    void testInvalidTokenReturnsThrowException() {
        // given
        String token = "invalidToken";

        // when
        // then
        assertThrows(InvalidJwtException.class, () -> jwtTokenUtil.getLoginVOFromToken(token));
    }

    @DisplayName("Id가 포함되지 않은 토큰을 입력했을 때, InvalidJwtException 예외가 발생한다.")
    @Test
    void testTokenWithoutIdReturnsThrowException() {
        // given
        String token = jwtTokenUtil.generateToken(new LoginVO());

        // when
        // then
        assertThrows(InvalidJwtException.class, () -> jwtTokenUtil.getLoginVOFromToken(token));
    }

    @DisplayName("다른 키로 서명된 토큰은 InvalidJwtException 예외가 발생한다.")
    @Test
    void testTokenSignedWithOtherSecretIsRejected() {
        // given — 다른 서명 키로 만든 토큰
        EgovJwtTokenUtil otherUtil = new EgovJwtTokenUtil();
        ReflectionTestUtils.setField(otherUtil, "secretKeyString", "another-secret-key-that-is-long-enough-32");
        LoginVO loginVO = new LoginVO();
        loginVO.setId("testUser");
        String forged = otherUtil.generateToken(loginVO);

        // when
        // then
        assertThrows(InvalidJwtException.class, () -> jwtTokenUtil.getLoginVOFromToken(forged));
    }
}
