/datum/action/cooldown/spell/disguise
	name = "Mimicry"
	desc = "Why fight your foes when you can simply outwit them? Disguises the caster as a random crewmember. \
			The body-covering shell keeps your form as is, and protects you from body-altering effects."
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "disguise"

	school = SCHOOL_TRANSMUTATION
	invocation = "CONJR DIS GUISE"
	invocation_type = INVOCATION_WHISPER

	cooldown_time = 1 MINUTES
	cooldown_reduction_per_rank = 10 SECONDS

	spell_max_level = 2
	spell_requirements = NONE
	var/is_disguised = FALSE //Tells us if a disguise is currently up.
	var/wasbeast = FALSE //We need this to make sure on can_cast, if they're found to be human and have this flag we can manually activate the uncloaking proc.

/datum/action/cooldown/spell/disguise/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(owner))
		//We need to undo the cloak after non-humanoid disguises because when the wizard becomes a non human during the spell, it will mess up their sprite. But since they are non human, we can't actually undo the spell. This leaves our recloaking bugged as hell, and breaks a lot of stuff.
		return FALSE
	if(ishuman(owner) && (wasbeast == TRUE))
		addtimer(CALLBACK(src, PROC_REF(undocloak), owner), 0.2 SECONDS)
	return TRUE

/datum/action/cooldown/spell/disguise/cast(mob/living/user)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/C = user //Turns the user into a carbon, we'll need this later.
	var/list/potentials = list()
	for(var/mob/living/carbon/human/H in GLOB.carbon_list)
		if(H.stat != DEAD)
			potentials += H
	var/mob/living/carbon/human/target = pick(potentials) //Picks a random subject from the viable targets.
	cloak(C, target, user)

	return TRUE

/datum/action/cooldown/spell/disguise/proc/cloak(mob/living/carbon/human/C, mob/living/carbon/human/target, mob/user) //Code shortcut to enable the disguise.
	if(is_disguised)
		message_admins("[ADMIN_LOOKUPFLW(C)] just tried to disguise while disguised! That shouldn't happen!") 
		return
	new /obj/effect/temp_visual/dir_setting/ninja/cloak(get_turf(C), C.dir) //Disguise animation.
	C.name_override = target.name
	C.SetSpecialVoice(target.name)
	C.icon = target.icon
	C.icon_state = target.icon_state
	C.cut_overlays()
	C.add_overlay(target.get_overlays_copy(list(HANDS_LAYER)))
	C.update_inv_hands()
	log_game("[C.name] has disguised as [target.name]!") 
	is_disguised = TRUE
	addtimer(CALLBACK(src, PROC_REF(undocloak), C), (40 SECONDS + (spell_level * 3))) //Sets it up so this is unchanged on default level, and goes up per level invested.
		
/datum/action/cooldown/spell/disguise/proc/undocloak(mob/living/carbon/human/C) //Code shortcut to disable the disguise.
	if((ishuman(C) && (C.mind)) || wasbeast == TRUE) //Shapeshift spell takes out your mind, buckles you to a body, and then puts your mind in a summoned animal. We need this bullshit to both check that this is not happening, and then override it when we have to fix the bullshit.
		new /obj/effect/temp_visual/dir_setting/ninja(get_turf(C), C.dir) //Makes an animation for disguising.
		C.name_override = null
		C.UnsetSpecialVoice()
		C.cut_overlays()
		C.regenerate_icons()
		is_disguised = FALSE
		wasbeast = FALSE
		return
	else
		wasbeast = TRUE //Unfortunately we need this to counter shapeshifting bullshit, sets up the caster to immediatly revert when becoming human.



