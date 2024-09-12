/datum/artifact_effect/soap
	examine_hint = "Smells nice."
	examine_discovered = "Seems to clean things."
	artifact_size = ARTIFACT_SIZE_TINY
	type_name = "Cleaning Effect"

/datum/artifact_effect/soap/setup()
	our_artifact.holder.AddComponent(/datum/component/slippery, 80)
	our_artifact.holder.AddComponent(/datum/component/cleaner, 2 SECOND, 0.1, pre_clean_callback=CALLBACK(src, PROC_REF(should_clean)), on_cleaned_callback=CALLBACK(src, TYPE_PROC_REF(/datum/artifact_effect/soap,sorry_nothing)))

/datum/artifact_effect/soap/proc/should_clean(datum/cleaning_source, atom/atom_to_clean, mob/living/cleaner)
	if(isitem(our_artifact.holder))
		var/obj/item/yep_its_an_item = our_artifact.holder
		return yep_its_an_item.check_allowed_items(atom_to_clean)
	return FALSE
/datum/artifact_effect/soap/proc/sorry_nothing(datum/source, atom/target, mob/living/user, clean_succeeded)
	return
