/datum/action/cooldown/spell/conjure/summon_greedslots
	name = "Summon Slotmachine"
	desc = "Summon forth a temporary slot machine of greed, allowing you to offer patrons a deadly game where the price is their life (and some money if you'd like) and the possible prize is a one use die of fate."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "slots"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	invocation = "Just one game?"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cooldown_time = 30 SECONDS
	summon_lifespan = 1 MINUTES
	summon_radius = 0 //spawns on top of us
	summon_type = list(/obj/structure/cursed_slot_machine/betterchance)

/datum/action/cooldown/spell/conjure/cursed_item //conjure a random unique cursed item, which can impart various benefits, but always at a cost...
	name = "Summon Cursed Item"
	desc = "Manifest a random cursed object from hell beneath you. They have powerful applications, though often times with unintended consequences. Perfect for selling, or even using yourself if in a bind. Be aware, many of their effects can harm you too if used."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "moneybag"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	invocation = "Power beyond measure"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cooldown_time = 180 SECONDS //no farming a bunch of items
	summon_radius = 0 //spawns on top of us
	summon_type = list(
		/obj/item/katana/greedcursed,
		/obj/item/reagent_containers/pill/greedcursed,
		/obj/item/book_of_babel/greedcursed,
		/obj/item/book/granter/action/spell/sacredflame/weak, //this one isnt actually 'cursed', but its also way weaker than the normal spell, and you're still setting yourself on fire
		/obj/item/greedcursed_bottle
	)

/obj/item/katana/greedcursed //quite a bit weaker katana, still deals good damage, but also siphons part of your health every hit.
	name = "peculiar katana"
	desc = "The handle seems to dig into your flesh as you swing it..."
	force = 20
	block_chance = 25
	armour_penetration = 15
	sharpness = SHARP_EDGED

/obj/item/katana/greedcursed/attack(mob/target, mob/living/carbon/human/user)
	to_chat(user, "<span class ='warning'>[src] digs into your hands...</span>")
	user.apply_damage(rand(force/4, force/2), BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)) //5-10 damage to one of your arms
	..()

/obj/item/reagent_containers/pill/greedcursed //has a good amount of healing chems, you just have to deal with being set on fire first
	name = "strange pill"
	desc = "It smells of brimstone. Just looking it, you instinctively feel like this might heal you in exchange for something else..."
	volume = 25
	list_reagents = list(/datum/reagent/medicine/omnizine = 20, /datum/reagent/hellwater = 3, /datum/reagent/medicine/lavaland_extract = 2)
	icon_state = "pill21"

/obj/item/book_of_babel/greedcursed
	desc = "An ancient tome written in countless tongues. It emits an overwhelming odor of sulphur. Reading this may bring you knowledge, if you can handle the price."

/obj/item/book_of_babel/greedcursed/attack_self(mob/living/carbon/human/user)
	if(!user.can_read(src))
		return FALSE
	if(!istype(user))
		return
	to_chat(user, span_notice("You flip through the pages as quickly as possible, the overwhelming stench draining seemingly your very being. As you finish, the book suddenly ignites in a flash of hellfire, and turns to dust."))
	user.grant_all_languages()
	user.health -= 20
	user.maxHealth -= 20
	new /obj/effect/decal/cleanable/ash(get_turf(user))
	qdel(src)

/obj/item/greedcursed_bottle //recovers a portion of your max health, at the cost of being cursed into a shadowperson
	name = "bottle of dark blood"
	desc = "The contents seem to swirl constantly, and shrivel away when faced with bright light. If you drink this, you may just recover a part of yourself, though perhaps at a terrible cost..."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/greedcursed_bottle/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return
	
	to_chat(user, span_danger("You feel a bit better for but a moment, like your very life force grew stronger. Then, all of a sudden, your flesh sloughs and darkens, revealing your terrible new form..."))
	user.set_species(/datum/species/shadow)
	if(user.maxHealth < 100) //cannot bring you above standard max health
		user.maxHealth += 20 

	playsound(user.loc,'sound/items/drink.ogg', rand(10,50), 1)
	qdel(src)
