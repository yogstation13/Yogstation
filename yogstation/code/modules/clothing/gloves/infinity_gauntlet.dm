/* ************************
	Sorry for the weird ASCII art headers, my mind was breaking trying to navigate the file.
   ************************/ 

/* ************************
	DEFINES
   ************************/ 
#define INFINITY_GEM "infinity_gem"

#define isspacegem(A)         (istype(A,/obj/item/infinity_gem/space_gem))

#define istimegem(A)          (istype(A,/obj/item/infinity_gem/time_gem))

#define ismindgem(A)          (istype(A,/obj/item/infinity_gem/mind_gem))

#define issoulgem(A)          (istype(A,/obj/item/infinity_gem/soul_gem))

#define ispowergem(A)         (istype(A,/obj/item/infinity_gem/power_gem))

#define isrealitygem(A)       (istype(A,/obj/item/infinity_gem/reality_gem))

#define NO_GEMS 0
#define SPACE_GEM (1<<0)
#define TIME_GEM (1<<1)
#define MIND_GEM (1<<2)
#define SOUL_GEM (1<<3)
#define POWER_GEM (1<<4)
#define REALITY_GEM (1<<5)
#define ALL_GEMS (SPACE_GEM | TIME_GEM | MIND_GEM | SOUL_GEM | POWER_GEM | REALITY_GEM)

/* ************************
	GAUNTLET
   ************************/ 

/datum/component/storage/concrete/infinity_gauntlet //TODO: probably put into another file
	rustle_sound = FALSE
	max_items = 6
	can_hold = typecacheof(list(
		obj/item/infinity_gem
	))

/datum/component/storage/concrete/infinity_gauntlet/handle_item_insertion(obj/item/I, prevent_warning = FALSE, mob/living/user)
	var/obj/item/storage/infinity_gauntlet/gauntlet = real_location()
	gauntlet.update_gems(user)
	. = ..()

//don't need to do remove_from_storage because storage already calls dropped in there

/datum/emote/living/sneeze
	key = "snap"
	key_third_person = "snaps"
	message = "snaps their finger."
	emote_type = EMOTE_AUDIBLE

/obj/effect/proc_holder/spell/snap
	name = "Snap"
	desc = "Reality can be anything you want."
	clothes_req = FALSE

/obj/effect/proc_holder/spell/snap/perform(list/targets, recharge = TRUE, mob/user = usr)
	var/list/shuffled_living = shuffle(GLOB.alive_mob_list)
	shuffled_living.len = shuffled_living.len/2
	shuffled_living-=user
	for(var/mob/living/M in shuffled_living)
		M.visible_message("<span class='userdanger'>You don't feel so good...</span>")
		M.dust()

/obj/item/storage/infinity_gauntlet
	name = "Infinity Gauntlet"
	desc = "A gauntlet which can hold the infinity gems."
	siemens_coefficient = 0
	strip_delay = 100
	equip_delay_self = 20
	permeability_coefficient = 0
	body_parts_covered = HAND_LEFT
	slot_flags = ITEM_SLOT_GLOVES
	component_type = /datum/component/storage/concrete/infinity_gauntlet
	var/obj/effect/proc_holder/spell/snap/snap_spell

/obj/item/storage/infinity_gauntlet/update_icon() //copy/pasted from belts mostly
	cut_overlays()
	if(content_overlays)
		for(var/I in contents)
			var/obj/item/infinity_gem/gem = I //can't hold anything else, so this is fine
			var/mutable_appearance/M = gem.get_gauntlet_overlay()
			add_overlay(M)
	..()

/obj/item/storage/infinity_gauntlet/equipped(mob/user,slot)
	if(slot == SLOT_GLOVES)
		add_gems_to_owner(user)
	else
		remove_gems_from_owner(user)

/obj/item/storage/infinity_gauntlet/dropped(mob/user)
	. = ..()
	remove_gems_from_owner(user)

/obj/item/storage/infinity_gauntlet/proc/remove_gems_from_owner(mob/user)
	for(var/I in contents)
		var/obj/item/infinity_gem/gem = I
		gem.remove_gem(user)
	update_gem_flags()

