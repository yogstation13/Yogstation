/obj/item/staff
	name = "inert staff"
	desc = "Usually used to channel power, this one seems hollow. Probably shouldn`t have it anyways..."
	icon = ''
	icon_state = ""
	item_state = ""
	lefthand_file = ''
	righthand_file = '' // TODO, All sprites :3
	slot_flags = ITEM_SLOT_BACK
	force = 8 // bonk
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL // its a big stick basically
	hitsound = '' // todo
	attack_verb = list("thwacked", "cleansed", "purified", "cludged")
	var/psychic_heat = 0 // To allow warp effects

/obj/item/staff/psyker
	name = "force staff"
	desc = "A Psykers staff, used to channel the powers of the warp with dealy prowess, or blow themselves up. More often the latter."

///////////////////////////////////////////////////////////////////////////////////
// Below follow the utter nonsense of trying to make the staff work sorta like a staff
///////////////////////////////////////////////////////////////////////////////////

/obj/item/staff/psyker/pickup(var/datum/mind/psyker, mob/user)
	if(psyker.special_role == ROLE_PSYKER)
		var/datum/action/cooldown/spell/pointed/mindpop = new(psyker)
		mindpop.Grant(psyker)


/obj/item/staff/psyker/dropped(var/datum/mind/psyker, mob/user)
	if(psyker.special_role == ROLE_PSYKER)
		to_chat(usr, span_warning("Your ability to channel your power fades as the staff drops from your grasp!"))
		var/datum/action/cooldown/spell/pointed/mindpop = locate(var/datum/action/cooldown/spell/pointed/mindpop) in psyker.actions
		if(mindpop)
			mindpop.Remove(psyker)
			 

/datum/action/cooldown/spell/pointed/mindpop	

// /datum/action/innate/staff/mindcrush/do_ability(mob/living/carbon/human/cast_on)
// 	. = ..()
// 	if(!.)
// 		return FALSE
// 	if(!ishuman(cast_on)) // cant crush a borg or a simple mob
// 		return FALSE
// 	if(isliving(cast_on))
// 		var/mob/living/L = cast_on
// 		L.apply_damage(200, def_zone = BODY_ZONE_HEAD)
// 		var/obj/item/bodypart/head = L.get_bodypart(BODY_ZONE_HEAD)
// 		head.gib()
// 		L.spawn_gibs()
// 		staff.heat += spell_heat
// 		to_chat(invoker, span_warning("so no head?"))
// 	to_chat(invoker, span_warning("its working"))
// 	return TRUE
