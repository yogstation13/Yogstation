#define FACIAL_HAIR "Facial hair"
#define HEAD_HAIR "Hair"
#define RACE "Race"
#define GENDER "Gender"
#define FACE_HAIR_COLOR "Facial hair color"
#define HAIR_COLOR "Hair color"
#define EYE_COLOR "Eye color"
#define SKIN_COLOR "Skintone"
#define MUTANT_COLOR "Mutant color"
#define NAME "Name"

//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	density = FALSE
	anchored = TRUE
	max_integrity = 200
	integrity_failure = 100

/obj/structure/mirror/Initialize(mapload)
	. = ..()
	if(icon_state == "mirror_broke" && !broken)
		obj_break(null, mapload)

/obj/structure/mirror/proc/get_choices(mob/living/carbon/human/H)
	. = list()
	var/datum/species/S = H.dna.species
	if((FACEHAIR in S.species_traits))
		. += list(FACIAL_HAIR = list("select a facial hair style", GLOB.facial_hair_styles_list))
		. += list(FACE_HAIR_COLOR)
	if((HAIR in S.species_traits))
		. += list(HEAD_HAIR = list("select a hair style", GLOB.hair_styles_list))
		. += list(HAIR_COLOR)

// for things that dont use a list style syntax
/obj/structure/mirror/proc/preapply_choices(selectiontype, mob/living/carbon/human/H)
	switch(selectiontype)
		if(FACE_HAIR_COLOR)
			var/new_hair_color = input(H, "Choose your face hair color", "Face Hair Color","#"+H.facial_hair_color) as color|null
			if(!new_hair_color)
				return TRUE
			H.facial_hair_color = sanitize_hexcolor(new_hair_color)
			H.dna.update_ui_block(DNA_FACIAL_HAIR_COLOR_BLOCK)
			H.update_hair()
			return TRUE
		if(HAIR_COLOR)
			var/new_hair_color = input(H, "Choose your hair color", "Hair Color","#"+H.hair_color) as color|null
			if(!new_hair_color)
				return TRUE
			H.hair_color = sanitize_hexcolor(new_hair_color)
			H.dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
			H.update_hair()
			return TRUE

/obj/structure/mirror/proc/apply_choices(selectiontype, selection, mob/living/carbon/human/H)
	if(!selection) // Prevent null-fuckups
		return
	switch(selectiontype)
		if(FACIAL_HAIR)
			H.facial_hair_style = selection
			H.update_hair()
			return TRUE
		if(HEAD_HAIR)
			H.hair_style = selection
			H.update_hair()
			return TRUE

/obj/structure/mirror/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(broken || !Adjacent(user))
		return

	if(user && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/choices = get_choices(H) // Get the choices you can change
		if(!choices) // No Choices
			return
		var/selection = input(user, "Choose your appearance", "Grooming") as null|anything in choices
		if(!selection || !(selection in choices))
			return
		if(preapply_choices(selection, H))
			return TRUE
		var/stylelist = choices[selection] // Get subchoices (aka the styles you could apply)
		var/newstyle = input(user, stylelist[1], "Grooming") as null|anything in stylelist[2]
		if(!newstyle)
			return
		. = apply_choices(selection, newstyle, H) // Now apply the style

/obj/structure/mirror/examine_status(mob/user)
	if(broken)
		return list()// no message spam
	return ..()

/obj/structure/mirror/obj_break(damage_flag, mapload)
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		icon_state = "mirror_broke"
		if(!mapload)
			playsound(src, "shatter", 70, 1)
		if(desc == initial(desc))
			desc = "Oh no, seven years of bad luck!"
		broken = TRUE

/obj/structure/mirror/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!disassembled)
			new /obj/item/shard( src.loc )
	qdel(src)

/obj/structure/mirror/welder_act(mob/living/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return FALSE

	if(!broken)
		return TRUE

	if(!I.tool_start_check(user, amount=0))
		return TRUE

	to_chat(user, span_notice("You begin repairing [src]..."))
	if(I.use_tool(src, user, 10, volume=50))
		to_chat(user, span_notice("You repair [src]."))
		broken = 0
		icon_state = initial(icon_state)
		desc = initial(desc)

	return TRUE

/obj/structure/mirror/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		if(BURN)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)


/obj/structure/mirror/magic
	name = "magic mirror"
	desc = "Turn and face the strange... face."
	icon_state = "magic_mirror"
	var/list/choosable_races = list()

/obj/structure/mirror/magic/New()
	if(!choosable_races.len)
		for(var/speciestype in subtypesof(/datum/species))
			var/datum/species/S = speciestype
			if(initial(S.changesource_flags) & MIRROR_MAGIC)
				choosable_races += initial(S.id)
	..()

