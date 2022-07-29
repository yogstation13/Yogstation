/client/proc/spawn_floor_cluwne()
	set category = "Admin.Round Interaction"
	set name = "Unleash Floor Cluwne"
	set desc = "Pick a specific target or just let it select randomly and spawn the floor cluwne mob on the station. Be warned: spawning more than one may cause issues!"
	var/target

	if(!check_rights(R_FUN))
		return

	var/turf/T = get_turf(usr)
	target = input("Any specific target in mind? Please note only live, non cluwned, human targets are valid.", "Target", target) as null|anything in GLOB.player_list
	if(target && ishuman(target))
		var/mob/living/carbon/human/H = target
		var/mob/living/simple_animal/hostile/floor_cluwne/FC = new /mob/living/simple_animal/hostile/floor_cluwne(T)
		FC.Acquire_Victim(H)
	else
		new /mob/living/simple_animal/hostile/floor_cluwne(T)
	log_admin("[key_name(usr)] spawned floor cluwne.")
	message_admins("[key_name(usr)] spawned floor cluwne.")

/client/proc/nerf_or_nothing() // Thank you Groudon, very cool
	set category = "Admin.Round End"
	set name = "Begin Nerf War"
	set desc = "Gives all living PC humans a nerf gun, and alerts that a Nerf War has begun."

	if(alert("Are you sure you want to spawn nerf guns for every single living person on the server?",,"Yes","No") != "Yes")
		return

	var/list/gun_type_list = list(/obj/item/gun/ballistic/automatic/toy, /obj/item/gun/ballistic/automatic/toy/pistol, /obj/item/gun/ballistic/shotgun/toy, /obj/item/gun/ballistic/shotgun/toy/crossbow)
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !(H.client))
			continue
		var/type = pick(gun_type_list)
		new /obj/item/ammo_box/foambox(get_turf(H))
		new type(get_turf(H))
		if(type == /obj/item/gun/ballistic/shotgun/toy/crossbow)//for that sick combo cafe.
			new /obj/item/toy/sword(get_turf(H))
		playsound(get_turf(H),'sound/magic/Summon_guns.ogg', 50, 1)
	message_admins("[key_name_admin(usr)] has spawned foam-force guns for the entire crew.")
	priority_announce("It's Nerf or Nothing!")
