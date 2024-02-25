
#define SCOUT (1<<0)
#define FIGHTER (1<<1)
#define WARLOCK (1<<2)
#define ALL_DARKSPAWN_CLASSES (SCOUT | FIGHTER | WARLOCK)

#define STORE_OFFENSE "offense" //things that you use and it fucks someone up
#define STORE_UTILITY "utility" //things that you use and it does something less straightforward
#define STORE_PASSIVE "passives" //things that always happen all the time


//shadow store datums (upgrades and abilities)
/datum/psi_web
	///Name of the effect
	var/name = "Basic knowledge"
	///Description of the effect
	var/desc = "Basic knowledge of forbidden arts."
	///Icon that gets displayed
	var/icon = ""
	///Cost of to learn this
	var/willpower_cost = 0
	///What specialization can buy this
	var/shadow_flags = NONE
	///what ability is granted if any
	var/list/datum/action/learned_abilities = list()
	///what is printed when learned
	var/learn_text
	///what tab of the antag menu does it fall under
	var/menu_tab
	///The owner of the psi_web datum that effects will be applied to
	var/mob/living/carbon/human/owner
	///The antag datum of the owner(used for modifying)
	var/datum/antagonist/darkspawn/darkspawn

///When the button to purchase is clicked
/datum/psi_web/proc/on_purchase(mob/living/carbon/human/user)
	if(!ishuman(user))
		return
	owner = user
	darkspawn = owner.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(!darkspawn || (darkspawn.willpower < willpower_cost))
		CRASH("[owner] tried to gain a psi_web datum despite not being a darkspawn")

	if(learn_text)
		to_chat(owner, span_velvet(learn_text))
	darkspawn.willpower -= willpower_cost
	on_gain()
	for(var/ability in learned_abilities)
		if(ispath(ability, /datum/action))
			var/datum/action/action = new ability(owner.mind)
			action.Grant(owner)
	return TRUE

///If the purchase goes through, this gets called
/datum/psi_web/proc/on_gain()
	return

/datum/psi_web/proc/on_loss()
	return

/datum/psi_web/proc/remove(refund = FALSE)
	on_loss()
	if(refund)
		darkspawn.willpower += willpower_cost
	
	for(var/ability in learned_abilities)
		if(ispath(ability, /datum/action))
			var/datum/action/action = locate(ability) in owner.actions
			action.Remove(owner)

	return QDEL_HINT_QUEUE

/datum/psi_web/Destroy(force, ...)
	remove()
	return ..()

////////////////////////////////////////////////////////////////////////////////////
//---------------------Darkspawn innate Upgrades----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/innate_darkspawn
	name = "darkspawn progression abilities"
	desc = "me no think so good"
	shadow_flags = ALL_DARKSPAWN_CLASSES
	learned_abilities = list(/datum/action/cooldown/spell/touch/devour_will, /datum/action/cooldown/spell/sacrament)

////////////////////////////////////////////////////////////////////////////////////
//----------------------Specialization innate Upgrades----------------------------//
////////////////////////////////////////////////////////////////////////////////////
//fighter
/datum/psi_web/fighter
	name = "fighter innate abilities"
	desc = "me no think so good"
	shadow_flags = FIGHTER
	learned_abilities = list(/datum/action/cooldown/spell/toggle/shadow_tendril)

/datum/psi_web/fighter/on_gain()
	owner.physiology.stamina_mod /= 2

/datum/psi_web/fighter/on_loss()
	owner.physiology.stamina_mod *= 2

//scout
/datum/psi_web/scout
	name = "scout innate abilities"
	desc = "GO FAST, TOUCH GRASS"
	shadow_flags = SCOUT
	learned_abilities = list(/datum/action/cooldown/spell/toggle/light_eater)

/datum/psi_web/scout/on_gain()
	owner.LoadComponent(/datum/component/walk/shadow)

/datum/psi_web/scout/on_loss()
	qdel(owner.GetComponent(/datum/component/walk/shadow))

//warlock
/datum/psi_web/warlock
	name = "warlock innate abilities"
	desc = "apartment \"complex\"... really? I find it quite simple"
	shadow_flags = WARLOCK
	learned_abilities = list(/datum/action/cooldown/spell/touch/veil_mind, /datum/action/cooldown/spell/unveil_mind, /datum/action/cooldown/spell/toggle/dark_staff)

/datum/psi_web/warlock/on_gain()
	darkspawn.psi_cap += 100

/datum/psi_web/warlock/on_loss()
	darkspawn.psi_cap -= 100
