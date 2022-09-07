/obj/effect/mob_spawn/human/ash_walker/cosmic
	name = "cosmic ashwalker egg"
	desc = "As you stare you can hear your own thoughts hum through the wind."
	mob_name = "a cosmic ashwalker"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bluespace"
	mob_species = /datum/species/lizard/ashwalker/cosmic
	flavour_text = "<font size=3><b>Y</b></font><b>ou are an ash walker. You were <span class='danger'>Abducted</span>. Taken from your home by strange beings, so they could take you apart and then put you back together as something which they could control. They failed, and paid the price. Your prison screamed and shook as ash storms dashed it to the ground. Now you are free, but... something is different.</b>"
	uniform = null

/obj/effect/mob_spawn/human/ash_walker/cosmic/special(mob/living/new_spawn)
	..()
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		H.grant_all_languages() // Is this powercreep?
		to_chat(H, span_notice("You are familiar with these human's language. Use this to your advantage to communicate with those authentic with it."))
	to_chat(new_spawn, span_notice("When you are close to  you will enter a chrysalis state where you will slowly regenerate. During this state you are very vunerable."))

// Rebirth egg that ashwalkers regenerate in when they reach under 0 health. Takes time to regenerate.
/obj/effect/cyrogenicbubble
	name = "cosmic egg"
	desc = "You can see the embryo of a slowly regenerating baby-ashwalker. This one is extraordinary."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bluespace"
	density = 1
	var/health = 100
	var/progress = 0
	var/mob/living/ashwalker

/obj/effect/cyrogenicbubble/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/effect/cyrogenicbubble/Destroy()
	if(ashwalker)
		qdel(ashwalker) // haha, you're not getting out of this one.
	if(health)
		health = 0
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/cyrogenicbubble/process()
	if(health)
		progress = min(50, progress + 1) // capped at 50, its all we need.
	else
		ejectEgg()
	if(progress == 50)
		ejectEgg()

/obj/effect/cyrogenicbubble/proc/reset_rebirth()
	if(!ashwalker)
		return

	if(ishuman(ashwalker))
		var/mob/living/carbon/human/H = ashwalker
		var/datum/species/lizard/ashwalker/cosmic/C = H.dna.species
		C.rebirth = FALSE

/obj/effect/cyrogenicbubble/attackby(obj/item/weapon, mob/user)
	if(health)
		if(weapon.force > health)
			ejectEgg()
			qdel(src)
		else
			health -= weapon.force
	playsound(loc, weapon.hitsound, 50, 1, 1)
	user.changeNext_move(CLICK_CD_MELEE)

/obj/effect/cyrogenicbubble/attack_animal(mob/living/simple_animal/M)
	var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
	if(damage > health)
		ejectEgg()
		qdel(src)
		visible_message(span_warning("[M] [M.attacktext] [src]"))
	else
		health -= damage

/obj/effect/cyrogenicbubble/proc/ejectEgg()
	if(ashwalker)
		if(progress == 50)
			ashwalker.revive(1) // full heal
		else
			// if they didn't make it to 50, then they'll be healed, but not completely
			// scaling is multiplied by 2, based on the fact that damage varies and I don't want to exactly set their brute/fire/tox/oxy damage
			ashwalker.adjustToxLoss(-progress*2, 0)
			ashwalker.adjustOxyLoss(-progress*2, 0)
			ashwalker.adjustBruteLoss(-progress*2, 0)
			ashwalker.adjustFireLoss(-progress*2, 0)
			ashwalker.revive()
		ashwalker.forceMove(get_turf(src))
		ashwalker.real_name = name
		ashwalker.name = name
		ashwalker.blood_volume = BLOOD_VOLUME_NORMAL(ashwalker)
		reset_rebirth()
		ashwalker.grab_ghost()
		ashwalker = null
	qdel(src)

/obj/effect/cyrogenicbubble/return_air()
	if(get_turf(src))
		var/turf/T = get_turf(src)
		return T.return_air()
	else
		return null

/obj/effect/mob_spawn/human/bus/crewmember
	name = "cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a standard issue Nanotrasen uniform underneath the ice. The machine is fully operational."
	mob_name = "a crew member"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	roundstart = FALSE
	 = FALSE
	random = TRUE
	mob_species = /datum/species/human
	flavour_text = "<span class='big bold'>You are a crew member working for Nanotrasen,</span><b> stationed onboard a state of the art research ship. It has been quite a while \
	since you left port. The clock in the cryopod does not match the planned wakeup date. You should check \
	the bridge and figure out what is going on. A dark feeling swells in your gut as you climb out of your pod. \
	Listen to the captain and help your fellow crew members survive. Do not attempt to leave the ship unless instructed to.</b>"
	outfit = /datum/outfit/crewmember
	assignedrole = "Exploratory Crew"

/obj/effect/mob_spawn/human/bus/crewmember/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	return ..()
	
/datum/outfit/crewmember
	name = "Exploratory Crew Member"
	uniform = /obj/item/clothing/under/rank/scientist
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	back = /obj/item/storage/backpack/science
	r_pocket = /obj/item/tank/internals/emergency_oxygen
	id = /obj/item/card/id/bus/crewmember
	
