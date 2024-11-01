/**
 * An element that deletes the casing when fired and, if reusable is true, adds the projectile_drop element to the bullet.
 * Just make sure to not add components or elements that also use COMSIG_FIRE_CASING after this one.
 * Not compatible with pellets (how the eff would that work in a senible way tho?).
 */
/datum/element/caseless
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/reusable = FALSE

/datum/element/caseless/Attach(datum/target, reusable = FALSE)
	. = ..()
	if(!isammocasing(target))
		return ELEMENT_INCOMPATIBLE
	src.reusable = reusable
	RegisterSignal(target, COMSIG_CASING_READY_PROJECTILE, PROC_REF(on_ready_projectile))
	RegisterSignal(target, COMSIG_FIRE_CASING, PROC_REF(on_fired_casing))

/datum/element/caseless/proc/on_ready_projectile(obj/item/ammo_casing/shell, atom/target, mob/living/user, quiet, zone_override, atom/fired_from)
	SIGNAL_HANDLER
	var/obj/projectile/proj = shell.loaded_projectile
	if(isnull(proj))
		return
	if(reusable)
		if(!ispath(proj.shrapnel_type))
			proj.shrapnel_type = shell.type
			proj.updateEmbedding()
		proj.AddElement(/datum/element/projectile_drop, shell.type)

/datum/element/caseless/proc/on_fired_casing(obj/item/ammo_casing/shell, atom/target, mob/living/user, fired_from, randomspread, spread, zone_override, params, distro, obj/projectile/proj)
	SIGNAL_HANDLER

	if(isgun(fired_from))
		var/obj/item/gun/shot_from = fired_from
		if(shot_from.chambered == shell)
			shot_from.chambered = null //Nuke it. Nuke it now.
		if(istype(shot_from, /obj/item/gun/ballistic/revolver/sol))
			var/obj/item/ammo_box/magazine/internal/cylinder/c35sol/cylinder1 = shot_from.contents[2]
			cylinder1.stored_ammo[1] = null
			return
	QDEL_NULL(shell)
