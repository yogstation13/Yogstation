/datum/controller/configuration
	var/list/lobby_notices

/datum/controller/configuration/proc/LoadMisc()
	load_important_notices()

/*
// JSON example of how lobby_notices.json works.

[
  "this notice will show in both the chatbox, and tgui. will do HTML like the others but using classes that are used in the chatbox will not show in tgui as they are separate",
  {
    "TGUI_SAFE": "This shows in tgui! <span style='font-size: 110%'>you can also use html! but not the classes used the chatbox, as said above</span>",
    "CHATBOX_SAFE": "This shows in tgui! <span class='bold red'>(with special formatting!)</span>."
  },
  {
    "TGUI_SAFE": [
      "this is the first line",
      "this is the second line. notice how this object doesn't have a chatbox_safe?",
      "that means it'll only show in Tgui"
    ]
  }
]

*/
/datum/controller/configuration/proc/load_important_notices()
	var/rawnotices = file2text("[directory]/lobby_notices.json")
	if(rawnotices)
		var/parsed = safe_json_decode(rawnotices)
		if(!parsed)
			log_config("JSON parsing failure for lobby_notices.json")
			DelayedMessageAdmins("JSON parsing failure for lobby_notices.json")
		else
			lobby_notices = parsed

/datum/controller/configuration/proc/ShowLobbyNotices(target)
	if (!config.lobby_notices) return FALSE
	var/final_notices = ""
	var/do_final_top_separator = FALSE
	for (var/notice as anything in config.lobby_notices)
		var/do_separator = FALSE
		if (islist(notice))
			var/list/_notice = notice
			if (_notice["CHATBOX_SAFE"])
				do_separator = TRUE
				final_notices = "[final_notices]<br>[_notice["CHATBOX_SAFE"]]"
		else
			final_notices = "[final_notices]<br>[notice]"
			do_separator = TRUE

		if (do_separator)
			do_final_top_separator = TRUE
			final_notices = "[final_notices]<hr class='solid'>"

	to_chat(target, "[do_final_top_separator ? "<hr class='solid'>" : ""][final_notices]")

	return TRUE
// I want to use this but i decided i didnt need to use it
/*
/proc/compare_dates(year1, month1, day1, year2, month2, day2)
		// TRUE if date1 >= date2, FALSE if date1 < date2
    var/comparable_date1 = year1 * 10000 + month1 * 100 + day1
    var/comparable_date2 = year2 * 10000 + month2 * 100 + day2

    return comparable_date1 >= comparable_date2
*/

/*  in some other proc
	var/cur_day = text2num(time2text(world.realtime, "DD", "PT"))
	var/cur_mon = text2num(time2text(world.realtime, "MM", "PT"))
	var/cur_year = text2num(time2text(world.realtime, "YYYY", "PT"))

	if (!compare_dates(cur_year, cur_mon, cur_day, 2025, 1, 15))
		motd = motd + "[motd]<br>" + ""
*/
