package egovframework.com.cmm.web;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.core.io.support.ResourcePatternResolver;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import egovframework.com.cmm.service.IntermediateResultVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;

/**
 * 프론트엔드(egov-simple-react / egov-simple-vue)가 사용할 다국어 메시지 번들을 JSON 으로 제공한다.
 *
 * <p>서버 렌더링 시절에는 Thymeleaf 가 {@code #{key}} 로 같은 번들을 읽었다. SPA 로 전환하면서
 * 화면 문구가 프론트로 옮겨갔지만, <b>메시지의 원본은 여전히 백엔드의 properties 한 벌</b>이다.
 * React 와 Vue 두 프론트가 이 엔드포인트를 함께 사용하므로 문구가 갈라지지 않는다.</p>
 *
 * <pre>
 * GET /api/i18n/ko  → { "resultCode":200, "result": { "header.brand": "전자정부 표준프레임워크", ... } }
 * GET /api/i18n/en  → { "resultCode":200, "result": { "header.brand": "eGovFrame", ... } }
 * </pre>
 *
 * <p>키 집합은 ko/en 이 동일해야 한다(누락 시 프론트는 키 문자열을 그대로 노출한다).</p>
 */
@Slf4j
@RestController
@Tag(name = "EgovI18nApiController", description = "다국어 메시지 번들")
public class EgovI18nApiController {

	/** 프론트에 내려줄 메시지 번들 basename 목록 (message-common 은 서버 검증 메시지) */
	private static final List<String> BUNDLE_BASENAMES = List.of(
			"classpath:/egovframework/message/message-ui",
			"classpath:/egovframework/message/com/message-common");

	private static final List<String> SUPPORTED_LANGS = List.of("ko", "en");

	private final ResourcePatternResolver resourceResolver = new PathMatchingResourcePatternResolver();

	@Operation(
			summary = "다국어 메시지 번들 조회",
			description = "프론트엔드가 화면 문구를 렌더링할 때 사용하는 key-value 전체를 반환한다.",
			tags = {"EgovI18nApiController"})
	@ApiResponses(value = {
			@ApiResponse(responseCode = "200", description = "조회 성공"),
			@ApiResponse(responseCode = "400", description = "지원하지 않는 언어")
	})
	@GetMapping("/i18n/{lang}")
	public IntermediateResultVO<Map<String, String>> getMessages(
			@Parameter(name = "lang", description = "언어 코드 (ko | en)", in = ParameterIn.PATH, example = "ko")
			@PathVariable("lang") String lang) {

		String normalized = (lang == null) ? "" : lang.trim().toLowerCase();
		if (!SUPPORTED_LANGS.contains(normalized)) {
			IntermediateResultVO<Map<String, String>> error = new IntermediateResultVO<>();
			error.setResultCode(400);
			error.setResultMessage("unsupported language: " + lang);
			return error;
		}

		Map<String, String> merged = new LinkedHashMap<>();
		for (String basename : BUNDLE_BASENAMES) {
			// 언어별 파일이 없으면(예: message-common_en 누락) 기본 파일로 대체하지 않고 건너뛴다 —
			// 조용히 한국어가 섞여 나가는 것보다 키 누락이 드러나는 편이 고치기 쉽다.
			merged.putAll(load(basename + "_" + normalized + ".properties"));
		}
		return IntermediateResultVO.success(merged);
	}

	private Map<String, String> load(String location) {
		Map<String, String> result = new LinkedHashMap<>();
		Resource resource = resourceResolver.getResource(location);
		if (!resource.exists()) {
			log.warn("메시지 번들이 없습니다: {}", location);
			return result;
		}
		Properties properties = new Properties();
		try (InputStream in = resource.getInputStream()) {
			// properties 파일은 UTF-8 로 저장돼 있다(ISO-8859-1 기본 규칙을 따르지 않는다)
			properties.load(new InputStreamReader(in, StandardCharsets.UTF_8));
		} catch (IOException e) {
			log.error("메시지 번들을 읽지 못했습니다: {}", location, e);
			return result;
		}
		properties.stringPropertyNames().stream()
				.sorted()
				.forEach(key -> result.put(key, properties.getProperty(key)));
		return result;
	}
}
