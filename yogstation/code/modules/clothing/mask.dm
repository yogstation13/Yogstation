/**
  * An undroppable mask that changes the user's speech to be unintelligable
  */
/obj/item/clothing/mask/yogs/cluwne
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	alternate_screams = list('yogstation/sound/voice/cluwnelaugh1.ogg','yogstation/sound/voice/cluwnelaugh2.ogg','yogstation/sound/voice/cluwnelaugh3.ogg')
	flags_cover = MASKCOVERSEYES
	icon_state = "cluwne"
	item_state = "cluwne"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_1 = MASKINTERNALS
	item_flags = ABSTRACT | DROPDEL
	flags_inv = HIDEEARS | HIDEEYES
	modifies_speech = TRUE

	///world.time when a clune laugh was last played
	var/last_sound = 0
	///cooldown before playing another cluwne laugh
	var/delay = 15
	///if the mask should cluwne you when you put it on
	var/auto_cluwne = TRUE

/obj/item/clothing/mask/yogs/cluwne/Initialize()
	.=..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/**
  * Plays one of three cluwne laughs
  */
/obj/item/clothing/mask/yogs/cluwne/proc/play_laugh()
	if(world.time > last_sound + delay)
		var/i = rand(1,3)
		switch(i)
			if(1)
				playsound (src, 'yogstation/sound/voice/cluwnelaugh1.ogg', 30, 1)
			if(2)
				playsound (src, 'yogstation/sound/voice/cluwnelaugh2.ogg', 30, 1)
			if(3)
				playsound (src, 'yogstation/sound/voice/cluwnelaugh3.ogg', 30, 1)
		last_sound = world.time

/obj/item/clothing/mask/yogs/cluwne/handle_speech(datum/source, list/speech_args) //whenever you speak
	if(!CHECK_BITFIELD(clothing_flags, VOICEBOX_DISABLED))
		if(prob(5)) //the brain isnt fully gone yet...
			speech_args[SPEECH_MESSAGE] = pick("HELP ME!!","PLEASE KILL ME!!","I WANT TO DIE!!", "END MY SUFFERING", "I CANT TAKE THIS ANYMORE!!" ,"SOMEBODY STOP ME!!")
			play_laugh()
		if(prob(3))
			speech_args[SPEECH_MESSAGE] = pick("HOOOOINKKKKKKK!!", "HOINK HOINK HOINK HOINK!!","HOINK HOINK!!","HOOOOOOIIINKKKK!!") //but most of the time they cant speak,
			play_laugh()
		else
			speech_args[SPEECH_MESSAGE] = pick("HEEEENKKKKKK!!", "HONK HONK HONK HONK!!","HONK HONK!!","HOOOOOONKKKK!!") //More sounds,
			play_laugh()

/obj/item/clothing/mask/yogs/cluwne/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == SLOT_WEAR_MASK)
		play_laugh()
		if(auto_cluwne)
			var/mob/living/carbon/human/H = user
			H.dna.add_mutation(CLUWNEMUT)

/**
  * Togglable cluwne mask that has a small chance to turn the user into a cluwne or create a floor cluwne with the user as a target
  *
  * The logic of the cluwne mask is predetermined in [/obj/item/clothing/mask/yogs/cluwne/happy_cluwne/proc/Initialize] to prevent spamming the equip until you get a floor cluwne
  */
/obj/item/clothing/mask/yogs/cluwne/happy_cluwne
	name = "Happy Cluwne Mask"
	desc = "The mask of a poor cluwne that has been scrubbed of its curse by the Nanotrasen supernatural machinations division. Guaranteed to be 99% curse free and 99.9% not haunted. "
	item_flags = ABSTRACT
	clothing_flags = VOICEBOX_TOGGLABLE
	auto_cluwne = FALSE

	/// If active, turns the user into a cluwne
	var/does_cluwne = FALSE
	/// If active, creates a floor cluwne with the user as a target
	var/does_floor_cluwne = FALSE

/obj/item/clothing/mask/yogs/cluwne/happy_cluwne/Initialize()
	.=..()
	REMOVE_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)
	if(prob(1)) //this function pre-determines the logic of the cluwne mask. applying and reapplying the mask does not alter or change anything
		does_cluwne = TRUE
		does_floor_cluwne = FALSE
	else if(prob(0.1))
		does_cluwne = FALSE
		does_floor_cluwne = TRUE

/obj/item/clothing/mask/yogs/cluwne/happy_cluwne/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(slot == SLOT_WEAR_MASK)
		if(does_cluwne)
			log_admin("[key_name(H)] was made into a cluwne by [src]")
			message_admins("[key_name(H)] got cluwned by [src]")
			to_chat(H, span_userdanger("The masks straps suddenly tighten to your face and your thoughts are erased by a horrible green light!"))
			H.dropItemToGround(src)
			ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)
			H.cluwneify()
			qdel(src)
		else if(does_floor_cluwne)
			var/turf/T = get_turf(src)
			var/mob/living/simple_animal/hostile/floor_cluwne/S = new(T)
			S.Acquire_Victim(user)
			log_admin("[key_name(user)] summoned a floor cluwne using the [src]")
			message_admins("[key_name(user)] summoned a floor cluwne using the [src]")
			to_chat(H, span_warning("The mask suddenly slips off your face and... slides under the floor?"))
			to_chat(H, "<i>...dneirf uoy ot gnoleb ton seod tahT</i>")
			qdel(src)

