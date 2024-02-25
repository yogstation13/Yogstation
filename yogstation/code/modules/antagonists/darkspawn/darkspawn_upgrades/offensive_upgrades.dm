/datum/psi_web/shadow_crash
	name = "Shadow crash"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = FIGHTER
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/pointed/shadow_crash)

/datum/psi_web/demented_outburst
	name = "Demented outburst"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = FIGHTER
	menu_tab = STORE_OFFENSE
	learned_abilities = list(/datum/action/cooldown/spell/aoe/demented_outburst)

//Using shadow tendrils will now form two tendrils if possible.
//Attacking with one set of tendrils will attack with the other.
//This also speeds up most actions they have.
//Check fighter_abilities.dm for the effect.
/datum/psi_web/twin_tendrils
	name = "\'Duality\' Sigils"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = FIGHTER
	menu_tab = STORE_OFFENSE

	var/datum/action/cooldown/spell/toggle/shadow_tendril/spell

/datum/psi_web/twin_tendrils/on_gain()
	spell = locate() in owner.actions
	if(spell)
		spell.twin = TRUE
	else
		remove(TRUE)

/datum/psi_web/twin_tendrils/on_loss()
	if(spell)
		spell.twin = FALSE
		spell = null
