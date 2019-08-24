/obj/item/clothing/gloves/gauntlet
	name = "Infinity Gauntlet"
	desc = "An old prop from an unsuccesful movie franchise."
	w_class = WEIGHT_CLASS_BULKY
	icon = 'yogstation/icons/obj/gauntlet.dmi'
	icon_state = "gauntlet"
	siemens_coefficient = 0.5
	body_parts_covered = HANDS
	slot_flags = ITEM_SLOT_GLOVES
	strip_delay = 40
	actions_types = list(/datum/action/item_action/snap)
	var/actions_times[] = list()
	var/applied_gems[] = list()
	var/spells_list[] = list()
	var/spells_list_cache[] = list()

/obj/item/clothing/gloves/gauntlet/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/snap))
		snap(user)

/obj/item/clothing/gloves/gauntlet/equipped(mob/user, slot)
	..()
	for(var/Y in actions)
		var/datum/action/A = Y
		A.Grant(user)
	for(var/S in spells_list)
		user.AddSpell(S)

/obj/item/clothing/gloves/gauntlet/dropped(mob/user)
	..()
	for(var/Y in actions)
		var/datum/action/A = Y
		A.Remove(user)
	for(var/S in spells_list)
		user.RemoveSpell(S)
		spells_list -= S
	rebuild_spells()

/obj/item/clothing/gloves/gauntlet/Destroy()
	message_admins("Someone destroyed the gauntlet.")
	..()

/obj/item/clothing/gloves/gauntlet/proc/rebuild_spells() //Bit shitty, but wanted to get this done
	for(var/G in applied_gems)
		if(G == 1)
			power_stone_activate()
		if(G == 2)
			space_stone_activate()
		if(G == 3)
			reality_stone_activate()
		if(G == 4)
			soul_stone_activate()
		if(G == 5)
			time_stone_activate()
		if(G == 6)
			mind_stone_activate()

/datum/action/item_action/snap
	name = "Snap"
	icon_icon = 'yogstation/icons/obj/gauntlet.dmi'
	button_icon_state = "gauntlet_icon"

/datum/action/item_action/time_stop
	name = "Time"
	icon_icon = 'yogstation/icons/obj/gauntlet.dmi'
	button_icon_state = "gem_5"

/obj/item/infinity_stone/
	name = "Bad Stone"
	desc = "Oops?"
	icon = 'yogstation/icons/obj/gauntlet.dmi'
	icon_state = "gem_1"
	w_class = WEIGHT_CLASS_NORMAL
	var/gem_type = 1
	throw_speed = 3
	throw_range = 7

/obj/item/infinity_stone/Destroy()
	message_admins("Someone destroyed [src]. It may have been inserted into the gauntlet.")
	..()

/obj/item/infinity_stone/power
	name = "Power Stone"
	desc = "A powerful gem, oozing with power!"
	gem_type = 1
	icon_state = "gem_1"

/obj/item/infinity_stone/space
	name = "Space Stone"
	desc = "A powerful gem, oozing with spacey-ness!"
	gem_type = 2
	icon_state = "gem_2"

/obj/item/infinity_stone/reality
	name = "Reality Stone"
	desc = "A powerful gem, oozing with illusions!"
	gem_type = 3
	icon_state = "gem_3"

/obj/item/infinity_stone/soul
	name = "Soul Stone"
	desc = "A powerful gem, oozing with heart!"
	gem_type = 4
	icon_state = "gem_4"

/obj/item/infinity_stone/time
	name = "Time Stone"
	desc = "A powerful gem, oozing with timeeeeeee!"
	gem_type = 5
	icon_state = "gem_5"

/obj/item/infinity_stone/mind
	name = "Mind Stone"
	desc = "A powerful gem, oozing with increased mental capacity!"
	gem_type = 6
	icon_state = "gem_6"

/obj/item/clothing/gloves/gauntlet/attackby(obj/item/I, mob/user, params)
	var/obj/item/infinity_stone/S = I
	if(istype(I, /obj/item/infinity_stone))
		add_stone(S.gem_type, user)
		qdel(I)
		user.dropItemToGround(src)
		to_chat(user, "<span class='warning'>The gauntlet becomes too hot to touch.</span>")