/obj/effect/mob_spawn/human/bus/crewmember/sec
	name = "security cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a standard issue Nanotrasen security uniform underneath the ice. The machine is fully operational."
	mob_name = "a security officer"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	roundstart = FALSE
	 = FALSE
	random = TRUE
	mob_species = /datum/species/human
	flavour_text = "<span class='big bold'>You are a security officer working for Nanotrasen,</span><b> stationed onboard a state of the art research ship. It has been quite a while \
	since you left port. The clock in the cryopod does not match the planned wakeup date. You should check \
	the bridge and figure out what is going on. A dark feeling swells in your gut as you climb out of your pod. \
	Listen to the captain and prevent the crew from panicking. Do not attempt to leave the ship unless instructed to.</b>"
	outfit = /datum/outfit/crewmember/sec
	assignedrole = "Exploratory Crew Security"

/obj/effect/mob_spawn/human/bus/crewmember/sec/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	return ..()
	
/datum/outfit/crewmember/sec
	name = "Exploratory Security Officer"
	
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	suit = /obj/item/clothing/suit/armor/vest
	gloves = /obj/item/clothing/gloves/combat
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	head = /obj/item/clothing/head/helmet/swat
	mask = /obj/item/clothing/mask/gas
	id = /obj/item/card/id/bus/crewmember/sec
	r_pocket = /obj/item/tank/internals/emergency_oxygen
	l_pocket = /obj/item/flashlight/seclite
	back = /obj/item/storage/backpack/security
	
	
/obj/effect/mob_spawn/human/bus/crewmember/captain
	name = "command cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a standard issue Nanotrasen security uniform underneath the ice. The machine is fully operational."
	mob_name = "a security officer"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	roundstart = FALSE
	 = FALSE
	random = TRUE
	mob_species = /datum/species/human
	flavour_text = "<span class='big bold'>You are a captain controlling a Nanotrasen,</span><b> state of the art research ship. It has been quite a while \
	since you left port. The clock in the cryopod does not match the planned wakeup date. You should check \
	the bridge and figure out what is going on. A dark feeling swells in your gut as you climb out of your pod. \
	Ensure that your crew survives this journey.. Do not attempt to leave the ship unless instructed to.</b>"
	outfit = /datum/outfit/crewmember/captain
	assignedrole = "Exploratory Crew Captain"

/obj/effect/mob_spawn/human/bus/crewmember/captain/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	return ..()

/datum/outfit/crewmember/captain
	name = "Exploratory Security Captain"
	
	id = /obj/item/card/id/bus/crewmember/captain
	glasses = /obj/item/clothing/glasses/sunglasses

	gloves = /obj/item/clothing/gloves/color/captain
	uniform =  /obj/item/clothing/under/rank/captain
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/alt
	shoes = /obj/item/clothing/shoes/sneakers/brown
	head = /obj/item/clothing/head/caphat/parade
	backpack_contents = list(/obj/item/melee/classic_baton/telescopic=1)
	back = /obj/item/storage/backpack/captain
	
/obj/item/card/id/bus/crewmember/captain
	name = "Captain"
	desc = "An employee ID used to access areas around the ship."
	access = list(ACCESS_CAPTAIN, ACCESS_SECURITY, ACCESS_RESEARCH)

/obj/item/card/id/bus/crewmember/captain/New()
	..()
	registered_account = new("Captain", FALSE)
	
/obj/item/card/id/bus/crewmember/sec
	name = "Security Officer"
	desc = "An employee ID used to access areas around the ship."
	access = list(ACCESS_SECURITY, ACCESS_RESEARCH)

/obj/item/card/id/bus/crewmember/sec/New()
	..()
	registered_account = new("Security Officer", FALSE)

/obj/item/card/id/bus/crewmember
	name = "Crew member"
	desc = "An employee ID used to access areas around the ship."
	access = list(ACCESS_RESEARCH)

/obj/item/card/id/bus/crewmember/New()
	..()
	registered_account = new("Crew member", FALSE)
	
/obj/effect/mob_spawn/human/bus/alien
	name = "grown alien egg"
	desc = "A pulsating alien egg. You can barely recognise what looks to be an alien larva inside."
	mob_name = "an alien larva"
	icon = 'icons/mob/alien.dmi'
	icon_state = "egg"
	roundstart = FALSE
	 = FALSE
	random = TRUE
	mob_type = /mob/living/carbon/alien/larva
	flavour_text = "<span class='big bold'>You are an alien.</span><b> You awoke on this metal bird. You have been in stasis \
	since you arrived. But you detect heat onboard this vessel and have awoken. Be careful \
	not to alert the natives of this vessel before you are strong enough. A feeling of fear envelops as you step out of your egg. \
	Ensure that your hive survives this journey.. Do not attempt to leave this vessel unless instructed to.</b>"
	assignedrole = "Exploratory Alien"

/obj/effect/mob_spawn/human/bus/alien/Destroy()
	new/obj/structure/alien/egg/burst(get_turf(src))
	return ..()
