CREATE TABLE IDS  (
  TABLE_NAME varchar(60) NOT NULL,  -- 대상 테이블명
  NEXT_ID numeric(30,0)DEFAULT 0 NOT NULL ,  -- 다음 ID 값
  CONSTRAINT IDS_PK PRIMARY KEY (TABLE_NAME)
);

CREATE TABLE COMTECOPSEQ  (
  TABLE_NAME varchar(60) NOT NULL,  -- 대상 테이블명
  NEXT_ID numeric(30,0)DEFAULT 0 NOT NULL ,  -- 다음 ID 값
  CONSTRAINT COMTECOPSEQ_PK PRIMARY KEY (TABLE_NAME)
);

CREATE TABLE TB_CMMN_CL_CODE (
  CL_CODE char(3) NOT NULL,  -- 분류코드
  CL_CODE_NM varchar(180) ,  -- 분류코드명
  CL_CODE_DC varchar(600) ,  -- 분류코드 설명
  USE_AT char(1) ,  -- 사용여부(Y/N)
  FRST_REGIST_PNTTM DATETIME ,  -- 최초등록시각
  FRST_REGISTER_ID varchar(60) ,  -- 최초등록자ID
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  CONSTRAINT TB_CMMN_CL_CODE_PK PRIMARY KEY (CL_CODE)
) ;

CREATE TABLE TB_CMMN_CODE  (
  CODE_ID varchar(18) NOT NULL,  -- 코드ID
  CODE_ID_NM varchar(180) ,  -- 코드ID명
  CODE_ID_DC varchar(600) ,  -- 코드ID 설명
  USE_AT char(1) ,  -- 사용여부(Y/N)
  CL_CODE char(3) ,  -- 분류코드
  FRST_REGIST_PNTTM DATETIME ,  -- 최초등록시각
  FRST_REGISTER_ID varchar(60) ,  -- 최초등록자ID
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  CONSTRAINT TB_CMMN_CODE_PK PRIMARY KEY (CODE_ID),
  CONSTRAINT TB_CMMN_CODE_ibfk_1 FOREIGN KEY (CL_CODE) REFERENCES TB_CMMN_CL_CODE (CL_CODE)
) ;

CREATE TABLE TB_CMMN_DETAIL_CODE  (
  CODE_ID varchar(18) NOT NULL,  -- 코드ID
  CODE varchar(45) NOT NULL,  -- 상세코드
  CODE_NM varchar(180) ,  -- 상세코드명
  CODE_DC varchar(600) ,  -- 상세코드 설명
  USE_AT char(1) ,  -- 사용여부(Y/N)
  FRST_REGIST_PNTTM DATETIME ,  -- 최초등록시각
  FRST_REGISTER_ID varchar(60) ,  -- 최초등록자ID
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  CONSTRAINT TB_CMMN_DETAIL_CODE_PK PRIMARY KEY (CODE_ID,CODE),
  CONSTRAINT TB_CMMN_DETAIL_CODE_ibfk_1 FOREIGN KEY (CODE_ID) REFERENCES TB_CMMN_CODE (CODE_ID)
) ;

