/obj/item/organ/internal/lungs/clockwork
	name = "clockwork diaphragm"
	desc = "A utilitarian bellows which serves to pump oxygen into an automaton's body."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "lungs-clock"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC

/obj/item/organ/internal/lungs/slime
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE
	safe_oxygen_min = 4 //We don't need much oxygen to subsist.

/obj/item/organ/internal/lungs/slime/on_life(seconds_per_tick, times_fired)
	. = ..()
	operated = FALSE

/obj/item/organ/internal/lungs/synth
	name = "heatsink"
	desc = "A device that transfers generated heat to a fluid medium to cool it down. Required to keep your synthetics cool-headed. It's shape resembles lungs." //Purposefully left the 'fluid medium' ambigious for interpretation of the character, whether it be air or fluid cooling
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "lungs-ipc"
	safe_nitro_min = 0
	safe_co2_max = 0
	safe_plasma_min = 0
	safe_plasma_max = 0
	safe_oxygen_min = 0	//What are you doing man, dont breathe with those!
	safe_oxygen_max = 0
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LUNGS
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES

/obj/item/organ/internal/lungs/synth/emp_act(severity)
	. = ..()

	if(!owner || . & EMP_PROTECT_SELF)
		return

	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)

	switch(severity)
		if(EMP_HEAVY)
			to_chat(owner, span_warning("Alert: Critical cooling system failure! Seek maintenance immediately. Error Code: 5H-17"))
			owner.adjust_bodytemperature(SYNTH_HEAVY_EMP_TEMPERATURE_POWER * TEMPERATURE_DAMAGE_COEFFICIENT)

		if(EMP_LIGHT)
			to_chat(owner, span_warning("Alert: Major cooling system failure!"))
			owner.adjust_bodytemperature(SYNTH_LIGHT_EMP_TEMPERATURE_POWER * TEMPERATURE_DAMAGE_COEFFICIENT)

/datum/design/synth_heatsink
	name = "Heatsink"
	desc = "A device that transfers generated heat to a fluid medium to cool it down. Required to keep your synthetics cool-headed. It's shape resembles lungs."
	id = "synth_lungs"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 4 SECONDS
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/organ/internal/lungs/synth
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_SYNTHETIC_ORGANS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE
