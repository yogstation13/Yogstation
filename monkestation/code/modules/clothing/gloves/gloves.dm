/obj/item/clothing/gloves/combat/maid
	name = "combat maid sleeves"
	desc = "These 'tactical' gloves and sleeves are fireproof and electrically insulated. Warm to boot."
	icon = 'monkestation/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/gloves.dmi'
	icon_state = "syndimaid_arms"

/obj/item/clothing/gloves/color/plasmaman
	icon = 'monkestation/icons/obj/clothing/plasmaman_gloves.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/plasmaman_gloves.dmi'

/obj/item/clothing/gloves/crueltysquad_gloves
	name = "CSIJ level I gloves"
	desc = "Armor used by assassins working for Cruelty Squad, stripped of all of its functions for kids to play with."
	icon = 'monkestation/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/gloves.dmi'
	icon_state = "crueltysquad_gloves"

/obj/item/clothing/gloves/civilprotection_gloves
	name = "civil protection gloves"
	desc = "Armored gloves for beating anticitizens."
	icon = 'monkestation/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/gloves.dmi'
	icon_state = "civilprotection_gloves"

/obj/item/clothing/gloves/infinity_gloves
	name = "infinity wristbands"
	desc = "The bands are oddly moist... let's hope it's not blood."
	icon = 'monkestation/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/gloves.dmi'
	icon_state = "infinity_wrist"

/obj/item/clothing/gloves/infinity_gloves/equipped(mob/living/carbon/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_GLOVES)
		var/obj/item/bodypart/user_active_arm = user.get_active_hand()
		user_active_arm.unarmed_damage_low += 0.2
		user_active_arm.unarmed_damage_high += 0.1

/obj/item/clothing/gloves/latex/surgical
	name = "Black Latex gloves"
	desc = "Pricy sterile gloves that are thinner than latex. The lining allows for the person to operate \
	        quicker along with the faster use time of various chemical related items"
	icon = 'monkestation/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/gloves.dmi'
	icon_state = "surgeonlatex"
	armor_type = /datum/armor/surgeon
	clothing_traits = list(TRAIT_PERFECT_SURGEON, TRAIT_FASTMED)
	custom_premium_price = PAYCHECK_CREW * 6

/datum/armor/surgeon
    bio = 100
