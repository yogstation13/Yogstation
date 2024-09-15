//magical chem sprayer
/obj/item/reagent_containers/spray/chemsprayer/magical
	name = "Magical Chem Sprayer"
	desc = "Simply hit the button on the side and this will instantly be filled with a new reagent! Warning: User not immune to effects."
	icon_state = "chemsprayer_janitor"
	inhand_icon_state = "chemsprayer_janitor"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	reagent_flags = NONE
	volume = 1200
	possible_transfer_amounts = list() //we dont want this to change transfer amounts

/obj/item/reagent_containers/spray/chemsprayer/magical/attack_self(mob/user)
	cycle_chems() //does this even need to be a proc
	. = ..()
	balloon_alert(user, "You change the reagent to [english_list(reagents.reagent_list)].")
	return

/obj/item/reagent_containers/spray/chemsprayer/magical/examine()
	. = ..()
	. += "It currently holds [english_list(reagents.reagent_list)]."
	return

/obj/item/reagent_containers/spray/chemsprayer/magical/proc/cycle_chems()
	reagents.clear_reagents()
	list_reagents = list(get_random_reagent_id_unrestricted() = volume)
	reagents.add_reagent_list(list_reagents)
	return

//wizard bio suit
/obj/item/clothing/head/wizard/bio_suit
	name = "gem encrusted bio hood"
	desc = "A hood that protects the head and face from biological contaminants. It's covered in small gemstones."
	icon = 'monkestation/icons/obj/clothing/head/bio.dmi'
	icon_state = "bio_wizard"
	worn_icon = 'monkestation/icons/mob/clothing/head/bio.dmi'
	worn_icon_state = "bio_wizard"
	inhand_icon_state = "bio_hood"
	clothing_flags = THICKMATERIAL | BLOCK_GAS_SMOKE_EFFECT | SNUG_FIT | PLASMAMAN_HELMET_EXEMPT | HEADINTERNALS | CASTING_CLOTHES
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR|HIDEFACE|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF

/obj/item/clothing/suit/wizrobe/bio_suit
	name = "gem encrusted bio suit"
	desc = "A suit that protects against biological contamination. It's covered in small gemstones."
	icon = 'monkestation/icons/obj/clothing/suits/bio.dmi'
	icon_state = "bio_wizard"
	worn_icon = 'monkestation/icons/mob/clothing/suits/bio.dmi'
	worn_icon_state = "bio_wizard"
	inhand_icon_state = "bio_suit"
	clothing_flags = THICKMATERIAL | CASTING_CLOTHES
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDEJUMPSUIT
	strip_delay = 7 SECONDS
	equip_delay_other = 7 SECONDS

//reactive talisman
#define REACTION_COOLDOWN_DURATION 10 SECONDS
/obj/item/clothing/neck/neckless/wizard_reactive //reactive armor for wizards that casts a spell when it reacts
	name = "reactive talisman"
	desc = "A reactive talisman for the reactive mage."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "memento_mori"
	worn_icon_state = "memento"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF | UNACIDABLE
	hit_reaction_chance = 50
	//weakref to whomever the talisman is bound to
	var/datum/weakref/binding_owner
	//list of spells that can be cast by the talisman
	var/static/list/spell_list = list(/datum/action/cooldown/spell/rod_form, /datum/action/cooldown/spell/aoe/magic_missile,
									  /datum/action/cooldown/spell/emp/disable_tech, /datum/action/cooldown/spell/aoe/repulse/wizard,
								      /datum/action/cooldown/spell/timestop, /datum/action/cooldown/spell/forcewall, /datum/action/cooldown/spell/conjure/the_traps,
								      /datum/action/cooldown/spell/conjure/bee, /datum/action/cooldown/spell/conjure/simian,
								      /datum/action/cooldown/spell/teleport/radius_turf/blink)

	COOLDOWN_DECLARE(armor_cooldown) //unsure if I should use a world.time instead of this

/obj/item/clothing/neck/neckless/wizard_reactive/examine(mob/user)
	. = ..()
	if(binding_owner)
		var/mob/owner = binding_owner?.resolve()
		. += "It is currently bound to [owner.name]."
	else
		. += "It is currently unbound."

