/obj/item/clothing/head/centhat
	name = "\improper CentCom hat"
	icon_state = "centcom"
	desc = "It's good to be emperor."
	item_state = "that"
	flags_inv = 0
	armor = list("melee" = 30, "bullet" = 15, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	strip_delay = 80

/obj/item/clothing/head/centhat/admiral
	name = "\improper CentCom admiral hat"
	icon_state = "admiral"
	desc = "It's good to be a god."
	item_state = "admiral"

/obj/item/clothing/head/centhat/admiral/grand
	name = "\improper CentCom grand admiral hat"
	icon_state = "grand_admiral"
	desc = "It's good to be a Q."
	item_state = "grand_admiral"

/obj/item/clothing/head/powdered_wig
	name = "powdered wig"
	desc = "A powdered wig."
	icon_state = "pwig"
	item_state = "pwig"

/obj/item/clothing/head/that
	name = "top-hat"
	desc = "It's an amish looking hat."
	icon_state = "tophat"
	item_state = "that"
	dog_fashion = /datum/dog_fashion/head
	throwforce = 1

/obj/item/clothing/head/canada
	name = "striped red tophat"
	desc = "It smells like fresh donut holes. / <i>Il sent comme des trous de beignets frais.</i>"
	icon_state = "canada"
	item_state = "canada"

/obj/item/clothing/head/redcoat
	name = "redcoat's hat"
	icon_state = "redcoat"
	desc = "<i>'I guess it's a redhead.'</i>"

/obj/item/clothing/head/mailman
	name = "mailman's hat"
	icon_state = "mailman"
	desc = "<i>'Right-on-time'</i> mail service head wear."

/obj/item/clothing/head/plaguedoctorhat
	name = "plague doctor's hat"
	desc = "These were once used by plague doctors. They're pretty much useless."
	icon_state = "plaguedoctor"
	permeability_coefficient = 0.01

/obj/item/clothing/head/hasturhood
	name = "hastur's hood"
	desc = "It's <i>unspeakably</i> stylish."
	icon_state = "hasturhood"
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/nursehat
	name = "nurse's hat"
	desc = "It allows quick identification of trained medical personnel."
	icon_state = "nursehat"
	dynamic_hair_suffix = ""

	dog_fashion = /datum/dog_fashion/head/nurse

/obj/item/clothing/head/syndicatefake
	name = "black space-helmet replica"
	icon_state = "syndicate-helm-black-red"
	item_state = "syndicate-helm-black-red"
	desc = "A plastic replica of a Syndicate agent's space helmet. You'll look just like a real murderous Syndicate agent in this! This is a toy, it is not made for use in space!"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/head/cueball
	name = "cueball helmet"
	desc = "A large, featureless white orb meant to be worn on your head. How do you even see out of this thing?"
	icon_state = "cueball"
	item_state="cueball"
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/head/snowman
	name = "Snowman Head"
	desc = "A ball of white styrofoam. So festive."
	icon_state = "snowman_h"
	item_state = "snowman_h"
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/head/justice
	name = "justice hat"
	desc = "Fight for what's righteous!"
	icon_state = "justicered"
	item_state = "justicered"
	flags_inv = HIDEHAIR|HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/justice/blue
	icon_state = "justiceblue"
	item_state = "justiceblue"

/obj/item/clothing/head/justice/yellow
	icon_state = "justiceyellow"
	item_state = "justiceyellow"

/obj/item/clothing/head/justice/green
	icon_state = "justicegreen"
	item_state = "justicegreen"

/obj/item/clothing/head/justice/pink
	icon_state = "justicepink"
	item_state = "justicepink"

/obj/item/clothing/head/rabbitears
	name = "rabbit ears"
	desc = "Wearing these makes you look useless, and only good for your sex appeal."
	icon_state = "bunny"
	dynamic_hair_suffix = ""

	dog_fashion = /datum/dog_fashion/head/rabbit


/obj/item/clothing/head/flatcap
	name = "flat cap"
	desc = "A working man's cap."
	icon_state = "flat_cap"
	item_state = "detective"


/obj/item/clothing/head/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	dog_fashion = /datum/dog_fashion/head/pirate

/obj/item/clothing/head/pirate
	var/datum/language/piratespeak/L = new

/obj/item/clothing/head/pirate/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == SLOT_HEAD)
		user.grant_language(/datum/language/piratespeak/, TRUE, TRUE, LANGUAGE_HAT)
		to_chat(user, "You suddenly know how to speak like a pirate!")

