/datum/mutation/human/radiantburst
	name = "Radiant Burst"
	desc = "A mutation hidden deep within ethereal genetic code that allows you to blind people nearby."
	quality = POSITIVE
	difficulty = 12
	locked = TRUE
	text_gain_indication = span_notice("The light surges within you! Ah, such bliss.") //changing this to be a reference because who's gonna stop me, I made the gene in the first place
	text_lose_indication = span_notice("The shadow returns to your night sky.") //really hamfist in those references
	power_path = /datum/action/cooldown/spell/aoe/radiantburst
	instability = 30
	power_coeff = 1 //increases aoe
	synchronizer_coeff = 1 //prevents blinding
	energy_coeff = 1 //reduces cooldown
	conflicts = list(/datum/mutation/human/glow, /datum/mutation/human/glow/anti)

/datum/mutation/human/radiantburst/modify()
	. = ..()
	var/datum/action/cooldown/spell/aoe/radiantburst/to_modify = .
	if(!istype(to_modify)) // null or invalid
		return

	if(GET_MUTATION_SYNCHRONIZER(src) < 1)
		to_modify.safe = TRUE //don't blind yourself
	if(GET_MUTATION_POWER(src) > 1)
		to_modify.bonus_strength += 1 //damages darkspawns more and blinds more
		to_modify.aoe_radius += 1

/datum/action/cooldown/spell/aoe/radiantburst
	name = "Radiant Burst"
	desc = "You release all the light that is within you."
	button_icon = 'icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "Kindle"
	active_icon_state = "Kindle"
	base_icon_state = "Kindle"
	aoe_radius = 5
	antimagic_flags = NONE
	spell_requirements = NONE
	school = SCHOOL_EVOCATION
	cooldown_time = 15 SECONDS
	sound = 'sound/magic/blind.ogg'
	var/safe = FALSE
	var/bonus_strength = 0

/datum/action/cooldown/spell/aoe/radiantburst/cast(atom/cast_on)
	. = ..()
	if(!safe && iscarbon(owner))
		var/mob/living/carbon/dummy = owner
		dummy.flash_act(3 + bonus_strength) //it's INSIDE you, it's gonna blind
	owner.visible_message(span_warning("[owner] releases a blinding light from within themselves."), span_notice("You release all the light within you."))
	owner.color = LIGHT_COLOR_HOLY_MAGIC
	animate(owner, 0.5 SECONDS, color = null)

/datum/action/cooldown/spell/aoe/radiantburst/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(!can_see(victim, caster))
		return
	if(ishuman(victim))
		var/mob/living/carbon/human/hurt = victim
		hurt.flash_act(1 + bonus_strength)//only strength of 1, so sunglasses protect from it unless strengthened
		if(isdarkspawn(hurt))
			hurt.adjustFireLoss(bonus_strength ? (-30) : (-20))
			to_chat(hurt, span_userdanger("The blinding light sears you!"))
			playsound(hurt, 'sound/weapons/sear.ogg', 75, TRUE)
