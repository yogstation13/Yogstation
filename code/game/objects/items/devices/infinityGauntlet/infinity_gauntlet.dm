/obj/item/clothing/gloves/infinity
	name = "Infinity Gauntlet"
	desc = "A gauntlet made of near-indestructable metal, made to hold the stones of absolute power, bringing all the stones together will grant the ultimate spell..."
	icon = 'icons/obj/gauntlet.dmi'
	icon_state = "gauntlet"
	item_state = "gauntlet"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	attack_verb = list("ponched", "punched", "pwned")
	force = 50
	throwforce = 10
	throw_range = 7
	strip_delay = 15 SECONDS
	cold_protection = HANDS
	heat_protection = HANDS
	w_class = WEIGHT_CLASS_NORMAL
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100, ELECTRIC = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	///list of ability paths held by the gauntlet
	var/list/abilities = list()
	///number of abilities required to grant the snap ability
	var/snap_threshold = 6

/obj/item/clothing/gloves/infinity/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_GLOVES)
		grant_abilities(user)

/obj/item/clothing/gloves/infinity/dropped(mob/user)
	. = ..()
	remove_abilities(user)
	return ..()

/obj/item/clothing/gloves/infinity/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/infinity_stone))
		var/obj/item/infinity_stone/stone = A
		stone.install(src, user)
	else
		..()

/obj/item/clothing/gloves/infinity/proc/update_abilities(mob/user)
	remove_abilities(user)
	if(user.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		grant_abilities(user)

/obj/item/clothing/gloves/infinity/proc/grant_abilities(mob/user)
	if(LAZYLEN(abilities))
		for(var/ability in abilities)
			if(ispath(ability, /datum/action))
				var/datum/action/spell = new ability(user)
				spell.Grant(user)
		if(LAZYLEN(abilities) >= snap_threshold)
			var/datum/action/cooldown/spell/snap/thanos = new(user)
			thanos.Grant(user)

/obj/item/clothing/gloves/infinity/proc/remove_abilities(mob/user)
	for(var/ability in abilities)
		if(ispath(ability, /datum/action))
			var/datum/action/action = locate(ability) in user.actions
			if(action)
				action.Remove(user)
				qdel(action)

	var/datum/action/action = locate(/datum/action/cooldown/spell/snap) in user.actions
	if(action)
		action.Remove(user)
		qdel(action)

/datum/action/cooldown/spell/snap
	button_icon_state = "touchofdeath"
	spell_requirements = NONE
	cooldown_time = 1 MINUTES
	invocation = "I am inevitable."
	invocation_type = INVOCATION_SHOUT

/datum/action/cooldown/spell/snap/cast(atom/cast_on)
	. = ..()
	sound_to_playing_players('sound/magic/clockwork/narsie_attack.ogg')
	var/list/victims = shuffle_inplace(GLOB.mob_living_list.Copy()) //make a copy list so it doesn't fuck with 
	var/number_of_victims = round(LAZYLEN(victims)/2)
	for(var/mob/living/snapped as anything in victims)
		addtimer(CALLBACK(snapped, TYPE_PROC_REF(/mob/living, dust), TRUE), rand(1,100)) //dust randomly, and with a delay (give the fear that you might be next)

		if(number_of_victims <= 0)
			return
		number_of_victims --
