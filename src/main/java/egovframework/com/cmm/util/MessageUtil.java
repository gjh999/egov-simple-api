package egovframework.com.cmm.util;

import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.stereotype.Component;

/**
 * 컨트롤러 등에서 현재 요청 Locale(LANG 쿠키 기준)에 맞는 다국어 메시지를 조회하는 유틸.
 *
 * <p>{@code message-ui_{ko,en}.properties} / {@code message-common_{ko,en}.properties} 의
 * 메시지 키를 LocaleContextHolder 의 현재 Locale 로 해석한다.
 * 화면(Thymeleaf {@code #{...}})과 동일한 메시지를 서버 측 플래시/모델 메시지에서도 사용하기 위함.</p>
 */
@Component("messageUtil")
public class MessageUtil {

    private final MessageSource messageSource;

    public MessageUtil(MessageSource messageSource) {
        this.messageSource = messageSource;
    }

    /**
     * 현재 요청 Locale 로 메시지 키를 해석한다.
     * @param code 메시지 키
     * @return 해석된 메시지(키가 없으면 키 자체를 반환)
     */
    public String get(String code) {
        return messageSource.getMessage(code, null, code, LocaleContextHolder.getLocale());
    }

    /**
     * 파라미터 치환을 포함하여 현재 요청 Locale 로 메시지 키를 해석한다.
     * @param code 메시지 키
     * @param args 치환 인자
     * @return 해석된 메시지(키가 없으면 키 자체를 반환)
     */
    public String get(String code, Object... args) {
        return messageSource.getMessage(code, args, code, LocaleContextHolder.getLocale());
    }
}
