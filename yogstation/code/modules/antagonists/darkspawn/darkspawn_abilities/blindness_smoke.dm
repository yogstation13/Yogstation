/datum/action/cooldown/spell/blindness_smoke //Spawns a cloud of smoke that blinds non-thralls/shadows and grants slight healing to shadowlings and their allies
	name = "Blindness Smoke"
	desc = "Spews a cloud of smoke which will blind enemies."
	panel = "Shadowling Abilities"
	button_icon_state = "black_smoke"
	button_icon = 'yogstation/icons/mob/actions.dmi'

	sound = 'sound/effects/bamf.ogg'
	cooldown_time = 1 MINUTES
	antimagic_flags = NONE
	panel = null
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	psi_cost = 15

/datum/action/cooldown/spell/blindness_smoke/cast(mob/living/carbon/human/user) //Extremely hacky ---- (oh god, it really is)
	. = ..()
	user.visible_message(span_warning("[user] bends over and coughs out a cloud of black smoke!"))
	to_chat(user, span_shadowling("You regurgitate a vast cloud of blinding smoke."))
	var/obj/item/reagent_containers/glass/beaker/large/B = new /obj/item/reagent_containers/glass/beaker/large(user.loc) //hacky
	B.reagents.clear_reagents() //Just in case!
	B.invisibility = INFINITY //This ought to do the trick
	B.reagents.add_reagent(/datum/reagent/shadowling_blindness_smoke, 10)
	var/datum/effect_system/fluid_spread/smoke/chem/S = new
	S.attach(B)
	if(S)
		S.set_up(4, location = B.loc, carry = B.reagents)
		S.start()
	qdel(B)
