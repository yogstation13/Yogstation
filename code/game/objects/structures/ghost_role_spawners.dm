//Objects that spawn ghosts in as a certain role when they click on it, i.e. away mission bartenders.

//Preserved terrarium/seed vault: Spawns in seed vault structures in lavaland. Ghosts become plantpeople and are advised to begin growing plants in the room near them.
/obj/effect/mob_spawn/human/seed_vault
	name = "preserved terrarium"
	desc = "An ancient machine that seems to be used for storing plant matter. The glass is obstructed by a mat of vines."
	mob_name = "a lifebringer"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "terrarium"
	density = TRUE
	roundstart = FALSE
	death = FALSE
	mob_species = /datum/species/pod
	short_desc = "You are a sentient ecosystem, an example of the mastery over life that your creators possessed."
	flavour_text = "Your masters, benevolent as they were, created uncounted \
	seed vaults and spread them across the universe to every planet they could chart. You are in one such seed vault. Your goal is to cultivate and spread life wherever it will go while waiting \
	for contact from your creators. Estimated time of last contact: Deployment, 5x10^3 millennia ago."
	assignedrole = "Lifebringer"

/obj/effect/mob_spawn/human/seed_vault/special(mob/living/new_spawn)
	var/plant_name = pick("Tomato", "Potato", "Broccoli", "Carrot", "Ambrosia", "Pumpkin", "Ivy", "Kudzu", "Banana", "Moss", "Flower", "Bloom", "Root", "Bark", "Glowshroom", "Petal", "Leaf", \
	"Venus", "Sprout", "Cocoa", "Strawberry", "Citrus", "Oak", "Cactus", "Pepper", "Juniper", "Cannabis")
	new_spawn.fully_replace_character_name(null,plant_name)
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		H.underwear = "Nude" //You're a plant, partner
		H.update_body()

/obj/effect/mob_spawn/human/seed_vault/Destroy()
	new/obj/structure/fluff/empty_terrarium(get_turf(src))
	return ..()

//Ash walker eggs: Spawns in ash walker dens in lavaland. Ghosts become unbreathing lizards that worship the Necropolis and are advised to retrieve corpses to create more ash walkers.
/obj/effect/mob_spawn/human/ash_walker
	name = "ash walker egg"
	desc = "A man-sized yellow egg, spawned from some unfathomable creature. A humanoid silhouette lurks within."
	mob_name = "an ash walker"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	mob_species = /datum/species/lizard/ashwalker
	outfit = /datum/outfit/ashwalker
	roundstart = FALSE
	death = FALSE
	anchored = FALSE
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	short_desc = "You are an ash walker. Your tribe worships the Necropolis."
	flavour_text = "The wastes are sacred ground, its monsters a blessed bounty. \
	You have seen lights in the distance... they foreshadow the arrival of outsiders that seek to tear apart the Necropolis and its domain. Fresh sacrifices for your nest."
	assignedrole = "Ash Walker"
	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_NONE,
		SKILL_MECHANICAL = EXP_NONE,
		SKILL_TECHNICAL = EXP_NONE,
		SKILL_SCIENCE = EXP_NONE,
		SKILL_FITNESS = EXP_HIGH,
	)
	skill_points = EXP_HIGH
	exceptional_skill = TRUE
	var/datum/team/ashwalkers/team

/obj/effect/mob_spawn/human/ash_walker/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(null,random_unique_lizard_name(gender))
	to_chat(new_spawn, "<b>Drag the corpses of men and beasts to your nest. It will absorb them to create more of your kind. Glory to the Necropolis!</b>") //yogs - removed a sentence
	new_spawn.mind.add_antag_datum(/datum/antagonist/ashwalker, team)

/obj/effect/mob_spawn/human/ash_walker/Initialize(mapload, datum/team/ashwalkers/ashteam)
	. = ..()
	var/area/A = get_area(src)
	team = ashteam
	if(A)
		notify_ghosts("[mob_name] egg is ready to hatch in \the [A.name].", source = src, action=NOTIFY_ATTACKORBIT, flashwindow = FALSE, ignore_key = POLL_IGNORE_ASHWALKER)

//Ash walker shaman eggs: Spawns in ash walker dens in lavaland. Only one can exist at a time, they are squishier than regular ashwalkers, and have the sole purpose of keeping other ashwalkers alive.
/obj/effect/mob_spawn/human/ash_walker/shaman
	name = "ash walker shaman egg"
	desc = "A man-sized, amber egg spawned from some unfathomable creature. A humanoid silhouette lurks within."
	mob_name = "an ash walker shaman"
	mob_species = /datum/species/lizard/ashwalker/shaman
	outfit = /datum/outfit/ashwalker/shaman //might be OP, but the flavour is there
	short_desc = "You are an ash walker shaman. Your tribe worships the Necropolis."
	flavour_text = "The wastes are sacred ground, its monsters a blessed bounty. You and your people have become one with the tendril and its land. \
	You have seen lights in the distance and from the skies: outsiders that come with greed in their hearts. Fresh sacrifices for your nest."
	assignedrole = "Ash Walker Shaman"
	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_HIGH,
		SKILL_MECHANICAL = EXP_NONE,
		SKILL_TECHNICAL = EXP_NONE,
		SKILL_SCIENCE = EXP_NONE,
		SKILL_FITNESS = EXP_NONE,
	)
	skill_points = EXP_HIGH

/datum/outfit/ashwalker
	name = "Ashwalker"
	uniform = /obj/item/clothing/under/tribal/chestwrap

/datum/outfit/ashwalker/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	H.underwear = "Nude"
	H.update_body()

/datum/outfit/ashwalker/tribesperson
	name = "Ashwalker Tribesperson"
	uniform = /obj/item/clothing/under/tribal/ash_robe

/datum/outfit/ashwalker/hunter
	name = "Ashwalker Hunter"
	uniform = /obj/item/clothing/under/tribal/ash_robe/hunter
	suit = /obj/item/clothing/suit/hooded/cloak/goliath/desert
	back = /obj/item/gun/ballistic/bow/ashen
	belt = /obj/item/storage/belt/quiver/weaver/ashwalker
	shoes = /obj/item/clothing/shoes/xeno_wraps

/datum/outfit/ashwalker/warrior
	name = "Ashwalker Warrior"
	uniform = /obj/item/clothing/under/tribal
	head = /obj/item/clothing/head/helmet/skull
	suit = /obj/item/clothing/suit/armor/bone/heavy
	back = /obj/item/melee/spear/bonespear
	gloves = /obj/item/clothing/gloves/bracer
	belt = /obj/item/storage/belt/mining/primitive
	shoes = /obj/item/clothing/shoes/xeno_wraps
	r_hand = /obj/item/shield/riot/goliath
	l_hand = /obj/item/claymore/bone