CREATE TABLE TB_EMPLYR_INFO_CHNG_DTLS (
  EMPLYR_ID     VARCHAR(20) NOT NULL,  -- 사용자ID
  CHANGE_DE     CHAR(20)    NOT NULL,  -- 변경일자
  ORGNZT_ID     CHAR(20),  -- 조직ID
  GROUP_ID      CHAR(20),  -- 그룹ID
  EMPL_NO       VARCHAR(20) NOT NULL,  -- 사번
  SEXDSTN_CODE  CHAR(1),  -- 성별코드
  BRTHDY        CHAR(20),  -- 생년월일
  FXNUM         VARCHAR(20),  -- 팩스
  HOUSE_ADRES   VARCHAR(100) NOT NULL,  -- 자택주소
  HOUSE_END_TELNO VARCHAR(4),  -- 자택전화 끝번호
  AREA_NO       VARCHAR(4),  -- 지역번호
  DETAIL_ADRES  VARCHAR(100) NOT NULL,  -- 상세주소
  ZIP           VARCHAR(6) NOT NULL,  -- 우편번호
  OFFM_TELNO    VARCHAR(20),  -- 사무실전화
  MBTLNUM       VARCHAR(20) NOT NULL,  -- 휴대전화
  EMAIL_ADRES   VARCHAR(50),  -- 이메일
  HOUSE_MIDDLE_TELNO CHAR(4),  -- 자택전화 중간번호
  PSTINST_CODE  CHAR(8),  -- 소속기관코드
  EMPLYR_STTUS_CODE VARCHAR(15) NOT NULL,  -- 사용자상태코드
  ESNTL_ID      CHAR(20),  -- 고유ID
  FRST_REGIST_PNTTM DATETIME ,  -- 최초등록시각
  FRST_REGISTER_ID varchar(60) ,  -- 최초등록자ID
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  CONSTRAINT TB_EMPLYR_INFO_CHNG_DTLS_PK PRIMARY KEY (EMPLYR_ID, CHANGE_DE),
  CONSTRAINT TB_EMPLYR_INFO_CHNG_DTLS_ibfk_1 FOREIGN KEY (EMPLYR_ID) REFERENCES TB_EMPLYR_INFO(EMPLYR_ID)
) ;


CREATE TABLE TB_ORGNZT_INFO  (
  ORGNZT_ID char(20) DEFAULT '' NOT NULL,  -- 조직ID
  ORGNZT_NM varchar(60) NOT NULL,  -- 조직명
  ORGNZT_DC varchar(300) ,  -- 조직 설명
  FRST_REGIST_PNTTM DATETIME ,  -- 최초등록시각
  FRST_REGISTER_ID varchar(60) ,  -- 최초등록자ID
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  CONSTRAINT TB_ORGNZT_INFO_PK PRIMARY KEY (ORGNZT_ID)
) ;

CREATE TABLE TB_AUTHOR_GROUP_INFO  (
  GROUP_ID char(20) DEFAULT '' NOT NULL,  -- 그룹ID
  GROUP_NM varchar(180) NOT NULL,  -- 그룹명
  GROUP_CREAT_DE char(60) NOT NULL,  -- 생성일자
  GROUP_DC varchar(300) ,  -- 그룹 설명
  FRST_REGIST_PNTTM DATETIME ,  -- 최초등록시각
  FRST_REGISTER_ID varchar(60) ,  -- 최초등록자ID
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  CONSTRAINT TB_AUTHOR_GROUP_INFO_PK PRIMARY KEY (GROUP_ID)
) ;

CREATE TABLE TB_AUTHOR_INFO (
  AUTHOR_CODE   VARCHAR(30) NOT NULL,  -- 권한코드
  AUTHOR_NM     VARCHAR(60) NOT NULL,  -- 권한명
  AUTHOR_DC     VARCHAR(200),  -- 권한 설명
  AUTHOR_CREAT_DE CHAR(20) NOT NULL,  -- 생성일자
  FRST_REGIST_PNTTM DATETIME ,  -- 최초등록시각
  FRST_REGISTER_ID varchar(60) ,  -- 최초등록자ID
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  CONSTRAINT TB_AUTHOR_INFO_PK PRIMARY KEY (AUTHOR_CODE)
) ;

