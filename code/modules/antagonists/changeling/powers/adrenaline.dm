/datum/action/changeling/adrenaline
	name = "Adrenaline Sacs"
	desc = "We evolve additional sacs of adrenaline throughout our body. Costs 20 chemicals." // monkestation edit
	helptext = "Makes you stun immune for 20 seconds and grants you a burst of speed. Can be used while unconscious. Mildly toxic. Maximum stack duration of a minute." // monkestation edit
	button_icon_state = "adrenaline"
	chemical_cost = 20 // monkestation edit
	dna_cost = 2
	req_human = TRUE
	req_stat = UNCONSCIOUS
	disabled_by_fire = FALSE

//Recover from stuns.
/datum/action/changeling/adrenaline/sting_action(mob/living/user)
	..()
	user.apply_status_effect(/datum/status_effect/changeling_adrenaline) // monkestation addition
	/* MONKESTATION REMOVAL START
	to_chat(user, span_notice("Energy rushes through us."))
	if(HAS_TRAIT_FROM(user, TRAIT_IMMOBILIZED, STAMINA))
		user.exit_stamina_stun()
	user.SetAllImmobility(0) // monkestation edit
	user.set_resting(FALSE, silent = TRUE, instant = TRUE) // monkestation edit
	user.reagents.add_reagent(/datum/reagent/medicine/changelingadrenaline, 4) //20 seconds
	user.reagents.add_reagent(/datum/reagent/medicine/changelinghaste, 3) //6 seconds, for a really quick burst of speed
	MONKESTATION REMOVAL END */
	return TRUE
