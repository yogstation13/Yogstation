/datum/component/darkspawn_class
	///Class name
	var/name = "Debug class"
	///Class short description
	var/description = "This is a debug class, you shouldn't see this short description."
	///Class long description. This will be shown in TGUI to explain to players with more depth of what to expect from the class
	var/long_description = "This is a debug class, you shouldn't see this long and in-depth description that i'll probably write at some point."
	///The flag of the classtype. Used to determine which psi_web options are available to the class
	var/specialization_flag = NONE
	///The darkspawn who this class belongs to
	var/mob/living/carbon/human/owner

	var/datum/antagonist/darkspawn/d
	///Abilities our class will start with. Granted to the owning darkspawn on initialization
	var/list/datum/psi_web/starting_abilities = list()
	///Abilities the darkspawn has learned from the psi_web
	var/list/datum/psi_web/learned_abilities = list()
	///The color of their aura outline
	var/render_layer = FLOAT_LAYER 
	var/render_plane = FLOAT_PLANE
	var/class_color = COLOR_SILVER

	//var/filter_data = list("type" = "outline", "color" = COLOR_PURPLE, "alpha" = 0, "size" = 1)
	var/filter
	
	var/icon_file = 'yogstation/icons/mob/darkspawn.dmi'
	var/mutable_appearance/eyes
	var/eye_icon = "eyes"

	var/mutable_appearance/class_sigil
	var/class_icon = "classless"

/datum/component/darkspawn_class/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	owner = parent
	if(!isdarkspawn(owner))
		return COMPONENT_INCOMPATIBLE
	for(var/datum/psi_web/power in starting_abilities)
		if(ispath(power))
			power = new()
		learned_abilities |= power
		power.on_gain()
	
	eyes = mutable_appearance(icon_file, eye_icon, layer = render_layer, plane = render_plane)
	eyes.color = class_color
	owner.add_overlay(eyes)
	
	class_sigil = mutable_appearance(icon_file, class_icon, layer = render_layer, plane = render_plane)
	class_sigil.color = class_color
	//SSvis_overlays.add_vis_overlay(owner, icon_file, eye_icon, layer, EMISSIVE_PLANE, owner.dir)
	owner.add_overlay(class_sigil)
	
	owner.add_filter(DARKSPAWN_AURA_FILTER, 2, list("type" = "outline", "color" = class_color, "alpha" = 0, "size" = 1))
	filter = owner.get_filter(DARKSPAWN_AURA_FILTER)
	animate(filter, alpha = 200, time = 1 SECONDS, loop = -1)
	animate(alpha = 0, time = 1 SECONDS)

/datum/component/darkspawn_class/Destroy()
	. = ..()
	filter = null
	owner = null

/datum/component/darkspawn_class/RegisterWithParent()
	RegisterSignal(parent, COMSIG_DARKSPAWN_PURCHASE_POWER, PROC_REF(gain_power))
	

/datum/component/darkspawn_class/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_DARKSPAWN_PURCHASE_POWER)
	
	owner.cut_overlay(eyes)
	owner.cut_overlay(class_sigil)
	QDEL_NULL(class_sigil)
	for(var/datum/psi_web/power in learned_abilities)
		lose_power(power)
	owner.remove_filter(DARKSPAWN_AURA_FILTER)
	
/datum/component/darkspawn_class/proc/get_purchasable_abilities()
	var/list/datum/psi_web/available_abilities = list()
	for(var/datum/psi_web/ability in subtypesof(/datum/psi_web))
		if(!(ability.shadow_flags & specialization_flag) || locate(ability) in learned_abilities)
			continue
		available_abilities += ability

/datum/component/darkspawn_class/proc/gain_power(power_typepath)
	if(!ispath(power_typepath, /datum/psi_web))
		CRASH("[owner] tried to gain [power_typepath] which is not a valid darkspawn ability")
	var/datum/psi_web/new_power = new power_typepath()
	if(!(new_power.shadow_flags & specialization_flag))
		CRASH("[owner] tried to gain [new_power] which is not allowed by their specialization")


/datum/component/darkspawn_class/proc/lose_power(datum/psi_web/power)
	if(!locate(power) in learned_abilities)
		CRASH("[owner] tried to lose [power] which they haven't learned")
	
	learned_abilities -= power
	power.remove()


/datum/component/darkspawn_class/classless
	name = "Deprived"
	description = "You've yet to peep the horror."
	long_description = "You can probably do this with just a club and loincloth anyway."
	specialization_flag = NONE
	class_color = COLOR_SILVER

/datum/component/darkspawn_class/fighter
	name = "Fighter"
	description = "Thick as a brick looking for dick to kick."
	long_description = "Where is the thrill of carnage."
	specialization_flag = FIGHTER
	class_color = COLOR_RED

/datum/component/darkspawn_class/scout
	name = "Scout"
	description = "Fast as fuck boi."
	long_description = "You're sure to win because your speed is superior."
	specialization_flag = SCOUT
	class_color = COLOR_YELLOW

/datum/component/darkspawn_class/warlock
	name = "Warlock"
	description = "Shadow Wizard Money Gang. You love casting spells and shit."
	long_description = "Legalize nuclear bombs."
	specialization_flag = WARLOCK
	class_color = COLOR_STRONG_VIOLET
