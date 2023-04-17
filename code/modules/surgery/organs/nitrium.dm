/obj/item/organ/nitrium_tumor
	name = "adrenaline gland"
	desc = "An adrenal gland, this one is incredibly swollen."
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_ADRENAL
	icon_state = "blacktumor"
	var/datum/action/cooldown/adrenal_tumor/implant_ability
	var/mutable_appearance/ad_overlay
	var/upgraded = FALSE

/obj/item/organ/nitrium_tumor/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = FALSE)
	. = ..()
	implant_ability = new
	implant_ability.tumor = src
	implant_ability.Grant(M)
	// red glowing veins as a tell for sec, surely this is healthy for you
	ad_overlay = mutable_appearance('yogstation/icons/mob/clothing/suit/suit.dmi', "sl_shell", -UNDER_SUIT_LAYER)
	M.add_overlay(ad_overlay)

/obj/item/organ/nitrium_tumor/Remove(mob/living/carbon/M, special = 0)
	. = ..()
	if(implant_ability)
		implant_ability.Remove(M)
	M.cut_overlay(ad_overlay)
	QDEL_NULL(ad_overlay)
	qdel(src) // don't want anyone using this outside of nitrium

/datum/action/cooldown/adrenal_tumor
	name = "Adrenal Tumor"
	desc = "Overclock your adrenal gland, making you extremely stun resistant for a short period of time."
	icon_icon = 'icons/obj/surgery.dmi'
	button_icon_state = "blacktumor"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 10 SECONDS
	var/mob/living/carbon/human/holder
	var/obj/item/organ/nitrium_tumor/tumor

/datum/action/cooldown/adrenal_tumor/Grant(mob/user)
	. = ..()
	holder = user

/datum/action/cooldown/adrenal_tumor/Trigger()
	. = ..()
	if(!.)
		return

	StartCooldown()
	to_chat(holder, span_warning("Your insides churn and burn as you feel a rush of energy!"))
	holder.adjustFireLoss(10) // oof ouch my organs
	holder.adjustToxLoss(5)
	holder.adjust_disgust(35) // oh god i dont feel so good
	holder.SetStun(0)
	holder.SetKnockdown(0)
	holder.SetImmobilized(0)
	holder.SetParalyzed(0)
	holder.reagents.add_reagent(/datum/reagent/medicine/changelingadrenaline/nitrium, 10) // general antistun that doesn't provide speed boost
	if(tumor?.upgraded)
		holder.reagents.add_reagent(/datum/reagent/medicine/nitriumhaste, 4)
	holder.adjustStaminaLoss(-75)
