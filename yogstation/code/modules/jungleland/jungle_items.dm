/obj/item/reagent_containers/herb
	possible_transfer_amounts = list()
	var/preset_herb_type
	var/herb_type
	
/obj/item/reagent_containers/herb/attack_self(mob/user)
	if(!canconsume(user, user))
		return ..()
	
/obj/item/dummy_toxic_buildup
	name = "test dummy"
	desc = "what"
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "damage_orb"

/obj/item/dummy_toxic_buildup/attack_self(mob/user)
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	living_user.apply_status_effect(/datum/status_effect/toxic_buildup)
		