/obj/item/storage/infinity_gauntlet/proc/add_gems_to_owner(mob/user)
	if(!sanity_check(user))
		return
	update_gem_flags()
	for(var/I in contents)
		var/obj/item/infinity_gem/gem = I
		gem.add_gem(user)

/obj/item/storage/infinity_gauntlet/proc/update_gem_flags()
	var/gems_found = NO_GEMS
	for(var/I in contents)
		var/obj/item/infinity_gem/gem = I
		gems_found |= gem.gem_flag
	for(var/I in contents)
		var/obj/item/infinity_gem/gem = I
		gem.other_gems = gems_found
	if(gems_found) == ALL_GEMS
		


/obj/item/storage/infinity_gauntlet/proc/sanity_check(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.gloves==src)
			return TRUE
	return FALSE

/obj/item/storage/infinity_gauntlet/proc/update_gems(mob/user)
	if(!sanity_check(user))
		return
	var/gems_found = NO_GEMS
	for(var/I in contents)
		var/obj/item/infinity_gem/gem = I
		gems_found |= gem.gem_flag
	for(var/I in contents)
		var/obj/item/infinity_gem/gem = I
		gem.other_gems = gems_found
		gem.remove_gem(user)
		gem.add_gem(user)

/* ************************
	BASE GEM CLASS
   ************************/ 

/obj/item/infinity_gem
	name = "Infinity Gem"
	desc = "You shouldn't see this!"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/turf/lastlocation //if the wizard can't track 'em, it's too hard!
	var/gem_flag = NO_GEMS
	var/other_gems
	var/spells
	var/traits

/obj/item/infinity_gem/equipped(mob/user,slot)
	. = ..()
	if(slot == SLOT_HANDS)
		gem_add(user)
	else
		gem_remove(user)

/obj/item/infinity_gem/proc/gem_add(mob/user)
	gem_remove(user)
	other_gem_actions(user)
	for(var/T in traits)
		user.add_trait(T,INFINITY_GEM)
	if(user.mind)
		for(var/S in spells)
			var/obj/effect/proc_holder/spell/spell = S
			user.mind.AddSpell(spell)
	else
		for(var/S in spells)
			var/obj/effect/proc_holder/spell/spell = S
			user.AddSpell(spell)
			

/obj/item/infinity_gem/proc/gem_remove(mob/user)
	for(var/T in traits)
		user.remove_trait(T,INFINITY_GEM)
	if(user.mind)
		for(var/S in spells)
			var/obj/effect/proc_holder/spell/spell = S
			user.mind.RemoveSpell(spell)
	else
		for(var/S in spells)
			var/obj/effect/proc_holder/spell/spell = S
			user.RemoveSpell(spell)


/obj/item/infinity_gem/dropped(mob/user)
	. = ..()
	gem_remove(user)

/obj/item/infinity_gem/proc/add_gem(mob/user)
	return //nothing here, defined in each gem

/obj/item/infinity_gem/proc/remove_gem(mob/user)
	return

/obj/item/infinity_gem/proc/other_gem_actions(mob/user)
	return

/obj/item/infinity_gem/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/stationloving, true) //obviously could make admins not informed but i don't see the point


/* ************************
	SPACE GEM
   ************************/ 

/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem
	name = "Space Gem Teleport"
	desc = "Use the gem to teleport you to an area of your selection."
	charge_max = 200
	sound1 = 'sound/magic/teleport_diss.ogg'
	sound2 = 'sound/magic/teleport_app.ogg'

/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/self
	name = "Space Gem Teleport (self)"
	range = -1
	include_user = TRUE

/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/other
	name = "Space Gem Teleport (other)"
	desc = "Use the space gem to teleport someone else to an area of your selection."
	range = 10
	include_user = FALSE

/obj/effect/proc_holder/spell/targeted/turf_teleport/space_gem
	name = "Space Gem: Chaos"
	desc = "Teleport everyone nearby, including yourself, to a nearby random location."
	range = 5
	include_user = TRUE
	charge_max = 20
	random_target = 1
	max_targets = 0