CREATE TABLE TB_EMPLYR_INFO  (
  EMPLYR_ID varchar(60) NOT NULL,  -- 사용자ID
  ORGNZT_ID char(20) ,  -- 조직ID
  USER_NM varchar(180) NOT NULL,  -- 사용자명
  PASSWORD varchar(600) NOT NULL,  -- 비밀번호(해시)
  EMPL_NO varchar(60) ,  -- 사번
  IHIDNUM varchar(39) ,  -- 주민등록번호
  SEXDSTN_CODE char(1) ,  -- 성별코드
  BRTHDY char(20) ,  -- 생년월일
  FXNUM varchar(60) ,  -- 팩스
  HOUSE_ADRES varchar(300) ,  -- 자택주소
  PASSWORD_HINT varchar(300) NOT NULL,  -- 비밀번호 힌트
  PASSWORD_CNSR varchar(300) NOT NULL,  -- 비밀번호 정답
  HOUSE_END_TELNO varchar(12) ,  -- 자택전화 끝번호
  AREA_NO varchar(12) ,  -- 지역번호
  DETAIL_ADRES varchar(300) ,  -- 상세주소
  ZIP varchar(18) ,  -- 우편번호
  OFFM_TELNO varchar(60) ,  -- 사무실전화
  MBTLNUM varchar(60) ,  -- 휴대전화
  EMAIL_ADRES varchar(150) ,  -- 이메일
  OFCPS_NM varchar(180) ,  -- 직책명
  HOUSE_MIDDLE_TELNO varchar(12) ,  -- 자택전화 중간번호
  GROUP_ID char(20) ,  -- 그룹ID
  PSTINST_CODE char(8) ,  -- 소속기관코드
  EMPLYR_STTUS_CODE varchar(45) NOT NULL,  -- 사용자상태코드
  ESNTL_ID char(20) NOT NULL,  -- 고유ID
  CRTFC_DN_VALUE varchar(60) ,  -- 인증DN
  SBSCRB_DE DATETIME ,  -- 가입일시
  FRST_REGIST_PNTTM DATETIME ,  -- 최초등록시각
  FRST_REGISTER_ID varchar(60) ,  -- 최초등록자ID
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  CONSTRAINT TB_EMPLYR_INFO_PK PRIMARY KEY (EMPLYR_ID),
  CONSTRAINT TB_EMPLYR_INFO_ibfk_2 FOREIGN KEY (GROUP_ID) REFERENCES TB_AUTHOR_GROUP_INFO (GROUP_ID) ON DELETE CASCADE,
  CONSTRAINT TB_EMPLYR_INFO_ibfk_1 FOREIGN KEY (ORGNZT_ID) REFERENCES TB_ORGNZT_INFO (ORGNZT_ID) ON DELETE CASCADE
) ;

CREATE TABLE TB_EMPLYR_SCRTY_ESTBS (
  SCRTY_DTRMN_TRGET_ID VARCHAR(20) NOT NULL,  -- 보안결정대상ID(보통 사용자ID)
  MBER_TY_CODE         VARCHAR(15),  -- 회원유형코드
  AUTHOR_CODE          VARCHAR(30) NOT NULL,  -- 권한코드
  FRST_REGIST_PNTTM DATETIME ,  -- 최초등록시각
  FRST_REGISTER_ID varchar(60) ,  -- 최초등록자ID
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  CONSTRAINT TB_EMPLYR_SCRTY_ESTBS_PK PRIMARY KEY (SCRTY_DTRMN_TRGET_ID),
  CONSTRAINT TB_EMPLYR_SCRTY_ESTBS_ibfk_1 FOREIGN KEY (SCRTY_DTRMN_TRGET_ID) REFERENCES TB_EMPLYR_INFO(EMPLYR_ID),
  CONSTRAINT TB_EMPLYR_SCRTY_ESTBS_ibfk_2 FOREIGN KEY (AUTHOR_CODE) REFERENCES TB_AUTHOR_INFO(AUTHOR_CODE),
  CONSTRAINT TB_EMPLYR_SCRTY_ESTBS_ibfk_3 FOREIGN KEY (SCRTY_DTRMN_TRGET_ID) REFERENCES TB_ENTRPRS_MBER(ENTRPRS_MBER_ID),
  CONSTRAINT TB_EMPLYR_SCRTY_ESTBS_ibfk_4 FOREIGN KEY (SCRTY_DTRMN_TRGET_ID) REFERENCES TB_GNRL_MBER(MBER_ID)
);