/datum/outfit/ashwalker/chief
	name = "Ashwalker Chief"
	uniform = /obj/item/clothing/under/tribal/ash_robe/chief
	head = /obj/item/clothing/head/crown/resin
	suit = /obj/item/clothing/suit/armor/bone
	back = /obj/item/melee/spear/bonespear/chitinspear
	gloves = /obj/item/clothing/gloves/color/black/goliath
	shoes = /obj/item/clothing/shoes/xeno_wraps/goliath
	neck = /obj/item/clothing/neck/cloak/tribalmantle

/datum/outfit/ashwalker/shaman
	name = "Ashwalker Shaman"
	uniform = /obj/item/clothing/under/tribal/ash_robe/shaman
	head = /obj/item/clothing/head/shamanash
	suit = /obj/item/clothing/suit/leather_mantle
	belt = /obj/item/storage/bag/medpouch
	gloves = /obj/item/clothing/gloves/color/black/goliath


//Timeless prisons: Spawns in Wish Granter prisons in lavaland. Ghosts become age-old users of the Wish Granter and are advised to seek repentance for their past.
/obj/effect/mob_spawn/human/exile
	name = "timeless prison"
	desc = "Although this stasis pod looks medicinal, it seems as though it's meant to preserve something for a very long time."
	mob_name = "a penitent exile"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	mob_species = /datum/species/shadow
	short_desc = "You are cursed."
	flavour_text = "Years ago, you sacrificed the lives of your trusted friends and the humanity of yourself to reach the Wish Granter. Though you \
	did so, it has come at a cost: your very body rejects the light, dooming you to wander endlessly in this horrible wasteland.</b>"
	assignedrole = "Exile"

/obj/effect/mob_spawn/human/exile/Destroy()
	new/obj/structure/fluff/empty_sleeper(get_turf(src))
	return ..()

/obj/effect/mob_spawn/human/exile/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(null,"Wish Granter's Victim ([rand(1,999)])")
	var/wish = rand(1,4)
	switch(wish)
		if(1)
			to_chat(new_spawn, "<b>You wished to kill, and kill you did. You've lost track of how many, but the spark of excitement that murder once held has winked out. You feel only regret.</b>")
		if(2)
			to_chat(new_spawn, "<b>You wished for unending wealth, but no amount of money was worth this existence. Maybe charity might redeem your soul?</b>")
		if(3)
			to_chat(new_spawn, "<b>You wished for power. Little good it did you, cast out of the light. You are the [gender == MALE ? "king" : "queen"] of a hell that holds no subjects. You feel only remorse.</b>")
		if(4)
			to_chat(new_spawn, "<b>You wished for immortality, even as your friends lay dying behind you. No matter how many times you cast yourself into the lava, you awaken in this room again within a few days. There is no escape.</b>")

//Golem shells: Spawns in Free Golem ships in lavaland. Ghosts become mineral golems and are advised to spread personal freedom.
/obj/effect/mob_spawn/human/golem
	name = "inert free golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	mob_name = "a free golem"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	mob_species = /datum/species/golem
	roundstart = FALSE
	death = FALSE
	anchored = FALSE
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	banType = ROLE_GOLEM
	var/has_owner = FALSE
	var/can_transfer = TRUE //if golems can switch bodies to this new shell
	var/mob/living/owner = null //golem's owner if it has one
	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_NONE,
		SKILL_MECHANICAL = EXP_NONE,
		SKILL_TECHNICAL = EXP_NONE,
		SKILL_SCIENCE = EXP_LOW,
		SKILL_FITNESS = EXP_NONE,
	)
	skill_points = EXP_GENIUS
	short_desc = "You are a Free Golem. Your family worships The Liberator."
	flavour_text = "In his infinite and divine wisdom, he set your clan free to \
	travel the stars with a single declaration: \"Yeah go do whatever.\" Though you are bound to the one who created you, it is customary in your society to repeat those same words to newborn \
	golems, so that no golem may ever be forced to serve again."

/obj/effect/mob_spawn/human/golem/Initialize(mapload, datum/species/golem/species = null, mob/creator = null)
	if(species) //spawners list uses object name to register so this goes before ..()
		name += " ([initial(species.prefix)])"
		mob_species = species
	. = ..()
	var/area/A = get_area(src)
	if(!mapload && A)
		notify_ghosts("\A [initial(species.prefix)] golem shell has been completed in \the [A.name].", source = src, action=NOTIFY_ATTACKORBIT, flashwindow = FALSE, ignore_key = POLL_IGNORE_GOLEM)
	if(has_owner && creator)
		short_desc = "You are a Golem."
		flavour_text = "You move slowly and are unable to wear clothes, but can still use most tools. Depending on the material you were made of, you will have different strengths and weaknesses \
		Serve [creator.real_name], and assist [creator.p_them()] in completing [creator.p_their()] goals at any cost."
		owner = creator

/obj/effect/mob_spawn/human/golem/special(mob/living/new_spawn, name)
	var/datum/species/golem/X = mob_species
	to_chat(new_spawn, "[initial(X.info_text)]")
	if(!owner)
		to_chat(new_spawn, "Build golem shells in the autolathe, and feed refined mineral sheets to the shells to bring them to life! You are generally a peaceful group unless provoked.")
	else
		new_spawn.mind.store_memory("<b>Serve [owner.real_name], your creator.</b>")
		new_spawn.mind.enslave_mind_to_creator(owner)
		log_game("[key_name(new_spawn)] possessed a golem shell enslaved to [key_name(owner)].")
		log_admin("[key_name(new_spawn)] possessed a golem shell enslaved to [key_name(owner)].")
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		if(has_owner)
			var/datum/species/golem/G = H.dna.species
			G.owner = owner
		H.set_cloned_appearance()
		if(!name)
			if(has_owner)
				H.fully_replace_character_name(null, "[initial(X.prefix)] Golem ([rand(1,999)])")
			else
				H.fully_replace_character_name(null, H.dna.species.random_name())
		else
			H.fully_replace_character_name(null, name)
	if(has_owner)
		new_spawn.mind.assigned_role = "Servant Golem"
	else
		new_spawn.mind.assigned_role = "Free Golem"

