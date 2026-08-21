package egovframework.com.security;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.core.Ordered;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.context.NullSecurityContextRepository;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.csrf.CsrfFilter;
import org.springframework.security.web.session.DisableEncodeUrlFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CharacterEncodingFilter;
import org.springframework.web.multipart.support.MultipartFilter;

import egovframework.com.cmm.filter.HTMLTagFilter;
import egovframework.com.jwt.JwtAuthenticationEntryPoint;
import egovframework.com.jwt.JwtAuthenticationFilter;

/**
 * fileName : SecurityConfig
 * author : crlee
 * date : 2023/06/10
 * description :
 * ===========================================================
 * DATE AUTHOR NOTE
 * -----------------------------------------------------------
 * 2023/06/10 crlee 최초 생성
 * 2026/05/13 보안취약점 대응
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    // Http Methpd : Get 인증예외 List
    private String[] AUTH_GET_WHITELIST = {
            "/mainPage", // 메인 화면 리스트 조회
            "/board", // 게시판 목록조회
            "/board/{bbsId}/{nttId}", // 게시물 상세조회
            "/boardFileAtch/{bbsId}", // 게시판 파일 첨부가능 여부 조회
            "/schedule/daily", // 일별 일정 조회
            "/schedule/week", // 주간 일정 조회
            "/schedule/{schdulId}", // 일정 상세조회
    };

    // 인증 예외 List
    // 이 백엔드는 REST API 전용이다 — 화면(Thymeleaf) 경로와 정적 리소스 경로는 존재하지 않는다.
    private String[] AUTH_WHITELIST = {
            "/error", // 예외 → JSON 에러 응답 진입점
            "/auth/login-jwt", // JWT 로그인
            "/auth/logout", // 로그아웃
            "/auth/me", // 현재 사용자 조회 — 익명 호출 시 컨트롤러가 401 응답을 직접 반환 (라우트 가드/메뉴 분기용)
            "/login/naver", "/login/naver/callback", // SNS 로그인 개시·콜백
            "/login/kakao", "/login/kakao/callback",
            // 주의: 파일/이미지 다운로드(/file, /image)는 로그인 사용자만 허용한다.
            // (게시판 첨부는 로그인이 필요한 게시판 접근정책과 일치 — permitAll 제거)
            "/etc/**", // 사용자단의 회원약관,회원가입,사용자아이디 중복여부체크 URL허용
            "/i18n/**", // 프론트가 사용할 메시지 번들 (로그인 화면에서도 필요)

            /* swagger */
            "/v3/api-docs/**",
            "/swagger-resources",
            "/swagger-resources/**",
            "/swagger-ui.html",
            "/swagger-ui/**",
            "/webjars/**", // Swagger UI 정적 리소스

    };
    // application.properties의 Globals.Allow.Origin 값을 사용하며,
    // 환경별로 콤마로 구분된 복수 Origin 지정 가능 (예: "https://a.com,https://b.com")
    @Value("${Globals.Allow.Origin:http://localhost:3000}")
    private String allowedOrigins;

    @Bean
    public JwtAuthenticationFilter authenticationTokenFilterBean() throws Exception {
        return new JwtAuthenticationFilter();
    }

    @Bean
    protected CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        // 명시적 Origin 목록만 허용 — setAllowedOriginPatterns("*") + credentials 동시 사용 금지
        List<String> origins = Arrays.stream(allowedOrigins.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toList());
        configuration.setAllowedOrigins(origins);
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        // Accept-Language: 프론트(React/Vue)가 선택 언어를 헤더로 전달 → 서버 검증 메시지 다국어
        configuration.setAllowedHeaders(List.of("Authorization", "Content-Type", "X-Requested-With", "Accept-Language"));
        configuration.setExposedHeaders(List.of("Authorization"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    @Bean
    public CharacterEncodingFilter characterEncodingFilter() {
        CharacterEncodingFilter characterEncodingFilter = new CharacterEncodingFilter();
        characterEncodingFilter.setEncoding("UTF-8");
        characterEncodingFilter.setForceEncoding(true);
        return characterEncodingFilter;
    }

    /**
     * 서블릿 컨테이너 최상위 우선순위로 UTF-8 인코딩 필터를 등록.
     * (SecurityConfig 가 CharacterEncodingFilter 빈을 직접 정의하면 Spring Boot 의 고우선순위
     *  인코딩 필터가 backoff 되어, 폼 파라미터가 파싱되기 전에 UTF-8 이 적용되지 않는다.
     *  → 한글 폼 입력(예: 회원가입 이름)이 깨지는 문제를 방지하기 위해 명시적으로 최상위 등록)
     */
    @Bean
    public FilterRegistrationBean<CharacterEncodingFilter> characterEncodingFilterRegistration() {
        FilterRegistrationBean<CharacterEncodingFilter> registration =
                new FilterRegistrationBean<>(characterEncodingFilter());
        registration.addUrlPatterns("/*");
        // DispatcherType.REQUEST 만으로는 FORWARD/ASYNC 시 인코딩이 누락될 수 있어 전 디스패처 적용
        registration.setDispatcherTypes(
                jakarta.servlet.DispatcherType.REQUEST,
                jakarta.servlet.DispatcherType.FORWARD,
                jakarta.servlet.DispatcherType.ASYNC,
                jakarta.servlet.DispatcherType.ERROR,
                jakarta.servlet.DispatcherType.INCLUDE);
        registration.setOrder(Ordered.HIGHEST_PRECEDENCE);
        return registration;
    }

    @Bean
    public HTMLTagFilter htmlTagFilter() {
        return new HTMLTagFilter();
    }

    // 멀티파트 필터 빈
    @Bean
    public MultipartFilter multipartFilter() {
        return new MultipartFilter();
    }

    // 멀티파트 크기 제한은 application.properties 의 spring.servlet.multipart.* 를
    // 단일 기준으로 사용한다(파일 10MB / 요청 35MB). 별도 MultipartConfigElement 빈을 두면
    // properties 설정이 무시되므로 정의하지 않는다.

    @Bean
    protected SecurityFilterChain filterChain(HttpSecurity http) throws Exception {

        return http
                .csrf(AbstractHttpConfigurer::disable)
                // 기본 LogoutFilter 비활성화 — JWT 쿠키(ACCESS_TOKEN) 만료는
                // EgovLoginApiController.actionLogoutJSON(/auth/logout) 이 직접 처리한다.
                .logout(AbstractHttpConfigurer::disable)
                .authorizeHttpRequests(authorize -> authorize
                        // CORS preflight 는 인증 대상이 아니다 (쿠키·Authorization 헤더가 실리지 않는다)
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        .requestMatchers("/admin/**").hasRole("ADMIN") // 관리자 비밀번호 변경
                        .requestMatchers("/bbsMaster/**").hasRole("ADMIN") // 게시판 마스터 관리
                        .requestMatchers("/bbsUseInf/**", "/notUsedBbsMaster").hasRole("ADMIN") // 게시판 사용정보 관리
                        .requestMatchers("/members/**").hasRole("ADMIN") // 회원 관리
                        .requestMatchers("/mypage/**").hasAnyRole("ADMIN", "USER") // 마이페이지는 ADMIN, USER 모두 접근
                        .requestMatchers(AUTH_WHITELIST).permitAll()
                        .requestMatchers(HttpMethod.GET, AUTH_GET_WHITELIST).permitAll()
                        .anyRequest().authenticated())
                .sessionManagement(sessionManagement ->
                        sessionManagement.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .securityContext(securityContext ->
                        securityContext.securityContextRepository(new NullSecurityContextRepository()))
                .requestCache(requestCache -> requestCache.disable())
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .addFilterBefore(characterEncodingFilter(), DisableEncodeUrlFilter.class)
                .addFilterBefore(authenticationTokenFilterBean(), UsernamePasswordAuthenticationFilter.class)
                .addFilterBefore(multipartFilter(), CsrfFilter.class)
                .exceptionHandling(exceptionHandling -> exceptionHandling
                        .authenticationEntryPoint(new JwtAuthenticationEntryPoint()))
                .build();
    }

}