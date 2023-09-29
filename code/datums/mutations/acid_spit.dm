/datum/mutation/human/acidspit // polysmorph inert mutation
	name = "Acid Spit"
	desc = "An ancient mutation from xenomorphs that changes the salivary glands to produce acid"
	instability = 50
	difficulty = 12
	locked = TRUE
	text_gain_indication = span_notice("Your saliva burns your mouth!")
	text_lose_indication = span_notice("Your saliva cools down.")
	power_path = /datum/action/cooldown/spell/pointed/projectile/acid_spit

/datum/action/cooldown/spell/pointed/projectile/acid_spit
	name = "Acid Spit"
	desc = "You focus your corrosive saliva to spit at your target"
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "alien_neurotoxin_0"
	active_icon_state = "alien_neurotoxin_1"
	base_icon_state = "alien_neurotoxin_0"
	active_overlay_icon_state = "bg_spell_border_active_red"
	cooldown_time = 18 SECONDS
	spell_requirements = NONE
	antimagic_flags = NONE
	school = SCHOOL_EVOCATION
	spell_requirements = NONE
	sound = 'sound/effects/alien_spitacid.ogg'

	active_msg = "You focus your acid spit!"
	deactive_msg = "You relax."
	projectile_type = /obj/item/projectile/bullet/acid

/datum/action/cooldown/spell/pointed/projectile/acid_spit/before_cast(atom/cast_on)
	. = ..()
	if(!iscarbon(owner))
		return

	var/mob/living/carbon/spitter = owner
	if(!spitter.is_mouth_covered())
		return

	spitter.wear_mask.acid_act(300, 600) //guarantees whatever is blocking it to get destroyed. probably.
	to_chat(spitter, span_warning("Something infront of your mouth blocks some of the spit!"))

/obj/item/projectile/bullet/acid
	name = "acid spit"
	icon_state = "neurotoxin"
	damage = 2
	damage_type = BURN
	flag = BIO
	range = 7
	speed = 1.8 // spit is not very fast

obj/item/projectile/bullet/acid/on_hit(atom/target, blocked = FALSE)
	if(isalien(target)) // shouldn't work on xenos
		nodamage = TRUE
	else if(!isopenturf(target))
		target.acid_act(50, 15) // does good damage to objects and structures
	else if(iscarbon(target))
		target.acid_act(18, 15) // balanced
	return ..()
