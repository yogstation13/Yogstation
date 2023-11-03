//////////////////////////////////////////////////////////////////////////
//----------------------Scout light eater ability-----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/toggle/light_eater
	name = "Light Eater"
	desc = "Twists an active arm into a blade of all-consuming shadow."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "pass"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/toggle/light_eater/process()
	active = owner.is_holding_item_of_type(/obj/item/light_eater)
	. = ..()

/datum/action/cooldown/spell/toggle/light_eater/can_cast_spell(feedback)
	if(!owner.get_empty_held_indexes())
		if(feedback)
			to_chat(owner, span_warning("You need an empty hand for this!"))
		return FALSE
	. = ..()

/datum/action/cooldown/spell/toggle/light_eater/Enable()
	owner.visible_message(span_warning("[owner]'s arm contorts into a blade!"), "<span class='velvet bold'>ikna</span><br>\
	[span_notice("You transform your arm into a blade.")]")
	playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, 1)
	var/obj/item/light_eater/T = new(owner)
	owner.put_in_hands(T)

/datum/action/cooldown/spell/toggle/light_eater/Disable()
	owner.visible_message(span_warning("[owner]'s blade transform back!"), "<span class='velvet bold'>haoo</span><br>\
	[span_notice("You dispel the blade.")]")
	playsound(owner, 'yogstation/sound/magic/pass_dispel.ogg', 50, 1)
	for(var/obj/item/light_eater/T in owner)
		qdel(T)

//////////////////////////////////////////////////////////////////////////
//---------------------Scout Long range option--------------------------//
//////////////////////////////////////////////////////////////////////////
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
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN

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
	
//////////////////////////////////////////////////////////////////////////
//---------------------Detain and capture ability-----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/glare //Stuns and mutes a human target for 10 seconds
	name = "Glare"
	desc = "Disrupts the target's motor and speech abilities. Much more effective within two meters."
	panel = "Shadowling Abilities"
	button_icon_state = "glare"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	panel = null
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	cooldown_time = 30 SECONDS
	ranged_mousepointer = 'icons/effects/mouse_pointers/gaze_target.dmi'
	var/strong = TRUE

/datum/action/cooldown/spell/pointed/glare/before_cast(atom/cast_on)
	. = ..()
	if(!cast_on || !isliving(cast_on))
		return . | SPELL_CANCEL_CAST
	if(!owner.getorganslot(ORGAN_SLOT_EYES))
		to_chat(owner, span_warning("You need eyes to glare!"))
		return . | SPELL_CANCEL_CAST
	var/mob/living/carbon/target = cast_on
	if(istype(target) && target.stat)
		to_chat(owner, span_warning("[target] must be conscious!"))
		return . | SPELL_CANCEL_CAST
	if(is_darkspawn_or_veil(target))
		to_chat(owner, span_warning("You cannot glare at allies!"))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/glare/cast(atom/cast_on)
	. = ..()
	if(!isliving(cast_on))
		return
	var/mob/living/target = cast_on
	owner.visible_message(span_warning("<b>[owner]'s eyes flash a purpleish-red!</b>"))
	var/distance = get_dist(target, owner)
	if (distance <= 2 && strong)
		target.visible_message(span_danger("[target] suddenly collapses..."))
		to_chat(target, span_userdanger("A purple light flashes across your vision, and you lose control of your movements!"))
		target.Paralyze(10 SECONDS)
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			M.silent += 10
	else //Distant glare
		var/loss = 100 - (distance * 10)
		target.adjustStaminaLoss(loss)
		target.adjust_stutter(loss)
		to_chat(target, span_userdanger("A purple light flashes across your vision, and exhaustion floods your body..."))
		target.visible_message(span_danger("[target] looks very tired..."))

//////////////////////////////////////////////////////////////////////////
//----------------------Temporary Darkness in aoe-----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/darkness_smoke //Spawns a cloud of smoke that blinds non-thralls/shadows and grants slight healing to shadowlings and their allies
	name = "Darkness Smoke"
	desc = "Spews a cloud of smoke which will blind enemies."
	panel = "Shadowling Abilities"
	button_icon_state = "black_smoke"
	button_icon = 'yogstation/icons/mob/actions.dmi'

	sound = 'sound/effects/bamf.ogg'
	cooldown_time = 1 MINUTES
	antimagic_flags = NONE
	panel = null
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	psi_cost = 15
	var/range = 4

