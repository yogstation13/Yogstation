/obj/item/skilltrainer
	name = "skilltrainer"
	desc = "A one-use dose of nanites which trains a specific skill by administering it through the orbit of the eye, once released into the brain they quickly improve the subject's skills in a specific area and transmute themselves into neural tissue as needed."
	icon = 'icons/obj/device.dmi'
	icon_state = "skill-trainer"
	w_class = WEIGHT_CLASS_SMALL
	var/reusable = FALSE		//If skills are removed from the change_skills list after given
	var/alert_target = FALSE	//If the skill trainer alerts the target of the skill change
	var/destroy_after = FALSE	//If the skill trainer is destroyed once its empty
	var/set_skills = FALSE		//If the skill trainer replaces the target skill set or adds to it
	var/list/change_skills		//List of changed skills, index is the skill ID and the value is the change amount

/obj/item/skilltrainer/proc/can_train(target, user)
	if(!change_skills || !change_skills.len)
		to_chat(user, span_warning("\The [src] has already been used and dulled."))
		return FALSE
	var/datum/skillset/target_skillset = find_skillset(target)
	if(!usesSkills(target_skillset))
		to_chat(user, span_warning("\The [src] rejects [target]."))
		return FALSE
	return TRUE

/obj/item/skilltrainer/proc/train_skills(target)
	var/datum/skillset/target_skillset = find_skillset(target)
	for(var/skill_id in change_skills)
		if(set_skills)
			target_skillset.set_skill_level(skill_id, change_skills[skill_id], alert_target)
		else
			target_skillset.adjust_skill_level(skill_id, change_skills[skill_id], alert_target)
		if(!reusable)
			LAZYREMOVE(change_skills, skill_id)

	if(destroy_after && (!change_skills || !change_skills.len))
		qdel(src)
	return TRUE

/obj/item/skilltrainer/attack(mob/living/M, mob/user)
	if(!can_train(M, user))
		return
	playsound(src, 'sound/weapons/slice.ogg', 5)
	if(!do_after(user, 10, target = M) || !can_train(M, user))
		return
	playsound(src, 'sound/effects/hypospray.ogg', 20)
	train_skills(M)

/obj/item/skilltrainer/combat
	name = "combat skilltrainer"
	change_skills = list(SKILL_HAND_TO_HAND = 1, SKILL_MELEE_WEAPONS = 1, SKILL_RANGED_WEAPONS = 1)

/obj/item/skilltrainer/max
	name = "max skilltrainer"
	set_skills = TRUE

/obj/item/skilltrainer/max/Initialize()
	..()
	if("All Master" in SSskills.skill_lists)
		change_skills = SSskills.skill_lists["All Master"]

/obj/item/skilltrainer/job
	name = "job skilltrainer"
	set_skills = TRUE
	var/trainer_job		//The job we take the skilllist from

/obj/item/skilltrainer/job/Initialize()
	..()
	if(trainer_job in SSjob.name_occupations_all)
		var/datum/job/skilltrainer_job = SSjob.name_occupations_all[trainer_job]
		change_skills = skilltrainer_job.default_skill_list

/obj/item/skilltrainer/job/captain
	name = "captain skilltrainer"
	trainer_job	= "Captain"
