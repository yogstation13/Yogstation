/datum/status_effect/voided
	id = "Voided"
	duration = 10 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/obj/effect/immortality_talisman/v 

/datum/status_effect/voided/on_apply()
	. = ..()
	v = new /obj/effect/immortality_talisman/void(get_turf(owner), owner)
	v.vanish(owner)	

/datum/status_effect/voided/on_remove()
	. = ..()
	v.unvanish(owner)

/datum/status_effect/scent_hunter
	id = "smelly"
	duration = 20 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	
	///the person doing the tracking. but here's the
	var/mob/living/sniffer

	///the tracked target
	var/mob/living/sniffee

	var/scent_color = COLOR_RED
	
	var/datum/effect_system/trail_follow/scent/scent_trail

	var/datum/atom_hud/alternate_appearance/basic/scent_hunter/smell_hud

/datum/status_effect/scent_hunter/on_creation(mob/living/owner, mob/living/target, target_color)
	if(target)
		sniffee = target
	if(target_color)
		scent_color = sanitize_hexcolor(target_color, 6, TRUE, COLOR_RED)
	return ..()

/datum/status_effect/scent_hunter/on_apply()
	. = ..()
	sniffer = owner
	sniffer.add_client_colour(/datum/client_colour/monochrome)
	if(sniffee)	
		var/icon/temp = icon(sniffee.icon, sniffee.icon_state)
		var/image/scent_glow = image(temp, layer = ABOVE_MOB_LAYER, loc = sniffee)
		scent_glow.copy_overlays(sniffee)
		scent_glow.layer = HUD_LAYER
		scent_glow.plane = HUD_PLANE
		scent_glow.appearance_flags = NO_CLIENT_COLOR
		scent_glow.color = scent_color
		scent_glow.name = id
		smell_hud = sniffee.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/scent_hunter, id, scent_glow, FALSE)
		
		scent_trail = new()
		scent_trail.set_up(sniffee, owner, scent_color)
		scent_trail.start()

/datum/status_effect/scent_hunter/on_remove()
	sniffer.remove_client_colour(/datum/client_colour/monochrome)
	sniffer.remove_alt_appearance(id)
	if(sniffee)
		sniffee.remove_alt_appearance(id)
	if(scent_trail)
		scent_trail.Destroy()
	if(smell_hud)
		smell_hud.remove_hud_from(owner)
	if(sniffer?.client?.images)
		for(var/image/I in sniffer.client.images)
			if(I.name==id)
				sniffer.client.images -= I

/datum/status_effect/scent_hunter/blood
	id = "blood_smelly"

/datum/status_effect/bloodthirsty
	id = "bloodthirsty"
	duration = 1.5 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/bloodthirsty
	var/mob/living/thirster
	//that sweet blood sings to you and makes your screen reddish tinged
	var/atom/movable/screen/fullscreen/brute/red_thirst

/datum/status_effect/bloodthirsty/on_apply()
	. = ..()
	thirster = owner
	owner.add_movespeed_modifier(src, update=TRUE, priority=100, multiplicative_slowdown=-0.8, blacklisted_movetypes=(FLOATING))
	if(!red_thirst)
		red_thirst = owner.overlay_fullscreen("thirsting", /atom/movable/screen/fullscreen/brute, 4)
		red_thirst.alpha = 0
		red_thirst.layer = HUD_LAYER
		red_thirst.plane = HUD_PLANE
		animate(red_thirst, alpha = 255, time = 1 SECONDS, easing = EASE_IN) //fade IN
	to_chat(owner, span_userdanger("As the scent of your prey overwhelms your sense of smell, the thrill of the hunt empowers you!"))

/datum/status_effect/bloodthirsty/on_remove()
	owner.remove_movespeed_modifier(src)
	owner.clear_fullscreen("thirsting")

/atom/movable/screen/alert/status_effect/bloodthirsty
	icon = 'yogstation/icons/mob/screen_alert.dmi'
	icon_state = "default"
	name = "Bloodthirsty"
	desc = "You smell blood in the air."
	icon_state = "bloodthirsty"
