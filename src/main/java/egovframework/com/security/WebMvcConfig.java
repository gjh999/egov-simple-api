package egovframework.com.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.i18n.AcceptHeaderLocaleResolver;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.fasterxml.jackson.databind.ObjectMapper;

import egovframework.com.config.HtmlCharacterEscapes;
import lombok.RequiredArgsConstructor;

import java.util.List;
import java.util.Locale;

/**
 * fileName       : WebMvcConfig
 * author         : crlee
 * date           : 2023/07/13
 * description    :
 * ===========================================================
 * DATE              AUTHOR             NOTE
 * -----------------------------------------------------------
 * 2023/07/13        crlee       최초 생성
 */
@Configuration
@RequiredArgsConstructor
public class WebMvcConfig implements WebMvcConfigurer {
	
	private final ObjectMapper objectMapper;
	
    @Override
    public void addArgumentResolvers(List<HandlerMethodArgumentResolver> argumentResolvers) {
        argumentResolvers.add(new CustomAuthenticationPrincipalResolver());
    }

    /**
     * 다국어 로케일 해석기 — SPA 는 언어 상태를 프론트가 보관하고 요청마다
     * {@code Accept-Language} 헤더로 전달한다. 서버는 그 헤더만 보고 응답 메시지를 고른다.
     * (서버 렌더링 시절의 LANG 쿠키 + /cmm/lang 리다이렉트 방식은 SPA 에서 불필요하다.)
     * 헤더가 없거나 지원하지 않는 언어면 한국어로 응답한다.
     */
    @Bean
    public LocaleResolver localeResolver() {
        AcceptHeaderLocaleResolver resolver = new AcceptHeaderLocaleResolver();
        resolver.setDefaultLocale(Locale.KOREAN);
        resolver.setSupportedLocales(List.of(Locale.KOREAN, Locale.ENGLISH));
        return resolver;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // API 응답은 브라우저가 캐시하지 못하도록 한다.
        // (게시물 등록 후 목록이 이전 결과로 응답되던 문제 방지)
        // 바이너리 응답(파일/이미지 다운로드)과 API 문서는 캐시 가능하도록 제외한다.
        registry.addInterceptor(new HandlerInterceptor() {
            @Override
            public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
                response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
                response.setHeader("Pragma", "no-cache");
                response.setDateHeader("Expires", 0);
                return true;
            }
        }).excludePathPatterns("/webjars/**", "/swagger-ui/**", "/v3/api-docs/**", "/file", "/image");
    }
    
    @Bean
    public HttpMessageConverter<?> htmlEscapingConverter() {
        ObjectMapper copy = objectMapper.copy();
        copy.getFactory().setCharacterEscapes(new HtmlCharacterEscapes());
        return new MappingJackson2HttpMessageConverter(copy);
    }
    
}