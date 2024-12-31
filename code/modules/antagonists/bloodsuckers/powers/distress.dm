/datum/action/cooldown/spell/distress
	name = "Distress"
	desc = "Injure yourself, allowing you to make a desperate call for help to your Master."
	transparent_when_unavailable = TRUE
	buttontooltipstyle = "cult"

	background_icon = 'icons/mob/actions/actions_bloodsucker.dmi'
	background_icon_state = "vamp_power_off"
	button_icon = 'icons/mob/actions/actions_bloodsucker.dmi'
	button_icon_state = "power_distress"

	//power_explanation = "Distress:Use this Power from anywhere and your Master Bloodsucker will instantly be alerted of your location."
	check_flags = NONE
	resource_costs = list(ANTAG_RESOURCE_BLOODSUCKER = 10)
	cooldown_time = 10 SECONDS

/datum/action/cooldown/spell/distress/cast()
	. = ..()
	var/turf/open/floor/target_area = get_area(owner)
	var/datum/antagonist/vassal/vassaldatum = owner.mind.has_antag_datum(/datum/antagonist/vassal)

	to_chat(owner, "You call out for your master!")
	to_chat(vassaldatum.master.owner, span_userdanger("[owner], your loyal Vassal, is desperately calling for aid at [target_area]!"))

	var/mob/living/user = owner
	user.adjustBruteLoss(10)