////obj/item/t_scanner/attack_self(mob/user)

/obj/item/clothing/gloves/gauntlet/proc/snap(user)
	if(applied_gems.len == 6)
		to_chat(user, "<span class='warning'>You destroy humanity</span>")
		for(var/mob/living/carbon/M in GLOB.mob_list)
			if(M.stat != DEAD)
				if(!(user == M))
					M.gib()
	else
		to_chat(user, "<span class='warning'>You need all the infinity gems to destroy humanity.</span>")

/obj/item/clothing/gloves/gauntlet/proc/power_stone_activate()
	var/obj/effect/proc_holder/spell/targeted/tesla/gauntlet/J = new /obj/effect/proc_holder/spell/targeted/tesla/gauntlet()
	spells_list += J

/obj/item/clothing/gloves/gauntlet/proc/space_stone_activate() // Now your body is space protected!!
	var/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/gauntlet/J = new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/gauntlet()
	spells_list += J

/obj/item/clothing/gloves/gauntlet/proc/reality_stone_activate() // You have a fist of steel!
	var/obj/effect/proc_holder/spell/spacetime_dist/gauntlet/J = new /obj/effect/proc_holder/spell/spacetime_dist/gauntlet()
	spells_list += J

/obj/item/clothing/gloves/gauntlet/proc/soul_stone_activate()
	var/obj/effect/proc_holder/spell/aimed/resurrect/J = new /obj/effect/proc_holder/spell/aimed/resurrect()
	spells_list += J

/obj/item/clothing/gloves/gauntlet/proc/time_stone_activate()
	var/obj/effect/proc_holder/spell/aimed/time/J = new /obj/effect/proc_holder/spell/aimed/time()
	spells_list += J

/obj/item/clothing/gloves/gauntlet/proc/mind_stone_activate()
	var/obj/effect/proc_holder/spell/aimed/animate/J = new /obj/effect/proc_holder/spell/aimed/animate()
	spells_list += J

/obj/item/clothing/gloves/gauntlet/proc/add_stone(New_stone, user)
	for(var/D in applied_gems)
		if(New_stone == D || New_stone > 6 || New_stone < 1)
			to_chat(user, "You've broken something.")
			return
	var/image/O = image(icon = 'yogstation/icons/obj/gauntlet.dmi', icon_state = "stone_[New_stone]")
	add_overlay(O)
	applied_gems += New_stone
	to_chat(user, "You add the stone to the [src].")
	if(New_stone == 1)
		power_stone_activate()
	if(New_stone == 2)
		space_stone_activate()
	if(New_stone == 3)
		reality_stone_activate()
	if(New_stone == 4)
		soul_stone_activate()
	if(New_stone == 5)
		time_stone_activate()
	if(New_stone == 6)
		mind_stone_activate()


/obj/item/clothing/gloves/gauntlet/proc/remove_stone(Old_stone) //Not used right now and not fully implemented
	cut_overlays()
	for(var/N in applied_gems)
		var/image/O = image(icon = 'yogstation/icons/obj/gauntlet.dmi', icon_state = "stone_[N]")
		add_overlay(O)

//Spells

/obj/effect/proc_holder/spell/targeted/tesla/gauntlet
	name = "Power Blast"
	desc = "Charge up a tesla arc and release it at a random nearby target! You can move freely while it charges. The arc jumps between targets and can knock them down."
	action_icon = 'yogstation/icons/obj/gauntlet.dmi'
	action_icon_state = "gem_1"
	charge_max	= 50
	clothes_req = FALSE
	invocation = "DIE!"
	invocation_type = "shout"
	cooldown_min = 30

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/gauntlet
	jaunt_duration = 80
	action_icon = 'yogstation/icons/obj/gauntlet.dmi'
	action_icon_state = "gem_2"
	invocation = "I'm inevitable."
	charge_max = 50
	clothes_req = FALSE

