// This is the dumbest fucking thing I have ever programmed t. Altoids
#define EGG_MAXBRUTEMOD 1.25
#define EGG_MINBRUTEMOD 0.8
#define EGG_BRUTELAMBDA 0.042
/datum/species/egg
	// Egghead humanoids composed of eggs and stale memes
	name = "Eggperson"
	id = "egg"
	say_mod = "blurbles"
	fixed_mut_color = "FFE7C9"
	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,0), OFFSET_EARS = list(0,2), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,2), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))
	species_traits = list(EYECOLOR,LIPS, MUTCOLORS)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	brutemod = 1.25 // not the toughest egg in the dozen (handled by the #defines above)
	heatmod = 1.1 // weak to being boiled
	default_features = list()
	changesource_flags = MIRROR_BADMIN // keeping it to just being an adminbus race for now
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/omelette
	skinned_type = /obj/item/stack/sheet/animalhide/egg
	exotic_blood = /datum/reagent/consumable/eggyolk
	disliked_food = GROSS | DAIRY | EGG
	liked_food = MEAT // Eggpeople are carnivores.
	screamsound = 'yogstation/sound/voice/eggperson/egg_scream.ogg' // (Hopefully) the sound of an egg cracking

/datum/species/egg/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	H.grant_language(/datum/language/egg)

/datum/species/egg/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H)
	if(damagetype == BRUTE) // Dynamic brute resist based on burn damage. The more fried the egg, the harder the shell!!
		var/x = H.getFireLoss()
		brutemod = EGG_MAXBRUTEMOD - (EGG_MAXBRUTEMOD - EGG_MINBRUTEMOD) * (1 - NUM_E ** (-EGG_BRUTELAMBDA * x)) //https://www.desmos.com/calculator/uvkwjltevf
		if(H.getBruteLoss() >= 200)
			H.gib(FALSE)
			return 1
	..()

#undef EGG_MAXBRUTEMOD
#undef EGG_MINBRUTEMOD
#undef EGG_BRUTELAMBDA
