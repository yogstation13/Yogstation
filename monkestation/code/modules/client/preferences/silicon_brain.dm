/datum/preference/choiced/silicon_brain
	savefile_key = "silicon_brain"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL

/datum/preference/choiced/silicon_brain/init_possible_values()
	return list("MMI", "Positronic")

/datum/preference/choiced/silicon_brain/create_default_value()
	return "MMI"

/datum/preference/choiced/silicon_brain/apply_to_human(mob/living/carbon/human/target, value)
	return

/mob/living/silicon/ai/apply_prefs_job(client/player_client, datum/job/job)
	posibrain_inside = player_client.prefs.read_preference(/datum/preference/choiced/silicon_brain) == "Positronic"
	. = ..()

/mob/living/silicon/proc/make_mmi(positronic=FALSE, organic_name=null)
	var/name_to_use = organic_name
	if (!name_to_use || positronic)
		name_to_use = real_name

	var/obj/item/mmi/mmi
	if (positronic)
		mmi = new/obj/item/mmi/posibrain/unjoinable(src, /* autoping = */ FALSE)
	else
		mmi = new/obj/item/mmi(src)
		mmi.brain = new /obj/item/organ/internal/brain(mmi)
		mmi.brain.organ_flags |= ORGAN_FROZEN
		mmi.brain.name = "[name_to_use]'s brain"
	mmi.name = "[initial(mmi.name)]: [name_to_use]"
	mmi.set_brainmob(new /mob/living/brain(mmi))
	mmi.brainmob.name = name_to_use
	mmi.brainmob.real_name = name_to_use
	mmi.brainmob.container = mmi
	mmi.update_appearance()
	return mmi

/obj/item/mmi/posibrain/unjoinable/is_occupied()
	return TRUE

/obj/item/mmi/posibrain/unjoinable/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-occupied"