/obj/effect/proc_holder/spell/spacetime_dist/gauntlet
	name = "Spacetime Distortion"
	desc = "Entangle the strings of space-time in an area around you, randomizing the layout and making proper movement impossible. The strings vibrate..."
	action_icon = 'yogstation/icons/obj/gauntlet.dmi'
	action_icon_state = "gem_3"
	charge_max = 50
	duration = 200
	range = 7
	sound = 'sound/effects/magic.ogg'
	cooldown_min = 50
	level_max = 0
	clothes_req = FALSE

/obj/effect/proc_holder/spell/aimed/resurrect
	name = "Resurrect"
	desc = "This spell fires a healing bolt at a target. Heals whoever it hits."
	charge_max = 60
	clothes_req = FALSE
	invocation = "Come back to life!"
	invocation_type = "shout"
	cooldown_min = 20 //10 deciseconds reduction per rank
	projectile_type = /obj/item/projectile/magic/resurrection
	icon = 'yogstation/icons/obj/gauntlet.dmi'
	action_icon = 'yogstation/icons/obj/gauntlet.dmi'
	base_icon_state = "gem_4"
	action_icon_state = "gem_4"
	active_icon_state = "gem_4"
	active_msg = "You prepare to throw your healing bolt!"
	deactive_msg = "You absorb your healing bolt... for now."
	active = FALSE

/obj/effect/proc_holder/spell/aimed/resurrect/update_icon()

/obj/effect/proc_holder/spell/aimed/time
	name = "Time"
	desc = "This spell fires a time bolt at a target. Pause time for whoever it hits."
	charge_max = 60
	clothes_req = FALSE
	invocation = "Stop right there!"
	invocation_type = "shout"
	cooldown_min = 20 //10 deciseconds reduction per rank
	projectile_type = /obj/item/projectile/magic/time
	icon = 'yogstation/icons/obj/gauntlet.dmi'
	action_icon = 'yogstation/icons/obj/gauntlet.dmi'
	base_icon_state = "gem_5"
	action_icon_state = "gem_5"
	active_icon_state = "gem_5"
	active_msg = "You prepare to throw your time bolt!"
	deactive_msg = "You absorb your time bolt... for now."
	active = FALSE

/obj/effect/proc_holder/spell/aimed/time/update_icon()

/obj/item/projectile/magic/time
	name = "bolt of time"
	icon_state = "pulse1_bl"

/obj/item/projectile/magic/time/on_hit(target)
	. = ..()
	new /obj/effect/timestop/wizard(loc, 1)

/obj/effect/proc_holder/spell/aimed/animate
	name = "Animate"
	desc = "This spell fires a sentience bolt at a target. Animates the objects it hits."
	charge_max = 60
	clothes_req = FALSE
	invocation = "Come to life!"
	invocation_type = "shout"
	cooldown_min = 20 //10 deciseconds reduction per rank
	projectile_type = /obj/item/projectile/magic/animate
	icon = 'yogstation/icons/obj/gauntlet.dmi'
	action_icon = 'yogstation/icons/obj/gauntlet.dmi'
	base_icon_state = "gem_6"
	action_icon_state = "gem_6"
	active_icon_state = "gem_6"
	active_msg = "You prepare to throw your healing bolt!"
	deactive_msg = "You absorb your healing bolt... for now."
	active = FALSE

/obj/effect/proc_holder/spell/aimed/animate/update_icon()

//Artifacts
//Power stone artifact

/obj/item/gun/energy/beam_rifle/power_artifact
	name = "Power Stone Focuser"
	desc = "A focused pulse rifle, based around the power stone."
	icon = 'yogstation/icons/obj/gauntlet.dmi'
	icon_state = "artifact_1"
	item_state = "artifact_1"
	delay = 3
	ammo_type = list(/obj/item/ammo_casing/energy/beam_rifle/hitscan/artifact)
	cell_type = /obj/item/stock_parts/cell/infinite
	aiming_time = 3
	recoil = 0
	pin = /obj/item/firing_pin

/obj/item/gun/energy/beam_rifle/power_artifact/update_icon()
	//Removes the overlays

/obj/item/gun/energy/beam_rifle/power_artifact/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/gloves/gauntlet))
		to_chat(user, "You destroy the artifact with the gauntlet, leaving just an infinity stone.")
		qdel(src)

