-- ============================================================
-- simple-home-boot HSQL DDL/DML (개발용 내장 HSQL 시드)
-- 테이블 명명규칙: TB_ + 기능명 (snake_case, 대문자). 뷰는 VW_.
-- 감사 컬럼: FRST_REGIST_PNTTM(최초등록시각), FRST_REGISTER_ID(최초등록자ID),
--           LAST_UPDT_PNTTM(최종수정시각), LAST_UPDUSR_ID(최종수정자ID)
--
-- 각 CREATE 문에는 [테이블 한글명 + 구(舊) 테이블명]과 컬럼별 한글 논리명을 주석으로 병기한다.
-- 구→신 테이블/컬럼 매핑 전체 정리: Docs/db-name-mapping.md, 컬럼 사전: Docs/db-schema-guide.md
-- (이 파일은 Spring EmbeddedDatabaseBuilder.addScript 로 실행 — '--' 주석/다중행 정상 처리)
-- ============================================================

DROP TABLE IF EXISTS TB_FILE_DETAIL CASCADE;
DROP TABLE IF EXISTS TB_FILE CASCADE;
DROP TABLE IF EXISTS TB_SCHDUL_INFO CASCADE;
DROP TABLE IF EXISTS TB_EMPLYR_SCRTY_ESTBS CASCADE;
DROP TABLE IF EXISTS TB_GNRL_MBER CASCADE;
DROP TABLE IF EXISTS TB_ENTRPRS_MBER CASCADE;
DROP TABLE IF EXISTS TB_EMPLYR_INFO_CHNG_DTLS CASCADE;
DROP TABLE IF EXISTS TB_EMPLYR_INFO CASCADE;
DROP TABLE IF EXISTS TB_ORGNZT_INFO CASCADE;
DROP TABLE IF EXISTS TB_BBS_USE CASCADE;
DROP TABLE IF EXISTS TB_BBS_MASTER_OPTN CASCADE;
DROP TABLE IF EXISTS TB_BBS CASCADE;
DROP TABLE IF EXISTS TB_BBS_MASTER CASCADE;
DROP TABLE IF EXISTS TB_CMMN_DETAIL_CODE CASCADE;
DROP TABLE IF EXISTS TB_CMMN_CODE CASCADE;
DROP TABLE IF EXISTS TB_CMMN_CL_CODE CASCADE;
DROP TABLE IF EXISTS TB_AUTHOR_GROUP_INFO CASCADE;
DROP TABLE IF EXISTS TB_AUTHOR_INFO CASCADE;
DROP TABLE IF EXISTS IDS CASCADE;
DROP TABLE IF EXISTS COMTECOPSEQ CASCADE;