/obj/item/clothing/mask/yogs/ronald
	name = "ronald mask"
	desc = "A mask worn by the popular children fast food salesman."
	clothing_flags = MASKINTERNALS
	icon_state = "ronald"
	item_state = "ronald"
	flags_cover = MASKCOVERSEYES
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDEHAIR
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/yogs/fawkes
	name = "fawkes mask"
	desc = "A mask often worn by that hacker known as 4chan."
	clothing_flags = MASKINTERNALS
	icon_state = "fawkes"
	item_state = "fawkes"
	flags_cover = MASKCOVERSEYES
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDEEYES
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/yogs/thejester
	name = "jester mask"
	desc = "A mask often seen being worn by criminals during bank robberies."
	clothing_flags = MASKINTERNALS
	icon_state = "the_jester"
	item_state = "the_jester"
	flags_cover = MASKCOVERSEYES
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDEEYES
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/yogs/dallas
	name = "dallas mask"
	desc = "A mask often seen being worn by criminals during bank robberies."
	clothing_flags = MASKINTERNALS
	icon_state = "pddallas"
	item_state = "pddallas"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/yogs/hoxton
	name = "hoxton mask"
	desc = "A mask often seen being worn by criminals during bank robberies."
	clothing_flags = MASKINTERNALS
	icon_state = "pdhoxton"
	item_state = "pdhoxton"
	flags_cover = MASKCOVERSEYES
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDEEYES
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/yogs/robwolf
	name = "wolf mask"
	desc = "A mask often seen being worn by criminals during bank robberies."
	clothing_flags = MASKINTERNALS
	icon_state = "pdwolf"
	item_state = "pdwolf"
	flags_cover = MASKCOVERSEYES
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDEEYES
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/yogs/chains
	name = "chains mask"
	desc = "A mask often seen being worn by criminals during bank robberies."
	clothing_flags = MASKINTERNALS
	icon_state = "pdchains"
	item_state = "pdchains"
	flags_cover = MASKCOVERSEYES
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDEEYES
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/yogs/scaryclown
	name = "scary clown mask"
	desc = "A clown mask often seen being worn by sewer clowns."
	clothing_flags = MASKINTERNALS
	icon_state = "scaryclownmask"
	item_state = "scaryclownmask"
	flags_cover = MASKCOVERSEYES
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDEHAIR
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/yogs/gigglesmask
	name = "giggles mask"
	desc = "Sometimes there are some things better left off not existing, this is one of them."
	clothing_flags = MASKINTERNALS
	icon_state = "gigglesmask"
	item_state = "gigglesmask"
	flags_cover = MASKCOVERSEYES
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDEHAIR
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/yogs/bananamask
	name = "banana mask"
	desc = "Do you want a banana?"
	clothing_flags = MASKINTERNALS
	mob_overlay_icon = 'yogstation/icons/mob/large-worn-icons/64x64/masks.dmi'
	icon_state = "bananamask"
	item_state = "bananamask"
	worn_x_dimension = 64
	worn_y_dimension = 64
	flags_cover = MASKCOVERSEYES
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDEHAIR
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/yogs/richard
	name = "rooster mask"
	desc = "Perfect mask for killing russian mob thugs!"
	clothing_flags = MASKINTERNALS
	flags_inv = HIDEEARS|HIDEFACE|HIDEFACIALHAIR|HIDEHAIR
	icon_state = "richard"
	item_state = "richard"
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/yogs/freddy
	name = "brown bear mask"
	desc = "A mask representing a old pizza place mascot."
	clothing_flags = MASKINTERNALS
	flags_inv = HIDEEARS|HIDEFACE|HIDEFACIALHAIR|HIDEHAIR
	icon_state = "freddy"
	item_state = "freddy"
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/yogs/bonnie
	name = "purple bunny mask"
	desc = "A mask representing a old pizza place mascot."
	clothing_flags = MASKINTERNALS
	flags_inv = HIDEEARS|HIDEFACE|HIDEFACIALHAIR|HIDEHAIR
	icon_state = "bonnie"
	item_state = "bonnie"
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/yogs/chica
	name = "yellow chicken mask"
	desc = "A mask representing a old pizza place mascot."
	clothing_flags = MASKINTERNALS
	flags_inv = HIDEEARS|HIDEFACE|HIDEFACIALHAIR|HIDEHAIR
	icon_state = "chica"
	item_state = "chica"
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/yogs/foxy
	name = "red fox mask"
	desc = "A mask representing a old pizza place mascot."
	clothing_flags = MASKINTERNALS
	flags_inv = HIDEEARS|HIDEFACE|HIDEFACIALHAIR|HIDEHAIR
	icon_state = "foxy"
	item_state = "foxy"
	resistance_flags = FLAMMABLE