CREATE TABLE TB_BBS_MASTER  (
  BBS_ID char(20) NOT NULL,  -- 게시판ID
  BBS_NM varchar(765) NOT NULL,  -- 게시판명
  BBS_INTRCN varchar(7200) ,  -- 게시판 소개
  BBS_TY_CODE char(6) NOT NULL,  -- 게시판 유형코드
  BBS_ATTRB_CODE char(6) NOT NULL,  -- 게시판 속성코드
  REPLY_POSBL_AT char(1) ,  -- 답글 가능(Y/N)
  FILE_ATCH_POSBL_AT char(1) NOT NULL,  -- 파일첨부 가능(Y/N)
  ATCH_POSBL_FILE_NUMBER numeric(2,0) NOT NULL,  -- 첨부가능 파일 수
  ATCH_POSBL_FILE_SIZE numeric(8,0) ,  -- 첨부가능 총 용량(단위: 시스템 정의)
  USE_AT char(1) NOT NULL,  -- 사용여부(Y/N)
  TMPLAT_ID char(20) ,  -- 템플릿ID
  FRST_REGISTER_ID varchar(60) NOT NULL,  -- 최초등록자ID
  FRST_REGIST_PNTTM DATETIME NOT NULL,  -- 최초등록시각
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  CONSTRAINT TB_BBS_MASTER_PK PRIMARY KEY (BBS_ID)
) ;

CREATE TABLE TB_BBS_USE  (
  BBS_ID char(20) NOT NULL,  -- 게시판ID
  TRGET_ID char(20) DEFAULT '' NOT NULL,  -- 사용대상ID
  USE_AT char(1) NOT NULL,  -- 사용여부(Y/N)
  REGIST_SE_CODE char(6) ,  -- 등록구분코드
  FRST_REGIST_PNTTM DATETIME ,  -- 최초등록시각
  FRST_REGISTER_ID varchar(60) NOT NULL,  -- 최초등록자ID
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  CONSTRAINT TB_BBS_USE_PK PRIMARY KEY (BBS_ID,TRGET_ID),
  CONSTRAINT TB_BBS_USE_ibfk_1 FOREIGN KEY (BBS_ID) REFERENCES TB_BBS_MASTER (BBS_ID)
) ;

CREATE TABLE TB_BBS (
  NTT_ID numeric(20,0) NOT NULL,  -- 게시물ID
  BBS_ID char(20) NOT NULL,  -- 게시판ID
  NTT_NO numeric(20,0) ,  -- 게시물 번호(정렬/표시용)
  NTT_SJ varchar(6000) ,  -- 제목
  NTT_CN STRING,  -- 내용
  ANSWER_AT char(1) ,  -- 답변글 여부(Y/N)
  PARNTSCTT_NO numeric(10,0) ,  -- 부모글 번호
  ANSWER_LC numeric(11) ,  -- 답변 계층(레벨)
  SORT_ORDR numeric(8,0) ,  -- 정렬순서
  RDCNT numeric(10,0) ,  -- 조회수
  USE_AT char(1) NOT NULL,  -- 사용여부(Y/N)
  NTCE_BGNDE char(20) ,  -- 공지 시작일시
  NTCE_ENDDE char(20) ,  -- 공지 종료일시
  NTCR_ID varchar(60) ,  -- 게시자ID
  NTCR_NM varchar(60) ,  -- 게시자명
  PASSWORD varchar(600) ,  -- 비밀번호(해시)
  ATCH_FILE_ID char(20) ,  -- 첨부파일 묶음ID
  FRST_REGIST_PNTTM DATETIME NOT NULL,  -- 최초등록시각
  FRST_REGISTER_ID varchar(60) NOT NULL,  -- 최초등록자ID
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  CONSTRAINT TB_BBS_PK PRIMARY KEY (NTT_ID,BBS_ID),
  CONSTRAINT TB_BBS_ibfk_1 FOREIGN KEY (BBS_ID) REFERENCES TB_BBS_MASTER (BBS_ID)
) ;

