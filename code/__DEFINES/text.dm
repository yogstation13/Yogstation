/// Prepares a text to be used for maptext. Use this so it doesn't look hideous.
#define MAPTEXT(text) {"<span class='maptext'>[##text]</span>"}

/// Prepares a text to be used for maptext, using a variable size font.
/// Variable size font. More flexible but doesn't scale pixel perfect to BYOND icon resolutions. (May be blurry.) Can use any size in pt or px.
#define MAPTEXT_VCR_OSD_MONO(text) {"<span style='font-family: \"VCR OSD Mono\"'>[##text]</span>"}

/// Prepares a text to be used for maptext using a pixel font. Cleaner but less size choices.
/// Standard size (ie: normal runechat) Use only sizing pt, multiples of 6: 6pt 12pt 18pt 24pt etc. - Not for use with px sizing
#define MAPTEXT_GRAND9K(text) {"<span style='font-family: \"Grand9K Pixel\"'>[##text]</span>"}

/// Prepares a text to be used for maptext using a pixel font. Cleaner but less size choices.
/// Small size. (ie: whisper runechat) Use only size pt, multiples of 12: 12pt 24pt 48pt etc. - Not for use with px sizing
#define MAPTEXT_TINY_UNICODE(text) {"<span style='font-family: \"TinyUnicode\"'>[##text]</span>"}

/// Macro from Lummox used to get height from a MeasureText proc.
/// resolves the MeasureText() return value once, then resolves the height, then sets return_var to that.
#define WXH_TO_HEIGHT(measurement, return_var) \
	do { \
		var/_measurement = measurement; \
		return_var = text2num(copytext(_measurement, findtextEx(_measurement, "x") + 1)); \
	} while(FALSE);

/*
 * Uses MAPTEXT to format antag points into a more appealing format
 */ 
#define ANTAG_MAPTEXT(value, color) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[color]'>[round(value)]</font></div>")
