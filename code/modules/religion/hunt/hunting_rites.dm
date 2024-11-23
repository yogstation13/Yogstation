GLOBAL_LIST_EMPTY(sect_of_the_hunt_preys)
/datum/religion_rites/initiate_hunter
	name = "Initiate Hunter"
	desc = "Awakens the hunter's instincts and lets them hear the Call of the Hunt. Buckle a human to awaken them, otherwise it will awaken you."
	ritual_length = 20 SECONDS
	ritual_invocations = list("By the grace and speed of our god ...",
						"... We call upon you, that beasts may be slain ...")
	invoke_msg = "... Awaken Hunter. Awaken and heed the call of the Hunt!!"
	favor_cost = -1

/datum/religion_rites/initiate_hunter/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user, span_warning("You're going to awaken the one buckled on [movable_reltool]."))
	else
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
			return FALSE
		if(user.has_status_effect(/datum/status_effect/agent_pinpointer/hunters_sense))
			to_chat(user, span_warning("You've already awakened yourself. To awaken others, they must be buckled to [movable_reltool]."))
			return FALSE
		to_chat(user, span_warning("You're going to awaken yourself with this ritual."))
	return ..()


/datum/religion_rites/initiate_hunter/invoke_effect(mob/living/user, atom/religious_tool)
	..()
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	var/mob/living/carbon/human/rite_target
	if(!movable_reltool?.buckled_mobs?.len)
		rite_target = user
	else
		for(var/buckled in movable_reltool.buckled_mobs)
			if(ishuman(buckled))
				rite_target = buckled
				break
	if(!rite_target)
		return FALSE
	rite_target.apply_status_effect(/datum/status_effect/agent_pinpointer/hunters_sense)
	rite_target.visible_message(span_notice("[rite_target] has awakened their instincts!"))
	return TRUE

/datum/religion_rites/call_the_hunt
	name = "Call the Hunt"
	desc = "Call upon the Great Hunt and Seek your Prey"
	ritual_length = 30 SECONDS
	ritual_invocations = list("We call now upon the most holy ...",
	"... By the will of our god ...",
	"... And by divine decree ...")
	invoke_msg = "... There is prey to be felled!!"
	favor_cost = 0


/datum/religion_rites/call_the_hunt/invoke_effect(mob/living/user, atom/religious_tool)
	. = ..()

	var/turf/prey_location = get_safe_random_station_turf()
	GLOB.sect_of_the_hunt_preys += new /mob/living/basic/deer/prey(prey_location)


/datum/religion_rites/craft_hunters_atlatl
	name = "Craft Hunter's Atlatl"
	desc = "With holy will and divine grace create a hunter's atlatl and a quiver of throwing spears"
	ritual_length = 15 SECONDS
	ritual_invocations = list("By grace and instinct ...",
	"... We are blessed with holy weapons ...")
	invoke_msg = "... May we strike true!"
	favor_cost = 5

/datum/religion_rites/craft_hunters_atlatl/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	var/altar_turf = get_turf(religious_tool)
	new /obj/item/gun/ballistic/atlatl(altar_turf)
	new /obj/item/storage/bag/spearquiver(altar_turf)

/datum/religion_rites/carve_spears
	name = "Carve throwing spears"
	desc = "Carve blessed spears of the Hunt so that more prey be slain"
	ritual_length = 10 SECONDS
	invoke_msg = "There's always more prey. The Hunt continues!"
	favor_cost = 3

/datum/religion_rites/carve_spears/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	for (var/i in 1 to 3)
		new /obj/item/ammo_casing/caseless/thrownspear(altar_turf)
