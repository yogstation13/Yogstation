/mob/living/attack_god(mob/camera/hog_god/god, modifier)
    var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(src)
    if(cultie.cult != god.cult || !cultie)
		get_fucked_by_hog_pylons(src, god.cult, god)
        return
    if(src.stat == DEAD)
        return ///We can't do anything with dead dudes
	var/list/spells_to_use = list()
	var/list/names = list()
    for(var/datum/hog_god_interaction/targeted/spell in cultie.god_actions)
        if(!(spell in god.spells))
            continue
		spells_to_use[spell.name] = spell
		names += spell.name
	var/datum/hog_god_interaction/spelli = spells_to_use[input(god,"What do you want to cast?","Action") in names]
	if(!spelli)
		return
	if(!spelli.on_called(god))
		return
	spelli.on_targeting(god, src)
	return 

/proc/get_fucked_by_hog_pylons(var/atom/target, var/datum/team/hog_cult/executor, var/mob/camera/god)	
	if(target.stat || target.IsStun() || target.IsParalyzed())
		return
	if(isslime(target))
		return
	if(ishostile(target))
		var/mob/living/simple_animal/hostile/H = target
		if(ismegafauna(H) || H.status_flags & GODMODE)
			return
    if(isrevenant(target))
		var/mob/living/simple_animal/revenant/R = target
		if(R.stasis)
            return
    if(isliving(target))
        var/mob/living/L = target
		if((HAS_TRAIT(L, TRAIT_BLIND)) || L.anti_magic_check(TRUE, TRUE) || L.stat == DEAD)
			return
        var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(target)
	    if(cultie && cultie.cult == executor)
		    return	
    else if(ismecha(target))
        var/obj/mecha/M = target
		if(M.occupant)
			var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(M.occupant)
	        if(cultie && cultie.cult == executor)
		        return	
    else if(istype(target, /obj/structure/hog_structure))
        var/obj/structure/hog_structure/structure = target
        if(structure.cult == executor)
            return
    var/yes = FALSE
    for(var/obj/structure/hog_structure/lance/turret in executor.objects)
        if(get_dist(target, turret) > turret.weapon.sight_range)
            continue
        turret.weapon.target = target
        yes = TRUE
    if(yes)
        to_chat(god, span_warning("You order your defensive structures to attack [target]!"))

