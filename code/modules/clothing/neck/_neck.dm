/obj/item/clothing/neck
	name = "necklace"
	icon = 'icons/obj/clothing/neck.dmi'
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_NECK
	strip_delay = 40
	equip_delay_other = 40

/obj/item/clothing/neck/worn_overlays(isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(body_parts_covered & HEAD)
			if(damaged_clothes)
				. += mutable_appearance('icons/effects/item_damage.dmi', "damagedmask")
			if(HAS_BLOOD_DNA(src))
				. += mutable_appearance('icons/effects/blood.dmi', "maskblood")

/obj/item/clothing/neck/tie
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "bluetie"
	item_state = ""	//no inhands
	item_color = "bluetie"
	w_class = WEIGHT_CLASS_SMALL
	custom_price = 15

/obj/item/clothing/neck/tie/blue
	name = "blue tie"
	icon_state = "bluetie"
	item_color = "bluetie"

/obj/item/clothing/neck/tie/red
	name = "red tie"
	icon_state = "redtie"
	item_color = "redtie"

/obj/item/clothing/neck/tie/black
	name = "black tie"
	icon_state = "blacktie"
	item_color = "blacktie"

/obj/item/clothing/neck/tie/horrible
	name = "horrible tie"
	desc = "A neosilk clip-on tie. This one is disgusting."
	icon_state = "horribletie"
	item_color = "horribletie"

/obj/item/clothing/neck/tie/detective
	name = "loose tie"
	desc = "A loosely tied necktie, a perfect accessory for the over-worked detective."
	icon_state = "detective"
	item_color = "detective"

/obj/item/clothing/neck/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus for listening to the sounds of the human body. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"
	item_color = "stethoscope"

/obj/item/clothing/neck/stethoscope/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] puts \the [src] to [user.p_their()] chest! It looks like [user.p_they()] wont hear much!</span>")
	return OXYLOSS

/obj/item/clothing/neck/stethoscope/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && isliving(user))
		if(user.a_intent == INTENT_HELP)
			var/body_part = parse_zone(user.zone_selected)

			var/heart_strength = "<span class='danger'>no</span>"
			var/lung_strength = "<span class='danger'>no</span>"

			var/obj/item/organ/heart/heart = M.getorganslot(ORGAN_SLOT_HEART)
			var/obj/item/organ/lungs/lungs = M.getorganslot(ORGAN_SLOT_LUNGS)

			if(!(M.stat == DEAD || (HAS_TRAIT(M, TRAIT_FAKEDEATH))))
				if(heart && istype(heart))
					heart_strength = "<span class='danger'>an unstable</span>"
					if(heart.beating)
						heart_strength = "a healthy"
				if(lungs && istype(lungs))
					lung_strength = "<span class='danger'>strained</span>"
					if(!(M.failed_last_breath || M.losebreath))
						lung_strength = "healthy"

			if(M.stat == DEAD && heart && world.time - M.timeofdeath < DEFIB_TIME_LIMIT * 10)
				heart_strength = "<span class='boldannounce'>a faint, fluttery</span>"

			var/diagnosis = (body_part == BODY_ZONE_CHEST ? "You hear [heart_strength] pulse and [lung_strength] respiration." : "You faintly hear [heart_strength] pulse.")
			user.visible_message("[user] places [src] against [M]'s [body_part] and listens attentively.", "<span class='notice'>You place [src] against [M]'s [body_part]. [diagnosis]</span>")
			return
	return ..(M,user)

///////////
//SCARVES//
///////////

/obj/item/clothing/neck/scarf //Default white color, same functionality as beanies.
	name = "white scarf"
	icon_state = "scarf"
	desc = "A stylish scarf. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their necks."
	item_color = "white"
	dog_fashion = /datum/dog_fashion/head
	custom_price = 10

/obj/item/clothing/neck/scarf/black
	name = "black scarf"
	item_color = "black"
	icon_state = "scarf"
	color = "#4A4A4B" //Grey but it looks black

/obj/item/clothing/neck/scarf/pink
	name = "pink scarf"
	item_color = "pink"
	icon_state = "scarf"
	color = "#F699CD" //Pink

/obj/item/clothing/neck/scarf/red
	name = "red scarf"
	item_color = "red"
	icon_state = "scarf"
	color = "#D91414" //Red

/obj/item/clothing/neck/scarf/green
	name = "green scarf"
	item_color = "green"
	icon_state = "scarf"
	color = "#5C9E54" //Green

/obj/item/clothing/neck/scarf/darkblue
	name = "dark blue scarf"
	item_color = "blue"
	icon_state = "scarf"
	color = "#1E85BC" //Blue

/obj/item/clothing/neck/scarf/purple
	name = "purple scarf"
	item_color = "purple"
	icon_state = "scarf"
	color = "#9557C5" //Purple

/obj/item/clothing/neck/scarf/yellow
	name = "yellow scarf"
	item_color = "yellow"
	icon_state = "scarf"
	color = "#E0C14F" //Yellow

