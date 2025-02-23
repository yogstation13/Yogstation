//DRG style callouts
//Useful mainly for Shaft Miners, but can be taken by anyone.
/datum/quirk/drg_callout
	name = "Miner Training"
	desc = "You arrive with a strange D.R.G.R.A.S skillchip that teaches you how to reflexively call out mining-related entities you point at."
	value = 0
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_HIDE_FROM_SCAN | QUIRK_DONT_CLONE
	mob_trait = TRAIT_MINING_CALLOUTS
	icon = FA_ICON_BULLHORN

/datum/quirk/drg_callout/add(client/client_source)
	if(!ishuman(quirk_holder))
		return
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/skillchip/drg_callout/skillchip = new
	human_holder.implant_skillchip(skillchip)
	skillchip.try_activate_skillchip()
