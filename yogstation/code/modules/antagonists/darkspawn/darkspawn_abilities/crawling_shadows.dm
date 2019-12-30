//Assumes a stealthier form for sixty seconds or until cancelled.
/datum/action/innate/darkspawn/crawling_shadows
	name = "Crawling Shadows"
	id = "crawling_shadows"
	desc = "Assumes a shadowy form for a minute that can crawl through vents and squeeze through the cracks in doors. You can also knock people out by attacking them."
	button_icon_state = "crawling_shadows"
	check_flags = AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	psi_cost = 60
	lucidity_price = 2 //probably going to replace creep with this

/datum/action/innate/darkspawn/crawling_shadows/IsAvailable()
	var/mob/living/L = owner
	if(L.has_status_effect(STATUS_EFFECT_TAGALONG))
		return
	return ..()

/datum/action/innate/darkspawn/crawling_shadows/Activate()
	owner.visible_message("<span class='warning'>[owner] falls to the ground and transforms into a shadowy creature!</span>", "<span class='velvet bold'>sa iahz sepd zwng</span>\n\
	<span class='notice'>You assume a stealthier form.</span>")
	playsound(owner, 'yogstation/sound/magic/devour_will_end.ogg', 50, 1)
	var/mob/living/simple_animal/hostile/crawling_shadows/CS = new /mob/living/simple_animal/hostile/crawling_shadows(get_turf(owner))
	CS.darkspawn_mob = owner
	return TRUE
