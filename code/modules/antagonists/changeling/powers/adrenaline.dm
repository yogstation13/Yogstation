/datum/action/changeling/adrenaline
	name = "Adrenaline Sacs"
	desc = "We evolve additional sacs of adrenaline throughout our body. Costs 75 chemicals."
	helptext = "Removes all stuns instantly. Can be used while unconscious. Continued use poisons the body." //yogs - changed text to suit the below change
	button_icon_state = "adrenaline"
	chemical_cost = 75
	dna_cost = 3
	req_human = 1
	req_stat = UNCONSCIOUS
	conflicts = list(/datum/action/changeling/strained_muscles)

//Recover from stuns.
/datum/action/changeling/adrenaline/sting_action(mob/living/user)
	..()
	to_chat(user, span_notice("Energy rushes through us.[(!(user.mobility_flags & MOBILITY_STAND)) ? " We arise." : ""]"))
	user.SetSleeping(0)
	user.SetUnconscious(0)
	user.SetStun(0)
	user.SetKnockdown(0)
	user.SetImmobilized(0)
	user.SetParalyzed(0)
	user.reagents.add_reagent(/datum/reagent/medicine/changelingadrenaline, 10)
	user.reagents.add_reagent(/datum/reagent/medicine/changelinghaste, 2) //For a really quick burst of speed
	user.adjustStaminaLoss(-75)
	user.clear_stamina_regen() // We already cleared our stamina, don't continue healing
	return TRUE