/obj/effect/mob_spawn/human/golem/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(isgolem(user) && can_transfer)
		var/transfer_choice = tgui_alert(user, "Transfer your soul to [src]? (Warning, your old body will die!)", "Swag to Mad transformation", list("Yes","No"))
		if(transfer_choice != "Yes")
			return
		if(QDELETED(src) || uses <= 0)
			return
		log_game("[key_name(user)] golem-swapped into [src]")
		user.visible_message(span_notice("A faint light leaves [user], moving to [src] and animating it!"),span_notice("You leave your old body behind, and transfer into [src]!"))
		show_flavour = FALSE
		create(ckey = user.ckey,name = user.real_name)
		user.death()
		return

// List of ckeys belonging to people who switched from being a ghost to a servant golem. Associative list; ckey = worldtime + cooldown.
GLOBAL_LIST_EMPTY(servant_golem_users)

/obj/effect/mob_spawn/human/golem/servant
	has_owner = TRUE
	name = "inert servant golem shell"
	mob_name = "a servant golem"

/obj/effect/mob_spawn/human/golem/servant/attack_ghost(mob/user)
	. = ..()
	if(.)
		var/datum/species/golem/golem = mob_species
		GLOB.servant_golem_users[user.ckey] = world.time + (initial(golem.ghost_cooldown) ? initial(golem.ghost_cooldown) : 0) // In case anything goes wrong.

/obj/effect/mob_spawn/human/golem/servant/check_allowed(mob/M)
	. = ..()
	if(!.)
		return FALSE
	/* 	Half the philosophy of posi-brains. 
		While they are mass producible like posi-brains, they lack "many of the strengths" that cyborgs have.*/
	if(GLOB.servant_golem_users[M.ckey])
		var/time_left = (GLOB.servant_golem_users[M.ckey]) - world.time
		var/seconds_left = time_left/10
		var/minutes_left_rounded = round(seconds_left/60, 0.1)
		if(time_left > 0) // Cooldown has not been finished.
			var/add_msg = seconds_left <= 60 ? "[seconds_left] more seconds" : "[minutes_left_rounded] more minutes"
			to_chat(M, span_warning("[src] rumbles. You have used a servant golem shell recently! Wait [add_msg]."))
			return FALSE

/obj/effect/mob_spawn/human/golem/adamantine
	name = "dust-caked free golem shell"
	desc = "A humanoid shape, empty, lifeless, and full of potential."
	mob_name = "a free golem"
	can_transfer = FALSE
	mob_species = /datum/species/golem/adamantine

//Malfunctioning cryostasis sleepers: Spawns in makeshift shelters in lavaland. Ghosts become hermits with knowledge of how they got to where they are now.
/obj/effect/mob_spawn/human/hermit
	name = "malfunctioning cryostasis sleeper"
	desc = "A humming sleeper with a silhouetted occupant inside. Its stasis function is broken and it's likely being used as a bed."
	mob_name = "a stranded hermit"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	outfit = /datum/outfit/hermit
	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_NONE,
		SKILL_MECHANICAL = EXP_NONE,
		SKILL_TECHNICAL = EXP_NONE,
		SKILL_SCIENCE = EXP_NONE,
		SKILL_FITNESS = EXP_NONE,
	)
	skill_points = EXP_MASTER
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	short_desc = "You've been stranded in this godless prison of a planet for longer than you can remember."
	flavour_text = "Each day you barely scrape by, and between the terrible \
	conditions of your makeshift shelter, the hostile creatures, and the ash drakes swooping down from the cloudless skies, all you can wish for is the feel of soft grass between your toes and \
	the fresh air of Earth. These thoughts are dispelled by yet another recollection of how you got here... "
	assignedrole = "Hermit"

/obj/effect/mob_spawn/human/hermit/Initialize(mapload)
	. = ..()
	var/arrpee = rand(1,4)
	switch(arrpee)
		if(1)
			flavour_text += "you were a [pick("arms dealer", "shipwright", "docking manager")]'s assistant on a small trading station several sectors from here. Raiders attacked, and there was \
			only one pod left when you got to the escape bay. You took it and launched it alone, and the crowd of terrified faces crowding at the airlock door as your pod's engines burst to \
			life and sent you to this hell are forever branded into your memory."
			outfit.uniform = /obj/item/clothing/under/rank/civilian/assistantformal
			base_skills[SKILL_MECHANICAL] = EXP_MID
		if(2)
			flavour_text += "you're an exile from the Tiger Cooperative. Their technological fanaticism drove you to question the power and beliefs of the Exolitics, and they saw you as a \
			heretic and subjected you to hours of horrible torture. You were hours away from execution when a high-ranking friend of yours in the Cooperative managed to secure you a pod, \
			scrambled its destination's coordinates, and launched it. You awoke from stasis when you landed and have been surviving - barely - ever since."
			outfit.uniform = /obj/item/clothing/under/rank/prisoner
			outfit.shoes = /obj/item/clothing/shoes/sneakers/orange
			base_skills[SKILL_TECHNICAL] = EXP_MID
		if(3)
			flavour_text += "you were a doctor on one of Nanotrasen's space stations, but you left behind that damn corporation's tyranny and everything it stood for. From a metaphorical hell \
			to a literal one, you find yourself nonetheless missing the recycled air and warm floors of what you left behind... but you'd still rather be here than there."
			outfit.uniform = /obj/item/clothing/under/rank/medical
			outfit.suit = /obj/item/clothing/suit/toggle/labcoat
			outfit.back = /obj/item/storage/backpack/medic
			base_skills[SKILL_PHYSIOLOGY] = EXP_MID
		if(4)
			flavour_text += "you were always joked about by your friends for \"not playing with a full deck\", as they so kindly put it. It seems that they were right when you, on a tour \
			at one of Nanotrasen's state-of-the-art research facilities, were in one of the escape pods alone and saw the red button. It was big and shiny, and it caught your eye. You pressed \
			it, and after a terrifying and fast ride for days, you landed here. You've had time to wisen up since then, and you think that your old friends wouldn't be laughing now."
			base_skills[SKILL_FITNESS] = EXP_MID

/obj/effect/mob_spawn/human/hermit/Destroy()
	new/obj/structure/fluff/empty_cryostasis_sleeper(get_turf(src))
	return ..()

/datum/outfit/hermit
	name = "Lavaland hermit"
	uniform = /obj/item/clothing/under/color/grey/glorf
	shoes = /obj/item/clothing/shoes/sneakers/black
	back = /obj/item/storage/backpack
	mask = /obj/item/clothing/mask/breath
	l_pocket = /obj/item/tank/internals/emergency_oxygen
	r_pocket = /obj/item/flashlight/glowstick

