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
	if(!owner.get_empty_held_indexes() && !active)
		if(feedback)
			to_chat(owner, span_warning("You need an empty hand for this!"))
		return FALSE
	. = ..()

/datum/action/cooldown/spell/toggle/light_eater/Enable()
	to_chat(owner, span_velvet("Akna"))
	owner.visible_message(span_warning("[owner]'s arm contorts into a blade!"), span_velvet("You transform your arm into a blade."))
	playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, 1)
	var/obj/item/light_eater/T = new(owner)
	owner.put_in_hands(T)

/datum/action/cooldown/spell/toggle/light_eater/Disable()
	to_chat(owner, span_velvet("Haoo"))
	owner.visible_message(span_warning("[owner]'s blade transforms back!"), span_velvet("You dispel the blade."))
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
	var/obj/item/gun/ballistic/bow/energy/shadow_caster/bow

/datum/action/cooldown/spell/toggle/shadow_caster/process()
	active = owner.is_holding_item_of_type(/obj/item/gun/ballistic/bow/energy/shadow_caster)
	. = ..()

/datum/action/cooldown/spell/toggle/shadow_caster/can_cast_spell(feedback)
	if(!owner.get_empty_held_indexes() && !active)
		if(feedback)
			to_chat(owner, span_warning("You need an empty hand for this!"))
		return FALSE
	. = ..()

/datum/action/cooldown/spell/toggle/shadow_caster/Enable()
	to_chat(owner, span_velvet("Crxkna"))
	owner.visible_message(span_warning("[owner]'s arm contorts into a bow!"), span_velvet("You transform your arm into a bow."))
	playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, 1)
	if(!bow)
		bow = new (owner)
	owner.put_in_hands(bow)

/datum/action/cooldown/spell/toggle/shadow_caster/Disable()
	to_chat(owner, span_velvet("Haoo"))
	owner.visible_message(span_warning("[owner]'s bow transforms back!"), span_velvet("You dispel the bow."))
	playsound(owner, 'yogstation/sound/magic/pass_dispel.ogg', 50, 1)
	bow.moveToNullspace()
	
//////////////////////////////////////////////////////////////////////////
//---------------------Detain and capture ability-----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/glare //Stuns and mutes a human target for 10 seconds
	name = "Glare"
	desc = "Disrupts the target's motor and speech abilities. Much more effective within two meters."
	panel = null
	button_icon_state = "glare"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
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
	owner.visible_message(span_warning("<b>[owner]'s eyes flash a purpleish-red!</b>"), span_velvet("Sskr'aya"))
	var/mob/living/target = cast_on
	if(target.can_block_magic(antimagic_flags, charge_cost = 1))
		return
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
/datum/action/cooldown/spell/darkness_smoke
	name = "Darkness Smoke"
	desc = "Spews a cloud of smoke which will blind enemies."
	panel = null
	button_icon_state = "black_smoke"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"

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
	to_chat(owner, span_velvet("Hwlok'krotho"))
	user.visible_message(span_warning("[user] bends over and bellows out a cloud of black smoke!"), span_velvet("You expel a vast cloud of blinding smoke."))
	var/obj/item/reagent_containers/glass/beaker/large/B = new /obj/item/reagent_containers/glass/beaker/large(user.loc) //hacky
	B.reagents.clear_reagents() //Just in case!
	B.invisibility = INFINITY //This ought to do the trick
	B.reagents.add_reagent(/datum/reagent/darkspawn_darkness_smoke, 50)
	var/datum/effect_system/fluid_spread/smoke/chem/transparent/S = new //it doesn't actually block light anyways, so let's not block vision either
	S.attach(B)
	if(S)
		S.set_up(range, location = B.loc, carry = B.reagents)
		S.start()
	qdel(B)

//////////////////////////////////////////////////////////////////////////
//----------------------------Trap abilities----------------------------//
//////////////////////////////////////////////////////////////////////////
//Reskinned punji sticks that don't stun for as long
/datum/action/cooldown/spell/pointed/darkspawn_build/punji
	name = "Damage trap"
	desc = "Place dangerous punji sticks. Allies pass safely."
	object_type = /obj/structure/trap/darkspawn/damage
	language_final = "ksha"

//Reskinned bear trap that doesn't slow as much and can't be picked up
/datum/action/cooldown/spell/pointed/darkspawn_build/legcuff
	name = "Legcuffs"
	desc = "a dark bear trap."
	object_type = /obj/item/restraints/legcuffs/beartrap/dark
	language_final = "xcrak"

//Discombobulates people
/datum/action/cooldown/spell/pointed/darkspawn_build/nausea
	name = "Nausea trap"
	desc = "a dark bear trap."
	object_type = /obj/structure/trap/darkspawn/nausea
	language_final = "guhxo"

//Discombobulates people
/datum/action/cooldown/spell/pointed/darkspawn_build/teleport
	name = "Teleport trap"
	desc = "a dark bear trap."
	object_type = /obj/structure/trap/darkspawn/teleport
	language_final = "hwkwo"

//////////////////////////////////////////////////////////////////////////
//-------------------It's a jaunt, what do you expect-------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/jaunt/ethereal_jaunt/void_jaunt
	name = "Void Jaunt"
	desc = "Move through the void for a time, avoiding mortal eyes and lights."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "space_crawl"

	cooldown_time = 60 SECONDS
	antimagic_flags = NONE
	panel = null
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	psi_cost = 30

	sound = 'sound/effects/bamf.ogg'
	exit_jaunt_sound = 'yogstation/sound/magic/devour_will_begin.ogg'
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/ninja/cloak
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/ninja

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/void_jaunt/do_steam_effects(turf/loc)
	return FALSE

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/void_jaunt/cast(mob/living/cast_on)
	. = ..()
	to_chat(owner, span_velvet("Vxklu'wop sla'txhaka"))

//////////////////////////////////////////////////////////////////////////
//--------------------------Targeted Teleport---------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/phase_jump/void_jump
	name = "Void jump"
	desc = "A short range targeted teleport."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "voidblink"
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	panel = null
	sound = 'sound/magic/voidblink.ogg'

	cooldown_time = 25 SECONDS
	cast_range = 7
	active_msg = span_velvet("You prepare to take a step through the void.")
	deactive_msg = span_notice("You relax your mind.")
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	beam_icon = "curse0"

/datum/action/cooldown/spell/pointed/phase_jump/void_jump/InterceptClickOn(mob/living/user, params, atom/target)
	. = ..()
	if(.)
		to_chat(owner, span_velvet("Vxklu'wop"))

//////////////////////////////////////////////////////////////////////////
//-----------------------------AOE ice field----------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/aoe/permafrost
	name = "Permafrost"
	desc = "permafrost."
	button_icon = 'icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "Kindle"
	active_icon_state = "Kindle"
	base_icon_state = "Kindle"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	panel = null
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN | SPELL_REQUIRES_HUMAN
	cooldown_time = 30 SECONDS
	sound = 'yogstation/sound/ambience/antag/veil_mind_scream.ogg'
	aoe_radius = 3

/datum/action/cooldown/spell/aoe/permafrost/cast(atom/cast_on)
	. = ..()
	to_chat(owner, span_velvet("Syn'thxklp"))
	if(isliving(owner))
		var/mob/living/target = owner
		target.extinguish_mob()

/datum/action/cooldown/spell/aoe/permafrost/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!isopenturf(victim))
		return
	var/turf/open/target = victim
	target.MakeSlippery(TURF_WET_PERMAFROST, 15 SECONDS, 15 SECONDS)
