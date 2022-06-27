//Generic system for picking up mobs.
//Currently works for head and hands.
//Currently uses the head.dmi for head icons, same should apply for other parts you may put your pet on.
/obj/item/clothing/mob_holder
	name = "bugged mob"
	desc = "Yell at coderbrush."
	icon = null
	icon_state = ""
	slot_flags = null
	alternate_worn_layer = ABOVE_BODY_FRONT_LAYER
	var/mob/living/held_mob
	var/destroying = FALSE

/obj/item/clothing/mob_holder/Initialize(mapload, mob/living/M, worn_state, held_icon, lh_icon, rh_icon, clothing_layer, weight, worn_slot_flags = null)
	. = ..()
	if(weight > MOB_SIZE_SMALL)
		w_class = weight + 2 // rough conversion
	if(lh_icon)
		lefthand_file = lh_icon
	if(rh_icon)	
		righthand_file = rh_icon
	if(worn_slot_flags)
		slot_flags = worn_slot_flags
	deposit(M)

/obj/item/clothing/mob_holder/Destroy()
	destroying = TRUE
	if(held_mob)
		release(FALSE)
	return ..()

/obj/item/clothing/mob_holder/dropped()
	. = ..()
	if(held_mob && isturf(loc))
		release()

/obj/item/clothing/mob_holder/proc/deposit(mob/living/L)
	if(!istype(L))
		return FALSE
	if(iscarbon(L))
		ADD_TRAIT(L, TRAIT_NOBREATH, HOLDER_TRAIT) //so monkeys don't die
	L.setDir(SOUTH)
	update_visuals(L)
	held_mob = L
	L.forceMove(src)
	name = L.name
	desc = L.desc
	return TRUE

/obj/item/clothing/mob_holder/proc/update_visuals(mob/living/L)
	appearance = L.appearance

/obj/item/clothing/mob_holder/proc/release(del_on_release = TRUE)
	if(!held_mob)
		if(del_on_release && !destroying)
			qdel(src)
		return FALSE
	if(isliving(loc))
		var/mob/living/L = loc
		L.visible_message(span_warning("[held_mob] wriggles free!"))
		L.dropItemToGround(src)
	else
		held_mob.visible_message(span_warning("[held_mob] wriggles free!"))
	if(HAS_TRAIT_FROM(held_mob, TRAIT_NOBREATH, HOLDER_TRAIT) && iscarbon(held_mob))
		REMOVE_TRAIT(held_mob, TRAIT_NOBREATH, HOLDER_TRAIT)
	held_mob.forceMove(get_turf(held_mob))
	held_mob.reset_perspective()
	held_mob.setDir(SOUTH)
	held_mob = null
	if(del_on_release && !destroying)
		qdel(src)
	return TRUE

/obj/item/clothing/mob_holder/relaymove(mob/user)
	release()

/obj/item/clothing/mob_holder/container_resist()
	release()

/obj/item/clothing/mob_holder/pre_attack(atom/A, mob/living/user, params)
	if(isobj(A) && ismachinery(A))
		if(istype(A, /obj/machinery/deepfryer))
			to_chat(user, span_warning("You wouldn't deepfry [name]....."))
		return
	. = ..()

/obj/item/clothing/mob_holder/drone/deposit(mob/living/L)
	. = ..()
	if(!isdrone(L))
		qdel(src)
	name = "drone (hiding)"
	desc = "This drone is scared and has curled up into a ball!"

/obj/item/clothing/mob_holder/drone/update_visuals(mob/living/L)
	var/mob/living/simple_animal/drone/D = L
	if(!D)
		return ..()
	icon = 'icons/mob/drone.dmi'
	icon_state = "[D.visualAppearence]_hat"

/obj/item/clothing/mob_holder/cheese/release(del_on_release = TRUE)
	if(!held_mob)
		if(del_on_release && !destroying)
			qdel(src)
		return FALSE
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, span_warning("[held_mob] cheeses free!"))
		L.dropItemToGround(src)
	held_mob.forceMove(get_turf(held_mob))
	held_mob.reset_perspective()
	held_mob.setDir(SOUTH)
	held_mob = null
	if(del_on_release && !destroying)
		qdel(src)
	return TRUE