/obj/item/clothing/head/pirate/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(SLOT_HEAD) == src)
		user.remove_language(/datum/language/piratespeak/, TRUE, TRUE, LANGUAGE_HAT)
		to_chat(user, "You can no longer speak like a pirate.")

/obj/item/clothing/head/pirate/captain
	name = "pirate captain"
	icon_state = "hgpiratecap"
	item_state = "hgpiratecap"

/obj/item/clothing/head/bandana
	name = "pirate bandana"
	desc = "Yarr."
	icon_state = "bandana"
	item_state = "bandana"
	dynamic_hair_suffix = ""

/obj/item/clothing/head/bowler
	name = "bowler-hat"
	desc = "Gentleman, elite aboard!"
	icon_state = "bowler"
	item_state = "bowler"
	dynamic_hair_suffix = ""

/obj/item/clothing/head/witchwig
	name = "witch costume wig"
	desc = "Eeeee~heheheheheheh!"
	icon_state = "witch"
	item_state = "witch"
	flags_inv = HIDEHAIR

/obj/item/clothing/head/chicken
	name = "chicken suit head"
	desc = "Bkaw!"
	icon_state = "chickenhead"
	item_state = "chickensuit"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/head/griffin
	name = "griffon head"
	desc = "Why not 'eagle head'? Who knows."
	icon_state = "griffinhat"
	item_state = "griffinhat"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/head/bearpelt
	name = "bear pelt hat"
	desc = "Fuzzy."
	icon_state = "bearpelt"
	item_state = "bearpelt"

/obj/item/clothing/head/xenos
	name = "xenos helmet"
	icon_state = "xenos"
	item_state = "xenos_helm"
	desc = "A helmet made out of chitinous alien hide."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/head/fedora
	name = "fedora"
	icon_state = "fedora"
	item_state = "fedora"
	desc = "A really cool hat if you're a mobster. A really lame hat if you're not."
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/small/fedora

/obj/item/clothing/head/fedora/suicide_act(mob/user)
	if(user.gender == FEMALE)
		return 0
	var/mob/living/carbon/human/H = user
	user.visible_message("<span class='suicide'>[user] is donning [src]! It looks like [user.p_theyre()] trying to be nice to girls.</span>")
	user.say("M'lady.", forced = "fedora suicide")
	sleep(10)
	H.facial_hair_style = "Neckbeard"
	return(BRUTELOSS)

/obj/item/clothing/head/sombrero
	name = "sombrero"
	icon_state = "sombrero"
	item_state = "sombrero"
	desc = "You can practically taste the fiesta."
	flags_inv = HIDEHAIR

	dog_fashion = /datum/dog_fashion/head/sombrero

/obj/item/clothing/head/sombrero/green
	name = "green sombrero"
	icon_state = "greensombrero"
	item_state = "greensombrero"
	desc = "As elegant as a dancing cactus."
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	dog_fashion = null

/obj/item/clothing/head/sombrero/shamebrero
	name = "shamebrero"
	icon_state = "shamebrero"
	item_state = "shamebrero"
	desc = "Once it's on, it never comes off."
	dog_fashion = null

/obj/item/clothing/head/sombrero/shamebrero/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, SHAMEBRERO_TRAIT)

/obj/item/clothing/head/cone
	desc = "This cone is trying to warn you of something!"
	name = "warning cone"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cone"
	item_state = "cone"
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("warned", "cautioned", "smashed")
	resistance_flags = NONE
	dynamic_hair_suffix = ""