/obj/item/infinity_gem/space_gem
	name = "Space Gem"
	desc = "A gem that allows the holder to be anywhere."
	gem_flag = SPACE_GEM
	var/obj/effect/proc_holder/spell/targeted/turf_teleport/space_gem/mass_blink

/obj/item/infinity_gem/space_gem/Initialize()
	. = ..()
	var/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/self/teleport_self = new
	var/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/other/teleport_other = new
	mass_blink = new obj/effect/proc_holder/spell/targeted/turf_teleport/space_gem/mass_blink
	spells=list(teleport_self,teleport_other)

/obj/item/infinity_gem/space_gem/other_gem_actions(mob/user)
	if(other_gems & POWER_GEM)
		if(user.mind)
			user.mind.AddSpell(mass_blink)
		else
			user.AddSpell(mass_blink)
	else
		if(user.mind)
			user.mind.RemoveSpell(mass_blink)
		else
			user.RemoveSpell(mass_blink)
	if(other_gems & TIME_GEM)
		spells[1].charge_max = 100
		spells[2].charge_max = 100
	else
		spells[1].charge_max = 200
		spells[2].charge_max = 200

/obj/item/infinity_gem/space_gem/remove_gem(mob/user)
	. = ..()
	if(user.mind)
		user.mind.RemoveSpell(mass_blink)
	else
		user.mind.RemoveSpell(mass_blink)

/* ************************
	TIME GEM
   ************************/ 

/obj/effect/proc_holder/spell/targeted/time_reverse
	name = "Reverse Time"
	desc = "Brings you back to a time when you were healthy."
	range = -1
	include_user = TRUE
	charge_max=1200

/obj/effect/proc_holder/spell/target/time_reverse/cast()
	. = ..()
	if(isliving(target))
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			C.regenerate_limbs()
			C.regenerate_organs()
			//was gonna have it deage the user, but realized that that would nerf people whose characters are younger,
			//which would be very, very dumb since all that's pure fluff. so instead it's just healing
		if(target.revive(full_heal = 1))
			target.grab_ghost(force = TRUE) // even suicides
			to_chat(target, "<span class='notice'>You rise with a start, you're alive!!!</span>")
		else if(target.stat != DEAD)
			to_chat(target, "<span class='notice'>You feel great!</span>")

/obj/item/infinity_gem/time_gem
	name = "Time Gem"
	desc = "A gem that allows the holder to be anytime."
	gem_flag = TIME_GEM
	var/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/stop
	var/obj/effect/proc_holder/spell/targeted/time_reverse/reverse_time

/obj/item/infinity_gem/time_gem/Initialize()
	. = ..()
	var/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/stop = new
	stop.invocation_type="none" //hey why does this use strings instead of defines or an enum or something
	stop.clothes_req = FALSE
	stop.charge_max = 100
	var/obj/effect/proc_holder/spell/targeted/time_reverse/reverse_time = new
	spells=list(stop,reverse_time)

/obj/item/infinity_gem/time_gem/other_gem_actions(mob/user)
	if(other_gems & POWER_GEM)
		spells[2].charge_max=300 //yeah i actually think this is good enough
	else
		spells[2].charge_max=1200

/* ************************
	MIND GEM
   ************************/ 

/obj/item/infinity_gem/mind_gem
	name = "Mind Gem"
	desc = "A gem that gives the power to access the thoughts and dreams of other beings."
	gem_flag = MIND_GEM
	var/obj/effect/proc_holder/spell/targeted/mind_transfer/mindswap = new
	traits = list(TRAIT_THERMAL_VISION)

/obj/item/infinity_gem/mind_gem/Initialize()
	. = ..()
	var/obj/effect/proc_holder/spell/targeted/telepathy/telepathy = new
	telepathy.range=7
	var/obj/effect/proc_holder/spell/targeted/mindread/mindread = new
	mindread.range=7
	spells=list(telepathy,mindread)
	mindswap.unconscious_amount_victim = 200
	mindswap.unconscious_amount_caster = 200

/obj/item/infinity_gem/mind_gem/gem_add(mob/user)
	. = ..()
	user.update_sight()

/obj/item/infinity_gem/mind_gem/gem_remove(mob/user)
	. = ..()
	if(user.mind)
		user.mind.RemoveSpell(mindread)
	else
		user.RemoveSpell(mindread)
	user.update_sight()