/obj/item/gun/energy/beam_rifle/power_artifact/Destroy()
	new /obj/item/infinity_stone/power(loc, 1)
	..()

/obj/item/ammo_casing/energy/beam_rifle/hitscan/artifact
	projectile_type = /obj/item/projectile/beam/beam_rifle/hitscan/artifact

/obj/item/projectile/beam/beam_rifle/hitscan/artifact
	tracer_type = /obj/effect/projectile/tracer/tracer/beam_rifle/artifact

/obj/effect/projectile/tracer/tracer/beam_rifle/artifact
	name = "laser"
	icon_state = "hcult"

//Space stone artifact

/obj/item/teleportation_scroll/space_artifact
	name = "The Tesseract"
	desc = "A cube of immense power. It's teleportation powers are unimaginable."
	icon = 'icons/obj/wizard.dmi'
	icon = 'yogstation/icons/obj/gauntlet.dmi'
	icon_state = "artifact_2"
	uses = 100000 //A number so large it'll never be reached

/obj/item/teleportation_scroll/space_artifact/attack_self(mob/user)
	user.set_machine(src)
	var/dat = "<B>The Tesseract:</B><BR>"
	dat += "<A href='byond://?src=[REF(src)];spell_teleport=1'>Teleport</A><BR>"
	user << browse(dat, "window=scroll")
	onclose(user, "scroll")
	return

/obj/item/teleportation_scroll/space_artifact/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/gloves/gauntlet))
		to_chat(user, "You destroy the artifact with the gauntlet, leaving just an infinity stone.")
		qdel(src)

/obj/item/teleportation_scroll/space_artifact/Destroy()
	new /obj/item/infinity_stone/space(loc, 1)
	..()
//Reality stone artifact

/obj/item/gun/magic/staff/reality_artifact
	name = "staff of reality"
	desc = "An artifact that warps reality. Use this to slowly tear away reality from a foe"
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/reality
	icon = 'yogstation/icons/obj/gauntlet.dmi'
	icon_state = "artifact_3"
	item_state = "artifact_3"
	max_charges = 1000000

/obj/item/gun/magic/staff/reality_artifact/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/gloves/gauntlet))
		to_chat(user, "You destroy the artifact with the gauntlet, leaving just an infinity stone.")
		qdel(src)

/obj/item/gun/magic/staff/reality_artifact/Destroy()
	new /obj/item/infinity_stone/reality(loc, 1)
	..()

/obj/item/ammo_casing/magic/reality
	projectile_type = /obj/item/projectile/magic/reality

/obj/item/projectile/magic/reality
	name = "bolt of reality"
	icon_state = "red_1"
	damage = 0
	damage_type = BURN
	nodamage = TRUE

	////obj/item/t_scanner/attack_self(mob/user)

/obj/item/projectile/magic/reality/on_hit(atom/change)
	. = ..()
	if(ishuman(change))
		var/mob/living/carbon/human/M = change
		if(M.anti_magic_check())
			M.visible_message("<span class='warning'>[src] fizzles on contact with [M]!</span>")
			qdel(src)
			return BULLET_ACT_BLOCK
		M.hallucination += 30
		M.AdjustParalyzed(30)
		M.adjustCloneLoss(8)
		if(M.health<0)
			wabbajack(change)
	qdel(src)

//Soul stone artifact

/obj/item/restraints/handcuffs/soul_artifact
	name = "Soulcuffs"
	icon = 'yogstation/icons/obj/gauntlet.dmi'
	icon_state = "artifact_4"
	desc = "Use this to bind a soul to the soul stone. With time you can extract their essence."
	var/cuffed_mobs = list()

/obj/item/restraints/handcuffs/soul_artifact/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/restraints/handcuffs/soul_artifact/process()
	for(var/mob/living/carbon/M in cuffed_mobs)
		var/obj/O = M.get_item_by_slot(SLOT_HANDCUFFED)
		if(!istype(O, /obj/item/restraints/handcuffs/soul_artifact))
			cuffed_mobs -= M
		else
			if(prob(10))
				new /obj/item/soul_essence(M.loc, 1)
				M.adjustCloneLoss(4)


