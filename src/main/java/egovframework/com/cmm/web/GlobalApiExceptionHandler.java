package egovframework.com.cmm.web;

import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.servlet.NoHandlerFoundException;

import egovframework.com.cmm.ResponseCode;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;

/**
 * 모든 예외를 JSON 으로 응답하는 전역 처리기.
 *
 * <p>서버 렌더링 백엔드는 예외를 에러 <b>페이지</b>로 보여줬다. 이 백엔드에는 화면이 없으므로,
 * 프론트(fetch/axios)가 항상 파싱 가능한 JSON 을 받도록 통일한다. HTML 이 섞여 오면
 * 프론트의 응답 파서가 그대로 깨진다.</p>
 *
 * <p>응답 형태는 다른 API 와 동일하게 {@code resultCode} / {@code resultMessage} 를 사용한다.</p>
 *
 * <pre>
 * { "resultCode": 404, "resultMessage": "요청한 경로를 찾을 수 없습니다.", "path": "/api/unknown" }
 * </pre>
 */
@Slf4j
@RestControllerAdvice
public class GlobalApiExceptionHandler {

	/** 존재하지 않는 경로 (spring.mvc.throw-exception-if-no-handler-found=true 필요) */
	@ExceptionHandler(NoHandlerFoundException.class)
	public ResponseEntity<Map<String, Object>> handleNotFound(NoHandlerFoundException e, HttpServletRequest request) {
		return build(HttpStatus.NOT_FOUND, 404, "요청한 경로를 찾을 수 없습니다.", request);
	}

	/** 지원하지 않는 HTTP 메서드 */
	@ExceptionHandler(HttpRequestMethodNotSupportedException.class)
	public ResponseEntity<Map<String, Object>> handleMethodNotAllowed(
			HttpRequestMethodNotSupportedException e, HttpServletRequest request) {
		return build(HttpStatus.METHOD_NOT_ALLOWED, 405, "허용되지 않은 요청 방식입니다.", request);
	}

	/** 권한 부족 — 인증은 됐으나 역할이 모자란 경우 */
	@ExceptionHandler(AccessDeniedException.class)
	public ResponseEntity<Map<String, Object>> handleAccessDenied(AccessDeniedException e, HttpServletRequest request) {
		return build(HttpStatus.FORBIDDEN, ResponseCode.AUTH_ERROR.getCode(),
				ResponseCode.AUTH_ERROR.getMessage(), request);
	}

	/** 필수 파라미터 누락 / 타입 불일치 / @Valid 위반 */
	@ExceptionHandler({
			MissingServletRequestParameterException.class,
			MethodArgumentTypeMismatchException.class,
			MethodArgumentNotValidException.class,
			IllegalArgumentException.class})
	public ResponseEntity<Map<String, Object>> handleBadRequest(Exception e, HttpServletRequest request) {
		log.debug("잘못된 요청: {} {}", request.getMethod(), request.getRequestURI(), e);
		return build(HttpStatus.BAD_REQUEST, ResponseCode.INPUT_CHECK_ERROR.getCode(),
				ResponseCode.INPUT_CHECK_ERROR.getMessage(), request);
	}

	/** 업로드 용량 초과 (application.properties 의 spring.servlet.multipart.* 기준) */
	@ExceptionHandler(MaxUploadSizeExceededException.class)
	public ResponseEntity<Map<String, Object>> handleUploadTooLarge(
			MaxUploadSizeExceededException e, HttpServletRequest request) {
		return build(HttpStatus.PAYLOAD_TOO_LARGE, 413, "업로드 가능한 파일 크기를 초과했습니다.", request);
	}

	/**
	 * 그 밖의 모든 예외.
	 * 내부 메시지(스택트레이스·SQL 문 등)는 응답에 싣지 않는다 — 서버 로그로만 남긴다.
	 */
	@ExceptionHandler(Exception.class)
	public ResponseEntity<Map<String, Object>> handleUnexpected(Exception e, HttpServletRequest request) {
		log.error("처리되지 않은 예외: {} {}", request.getMethod(), request.getRequestURI(), e);
		return build(HttpStatus.INTERNAL_SERVER_ERROR, 500, "서버 내부 오류가 발생했습니다.", request);
	}

	private ResponseEntity<Map<String, Object>> build(
			HttpStatus status, int resultCode, String message, HttpServletRequest request) {
		Map<String, Object> body = new LinkedHashMap<>();
		body.put("resultCode", resultCode);
		body.put("resultMessage", message);
		body.put("path", request.getRequestURI());
		return ResponseEntity.status(status).body(body);
	}
}
