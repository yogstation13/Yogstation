// This is the dumbest fucking thing I have ever programmed t. Altoids
#define EGG_MAXBRUTEMOD 1.5
#define EGG_ALPHA 0.00018
#define EGG_BETA (-0.027)
/datum/species/egg
	// Egghead humanoids composed of eggs and stale memes
	species_traits = list(MUTCOLORS)
	name = "Eggperson"
	id = "egg"
	say_mod = "blurbles"
	fixed_mut_color = "FFE7C9"
	offset_features = list(OFFSET_EARS = list(0,2), OFFSET_HEAD = list(0,2))
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	brutemod = EGG_MAXBRUTEMOD // not the toughest egg in the dozen (handled by the #defines above)
	heatmod = 1.1 // weak to being boiled
	default_features = list()
	changesource_flags = MIRROR_BADMIN | SLIME_EXTRACT | MIRROR_PRIDE | MIRROR_MAGIC
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/omelette
	skinned_type = /obj/item/stack/sheet/animalhide/egg
	exotic_blood = /datum/reagent/consumable/eggyolk
	disliked_food = GROSS | DAIRY | EGG | MICE
	liked_food = MEAT // Eggpeople are carnivores.
	screamsound = 'yogstation/sound/voice/eggperson/egg_scream.ogg' // (Hopefully) the sound of an egg cracking
	species_language_holder = /datum/language_holder/egg

/datum/species/egg/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, wound_bonus = 0, bare_wound_bonus = 0, sharpness = FALSE)
	if(damagetype == BRUTE) // Dynamic brute resist based on burn damage. The more fried the egg, the harder the shell!!
		var/x = H.getFireLoss()
		brutemod = EGG_ALPHA * x*x + EGG_BETA * x + EGG_MAXBRUTEMOD //A polynomial, to determine how much brute we take. https://www.desmos.com/calculator/dwxdxwt0rl
		if(H.getBruteLoss() >= 200) // This makes it so the hit *after* taking 200 brute kills you.
			H.gib(FALSE)
			return 1
	..()

#undef EGG_MAXBRUTEMOD
#undef EGG_ALPHA
#undef EGG_BETA