//Broken rejuvenation pod: Spawns in animal hospitals in lavaland. Ghosts become disoriented interns and are advised to search for help.
/obj/effect/mob_spawn/human/doctor/alive/lavaland
	name = "broken rejuvenation pod"
	desc = "A small sleeper typically used to instantly restore minor wounds. This one seems broken, and its occupant is comatose."
	mob_name = "a translocated vet"
	flavour_text = "What...? Where are you? Where are the others? This is still the animal hospital - you should know, you've been an intern here for weeks - but \
	everyone's gone. One of the cats scratched you just a few minutes ago. That's why you were in the pod - to heal the scratch. The scabs are still fresh; you see them right now. So where is \
	everyone? Where did they go? What happened to the hospital? And is that smoke you smell? You need to find someone else. Maybe they can tell you what happened."
	assignedrole = "Translocated Vet"
	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_MID,
		SKILL_MECHANICAL = EXP_NONE,
		SKILL_TECHNICAL = EXP_NONE,
		SKILL_SCIENCE = EXP_NONE,
		SKILL_FITNESS = EXP_NONE,
	)
	skill_points = EXP_MASTER

/obj/effect/mob_spawn/human/doctor/alive/lavaland/Destroy()
	var/obj/structure/fluff/empty_sleeper/S = new(drop_location())
	S.setDir(dir)
	return ..()

//Prisoner containment sleeper: Spawns in crashed prison ships in lavaland. Ghosts become escaped prisoners and are advised to find a way out of the mess they've gotten themselves into.
/obj/effect/mob_spawn/human/prisoner_transport
	name = "prisoner containment sleeper"
	desc = "A sleeper designed to put its occupant into a deep coma, unbreakable until the sleeper turns off. This one's glass is cracked and you can see a pale, sleeping face staring out."
	mob_name = "an escaped prisoner"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	outfit = /datum/outfit/lavalandprisoner
	roundstart = FALSE
	death = FALSE
	short_desc = "You're a prisoner, sentenced to hard work in one of Nanotrasen's labor camps."
	flavour_text = "Good. It seems as though your ship crashed. It seems as \
	though fate has other plans for you. You remember that you were convicted of "
	assignedrole = "Escaped Prisoner"

/obj/effect/mob_spawn/human/prisoner_transport/special(mob/living/L)
	L.fully_replace_character_name(null,"NTP #LL-0[rand(111,999)]") //Nanotrasen Prisoner #Lavaland-(numbers)

/obj/effect/mob_spawn/human/prisoner_transport/Initialize(mapload)
	. = ..()
	var/list/crimes = list("murder", "larceny", "embezzlement", "unionization", "dereliction of duty", "kidnapping", "gross incompetence", "grand theft", "collaboration with the Syndicate", \
	"worship of a forbidden deity", "interspecies relations", "mutiny")
	flavour_text += "[pick(crimes)]. But regardless of that, it seems like your crime doesn't matter now. You don't know where you are, but you know that it's out to kill you, and you're not going \
	to lose this opportunity. Find a way to get out of this mess and back to where you rightfully belong - your [pick("house", "apartment", "spaceship", "station")]."

/datum/outfit/lavalandprisoner
	name = "Lavaland Prisoner"
	uniform = /obj/item/clothing/under/rank/prisoner
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/sneakers/orange
	r_pocket = /obj/item/tank/internals/emergency_oxygen


/obj/effect/mob_spawn/human/prisoner_transport/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	return ..()

//Space Hotel Staff
/obj/effect/mob_spawn/human/hotel_staff //not free antag u little shits
	name = "staff sleeper"
	desc = "A sleeper designed for long-term stasis between guest visits."
	mob_name = "hotel staff member"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	//objectives = "Cater to visiting guests with your fellow staff. Do not leave your assigned hotel and always remember: The customer is always right!" //yogs - removed hotel staff objectives
	death = FALSE
	roundstart = FALSE
	random = TRUE
	outfit = /datum/outfit/hotelstaff
	short_desc = "You are a staff member of a top-of-the-line space hotel!"
	flavour_text = "You are a staff member of a top-of-the-line space hotel! Cater to guests and make sure the manager doesn't fire you."
	important_info = "DON'T leave the hotel"
	assignedrole = "Hotel Staff"

/datum/outfit/hotelstaff
	name = "Hotel Staff"
	uniform = /obj/item/clothing/under/rank/civilian/assistantformal
	shoes = /obj/item/clothing/shoes/laceup
	r_pocket = /obj/item/radio/off
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/mindshield, /obj/item/implant/teleporter/ghost_role)

/obj/effect/mob_spawn/human/hotel_staff/security
	name = "hotel security sleeper"
	mob_name = "hotel security member"
	outfit = /datum/outfit/hotelstaff/security
	short_desc = "You are a peacekeeper."
	flavour_text = "You have been assigned to this hotel to protect the interests of the company while keeping the peace between \
		guests and the staff."
	important_info = "Do NOT leave the hotel, as that is grounds for contract termination."

/datum/outfit/hotelstaff/security
	name = "Hotel Security"
	uniform = /obj/item/clothing/under/rank/security/blueshirt
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	head = /obj/item/clothing/head/helmet/blueshirt
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security/full

/obj/effect/mob_spawn/human/hotel_staff/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	..()

/obj/effect/mob_spawn/human/demonic_friend
	name = "Essence of friendship"
	desc = "Oh boy! Oh boy! A friend!"
	mob_name = "Demonic friend"
	icon = 'icons/obj/cardboard_cutout.dmi'
	icon_state = "cutout_basic"
	outfit = /datum/outfit/demonic_friend
	death = FALSE
	roundstart = FALSE
	random = TRUE
	id_job = "SuperFriend"
	id_access = "assistant"
	var/datum/action/cooldown/spell/summon_friend/spell
	var/datum/mind/owner
	assignedrole = "SuperFriend"

/obj/effect/mob_spawn/human/demonic_friend/Initialize(mapload, datum/mind/owner_mind, datum/action/cooldown/spell/summon_friend/summoning_spell)
	. = ..()
	owner = owner_mind
	flavour_text = "You have been given a reprieve from your eternity of torment, to be [owner.name]'s friend for [owner.p_their()] short mortal coil."
	important_info = "Be aware that if you do not live up to [owner.name]'s expectations, they can send you back to hell with a single thought. [owner.name]'s death will also return you to hell."
	var/area/A = get_area(src)
	if(!mapload && A)
		notify_ghosts("\A friendship shell has been completed in \the [A.name].", source = src, action=NOTIFY_ATTACKORBIT, flashwindow = FALSE)
	objectives = "Be [owner.name]'s friend, and keep [owner.name] alive, so you don't get sent back to hell."
	spell = summoning_spell

