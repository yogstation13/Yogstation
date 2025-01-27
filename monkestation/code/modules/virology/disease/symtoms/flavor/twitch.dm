
/datum/symptom/twitch
	name = "Twitcher"
	desc = "Causes the infected to twitch."
	stage = 1
	badness = EFFECT_DANGER_FLAVOR
	severity = 1

/datum/symptom/twitch/activate(mob/living/mob)
	mob.emote("twitch")
