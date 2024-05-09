/*! Movespeed modification datums.

	How move speed for mobs works

Move speed is now calculated by using modifier datums which are added to mobs. Some of them (nonvariable ones) are globally cached, the variable ones are instanced and changed based on need.

This gives us the ability to have multiple sources of movespeed, reliabily keep them applied and remove them when they should be

THey can have unique sources and a bunch of extra fancy flags that control behaviour

Previously trying to update move speed was a shot in the dark that usually meant mobs got stuck going faster or slower

Movespeed modification list is a simple key = datum system. Key will be the datum's ID if it is overridden to not be null, or type if it is not.

DO NOT override datum IDs unless you are going to have multiple types that must overwrite each other. It's more efficient to use types, ID functionality is only kept for cases where dynamic creation of modifiers need to be done.

When update movespeed is called, the list of items is iterated, according to flags priority and a bunch of conditions
this spits out a final calculated value which is used as a modifer to last_move + modifier for calculating when a mob
can next move

Key procs
* [add_movespeed_modifier](mob.html#proc/add_movespeed_modifier)
* [remove_movespeed_modifier](mob.html#proc/remove_movespeed_modifier)
* [has_movespeed_modifier](mob.html#proc/has_movespeed_modifier)
* [update_movespeed](mob.html#proc/update_movespeed)
*/

/datum/movespeed_modifier
	/// Whether or not this is a variable modifier. Variable modifiers can NOT be ever auto-cached. ONLY CHECKED VIA INITIAL(), EFFECTIVELY READ ONLY (and for very good reason)
	var/variable = FALSE

	/// Unique ID. You can never have different modifications with the same ID. By default, this SHOULD NOT be set. Only set it for cases where you're dynamically making modifiers/need to have two types overwrite each other. If unset, uses path (converted to text) as ID.
	var/id

	/// Higher ones override lower priorities. This is NOT used for ID, ID must be unique, if it isn't unique the newer one overwrites automatically if overriding.
	var/priority = 0
	var/flags = NONE

	/// Multiplicative slowdown
	var/multiplicative_slowdown = 0

	/// Movetypes this applies to
	var/movetypes = ALL

	/// Movetypes this never applies to
	var/blacklisted_movetypes = NONE

	/// Other modification datums this conflicts with.
	var/conflicts_with

/datum/movespeed_modifier/New()
	. = ..()
	if(!id)
		id = "[type]" //We turn the path into a string.

GLOBAL_LIST_EMPTY(movespeed_modification_cache)

/// Grabs a STATIC MODIFIER datum from cache. YOU MUST NEVER EDIT THESE DATUMS, OR IT WILL AFFECT ANYTHING ELSE USING IT TOO!
/proc/get_cached_movespeed_modifier(modtype)
	if(!ispath(modtype, /datum/movespeed_modifier))
		CRASH("[modtype] is not a movespeed modification typepath.")
	var/datum/movespeed_modifier/M = modtype
	if(initial(M.variable))
		CRASH("[modtype] is a variable modifier, and can never be cached.")
	M = GLOB.movespeed_modification_cache[modtype]
	if(!M)
		M = GLOB.movespeed_modification_cache[modtype] = new modtype
	return M


/*! Used for variable slowdowns like hunger/health loss/etc, works somewhat like the old list-based modification adds. Returns the modifier datum if successful
	How this SHOULD work is:
	1. Ensures type_id_datum one way or another refers to a /variable datum. This makes sure it can't be cached. This includes if it's already in the modification list.
	2. Instantiate a new datum if type_id_datum isn't already instantiated + in the list, using the type. Obviously, wouldn't work for ID only.
	3. Add the datum if necessary using the regular add proc
	4. If any of the rest of the args are not null (see: multiplicative slowdown), modify the datum
	5. Update if necessary
*/
/mob/proc/add_or_update_variable_movespeed_modifier(datum/movespeed_modifier/type_id_datum, update = TRUE, multiplicative_slowdown)
	var/modified = FALSE
	var/inject = FALSE
	var/datum/movespeed_modifier/final
	if(istext(type_id_datum))
		final = LAZYACCESS(movespeed_modification, type_id_datum)
		if(!final)
			CRASH("Couldn't find existing modification when provided a text ID.")
	else if(ispath(type_id_datum))
		if(!initial(type_id_datum.variable))
			CRASH("Not a variable modifier")
		final = LAZYACCESS(movespeed_modification, initial(type_id_datum.id) || "[type_id_datum]")
		if(!final)
			final = new type_id_datum
			inject = TRUE
			modified = TRUE
	else
		if(!initial(type_id_datum.variable))
			CRASH("Not a variable modifier")
		final = type_id_datum
		if(!LAZYACCESS(movespeed_modification, final.id))
			inject = TRUE
			modified = TRUE
	if(!isnull(multiplicative_slowdown))
		final.multiplicative_slowdown = multiplicative_slowdown
		modified = TRUE
	if(inject)
		add_movespeed_modifier(final, FALSE)
	if(update && modified)
		update_movespeed(TRUE)
	return final

/// Handles the special case of editing the movement var
/mob/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, control_object))
		var/obj/O = var_value
		if(!istype(O) || (O.obj_flags & DANGEROUS_POSSESSION))
			return FALSE
	var/slowdown_edit = (var_name == NAMEOF(src, cached_multiplicative_slowdown))
	var/diff
	if(slowdown_edit && isnum(cached_multiplicative_slowdown) && isnum(var_value))
		remove_movespeed_modifier(/datum/movespeed_modifier/admin_varedit)
		diff = var_value - cached_multiplicative_slowdown
	. = ..()
	if(. && slowdown_edit && isnum(diff))
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/admin_varedit, multiplicative_slowdown = diff)