CREATE TABLE TB_BBS_MASTER_OPTN (
  BBS_ID char(20) DEFAULT '' NOT NULL,  -- 게시판ID
  ANSWER_AT char(1) DEFAULT '' NOT NULL,  -- 답변글 여부(Y/N)
  STSFDG_AT char(1) DEFAULT '' NOT NULL,  -- 만족도 조사 사용(Y/N)
  FRST_REGIST_PNTTM DATETIME DEFAULT SYSDATE NOT NULL,  -- 최초등록시각
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  FRST_REGISTER_ID varchar(60) DEFAULT '' NOT NULL,  -- 최초등록자ID
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  CONSTRAINT TB_BBS_MASTER_OPTN_PK PRIMARY KEY (BBS_ID)
) ;

CREATE TABLE TB_ENTRPRS_MBER (
  ENTRPRS_MBER_ID varchar(60) DEFAULT '' NOT NULL,  -- 기업회원ID
  ENTRPRS_SE_CODE char(15) ,  -- 기업구분코드
  BIZRNO varchar(30) ,  -- 사업자등록번호
  JURIRNO varchar(39) ,  -- 법인등록번호
  CMPNY_NM varchar(180) NOT NULL,  -- 회사명
  CXFC varchar(150) ,  -- 대표자명
  ZIP varchar(18) ,  -- 우편번호
  ADRES varchar(300) ,  -- 주소
  ENTRPRS_MIDDLE_TELNO varchar(12) ,  -- 전화 중간번호
  FXNUM varchar(60) ,  -- 팩스
  INDUTY_CODE char(15) ,  -- 업종코드
  APPLCNT_NM varchar(150) NOT NULL,  -- 신청자명
  APPLCNT_IHIDNUM varchar(39) ,  -- 신청자 주민등록번호
  SBSCRB_DE DATETIME ,  -- 가입일시
  ENTRPRS_MBER_STTUS varchar(45) ,  -- 회원상태코드
  ENTRPRS_MBER_PASSWORD varchar(600) NOT NULL,  -- 비밀번호(해시)
  ENTRPRS_MBER_PASSWORD_HINT varchar(300) NOT NULL,  -- 비밀번호 힌트
  ENTRPRS_MBER_PASSWORD_CNSR varchar(300) NOT NULL,  -- 비밀번호 정답
  GROUP_ID char(20) ,  -- 그룹ID
  DETAIL_ADRES varchar(300) ,  -- 상세주소
  ENTRPRS_END_TELNO varchar(12) ,  -- 전화 끝번호
  AREA_NO varchar(12) ,  -- 지역번호
  APPLCNT_EMAIL_ADRES varchar(150) ,  -- 신청자 이메일
  ESNTL_ID char(20) NOT NULL,  -- 고유ID
  FRST_REGIST_PNTTM DATETIME ,  -- 최초등록시각
  FRST_REGISTER_ID varchar(60) ,  -- 최초등록자ID
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  CONSTRAINT TB_ENTRPRS_MBER_PK PRIMARY KEY (ENTRPRS_MBER_ID),
  CONSTRAINT TB_ENTRPRS_MBER_ibfk_1 FOREIGN KEY (GROUP_ID) REFERENCES TB_AUTHOR_GROUP_INFO (GROUP_ID) ON DELETE CASCADE
) ;

CREATE TABLE TB_FILE (
  ATCH_FILE_ID char(20) NOT NULL,  -- 첨부파일 묶음ID
  CREAT_DT DATETIME NOT NULL,  -- 생성시각
  USE_AT char(1) ,  -- 사용여부(Y/N)
  FRST_REGIST_PNTTM DATETIME ,  -- 최초등록시각
  FRST_REGISTER_ID varchar(60) ,  -- 최초등록자ID
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  CONSTRAINT TB_FILE_PK PRIMARY KEY (ATCH_FILE_ID)
) ;

