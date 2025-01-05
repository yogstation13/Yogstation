GLOBAL_LIST_INIT(all_bloodsucker_powers, generate_bloodsucker_power_list())

/proc/generate_bloodsucker_power_list()
	var/list/powers = list()
	for(var/path in subtypesof(/datum/bloodsucker_power))
		powers += new path()
	return

/datum/bloodsucker_power
	var/ability_path
	///Name of the effect
	var/name = "Basic knowledge"
	///Description of the effect
	var/desc = "Basic knowledge of forbidden arts."
	///Fancy description about the effect
	var/lore_description = ""
	///Icon file used for the tgui menu
	var/icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	///Specific icon used for the tgui menu
	var/icon_state = null
	///What clan can buy this
	var/list/clans_purchasable = list()
	///what ability is granted if any
	var/list/datum/action/learned_abilities = list()
	///The owner of the power datum that effects will be applied to
	var/datum/mind/owner
	///The antag datum of the owner(used for modifying)
	var/datum/antagonist/bloodsucker/bloodsucker

///When the button to purchase is clicked
/datum/bloodsucker_power/proc/on_purchase(datum/mind/user, silent = FALSE)
	if(!istype(user, /datum/mind))
		return
	owner = user
	bloodsucker = owner.has_antag_datum(/datum/antagonist/bloodsucker)
	if(!bloodsucker)
		CRASH("[owner] tried to gain an ability datum despite not being a bloodsucker")
	if(bloodsucker.bloodsucker_level_unspent <= 0)
		return

	bloodsucker.bloodsucker_level_unspent --

	if(!silent)
		to_chat(user, span_velvet("You have unlocked [name]"))
	for(var/ability in learned_abilities)
		if(ispath(ability, /datum/action))
			var/datum/action/action = new ability(owner)
			action.Grant(owner.current)
	return TRUE

/datum/bloodsucker_power/proc/remove(refund = FALSE)
	for(var/ability in learned_abilities)
		if(ispath(ability, /datum/action))
			var/datum/action/action = locate(ability) in owner.current.actions
			if(action)
				action.Remove(owner.current)
				qdel(action)

	if(refund && bloodsucker)
		bloodsucker.bloodsucker_level_unspent ++
	
	return QDEL_HINT_QUEUE

/datum/bloodsucker_power/proc/ascend()

/datum/bloodsucker_power/Destroy(force, ...)
	remove()
	return ..()
