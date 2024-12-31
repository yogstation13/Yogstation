#define UWUIFY_ACREPLACE_KEY	"uwuify"

/// uwuifies text, used by fluffy tongue quirk and the cyborg UwU-speak "upgrade"
/proc/uwuify_text(text)
	var/static/acreplace_setup = FALSE
	if(!acreplace_setup)
		//yeah i just precalculated all combinations
		rustg_setup_acreplace( \
			UWUIFY_ACREPLACE_KEY, \
			list( "ne",  "Ne",  "nE",  "NE",  "nu",  "Nu",  "nU",  "NU",  "na",  "Na",  "nA",  "NA",  "no",  "No",  "nO",  "NO", "ove", "Ove", "oVe", "OVe", "ovE", "OvE", "oVE", "OVE", "r", "R", "l", "L"), \
			list("nye", "Nye", "nYe", "NYe", "nyu", "Nyu", "nYu", "NYu", "nya", "Nya", "nYa", "NYa", "nyo", "Nyo", "nYo", "NYo",  "uv",  "Uv",  "uV",  "UV",  "uv",  "Uv",  "uV",  "UV", "w", "W", "w", "W") \
		)
		acreplace_setup = TRUE
	return rustg_acreplace(UWUIFY_ACREPLACE_KEY, "[text]")

#undef UWUIFY_ACREPLACE_KEY