CREATE TABLE TB_FILE_DETAIL (
  ATCH_FILE_ID char(20) NOT NULL,  -- 첨부파일 묶음ID
  FILE_SN numeric(10,0) NOT NULL,  -- 파일 일련번호
  FILE_STRE_COURS varchar(6000) NOT NULL,  -- 파일 저장경로
  STRE_FILE_NM varchar(765) NOT NULL,  -- 저장파일명
  ORIGNL_FILE_NM varchar(765) ,  -- 원파일명
  FILE_EXTSN varchar(60) NOT NULL,  -- 파일확장자
  FILE_CN STRING,  -- 파일 내용/비고
  FILE_SIZE numeric(8,0) ,  -- 파일크기(Byte)
  FRST_REGIST_PNTTM DATETIME ,  -- 최초등록시각
  FRST_REGISTER_ID varchar(60) ,  -- 최초등록자ID
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  CONSTRAINT TB_FILE_DETAIL_PK PRIMARY KEY (ATCH_FILE_ID,FILE_SN),
  CONSTRAINT TB_FILE_DETAIL_ibfk_1 FOREIGN KEY (ATCH_FILE_ID) REFERENCES TB_FILE (ATCH_FILE_ID)
) ;

CREATE TABLE TB_GNRL_MBER (
  MBER_ID varchar(60) DEFAULT '' NOT NULL,  -- 회원ID
  PASSWORD varchar(600) NOT NULL,  -- 비밀번호(해시)
  PASSWORD_HINT varchar(300) NOT NULL,  -- 비밀번호 힌트
  PASSWORD_CNSR varchar(300) NOT NULL,  -- 비밀번호 정답
  IHIDNUM varchar(39) ,  -- 주민등록번호
  MBER_NM varchar(150) NOT NULL,  -- 회원명
  ZIP varchar(18) ,  -- 우편번호
  ADRES varchar(300) ,  -- 주소
  AREA_NO varchar(12) ,  -- 지역번호
  MBER_STTUS varchar(45) ,  -- 회원상태코드
  DETAIL_ADRES varchar(300) ,  -- 상세주소
  END_TELNO varchar(12) ,  -- 전화 끝번호
  MBTLNUM varchar(60) ,  -- 휴대전화
  GROUP_ID char(20) ,  -- 그룹ID
  MBER_FXNUM varchar(60) ,  -- 팩스번호
  MBER_EMAIL_ADRES varchar(150) ,  -- 이메일주소
  MIDDLE_TELNO varchar(12) ,  -- 전화 중간번호
  SBSCRB_DE DATETIME ,  -- 가입일시
  SEXDSTN_CODE char(1) ,  -- 성별코드
  ESNTL_ID char(20) NOT NULL,  -- 고유ID
  FRST_REGIST_PNTTM DATETIME ,  -- 최초등록시각
  FRST_REGISTER_ID varchar(60) ,  -- 최초등록자ID
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  CONSTRAINT TB_GNRL_MBER_PK PRIMARY KEY (MBER_ID),
  CONSTRAINT TB_GNRL_MBER_ibfk_1 FOREIGN KEY (GROUP_ID) REFERENCES TB_AUTHOR_GROUP_INFO (GROUP_ID) ON DELETE CASCADE
) ;

