GLOBAL_LIST_INIT(guardian_precision_speedup, list(
	1 = -0.5,
	2 = -0.75,
	3 = -1,
	4 = -1.25,
	5 = -1.5
)) //doing this for consistency's sake
/mob/living/simple_animal/hostile/guardian/emperor //tiny
	melee_damage_lower = 2
	melee_damage_upper = 4
	
/mob/living/simple_animal/hostile/guardian/emperor/updatetheme(theme)
	. = ..()
	icon_living = "[theme]Mini"
	icon_state = "[theme]Mini"
	icon_dead = "[theme]Mini"

/datum/guardian_ability/major/precision
	name = "Precision"
	desc = "The guardian takes the form of a gun, able to fire precise shots."
	cost = 2
	recall_mode = TRUE
	mode_on_msg = "<span class='danger'><B>You transform yourself into your gun form.</span></B>"
	mode_off_msg = "<span class='danger'><B>You transform yourself into your holoform.</span></B>"
	arrow_weight = 0.9
	COOLDOWN_DECLARE(runcdindex)
	COOLDOWN_DECLARE(bulletcdindex)
	var/runcooldown = 0
	var/bulletcooldown = 0
	var/obj/item/gun/ballistic/revolver/emperor/gun_form

/datum/guardian_ability/major/precision/Apply()
	. = ..()
	bulletcooldown = 1 SECONDS / master_stats.potential
	runcooldown = 20 SECONDS / master_stats.speed

/datum/guardian_ability/major/precision/Recall()
	. = ..()
	if(COOLDOWN_FINISHED(src, runcdindex))
		guardian.summoner.current.add_movespeed_modifier("I'm out of here", update=TRUE, priority=102, multiplicative_slowdown=GLOB.guardian_frenzy_speedup[guardian.stats.speed])
		addtimer(CALLBACK(guardian.summoner.current, /mob.proc/remove_movespeed_modifier, "I'm out of here"), min(5, master_stats.potential * 2) SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
		COOLDOWN_START(src, runcdindex, runcooldown)
	QDEL_NULL(gun_form)

/datum/guardian_ability/major/precision/Mode()
	if(mode)
		gun_form = new /obj/item/gun/ballistic/revolver/emperor(get_turf(guardian))
		guardian.forceMove(gun_form)
		if(guardian.summoner?.current?.Adjacent(get_turf(gun_form)))
			guardian.summoner.current.put_in_active_hand(gun_form)
	else
		guardian.forceMove(get_turf(gun_form))

/obj/item/gun/ballistic/revolver/emperor
	name = "Emperor"
	desc = "The gun is mightier than the sword!"
	icon_state = "emperor"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/emperor
	var/mob/living/simple_animal/hostile/guardian/linked_guardian //ourselves
	var/obj/item/projectile/bullet/a357/emperor/favorite_projectile //our favorite son

/obj/item/gun/ballistic/revolver/emperor/Initialize()
	. = ..()
	update_clip()

/obj/item/gun/ballistic/revolver/emperor/proc/update_clip()
	for(var/obj/item/ammo_casing/a357/emperor/loaded_boolets as anything in magazine.stored_ammo) //see the bullets inside our gun's magazine
		var/obj/item/projectile/bullet/a357/emperor/loaded_projectile = loaded_boolets.BB //see the projectile inside these bullets
		loaded_projectile.linked_guardian = linked_guardian //link our shit

/obj/item/gun/ballistic/revolver/emperor/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0,cd_override = FALSE)
	magazine.top_off() //mind bullets baby
	if(favorite_projectile)
		QDEL_NULL(favorite_projectile) //get rid of the old one since we don't care about it anymore since we are firing twice //list to add turfs into
	if(linked_guardian) //do we have a stand in the first place or are we just messing around
		var/list/turfs_to_vibe_in = list()
		for(var/turf/bullet_passable_turfs in range(10 * linked_guardian.stats.range)) // get turfs in range
			turfs_to_vibe_in += bullet_passable_turfs //get our turfs in here
		var/obj/item/projectile/bullet/a357/emperor/loaded_projectile = chambered.BB //get our loaded proj before we actually fire it
		loaded_projectile.linked_guardian = linked_guardian //tuck it to bed and give it a good hug
		loaded_projectile.allowed_area = LAZYCOPY(turfs_to_vibe_in)
		favorite_projectile = loaded_projectile //set it to favorite
	. = ..()
	if(linked_guardian)
		update_clip()
	
