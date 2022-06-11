/obj/item/hog_item/book
	name = "Cult Book"
	desc = "A strange tome, filled with dark magic."
	icon_state = "book"
	original_icon = "book"
	force = 13
	damtype = BURN
	var/charges = 0
	var/casting = FALSE
	var/stam_damage = 49
	
/obj/item/hog_item/book/attack_self(mob/user)
	return ///Here will be code for making spells

/obj/item/hog_item/book/attack(mob/M, mob/living/carbon/human/user)
	if(!ishuman(M))
		return ..()
	var/mob/living/carbon/human/H = M
	if(user == H)
		return
	if(user.a_intent == INTENT_DISARM)
		if(iscultist(H) || H.anti_magic_check() || HAS_TRAIT(H, TRAIT_MINDSHIELD) || is_servant_of_ratvar(H))  ///Mindshielded nerds just get attacked, antimagic dudes and enemy cult members also
			return ..()
		var/stamina_damage = H.getStaminaLoss()
		if(stamina_damage >= 85)
			var/stunforce = 7 SECONDS //A bit less if alredy stunned
			if(!H.IsParalyzed())
				to_chat(H, span_warning("You feel pure horror inflitrating your mind!"))
				stunforce = 11 SECONDS
			H.Paralyze(stunforce)
		else
			H.apply_damage(stam_damage, STAMINA, BODY_ZONE_CHEST, 0)
			addtimer(CALLBACK(src, H,  .proc/calm_down), 2 SECONDS)	

	if(user.a_intent == INTENT_GRAB)
		return ///Here will be handcuffing code.

	if(user.a_intent == INTENT_HELP)
		return  ///Here will be giving power to allies and allied structures.

/obj/item/hog_item/book/proc/calm_down(mob/living/carbon/human/target)
	if(!target)
		return
	target.apply_damage(stam_damage, STAMINA, BODY_ZONE_CHEST, 0)

			