/obj/item/restraints/handcuffs/soul_artifact/attack(mob/living/carbon/C, mob/living/user)
	if(!istype(C))
		return

	if(iscarbon(user) && (HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50)))
		to_chat(user, "<span class='warning'>Uh... These magic things look funny?!</span>")
		apply_cuffs(user,user)
		return

	if(!C.handcuffed)
		if(C.get_num_arms(FALSE) >= 2 || C.get_arm_ignore())
			C.visible_message("<span class='danger'>[user] is trying to put [src.name] on [C]!</span>", \
								"<span class='userdanger'>[user] is trying to put [src.name] on [C]!</span>")
			if(do_mob(user, C, 30) && (C.get_num_arms(FALSE) >= 2 || C.get_arm_ignore()))
				if(iscyborg(user))
					apply_cuffs(C, user, TRUE)
				else
					apply_cuffs(C, user)
				to_chat(user, "<span class='notice'>You handcuff [C].</span>")
				cuffed_mobs += C
				SSblackbox.record_feedback("tally", "handcuffs", 1, type)

				log_combat(user, C, "handcuffed with the Soul artifact")
			else
				to_chat(user, "<span class='warning'>You fail to handcuff [C]!</span>")
		else
			to_chat(user, "<span class='warning'>[C] doesn't have two hands...</span>")

/obj/item/restraints/handcuffs/soul_artifact/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/gloves/gauntlet))
		to_chat(user, "You destroy the artifact with the gauntlet, leaving just an infinity stone.")
		qdel(src)

/obj/item/restraints/handcuffs/soul_artifact/Destroy()
	new /obj/item/infinity_stone/soul(loc, 1)
	..()



/obj/item/soul_essence
	name = "regenerative essence"
	desc = "An essence of a soul."
	icon = 'yogstation/icons/obj/gauntlet.dmi'
	icon_state = "soul_essence"
	var/empty = 0


/obj/item/soul_essence/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/go_inert_soul),300)

/obj/item/soul_essence/proc/go_inert_soul()
	name = "regenerative essence"
	desc = "An empty essence."
	icon = 'yogstation/icons/obj/gauntlet.dmi'
	icon_state = "soul_essence_empty"
	empty = 1

/obj/item/soul_essence/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag && ishuman(target))
		var/mob/living/carbon/human/H = target
		if(empty)
			to_chat(user, "<span class='notice'>[src] is empty and can no longer be used to heal.</span>")
			return
		else
			if(H.stat == DEAD)
				to_chat(user, "<span class='notice'>[src] are useless on the dead.</span>")
				return
			if(H != user)
				H.visible_message("[user] forces [H] to apply [src]... A white glow heals [H.p_them()]!")
			else
				to_chat(user, "<span class='notice'>You push the [src] into yourself. A glow consumes you.</span>")
			H.apply_status_effect(STATUS_EFFECT_REGENERATIVE_CORE)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "core", /datum/mood_event/healsbadman) //Now THIS is a miner buff (fixed - nerf)
			qdel(src)

//Time stone artifact

/obj/item/clothing/neck/time_artifact
	name = "Time Tether"
	desc = "Use this to pause time and manipulate your own personal time."
	icon = 'yogstation/icons/obj/gauntlet.dmi'
	icon_state = "artifact_5"
	item_state = "artifact_5"
	var/toggle = 0

/obj/item/clothing/neck/time_artifact/equipped(mob/user, slot)
	..()
	var/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/J = new /obj/effect/proc_holder/spell/aoe_turf/conjure/timestop()
	timestop_definitions(J)
	if(!toggle)
		user.AddSpell(J)
		user.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-2, blacklisted_movetypes=(FLYING|FLOATING))
	toggle = 1

/obj/item/clothing/neck/time_artifact/dropped(mob/user)
	..()
	user.remove_movespeed_modifier(type)
	user.RemoveSpell(/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop)
	toggle = 0