/obj/item/infinity_gem/mind_gem/other_gem_actions(mob/user)
	. = ..()
	if(other_gems & POWER_GEM)
		spells[1].range=100
		spells[2].range=100
		spells[1].selection_type = "range"
		spells[2].selection_type = "range"
	if(other_gems & SOUL_GEM)
		if(other_gems & TIME_GEM)
			mindswap.unconscious_amount_victim=0
			mindswap.unconscious_amount_caster=200
		if(user.mind)
			user.mind.AddSpell(mindread)
		else
			user.AddSpell(mindread)
	else
		if(user.mind)
			user.mind.RemoveSpell(mindread)
		else
			user.RemoveSpell(mindread)

/* ************************
	SOUL GEM
   ************************/ 

/obj/effect/proc_holder/spell/targeted/ghostify
	name = "Ghostize"
	desc = "Turns you into a ghost. Spooky!"
	range = -1
	include_user = TRUE
	charge_max=10

/obj/effect/proc_holder/spell/target/ghostify/cast()
	. = ..()
	visible_message("<span class='danger'>[user] stares into the soul gem, their eyes glazing over.</span>")
	user.ghostize(1)

/obj/effect/proc_holder/spell/targeted/conjure_item/soulstone
	name = "Create Soulstone"
	desc = "Forges a soulstone using the soul gem."
	item_type = /obj/item/soulstone
	charge_max = 1200
	delete_old = FALSE

/obj/item/infinity_gem/soul_gem
	name = "Soul Gem"
	desc = "A gem that gives power over souls."
	gem_flag = SOUL_GEM
	traits = list(TRAIT_SIXTHSENSE)
	spells = list(/obj/effect/proc_holder/spell/targeted/ghostify)
	var/obj/effect/proc_holder/spell/targeted/conjure_item/soulstone/soulstone_spell

/obj/item/infinity_gem/soul_gem/other_gem_actions(mob/user)
	if(other_gems & REALITY_GEM)
		if(user.mind)
			user.mind.AddSpell(soulstone_spell)
		else
			user.AddSpell(soulstone_spell)
	else
		if(user.mind)
			user.mind.RemoveSpell(soulstone_spell)
		else
			user.RemoveSpell(soulstone_spell)


/* ************************
	POWER GEM
   ************************/ 

/obj/item/infinity_gem/power_gem
	name = "Power Gem"
	desc = "A gem granting dominion over power itself."
	gem_flag = POWER_GEM
	var/obj/effect/proc_holder/spell/aoe_turf/repulse/gem_repulse

/obj/item/infinity_gem/power_gem/Initialize()
	gem_repulse.anti_magic_check = FALSE
	spells = list(gem_repulse)

/obj/item/infinity_gem/power_gem/other_gem_actions(mob/user)
	if(other_gems & SPACE_GEM)
		spells[1].range=8
		spells[1].maxthrow=8
	if(other_gems & REALITY_GEM)
		spells[1].repulse_force = MOVE_FORCE_OVERPOWERING

/* ************************
	REALITY GEM
   ************************/ 

/obj/item/infinity_gem/reality_gem
	name = "Reality Gem"
	desc = "A gem granting dominion over reality."
	gem_flag = REALITY_GEM
	traits = list(TRAIT_NOSLIPALL)

/obj/item/infinity_gem/reality_gem/other_gem_actions(mob/user)
	traits=list(TRAIT_NOSLIPALL)
	if(other_gems & POWER_GEM)
		traits |= TRAIT_NOSOFTCRIT
		if(other_gems & SOUL_GEM)
			traits |= TRAIT_NODEATH
	if(other_gems & SPACE_GEM)
		traits |= TRAIT_NODISMEMBER
	if(other_gems & TIME_GEM)
		traits |= TRAIT_NOCRITDAMAGE
	if(other_gems & MIND_GEM)
		/var/obj/effect/proc_holder/spell/voice_of_god/voice_spell
		if(other_gems & POWER_GEM)
			voice_spell.power_mod=2
		if(other_gems & TIME_GEM)
			voice_spell.cooldown_mod=0.5
