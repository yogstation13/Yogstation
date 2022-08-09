/datum/antagonist/thrall
	name = "Thrall"
	roundend_category = "other"
	antagpanel_category = "Paramount"
	var/datum/mind/master

/datum/antagonist/thrall/antag_panel_data()
	return "Master : [master.name]"

/datum/antagonist/thrall/on_gain()
	if(!master)
		return // Someone is playing with buttons they shouldn't be.
	..()
	var/datum/objective/obey = new
	obey.owner = owner
	obey.explanation_text = "Obey your master, [master.name], in all things."
	obey.completed = TRUE
	objectives |= obey

/datum/antagonist/thrall/greet()
	to_chat(owner, "<span class='danger'>Your mind is no longer solely your own, your will has been subjugated by that of [master.name]. Obey them in all things.</span>")
