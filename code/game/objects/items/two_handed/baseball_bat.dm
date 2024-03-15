/obj/item/melee/baseball_bat
	name = "baseball bat"
	desc = "A traditional tool for a game of Baseball. Modern wood isn't very strong, try not to crack the bat!"
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "baseball_bat"
	item_state = "baseball_bat"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 16
	wound_bonus = 5
	armour_penetration = -30
	bare_wound_bonus = 40
	throwforce = 0
	attack_verb = list("beat", "smacked")
	sharpness = SHARP_NONE
	w_class = WEIGHT_CLASS_HUGE
	var/homerun_ready = FALSE
	var/homerun_able = FALSE
	var/flimsy = TRUE //spesswood? only used for knockback check now

/obj/item/melee/baseball_bat/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)
	AddComponent(/datum/component/cleave_attack, arc_size=90, requires_wielded=TRUE, no_multi_hit=TRUE)

/obj/item/melee/baseball_bat/homerun
	name = "home run bat"
	desc = "This thing looks dangerous... Dangerously good at baseball, that is."
	homerun_able = TRUE

/obj/item/melee/baseball_bat/attack_self(mob/user)
	if(!homerun_able)
		..()
		return
	if(homerun_ready)
		to_chat(user, span_notice("You're already ready to do a home run!"))
		return
	to_chat(user, span_warning("You begin gathering strength..."))
	playsound(get_turf(src), 'sound/magic/lightning_chargeup.ogg', 65, 1)
	if(do_after(user, 9 SECONDS, src))
		to_chat(user, span_userdanger("You gather power! Time for a home run!"))
		homerun_ready = 1
	return ..()

/obj/item/melee/baseball_bat/attack(mob/living/target, mob/living/user)
	. = ..()
	var/atom/throw_target = get_edge_target_turf(target, user.dir)
	if(target == user)
		return
	if(homerun_ready)
		user.visible_message(span_userdanger("It's a home run!"))
		target.throw_at(throw_target, rand(8,10), 14, user)
		SSexplosions.medturf += throw_target
		playsound(get_turf(src), 'sound/weapons/homerun.ogg', 100, 1)
		homerun_ready = 0
		return
	else if(!flimsy && !target.anchored)
		var/whack_speed = (prob(50) ? 1 : 6)
		target.throw_at(throw_target, rand(1, 2), whack_speed, user) // sorry friends, 7 speed batting caused wounds to absolutely delete whoever you knocked your target into (and said target)

/obj/item/melee/baseball_bat/metal_bat
	name = "titanium baseball bat"
	desc = "This bat is made of titanium, it feels light yet strong."
	icon_state = "baseball_bat_metal"
	item_state = "baseball_bat_metal"
	hitsound = 'yogstation/sound/weapons/bat_hit.ogg'
	force = 18
	throwforce = 0
	wound_bonus = 15
	armour_penetration = -25
	bare_wound_bonus = 50
	w_class = WEIGHT_CLASS_HUGE
	flimsy = FALSE

/obj/item/melee/baseball_bat/metal_bat/attack(mob/living/target, mob/living/user)
	. = ..()
	if(user.zone_selected == BODY_ZONE_HEAD && get_location_accessible(target, BODY_ZONE_HEAD))
		if(prob(30))
			target.Paralyze(40)
		else
			return TRUE