CREATE TABLE TB_SCHDUL_INFO (
  SCHDUL_ID char(20) NOT NULL,  -- 일정ID
  SCHDUL_SE char(1) ,  -- 일정구분코드
  SCHDUL_DEPT_ID varchar(60) ,  -- 부서ID
  SCHDUL_KND_CODE varchar(60) ,  -- 일정종류코드
  SCHDUL_BEGINDE char(40) ,  -- 시작일시
  SCHDUL_ENDDE char(40) ,  -- 종료일시
  SCHDUL_NM varchar(765) ,  -- 일정명
  SCHDUL_CN varchar(7500) ,  -- 일정 내용
  SCHDUL_PLACE varchar(765) ,  -- 장소
  SCHDUL_IPCR_CODE char(1) ,  -- 중요도코드
  SCHDUL_CHARGER_ID varchar(60) ,  -- 담당자ID
  ATCH_FILE_ID char(20) ,  -- 첨부파일 묶음ID
  FRST_REGIST_PNTTM DATETIME ,  -- 최초등록시각
  FRST_REGISTER_ID varchar(60) ,  -- 최초등록자ID
  LAST_UPDT_PNTTM DATETIME ,  -- 최종수정시각
  LAST_UPDUSR_ID varchar(60) ,  -- 최종수정자ID
  REPTIT_SE_CODE char(3) ,  -- 반복구분코드
  CONSTRAINT TB_SCHDUL_INFO_PK PRIMARY KEY (SCHDUL_ID)
) ;
CREATE OR REPLACE VIEW VW_USER_MASTER ( ESNTL_ID,USER_ID,PASSWORD,USER_NM,USER_ZIP,USER_ADRES,USER_EMAIL,GROUP_ID, USER_SE, ORGNZT_ID )
AS
        SELECT ESNTL_ID, MBER_ID,PASSWORD,MBER_NM,ZIP,ADRES,MBER_EMAIL_ADRES,' ','GNR' AS USER_SE, ' ' ORGNZT_ID
        FROM TB_GNRL_MBER
    UNION ALL
        SELECT ESNTL_ID,EMPLYR_ID,PASSWORD,USER_NM,ZIP,HOUSE_ADRES,EMAIL_ADRES,GROUP_ID ,'USR' AS USER_SE, ORGNZT_ID
        FROM TB_EMPLYR_INFO
    UNION ALL
        SELECT ESNTL_ID,ENTRPRS_MBER_ID,ENTRPRS_MBER_PASSWORD,CMPNY_NM,ZIP,ADRES,APPLCNT_EMAIL_ADRES,' ' ,'ENT' AS USER_SE, ' ' ORGNZT_ID
        FROM TB_ENTRPRS_MBER
;

