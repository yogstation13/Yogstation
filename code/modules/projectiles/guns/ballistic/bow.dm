/obj/item/gun/ballistic/bow
	name = "wooden bow"
	desc = "some sort of primitive projectile weapon. used to fire arrows."
	icon_state = "bow"
	item_state = "bow"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY //need both hands to fire
	force = 5
	spread = 1
	mag_type = /obj/item/ammo_box/magazine/internal/bow
	fire_sound = 'sound/weapons/sound_weapons_bowfire.ogg'
	slot_flags = ITEM_SLOT_BACK
	item_flags = NEEDS_PERMIT | SLOWS_WHILE_IN_HAND
	casing_ejector = FALSE
	internal_magazine = TRUE
	pin = null
	no_pin_required = TRUE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL //so ashwalkers can use it

	var/drawing = FALSE
	var/drop_release_draw = TRUE
	var/move_drawing = TRUE
	var/draw_time = 0.5 SECONDS
	var/draw_slowdown = 1.5
	var/draw_sound = 'sound/weapons/sound_weapons_bowdraw.ogg'
	var/mutable_appearance/arrow_overlay

/obj/item/gun/ballistic/bow/shoot_with_empty_chamber()
	return

/obj/item/gun/ballistic/bow/chamber_round()
	chambered = magazine.get_round(1)
	update_icon()

/obj/item/gun/ballistic/bow/dropped()
	. = ..()
	if(drop_release_draw && !QDELING(src))
		addtimer(CALLBACK(src, .proc/release_draw_if_not_held))

/obj/item/gun/ballistic/bow/proc/release_draw_if_not_held()
	if(!ismob(loc))
		release_draw()

/obj/item/gun/ballistic/bow/proc/release_draw()
	var/old_chambered = chambered
	chambered = null
	magazine.give_round(old_chambered)
	update_slowdown()
	update_icon()

/obj/item/gun/ballistic/bow/process_chamber()
	chambered = null
	magazine.get_round(0)
	update_slowdown()
	update_icon()

/obj/item/gun/ballistic/bow/attack_self(mob/living/user)
	if(chambered)
		var/obj/item/ammo_casing/AC = magazine.get_round(0)
		user.put_in_hands(AC)
		chambered = null
		to_chat(user, span_notice("You gently release the bowstring, removing the arrow."))
	else if(get_ammo())
		drawing = TRUE
		update_slowdown()
		if (!do_after(user, draw_time, src, TRUE, stayStill = !move_drawing))
			drawing = FALSE
			update_slowdown()
			return
		drawing = FALSE
		to_chat(user, span_notice("You draw back the bowstring."))
		playsound(src, draw_sound, 75, 0, falloff = 3) //gets way too high pitched if the freq varies
		chamber_round()
	update_slowdown()
	update_icon()

/obj/item/gun/ballistic/bow/attackby(obj/item/I, mob/user, params)
	if (magazine.attackby(I, user, params, 1))
		to_chat(user, span_notice("You notch the arrow."))
	update_slowdown()
	update_icon()

/obj/item/gun/ballistic/bow/update_icon()
	cut_overlay(arrow_overlay, TRUE)
	icon_state = "[initial(icon_state)][chambered ? "_firing" : ""]"
	if(get_ammo())
		var/obj/item/ammo_casing/caseless/arrow/energy/E = magazine.get_round(TRUE)
		arrow_overlay = mutable_appearance(icon, "[initial(E.icon_state)][chambered ? "_firing" : ""]")
		add_overlay(arrow_overlay, TRUE)

/obj/item/gun/ballistic/bow/proc/update_slowdown()
	if(chambered || drawing)
		slowdown = draw_slowdown
	else
		slowdown = initial(slowdown)

/obj/item/gun/ballistic/bow/can_shoot()
	return chambered

/obj/item/gun/ballistic/bow/ashen
	name = "Bone Bow"
	desc = "Some sort of primitive projectile weapon made of bone and wrapped sinew."
	icon_state = "ashenbow"
	item_state = "ashenbow"
	spread = 3
	force = 8

/obj/item/gun/ballistic/bow/pipe
	name = "Pipe Bow"
	desc = "A crude projectile weapon made from silk string, pipe and lots of bending."
	icon_state = "pipebow"
	item_state = "pipebow"
	force = 7
	spread = 5
	draw_time = 1 SECONDS