/obj/item/clothing/head/santa
	name = "santa hat"
	desc = "On the first day of christmas my employer gave to me!"
	icon_state = "santahatnorm"
	item_state = "that"
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	dog_fashion = /datum/dog_fashion/head/santa

/obj/item/clothing/head/jester
	name = "jester hat"
	desc = "A hat with bells, to add some merriness to the suit."
	icon_state = "jester_hat"
	dynamic_hair_suffix = ""

/obj/item/clothing/head/rice_hat
	name = "rice hat"
	desc = "Welcome to the rice fields, motherfucker."
	icon_state = "rice_hat"

/obj/item/clothing/head/lizard
	name = "lizardskin cloche hat"
	desc = "How many lizards died to make this hat? Not enough."
	icon_state = "lizard"

/obj/item/clothing/head/papersack
	name = "paper sack hat"
	desc = "A paper sack with crude holes cut out for eyes. Useful for hiding one's identity or ugliness."
	icon_state = "papersack"
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	
/obj/item/clothing/head/bombCollar
	name = "bomb collar"
	desc = "A metal collar with electronic locks designed to be worn around the neck. Can be triggered with a remote detonator."
	icon_state = "bombCollar"
	item_state = "electronic"
	strip_delay = 150
	resistance_flags = UNACIDABLE
	var/obj/item/device/collarDetonator/linked = null //The linked detonator
	var/locked = 0 //if the collar can be removed
	
/obj/item/clothing/head/bombCollar/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/screwdriver) && !locked && linked)
		user << "<span class='notice'>You unlink [src] from [linked].</span>"
		linked.linkedCollars.Remove(src)
		linked = null
		return
	..()
	
/obj/item/clothing/head/bombCollar/proc/detonate()
	audible_message("<span class='boldannounce'>[src] lets out a high-pitched squeal.</span>")
	playsound(src, "sound/machines/defib_charge.ogg", 100, 0)
	spawn(30)
		if(!iscarbon(loc) || !linked)
			audible_message("<span class='danger'>[src] lets out two beeps and falls silent.</span>")
			playsound(src, "sound/machines/defib_failed.ogg", 50, 0)
			return
		var/mob/living/carbon/H = loc
		if(!H || !istype(H))
			audible_message("<span class='danger'>[src] lets out two beeps and falls silent.</span>")
			playsound(src, "sound/machines/defib_failed.ogg", 50, 0)
			return
		explosion(H, -1, -1, 1, 1)
		H.apply_damage(200, BRUTE, "head")
		H.apply_damage(200, BURN, "head")
		if(ishuman(H))
			var/mob/living/carbon/human/HH = H
			HH.facial_hair_style = "Shaved"
			HH.hair_style = "Bald" //Hair burned away
		H.update_hair()
		H.visible_message("<span class='warning'>[H]'s bomb collar explodes!</span>", \
						  "<span class='userdanger'>Your collar explodes!</span>")
		if(flag & nodrop)
			flag &= ~nodrop
			H.unEquip(src)
		locked = 0
		qdel(src)
		return

/obj/item/clothing/head/bombCollar/pickup(mob/living/carbon/user)
	if(src.locked == 1 && flag & nodrop)
		flag &= ~nodrop
		user << "<span class='notice'>[src] blares a sharp red light as if it's just come to realize something.</span>"
		if(linked && linked.z == src.z)
			var/area/A = get_area(linked)
			linked.audible_message("[src] begins to beep rapidly.")
			linked.info = "<span class='notice'>A bomb collar has lost contact with it's captive target. The last known area is [A]."
		return
		
/obj/item/device/collarDetonator
	name = "remote collar detonator"
	desc = "A wireless detonator used to control bomb collars."
	icon_state = "locator"
	w_class = 2
	var/list/linkedCollars = list()
	var/info