/obj/effect/mob_spawn/human/demonic_friend/special(mob/living/L)
	if(!QDELETED(owner.current) && owner.current.stat != DEAD)
		L.fully_replace_character_name(null,"[owner.name]'s best friend")
		soullink(/datum/soullink/oneway, owner.current, L)
		spell.friend = L
		L.mind.hasSoul = FALSE
		var/mob/living/carbon/human/H = L
		var/obj/item/worn = H.wear_id
		var/obj/item/card/id/id = worn.GetID()
		id.registered_name = L.real_name
		id.update_label()
	else
		to_chat(L, span_userdanger("Your owner is already dead! You will soon perish."))
		addtimer(CALLBACK(L, TYPE_PROC_REF(/mob/living, dust), 15 SECONDS)) //Give em a few seconds as a mercy.

/datum/outfit/demonic_friend
	name = "Demonic Friend"
	uniform = /obj/item/clothing/under/rank/civilian/assistantformal
	shoes = /obj/item/clothing/shoes/laceup
	r_pocket = /obj/item/radio/off
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/mindshield) //No revolutionaries, he's MY friend.
	id = /obj/item/card/id

/obj/effect/mob_spawn/human/icemoon_walker
	name = "disturbed grave"
	desc = "A grave.  It's dirt seems to be churned up, with signs of recent activity."
	roundstart = FALSE
	death = FALSE
	important_info = "Do not board the Nanotrasen station under any circumstances."
	icon = 'icons/obj/lavaland/misc.dmi'
	icon_state = "grave"
	mob_species = /datum/species/zombie
	outfit = /datum/outfit/icemoon_walker
	short_desc = "You are an Icemoon Walker, created by The Syndicate's early experiments with Romerol."
	flavour_text = "You suffer from an eternal hunger, due to a curse bestowed upon you by Syndicate scientists. The snowy wastes are filled with meat, including that of Nanotrasen miners. Your feast awaits."
	assignedrole = "Icemoon Walker"

/datum/outfit/icemoon_walker
	name = "Icemoon Walker"
	uniform = /obj/item/clothing/under/color/grey
	suit = /obj/item/clothing/suit/hooded/wintercoat
	shoes = /obj/item/clothing/shoes/winterboots
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack

/obj/effect/mob_spawn/human/icemoon_walker/chieftain
	name = "immaculate grave"
	desc = "A grave.  It's dirt is perfectly shaped, as though someone has smoothed it out recently."
	roundstart = FALSE
	death = FALSE
	important_info = "Do not board the Nanotrasen station under any circumstances."
	icon = 'icons/obj/lavaland/misc.dmi'
	icon_state = "grave"
	mob_species = /datum/species/zombie
	outfit = /datum/outfit/icemoon_walker/chieftain
	short_desc = "You lead a tribe of Icemoon Walkers, zombies created by The Syndicate's early experiments with Romerol."
	flavour_text = "You suffer from an eternal hunger, due to a curse bestowed upon you by Syndicate scientists. The snowy wastes are filled with meat, including that of Nanotrasen miners. Your feast awaits."
	assignedrole = "Icemoon Walker Chieftain"

/datum/outfit/icemoon_walker/chieftain
	name = "Icemoon Walker Chieftain"
	uniform = /obj/item/clothing/under/color/grey
	suit = /obj/item/clothing/suit/hooded/wintercoat/bluecoat
	shoes = /obj/item/clothing/shoes/winterboots
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack

/obj/effect/mob_spawn/human/syndicate
	name = "Syndicate Operative"
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_NONE,
		SKILL_MECHANICAL = EXP_NONE,
		SKILL_TECHNICAL = EXP_NONE,
		SKILL_SCIENCE = EXP_NONE,
		SKILL_FITNESS = EXP_MID,
	)
	skill_points = EXP_GENIUS
	exceptional_skill = TRUE
	outfit = /datum/outfit/syndicate_empty
	assignedrole = "Space Syndicate"	//I know this is really dumb, but Syndicate operative is nuke ops

/datum/outfit/syndicate_empty
	name = "Syndicate Operative Empty"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/syndicate/alt
	implants = list(/obj/item/implant/weapons_auth)
	id = /obj/item/card/id/syndicate
	back = /obj/item/storage/backpack
	box = /obj/item/storage/box/survival/syndie

/datum/outfit/syndicate_empty/post_equip(mob/living/carbon/human/H)
	H.faction |= ROLE_ANTAG

/obj/effect/mob_spawn/human/syndicate/battlecruiser
	name = "Syndicate Battlecruiser Ship Operative"
	short_desc = "You are a crewmember aboard the syndicate flagship: the SBC Starfury."
	flavour_text = "Your job is to follow your captain's orders, maintain the ship, and keep the engine running. If you are not familiar with how the supermatter engine functions: do not attempt to start it."
	important_info = "The armory is not a candy store, and your role is not to assault the station directly, leave that work to the assault operatives."
	outfit = /datum/outfit/syndicate_empty/SBC

/datum/outfit/syndicate_empty/SBC
	name = "Syndicate Battlecruiser Ship Operative"
	l_pocket = /obj/item/gun/ballistic/automatic/pistol
	r_pocket = /obj/item/kitchen/knife/combat/survival
	belt = /obj/item/storage/belt/military/assault
	back = /obj/item/storage/backpack

/obj/effect/mob_spawn/human/syndicate/battlecruiser/assault
	name = "Syndicate Battlecruiser Assault Operative"
	short_desc = "You are an assault operative aboard the syndicate flagship: the SBC Starfury."
	flavour_text = "Your job is to follow your captain's orders, keep intruders out of the ship, and assault Space Station 13. There is an armory, multiple assault ships, and beam cannons to attack the station with."
	important_info = "Work as a team with your fellow operatives and work out a plan of attack. If you are overwhelmed, escape back to your ship!"
	outfit = /datum/outfit/syndicate_empty/SBC/assault

/datum/outfit/syndicate_empty/SBC/assault
	name = "Syndicate Battlecruiser Assault Operative"
	uniform = /obj/item/clothing/under/syndicate/combat
	l_pocket = /obj/item/ammo_box/magazine/m10mm
	r_pocket = /obj/item/kitchen/knife/combat/survival
	belt = /obj/item/storage/belt/military
	suit = /obj/item/clothing/suit/armor/vest
	suit_store = /obj/item/gun/ballistic/automatic/pistol
	back = /obj/item/storage/backpack/security
	mask = /obj/item/clothing/mask/gas/syndicate

