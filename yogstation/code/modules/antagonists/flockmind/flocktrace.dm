/mob/camera/flocktrace
	name = "Flocktrace"
	real_name = "Flocktrace"
	desc = "Something like a digital pilot, capable of controling flockdrones."
	initial_language_holder = /datum/language_holder/flock
	icon = 'icons/mob/flock_mobs.dmi'
	icon_state = "flocktrace"
	faction = list("flock")
	hud_type = /datum/hud/flocktrace
	var/datum/flock_command/stored_action = null
	var/datum/action/cooldown/flock/enemi/enemy_designate
	var/datum/action/cooldown/flock/radio_talk/narrowbeam
	var/datum/action/cooldown/flock/talk/talkin

/mob/camera/flocktrace/Initialize()
	. = ..()
	var/obj/item/radio/headset/silicon/ai/radio = new(src)
	radio.wires.cut(WIRE_TX) 
	AddComponent(/datum/component/stationloving, FALSE, TRUE)
	grant_skills()
	if(!isflockmind(src))
		AddComponent(/datum/component/flock_compute, -100, TRUE) 

/mob/camera/flocktrace/proc/grant_skills()
	talkin = new
	talkin.Grant(src)
	enemy_designate = new
	enemy_designate.Grant(src)

/mob/camera/flocktrace/get_status_tab_items()
	. = ..()
	var/datum/team/flock/flock = get_flock_team(mind)
	. += "Unused Compute: [flock.get_compute(TRUE)]"
	. += "Total Compute: [flock.get_compute(FALSE)]"

/mob/camera/flocktrace/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat)
		return

	if (!message)
		return

	ping_flock(message, src)

/mob/camera/flocktrace/flockmind
	name = "Flockmind"
	real_name = "Flockmind"
	desc = "The overmind of the flock."
	icon_state = "flockmind"
	var/datum/action/cooldown/flock/ping/ping
	var/datum/action/cooldown/flock/flocktrace/partition
	var/datum/action/cooldown/flock/repair_burst/repair
	var/datum/action/cooldown/flock/door_open/gatecrash
	var/datum/action/cooldown/flock/radio_stun/radiostun
	var/datum/action/cooldown/flock/spawn_egg/rift/rift

/mob/camera/flocktrace/flockmind/New()
	. = ..()
	var/datum/team/flock/team = get_flock_team(mind)
	team.overmind = src

/mob/camera/flocktrace/flockmind/grant_skills()
	rift = new
	rift.Grant(src)

/mob/camera/flocktrace/flockmind/proc/actually_grant_skills()
	qdel(rift)
	talkin = new
	talkin.Grant(src)
	enemy_designate = new
	enemy_designate.Grant(src)
	ping = new
	ping.Grant(src)
	partition = new
	partition.Grant(src)
	repair = new
	repair.Grant(src)
	gatecrash = new
	gatecrash.Grant(src)
	radiostun = new
	radiostun.Grant(src)
	narrowbeam = new
	narrowbeam.Grant(src)
	var/datum/team/flock/flock = get_flock_team(mind)
	flock.acting = TRUE
	flock.update_flock_status(TRUE)