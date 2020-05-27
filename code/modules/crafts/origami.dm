
//Origami Volume 1 stuff

/obj/item/storage/paperhouse
	name = "paper house"
	desc = "Fit for a tiny person or your favorite action figure. Watch out for paper cuts!"
	icon = 'icons/obj/storage.dmi'
	icon_state = "paperhouse"
	sharpness = IS_SHARP
	resistance_flags = FLAMMABLE
	max_integrity = 40

/obj/item/storage/book/fake_spellbook
	name = "spellbook"
	desc = "Wait, this one is completely blank!"
	resistance_flags = FLAMMABLE
	max_integrity = 100

/obj/item/melee/paper_sword
	name = "paper sword"
	desc = "Numerous sheets of paper carefully folded into the shape of a sword. Watch out for paper cuts!"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "paper_sword"
	item_state = "paper_sword"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 4
	throwforce = 1
	throw_speed = 2
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("poked", "slightly cut", "given a paper cut to",) //imagine attacking someone with paper
	siemens_coefficient = 0 //Means it's insulated
	sharpness = IS_SHARP
	resistance_flags = FLAMMABLE
	max_integrity = 30

/obj/item/melee/paper_sword/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is giving themself too many papercuts! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return(BRUTELOSS)

/obj/item/throwing_star/paper
	name = "paper throwing star"
	desc = "I remember making these in elementary school!"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "paper-star"
	item_state = "paper-star"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	force = 2
	throwforce = 4
	throw_speed = 4
	embedding = list("embedded_pain_multiplier" = 2, "embed_chance" = 10, "embedded_fall_chance" = 80)
	w_class = WEIGHT_CLASS_SMALL
	sharpness = IS_SHARP
	resistance_flags = FLAMMABLE
	max_integrity = 25
	hitsound = 'sound/weapons/tap.ogg'

/obj/item/restraints/handcuffs/paper
	name = "paper handcuffs"
	desc = "Handcuffs made out of paper. Do these even work?"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "papercuff"
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 2
	throw_range = 3
	materials = list(/obj/item/paper)
	breakouttime = 5 SECONDS
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	sharpness = IS_SHARP
	resistance_flags = FLAMMABLE
	max_integrity = 15

/obj/item/card/id/paper
	name = "paper identification card"
	desc = "An ID card made entirely out of a single sheet of paper! It is so masterfully and carefully folded that it seems to have maintenance access!"
	icon = 'icons/obj/card.dmi'
	icon_state = "paperid"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	resistance_flags = FLAMMABLE
	access = list(ACCESS_MAINT_TUNNELS)
	throw_speed = 0.5 
