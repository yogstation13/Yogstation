/obj/item/implant/honor
	name = "honor implant"
	desc = "For the honorable."
	activated = 0

/obj/item/implant/honor/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE) //Copied and adjusted from mindshields
	if(..())
		if(!target.mind)
			ADD_TRAIT(target, TRAIT_NOGUNS, "implant")
			return TRUE
		if(!silent)
			to_chat(target, span_notice("You feel that the use of guns would bring you shame. You no longer think that you can hold the trigger."))
		ADD_TRAIT(target, TRAIT_NOGUNS, "implant")
		return TRUE

/obj/item/implant/honor/removed(mob/target, silent = FALSE, special = 0)
	if(..())
		if(isliving(target))
			var/mob/living/L = target
			REMOVE_TRAIT(L, TRAIT_NOGUNS, "implant")
		if(target.stat != DEAD && !silent)
			to_chat(target, span_boldnotice("Your mind suddenly feels like guns are not dishonorable. You can now bear the thought of using guns."))
		return TRUE

/obj/item/implanter/honor
	name = "implanter (honor)"
	imp_type = /obj/item/implant/honor

/obj/item/implantcase/honor
	name = "implant case - 'Honor'"
	desc = "A glass case containing a honorable implant for those who seek to not use guns."
	imp_type = /obj/item/implant/honor