/obj/item/clothing/neck/scarf/orange
	name = "orange scarf"
	item_color = "orange"
	icon_state = "scarf"
	color = "#C67A4B" //Orange

/obj/item/clothing/neck/scarf/cyan
	name = "cyan scarf"
	item_color = "cyan"
	icon_state = "scarf"
	color = "#54A3CE" //Cyan


//Striped scarves get their own icons

/obj/item/clothing/neck/scarf/zebra
	name = "zebra scarf"
	icon_state = "zebrascarf"
	item_color = "zebrascarf"

/obj/item/clothing/neck/scarf/christmas
	name = "christmas scarf"
	icon_state = "christmasscarf"
	item_color = "christmasscarf"

//The three following scarves don't have the scarf subtype
//This is because Ian can equip anything from that subtype
//However, these 3 don't have corgi versions of their sprites
/obj/item/clothing/neck/stripedredscarf
	name = "striped red scarf"
	icon_state = "stripedredscarf"
	item_color = "stripedredscarf"
	custom_price = 10

/obj/item/clothing/neck/stripedgreenscarf
	name = "striped green scarf"
	icon_state = "stripedgreenscarf"
	item_color = "stripedgreenscarf"
	custom_price = 10

/obj/item/clothing/neck/stripedbluescarf
	name = "striped blue scarf"
	icon_state = "stripedbluescarf"
	item_color = "stripedbluescarf"
	custom_price = 10

/obj/item/clothing/neck/petcollar
	name = "pet collar"
	desc = "It has a little bell!"
	icon_state = "petcollar"
	item_color = "petcollar"
	var/tagname = null

/obj/item/clothing/neck/petcollar/Initialize()
	.= ..()
	AddComponent(/datum/component/squeak, list('sound/effects/collarbell1.ogg'=1,'sound/effects/collarbell2.ogg'=1), 50, 100, 2)

/obj/item/clothing/neck/petcollar/mob_can_equip(mob/M, mob/equipper, slot, disable_warning = 0)
	var/mob/living/carbon/C = M
	if(C && ishumanbasic(C) && !iscatperson(C))
		return FALSE
	return ..()

/obj/item/clothing/neck/petcollar/attack_self(mob/user)
	tagname = stripped_input(user, "Would you like to change the name on the tag?", "Name your new pet", "Spot", MAX_NAME_LEN)
	name = "[initial(name)] - [tagname]"

//////////////
//DOPE BLING//
//////////////

/obj/item/clothing/neck/necklace/dope
	name = "gold necklace"
	desc = "Damn, it feels good to be a gangster."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "bling"
	item_color = "bling"

/obj/item/clothing/neck/neckerchief
	icon = 'icons/obj/clothing/masks.dmi' //In order to reuse the bandana sprite
	w_class = WEIGHT_CLASS_TINY
	var/sourceBandanaType

/obj/item/clothing/neck/neckerchief/worn_overlays(isinhands)
	. = ..()
	if(!isinhands)
		var/mutable_appearance/realOverlay = mutable_appearance('icons/mob/mask.dmi', icon_state)
		realOverlay.pixel_y = -3
		. += realOverlay

/obj/item/clothing/neck/neckerchief/AltClick(mob/user)
	. = ..()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.get_item_by_slot(SLOT_NECK) == src)
			to_chat(user, "<span class='warning'>You can't untie [src] while wearing it!</span>")
			return
		if(user.is_holding(src))
			var/obj/item/clothing/mask/bandana/newBand = new sourceBandanaType(user)
			var/currentHandIndex = user.get_held_index_of_item(src)
			var/oldName = src.name
			qdel(src)
			user.put_in_hand(newBand, currentHandIndex)
			user.visible_message("You untie [oldName] back into a [newBand.name]", "[user] unties [oldName] back into a [newBand.name]")
		else
			to_chat(user, "<span class='warning'>You must be holding [src] in order to untie it!</span>")

//CentCom

