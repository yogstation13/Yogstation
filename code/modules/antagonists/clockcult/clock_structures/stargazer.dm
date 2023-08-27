//==================================//
// !      Stargazer     ! //
//==================================//
/datum/clockwork_scripture/create_object/construct/stargazer
	descname = "Structure, Stargazer"
	name = "Stargazer"
	desc = "Allows you to enchant your weapons and armor, however enchanting can have risky side effects."
	usage_tip = "Make your gear more powerful by enchanting them with stargazers."
	power_cost = 600
	channel_time  = 8 SECONDS
	invocations = list("A light of Engine shall empower my armaments!")
	object_path = /obj/structure/destructible/clockwork/stargazer
	one_per_tile = TRUE
	primary_component = HIEROPHANT_ANSIBLE
	tier = SCRIPTURE_SCRIPT

//Stargazer light

/obj/effect/stargazer_light
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "stargazer_closed"
	pixel_y = 10
	layer = FLY_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 160
	var/active_timer

/obj/effect/stargazer_light/ex_act()
	return

/obj/effect/stargazer_light/Destroy(force)
	cancel_timer()
	. = ..()

/obj/effect/stargazer_light/proc/finish_opening()
	icon_state = "stargazer_light"
	active_timer = null

/obj/effect/stargazer_light/proc/finish_closing()
	icon_state = "stargazer_closed"
	active_timer = null

/obj/effect/stargazer_light/proc/open()
	icon_state = "stargazer_opening"
	cancel_timer()
	active_timer = addtimer(CALLBACK(src, PROC_REF(finish_opening)), 2, TIMER_STOPPABLE | TIMER_UNIQUE)

/obj/effect/stargazer_light/proc/close()
	icon_state = "stargazer_closing"
	cancel_timer()
	active_timer = addtimer(CALLBACK(src, PROC_REF(finish_closing)), 2, TIMER_STOPPABLE | TIMER_UNIQUE)

/obj/effect/stargazer_light/proc/cancel_timer()
	if(active_timer)
		deltimer(active_timer)

#define STARGAZER_COOLDOWN 1800

//Stargazer structure
/obj/structure/destructible/clockwork/stargazer
	name = "stargazer"
	desc = "A small pedestal, glowing with a divine energy."
	clockwork_desc = "A small pedestal, glowing with a divine energy. Used to provide special powers and abilities to items."
	icon_state = "stargazer"
	anchored = TRUE
	break_message = "<span class='warning'>The stargazer collapses.</span>"
	var/cooldowntime = 0
	var/mobs_in_range = FALSE
	var/fading = FALSE
	var/obj/effect/stargazer_light/sg_light

/obj/structure/destructible/clockwork/stargazer/Initialize(mapload)
	. = ..()
	sg_light = new(get_turf(src))
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/clockwork/stargazer/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(!QDELETED(sg_light))
		qdel(sg_light)
	. = ..()

/obj/structure/destructible/clockwork/stargazer/process()
	if(QDELETED(sg_light))
		return
	var/mob_nearby = FALSE
	for(var/mob/living/M in view(2, get_turf(src)))
		if(is_servant_of_ratvar(M))
			mob_nearby = TRUE
			break
	if(mob_nearby && !mobs_in_range)
		sg_light.open()
		mobs_in_range = TRUE
	else if(!mob_nearby && mobs_in_range)
		mobs_in_range = FALSE
		sg_light.close()

/obj/structure/destructible/clockwork/stargazer/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent != INTENT_HELP)
		return ..()
	if(!anchored)
		to_chat(user, "<span class='brass'>You need to anchor [src] to the floor first.</span>")
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='brass'>[src] is still warming up, it will be ready in [DisplayTimeText(cooldowntime - world.time)].</span>")
		return
	if(HAS_TRAIT(I, TRAIT_STARGAZED))
		to_chat(user, "<span class='brass'>[I] has already been enhanced!</span>")
		return
	to_chat(user, "<span class='brass'>You begin placing [I] onto [src].</span>")
	if(do_after(user, 6 SECONDS, I))
		if(cooldowntime > world.time)
			to_chat(user, "<span class='brass'>[src] is still warming up, it will be ready in [DisplayTimeText(cooldowntime - world.time)].</span>")
			return
		if(HAS_TRAIT(I, TRAIT_STARGAZED))
			to_chat(user, "<span class='brass'>[I] has already been enhanced!</span>")
			return
		if(istype(I, /obj/item))
			upgrade_weapon(I, user)
			cooldowntime = world.time + STARGAZER_COOLDOWN
			return
		to_chat(user, "<span class='brass'>You cannot upgrade [I].</span>")

/obj/structure/destructible/clockwork/stargazer/proc/upgrade_weapon(obj/item/I, mob/living/user)
	ADD_TRAIT(I, TRAIT_STARGAZED, STARGAZER_TRAIT)
	switch(rand(1, 8))
		if(1)
			to_chat(user, "<span class='neovgre'>[I] looks as if it could pierce reality.</span>")
			I.force += 1
			I.armour_penetration += 10
			I.sharpness = SHARP_POINTY
			return
		if(2)
			to_chat(user, "<span class='neovgre'>[I] looks as if it could cut through anything.</span>")
			I.force += 2
			I.sharpness = SHARP_EDGED
			return
		if(3)
			to_chat(user, "<span class='neovgre'>[I] looks as if it could shatter bones in a single strike.</span>")
			I.force += 2
			I.sharpness = SHARP_NONE
			return
		if(4)
			I.damtype = BURN
			I.force += 2
			I.light_power = 1
			I.light_range = 2
			I.light_color = LIGHT_COLOR_FIRE
			to_chat(user, "<span class='neovgre'>[I] begins to emit an intense heat!</span>")
			return
		if(5)
			I.light_power = 3
			I.light_range = 3
			I.light_color = LIGHT_COLOR_CLOCKWORK
			I.block_chance += 15
			to_chat(user, "<span class='neovgre'>[I] shines with a brilliant protecting light!</span>")
			return
		if(6)
			I.w_class = WEIGHT_CLASS_TINY
			I.slot_flags |= ITEM_SLOT_POCKETS
			to_chat(user, "<span class='neovgre'>[I] suddenly shrinks small enough to fit in one's pockets!</span>")
			return
		if(7)
			to_chat(user, "<span class='neovgre'>You feel bloodlust starting to emanate from [I]!</span>")
			I.AddComponent(/datum/component/lifesteal, 4)
			return
		if(8)
			I.block_chance += 10
			I.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
			to_chat(user, "<span class='neovgre'>[I] becomes unbreakable!</span>")
			return