/obj/item/clothing/neck/neckless/wizard_reactive/attack_self(mob/user)
	. = ..()
	if(binding_owner)
		if(binding_owner?.resolve() == user)
			to_chat(user, "You start to unbind the talisman from yourself.")
			if(!do_after(user, 10 SECONDS))
				to_chat(user, "You fail to unbind the talisman from yourself.")
				return
			to_chat(user, "You unbind the talisman from yourself!")
			binding_owner = null
			return
		to_chat(user, "This talisman is already bound to someone else!.")
		return

	to_chat(user, "You start to bind the talisman to yourself.")
	if(!do_after(user, 10 SECONDS))
		to_chat(user, "You fail to bind the talisman to yourself.")
		return
	to_chat(user, "You bind the talisman to yourself!")
	binding_owner = WEAKREF(user)

/obj/item/clothing/neck/neckless/wizard_reactive/hit_reaction(mob/owner)
	if(!(prob(hit_reaction_chance)) || !(binding_owner))
		return FALSE
	if(!COOLDOWN_FINISHED(src, armor_cooldown))
		owner.visible_message("The [src] glows faintly for a second and then fades.")
		return FALSE
	return talisman_activation()

//do the casting of the spell
/obj/item/clothing/neck/neckless/wizard_reactive/proc/talisman_activation()
	var/mob/living/binding_ref = binding_owner?.resolve()
	var/datum/action/cooldown/spell/new_spell = pick(spell_list)

	COOLDOWN_START(src, armor_cooldown, REACTION_COOLDOWN_DURATION)
	new_spell = new new_spell(binding_ref.mind || binding_ref)
	new_spell.owner_has_control = FALSE
	new_spell.spell_requirements = ~SPELL_REQUIRES_WIZARD_GARB
	new_spell.Grant(binding_ref)

	if(!new_spell.cast(binding_ref))
		binding_ref.visible_message("The [src] glows brightly and then fades, looks like something went wrong!")
		qdel(new_spell)
		return

	binding_ref.visible_message("The [src] glows brightly and casts [new_spell.name]!")
	qdel(new_spell)

#undef REACTION_COOLDOWN_DURATION

//spellbook charges
//technically not used now, still useful for badminning though
/obj/item/spellbook_charge
	name = "power charge"
	desc = "An artifact that when inserted into a spellbook increases its power."
	icon = 'icons/effects/anomalies.dmi'
	icon_state = "flux"
	var/value = 1

/obj/item/spellbook_charge/ten
	name = "greater power charge"
	desc = "An artifact that when inserted into a spellbook increases its power by a massive amount."
	value = 10

/obj/item/spellbook_charge/debug
	name = "debug power charge"
	desc = "An artifact that when inserted into a spellbook increases its power by 100."
	value = 100

/obj/item/spellbook_charge/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/charge_adjuster, type_to_charge_to = /obj/item/spellbook, charges_given = value, called_proc_name = TYPE_PROC_REF(/obj/item/spellbook, adjust_charge))

//wizard shield charges
#define ADDED_MAX_CHARGE 50
#define MAX_CHARGES_ABSORBED 3
/obj/item/wizard_armour_charge/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/charge_adjuster, type_to_charge_to = /obj/item/spellbook, charges_given = 1, called_proc_name = TYPE_PROC_REF(/obj/item/spellbook, adjust_charge))

/obj/item/wizard_armour_charge/pre_attack(atom/A, mob/living/user, params)
	. = ..()
	if(.)
		return

	var/obj/item/mod/module/energy_shield/wizard/shield = istype(A, /obj/item/mod/module/energy_shield/wizard) || locate(/obj/item/mod/module/energy_shield/wizard) in A.contents
	if(shield)
		if(isnum(shield))
			shield = A
		if(shield.max_charges >= (initial(shield.max_charges) + (ADDED_MAX_CHARGE * MAX_CHARGES_ABSORBED)))
			balloon_alert(user, "\The [shield] cannot take more charges, you can put this back into your spellbook to refund it.")
			return TRUE

		shield.max_charges += ADDED_MAX_CHARGE
		var/datum/component/shielded/shield_comp = shield.mod?.GetComponent(/datum/component/shielded)
		if(shield_comp)
			shield_comp.max_charges += ADDED_MAX_CHARGE
			shield_comp.current_charges += (ADDED_MAX_CHARGE - initial(shield_comp.charge_recovery))
		qdel(src) //should still be able to finish the attack chain

#undef ADDED_MAX_CHARGE
#undef MAX_CHARGES_ABSORBED

/obj/item/mod/module/energy_shield/wizard
	lose_multiple_charges = TRUE //I dont think we have anything else that uses this var, so all the numbers for this are subject to change