/obj/effect/mob_spawn/human/syndicate/battlecruiser/captain
	name = "Syndicate Battlecruiser Captain"
	short_desc = "You are the captain aboard the syndicate flagship: the SBC Starfury."
	flavour_text = "Your job is to oversee your crew, defend the ship, and destroy Space Station 13. The ship has an armory, multiple ships, beam cannons, and multiple crewmembers to accomplish this goal."
	important_info = "As the captain, this whole operation falls on your shoulders. You do not need to nuke the station, causing sufficient damage and preventing your ship from being destroyed will be enough."
	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_LOW,
		SKILL_MECHANICAL = EXP_LOW,
		SKILL_TECHNICAL = EXP_LOW,
		SKILL_SCIENCE = EXP_LOW,
		SKILL_FITNESS = EXP_HIGH,
	)
	skill_points = EXP_MID
	outfit = /datum/outfit/syndicate_empty/SBC/assault/captain
	id_access_list = list(ACCESS_SYNDICATE_LEADER)

/datum/outfit/syndicate_empty/SBC/assault/captain
	name = "Syndicate Battlecruiser Captain"
	l_pocket = /obj/item/melee/transforming/energy/sword/saber/red
	r_pocket = /obj/item/melee/classic_baton/telescopic
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	suit_store = /obj/item/gun/ballistic/revolver/mateba
	back = /obj/item/storage/backpack/satchel/leather
	head = /obj/item/clothing/head/HoS/syndicate
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	glasses = /obj/item/clothing/glasses/thermal/eyepatch

//Icemoon Syndicate. Players become research agents working under a Syndicate research station.
/obj/effect/mob_spawn/human/syndicate/icemoon_syndicate //generic version - shouldnt be spawned
	name = "Syndicate Outpost Agent"
	desc = "A reinforced, Syndicate-made cryogenic sleeper used to store their agents for long periods of time, with hundreds of layers of redundancy."
	short_desc = "You are an agent at the Syndicate icemoon outpost."
	flavour_text = "You are meant to work within the outpost and may take any role within the base you see fit."
	important_info = "Do not abandon the base or give supplies to NT employees under any circumstances."
	outfit = /datum/outfit/syndicate_empty/icemoon_base
	assignedrole = "Icemoon Syndicate"
	skill_points = EXP_GENIUS // 5 skill points

/obj/effect/mob_spawn/human/syndicate/icemoon_syndicate/special(mob/living/new_spawn) //oops!
	new_spawn.grant_language(/datum/language/codespeak, TRUE, TRUE, LANGUAGE_MIND)

/datum/outfit/syndicate_empty/icemoon_base
	name = "Generic Syndicate Icemoon Outpost Agent"
	uniform = /obj/item/clothing/under/syndicate/coldres
	suit = /obj/item/clothing/suit/armor/vest
	l_pocket = /obj/item/gun/ballistic/automatic/pistol
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double
	mask = /obj/item/clothing/mask/gas/syndicate
	id = /obj/item/card/id/syndicate/anyone
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/weapons_auth, /obj/item/implant/teleporter/syndicate_icemoon) //stay in the FUCKING BASE you LITTLE SHIT

/obj/effect/mob_spawn/human/syndicate/icemoon_syndicate/security
	name = "Syndicate Outpost Security Officer"
	short_desc = "You are a security officer at the Syndicate icemoon outpost."
	flavour_text = "Protect the outpost at all costs and prevent its destruction by any means necessary. Repel intruders with your submachinegun."
	important_info = "Do not abandon the base or give supplies to NT employees under any circumstances."
	outfit = /datum/outfit/syndicate_empty/icemoon_base/security

/datum/outfit/syndicate_empty/icemoon_base/security
	name = "Syndicate Icemoon Outpost Security Guard"
	r_hand = /obj/item/gun/ballistic/automatic/c20r/ultrasecure //get fucked in every single comprehensible way.
	head = /obj/item/clothing/head/helmet/swat
	mask = /obj/item/clothing/mask/gas //i want them to look like the generic operative NPC
	belt = /obj/item/storage/belt/security/full //take like one guy alive
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses //identify the job of whoever the fuck is breaking in at a glance
	back = /obj/item/storage/backpack

/obj/effect/mob_spawn/human/syndicate/icemoon_syndicate/sci
	name = "Syndicate Outpost Researcher"
	short_desc = "You are a researcher at the Syndicate icemoon outpost."
	flavour_text = "Perform research for the sake of the Syndicate and advance technology. Do xenobiological or chemical research."
	important_info = "Do not abandon the base or give supplies to NT employees under any circumstances."
	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_LOW,
		SKILL_MECHANICAL = EXP_NONE,
		SKILL_TECHNICAL = EXP_NONE,
		SKILL_SCIENCE = EXP_HIGH,
		SKILL_FITNESS = EXP_LOW,
	)
	skill_points = EXP_HIGH
	outfit = /datum/outfit/syndicate_empty/icemoon_base/scientist

/datum/outfit/syndicate_empty/icemoon_base/scientist
	name = "Syndicate Icemoon Outpost Scientist"
	r_hand = /obj/item/gun/ballistic/rifle/sniper_rifle/ultrasecure //get fucked in every single comprehensible way.
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	accessory = /obj/item/clothing/accessory/armband/science
	glasses = /obj/item/clothing/glasses/hud/diagnostic/sunglasses/rd //it's a syndicate nerd
	back = /obj/item/storage/backpack

/obj/effect/mob_spawn/human/syndicate/icemoon_syndicate/engineer
	name = "Syndicate Outpost Engineer"
	short_desc = "You are an engineer at the Syndicate icemoon outpost."
	flavour_text = "Maintain and upgrade the base's systems and equipment. Operate the nuclear reactor and absolutely do not let it melt down."
	important_info = "Do not abandon the base or give supplies to NT employees under any circumstances."
	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_NONE,
		SKILL_MECHANICAL = EXP_MID,
		SKILL_TECHNICAL = EXP_MID,
		SKILL_SCIENCE = EXP_NONE,
		SKILL_FITNESS = EXP_LOW,
	)
	skill_points = EXP_HIGH
	outfit = /datum/outfit/syndicate_empty/icemoon_base/engineer

/datum/outfit/syndicate_empty/icemoon_base/engineer
	name = "Syndicate Icemoon Outpost Engineer"
	belt = /obj/item/storage/belt/utility/chief/full //gamer tools
	suit = /obj/item/clothing/suit/hazardvest
	head = /obj/item/clothing/head/hardhat
	accessory = /obj/item/clothing/accessory/armband/engine
	glasses = /obj/item/clothing/glasses/meson/sunglasses/ce //why not
	back = /obj/item/storage/backpack

