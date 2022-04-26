/obj/item/claymore/kingsword
	name = "King's sword"
	desc = "Sword of a glorious king!"
	force = 20
	throwforce = 25
	block_chance = 5
	max_integrity = 99999 //Based
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/is_disguised = FALSE

/obj/item/claymore/kingsword/pickup(mob/living/user)
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
		desc = "A useless plastic sword. Although it looks very realistic..."
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
		user.AdjustParalyzed(1 SECONDS)