/obj/item/device/collarDetonator/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/clothing/head/bombCollar))
		var/obj/item/clothing/head/bombCollar/C = W
		if(C.linked)
			user << "<span class='warning'>[C] is already linked to a detonator!</span>"
			return
		user << "<span class='notice'>You link [C] to [src] and add it to the control interface.</span>"
		var/newName = input(user, "Enter an ID for the collar.", "Collar ID")
		if(!newName)
			C.name = "[initial(C.name)] #[rand(1,99999)]"
		else
			C.name = "[initial(C.name)] - [newName]"
		linkedCollars.Add(C)
		C.linked = src
		return
	..()
/obj/item/device/collarDetonator/attack_self(mob/user as mob)
	if(!ishuman(user))
		user << "<span class='warning'>You aren't sure how to use this...</span>"
		return
	for(var/obj/item/weapon/implant/bombcollar/I in user.contents)
		I.linkedCollars = src.linkedCollars
		user << "Implant updated with the latest collars"
	switch(alert("Select an option.","Bomb Collar Control","Locks","Detonation","Status"))
		if("Locks")
			var/choice = input(user, "Select collar to change.", "Locking Control") in linkedCollars
			if(!choice || !user.canUseTopic(src))
				return
			var/obj/item/clothing/head/bombCollar/collarToLock = choice
			if(!collarToLock)
				return
			if(!iscarbon(collarToLock.loc))
				user << "<span class='warning'>That collar isn't being held or worn by anyone.</span>"
				return
			var/mob/living/carbon/C = collarToLock.loc
			if(C.head != collarToLock)
				user << "<span class='warning'>That collar isn't around someone's neck.</span>"
				return
			collarToLock.audible_message("<span class='warning'>[collarToLock] softly clicks.</span>")
			switch(collarToLock.locked)
				if(0)
					collarToLock.locked = 1
					collarToLock.flags |= NODROP
					C << "<span class='boldannounce'>[collarToLock] tightens and locks around your neck.</span>"
					message_admins("[user] locked bomb collar worn by [C]")
				if(1)
					collarToLock.locked = 0
					collarToLock.flags &= ~NODROP
					C << "<span class='boldannounce'>[collarToLock] loosens around your neck.</span>"
					message_admins("[user] unlocked bomb collar worn by [C]")
			user << "<span class='notice'>You [collarToLock.locked ? "" : "dis"]engage [collarToLock]'s locks.</span>"
			return
		if("Detonation")
			var/choice = input(user, "Select collar to detonate.", "Detonation Control") in linkedCollars
			if(!choice || !user.canUseTopic(src))
				return
			var/obj/item/clothing/head/bombCollar/collarToDetonate = choice
			if(!collarToDetonate)
				return
			if(!iscarbon(collarToDetonate.loc))
				user << "<span class='warning'>That collar isn't being held or worn by anyone.</span>"
				return
			var/mob/living/carbon/C = collarToDetonate.loc
			if(C.head != collarToDetonate)
				user << "<span class='warning'>That collar isn't around someone's neck.</span>"
				return
			switch(alert("Are you sure about this?","Bomb Collar Detonation","Proceed","Exit"))
				if("Proceed")
					if(!collarToDetonate.locked)
						user << "<span class='warning'>That collar isn't locked.</span>"
						return
					user << "<span class='notice'>Detonation signal sent.</span>"
					linkedCollars.Remove(collarToDetonate)
					collarToDetonate.detonate()
					message_admins("[user] detonated bomb collar worn by [C]")
				if("Exit")
					return
			return
		if("Status")
			user << "<span class='notice'><b>Bomb Collar Status Report:</b></span>"
			for(var/obj/item/clothing/head/bombCollar/C in linkedCollars)
				var/turf/T = get_turf(C)
				user << "<b>[C]:</b> [iscarbon(C.loc) ? "Worn by [C.loc], " : ""][get_area(C)], [T.loc.x], [T.loc.y], [C.locked ? "<span class='boldannounce'>Locked</span>" : "<font color='green'><b>Unlocked</b></font>"]"
			return

