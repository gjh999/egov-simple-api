package egovframework.com.config;

import com.fasterxml.jackson.core.SerializableString;
import com.fasterxml.jackson.core.io.CharacterEscapes;
import com.fasterxml.jackson.core.io.SerializedString;

/**
 * JSON 응답에 XSS 방어용 escape 를 적용한다.
 *
 * <p>Jackson 은 문자마다 {@link #getEscapeSequence(int)} 를 물어보므로, 여기서 무엇을 바꿀지
 * <b>명시적으로</b> 정해야 한다. 예전에는 {@code StringEscapeUtils.escapeHtml4()} 를 그대로 돌려줬는데,
 * 그 함수는 HTML4 엔티티가 존재하는 <b>모든</b> 문자를 바꾼다 — 가운뎃점(·)은 {@code &middot;},
 * 줄표(—)는 {@code &mdash;} 가 되어 <b>화면에 엔티티 문자열이 그대로 보였다.</b>
 * (메시지 번들 한 벌에서만 60여 곳이 그렇게 나왔다.)</p>
 *
 * <p>그래서 스크립트 삽입에 실제로 쓰이는 문자만 바꾸고, 나머지는 {@code null} 을 돌려줘
 * Jackson 의 표준 JSON escape 에 맡긴다.</p>
 */
public class HtmlCharacterEscapes extends CharacterEscapes {

	private static final long serialVersionUID = -6353236148390563705L;

	private final int[] asciiEscapes;

	/** 바꿀 문자와 그 자리에 넣을 엔티티. 위 배열에 표시한 문자와 짝이 맞아야 한다. */
	private static final SerializedString LT = new SerializedString("&lt;");
	private static final SerializedString GT = new SerializedString("&gt;");
	private static final SerializedString QUOT = new SerializedString("&quot;");
	private static final SerializedString APOS = new SerializedString("&#39;");
	private static final SerializedString LPAREN = new SerializedString("&#40;");
	private static final SerializedString RPAREN = new SerializedString("&#41;");
	private static final SerializedString HASH = new SerializedString("&#35;");

	public HtmlCharacterEscapes() {
		this.asciiEscapes = CharacterEscapes.standardAsciiEscapesForJSON();
		this.asciiEscapes['<'] = CharacterEscapes.ESCAPE_CUSTOM;
		this.asciiEscapes['>'] = CharacterEscapes.ESCAPE_CUSTOM;
		this.asciiEscapes['\"'] = CharacterEscapes.ESCAPE_CUSTOM;
		this.asciiEscapes['('] = CharacterEscapes.ESCAPE_CUSTOM;
		this.asciiEscapes[')'] = CharacterEscapes.ESCAPE_CUSTOM;
		this.asciiEscapes['#'] = CharacterEscapes.ESCAPE_CUSTOM;
		this.asciiEscapes['\''] = CharacterEscapes.ESCAPE_CUSTOM;
	}

	@Override
	public int[] getEscapeCodesForAscii() {
		// 26.03.04 KISA 보안취약점 조치
		// private 배열의 복제본 반환 처리
		return asciiEscapes.clone();
	}

	@Override
	public SerializableString getEscapeSequence(int ch) {
		switch (ch) {
		case '<':
			return LT;
		case '>':
			return GT;
		case '\"':
			return QUOT;
		case '\'':
			return APOS;
		case '(':
			return LPAREN;
		case ')':
			return RPAREN;
		case '#':
			return HASH;
		default:
			// 위 목록 밖의 문자는 손대지 않는다 — 본문에 쓰이는 기호·문장부호가 엔티티로 바뀌지 않도록.
			return null;
		}
	}
}