/obj/item/ammo_box/magazine/internal/cylinder/emperor
	name = "emperor cylinder"
	ammo_type = /obj/item/ammo_casing/a357/emperor

/obj/item/ammo_casing/a357/emperor
	projectile_type = /obj/item/projectile/bullet/a357/emperor

/obj/item/projectile/bullet/a357/emperor
	wound_bonus = -20
	wound_falloff_tile = -2
	penetrating = TRUE
	var/mob/camera/emperor/following_camera
	var/mob/living/simple_animal/hostile/guardian/linked_guardian
	var/list/allowed_area = list()
	var/datum/action/rotateemperorbullet/left/rotatio1
	var/datum/action/rotateemperorbullet/right/rotatio2

/obj/item/projectile/bullet/a357/emperor/Initialize()
	. = ..()
	if(linked_guardian)
		damage = 10 * linked_guardian.stats.damage
		armour_penetration = 5 * linked_guardian.stats.damage
		penetrations = linked_guardian.stats.defense - 1 //sturdy bullet, E defense will not penetrate anything
		penetration_type = FLOOR(linked_guardian.stats.defense / 2, 1) // A & B defense can penetrate mobs, E cannot penetrate and C & D penetrate objects
		following_camera = new /mob/camera/emperor(get_turf(src))
		following_camera.linked_guardian = linked_guardian
		following_camera.linked_bullet = src
		RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/on_move)
		give_actions(linked_guardian)

/obj/item/projectile/bullet/a357/emperor/Destroy()
	if(linked_guardian)
		UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
		QDEL_NULL(following_camera)
		remove_actions(linked_guardian)
	. = ..()

/obj/item/projectile/bullet/a357/emperor/prehit(atom/target)
	. = ..()
	if(linked_guardian)
		UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
		QDEL_NULL(following_camera)
		remove_actions(linked_guardian)

/obj/item/projectile/bullet/a357/emperor/proc/on_move()
	following_camera.forceMove(get_turf(src))
	if(!LAZYFIND(allowed_area, get_turf(src)))
		to_chat(linked_guardian, span_warning("You went too far and lost control of the bullet!"))
		QDEL_NULL(src)

/datum/action/rotateemperorbullet
	name = "Rotate Bullet"
	icon_icon = 'icons/mob/actions_guardian.dmi'
	button_icon_state = "rotate_left"
	var/obj/item/projectile/bullet/a357/emperor/emperor_bullet
	var/degrees = 0

/datum/action/rotateemperorbullet/Trigger()
	. = ..()
	emperor_bullet.setAngle(emperor_bullet.original_angle + degrees)

/datum/action/rotateemperorbullet/left
	name = "Rotate Bullet (left)"
	degrees = 90

/datum/action/rotateemperorbullet/right
	name = "Rotate Bullet (right)"
	button_icon_state = "rotate_right"
	degrees = -90

/obj/item/projectile/bullet/a357/emperor/proc/give_actions(mob/living/lucky)
	rotatio1 = new /datum/action/rotateemperorbullet/left
	rotatio2 = new /datum/action/rotateemperorbullet/right
	rotatio1.emperor_bullet = src
	rotatio2.emperor_bullet = src
	rotatio1.Grant(lucky)
	rotatio2.Grant(lucky)

/obj/item/projectile/bullet/a357/emperor/proc/remove_actions(mob/living/lucky)
	rotatio1.emperor_bullet = null
	rotatio2.emperor_bullet = null
	rotatio1.Remove(lucky)
	rotatio2.Remove(lucky)
	
/mob/camera/emperor
	name = "emperor sight"
	desc = "Calibrate the endpoint of the bullet."
	var/mob/living/simple_animal/hostile/guardian/linked_guardian
	var/obj/item/projectile/bullet/linked_bullet

/mob/camera/emperor/Initialize()
	. = ..()
	linked_guardian.remote_control = src
	linked_guardian.reset_perspective(src)
	linked_guardian.client.view_size.supress()

/mob/camera/emperor/Move()
	return FALSE

/mob/camera/emperor/Destroy()
	linked_guardian.reset_perspective(null)
	linked_guardian.remote_control = null
	linked_guardian.client.view_size.unsupress()
	. = ..()