/obj/item/clothing/head/papersack/smiley
	name = "paper sack hat"
	desc = "A paper sack with crude holes cut out for eyes and a sketchy smile drawn on the front. Not creepy at all."
	icon_state = "papersack_smile"
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS

/obj/item/clothing/head/crown
	name = "crown"
	desc = "A crown fit for a king, a petty king maybe."
	icon_state = "crown"
	armor = list("melee" = 15, "bullet" = 0, "laser" = 0,"energy" = 15, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF
	dynamic_hair_suffix = ""

/obj/item/clothing/head/crown/fancy
	name = "magnificent crown"
	desc = "A crown worn by only the highest emperors of the <s>land</s> space."
	icon_state = "fancycrown"

/obj/item/clothing/head/scarecrow_hat
	name = "scarecrow hat"
	desc = "A simple straw hat."
	icon_state = "scarecrow_hat"

/obj/item/clothing/head/lobsterhat
	name = "foam lobster head"
	desc = "When everything's going to crab, protecting your head is the best choice."
	icon_state = "lobster_hat"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/head/drfreezehat
	name = "doctor freeze's wig"
	desc = "A cool wig for cool people."
	icon_state = "drfreeze_hat"
	flags_inv = HIDEHAIR

/obj/item/clothing/head/pharaoh
	name = "pharaoh hat"
	desc = "Walk like an Egyptian."
	icon_state = "pharoah_hat"
	icon_state = "pharoah_hat"

/obj/item/clothing/head/jester/alt
	name = "jester hat"
	desc = "A hat with bells, to add some merriness to the suit."
	icon_state = "jester_hat2"
	dynamic_hair_suffix = ""

/obj/item/clothing/head/nemes
	name = "headdress of Nemes"
	desc = "Lavish space tomb not included."
	icon_state = "nemes_headdress"
	icon_state = "nemes_headdress"

/obj/item/clothing/head/frenchberet
	name = "french beret"
	desc = "A quality beret, infused with the aroma of chain-smoking, wine-swilling Parisians. You feel less inclined to engage military conflict, for some reason."
	icon_state = "beret"
	dynamic_hair_suffix = ""

/obj/item/clothing/head/frenchberet/equipped(mob/M, slot)
	. = ..()
	if (slot == SLOT_HEAD)
		RegisterSignal(M, COMSIG_MOB_SAY, .proc/handle_speech)
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/head/frenchberet/dropped(mob/M)
	. = ..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/head/frenchberet/proc/handle_speech(datum/source, mob/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/french_words = strings("french_replacement.json", "french")

		for(var/key in french_words)
			var/value = french_words[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
			message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
			message = replacetextEx(message, " [key]", " [value]")

		if(prob(3))
			message += pick(" Honh honh honh!"," Honh!"," Zut Alors!")
	speech_args[SPEECH_MESSAGE] = trim(message)

/obj/item/clothing/head/clownmitre
	name = "Hat of the Honkmother"
	desc = "It's hard for parishoners to see a banana peel on the floor when they're looking up at your glorious chapeau."
	icon_state = "clownmitre"

/obj/item/clothing/head/kippah
	name = "kippah"
	desc = "Signals that you follow the Jewish Halakha. Keeps the head covered and the soul extra-Orthodox."
	icon_state = "kippah"

/obj/item/clothing/head/medievaljewhat
	name = "medieval Jew hat"
	desc = "A silly looking hat, intended to be placed on the heads of the station's oppressed religious minorities."
	icon_state = "medievaljewhat"

/obj/item/clothing/head/taqiyahwhite
	name = "white taqiyah"
	desc = "An extra-mustahabb way of showing your devotion to Allah."
	icon_state = "taqiyahwhite"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/small

/obj/item/clothing/head/taqiyahred
	name = "red taqiyah"
	desc = "An extra-mustahabb way of showing your devotion to Allah."
	icon_state = "taqiyahred"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/small
