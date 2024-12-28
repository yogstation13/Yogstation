/obj/structure/blood_fountain
	name = "blood fountain"
	desc = "A huge resevoir of thick blood, perhaps drinking some of it would restore some vigor..."
	icon = 'monkestation/icons/obj/blood_fountain.dmi'
	icon_state = "blood_fountain"
	plane = ABOVE_GAME_PLANE
	anchored = TRUE
	density = TRUE
	bound_width = 64
	bound_height = 64
	resistance_flags = INDESTRUCTIBLE

/obj/structure/blood_fountain/Initialize(mapload)
	. = ..()
	add_overlay("droplet")

/obj/structure/blood_fountain/attackby(obj/item/bottle, mob/living/user, params)
	if(!istype(bottle, /obj/item/blood_vial))
		balloon_alert(user, "need a blood vial!")
		return ..()
	var/obj/item/blood_vial/vial = bottle
	vial.fill_vial(user)

/obj/item/blood_vial
	name = "blood vial"
	desc = "Used to collect samples of blood from the dead-still blood fountain."
	icon = 'monkestation/icons/obj/items/monster_hunter.dmi'
	base_icon_state = "blood_vial"
	icon_state = "blood_vial_empty"
	inhand_icon_state = "beaker"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	var/filled = FALSE ///does the bottle contain fluid

/obj/item/blood_vial/proc/fill_vial(mob/living/user)
	if(filled)
		balloon_alert(user, "vial already full!")
		return
	filled = TRUE
	update_appearance(UPDATE_ICON_STATE)

/obj/item/blood_vial/attack_self(mob/living/user)
	if(!filled)
		balloon_alert(user, "empty!")
		return
	filled = FALSE
	user.apply_status_effect(/datum/status_effect/cursed_blood)
	update_appearance(UPDATE_ICON_STATE)
	playsound(src, 'monkestation/sound/items/blood_vial_slurp.ogg', vol = 50)

/obj/item/blood_vial/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(proximity_flag && target == user)
		attack_self(user)
		. |= AFTERATTACK_PROCESSED_ITEM

/obj/item/blood_vial/update_icon_state()
	icon_state = "[base_icon_state][filled ? "" : "_empty"]"
	return ..()

/datum/status_effect/cursed_blood
	id = "cursed_blood"
	duration = 20 SECONDS
	tick_interval = 0.2 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/cursed_blood
	show_duration = TRUE
	processing_speed = STATUS_EFFECT_PRIORITY

/atom/movable/screen/alert/status_effect/cursed_blood
	name = "Cursed Blood"
	desc = "Something foreign is coursing through your veins!"
	icon_state = "blooddrunk"

/datum/status_effect/cursed_blood/on_apply()
	to_chat(owner, span_warning("You feel a great power surging through you!"))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/cursed_blood)
	return TRUE

/datum/status_effect/cursed_blood/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/cursed_blood)

/datum/status_effect/cursed_blood/tick(seconds_per_tick, times_fired)
	var/needs_update = FALSE
	if(ISINRANGE(owner.health, 0, 90))
		needs_update += owner.adjustBruteLoss(-2 * seconds_per_tick, updating_health = FALSE)
		needs_update += owner.adjustFireLoss(-2 * seconds_per_tick, updating_health = FALSE)
		needs_update += owner.adjustToxLoss(-1 * seconds_per_tick, updating_health = FALSE, forced = TRUE)
		needs_update += owner.adjustOxyLoss(-1 * seconds_per_tick, updating_health = FALSE)
	owner.AdjustAllImmobility((-6 SECONDS) * seconds_per_tick)
	owner.stamina.adjust(7 * seconds_per_tick, forced = TRUE)
	if(needs_update)
		owner.updatehealth()

/datum/movespeed_modifier/cursed_blood
	multiplicative_slowdown = -0.6
