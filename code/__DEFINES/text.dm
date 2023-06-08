/// Prepares a text to be used for maptext. Use this so it doesn't look hideous.
#define MAPTEXT(text) {"<span class='maptext'>[##text]</span>"}

/// Macro from Lummox used to get height from a MeasureText proc
#define WXH_TO_HEIGHT(x) text2num(copytext(x, findtextEx(x, "x") + 1))

/*
 * Uses MAPTEXT to format antag points into a more appealing format
 */ 
#define ANTAG_MAPTEXT(value, color) MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[color]'>[round(value)]</font></div>")
