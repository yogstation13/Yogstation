/obj/item/shard/shank
	name = "shank"
	desc = "A nasty looking shard of glass. There's cloth over one of the ends."
	icon = 'yogstation/icons/obj/weapons.dmi'
	icon_state = "shank"
	force = 10 //Average force
	throwforce = 10
	item_state = "shard-glass"
	attack_verb = list("stabbed", "shanked", "sliced", "cut")
	siemens_coefficient = 0 //Means it's insulated
	embedding = list("embedded_pain_multiplier" = 1.5, "embed_chance" = 10, "embedded_fall_chance" = 45)
	sharpness = IS_SHARP