-- IDS : 내장샘플 시퀀스
CREATE MEMORY TABLE IDS (
    TABLE_NAME VARCHAR(20) DEFAULT '' NOT NULL PRIMARY KEY,  -- 대상 테이블명
    NEXT_ID    NUMERIC(30) DEFAULT 0  NOT NULL               -- 다음 ID 값
);
-- COMTECOPSEQ : 범용 시퀀스
CREATE MEMORY TABLE COMTECOPSEQ (
    TABLE_NAME VARCHAR(20) DEFAULT '' NOT NULL PRIMARY KEY,  -- 대상 테이블명
    NEXT_ID    NUMERIC(30) DEFAULT 0  NOT NULL               -- 다음 ID 값
);
-- TB_CMMN_CL_CODE : 공통코드 대분류 (구: LETTCCMMNCLCODE)
CREATE MEMORY TABLE TB_CMMN_CL_CODE (
    CL_CODE           CHAR(3)      NOT NULL PRIMARY KEY,  -- 분류코드
    CL_CODE_NM        VARCHAR(60),                        -- 분류코드명
    CL_CODE_DC        VARCHAR(200),                       -- 분류코드 설명
    USE_AT            CHAR(1),                            -- 사용여부(Y/N)
    FRST_REGIST_PNTTM TIMESTAMP,                          -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20),                        -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,                          -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20)                         -- 최종수정자ID
);
-- TB_CMMN_CODE : 공통코드 중분류 (구: LETTCCMMNCODE)
CREATE MEMORY TABLE TB_CMMN_CODE (
    CODE_ID           VARCHAR(6)   NOT NULL PRIMARY KEY,  -- 코드ID
    CODE_ID_NM        VARCHAR(60),                        -- 코드ID명
    CODE_ID_DC        VARCHAR(200),                       -- 코드ID 설명
    USE_AT            CHAR(1),                            -- 사용여부(Y/N)
    CL_CODE           CHAR(3),                            -- 분류코드(FK→TB_CMMN_CL_CODE)
    FRST_REGIST_PNTTM TIMESTAMP,                          -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20),                        -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,                          -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20),                        -- 최종수정자ID
    CONSTRAINT FK_CMMN_CODE_CL FOREIGN KEY (CL_CODE) REFERENCES TB_CMMN_CL_CODE(CL_CODE)
);
-- TB_CMMN_DETAIL_CODE : 공통코드 소분류 (구: LETTCCMMNDETAILCODE) / 복합PK(CODE_ID, CODE)
CREATE MEMORY TABLE TB_CMMN_DETAIL_CODE (
    CODE_ID           VARCHAR(6)   NOT NULL,  -- 코드ID(FK→TB_CMMN_CODE)
    CODE              VARCHAR(15)  NOT NULL,  -- 상세코드
    CODE_NM           VARCHAR(60),            -- 상세코드명
    CODE_DC           VARCHAR(200),           -- 상세코드 설명
    USE_AT            CHAR(1),                -- 사용여부(Y/N)
    FRST_REGIST_PNTTM TIMESTAMP,              -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20),            -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,              -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20),            -- 최종수정자ID
    PRIMARY KEY(CODE_ID, CODE),
    CONSTRAINT FK_CMMN_DTL_CODE FOREIGN KEY(CODE_ID) REFERENCES TB_CMMN_CODE(CODE_ID)
);
-- TB_AUTHOR_INFO : 권한 (구: LETTNAUTHORINFO)
CREATE MEMORY TABLE TB_AUTHOR_INFO (
    AUTHOR_CODE       VARCHAR(30)  NOT NULL PRIMARY KEY,  -- 권한코드
    AUTHOR_NM         VARCHAR(60)  NOT NULL,              -- 권한명
    AUTHOR_DC         VARCHAR(200),                       -- 권한 설명
    AUTHOR_CREAT_DE   CHAR(20)     NOT NULL,              -- 생성일자
    FRST_REGIST_PNTTM TIMESTAMP,                          -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20),                        -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,                          -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20)                         -- 최종수정자ID
);
-- TB_AUTHOR_GROUP_INFO : 권한그룹 (구: LETTNAUTHORGROUPINFO)
CREATE MEMORY TABLE TB_AUTHOR_GROUP_INFO (
    GROUP_ID          CHAR(20)     DEFAULT '' NOT NULL PRIMARY KEY,  -- 그룹ID
    GROUP_NM          VARCHAR(60)  NOT NULL,                         -- 그룹명
    GROUP_CREAT_DE    CHAR(20)     NOT NULL,                         -- 생성일자
    GROUP_DC          VARCHAR(100),                                  -- 그룹 설명
    FRST_REGIST_PNTTM TIMESTAMP,                                     -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20),                                   -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,                                     -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20)                                    -- 최종수정자ID
);
-- TB_ORGNZT_INFO : 조직 (구: LETTNORGNZTINFO)
CREATE MEMORY TABLE TB_ORGNZT_INFO (
    ORGNZT_ID         CHAR(20)     DEFAULT '' NOT NULL PRIMARY KEY,  -- 조직ID
    ORGNZT_NM         VARCHAR(20)  NOT NULL,                         -- 조직명
    ORGNZT_DC         VARCHAR(100),                                  -- 조직 설명
    FRST_REGIST_PNTTM TIMESTAMP,                                     -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20),                                   -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,                                     -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20)                                    -- 최종수정자ID
);
-- TB_EMPLYR_INFO : 사용자/직원 (구: LETTNEMPLYRINFO)
CREATE MEMORY TABLE TB_EMPLYR_INFO (
    EMPLYR_ID          VARCHAR(20)  NOT NULL PRIMARY KEY,  -- 사용자ID
    ORGNZT_ID          CHAR(20),                           -- 조직ID
    USER_NM            VARCHAR(60)  NOT NULL,              -- 사용자명
    PASSWORD           VARCHAR(200) NOT NULL,              -- 비밀번호(해시)
    EMPL_NO            VARCHAR(20),                        -- 사번
    IHIDNUM            VARCHAR(13),                        -- 주민등록번호
    SEXDSTN_CODE       CHAR(1),                            -- 성별코드
    BRTHDY             CHAR(20),                           -- 생년월일
    FXNUM              VARCHAR(20),                        -- 팩스번호
    HOUSE_ADRES        VARCHAR(100),                       -- 자택주소
    PASSWORD_HINT      VARCHAR(100) NOT NULL,              -- 비밀번호 힌트
    PASSWORD_CNSR      VARCHAR(100) NOT NULL,              -- 비밀번호 정답
    HOUSE_END_TELNO    VARCHAR(4),                         -- 자택전화 끝번호
    AREA_NO            VARCHAR(4),                         -- 지역번호
    DETAIL_ADRES       VARCHAR(100),                       -- 상세주소
    ZIP                VARCHAR(6),                         -- 우편번호
    OFFM_TELNO         VARCHAR(20),                        -- 사무실전화
    MBTLNUM            VARCHAR(20),                        -- 휴대전화
    EMAIL_ADRES        VARCHAR(50),                        -- 이메일
    OFCPS_NM           VARCHAR(60),                        -- 직책명
    HOUSE_MIDDLE_TELNO VARCHAR(4),                         -- 자택전화 중간번호
    GROUP_ID           CHAR(20),                           -- 권한그룹ID(FK→TB_AUTHOR_GROUP_INFO)
    PSTINST_CODE       CHAR(8),                            -- 소속기관코드
    EMPLYR_STTUS_CODE  VARCHAR(15)  NOT NULL,              -- 사용자상태코드
    ESNTL_ID           CHAR(20)     NOT NULL,              -- 고유ID
    CRTFC_DN_VALUE     VARCHAR(20),                        -- 인증DN
    SBSCRB_DE          TIMESTAMP,                          -- 가입일시
    FRST_REGIST_PNTTM  TIMESTAMP,                          -- 최초등록시각
    FRST_REGISTER_ID   VARCHAR(20),                        -- 최초등록자ID
    LAST_UPDT_PNTTM    TIMESTAMP,                          -- 최종수정시각
    LAST_UPDUSR_ID     VARCHAR(20),                        -- 최종수정자ID
    CONSTRAINT FK_EMPLYR_GROUP FOREIGN KEY(GROUP_ID) REFERENCES TB_AUTHOR_GROUP_INFO(GROUP_ID) ON DELETE CASCADE
);
ALTER TABLE TB_EMPLYR_INFO ADD CONSTRAINT FK_EMPLYR_ORGNZT FOREIGN KEY(ORGNZT_ID) REFERENCES TB_ORGNZT_INFO(ORGNZT_ID);
-- TB_EMPLYR_INFO_CHNG_DTLS : 사용자 변경이력 (구: LETTHEMPLYRINFOCHANGEDTLS) / 복합PK(EMPLYR_ID, CHANGE_DE)
CREATE MEMORY TABLE TB_EMPLYR_INFO_CHNG_DTLS (
    EMPLYR_ID          VARCHAR(20)  NOT NULL,  -- 사용자ID
    CHANGE_DE          CHAR(20)     NOT NULL,  -- 변경일자
    ORGNZT_ID          CHAR(20),               -- 조직ID
    GROUP_ID           CHAR(20),               -- 그룹ID
    EMPL_NO            VARCHAR(20)  NOT NULL,  -- 사번
    SEXDSTN_CODE       CHAR(1),                -- 성별코드
    BRTHDY             CHAR(20),               -- 생년월일
    FXNUM              VARCHAR(20),            -- 팩스
    HOUSE_ADRES        VARCHAR(100) NOT NULL,  -- 자택주소
    HOUSE_END_TELNO    VARCHAR(4),             -- 자택전화 끝번호
    AREA_NO            VARCHAR(4),             -- 지역번호
    DETAIL_ADRES       VARCHAR(100) NOT NULL,  -- 상세주소
    ZIP                VARCHAR(6)   NOT NULL,  -- 우편번호
    OFFM_TELNO         VARCHAR(20),            -- 사무실전화
    MBTLNUM            VARCHAR(20)  NOT NULL,  -- 휴대전화
    EMAIL_ADRES        VARCHAR(50),            -- 이메일
    HOUSE_MIDDLE_TELNO VARCHAR(4),             -- 자택전화 중간번호
    PSTINST_CODE       CHAR(8),                -- 소속기관코드
    EMPLYR_STTUS_CODE  VARCHAR(15)  NOT NULL,  -- 사용자상태코드
    ESNTL_ID           CHAR(20),               -- 고유ID
    FRST_REGIST_PNTTM  TIMESTAMP,              -- 최초등록시각
    FRST_REGISTER_ID   VARCHAR(20),            -- 최초등록자ID
    LAST_UPDT_PNTTM    TIMESTAMP,              -- 최종수정시각
    LAST_UPDUSR_ID     VARCHAR(20),            -- 최종수정자ID
    PRIMARY KEY(EMPLYR_ID, CHANGE_DE),
    CONSTRAINT FK_CHNG_EMPLYR FOREIGN KEY(EMPLYR_ID) REFERENCES TB_EMPLYR_INFO(EMPLYR_ID)
);
-- TB_EMPLYR_SCRTY_ESTBS : 사용자-권한 매핑 (구: LETTNEMPLYRSCRTYESTBS)
CREATE MEMORY TABLE TB_EMPLYR_SCRTY_ESTBS (
    SCRTY_DTRMN_TRGET_ID VARCHAR(20) NOT NULL PRIMARY KEY,  -- 보안결정대상ID(보통 사용자ID)
    MBER_TY_CODE         VARCHAR(15),                        -- 회원유형코드
    AUTHOR_CODE          VARCHAR(30) NOT NULL,               -- 권한코드(FK→TB_AUTHOR_INFO)
    FRST_REGIST_PNTTM    TIMESTAMP,                          -- 최초등록시각
    FRST_REGISTER_ID     VARCHAR(20),                        -- 최초등록자ID
    LAST_UPDT_PNTTM      TIMESTAMP,                          -- 최종수정시각
    LAST_UPDUSR_ID       VARCHAR(20),                        -- 최종수정자ID
    CONSTRAINT FK_SCRTY_AUTHOR FOREIGN KEY(AUTHOR_CODE) REFERENCES TB_AUTHOR_INFO(AUTHOR_CODE)
);
-- TB_GNRL_MBER : 일반회원 (구: LETTNGNRLMBER)
CREATE MEMORY TABLE TB_GNRL_MBER (
    MBER_ID           VARCHAR(20)  DEFAULT '' NOT NULL PRIMARY KEY,  -- 회원ID
    PASSWORD          VARCHAR(200) NOT NULL,                         -- 비밀번호(해시)
    PASSWORD_HINT     VARCHAR(100),                                  -- 비밀번호 힌트
    PASSWORD_CNSR     VARCHAR(100),                                  -- 비밀번호 정답
    IHIDNUM           VARCHAR(13),                                   -- 주민등록번호
    MBER_NM           VARCHAR(50)  NOT NULL,                         -- 회원명
    ZIP               VARCHAR(6),                                    -- 우편번호
    ADRES             VARCHAR(100),                                  -- 주소
    AREA_NO           VARCHAR(4),                                    -- 지역번호
    MBER_STTUS        VARCHAR(15),                                   -- 회원상태코드
    DETAIL_ADRES      VARCHAR(100),                                  -- 상세주소
    END_TELNO         VARCHAR(4),                                    -- 전화 끝번호
    MBTLNUM           VARCHAR(20),                                   -- 휴대전화번호
    GROUP_ID          CHAR(20),                                      -- 권한그룹ID(FK→TB_AUTHOR_GROUP_INFO)
    MBER_FXNUM        VARCHAR(20),                                   -- 팩스번호
    MBER_EMAIL_ADRES  VARCHAR(50),                                   -- 이메일주소
    MIDDLE_TELNO      VARCHAR(4),                                    -- 전화 중간번호
    SBSCRB_DE         TIMESTAMP,                                     -- 가입일시
    SEXDSTN_CODE      CHAR(1),                                       -- 성별코드
    ESNTL_ID          CHAR(20)     NOT NULL,                         -- 고유ID
    FRST_REGIST_PNTTM TIMESTAMP,                                     -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20),                                   -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,                                     -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20),                                   -- 최종수정자ID
    CONSTRAINT FK_GNRL_GROUP FOREIGN KEY(GROUP_ID) REFERENCES TB_AUTHOR_GROUP_INFO(GROUP_ID) ON DELETE CASCADE
);
-- TB_ENTRPRS_MBER : 기업회원 (구: LETTNENTRPRSMBER)
CREATE MEMORY TABLE TB_ENTRPRS_MBER (
    ENTRPRS_MBER_ID            VARCHAR(20)  DEFAULT '' NOT NULL PRIMARY KEY,  -- 기업회원ID
    ENTRPRS_SE_CODE            CHAR(15),                                      -- 기업구분코드
    BIZRNO                     VARCHAR(10),                                   -- 사업자등록번호
    JURIRNO                    VARCHAR(13),                                   -- 법인등록번호
    CMPNY_NM                   VARCHAR(60)  NOT NULL,                         -- 회사명
    CXFC                       VARCHAR(50),                                   -- 대표자명
    ZIP                        VARCHAR(6),                                    -- 우편번호
    ADRES                      VARCHAR(100),                                  -- 주소
    ENTRPRS_MIDDLE_TELNO       VARCHAR(4),                                    -- 전화 중간번호
    FXNUM                      VARCHAR(20),                                   -- 팩스번호
    INDUTY_CODE                CHAR(15),                                      -- 업종코드
    APPLCNT_NM                 VARCHAR(50)  NOT NULL,                         -- 신청자명
    APPLCNT_IHIDNUM            VARCHAR(13),                                   -- 신청자 주민등록번호
    SBSCRB_DE                  TIMESTAMP,                                     -- 가입일시
    ENTRPRS_MBER_STTUS         VARCHAR(15),                                   -- 회원상태코드
    ENTRPRS_MBER_PASSWORD      VARCHAR(200),                                  -- 비밀번호(해시)
    ENTRPRS_MBER_PASSWORD_HINT VARCHAR(100) NOT NULL,                         -- 비밀번호 힌트
    ENTRPRS_MBER_PASSWORD_CNSR VARCHAR(100) NOT NULL,                         -- 비밀번호 정답
    GROUP_ID                   CHAR(20),                                      -- 권한그룹ID(FK→TB_AUTHOR_GROUP_INFO)
    DETAIL_ADRES               VARCHAR(100),                                  -- 상세주소
    ENTRPRS_END_TELNO          VARCHAR(4),                                    -- 전화 끝번호
    AREA_NO                    VARCHAR(4),                                    -- 지역번호
    APPLCNT_EMAIL_ADRES        VARCHAR(50),                                   -- 신청자 이메일
    ESNTL_ID                   CHAR(20)     NOT NULL,                         -- 고유ID
    FRST_REGIST_PNTTM          TIMESTAMP,                                     -- 최초등록시각
    FRST_REGISTER_ID           VARCHAR(20),                                   -- 최초등록자ID
    LAST_UPDT_PNTTM            TIMESTAMP,                                     -- 최종수정시각
    LAST_UPDUSR_ID             VARCHAR(20),                                   -- 최종수정자ID
    CONSTRAINT FK_ENTRPRS_GROUP FOREIGN KEY(GROUP_ID) REFERENCES TB_AUTHOR_GROUP_INFO(GROUP_ID) ON DELETE CASCADE
);
-- 사용자-권한 매핑(TB_EMPLYR_SCRTY_ESTBS)의 보안결정대상ID → 3개 회원유형 테이블 FK
ALTER TABLE TB_EMPLYR_SCRTY_ESTBS ADD CONSTRAINT FK_SCRTY_EMPLYR FOREIGN KEY(SCRTY_DTRMN_TRGET_ID) REFERENCES TB_EMPLYR_INFO(EMPLYR_ID);
ALTER TABLE TB_EMPLYR_SCRTY_ESTBS ADD CONSTRAINT FK_SCRTY_ENTRPRS FOREIGN KEY(SCRTY_DTRMN_TRGET_ID) REFERENCES TB_ENTRPRS_MBER(ENTRPRS_MBER_ID);
ALTER TABLE TB_EMPLYR_SCRTY_ESTBS ADD CONSTRAINT FK_SCRTY_GNRL FOREIGN KEY(SCRTY_DTRMN_TRGET_ID) REFERENCES TB_GNRL_MBER(MBER_ID);
-- TB_BBS_MASTER : 게시판 마스터 (구: LETTNBBSMASTER)
CREATE MEMORY TABLE TB_BBS_MASTER (
    BBS_ID                 CHAR(20)      NOT NULL PRIMARY KEY,  -- 게시판ID
    BBS_NM                 VARCHAR(255)  NOT NULL,              -- 게시판명
    BBS_INTRCN             VARCHAR(2400),                       -- 게시판 소개
    BBS_TY_CODE            CHAR(6)       NOT NULL,              -- 게시판 유형코드
    BBS_ATTRB_CODE         CHAR(6)       NOT NULL,              -- 게시판 속성코드
    REPLY_POSBL_AT         CHAR(1),                             -- 답글 가능(Y/N)
    FILE_ATCH_POSBL_AT     CHAR(1)       NOT NULL,              -- 파일첨부 가능(Y/N)
    ATCH_POSBL_FILE_NUMBER NUMERIC(2)    NOT NULL,              -- 첨부가능 파일 수
    ATCH_POSBL_FILE_SIZE   NUMERIC(8),                          -- 첨부가능 총 용량
    USE_AT                 CHAR(1)       NOT NULL,              -- 사용여부(Y/N)
    TMPLAT_ID              CHAR(20),                            -- 템플릿ID
    FRST_REGIST_PNTTM      TIMESTAMP     NOT NULL,              -- 최초등록시각
    FRST_REGISTER_ID       VARCHAR(20)   NOT NULL,              -- 최초등록자ID
    LAST_UPDT_PNTTM        TIMESTAMP,                           -- 최종수정시각
    LAST_UPDUSR_ID         VARCHAR(20)                          -- 최종수정자ID
);
-- TB_BBS_MASTER_OPTN : 게시판 옵션 (구: LETTNBBSMASTEROPTN)
CREATE MEMORY TABLE TB_BBS_MASTER_OPTN (
    BBS_ID            CHAR(20)     DEFAULT '' NOT NULL PRIMARY KEY,            -- 게시판ID
    ANSWER_AT         CHAR(1)      DEFAULT '' NOT NULL,                        -- 답변 기능 사용(Y/N)
    STSFDG_AT         CHAR(1)      DEFAULT '' NOT NULL,                        -- 만족도 조사 사용(Y/N)
    FRST_REGIST_PNTTM TIMESTAMP    DEFAULT '1970-01-01 00:00:00.0' NOT NULL,  -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20)  DEFAULT '' NOT NULL,                        -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,                                               -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20)                                             -- 최종수정자ID
);
-- TB_BBS_USE : 게시판 사용대상 (구: LETTNBBSUSE) / 복합PK(BBS_ID, TRGET_ID)
CREATE MEMORY TABLE TB_BBS_USE (
    BBS_ID            CHAR(20)     NOT NULL,             -- 게시판ID(FK→TB_BBS_MASTER)
    TRGET_ID          CHAR(20)     DEFAULT '' NOT NULL,  -- 사용대상ID
    USE_AT            CHAR(1)      NOT NULL,             -- 사용여부(Y/N)
    REGIST_SE_CODE    CHAR(6),                           -- 등록구분코드
    FRST_REGIST_PNTTM TIMESTAMP,                         -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20)  NOT NULL,             -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,                         -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20),                       -- 최종수정자ID
    PRIMARY KEY(BBS_ID, TRGET_ID),
    CONSTRAINT FK_BBS_USE_MASTER FOREIGN KEY(BBS_ID) REFERENCES TB_BBS_MASTER(BBS_ID)
);
-- TB_BBS : 게시물 (구: LETTNBBS) / 복합PK(NTT_ID, BBS_ID)
CREATE MEMORY TABLE TB_BBS (
    NTT_ID            NUMERIC(20)   NOT NULL,  -- 게시물ID
    BBS_ID            CHAR(20)      NOT NULL,  -- 게시판ID(FK→TB_BBS_MASTER)
    NTT_NO            NUMERIC(20),             -- 게시물 번호(정렬/표시용)
    NTT_SJ            VARCHAR(2000),           -- 제목
    NTT_CN            LONGVARCHAR,             -- 내용
    ANSWER_AT         CHAR(1),                 -- 답변글 여부(Y/N)
    PARNTSCTT_NO      NUMERIC(10),             -- 부모글 번호
    ANSWER_LC         INTEGER,                 -- 답변 계층(레벨)
    SORT_ORDR         NUMERIC(8),              -- 정렬순서
    RDCNT             NUMERIC(10),             -- 조회수
    USE_AT            CHAR(1)       NOT NULL,  -- 사용여부(Y/N)
    NTCE_BGNDE        CHAR(20),                -- 공지 시작일시
    NTCE_ENDDE        CHAR(20),                -- 공지 종료일시
    NTCR_ID           VARCHAR(20),             -- 게시자ID
    NTCR_NM           VARCHAR(20),             -- 게시자명
    PASSWORD          VARCHAR(200),            -- 글 비밀번호(옵션)
    ATCH_FILE_ID      CHAR(20),                -- 첨부파일 묶음ID
    FRST_REGIST_PNTTM TIMESTAMP     NOT NULL,  -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20)   NOT NULL,  -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,               -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20),             -- 최종수정자ID
    PRIMARY KEY(NTT_ID, BBS_ID),
    CONSTRAINT FK_BBS_MASTER FOREIGN KEY(BBS_ID) REFERENCES TB_BBS_MASTER(BBS_ID)
);
-- TB_FILE : 첨부파일 묶음 헤더 (구: LETTNFILE)
CREATE MEMORY TABLE TB_FILE (
    ATCH_FILE_ID      CHAR(20)     NOT NULL PRIMARY KEY,  -- 첨부파일ID(묶음)
    CREAT_DT          TIMESTAMP    NOT NULL,              -- 생성시각
    USE_AT            CHAR(1),                            -- 사용여부(Y/N)
    FRST_REGIST_PNTTM TIMESTAMP,                          -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20),                        -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,                          -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20)                         -- 최종수정자ID
);
-- TB_FILE_DETAIL : 첨부파일 상세 (구: LETTNFILEDETAIL) / 복합PK(ATCH_FILE_ID, FILE_SN)
CREATE MEMORY TABLE TB_FILE_DETAIL (
    ATCH_FILE_ID      CHAR(20)      NOT NULL,  -- 첨부파일ID(묶음, FK→TB_FILE)
    FILE_SN           NUMERIC(10)   NOT NULL,  -- 파일 일련번호
    FILE_STRE_COURS   VARCHAR(2000) NOT NULL,  -- 파일 저장경로
    STRE_FILE_NM      VARCHAR(255)  NOT NULL,  -- 저장파일명
    ORIGNL_FILE_NM    VARCHAR(255),            -- 원파일명
    FILE_EXTSN        VARCHAR(20)   NOT NULL,  -- 파일확장자
    FILE_CN           LONGVARCHAR,             -- 파일 내용/비고
    FILE_SIZE         NUMERIC(8),              -- 파일크기(Byte)
    FRST_REGIST_PNTTM TIMESTAMP,               -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20),             -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,               -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20),             -- 최종수정자ID
    PRIMARY KEY(ATCH_FILE_ID, FILE_SN),
    CONSTRAINT FK_FILE_DETAIL FOREIGN KEY(ATCH_FILE_ID) REFERENCES TB_FILE(ATCH_FILE_ID)
);
-- TB_SCHDUL_INFO : 일정 (구: LETTNSCHDULINFO)
CREATE MEMORY TABLE TB_SCHDUL_INFO (
    SCHDUL_ID         CHAR(20)      NOT NULL PRIMARY KEY,  -- 일정ID
    SCHDUL_SE         CHAR(1),                             -- 일정구분코드
    SCHDUL_DEPT_ID    VARCHAR(20),                         -- 부서ID
    SCHDUL_KND_CODE   VARCHAR(20),                         -- 일정종류코드
    SCHDUL_BEGINDE    TIMESTAMP,                           -- 시작일시
    SCHDUL_ENDDE      TIMESTAMP,                           -- 종료일시
    SCHDUL_NM         VARCHAR(255),                        -- 일정명
    SCHDUL_CN         VARCHAR(2500),                       -- 일정 내용
    SCHDUL_PLACE      VARCHAR(255),                        -- 장소
    SCHDUL_IPCR_CODE  CHAR(1),                             -- 중요도코드
    SCHDUL_CHARGER_ID VARCHAR(20),                         -- 담당자ID
    ATCH_FILE_ID      CHAR(20),                            -- 첨부파일ID(묶음)
    REPTIT_SE_CODE    CHAR(3),                             -- 반복구분코드
    FRST_REGIST_PNTTM TIMESTAMP,                           -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20),                         -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,                           -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20)                          -- 최종수정자ID
);
-- VW_USER_MASTER : 사용자 통합 뷰 (구: COMVNUSERMASTER) — 일반회원/직원/기업회원 UNION
--   컬럼: ESNTL_ID(고유ID), USER_ID(사용자ID), PASSWORD(비밀번호), USER_NM(사용자명),
--         USER_ZIP(우편번호), USER_ADRES(주소), USER_EMAIL(이메일), GROUP_ID(권한그룹ID),
--         USER_SE(사용자구분: GNR/USR/ENT), ORGNZT_ID(조직ID)
CREATE VIEW VW_USER_MASTER (ESNTL_ID, USER_ID, PASSWORD, USER_NM, USER_ZIP, USER_ADRES, USER_EMAIL, GROUP_ID, USER_SE, ORGNZT_ID) AS SELECT ESNTL_ID, MBER_ID, PASSWORD, MBER_NM, ZIP, ADRES, MBER_EMAIL_ADRES, ' ', 'GNR', ' ' FROM TB_GNRL_MBER UNION ALL SELECT ESNTL_ID, EMPLYR_ID, PASSWORD, USER_NM, ZIP, HOUSE_ADRES, EMAIL_ADRES, GROUP_ID, 'USR', ORGNZT_ID FROM TB_EMPLYR_INFO UNION ALL SELECT ESNTL_ID, ENTRPRS_MBER_ID, ENTRPRS_MBER_PASSWORD, CMPNY_NM, ZIP, ADRES, APPLCNT_EMAIL_ADRES, ' ', 'ENT', ' ' FROM TB_ENTRPRS_MBER;