/obj/item/clothing/neck/time_artifact/afterattack(atom/target, mob/user, proximity)
	if(istype(target, /obj/machinery/hydroponics))
		to_chat(user, "<span class='warning'>The plants begin to grow rapidly! Soon they will be ready to harvest.</span>")
		plant_growth(target)

/obj/item/clothing/neck/time_artifact/proc/plant_growth(obj/machinery/hydroponics/H)
	H.age += 10

/proc/timestop_definitions(obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/S) //Timestop needs to have the same path to ensure its host can timestop immune.
	S.clothes_req = FALSE

/obj/item/clothing/neck/time_artifact/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/gloves/gauntlet))
		to_chat(user, "You destroy the artifact with the gauntlet, leaving just an infinity stone.")
		qdel(src)

/obj/item/clothing/neck/time_artifact/Destroy()
	new /obj/item/infinity_stone/time(loc, 1)
	..()

//Mind stone artifact

/obj/item/mind/mind_artifact
	name = "Staff of Intelligence"
	desc = "An artifact that enables increased brain function. Use this to give creatures sentience."
	icon = 'yogstation/icons/obj/gauntlet.dmi'
	icon_state = "artifact_6"
	item_state = "artifact_6"

/obj/item/mind/mind_artifact/afterattack(atom/target, mob/user, proximity)
	if(ismob(target))
		var/mob/M = target
		if(!isanimal(M) || M.ckey) //only works on animals that aren't player controlled
			to_chat(user, "<span class='warning'>[M] is already too intelligent for this to work!</span>")
			return
		if(M.stat)
			to_chat(user, "<span class='warning'>[M] is dead!</span>")
			return
		var/mob/living/simple_animal/SM = M
		to_chat(user, "<span class='notice'>You offer [src] to [SM]...</span>")

		var/list/candidates = pollCandidatesForMob("Do you want to play as [SM.name]?", ROLE_SENTIENCE, null, ROLE_SENTIENCE, 50, SM, POLL_IGNORE_SENTIENCE_POTION) // see poll_ignore.dm
		if(LAZYLEN(candidates))
			var/mob/dead/observer/C = pick(candidates)
			SM.key = C.key
			SM.mind.enslave_mind_to_creator(user)
			SM.sentience_act()
			to_chat(SM, "<span class='warning'>All at once it makes sense: you know what you are and who you are! Self awareness is yours!</span>")
			to_chat(SM, "<span class='userdanger'>You are grateful to be self aware and owe [user.real_name] a great debt. Serve [user.real_name], and assist [user.p_them()] in completing [user.p_their()] goals at any cost.</span>")
			if(SM.flags_1 & HOLOGRAM_1) //Check to see if it's a holodeck creature
				to_chat(SM, "<span class='userdanger'>You also become depressingly aware that you are not a real creature, but instead a holoform. Your existence is limited to the parameters of the holodeck.</span>")
			to_chat(user, "<span class='notice'>[SM] accepts [src] and suddenly becomes attentive and aware. It worked!</span>")
			SM.copy_known_languages_from(user, FALSE)
		else
			to_chat(user, "<span class='notice'>[SM] looks interested for a moment, but then looks back down. Maybe you should try again later.</span>")
			..()

/obj/item/mind/mind_artifact/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clothing/gloves/gauntlet))
		to_chat(user, "You destroy the artifact with the gauntlet, leaving just an infinity stone.")
		qdel(src)

/obj/item/mind/mind_artifact/Destroy()
	new /obj/item/infinity_stone/mind(loc, 1)
	..()

//Debug tool for admins

/obj/item/storage/toolbox/gauntlet
	name = "gauntlet toolbox"
	icon_state = "red"
	item_state = "toolbox_red"

/obj/item/storage/toolbox/gauntlet/PopulateContents()
	new /obj/item/clothing/gloves/gauntlet(src)
	new /obj/item/gun/energy/beam_rifle/power_artifact(src)
	new /obj/item/teleportation_scroll/space_artifact(src)
	new /obj/item/gun/magic/staff/reality_artifact(src)
	new /obj/item/restraints/handcuffs/soul_artifact(src)
	new /obj/item/clothing/neck/time_artifact(src)
	new /obj/item/mind/mind_artifact(src)
