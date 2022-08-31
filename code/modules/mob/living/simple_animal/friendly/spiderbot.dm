/mob/living/simple_animal/spiderbot
	name = "Spider bot"
	desc = "A skittering robotic friend!"
	icon = 'icons/mob/robots.dmi'
	icon_state = "spiderbot-chassis"
	icon_living = "spiderbot-chassis"
	icon_dead = "spiderbot-smashed"
	language_holder = /datum/language_holder/universal
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 500
	wander = FALSE
	health = 10
	maxHealth = 10
	attacktext = "shocks"
	melee_damage_lower = 2
	melee_damage_upper = 2
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	ventcrawler = 2
	speed = -1                    //Spiderbots gotta go fast.
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_TINY
	speak_emote = list("beeps","clicks","chirps")

	var/obj/item/radio/borg/radio = null
	var/obj/item/weapon/stock_parts/cell/cell = null
	var/obj/machinery/camera/camera = null
	var/obj/item/mmi/mmi = null
	var/list/req_access = list(ACCESS_ROBOTICS) //Access needed to pop out the brain.

	var/emagged = 0
	var/obj/item/held_item = null //Storage for single item they can hold.

/mob/living/simple_animal/spiderbot/attackby(obj/item/O, mob/user)

	if(istype(O, /obj/item/mmi))
		var/obj/item/mmi/M = O
		if(mmi) //There's already a brain in it.
			to_chat(user, span_warning("There's already a brain in [src]!"))
			return
		if(!M.brainmob)
			to_chat(user, span_warning("Sticking an empty MMI into the frame would sort of defeat the purpose."))
			return
		var/mob/living/brain/BM = M.brainmob
		if(!BM.key || !BM.mind)
			to_chat(user, span_warning("The MMI indicates that their mind is completely unresponsive; there's no point!"))
			return

		if(!BM.client) //braindead
			to_chat(user, span_warning("The MMI indicates that their mind is currently inactive; it might change!"))
			return

		if(BM.stat == DEAD || BM.suiciding || (M.brain && (M.brain.brain_death || M.brain.suicided)))
			to_chat(user, span_warning("Sticking a dead brain into the frame would sort of defeat the purpose!"))
			return

		if(is_banned_from(BM.ckey, "Cyborg") || QDELETED(src) || QDELETED(BM) || QDELETED(user) || QDELETED(M) || !Adjacent(user))
			if(!QDELETED(M))
				to_chat(user, span_warning("This [M.name] does not seem to fit!"))
			return

		if(!user.temporarilyRemoveItemFromInventory(M))
			return

		to_chat(user, span_notice("You install [M] in [src]!"))

		transfer_personality(M)

		update_icon()
		return 1

	else if(O.tool_behaviour == TOOL_WELDER && (user.a_intent != INTENT_HARM || user == src)) ///STOLEN FROM CYRORG CODE
		user.changeNext_move(CLICK_CD_MELEE)
		if (!getBruteLoss())
			to_chat(user, span_warning("[src] is already in good condition!"))
			return
		if (!O.tool_start_check(user, amount=0))
			return
		if(src == user)
			if(health > 0)
				to_chat(user, span_warning("You have repaired what you could! Get some help to repair the remaining damage."))
				return
			to_chat(user, span_notice("You start fixing yourself..."))
			if(!O.use_tool(src, user, 50))
				return
			if(health > 0)
				return

		adjustBruteLoss(-10)
		updatehealth()
		add_fingerprint(user)
		visible_message(span_notice("[user] has fixed some of the dents on [src]."))
		return
	else if(istype(O, /obj/item/card/id)||istype(O, /obj/item/pda))
		if (!mmi)
			to_chat(user, span_warning("There's no reason to swipe your ID - the spiderbot has no brain to remove."))
			return 0

		var/obj/item/card/id/id_card

		if(istype(O, /obj/item/card/id))
			id_card = O
		else
			var/obj/item/pda/pda = O
			id_card = pda.id

		if(access_robotics in id_card.GetAccess())
			to_chat(user, span_notice("You swipe your access card and pop the brain out of [src]."))
			eject_brain()

			if(held_item)
				held_item.loc = src.loc
				held_item = null

			return 1
		else
			to_chat(user, span_warning("You swipe your card, with no effect."))
			return 0

	return ..()

/mob/living/simple_animal/spiderbot/proc/transfer_personality(obj/item/mmi/M)
	M.brainmob.mind.transfer_to(src)
	M.forceMove(src)
	job = "Spider Bot"