/obj/effect/mob_spawn/human/syndicate/icemoon_syndicate/medic
	name = "Syndicate Outpost Doctor"
	short_desc = "You are a medical officer at the Syndicate icemoon outpost."
	flavour_text = "Provide medical aid to the crew of the outpost and keep them all alive."
	important_info = "Do not abandon the base or give supplies to NT employees under any circumstances."
	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_HIGH,
		SKILL_MECHANICAL = EXP_NONE,
		SKILL_TECHNICAL = EXP_NONE,
		SKILL_SCIENCE = EXP_LOW,
		SKILL_FITNESS = EXP_LOW,
	)
	skill_points = EXP_HIGH
	outfit = /datum/outfit/syndicate_empty/icemoon_base/medic

/datum/outfit/syndicate_empty/icemoon_base/medic
	name = "Syndicate Icemoon Outpost Medical Officer"
	r_hand = /obj/item/storage/firstaid/hypospray/deluxe/cmo //rapid un-hurt
	suit = /obj/item/clothing/suit/toggle/labcoat/md //I AM A SURGEON!!
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses/cmo //rapid hurt and chemical identification
	accessory = /obj/item/clothing/accessory/armband/medblue
	back = /obj/item/storage/backpack

/obj/effect/mob_spawn/human/syndicate/icemoon_syndicate/commander
	name = "Syndicate Outpost Commander"
	desc = "A Syndicate-made high-security cryogenic sleeper for senior officers. Looks fancy, and has even more layers of redundancy."
	short_desc = "You are the commander of the Syndicate icemoon outpost."
	flavour_text = "Direct the agents working under your command to operate the base, and keep it secure. If the situation gets dire, activate the emergency self-destruct located in the control room."
	important_info = "Do not abandon the base or give supplies to NT employees under any circumstances."
	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_LOW,
		SKILL_MECHANICAL = EXP_LOW,
		SKILL_TECHNICAL = EXP_LOW,
		SKILL_SCIENCE = EXP_LOW,
		SKILL_FITNESS = EXP_HIGH,
	)
	skill_points = EXP_MID
	outfit = /datum/outfit/syndicate_empty/icemoon_base/captain
	id_access_list = list(ACCESS_SYNDICATE_LEADER)

/datum/outfit/syndicate_empty/icemoon_base/captain
	name = "Syndicate Icemoon Outpost Commander"
	glasses = /obj/item/clothing/glasses/sunglasses/big //big man get big sunglasses
	ears = /obj/item/radio/headset/syndicate/alt/leader //big voice
	accessory = /obj/item/clothing/accessory/medal/gold //because the captain one is NT brand
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	l_pocket = /obj/item/melee/transforming/energy/sword/saber/red
	mask = /obj/item/clothing/mask/chameleon/gps //best one to give a GPS is this guy because he has a fast-firing 2-shot kill to defend his home with
	head = /obj/item/clothing/head/HoS/beret/syndicate
	back = /obj/item/storage/backpack/satchel/leather //LUXURY AT ITS FINEST
	suit_store = /obj/item/gun/ballistic/revolver/ultrasecure //No
	belt = /obj/item/storage/belt/sabre //ceremonial shamnk
	backpack_contents = list(
		/obj/item/modular_computer/tablet/preset/syndicate=1,
		/obj/item/ammo_box/a357=2,
		/obj/item/melee/classic_baton/telescopic=1
		)

//Icemoon Hermit. Player becomes a individual who sook out shelter from society by running away.

/obj/effect/mob_spawn/human/icemoon_hermit
	name = "Icemoon Hermit"
	short_desc = "After becoming disillusioned with society, you chose a life here with the ice and snow."
	roundstart = FALSE
	death = FALSE
	flavour_text = "Your solitude might be threatened by the new Nanotrasen facility constructed nearby, but it also might offer minor comforts and services that you haven't experienced in years."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	outfit = /datum/outfit/ice_hermit
	assignedrole = "Ice Hermit"

/datum/outfit/ice_hermit
	name = "Icemoon Hermit"
	uniform = /obj/item/clothing/under/color/grey/glorf
	suit = /obj/item/clothing/suit/hooded/wintercoat
	shoes = /obj/item/clothing/shoes/sneakers/black
	back = /obj/item/storage/backpack/satchel //satchel gang
	mask = /obj/item/clothing/mask/breath
	l_pocket = /obj/item/tank/internals/emergency_oxygen
	r_pocket = /obj/item/flashlight/glowstick

//Ancient cryogenic sleepers. Players become NT crewmen from a hundred year old space station, now on the verge of collapse.
/obj/effect/mob_spawn/human/oldstation
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a security uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a security officer"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	short_desc = "You are a security officer working for Nanotrasen, stationed onboard a state of the art research station."
	flavour_text = "You vaguely recall rushing into a cryogenics pod due to an oncoming radiation storm. \
	The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod."
	important_info = "Work as a team with your fellow survivors and do not abandon them."
	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_NONE,
		SKILL_MECHANICAL = EXP_NONE,
		SKILL_TECHNICAL = EXP_NONE,
		SKILL_SCIENCE = EXP_NONE,
		SKILL_FITNESS = EXP_HIGH,
	)
	skill_points = EXP_MID
	uniform = /obj/item/clothing/under/rank/security/officer
	shoes = /obj/item/clothing/shoes/jackboots
	id = /obj/item/card/id/away/old/sec
	r_pocket = /obj/item/restraints/handcuffs
	l_pocket = /obj/item/assembly/flash/handheld
	assignedrole = "Ancient Crew"

/obj/effect/mob_spawn/human/oldstation/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/oldstation/eng
	desc = "A humming cryo pod. You can barely recognise an engineering uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "an engineer"
	short_desc = "You are an engineer working for Nanotrasen, stationed onboard a state of the art research station."
	flavour_text = "You vaguely recall rushing into a cryogenics pod due to an oncoming radiation storm. The last thing \
	you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod."
	important_info = "Work as a team with your fellow survivors and do not abandon them."
	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_NONE,
		SKILL_MECHANICAL = EXP_MID,
		SKILL_TECHNICAL = EXP_MID,
		SKILL_SCIENCE = EXP_NONE,
		SKILL_FITNESS = EXP_NONE,
	)
	skill_points = EXP_MID
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	shoes = /obj/item/clothing/shoes/workboots
	id = /obj/item/card/id/away/old/eng
	gloves = /obj/item/clothing/gloves/color/fyellow/old
	l_pocket = /obj/item/tank/internals/emergency_oxygen
	r_pocket = null
	assignedrole = "Ancient Crew"

