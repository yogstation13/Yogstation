/obj/effect/proc_holder/spell/disguise
	name = "Mimicry"
	desc = "Why fight your foes when you can simply outwit them? Disguises the caster as a random crewmember. The body-covering shell keeps your form as is, and protects you from body-altering effects."
	invocation = "CONJR DIS GUISE"
	invocation_type = "whisper"
	school = "transmutation"
	charge_max = 30 SECONDS
	level_max = 2
	cooldown_min = 25 SECONDS
	clothes_req = FALSE
	var/is_disguised = FALSE //Tells us if a disguise is currently up.
	var/wasbeast = FALSE //We need this to make sure on can_cast, if they're found to be human and have this flag we can manually activate the uncloaking proc.
	action_icon = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "disguise"

/obj/effect/proc_holder/spell/disguise/can_cast(mob/user = usr)
	if(!ishuman(user))
		//We need to undo the cloak after non-humanoid disguises because when the wizard becomes a non human during the spell, it will mess up their sprite. But since they are non human, we can't actually undo the spell. This leaves our recloaking bugged as hell, and breaks a lot of stuff.
		return FALSE
	if(ishuman(user) && (wasbeast == TRUE))
		addtimer(CALLBACK(src, .proc/undocloak, user), 2)
	return TRUE

/obj/effect/proc_holder/spell/disguise/choose_targets(mob/user = usr)
	perform(user=user)

/obj/effect/proc_holder/spell/disguise/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/C = user //Turns the user into a carbon, we'll need this later.
	var/list/potentials = list()
	for(var/mob/living/carbon/human/H in GLOB.carbon_list) //Checks all the humanoid mobs.
		if(H.job) //Checks if they're crew.
			potentials += H //Adds the crewmember to the list.
	if(potentials.len == 0)
		to_chat(C, span_notice("There's nobody to disguise as!"))
		revert_cast(user)
		return
	var/mob/living/carbon/human/target = pick(potentials) //Picks a random subject from the viable targets.
	cloak(C, target, user)



/obj/effect/proc_holder/spell/disguise/proc/cloak(var/mob/living/carbon/human/C, var/mob/living/carbon/human/target, mob/user) //Code shortcut to enable the disguise.
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
	addtimer(CALLBACK(src, .proc/undocloak, C), (15 SECONDS + (spell_level * 3 SECONDS)))
		
/obj/effect/proc_holder/spell/disguise/proc/undocloak(var/mob/living/carbon/human/C) //Code shortcut to disable the disguise.
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

/datum/spellbook_entry/disguise //Spellbook entry, needed for the spell to be purchasable in game.
	name = "Mimicry"
	spell_type = /obj/effect/proc_holder/spell/disguise
	category = "Assistance"
	cost = 1