/mob/living/simple_animal/spiderbot/emag_act(mob/user)
	if (emagged)
		to_chat(user, "<span class='warning'>[src] is already overloaded - better run.</span>")
		return
	else
		emagged = 1
		to_chat(user, "<span class='notice'>You short out the security protocols and overload [src]'s cell, priming it to explode in a short time.</span>")
		spawn(100)
			to_chat(src, "<span class='warning'>Your cell seems to be outputting a lot of power...</span>")
		spawn(200)
			to_chat(src, "<span class='warning'>Internal heat sensors are spiking! Something is badly wrong with your cell!</span>")
		spawn(300)
			explode()
		return

/mob/living/simple_animal/spiderbot/proc/explode() //When emagged.
	visible_message("<span class='warning'>[src] makes an odd warbling noise, fizzles, and explodes.</span>")
	explosion(get_turf(src), -1, 0, 2, 3, 0, flame_range = 2) ///Explodes like a fireball
	if(!QDELETED(src) && stat != DEAD)
		death()

/mob/living/simple_animal/spiderbot/update_icon()
	if(mmi)
		if(istype(mmi, /obj/item/mmi/posibrain))
			icon_state = "spiderbot-chassis-posi"
			icon_living = "spiderbot-chassis-posi"
			return
		else if(isMMI(mmi))
			icon_state = "spiderbot-chassis-mmi"
			icon_living = "spiderbot-chassis-mmi"
			return

	icon_state = "spiderbot-chassis"
	icon_living = "spiderbot-chassis"

/mob/living/simple_animal/spiderbot/proc/eject_brain()
	if(mmi)
		if(mind)	
			mind.transfer_to(mmi.brainmob)
		mmi = null
		name = initial(name)
		mmi.forceMove(loc)
		update_icon()

/mob/living/simple_animal/spiderbot/Destroy()
	eject_brain()
	return ..()

/mob/living/simple_animal/spiderbot/Initialize()
	. = ..()
	radio = new /obj/item/device/radio/borg(src)
	camera = new /obj/machinery/camera(src)
	RegisterSignal(src, COMSIG_MOB_DEATH, .proc/on_death())

/mob/living/simple_animal/spiderbot/proc/on_death()
	UnregisterSignal(src, COMSIG_MOB_DEATH)
	gib()

/mob/living/simple_animal/spiderbot/Destroy()
	if(radio)
		qdel(radio)
		radio = null
	if(camera)
		qdel(camera)
		camera = null
	if(held_item)
		held_item.forceMove(loc)
		held_item = null
	if(cell)
		cell.forceMove(loc)
		cell = null
	if(mmi)
		mmi.forceMove(loc)
		mmi = null
	UnregisterSignal(src, COMSIG_MOB_DEATH)
	. = ..()

//copy paste from alien/larva, if that func is updated please update this one alsoghost
/mob/living/simple_animal/spiderbot/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Spiderbot"

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
	else
		layer = MOB_LAYER
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))

//Cannibalized from the parrot mob. ~Zuhayr

/mob/living/simple_animal/spiderbot/verb/drop_held_item()
	set name = "Drop held item"
	set category = "Spiderbot"
	set desc = "Drop the item you're holding."

	if(incapacitated())
		return

	if(!held_item)
		to_chat(usr, "<span class='warning'>You have nothing to drop!</span>")
		return 0

	visible_message("<span class='notice'>[src] drops \the [held_item]!</span>", "<span class='notice'>You drop \the [held_item]!</span>", "You hear a skittering noise and a soft thump.")

	held_item.forceMove(loc)
	held_item = null
	return 1

/mob/living/simple_animal/spiderbot/verb/get_item()
	set name = "Pick up item"
	set category = "Spiderbot"
	set desc = "Allows you to take a nearby small item."

	if(incapacitated())
		return -1

	if(held_item)
		to_chat(src, "<span class='warning'>You are already holding \the [held_item]</span>")
		return 1

	var/list/items = list()
	for(var/obj/item/I in view(1,src))
		if(I.loc != src && I.w_class <= SIZE_TINY)
			items.Add(I)

	var/obj/selection = input("Select an item.", "Pickup") in items

	if(selection)
		for(var/obj/item/I in view(1, src))
			if(selection == I)
				held_item = selection
				selection.loc = src
				visible_message("<span class='notice'>[src] scoops up \the [held_item]!</span>", "<span class='notice'>You grab \the [held_item]!</span>", "You hear a skittering noise and a clink.")
				return held_item
		to_chat(src, "<span class='warning'>\The [selection] is too far away.</span>")
		return 0

	to_chat(src, "<span class='warning'>There is nothing of interest to take.</span>")
	return 0

/mob/living/simple_animal/spiderbot/examine(mob/user)
	..()
	if(src.held_item)
		to_chat(user, "It is carrying \a [src.held_item] [bicon(src.held_item)].")