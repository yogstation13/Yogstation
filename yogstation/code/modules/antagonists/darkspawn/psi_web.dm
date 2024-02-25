
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
	var/mob/living/owner
	///The antag datum of the owner(used for modifying)
	var/datum/antagonist/darkspawn/darkspawn

///When the button to purchase is clicked
/datum/psi_web/proc/on_purchase(mob/living/user)
	owner = user
	darkspawn = owner.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(!darkspawn || (darkspawn.willpower < willpower_cost))
		return FALSE

	var/datum/component/darkspawn_class/class = owner.GetComponent(/datum/component/darkspawn_class)
	if(!(class || istype(class)))
		return FALSE

	if(!(class.specialization_flag & shadow_flags))
		CRASH("[owner] tried to gain [name] which is not allowed by their specialization")

	if(learn_text)
		to_chat(owner, span_velvet(learn_text))
	darkspawn.willpower -= willpower_cost
	on_gain()
	for(var/ability in learned_abilities)
		if(istype(ability, /datum/action))
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
		if(istype(ability, /datum/action))
			var/datum/action/action = locate(ability) in owner.actions
			action.Remove(owner)

	return QDEL_HINT_QUEUE

/datum/psi_web/Destroy(force, ...)
	remove()
	return ..()

////////////////////////////////////////////////////////////////////////////////////
//----------------------Specialization innate Upgrades----------------------------//
////////////////////////////////////////////////////////////////////////////////////
//fighter
/datum/psi_web/fighter
	name = "fighter ability"
	desc = "me no think so good"
	shadow_flags = FIGHTER
	learned_abilities = list(/datum/action/cooldown/spell/toggle/shadow_tendril)

//scout
/datum/psi_web/scout
	name = "scout ability (dark speed)"
	desc = "GO FAST, TOUCH GRASS"
	shadow_flags = SCOUT
	learned_abilities = list(/datum/action/cooldown/spell/toggle/light_eater)

/datum/psi_web/scout/on_gain()
	owner.AddComponent(/datum/component/shadow_step)

/datum/psi_web/scout/on_loss()
	qdel(owner.GetComponent(/datum/component/shadow_step))

//warlock
/datum/psi_web/warlock
	name = "warlock ability"
	desc = "apartment \"complex\"... really? I find it quite simple"
	shadow_flags = WARLOCK
	learned_abilities = list(/datum/action/cooldown/spell/touch/veil_mind, /datum/action/cooldown/spell/unveil_mind)

/datum/psi_web/warlock/on_gain()
	darkspawn.psi_cap += 100

/datum/psi_web/warlock/on_loss()
	darkspawn.psi_cap -= 100

////////////////////////////////////////////////////////////////////////////////////
//-----------------------------Implicit Upgrades----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/psi_web/innate_darkspawn
	name = "darkspawn progression abilities"
	desc = "me no think so good"
	shadow_flags = ALL_DARKSPAWN_CLASSES
	learned_abilities = list(/datum/action/cooldown/spell/touch/devour_will, /datum/action/cooldown/spell/sacrament)

////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Passive Upgrades--------------------------------//
////////////////////////////////////////////////////////////////////////////////////

//Increases max Psi by 25.
/datum/psi_web/psi_cap
	name = "\'Psi\' Sigils"
	desc = "The Atlwjz sigils, representing Psi, are etched onto the forehead. Unlocking these sigils increases your maximum Psi by 25."
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER | SCOUT

/datum/psi_web/psi_cap/on_gain()
	darkspawn.psi_cap += 100

/datum/psi_web/psi_cap/on_loss()
	darkspawn.psi_cap -= 100

//Decreases the delay before psi starts regenerating
/datum/psi_web/psi_regen_delay
	name = "\'Relief\' Sigil"
	desc = "The Mqeygjao sigil, representing swiftness, is etched onto the forehead. Unlocking this sigil causes your Psi to regenerate 3 ticks sooner, and you will regenerate up to 25 Psi instead of 20."
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = WARLOCK

/datum/psi_web/psi_regen_delay/on_gain()
	darkspawn.psi_regen_delay -= 5 SECONDS

/datum/psi_web/psi_regen_delay/on_loss()
	darkspawn.psi_regen_delay += 5 SECONDS

//increase the speed at which psi regenerates when it does start
/datum/psi_web/psi_regen_speed
	name = "\'Recovery\' Sigil"
	desc = "The Mqeygjao sigil, representing swiftness, is etched onto the forehead. Unlocking this sigil causes your Psi to regenerate 3 ticks sooner, and you will regenerate up to 25 Psi instead of 20."
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = WARLOCK

/datum/psi_web/psi_regen_speed/on_gain()
	darkspawn.psi_per_second += 10

/datum/psi_web/psi_regen_speed/on_loss()
	darkspawn.psi_per_second -= 10

//Increases healing in darkness by 25%.
/datum/psi_web/dark_healing
	name = "\'Mending\' Sigil"
	desc = "The Naykranu sigil, representing perseverence, is etched onto the back. Unlocking this sigil increases your healing in darkness by 25%."
	willpower_cost = 1
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER | SCOUT

/datum/psi_web/dark_healing/on_gain()
	darkspawn.dark_healing *= 1.25

/datum/psi_web/dark_healing/on_gain()
	darkspawn.dark_healing /= 1.25

//Halves lightburn damage and gives resistance to dim light.
/datum/psi_web/light_resistance
	name = "\'Lightward\' Sigil"
	desc = "The Lnkpayp sigil, representing imperviousness, is etched onto the abdomen. Unlocking this sigil halves light damage taken and protects from dim light."
	willpower_cost = 2
	menu_tab = STORE_PASSIVE
	shadow_flags = FIGHTER

/datum/psi_web/light_resistance/on_gain()
	darkspawn.light_burning /= 2
	ADD_TRAIT(owner, TRAIT_DARKSPAWN_LIGHTRES, src)

/datum/psi_web/light_resistance/on_loss()
	darkspawn.light_burning *= 2
	REMOVE_TRAIT(owner, TRAIT_DARKSPAWN_LIGHTRES, src)

//Using shadow tendrils will now form two tendrils if possible.
//Attacking with one set of tendrils will attack with the other.
//This also speeds up most actions they have.
//Check shadow_tendril.dm for the effect.
/datum/psi_web/twin_tendrils
	name = "\'Duality\' Sigils"
	desc = "The Zkqxha sigils, representing duality, are etched onto the arms. Unlocking these sigils causes tendrils to form in both hands if possible, which empowers both."
	willpower_cost = 1
	shadow_flags = FIGHTER
	menu_tab = STORE_PASSIVE

	var/datum/action/cooldown/spell/toggle/shadow_tendril/spell

/datum/psi_web/twin_tendrils/on_gain()
	spell = locate() in owner.actions
	if(spell)
		spell.twin = TRUE
	else
		remove(TRUE)

/datum/psi_web/twin_tendrils/on_loss()
	if(spell)
		spell.twin = FALSE
		spell = null
