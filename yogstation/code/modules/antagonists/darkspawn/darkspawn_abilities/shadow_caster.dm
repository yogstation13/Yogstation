/datum/action/cooldown/spell/toggle/shadow_caster
	name = "Shadow caster"
	desc = "Twists an active arm into a bow that shoots harddark arrows."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "pass"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN

/datum/action/cooldown/spell/toggle/shadow_caster/process()
	active = owner.is_holding_item_of_type(/obj/item/gun/ballistic/bow/energy/shadow_caster)
	. = ..()

/datum/action/cooldown/spell/toggle/shadow_caster/can_cast_spell(feedback)
	if(!owner.get_empty_held_indexes())
		if(feedback)
			to_chat(owner, span_warning("You need an empty hand for this!"))
		return FALSE
	. = ..()

/datum/action/cooldown/spell/toggle/shadow_caster/Enable()
	owner.visible_message(span_warning("[owner]'s arm contorts into a blade!"), "<span class='velvet bold'>ikna</span><br>\
	[span_notice("You transform your arm into a blade.")]")
	playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, 1)
	var/obj/item/gun/ballistic/bow/energy/shadow_caster/T = new(owner)
	owner.put_in_hands(T)

/datum/action/cooldown/spell/toggle/shadow_caster/Disable()
	owner.visible_message(span_warning("[owner]'s blade transform back!"), "<span class='velvet bold'>haoo</span><br>\
	[span_notice("You dispel the blade.")]")
	playsound(owner, 'yogstation/sound/magic/pass_dispel.ogg', 50, 1)
	for(var/obj/item/gun/ballistic/bow/energy/shadow_caster/T in owner)
		qdel(T)

/obj/item/gun/ballistic/bow/energy/shadow_caster
	name = "shadow caster"
	desc = "A bow made of solid darkness. The arrows it shoots seem to suck light out of the surroundings."
	icon_state = "bow_hardlight"
	item_state = "bow_hardlight"
	mag_type = /obj/item/ammo_box/magazine/internal/bow/shadow
	no_pin_required = TRUE

/obj/item/gun/ballistic/bow/energy/shadow_caster/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/light_eater)

/obj/item/ammo_box/magazine/internal/bow/shadow
	ammo_type = /obj/item/ammo_casing/reusable/arrow/shadow

/obj/item/ammo_casing/reusable/arrow/shadow
	name = "shadow arrow"
	desc = "it seem to suck light out of the surroundings."
	light_system = MOVABLE_LIGHT
	light_power = -0.5
	light_color = COLOR_DARKSPAWN_PSI
	light_range = 2
	projectile_type = /obj/projectile/bullet/reusable/arrow/shadow

/obj/item/ammo_casing/reusable/arrow/shadow/on_land(obj/projectile/old_projectile)
	. = ..()
	QDEL_IN(src, 10 SECONDS)

/obj/projectile/bullet/reusable/arrow/shadow
	name = "shadow arrow"
	light_system = MOVABLE_LIGHT
	light_power = -0.5
	light_color = COLOR_DARKSPAWN_PSI
	light_range = 2
