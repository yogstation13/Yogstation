/obj/item/gun/energy/taser
	name = "taser gun"
	desc = "A low-capacity, energy-based stun gun used by security teams to subdue targets at range."
	icon_state = "taser"
	inhand_icon_state = null //so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/electrode)
	ammo_x_offset = 3

//MONKESTATION EDIT START
/obj/item/gun/energy/taser/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	playsound(src, 'monkestation/sound/effects/taser_charge.ogg', 45, TRUE, 1)
	if(do_after(user, 1 SECONDS, timed_action_flags = IGNORE_USER_LOC_CHANGE))
		return ..()

/obj/item/gun/energy/taser/old
	name = "old taser gun"
	desc = "A low-capacity, energy-based stun gun used by security teams to subdue targets at range. There is a piece of tape loosely holding the cell in place..."

/obj/item/gun/energy/taser/old/examine_more(mob/user)
	. = ..()
	. += span_notice("The cell is leaking a metallic smelling fluid from underneath the tape... Is this safe?")

/obj/item/gun/energy/taser/old/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(prob(50))
		do_sparks(rand(3, 4), FALSE, src)
		to_chat(user, span_warning("[user]'s taser jams, sputtering acid onto [user]!"))
		target = user //get tased
		user.apply_damage(24, BURN, spread_damage = TRUE, wound_bonus = 10)
		user.apply_damage(150, STAMINA)
		if(prob(25))
			user.adjust_fire_stacks(2)
		user.ignite_mob()
		return ..()
	else
		return ..()

//MONKESTATION EDIT STOP

/obj/item/gun/energy/e_gun/advtaser
	name = "hybrid taser"
	desc = "A dual-mode taser designed to fire both short-range high-power electrodes and long-range disabler beams."
	icon_state = "advtaser"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler)
	ammo_x_offset = 2

//MONKESTATION EDIT START
/obj/item/gun/energy/e_gun/advtaser/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(select == 1)
		playsound(src, 'monkestation/sound/effects/taser_charge.ogg', 45, TRUE, 1)
		if(do_after(user, 1 SECONDS, timed_action_flags = IGNORE_USER_LOC_CHANGE))
			return ..()
	else
		return ..()
//MONKESTATION EDIT STOP

/obj/item/gun/energy/e_gun/advtaser/cyborg
	name = "cyborg taser"
	desc = "An integrated hybrid taser that draws directly from a cyborg's power cell. The weapon contains a limiter to prevent the cyborg's power cell from overheating."
	can_charge = FALSE
	use_cyborg_cell = TRUE

/obj/item/gun/energy/e_gun/advtaser/cyborg/add_seclight_point()
	return

/obj/item/gun/energy/e_gun/advtaser/cyborg/emp_act()
	return

/obj/item/gun/energy/disabler
	name = "disabler"
	desc = "A self-defense weapon that exhausts organic targets, weakening them until they collapse."
	icon_state = "disabler"
	inhand_icon_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/disabler)
	ammo_x_offset = 2

/obj/item/gun/energy/disabler/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 15, \
		overlay_y = 10)

/obj/item/gun/energy/disabler/smg
	name = "disabler smg"
	desc = "An automatic disabler variant, as opposed to the conventional model, boasts a higher ammunition capacity at the cost of slightly reduced beam effectiveness."
	icon_state = "disabler_smg"
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/smg)
	shaded_charge = 1

/obj/item/gun/energy/disabler/smg/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.15 SECONDS, allow_akimbo = FALSE)

/obj/item/gun/energy/disabler/add_seclight_point()
	AddComponent(\
		/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 15, \
		overlay_y = 13, \
	)

/obj/item/gun/energy/disabler/cyborg
	name = "cyborg disabler"
	desc = "An integrated disabler that draws from a cyborg's power cell. This weapon contains a limiter to prevent the cyborg's power cell from overheating."
	can_charge = FALSE
	use_cyborg_cell = TRUE

/obj/item/gun/energy/disabler/cyborg/emp_act()
	return