/datum/action/cooldown/spell/darkness_smoke/cast(mob/living/carbon/human/user) //Extremely hacky ---- (oh god, it really is)
	. = ..()
	user.visible_message(span_warning("[user] bends over and coughs out a cloud of black smoke!"), span_velvet("You regurgitate a vast cloud of blinding smoke."))
	var/obj/item/reagent_containers/glass/beaker/large/B = new /obj/item/reagent_containers/glass/beaker/large(user.loc) //hacky
	B.reagents.clear_reagents() //Just in case!
	B.invisibility = INFINITY //This ought to do the trick
	B.reagents.add_reagent(/datum/reagent/darkspawn_darkness_smoke, 10)
	var/datum/effect_system/fluid_spread/smoke/chem/transparent/S = new //it doesn't actually block light anyways, so let's not block vision either
	S.attach(B)
	if(S)
		S.set_up(range, location = B.loc, carry = B.reagents)
		S.start()
	qdel(B)

//////////////////////////////////////////////////////////////////////////
//-------------------It's a jaunt, what do you expect-------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/jaunt/ethereal_jaunt/void_jaunt
	name = "Void Jaunt"
	desc = "Move through the void for a time, avoiding mortal eyes and lights."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "jaunt"

	cooldown_time = 60 SECONDS
	antimagic_flags = NONE
	panel = null
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	psi_cost = 30

	exit_jaunt_sound = 'sound/magic/ethereal_exit.ogg'
	/// For how long are we jaunting?
	jaunt_duration = 5 SECONDS
	/// Visual for jaunting
	jaunt_in_type = /obj/effect/temp_visual/wizard
	/// Visual for exiting the jaunt
	jaunt_out_type = /obj/effect/temp_visual/wizard/out

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/void_jaunt/do_steam_effects(turf/loc)
	return FALSE


//////////////////////////////////////////////////////////////////////////
//----------------------------Trap abilities----------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/darkspawn_trap
	name = "Dark sticks"
	desc = "Place dangerous punji sticks. Allies pass safely."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "sacrament"
	antimagic_flags = NONE
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	cooldown_time = 30 SECONDS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	cast_range = 2
	var/casting = FALSE
	var/cast_time = 2 SECONDS
	var/object_type = /obj/structure/dark_sticks

/datum/action/cooldown/spell/pointed/darkspawn_trap/can_cast_spell(feedback)
	if(casting)
		return FALSE
	. = ..()

/datum/action/cooldown/spell/pointed/darkspawn_trap/before_cast(atom/cast_on)
	. = ..()
	if(cast_on.density)
		return . | SPELL_CANCEL_CAST
	if(casting)
		return . | SPELL_CANCEL_CAST
	if(. & SPELL_CANCEL_CAST)
		return .
	casting = TRUE
	playsound(get_turf(owner), 'yogstation/sound/magic/devour_will_begin.ogg', 50, TRUE)
	if(!do_after(owner, cast_time, cast_on))
		casting = FALSE
		return . | SPELL_CANCEL_CAST
	casting = FALSE
	
/datum/action/cooldown/spell/pointed/darkspawn_trap/cast(atom/cast_on)
	. = ..()
	playsound(get_turf(owner), 'yogstation/sound/magic/devour_will_end.ogg', 50, TRUE)
	var/obj/thing = new object_type(get_turf(cast_on))
	owner.visible_message(span_warning("[owner] knits shadows together into a [thing]!"), span_velvet("You create a [thing]"))

/datum/action/cooldown/spell/pointed/darkspawn_trap/legcuff
	name = "Legcuffs"
	desc = "Place dangerous punji sticks. Darkspawn can pass safely, but thralls can't."
	object_type = /obj/item/restraints/legcuffs/beartrap/energy/dark
