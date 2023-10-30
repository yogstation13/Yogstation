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
	var/range = 4

/datum/action/cooldown/spell/blindness_smoke/cast(mob/living/carbon/human/user) //Extremely hacky ---- (oh god, it really is)
	. = ..()
	user.visible_message(span_warning("[user] bends over and coughs out a cloud of black smoke!"), span_velvet("You regurgitate a vast cloud of blinding smoke."))
	var/obj/item/reagent_containers/glass/beaker/large/B = new /obj/item/reagent_containers/glass/beaker/large(user.loc) //hacky
	B.reagents.clear_reagents() //Just in case!
	B.invisibility = INFINITY //This ought to do the trick
	B.reagents.add_reagent(/datum/reagent/darkspawn_blindness_smoke, 10)
	var/datum/effect_system/fluid_spread/smoke/chem/S = new
	S.attach(B)
	if(S)
		S.set_up(range, location = B.loc, carry = B.reagents)
		S.start()
	qdel(B)

/datum/reagent/darkspawn_blindness_smoke
	name = "odd black liquid"
	description = "<::ERROR::> CANNOT ANALYZE REAGENT <::ERROR::>"
	color = "#000000" //Complete black (RGB: 0, 0, 0)
	metabolization_rate = 100 //lel

/datum/reagent/darkspawn_blindness_smoke/on_mob_life(mob/living/M)
	if(!is_darkspawn_or_veil(M))
		to_chat(M, span_warning("<b>You breathe in the black smoke, and your eyes burn horribly!</b>"))
		M.blind_eyes(5)
		if(prob(25))
			M.visible_message("<b>[M]</b> claws at their eyes!")
			M.Stun(3, 0)
			. = 1
	else
		to_chat(M, span_velvet("<b>You breathe in the black smoke, and you feel revitalized!</b>"))
		M.adjustOxyLoss(-2, 0)
		M.adjustToxLoss(-2, 0)
		. = 1
	return ..() || .