/obj/structure/mirror/magic/lesser/New()
	choosable_races = GLOB.roundstart_races.Copy()
	..()

/obj/structure/mirror/magic/badmin/New()
	for(var/speciestype in subtypesof(/datum/species))
		var/datum/species/S = speciestype
		if(initial(S.changesource_flags) & MIRROR_BADMIN)
			choosable_races += initial(S.id)
	..()

/obj/structure/mirror/magic/get_choices(mob/living/carbon/human/H)
	. = ..()
	. += list(RACE = list("select a new race", choosable_races))
	. += list(GENDER = list("Select a new gender", list()))
	var/datum/species/S = H.dna.species
	if(!(AGENDER in S.species_traits || FGENDER in S.species_traits || MGENDER in S.species_traits))
		.[GENDER][2] = list(MALE, FEMALE)
	if(!(NOEYESPRITES in S.species_traits))
		. += list(EYE_COLOR)
	if(S.use_skintones)
		. += list(SKIN_COLOR = list("select a new skintone", GLOB.skin_tones))
	if((MUTCOLORS in S.species_traits) && !(NOCOLORCHANGE in S.species_traits))
		. += list(MUTANT_COLOR)
	. += list(NAME)

/obj/structure/mirror/magic/preapply_choices(selectiontype, mob/living/carbon/human/H)
	. = ..()
	switch(selectiontype)
		if(EYE_COLOR)
			var/new_eye_color = input(H, "Choose your eye color", "Eye Color","#"+H.eye_color) as color|null
			if(!new_eye_color)
				return TRUE
			H.eye_color = sanitize_hexcolor(new_eye_color)
			H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
			H.update_body()
			return TRUE
		if(NAME)
			var/newname = sanitize_name(reject_bad_text(stripped_input(H, "Who are we again?", "Name change", H.name, MAX_NAME_LEN)))
			if(!newname)
				return TRUE
			H.real_name = newname
			H.name = newname
			if(H.dna)
				H.dna.real_name = newname
			if(H.mind)
				H.mind.name = newname
			return TRUE
		if(MUTANT_COLOR)
			var/new_mutantcolor = input(H, "Choose your skin color:", "Race change","#"+H.dna.features["mcolor"]) as color|null
			if(!new_mutantcolor)
				return TRUE
			var/temp_hsv = RGBtoHSV(new_mutantcolor)
			if(ReadHSV(temp_hsv)[3] >= ReadHSV("#7F7F7F")[3]) // mutantcolors must be bright
				H.dna.features["mcolor"] = sanitize_hexcolor(new_mutantcolor)
			else
				to_chat(H, span_notice("Invalid color. Your color is not bright enough."))
			H.update_body()
			H.update_hair()
			H.update_body_parts()
			H.update_mutations_overlay() // no hulk lizard

			return TRUE

/obj/structure/mirror/magic/apply_choices(selectiontype, selection, mob/living/carbon/human/H)
	. = ..()
	var/datum/species/S = H.dna.species
	switch(selectiontype)
		if(GENDER)
			if(selection == FEMALE)
				H.gender = FEMALE
				to_chat(H, span_notice("Man, you feel like a woman!"))

			else if(selection == MALE)
				H.gender = MALE
				to_chat(H, span_notice("Whoa man, you feel like a man!"))
			H.dna.update_ui_block(DNA_GENDER_BLOCK)
			H.update_body()
			H.update_mutations_overlay() //(hulk male/female)
			return TRUE

		if(RACE)
			var/newrace = GLOB.species_list[selection]
			H.set_species(newrace, icon_update=0)
			if(FGENDER in S.species_traits)
				H.gender = FEMALE
			if(MGENDER in S.species_traits)
				H.gender = MALE
			if(AGENDER in S.species_traits)
				H.gender = PLURAL
			return TRUE
		if(SKIN_COLOR)
			H.skin_tone = selection
			H.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)
			H.update_body()
			H.update_body_parts()
			H.update_mutations_overlay() // no hulk lizard
			return TRUE

/obj/structure/mirror/magic/attack_hand(mob/user)
	. = ..()
	if(.)
		curse(user)

/obj/structure/mirror/magic/proc/curse(mob/living/user)
	return

#undef FACIAL_HAIR
#undef HEAD_HAIR
#undef RACE
#undef GENDER
#undef FACE_HAIR_COLOR
#undef HAIR_COLOR
#undef EYE_COLOR
#undef SKIN_COLOR
#undef MUTANT_COLOR
#undef NAME
