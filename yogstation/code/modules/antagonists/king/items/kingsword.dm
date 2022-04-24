/obj/item/kingsword
	name = "King's sword"
	desc = "Sword of a glorious king!"
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "claymore"
	item_state = "claymore"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	force = 20
	throwforce = 25
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 5
	sharpness = SHARP_EDGED
	max_integrity = 99999 //Based
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/is_disguised = FALSE

/obj/item/kingsword/pickup(mob/living/user)
	. = ..()
	if((IS_KING(user) || IS_KNIGHT(user)) && src.is_disguised)
		name = "King's sword"
		desc = "Sword of a glorious king!"
		force = 20
		throwforce = 25
		is_disguised = FALSE
		return
	if(!IS_KING(user) && !IS_KNIGHT(user) && !IS_SERVANT(user) && !src.is_disguised)
		name = "Toy sword"
		desc = "A useless plastic sword. Perhaps it looks very realistic! "
		force = 4
		throwforce = 4
		is_disguised = TRUE
		return
	if(IS_SERVANT(user))
		if(src.is_disguised)
			name = "King's sword"
			desc = "Sword of a glorious king!"
			force = 20
			throwforce = 25
			is_disguised = FALSE
		to_chat(user, span_notice("You feel unworthy to carry such a magnificent weapon!"))
		human_user.AdjustParalyzed(1 SECONDS)


