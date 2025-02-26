/obj/item/organ/internal/liver/clockwork
	name = "biometallic alembic"
	desc = "A series of small pumps and boilers, designed to facilitate proper metabolism."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "liver-clock"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	alcohol_tolerance = 0
	liver_resistance = 0
	toxTolerance = 1 //while the organ isn't damaged by doing its job, it doesnt do it very well

/obj/item/organ/internal/liver/slime
	name = "endoplasmic reticulum"
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE
	organ_traits = list(TRAIT_TOXINLOVER)

/obj/item/organ/internal/liver/slime/on_life(seconds_per_tick, times_fired)
	. = ..()
	operated = FALSE

/obj/item/organ/internal/liver/synth
	name = "reagent processing unit"
	desc = "An electronic device that processes the beneficial chemicals for the synthetic user."
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "liver-ipc"
	filterToxins = FALSE //We dont filter them, we're immune to them
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LIVER
	maxHealth = 1 * STANDARD_ORGAN_THRESHOLD
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES

/obj/item/organ/internal/liver/synth/emp_act(severity)
	. = ..()

	if(!owner || . & EMP_PROTECT_SELF)
		return

	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)

	switch(severity)
		if(EMP_HEAVY)
			to_chat(owner, span_warning("Alert: Critical! Reagent processing unit failure, seek maintenance immediately. Error Code: DR-1k"))
			apply_organ_damage(SYNTH_ORGAN_HEAVY_EMP_DAMAGE, maxHealth, required_organtype = ORGAN_ROBOTIC)

		if(EMP_LIGHT)
			to_chat(owner, span_warning("Alert: Reagent processing unit failure, seek maintenance for diagnostic. Error Code: DR-0k"))
			apply_organ_damage(SYNTH_ORGAN_LIGHT_EMP_DAMAGE, maxHealth, required_organtype = ORGAN_ROBOTIC)

/datum/design/synth_liver
	name = "Reagent Processing Unit"
	desc = "An electronic device that processes the beneficial chemicals for the synthetic user."
	id = "synth_liver"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 4 SECONDS
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/organ/internal/liver/synth
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_SYNTHETIC_ORGANS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE
