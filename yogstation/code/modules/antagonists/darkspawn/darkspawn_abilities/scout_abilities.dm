//////////////////////////////////////////////////////////////////////////
//----------------------Scout light eater ability-----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/toggle/light_eater
	name = "Light Eater"
	desc = "Twists an active arm into a blade of all-consuming shadow."
	panel = "Darkspawn"
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "light_eater"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	///The blade spawned by the ability
	var/obj/item/light_eater/armblade

/datum/action/cooldown/spell/toggle/light_eater/process()
	active = owner.is_holding_item_of_type(/obj/item/light_eater)
	return ..()

/datum/action/cooldown/spell/toggle/light_eater/can_cast_spell(feedback)
	if(!owner.get_empty_held_indexes() && !active)
		if(feedback)
			to_chat(owner, span_warning("You need an empty hand for this!"))
		return FALSE
	return ..()

/datum/action/cooldown/spell/toggle/light_eater/Enable()
	owner.balloon_alert(owner, "Akna")
	owner.visible_message(span_warning("[owner]'s arm contorts into a blade!"), span_velvet("You transform your arm into a blade."))
	playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, 1)
	if(!armblade)
		armblade = new(owner)
	owner.put_in_hands(armblade)

/datum/action/cooldown/spell/toggle/light_eater/Disable()
	owner.balloon_alert(owner, "Haoo")
	owner.visible_message(span_warning("[owner]'s blade transforms back!"), span_velvet("You dispel the blade."))
	playsound(owner, 'yogstation/sound/magic/pass_dispel.ogg', 50, 1)
	if(armblade)
		armblade.moveToNullspace()

//////////////////////////////////////////////////////////////////////////
//---------------------Scout Long range option--------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/toggle/shadow_caster
	name = "Shadow caster"
	desc = "Twists an active arm into a bow that shoots arrows made of solid darkness."
	panel = "Darkspawn"
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "shadow_caster"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	///the bow spawned by the ability
	var/obj/item/gun/ballistic/bow/energy/shadow_caster/bow

/datum/action/cooldown/spell/toggle/shadow_caster/process()
	active = owner.is_holding_item_of_type(/obj/item/gun/ballistic/bow/energy/shadow_caster)
	return ..()

/datum/action/cooldown/spell/toggle/shadow_caster/can_cast_spell(feedback)
	if(!owner.get_empty_held_indexes() && !active)
		if(feedback)
			to_chat(owner, span_warning("You need an empty hand for this!"))
		return FALSE
	return ..()

/datum/action/cooldown/spell/toggle/shadow_caster/Enable()
	owner.balloon_alert(owner, "Crxkna")
	owner.visible_message(span_warning("[owner]'s arm contorts into a bow!"), span_velvet("You transform your arm into a bow."))
	playsound(owner, 'yogstation/sound/magic/pass_create.ogg', 50, 1)
	if(!bow)
		bow = new (owner)
	owner.put_in_hands(bow)

/datum/action/cooldown/spell/toggle/shadow_caster/Disable()
	owner.balloon_alert(owner, "Haoo")
	owner.visible_message(span_warning("[owner]'s bow transforms back!"), span_velvet("You dispel the bow."))
	playsound(owner, 'yogstation/sound/magic/pass_dispel.ogg', 50, 1)
	if(bow)
		bow.moveToNullspace()

//////////////////////////////////////////////////////////////////////////
//----------------------Temporary Darkness in aoe-----------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/darkness_smoke
	name = "Blinding Miasma"
	desc = "Spews a cloud of smoke which will blind enemies and provide cover from light."
	panel = "Darkspawn"
	button_icon_state = "blinding_miasma"
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"

	sound = 'sound/effects/bamf.ogg'
	psi_cost = 35
	cooldown_time = 45 SECONDS
	antimagic_flags = NONE
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = NONE
	///The size of the smoke cloud spawned by the ability
	var/range = 4

/datum/action/cooldown/spell/darkness_smoke/cast(mob/living/carbon/human/user) //Extremely hacky ---- (oh god, it really is)
	. = ..()
	owner.balloon_alert(owner, "Hwlok'krotho")
	owner.visible_message(span_warning("[owner] bends over and bellows out a cloud of black smoke!"), span_velvet("You expel a vast cloud of blinding smoke."))
	var/obj/item/reagent_containers/glass/beaker/large/B = new /obj/item/reagent_containers/glass/beaker/large(get_turf(owner)) //hacky
	B.reagents.clear_reagents() //Just in case!
	B.invisibility = INFINITY //This ought to do the trick
	B.reagents.add_reagent(/datum/reagent/darkspawn_darkness_smoke, 50)
	var/datum/effect_system/fluid_spread/smoke/chem/darkspawn/S = new //it doesn't actually block light anyways, so let's not block vision either
	S.attach(B)
	if(S)
		S.set_up(range, location = B.loc, carry = B.reagents)
		S.start()
	qdel(B)

//////////////////////////////////////////////////////////////////////////
//----------------------------Trap abilities----------------------------//
//////////////////////////////////////////////////////////////////////////
//Reskinned punji sticks that don't stun for as long
/datum/action/cooldown/spell/pointed/darkspawn_build/trap
	name = "Psi Trap"
	desc = "Stitch together shadows into a trap."
	button_icon_state = "psi_trap_damage"
	language_final = "DEBUGIFY"

/datum/action/cooldown/spell/pointed/darkspawn_build/trap/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return .
	var/turf/target_loc = get_turf(cast_on)
	var/obj/structure/trap/darkspawn/trap = locate() in target_loc
	if(trap)
		owner.balloon_alert(owner, "There is already a trap there")
		return . | SPELL_CANCEL_CAST

//Reskinned punji sticks that don't stun for as long
/datum/action/cooldown/spell/pointed/darkspawn_build/trap/damage
	name = "Psi Trap (damage)"
	desc = "Stitch together shadows into a trap that deals damage to non-ally that crosses it."
	button_icon_state = "psi_trap_damage"
	object_type = /obj/structure/trap/darkspawn/damage
	language_final = "ksha"

//Reskinned bear trap that doesn't slow as much and can't be picked up
/datum/action/cooldown/spell/pointed/darkspawn_build/trap/legcuff
	name = "Psi Trap (restrain)"
	desc = "Stitch together shadows into a trap that restrains the legs of any non-ally that crosses it."
	button_icon_state = "psi_trap_bear"
	object_type = /obj/structure/trap/darkspawn/legcuff
	language_final = "xcrak"

//Discombobulates people
/datum/action/cooldown/spell/pointed/darkspawn_build/trap/nausea
	name = "Psi Trap (nausea)"
	desc = "Stitch together shadows into a trap that makes any non-ally that crosses it sick to their stomach."
	button_icon_state = "psi_trap_nausea"
	object_type = /obj/structure/trap/darkspawn/nausea
	language_final = "guhxo"

//Discombobulates people
/datum/action/cooldown/spell/pointed/darkspawn_build/trap/teleport
	name = "Psi Trap (teleport)"
	desc = "Stitch together shadows into a trap that teleports any non-ally to a random location on the station."
	button_icon_state = "psi_trap_teleport"
	object_type = /obj/structure/trap/darkspawn/teleport
	language_final = "hwkwo"

//////////////////////////////////////////////////////////////////////////
//-------------------It's a jaunt, what do you expect-------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/jaunt/ethereal_jaunt/void_jaunt
	name = "Void Jaunt"
	desc = "Move through the veil for a time, avoiding mortal eyes and lights."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "void_jaunt"

	antimagic_flags = NONE
	panel = "Darkspawn"
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	psi_cost = 70
	cooldown_time = 90 SECONDS

	sound = 'sound/effects/bamf.ogg'
	exit_jaunt_sound = 'yogstation/sound/magic/devour_will_begin.ogg'
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/ninja/cloak
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/ninja

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/void_jaunt/do_steam_effects(turf/loc)
	return FALSE

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/void_jaunt/cast(mob/living/cast_on)
	. = ..()
	owner.balloon_alert(owner, "Vxklu'wop sla'txhaka")

//////////////////////////////////////////////////////////////////////////
//--------------------------Targeted Teleport---------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/phase_jump/void_jump
	name = "Void jump"
	desc = "A short range targeted teleport."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "shadow_jump"
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	panel = "Darkspawn"
	sound = 'sound/magic/voidblink.ogg'

	psi_cost = 20
	cooldown_time = 20 SECONDS
	cast_range = 7
	active_msg = span_velvet("You prepare to take a step through the void.")
	deactive_msg = span_notice("You relax your mind.")
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_CASTABLE_AS_BRAIN
	beam_icon = "curse0"

/datum/action/cooldown/spell/pointed/phase_jump/void_jump/InterceptClickOn(mob/living/user, params, atom/target)
	. = ..()
	if(.)
		owner.balloon_alert(owner, "Vxklu'wop")

//////////////////////////////////////////////////////////////////////////
//-----------------------------AOE ice field----------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/aoe/permafrost
	name = "Permafrost"
	desc = "Banish heat from the surrounding terrain, freezing it instantly."
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "permafrost"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	panel = "Darkspawn"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags =  AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_HUMAN
	psi_cost = 65
	cooldown_time = 60 SECONDS
	sound = 'yogstation/sound/ambience/antag/veil_mind_scream.ogg'
	aoe_radius = 3

/datum/action/cooldown/spell/aoe/permafrost/cast(atom/cast_on)
	. = ..()
	owner.balloon_alert(owner, "Syn'thxklp")
	if(isliving(owner))
		var/mob/living/target = owner
		target.extinguish_mob()

/datum/action/cooldown/spell/aoe/permafrost/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!isopenturf(victim))
		return
	var/turf/open/target = victim
	target.MakeSlippery(TURF_WET_PERMAFROST, 10 SECONDS)

//////////////////////////////////////////////////////////////////////////
//------------------------Chameleon projector---------------------------//
//////////////////////////////////////////////////////////////////////////
/datum/action/cooldown/spell/pointed/disguise //chameleon projector as a spell
	name = "Shadow disguise"
	desc = "Restrain a target's mental faculties, preventing speech and actions of any kind for a moderate duration."
	panel = "Darkspawn"
	button_icon_state = "glare"
	button_icon = 'yogstation/icons/mob/actions.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	antimagic_flags = MAGIC_RESISTANCE_MIND
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED | AB_CHECK_LYING
	spell_requirements = SPELL_REQUIRES_HUMAN
	cooldown_time = 30 SECONDS
	ranged_mousepointer = 'icons/effects/mouse_pointers/gaze_target.dmi'
	///Item stored by the projector
	var/obj/item/chameleon/handler
	///boolean, if the chameleon projector is active
	var/active = FALSE

/datum/action/cooldown/spell/pointed/disguise/New(Target)
	. = ..()
	handler = new()

/datum/action/cooldown/spell/pointed/disguise/before_cast(atom/cast_on)
	. = ..()
	if(!handler)
		return . | SPELL_CANCEL_CAST
	if(!cast_on || !isobj(cast_on))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/pointed/disguise/cast(atom/cast_on)
	. = ..()
	if(!handler)
		return
	if(active)
		handler.disrupt()
		return

	handler.afterattack(cast_on, owner, TRUE)
	handler.toggle(owner)
