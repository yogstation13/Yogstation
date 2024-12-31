/// return additional data that should be remembered by cloning
/datum/quirk/proc/clone_data()
	return

/// create the quirk from clone data
/datum/quirk/proc/on_clone(mob/living/carbon/human/cloned_mob, client/client_source, data)
	add_to_holder(cloned_mob, TRUE, client_source)

/// Subtype quirk that has some bonus logic to give the player some sort of cybernetics
/datum/quirk/cybernetics_quirk
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_DONT_CLONE
	abstract_parent_type = /datum/quirk/cybernetics_quirk
	/// The typepath of the organ to implant.
	var/obj/item/organ/internal/cybernetic_type
	/// Weakref to the organ that was given.
	var/datum/weakref/given_organ

/datum/quirk/cybernetics_quirk/Destroy()
	given_organ = null
	return ..()

/datum/quirk/cybernetics_quirk/add_unique(client/client_source)
	if(!cybernetic_type)
		CRASH("No cybernetic_type specified for [type]")
	var/obj/item/organ/internal/new_organ = new cybernetic_type
	new_organ.Insert(quirk_holder, special = TRUE, drop_if_replaced = FALSE)
	given_organ = WEAKREF(given_organ)

/datum/quirk/cybernetics_quirk/remove()
	var/obj/item/organ/internal/quirk_organ = given_organ?.resolve()
	if(QDELETED(quirk_organ))
		return
	var/original_type = get_original_type()
	quirk_organ.Remove(quirk_holder, special = !isnull(original_type))
	qdel(quirk_organ)
	given_organ = null
	if(original_type)
		var/obj/item/organ/internal/original_organ = new original_type
		original_organ.Insert(quirk_holder, special = TRUE, drop_if_replaced = FALSE)

/datum/quirk/cybernetics_quirk/on_clone(mob/living/carbon/human/cloned_mob, client/client_source, data)
	CRASH()

/// Returns the typepath of the original organ to implant if this quirk is removed.
/datum/quirk/cybernetics_quirk/proc/get_original_type()
	return null
