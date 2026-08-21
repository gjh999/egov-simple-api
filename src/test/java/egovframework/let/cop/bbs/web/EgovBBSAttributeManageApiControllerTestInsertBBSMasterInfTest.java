package egovframework.let.cop.bbs.web;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import egovframework.com.cmm.LoginVO;
import egovframework.com.jwt.EgovJwtTokenUtil;
import egovframework.let.cop.bbs.dto.request.BbsAttributeInsertRequestDTO;
import egovframework.let.cop.bbs.service.EgovBBSAttributeManageService;
import jakarta.servlet.http.Cookie;
import lombok.extern.slf4j.Slf4j;

/**
 * [게시판생성관리] 게시판 마스터 목록 조회 API 통합 테스트.
 *
 * <p>{@code GET /bbsMaster} 는 ROLE_ADMIN 전용이다. SPA 인증 계약에 맞춰
 * {@code ACCESS_TOKEN} 쿠키로 관리자 토큰을 실어 호출한다.</p>
 *
 * @author 이백행
 * @since 2024-09-20
 */
@SpringBootTest
@AutoConfigureMockMvc
@Slf4j
class EgovBBSAttributeManageApiControllerTestInsertBBSMasterInfTest {

	private static final String ACCESS_TOKEN_COOKIE = "ACCESS_TOKEN";

	@Autowired
	private MockMvc mockMvc;

	@Autowired
	private EgovJwtTokenUtil jwtTokenUtil;

	/** 게시판 속성정보 관리를 위한 서비스 */
	@Autowired
	private EgovBBSAttributeManageService egovBBSAttributeManageService;

	@Test
	@DisplayName("관리자 토큰으로 게시판 마스터를 검색하면 방금 등록한 게시판이 조회된다")
	void searchBbsMasterAsAdmin() throws Exception {
		// given — 검색 대상이 될 게시판 마스터 1건 등록
		final BbsAttributeInsertRequestDTO bbsInsertRequestDTO = new BbsAttributeInsertRequestDTO();

		final String now = LocalDateTime.now().format(DateTimeFormatter.ofPattern("uuuu-MM-dd'T'HH:mm:ss.SSSSSSSSS"));
		bbsInsertRequestDTO.setBbsNm("test 게시판명 " + now);
		bbsInsertRequestDTO.setPosblAtchFileSize("0");
		bbsInsertRequestDTO.setBbsAttrbCode("BBSA02");
		bbsInsertRequestDTO.setBbsTyCode("BBST01");
		bbsInsertRequestDTO.setFileAtchPosblAt("Y");
		bbsInsertRequestDTO.setUseAt("Y");
		bbsInsertRequestDTO.setFrstRegisterId("admin");

		final String resultBbsId = egovBBSAttributeManageService.insertBBSMastetInf(bbsInsertRequestDTO);

		// when / then
		mockMvc.perform(get("/bbsMaster")
						.param("searchCnd", "0")
						.param("searchWrd", bbsInsertRequestDTO.getBbsNm())
						.cookie(new Cookie(ACCESS_TOKEN_COOKIE, adminToken())))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.resultCode").value(equalTo(200)))
				.andExpect(jsonPath("$.resultMessage").value(equalTo("성공했습니다.")))
				.andExpect(jsonPath("$.result.resultCnt").value(equalTo(1)))
				.andExpect(jsonPath("$.result.resultList[0].bbsNm").value(equalTo(bbsInsertRequestDTO.getBbsNm())))
				.andExpect(jsonPath("$.result.resultList[0].bbsId").value(equalTo(resultBbsId)));

		if (log.isDebugEnabled()) {
			log.debug("resultBbsId={}", resultBbsId);
		}
	}

	@Test
	@DisplayName("인증 없이 게시판 마스터 목록을 호출하면 401 이다")
	void searchBbsMasterWithoutAuthIsUnauthorized() throws Exception {
		mockMvc.perform(get("/bbsMaster").param("searchCnd", "0").param("searchWrd", ""))
				.andExpect(status().isUnauthorized());
	}

	/** ROLE_ADMIN 권한을 가진 관리자 토큰을 만든다(JwtAuthenticationFilter 가 groupNm 으로 역할을 판정한다). */
	private String adminToken() {
		LoginVO admin = new LoginVO();
		admin.setId("admin");
		admin.setName("관리자");
		admin.setUserSe("USR");
		admin.setUniqId("USRCNFRM_00000000000");
		admin.setGroupNm("ROLE_ADMIN");
		return jwtTokenUtil.generateToken(admin);
	}
}
