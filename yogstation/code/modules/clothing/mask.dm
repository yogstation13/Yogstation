/obj/item/clothing/mask/yogs/cluwne
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	flags_cover = MASKCOVERSEYES
	icon_state = "cluwne"
	item_state = "cluwne"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_1 = MASKINTERNALS
	item_flags = ABSTRACT | DROPDEL
	flags_inv = HIDEEARS|HIDEEYES
	var/voicechange = TRUE
	var/last_sound = 0
	var/delay = 15

/obj/item/clothing/mask/yogs/cluwne/Initialize()
	.=..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/mask/yogs/cluwne/proc/play_laugh1()
	if(world.time - delay > last_sound)
		playsound (src, 'yogstation/sound/voice/cluwnelaugh1.ogg', 30, 1)
		last_sound = world.time

/obj/item/clothing/mask/yogs/cluwne/proc/play_laugh2()
	if(world.time - delay > last_sound)
		playsound (src, 'yogstation/sound/voice/cluwnelaugh2.ogg', 30, 1)
		last_sound = world.time

/obj/item/clothing/mask/yogs/cluwne/proc/play_laugh3()
	if(world.time - delay > last_sound)
		playsound (src, 'yogstation/sound/voice/cluwnelaugh3.ogg', 30, 1)
		last_sound = world.time

/obj/item/clothing/mask/yogs/cluwne/equipped(mob/user, slot) //when you put it on
	var/mob/living/carbon/C = user
	if((C.wear_mask == src) && (voicechange))
		play_laugh1()
	return ..()

/obj/item/clothing/mask/yogs/cluwne/handle_speech(datum/source, list/speech_args) //whenever you speak
	if(voicechange)
		if(prob(5)) //the brain isnt fully gone yet...
			speech_args[SPEECH_MESSAGE] = pick("HELP ME!!","PLEASE KILL ME!!","I WANT TO DIE!!", "END MY SUFFERING", "I CANT TAKE THIS ANYMORE!!" ,"SOMEBODY STOP ME!!")
			play_laugh2()
		if(prob(3))
			speech_args[SPEECH_MESSAGE] = pick("HOOOOINKKKKKKK!!", "HOINK HOINK HOINK HOINK!!","HOINK HOINK!!","HOOOOOOIIINKKKK!!") //but most of the time they cant speak,
			play_laugh3()
		else
			speech_args[SPEECH_MESSAGE] = pick("HEEEENKKKKKK!!", "HONK HONK HONK HONK!!","HONK HONK!!","HOOOOOONKKKK!!") //More sounds,
			play_laugh1()

/obj/item/clothing/mask/yogs/cluwne/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == SLOT_WEAR_MASK)
		var/mob/living/carbon/human/H = user
		H.dna.add_mutation(CLUWNEMUT)
	return

/obj/item/clothing/mask/yogs/cluwne/happy_cluwne
	name = "Happy Cluwne Mask"
	desc = "The mask of a poor cluwne that has been scrubbed of its curse by the Nanotrasen supernatural machinations division. Guaranteed to be %99 curse free and %99.9 not haunted. "
	flags_1 = MASKINTERNALS
	alternate_screams = list('yogstation/sound/voice/cluwnelaugh1.ogg','yogstation/sound/voice/cluwnelaugh2.ogg','yogstation/sound/voice/cluwnelaugh3.ogg')
	item_flags = ABSTRACT
	var/can_cluwne = FALSE
	var/is_cursed = FALSE //i don't care that this is *slightly* memory wasteful, it's just one more byte and it's not like some madman is going to spawn thousands of these
	var/is_very_cursed = FALSE

/obj/item/clothing/mask/yogs/cluwne/happy_cluwne/Initialize()
	.=..()
	REMOVE_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)
	if(prob(1)) //this function pre-determines the logic of the cluwne mask. applying and reapplying the mask does not alter or change anything
		is_cursed = TRUE
		is_very_cursed = FALSE
	else if(prob(0.1))
		is_cursed = FALSE
		is_very_cursed = TRUE

/obj/item/clothing/mask/yogs/cluwne/happy_cluwne/attack_self(mob/user)
	voicechange = !voicechange
	to_chat(user, "<span class='notice'>You turn the voice box [voicechange ? "on" : "off"]!</span>")
	if(voicechange)
		play_laugh1()

/obj/item/clothing/mask/yogs/cluwne/happy_cluwne/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(slot == SLOT_WEAR_MASK)
		if(is_cursed && can_cluwne) //logic predetermined
			log_admin("[key_name(H)] was made into a cluwne by [src]")
			message_admins("[key_name(H)] got cluwned by [src]")
			to_chat(H, "<span class='userdanger'>The masks straps suddenly tighten to your face and your thoughts are erased by a horrible green light!</span>")
			H.dropItemToGround(src)
			H.cluwneify()
			qdel(src)
		else if(is_very_cursed && can_cluwne)
			var/turf/T = get_turf(src)
			var/mob/living/simple_animal/hostile/floor_cluwne/S = new(T)
			S.Acquire_Victim(user)
			log_admin("[key_name(user)] summoned a floor cluwne using the [src]")
			message_admins("[key_name(user)] summoned a floor cluwne using the [src]")
			to_chat(H, "<span class='warning'>The mask suddenly slips off your face and... slides under the floor?</span>")
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
	alternate_worn_icon = 'yogstation/icons/mob/large-worn-icons/64x64/masks.dmi'
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