-- 커뮤니티/동호회/약관/다이어리 (기능 유지 — 표준 TB_ 명명 + 감사컬럼)
DROP TABLE IF EXISTS TB_CMMNTY_USER;
DROP TABLE IF EXISTS TB_CLUB_USER;
DROP TABLE IF EXISTS TB_CMMNTY;
DROP TABLE IF EXISTS TB_CLUB;
DROP TABLE IF EXISTS TB_STPLAT_INFO;
DROP TABLE IF EXISTS TB_DIARY_INFO;
CREATE TABLE TB_CMMNTY (
  CMMNTY_ID varchar(20) NOT NULL,  -- 커뮤니티ID
  CMMNTY_NM varchar(180) ,  -- 커뮤니티명
  USE_AT char(1) ,  -- 사용여부(Y/N)
  FRST_REGIST_PNTTM DATETIME,  -- 최초등록시각
  FRST_REGISTER_ID  varchar(60),  -- 최초등록자ID
  LAST_UPDT_PNTTM   DATETIME,  -- 최종수정시각
  LAST_UPDUSR_ID    varchar(60),  -- 최종수정자ID
  CONSTRAINT TB_CMMNTY_PK PRIMARY KEY (CMMNTY_ID)
) ;
CREATE TABLE TB_CMMNTY_USER (
  ESNTL_ID varchar(20) NOT NULL,  -- 고유ID
  CMMNTY_ID varchar(20) ,  -- 커뮤니티ID
  EMPLYR_ID varchar(20) ,  -- 사용자ID
  MNGR_AT char(1) ,  -- 관리자 여부(Y/N)
  USE_AT char(1) ,  -- 사용여부(Y/N)
  REGIST_SE_CODE varchar(18) ,  -- 등록구분코드
  FRST_REGIST_PNTTM DATETIME,  -- 최초등록시각
  FRST_REGISTER_ID  varchar(60),  -- 최초등록자ID
  LAST_UPDT_PNTTM   DATETIME,  -- 최종수정시각
  LAST_UPDUSR_ID    varchar(60),  -- 최종수정자ID
  CONSTRAINT TB_CMMNTY_USER_PK PRIMARY KEY (ESNTL_ID)
) ;
CREATE TABLE TB_CLUB (
  CLB_ID varchar(20) NOT NULL,  -- 동호회ID
  CLB_NM varchar(180) ,  -- 동호회명
  USE_AT char(1) ,  -- 사용여부(Y/N)
  FRST_REGIST_PNTTM DATETIME,  -- 최초등록시각
  FRST_REGISTER_ID  varchar(60),  -- 최초등록자ID
  LAST_UPDT_PNTTM   DATETIME,  -- 최종수정시각
  LAST_UPDUSR_ID    varchar(60),  -- 최종수정자ID
  CONSTRAINT TB_CLUB_PK PRIMARY KEY (CLB_ID)
) ;
CREATE TABLE TB_CLUB_USER (
  ESNTL_ID varchar(20) NOT NULL,  -- 고유ID
  CLB_ID varchar(20) ,  -- 동호회ID
  EMPLYR_ID varchar(20) ,  -- 사용자ID
  OPRTR_AT char(1) ,  -- 운영자 여부(Y/N)
  USE_AT char(1) ,  -- 사용여부(Y/N)
  REGIST_SE_CODE varchar(18) ,  -- 등록구분코드
  FRST_REGIST_PNTTM DATETIME,  -- 최초등록시각
  FRST_REGISTER_ID  varchar(60),  -- 최초등록자ID
  LAST_UPDT_PNTTM   DATETIME,  -- 최종수정시각
  LAST_UPDUSR_ID    varchar(60),  -- 최종수정자ID
  CONSTRAINT TB_CLUB_USER_PK PRIMARY KEY (ESNTL_ID)
) ;
CREATE TABLE TB_STPLAT_INFO (
  USE_STPLAT_ID varchar(20) NOT NULL,  -- 이용약관ID
  USE_STPLAT_NM varchar(300) ,  -- 이용약관명
  USE_STPLAT_CN varchar(12000) ,  -- 이용약관 내용
  INFO_PROVD_AGRE_CN varchar(12000) ,  -- 정보제공 동의 내용
  FRST_REGIST_PNTTM DATETIME,  -- 최초등록시각
  FRST_REGISTER_ID  varchar(60),  -- 최초등록자ID
  LAST_UPDT_PNTTM   DATETIME,  -- 최종수정시각
  LAST_UPDUSR_ID    varchar(60),  -- 최종수정자ID
  CONSTRAINT TB_STPLAT_INFO_PK PRIMARY KEY (USE_STPLAT_ID)
) ;
CREATE TABLE TB_DIARY_INFO (
  DIARY_ID varchar(20) NOT NULL,  -- 다이어리ID
  SCHDUL_ID varchar(20) ,  -- 일정ID
  DIARY_CN varchar(7500) ,  -- 다이어리 내용
  FRST_REGIST_PNTTM DATETIME,  -- 최초등록시각
  FRST_REGISTER_ID  varchar(60),  -- 최초등록자ID
  LAST_UPDT_PNTTM   DATETIME,  -- 최종수정시각
  LAST_UPDUSR_ID    varchar(60),  -- 최종수정자ID
  CONSTRAINT TB_DIARY_INFO_PK PRIMARY KEY (DIARY_ID)
) ;

-- 개정이력: 2026.06.17  구재호  커뮤니티/동호회/약관/다이어리 TB_ 테이블 추가