/obj/effect/mob_spawn/human/oldstation/science
	desc = "A humming cryo pod. You can barely recognise a science uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a scientist"
	short_desc = "You are a scientist working for Nanotrasen, stationed onboard a state of the art research station."
	flavour_text = "You vaguely recall rushing into a cryogenics pod due to an oncoming radiation storm. \
	The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. As you open \
	your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod."
	important_info = "Work as a team with your fellow survivors and do not abandon them."
	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_NONE,
		SKILL_MECHANICAL = EXP_NONE,
		SKILL_TECHNICAL = EXP_NONE,
		SKILL_SCIENCE = EXP_HIGH,
		SKILL_FITNESS = EXP_NONE,
	)
	skill_points = EXP_HIGH
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	shoes = /obj/item/clothing/shoes/laceup
	id = /obj/item/card/id/away/old/sci
	l_pocket = /obj/item/stack/medical/bruise_pack
	r_pocket = null
	assignedrole = "Ancient Crew"

/obj/effect/mob_spawn/human/pirate
	name = "space pirate sleeper"
	desc = "A cryo sleeper smelling faintly of rum."
	random = TRUE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	mob_name = "a space pirate"
	mob_species = /datum/species/skeleton
	outfit = /datum/outfit/pirate/space
	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_NONE,
		SKILL_MECHANICAL = EXP_NONE,
		SKILL_TECHNICAL = EXP_NONE,
		SKILL_SCIENCE = EXP_NONE,
		SKILL_FITNESS = EXP_MID,
	)
	skill_points = EXP_GENIUS
	exceptional_skill = TRUE
	roundstart = FALSE
	death = FALSE
	anchored = TRUE
	density = FALSE
	show_flavour = FALSE //Flavour only exists for spawners menu
	short_desc = "You are a space pirate."
	flavour_text = "The station refused to pay for your protection, protect the ship, siphon the credits from the station and raid it for even more loot."
	assignedrole = "Space Pirate"
	var/rank = "Mate"

/obj/effect/mob_spawn/human/pirate/special(mob/living/new_spawn)
	new_spawn.fully_replace_character_name(new_spawn.real_name,generate_pirate_name())
	new_spawn.mind.add_antag_datum(/datum/antagonist/pirate)

/obj/effect/mob_spawn/human/pirate/proc/generate_pirate_name()
	var/beggings = strings(PIRATE_NAMES_FILE, "beginnings")
	var/endings = strings(PIRATE_NAMES_FILE, "endings")
	return "[rank] [pick(beggings)][pick(endings)]"

/obj/effect/mob_spawn/human/pirate/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/obj/effect/mob_spawn/human/pirate/captain
	rank = "Captain"
	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_LOW,
		SKILL_MECHANICAL = EXP_LOW,
		SKILL_TECHNICAL = EXP_LOW,
		SKILL_SCIENCE = EXP_LOW,
		SKILL_FITNESS = EXP_HIGH,
	)
	skill_points = EXP_MID
	exceptional_skill = TRUE
	outfit = /datum/outfit/pirate/space/captain

/obj/effect/mob_spawn/human/pirate/gunner
	rank = "Gunner"
	outfit = /datum/outfit/pirate/space/gunner

//The Innkeeper, a iceplanet ghostrole for peacefully operating a rest stop complete with food and drinks.
/obj/effect/mob_spawn/human/innkeeper
	name = "innkeeper sleeper"
	desc = "A standard sleeper designed to keep someone in suspended animation until they are ready to awake."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	outfit = /datum/outfit/innkeeper
	id_job = "Bartender"
	id_access_list = list(ACCESS_BAR,ACCESS_KITCHEN,ACCESS_HYDROPONICS)
	random = TRUE
	roundstart = FALSE
	death = FALSE
	short_desc = "You're a simpleman on a desolate ice land, with the goal of running your inn."
	flavour_text = "The electricity bill isn't going to pay itself. Try to get some customers and earn some money at your inn."
	assignedrole = "Innkeeper"

/datum/outfit/innkeeper
	name = "Innkeeper"
	uniform = /obj/item/clothing/under/rank/civilian/bartender
	head = /obj/item/clothing/head/flatcap
	back = /obj/item/storage/backpack
	suit = /obj/item/clothing/suit/armor/vest
	mask = /obj/item/clothing/mask/cigarette/pipe
	shoes = /obj/item/clothing/shoes/sneakers/black
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	ears = /obj/item/radio/headset
	id = /obj/item/card/id
	implants = list(/obj/item/implant/teleporter/innkeeper) //stay at your inn please.
	suit_store = /obj/item/gun/ballistic/shotgun/doublebarrel //emergency weapon, ice planets are dangerous, and customers can be too.

// Syndicate Derelict Station spawns

/obj/effect/mob_spawn/human/syndicate_derelict_engineer
	name = "syndicate engineer sleeper"
	short_desc = "You're an engineer working for the Syndicate, assigned to repair a derelict research station."
	flavour_text = "During your briefing, you're told that an old syndicate research post has gone missing without notice. No theories have been brought to its fate, and it's unlikely to know the cause of its destruction. Your job will be to restore this post to optimal levels."
	important_info = "Do not abandon the derelict or mess with the main station under any circumstances."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_LOW,
		SKILL_MECHANICAL = EXP_MID,
		SKILL_TECHNICAL = EXP_MID,
		SKILL_SCIENCE = EXP_NONE,
		SKILL_FITNESS = EXP_NONE,
	)
	skill_points = EXP_HIGH
	exceptional_skill = TRUE
	outfit = /datum/outfit/syndicate_derelict_engi
	random = TRUE
	roundstart = FALSE
	death = FALSE
	assignedrole = "Syndicate Derelict Engineer"

/datum/outfit/syndicate_derelict_engi
	name = "Syndicate Derelict Engineer"
	uniform = /obj/item/clothing/under/syndicate
	head = /obj/item/clothing/head/helmet/space/syndicate/black/engie
	back = /obj/item/storage/backpack/duffelbag/syndie
	suit = /obj/item/clothing/suit/space/syndicate/black/engie
	suit_store = /obj/item/tank/internals/oxygen/red
	belt = /obj/item/storage/belt/utility/chief/full
	mask = /obj/item/clothing/mask/gas/syndicate
	shoes = /obj/item/clothing/shoes/magboots/syndie
	gloves = /obj/item/clothing/gloves/combat
	glasses = /obj/item/clothing/glasses/meson/engine
	ears = /obj/item/radio/headset/syndicate
	id = /obj/item/card/id/syndicate
	l_pocket = /obj/item/flashlight
	r_pocket = /obj/item/kitchen/knife/combat/survival
	implants = list(
		/obj/item/implant/weapons_auth,
		/obj/item/implant/teleporter/syndicate_engineer)
	box = /obj/item/storage/box/survival/syndie

/datum/outfit/syndicate_derelict_engi/post_equip(mob/living/carbon/human/H)
	H.faction |= ROLE_ANTAG