/obj/item/gun/ballistic/bow/maint
	name = "Makeshift Bow"
	desc = "A crude projectile weapon made from cables, pipe, tape and lots of bending."
	icon_state = "makeshift_bow"
	item_state = "makeshift_bow"
	force = 7
	spread = 10
	draw_time = 2 SECONDS
	
/obj/item/gun/ballistic/bow/crossbow
	name = "wooden crossbow"
	desc = "A bow with a locking mechanism that more closely resembles a modern gun."
	icon_state = "crossbow"
	spread = 0
	draw_time = 2 SECONDS
	draw_slowdown = FALSE
	drop_release_draw = FALSE
	move_drawing = FALSE
	
/obj/item/gun/ballistic/bow/crossbow/magfed
	name = "wooden magfed crossbow"
	desc = "A bow with a locking mechanism that more closely resembles a modern gun. This one seems to be outfitted with an automatic loading mechanism."
	mag_type = /obj/item/ammo_box/magazine/arrow
	internal_magazine = FALSE

/obj/item/gun/ballistic/bow/attackby(obj/item/I, mob/user, params)
	if (!internal_magazine && istype(I, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = I
		if (!magazine)
			insert_magazine(user, AM)
		else
			if (tac_reloads)
				eject_magazine(user, FALSE, AM)
			else
				to_chat(user, span_notice("There's already a [magazine_wording] in \the [src]."))
		return
	..()

/obj/item/gun/ballistic/bow/energy
	name = "Hardlight Bow"
	desc = "A modern bow that can fabricate hardlight arrows using an internal energy."
	icon_state = "bow_hardlight"
	item_state = "bow_hardlight"
	mag_type = /obj/item/ammo_box/magazine/internal/bow/energy
	no_pin_required = FALSE
	draw_slowdown = 0
	var/recharge_time = 1.5 SECONDS

/obj/item/gun/ballistic/bow/energy/update_icon()
	cut_overlay(arrow_overlay, TRUE)
	if(get_ammo())
		var/obj/item/ammo_casing/caseless/arrow/energy/E = magazine.get_round(TRUE)
		arrow_overlay = mutable_appearance(icon, "[initial(E.icon_state)][chambered ? "_firing" : ""]")
		add_overlay(arrow_overlay, TRUE)

/obj/item/gun/ballistic/bow/energy/shoot_live_shot(mob/living/user, pointblank, atom/pbtarget, message)
	. = ..()
	if(recharge_time)
		TIMER_COOLDOWN_START(src, "arrow_recharge", recharge_time)
		addtimer(CALLBACK(src, .proc/end_cooldown), recharge_time)

/obj/item/gun/ballistic/bow/energy/proc/end_cooldown()
	playsound(src, 'sound/effects/sparks4.ogg', 25, 0)

/obj/item/gun/ballistic/bow/energy/attack_self(mob/living/user)
	if(chambered)
		chambered = null
		to_chat(user, span_notice("You disperse the arrow."))
	else if(get_ammo())
		drawing = TRUE
		update_slowdown()
		if (!do_after(user, draw_time, src, TRUE, stayStill = FALSE))
			drawing = FALSE
			update_slowdown()
			return
		drawing = FALSE
		to_chat(user, span_notice("You draw back the bowstring."))
		playsound(src, draw_sound, 75, 0, falloff = 3) //gets way too high pitched if the freq varies
		chamber_round()
	else if(!recharge_time || !TIMER_COOLDOWN_CHECK(src, "arrow_recharge"))
		to_chat(user, span_notice("You fabricate an arrow."))
		recharge_bolt()
	update_slowdown()
	update_icon()

/obj/item/gun/ballistic/bow/energy/proc/recharge_bolt()
	if(magazine.get_round(TRUE))
		return
	var/ammo_type = magazine.ammo_type
	magazine.give_round(new ammo_type())

	update_icon()

/obj/item/gun/ballistic/bow/energy/attackby(obj/item/I, mob/user, params)
	return

/obj/item/gun/ballistic/bow/energy/AltClick(mob/living/user)
	select_projectile(user)
	var/current_round = magazine.get_round(TRUE)
	if(current_round)
		QDEL_NULL(current_round)
	if(!TIMER_COOLDOWN_CHECK(src, "arrow_recharge"))
		recharge_bolt()
	update_icon()

/obj/item/gun/ballistic/bow/energy/proc/select_projectile(mob/living/user)
	var/obj/item/ammo_box/magazine/internal/bow/energy/M = magazine
	if(!istype(M) || !M.selectable_types)
		return
	var/list/selectable_types = M.selectable_types

	if(selectable_types.len == 1)
		M.ammo_type = selectable_types[1]
		to_chat(user, span_notice("\The [src] doesn't have any other firing modes."))
		update_icon()
		return

	if(selectable_types.len == 2)
		selectable_types = selectable_types - M.ammo_type
		M.ammo_type = selectable_types[1]
		to_chat(user, span_notice("You switch \the [src]'s firing mode."))
		update_icon()
		return

	var/list/choice_list = list()
	for(var/arrow_type in M.selectable_types)
		var/obj/item/ammo_casing/caseless/arrow/energy/arrow = new arrow_type()
		choice_list[arrow] = image(arrow)
	var/obj/item/ammo_casing/caseless/arrow/energy/choice = show_radial_menu(user, user, choice_list, tooltips = TRUE)
	if(!choice || !(choice.type in M.selectable_types))
		return
	M.ammo_type = choice.type
	to_chat(user, span_notice("You switch \the [src]'s firing mode to \"[choice]\"."))
	for(var/arrow in choice_list)
		QDEL_NULL(choice_list[arrow])
		QDEL_NULL(arrow)
	QDEL_NULL(choice_list)
	update_icon()

/obj/item/gun/ballistic/bow/energy/advanced
	name = "Advanced Hardlight Bow"
	mag_type = /obj/item/ammo_box/magazine/internal/bow/energy/advanced
	recharge_time = 0
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/bow/energy/syndicate
	name = "Syndicate Hardlight Bow"
	desc = "A modern bow that can fabricate hardlight arrows using an internal energy. This one is designed by the Syndicate for silent takedowns of targets."
	icon_state = "bow_syndicate"
	item_state = "bow_syndicate"
	mag_type = /obj/item/ammo_box/magazine/internal/bow/energy/syndicate
	recharge_time = 2 SECONDS
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 5
	pin = /obj/item/firing_pin
	fire_sound = null
	draw_sound = null
	var/folded = FALSE
	var/stored_ammo ///what was stored in the magazine before being folded?

/obj/item/gun/ballistic/bow/energy/syndicate/examine(mob/user)
	. = ..()
	. += "It can be folded into a compact form by using CTRL + CLICK."

/obj/item/gun/ballistic/bow/energy/syndicate/shoot_live_shot(mob/living/user, pointblank, atom/pbtarget, message)
	if(!folded)
		return ..()
	else
		to_chat(user, span_notice("You must unfold [src] before firing it!"))
		return FALSE

/obj/item/gun/ballistic/bow/energy/syndicate/attack_self(mob/living/user)
	if(!folded)
		return ..()
	else
		to_chat(user, span_notice("You must unfold [src] to chamber a round!"))
		return FALSE

/obj/item/gun/ballistic/bow/energy/syndicate/AltClick(mob/living/user)
	if(!folded)
		return ..()
	else
		to_chat(user, span_notice("You must unfold [src] to switch firing modes!"))
		return FALSE

/obj/item/gun/ballistic/bow/energy/syndicate/CtrlClick(mob/living/user)
	if(!user.is_holding(src))
		to_chat(user, span_notice("You need be holding [src] to do that!"))
		return
	folded = !folded
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)
	if(folded)
		to_chat(user, span_notice("You fold [src]."))
		w_class = WEIGHT_CLASS_NORMAL
		chambered = null
		icon_state = "bow_syndicate_folded"
		stored_ammo = magazine.ammo_list()
		magazine.stored_ammo = null
		update_icon()
	else
		w_class = WEIGHT_CLASS_BULKY
		to_chat(user, span_notice("You extend [src], allowing it to be fired."))
		icon_state = "bow_syndicate"
		magazine.stored_ammo = stored_ammo
		update_icon()

/obj/item/gun/ballistic/bow/energy/clockwork
	name = "Brass Bow"
	desc = "A bow made from brass and other components that you can't quite understand. It glows with a deep energy and fabricates arrows by itself."
	icon_state = "bow_clockwork"
	item_state = "bow_clockwork"
	mag_type = /obj/item/ammo_box/magazine/internal/bow/energy/clockcult
	pin = /obj/item/firing_pin/clockie