/obj/item/clothing/neck/pauldron
	name = "major's pauldron"
	icon_state = "major"
	item_state = "major"
	desc = "A red padded pauldron signifying the rank of Major; offers a small amount of protection to the wearer."
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST
	armor = list("melee" = 15, "bullet" = 25, "laser" = 10, "energy" = 10, "bomb" = 5, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/neck/pauldron/commander
	name = "commodore's pauldron"
	desc = "A gold alloy reinforced pauldron signifying the rank of Commodore;offers a moderate amount of protection to the wearer."
	icon_state = "commodore"
	item_state = "commodore"
	armor = list("melee" = 25, "bullet" = 25, "laser" = 20, "energy" = 20, "bomb" = 5, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 50)

/obj/item/clothing/neck/pauldron/colonel
	name = "colonel's pauldrons"
	desc = "Gold alloy reinforced pauldrons signifying the rank of Colonel; offers slightly more protection than the Commander's pauldron to the wearer."
	icon_state = "colonel"
	item_state = "colonel"
	armor = list("melee" = 35, "bullet" = 30, "laser" = 35, "energy" = 35, "bomb" = 5, "bio" = 20, "rad" = 0, "fire" = 0, "acid" = 90)

/obj/item/clothing/neck/cape
	name = "admiral's cape"
	desc = "A sizable green cape with gold connects."
	icon_state = "admiralcape"
	item_state = "admiralcape"
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDESUITSTORAGE

/obj/item/clothing/neck/cape/grand
	name = "grand admiral's cape"
	desc = "A sizable white cape with gold connects."
	icon_state = "grandadmiral"
	item_state = "grand_admiral"

/*
 * Bodycamera stuff
 * NOTE: Unlike regular cameras, bodycams can only stream to one camera network at a time. Unless you want to give it more networks,
 * the code will only ever worry about bodcam.network[1]
 */

/obj/item/clothing/neck/bodycam
	name = "body camera"
	desc = "A wearable camera, capable of streaming a live feed."
	icon_state = "bodycam_off"
	item_state = "bodycam_off"
	var/prefix = "sec"//used for sprites, miner etc
	var/obj/machinery/camera/bodcam = null
	var/setup = FALSE
	var/preset = FALSE //if true, the camera is already configured and cannot be reset
	actions_types = list(/datum/action/item_action/toggle_bodycam)
	strip_delay = 1 SECONDS //takes one second to strip, so a downed officer can be un-cammed quickly
	w_class = WEIGHT_CLASS_BULKY //you HAVE to wear it or carry it. No cheating by putting it in a bag!

/obj/item/clothing/neck/bodycam/Initialize()
	..()
	bodcam = new(src)
	bodcam.c_tag = "NT_BodyCam"
	bodcam.network = list("ss13")
	bodcam.internal_light = FALSE
	bodcam.status = FALSE
	update_icon()

/obj/item/clothing/neck/bodycam/attack_self(mob/user)
	if(!setup)
		AltClick(user)
		return
	if(bodcam.status)
		bodcam.status = FALSE
		to_chat(user, "<span class='notice'>You shut off the body camera.</span>")
	else
		bodcam.status = TRUE
		to_chat(user, "<span class='notice'>You turn on the body camera.</span>")
	update_icon()

/obj/item/clothing/neck/bodycam/AltClick(mob/user)
	if(preset)
		return //can't change the settings on it if it's preset
	var/name = input(user, "What would you like your camera's display name to be?", "Camera id", "[user.name]") as null|text
	if(name)
		bodcam.c_tag = "(Bodycam) " + name
	bodcam.network[1] = input(user, "Which network should the camera broadcast to?\nFor example, 'ss13', 'security', and 'mine' are existing networks", "Camera network", "ss13") as null|text
	if(bodcam.c_tag && bodcam.network.len > 0)
		setup = TRUE
		bodcam.status = TRUE
		update_icon()

/obj/item/clothing/neck/bodycam/update_icon()
	..()
	var/suffix = "off"
	if (bodcam.status)
		suffix = "on"
	icon_state = "[prefix]_bodycam_[suffix]"
	item_state = "[prefix]_bodycam_[suffix]"
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/neck/bodycam/examine(mob/user)
	.=..()
	. += "<span class='notice'>The camera is currently [bodcam.status ? "on" : "off"].<span>"
	if(setup)
		. += "<span class='notice'>It is registered under the name \"[bodcam.c_tag]\".</span>"
		. += "<span class='notice'>It is streaming to the network \"[bodcam.network[1]]\".</span>"
		if(!preset)
			. += "<span class='notice'>Alt-click to configure the camera.</span>"
		else
			. += "<span class='notice'>This camera is locked and cannot be reconfigured.</span>"
	else
		. += "<span class='warning'>It hasn't been set up yet!</span>"

/obj/item/clothing/neck/bodycam/verb/toggle_bodycam()
	set name = "Toggle Bodycam"
	set category = "Object"
	set src in oview(1)

	if(!usr.incapacitated())
		attack_self(usr)

/obj/item/clothing/neck/bodycam/emp_act(severity)
	. = ..()
	if(prob(150/severity))
		bodcam.c_tag = rand(1,10000)
		bodcam.network[1] = rand(1, 10000) //gibberish, this will render the camera basically unreadable by any console
		bodcam.status = FALSE
		update_icon()

/obj/item/clothing/neck/bodycam/Destroy()
	. = ..()
	QDEL_NULL(bodcam)

//Miner specfic camera, cannot be reconfigured
/obj/item/clothing/neck/bodycam/miner
	name = "miner body camera"
	desc = "A wearable camera, capable of streaming a live feed. This one is preconfigured to be used by miners."
	prefix = "miner"
	setup = TRUE
	preset = TRUE

/obj/item/clothing/neck/bodycam/miner/Initialize()
	..()
	bodcam.network[1] = "mine"
	bodcam.c_tag = "Unactivated Miner Body Camera"

/obj/item/clothing/neck/bodycam/miner/attack_self(mob/user)
	..()
	bodcam.c_tag = "(Miner bodycam) " + user.name
	bodcam.network[1] = "mine"