SET WRITE_DELAY 20;
SET SCHEMA PUBLIC;

-- [DML] 시퀀스 시드 — IDS/COMTECOPSEQ (TABLE_NAME 대상테이블명, NEXT_ID 다음ID값)
INSERT INTO IDS (TABLE_NAME, NEXT_ID) VALUES ('BBS_ID', 1);
INSERT INTO IDS (TABLE_NAME, NEXT_ID) VALUES ('FILE_ID', 1);
INSERT INTO IDS (TABLE_NAME, NEXT_ID) VALUES ('SAMPLE', 1);
INSERT INTO IDS (TABLE_NAME, NEXT_ID) VALUES ('SCHDUL_ID', 1);
INSERT INTO IDS (TABLE_NAME, NEXT_ID) VALUES ('TMPLAT_ID', 1);
INSERT INTO COMTECOPSEQ (TABLE_NAME, NEXT_ID) VALUES ('USRCNFRM_ID', 20);

-- [DML] TB_CMMN_CL_CODE 공통코드 대분류
--   컬럼순서: CL_CODE(분류코드), CL_CODE_NM(분류코드명), CL_CODE_DC(분류코드설명), USE_AT(사용여부),
--            FRST_REGIST_PNTTM(최초등록시각), FRST_REGISTER_ID(최초등록자ID), LAST_UPDT_PNTTM(최종수정시각), LAST_UPDUSR_ID(최종수정자ID)
INSERT INTO TB_CMMN_CL_CODE (CL_CODE, CL_CODE_NM, CL_CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('LET', '전자정부 프레임워크 경량환경 템플릿', '전자정부 프레임워크 경량환경 템플릿', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
-- [DML] TB_CMMN_CODE 공통코드 중분류
--   컬럼순서: CODE_ID(코드ID), CODE_ID_NM(코드ID명), CODE_ID_DC(코드ID설명), USE_AT(사용여부), CL_CODE(분류코드), 감사컬럼4종
INSERT INTO TB_CMMN_CODE (CODE_ID, CODE_ID_NM, CODE_ID_DC, USE_AT, CL_CODE, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM001', '등록구분', '게시판, 커뮤니티, 동호회 등록구분코드', 'Y', 'LET', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_CODE (CODE_ID, CODE_ID_NM, CODE_ID_DC, USE_AT, CL_CODE, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM003', '업무구분', '업무구분코드', 'Y', 'LET', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_CODE (CODE_ID, CODE_ID_NM, CODE_ID_DC, USE_AT, CL_CODE, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM004', '게시판유형', '게시판유형구분코드', 'Y', 'LET', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_CODE (CODE_ID, CODE_ID_NM, CODE_ID_DC, USE_AT, CL_CODE, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM005', '템플릿유형', '템플릿유형구분코드', 'Y', 'LET', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_CODE (CODE_ID, CODE_ID_NM, CODE_ID_DC, USE_AT, CL_CODE, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM009', '게시판속성', '게시판 속성', 'Y', 'LET', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_CODE (CODE_ID, CODE_ID_NM, CODE_ID_DC, USE_AT, CL_CODE, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM019', '일정중요도', '일정중요도 낮음/보통/높음 상태구분', 'Y', 'LET', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_CODE (CODE_ID, CODE_ID_NM, CODE_ID_DC, USE_AT, CL_CODE, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM030', '일정구분', '일정구분 코드', 'Y', 'LET', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_CODE (CODE_ID, CODE_ID_NM, CODE_ID_DC, USE_AT, CL_CODE, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM031', '반복구분', '일정 반복구분 코드', 'Y', 'LET', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
-- [DML] TB_CMMN_DETAIL_CODE 공통코드 소분류
--   컬럼순서: CODE_ID(코드ID), CODE(상세코드), CODE_NM(상세코드명), CODE_DC(상세코드설명), USE_AT(사용여부), 감사컬럼4종
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM001', 'REGC01', '단일 게시판 이용등록', '단일 게시판 이용등록', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM001', 'REGC07', '게시판사용자등록', '게시판사용자등록', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM003', 'BBS', '게시판', '게시판', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM004', 'BBST01', '일반게시판', '일반게시판', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM004', 'BBST02', '익명게시판', '익명게시판', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM004', 'BBST03', '공지게시판', '공지게시판', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM004', 'BBST04', '방명록', '방명록', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM005', 'TMPT01', '게시판템플릿', '게시판템플릿', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM009', 'BBSA01', '유효게시판', '유효게시판', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM009', 'BBSA02', '갤러리', '갤러리', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM009', 'BBSA03', '일반게시판', '일반게시판', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM019', 'A', '높음', '높음', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM019', 'B', '보통', '보통', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM019', 'C', '낮음', '낮음', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM030', '1', '회의', '회의', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM030', '2', '세미나', '세미나', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM030', '3', '강의', '강의', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM030', '4', '교육', '교육', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM030', '5', '기타', '기타', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM031', '1', '당일', '당일', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM031', '2', '반복', '반복', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM031', '3', '연속', '연속', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_CMMN_DETAIL_CODE (CODE_ID, CODE, CODE_NM, CODE_DC, USE_AT, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('COM031', '4', '요일반복', '요일반복', 'Y', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');

-- [DML] TB_ORGNZT_INFO 조직 (ORGNZT_ID 조직ID, ORGNZT_NM 조직명, ORGNZT_DC 조직설명, 감사컬럼4종)
INSERT INTO TB_ORGNZT_INFO (ORGNZT_ID, ORGNZT_NM, ORGNZT_DC, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('ORGNZT_0000000000000', '기본조직', '기본조직', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
-- [DML] TB_AUTHOR_GROUP_INFO 권한그룹 (GROUP_ID 그룹ID, GROUP_NM 그룹명, GROUP_CREAT_DE 생성일자, GROUP_DC 그룹설명, 감사컬럼4종)
INSERT INTO TB_AUTHOR_GROUP_INFO (GROUP_ID, GROUP_NM, GROUP_CREAT_DE, GROUP_DC, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('GROUP_00000000000000', 'ROLE_ADMIN', '2024-07-31', '관리자 그룹입니다', '2024-07-31 00:00:00.000000000', 'SYSTEM', '2024-07-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_AUTHOR_GROUP_INFO (GROUP_ID, GROUP_NM, GROUP_CREAT_DE, GROUP_DC, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('GROUP_00000000000001', 'ROLE_USER', '2024-07-31', '사용자 그룹입니다', '2024-07-31 00:00:00.000000000', 'SYSTEM', '2024-07-31 00:00:00.000000000', 'SYSTEM');

-- [DML] TB_EMPLYR_INFO 사용자/직원 (관리자 admin, 사용자 user — 컬럼명은 INSERT에 명시됨)
INSERT INTO TB_EMPLYR_INFO (EMPLYR_ID, ORGNZT_ID, USER_NM, PASSWORD, EMPL_NO, IHIDNUM, SEXDSTN_CODE, BRTHDY, FXNUM, HOUSE_ADRES, PASSWORD_HINT, PASSWORD_CNSR, HOUSE_END_TELNO, AREA_NO, DETAIL_ADRES, ZIP, OFFM_TELNO, MBTLNUM, EMAIL_ADRES, OFCPS_NM, HOUSE_MIDDLE_TELNO, GROUP_ID, PSTINST_CODE, EMPLYR_STTUS_CODE, ESNTL_ID, CRTFC_DN_VALUE, SBSCRB_DE, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('admin', 'ORGNZT_0000000000000', '관리자', 'Igeuuo4cojVU07mlpQKvrnEvq+5YsCN7YChFXwDKG7M=', '', '', 'F', '', '', '관리자 주소', '', '', '', '', '', '', '', '', '', '', '', 'GROUP_00000000000000', '00000000', 'P', 'USRCNFRM_00000000000', '', '2011-08-31 00:00:00.000000000', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');
INSERT INTO TB_EMPLYR_INFO (EMPLYR_ID, ORGNZT_ID, USER_NM, PASSWORD, EMPL_NO, IHIDNUM, SEXDSTN_CODE, BRTHDY, FXNUM, HOUSE_ADRES, PASSWORD_HINT, PASSWORD_CNSR, HOUSE_END_TELNO, AREA_NO, DETAIL_ADRES, ZIP, OFFM_TELNO, MBTLNUM, EMAIL_ADRES, OFCPS_NM, HOUSE_MIDDLE_TELNO, GROUP_ID, PSTINST_CODE, EMPLYR_STTUS_CODE, ESNTL_ID, CRTFC_DN_VALUE, SBSCRB_DE, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('user', 'ORGNZT_0000000000000', '사용자', 'rTozi2u1iWZ8AikX9o06EtgDVxXtwNV7Eb600ai5Amk=', '', '', 'F', '', '', '사용자 주소', '', '', '', '', '', '', '', '', '', '', '', 'GROUP_00000000000001', '00000000', 'P', 'USRCNFRM_00000000001', '', '2011-08-31 00:00:00.000000000', '2011-08-31 00:00:00.000000000', 'SYSTEM', '2011-08-31 00:00:00.000000000', 'SYSTEM');

-- [DML] TB_BBS_MASTER 게시판 마스터
--   컬럼순서: BBS_ID(게시판ID), BBS_NM(게시판명), BBS_INTRCN(게시판소개), BBS_TY_CODE(유형코드), BBS_ATTRB_CODE(속성코드),
--            REPLY_POSBL_AT(답글가능), FILE_ATCH_POSBL_AT(파일첨부가능), ATCH_POSBL_FILE_NUMBER(첨부가능수), ATCH_POSBL_FILE_SIZE(첨부가능용량),
--            USE_AT(사용여부), TMPLAT_ID(템플릿ID), 감사컬럼4종
INSERT INTO TB_BBS_MASTER (BBS_ID, BBS_NM, BBS_INTRCN, BBS_TY_CODE, BBS_ATTRB_CODE, REPLY_POSBL_AT, FILE_ATCH_POSBL_AT, ATCH_POSBL_FILE_NUMBER, ATCH_POSBL_FILE_SIZE, USE_AT, TMPLAT_ID, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('BBSMSTR_AAAAAAAAAAAA', '공지사항', '공지사항게시판', 'BBST03', 'BBSA03', 'Y', 'Y', 2, 5242880, 'Y', 'TMPLAT_BOARD_DEFAULT', '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000', '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000');
INSERT INTO TB_BBS_MASTER (BBS_ID, BBS_NM, BBS_INTRCN, BBS_TY_CODE, BBS_ATTRB_CODE, REPLY_POSBL_AT, FILE_ATCH_POSBL_AT, ATCH_POSBL_FILE_NUMBER, ATCH_POSBL_FILE_SIZE, USE_AT, TMPLAT_ID, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('BBSMSTR_BBBBBBBBBBBB', '갤러리', '갤러리게시판', 'BBST01', 'BBSA02', 'Y', 'Y', 2, 5242880, 'Y', 'TMPLAT_BOARD_DEFAULT', '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000', '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000');
INSERT INTO TB_BBS_MASTER (BBS_ID, BBS_NM, BBS_INTRCN, BBS_TY_CODE, BBS_ATTRB_CODE, REPLY_POSBL_AT, FILE_ATCH_POSBL_AT, ATCH_POSBL_FILE_NUMBER, ATCH_POSBL_FILE_SIZE, USE_AT, TMPLAT_ID, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('BBSMSTR_CCCCCCCCCCCC', '자료실', '자료실게시판', 'BBST01', 'BBSA03', 'Y', 'Y', 2, 5242880, 'Y', 'TMPLAT_BOARD_DEFAULT', '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000', '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000');

-- [DML] TB_BBS_USE 게시판 사용대상
--   컬럼순서: BBS_ID(게시판ID), TRGET_ID(사용대상ID), USE_AT(사용여부), REGIST_SE_CODE(등록구분코드), 감사컬럼4종
INSERT INTO TB_BBS_USE (BBS_ID, TRGET_ID, USE_AT, REGIST_SE_CODE, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('BBSMSTR_AAAAAAAAAAAA', 'SYSTEM_DEFAULT_BOARD', 'Y', 'REGC01', '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000', '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000');
INSERT INTO TB_BBS_USE (BBS_ID, TRGET_ID, USE_AT, REGIST_SE_CODE, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('BBSMSTR_BBBBBBBBBBBB', 'SYSTEM_DEFAULT_BOARD', 'Y', 'REGC01', '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000', '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000');
INSERT INTO TB_BBS_USE (BBS_ID, TRGET_ID, USE_AT, REGIST_SE_CODE, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES ('BBSMSTR_CCCCCCCCCCCC', 'SYSTEM_DEFAULT_BOARD', 'Y', 'REGC01', '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000', '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000');

-- [DML] TB_BBS 게시물 (샘플 공지/게시물 — 컬럼명은 INSERT에 명시됨)
INSERT INTO TB_BBS (NTT_ID, BBS_ID, NTT_NO, NTT_SJ, NTT_CN, ANSWER_AT, PARNTSCTT_NO, ANSWER_LC, SORT_ORDR, RDCNT, USE_AT, NTCE_BGNDE, NTCE_ENDDE, NTCR_ID, NTCR_NM, PASSWORD, ATCH_FILE_ID, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES (1, 'BBSMSTR_AAAAAAAAAAAA', 1, '홈페이지 샘플공지1', '홈페이지 샘플공지1', 'N', 0, 0, 2, 0, 'Y', '10000101', '99991231', '', '', '', null, '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000', null, null);
INSERT INTO TB_BBS (NTT_ID, BBS_ID, NTT_NO, NTT_SJ, NTT_CN, ANSWER_AT, PARNTSCTT_NO, ANSWER_LC, SORT_ORDR, RDCNT, USE_AT, NTCE_BGNDE, NTCE_ENDDE, NTCR_ID, NTCR_NM, PASSWORD, ATCH_FILE_ID, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES (2, 'BBSMSTR_AAAAAAAAAAAA', 2, '홈페이지 샘플공지2', '홈페이지 샘플공지2', 'N', 0, 0, 2, 0, 'Y', '10000101', '99991231', '', '', '', null, '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000', null, null);
INSERT INTO TB_BBS (NTT_ID, BBS_ID, NTT_NO, NTT_SJ, NTT_CN, ANSWER_AT, PARNTSCTT_NO, ANSWER_LC, SORT_ORDR, RDCNT, USE_AT, NTCE_BGNDE, NTCE_ENDDE, NTCR_ID, NTCR_NM, PASSWORD, ATCH_FILE_ID, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES (3, 'BBSMSTR_AAAAAAAAAAAA', 3, '홈페이지 샘플공지3', '홈페이지 샘플공지3', 'N', 0, 0, 2, 0, 'Y', '10000101', '99991231', '', '', '', null, '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000', null, null);
INSERT INTO TB_BBS (NTT_ID, BBS_ID, NTT_NO, NTT_SJ, NTT_CN, ANSWER_AT, PARNTSCTT_NO, ANSWER_LC, SORT_ORDR, RDCNT, USE_AT, NTCE_BGNDE, NTCE_ENDDE, NTCR_ID, NTCR_NM, PASSWORD, ATCH_FILE_ID, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES (4, 'BBSMSTR_AAAAAAAAAAAA', 4, '홈페이지 샘플공지4', '홈페이지 샘플공지4', 'N', 0, 0, 2, 0, 'Y', '10000101', '99991231', '', '', '', null, '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000', null, null);
INSERT INTO TB_BBS (NTT_ID, BBS_ID, NTT_NO, NTT_SJ, NTT_CN, ANSWER_AT, PARNTSCTT_NO, ANSWER_LC, SORT_ORDR, RDCNT, USE_AT, NTCE_BGNDE, NTCE_ENDDE, NTCR_ID, NTCR_NM, PASSWORD, ATCH_FILE_ID, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES (5, 'BBSMSTR_AAAAAAAAAAAA', 5, '홈페이지 샘플공지5', '홈페이지 샘플공지5', 'N', 0, 0, 2, 0, 'Y', '10000101', '99991231', '', '', '', null, '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000', null, null);
INSERT INTO TB_BBS (NTT_ID, BBS_ID, NTT_NO, NTT_SJ, NTT_CN, ANSWER_AT, PARNTSCTT_NO, ANSWER_LC, SORT_ORDR, RDCNT, USE_AT, NTCE_BGNDE, NTCE_ENDDE, NTCR_ID, NTCR_NM, PASSWORD, ATCH_FILE_ID, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES (6, 'BBSMSTR_BBBBBBBBBBBB', 1, '홈페이지 샘플게시1', '홈페이지 샘플게시1', 'N', 0, 0, 2, 0, 'Y', '10000101', '99991231', '', '', '', null, '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000', null, null);
INSERT INTO TB_BBS (NTT_ID, BBS_ID, NTT_NO, NTT_SJ, NTT_CN, ANSWER_AT, PARNTSCTT_NO, ANSWER_LC, SORT_ORDR, RDCNT, USE_AT, NTCE_BGNDE, NTCE_ENDDE, NTCR_ID, NTCR_NM, PASSWORD, ATCH_FILE_ID, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES (7, 'BBSMSTR_BBBBBBBBBBBB', 2, '홈페이지 샘플게시2', '홈페이지 샘플게시2', 'N', 0, 0, 2, 0, 'Y', '10000101', '99991231', '', '', '', null, '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000', null, null);
INSERT INTO TB_BBS (NTT_ID, BBS_ID, NTT_NO, NTT_SJ, NTT_CN, ANSWER_AT, PARNTSCTT_NO, ANSWER_LC, SORT_ORDR, RDCNT, USE_AT, NTCE_BGNDE, NTCE_ENDDE, NTCR_ID, NTCR_NM, PASSWORD, ATCH_FILE_ID, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES (8, 'BBSMSTR_BBBBBBBBBBBB', 3, '홈페이지 샘플게시3', '홈페이지 샘플게시3', 'N', 0, 0, 2, 0, 'Y', '10000101', '99991231', '', '', '', null, '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000', null, null);
INSERT INTO TB_BBS (NTT_ID, BBS_ID, NTT_NO, NTT_SJ, NTT_CN, ANSWER_AT, PARNTSCTT_NO, ANSWER_LC, SORT_ORDR, RDCNT, USE_AT, NTCE_BGNDE, NTCE_ENDDE, NTCR_ID, NTCR_NM, PASSWORD, ATCH_FILE_ID, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES (9, 'BBSMSTR_BBBBBBBBBBBB', 4, '홈페이지 샘플게시4', '홈페이지 샘플게시4', 'N', 0, 0, 2, 0, 'Y', '10000101', '99991231', '', '', '', null, '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000', null, null);
INSERT INTO TB_BBS (NTT_ID, BBS_ID, NTT_NO, NTT_SJ, NTT_CN, ANSWER_AT, PARNTSCTT_NO, ANSWER_LC, SORT_ORDR, RDCNT, USE_AT, NTCE_BGNDE, NTCE_ENDDE, NTCR_ID, NTCR_NM, PASSWORD, ATCH_FILE_ID, FRST_REGIST_PNTTM, FRST_REGISTER_ID, LAST_UPDT_PNTTM, LAST_UPDUSR_ID) VALUES (10, 'BBSMSTR_BBBBBBBBBBBB', 5, '홈페이지 샘플게시5', '홈페이지 샘플게시5', 'N', 0, 0, 2, 0, 'Y', '10000101', '99991231', '', '', '', null, '2011-08-31 12:00:00.000000000', 'USRCNFRM_00000000000', null, null);

-- ============================================================
-- 커뮤니티/동호회/약관/다이어리 (기능 유지 — 표준 TB_ 명명 + 감사컬럼)
-- ============================================================
DROP TABLE IF EXISTS TB_CMMNTY_USER CASCADE;
DROP TABLE IF EXISTS TB_CLUB_USER CASCADE;
DROP TABLE IF EXISTS TB_CMMNTY CASCADE;
DROP TABLE IF EXISTS TB_CLUB CASCADE;
DROP TABLE IF EXISTS TB_STPLAT_INFO CASCADE;
DROP TABLE IF EXISTS TB_DIARY_INFO CASCADE;
-- TB_CMMNTY : 커뮤니티 (구: LETTNCMMNTY)
CREATE MEMORY TABLE TB_CMMNTY (
    CMMNTY_ID         VARCHAR(20)  NOT NULL PRIMARY KEY,  -- 커뮤니티ID
    CMMNTY_NM         VARCHAR(60),                        -- 커뮤니티명
    USE_AT            CHAR(1),                            -- 사용여부(Y/N)
    FRST_REGIST_PNTTM TIMESTAMP,                          -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20),                        -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,                          -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20)                         -- 최종수정자ID
);
-- TB_CMMNTY_USER : 커뮤니티 사용자 (구: LETTNCMMNTYUSER)
CREATE MEMORY TABLE TB_CMMNTY_USER (
    ESNTL_ID          VARCHAR(20)  NOT NULL PRIMARY KEY,  -- 고유ID
    CMMNTY_ID         VARCHAR(20),                        -- 커뮤니티ID
    EMPLYR_ID         VARCHAR(20),                        -- 사용자ID
    MNGR_AT           CHAR(1),                            -- 관리자 여부(Y/N)
    USE_AT            CHAR(1),                            -- 사용여부(Y/N)
    REGIST_SE_CODE    VARCHAR(6),                         -- 등록구분코드
    FRST_REGIST_PNTTM TIMESTAMP,                          -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20),                        -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,                          -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20)                         -- 최종수정자ID
);
-- TB_CLUB : 동호회 (구: LETTNCLUB)
CREATE MEMORY TABLE TB_CLUB (
    CLB_ID            VARCHAR(20)  NOT NULL PRIMARY KEY,  -- 동호회ID
    CLB_NM            VARCHAR(60),                        -- 동호회명
    USE_AT            CHAR(1),                            -- 사용여부(Y/N)
    FRST_REGIST_PNTTM TIMESTAMP,                          -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20),                        -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,                          -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20)                         -- 최종수정자ID
);
-- TB_CLUB_USER : 동호회 사용자 (구: LETTNCLUBUSER)
CREATE MEMORY TABLE TB_CLUB_USER (
    ESNTL_ID          VARCHAR(20)  NOT NULL PRIMARY KEY,  -- 고유ID
    CLB_ID            VARCHAR(20),                        -- 동호회ID
    EMPLYR_ID         VARCHAR(20),                        -- 사용자ID
    OPRTR_AT          CHAR(1),                            -- 운영자 여부(Y/N)
    USE_AT            CHAR(1),                            -- 사용여부(Y/N)
    REGIST_SE_CODE    VARCHAR(6),                         -- 등록구분코드
    FRST_REGIST_PNTTM TIMESTAMP,                          -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20),                        -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,                          -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20)                         -- 최종수정자ID
);
-- TB_STPLAT_INFO : 이용약관 (구: LETTNSTPLATINFO)
CREATE MEMORY TABLE TB_STPLAT_INFO (
    USE_STPLAT_ID      VARCHAR(20)   NOT NULL PRIMARY KEY,  -- 이용약관ID
    USE_STPLAT_NM      VARCHAR(100),                        -- 이용약관명
    USE_STPLAT_CN      VARCHAR(4000),                       -- 이용약관 내용
    INFO_PROVD_AGRE_CN VARCHAR(4000),                       -- 정보제공 동의 내용
    FRST_REGIST_PNTTM  TIMESTAMP,                           -- 최초등록시각
    FRST_REGISTER_ID   VARCHAR(20),                         -- 최초등록자ID
    LAST_UPDT_PNTTM    TIMESTAMP,                           -- 최종수정시각
    LAST_UPDUSR_ID     VARCHAR(20)                          -- 최종수정자ID
);
-- TB_DIARY_INFO : 일정 다이어리 (구: LETTNDIARYINFO)
CREATE MEMORY TABLE TB_DIARY_INFO (
    DIARY_ID          VARCHAR(20)   NOT NULL PRIMARY KEY,  -- 다이어리ID
    SCHDUL_ID         VARCHAR(20),                         -- 일정ID
    DIARY_CN          VARCHAR(2500),                       -- 다이어리 내용
    FRST_REGIST_PNTTM TIMESTAMP,                           -- 최초등록시각
    FRST_REGISTER_ID  VARCHAR(20),                         -- 최초등록자ID
    LAST_UPDT_PNTTM   TIMESTAMP,                           -- 최종수정시각
    LAST_UPDUSR_ID    VARCHAR(20)                          -- 최종수정자ID
);

-- 개정이력: 2026.06.17  구재호  커뮤니티/동호회/약관/다이어리 TB_ 테이블 추가
