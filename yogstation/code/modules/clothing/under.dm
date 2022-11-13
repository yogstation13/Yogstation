/obj/item/clothing/under/yogs/cluwne
	name = "clown suit"
	desc = "<i>'HONK!'</i>"
	alternate_screams = list('yogstation/sound/voice/cluwnelaugh1.ogg','yogstation/sound/voice/cluwnelaugh2.ogg','yogstation/sound/voice/cluwnelaugh3.ogg')
	icon_state = "cluwne"
	item_state = "cluwne"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	item_flags = DROPDEL
	can_adjust = 0

/obj/item/clothing/under/yogs/cluwne/Initialize()
	.=..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/under/yogs/cluwne/equipped(mob/living/carbon/user, slot)
	if(!ishuman(user))
		return
	if(slot == SLOT_W_UNIFORM)
		var/mob/living/carbon/human/H = user
		H.dna.add_mutation(CLUWNEMUT)
	return ..()

/obj/item/clothing/under/yogs/ronaldmcdonald
	name = "ronald mcdonald uniform"
	desc = "<i>'An old uniform that was used as a mascot in commercial advertising to make children smile while in other places slaughtering children.'</i>"
	icon_state = "ronald_s"
	item_state = "clown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/yogs/soviet_dress_uniform
	name = "soviet dress uniform"
	desc = "Seize the means of production in style!"
	icon_state = "soviet_dress_uniform"
	item_state = "soviet_dress_uniform"
	can_adjust = FALSE

/obj/item/clothing/under/yogs/lederhosen
	name = "lederhosen"
	desc = "<i>'Nothing like wearing a lederhosen for another hard day at work on a space station.'</i>"
	icon_state = "lederhosen"
	item_state = "lederhosen"
	can_adjust = FALSE
