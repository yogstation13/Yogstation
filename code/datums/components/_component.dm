/datum/component
	var/dupe_mode = COMPONENT_DUPE_HIGHLANDER
	var/dupe_type
	var/datum/parent
	//only set to true if you are able to properly transfer this component
	//At a minimum RegisterWithParent and UnregisterFromParent should be used
	//Make sure you also implement PostTransfer for any post transfer handling
	var/can_transfer = FALSE

/datum/component/New(list/raw_args)
	parent = raw_args[1]
	var/list/arguments = raw_args.Copy(2)
	if(Initialize(arglist(arguments)) == COMPONENT_INCOMPATIBLE)
		qdel(src, TRUE, TRUE)
		CRASH("Incompatible [type] assigned to a [parent.type]! args: [json_encode(arguments)]")

	_JoinParent(parent)

/datum/component/proc/_JoinParent()
	var/datum/P = parent
	//lazy init the parent's dc list
	var/list/dc = P.datum_components
	if(!dc)
		P.datum_components = dc = list()

	//set up the typecache
	var/our_type = type
	for(var/I in _GetInverseTypeList(our_type))
		var/test = dc[I]
		if(test)	//already another component of this type here
			var/list/components_of_type
			if(!length(test))
				components_of_type = list(test)
				dc[I] = components_of_type
			else
				components_of_type = test
			if(I == our_type)	//exact match, take priority
				var/inserted = FALSE
				for(var/J in 1 to components_of_type.len)
					var/datum/component/C = components_of_type[J]
					if(C.type != our_type) //but not over other exact matches
						components_of_type.Insert(J, I)
						inserted = TRUE
						break
				if(!inserted)
					components_of_type += src
			else	//indirect match, back of the line with ya
				components_of_type += src
		else	//only component of this type, no list
			dc[I] = src

	RegisterWithParent()

// If you want/expect to be moving the component around between parents, use this to register on the parent for signals
/datum/component/proc/RegisterWithParent()
	return

/datum/component/proc/Initialize(...)
	return

/datum/component/Destroy(force=FALSE, silent=FALSE)
	if(!force && parent)
		_RemoveFromParent()
	if(!silent && parent)
		SEND_SIGNAL(parent, COMSIG_COMPONENT_REMOVING, src)
	parent = null
	return ..()

/datum/component/proc/_RemoveFromParent()
	var/datum/P = parent
	var/list/dc = P.datum_components
	for(var/I in _GetInverseTypeList())
		var/list/components_of_type = dc[I]
		if(length(components_of_type))	//
			var/list/subtracted = components_of_type - src
			if(subtracted.len == 1)	//only 1 guy left
				dc[I] = subtracted[1]	//make him special
			else
				dc[I] = subtracted
		else	//just us
			dc -= I
	if(!dc.len)
		P.datum_components = null

	UnregisterFromParent()

/datum/component/proc/UnregisterFromParent()
	return

/**
 * Register to listen for a signal from the passed in target
 *
 * This sets up a listening relationship such that when the target object emits a signal
 * the source datum this proc is called upon, will receive a callback to the given proctype
 * Use PROC_REF(procname), TYPE_PROC_REF(type,procname) or GLOBAL_PROC_REF(procname) macros to validate the passed in proc at compile time.
 * PROC_REF for procs defined on current type or it's ancestors, TYPE_PROC_REF for procs defined on unrelated type and GLOBAL_PROC_REF for global procs.
 * Return values from procs registered must be a bitfield
 *
 * Arguments:
 * * datum/target The target to listen for signals from
 * * signal_type A signal name
 * * proctype The proc to call back when the signal is emitted
 * * override If a previous registration exists you must explicitly set this
 */
/datum/proc/RegisterSignal(datum/target, signal_type, proctype, override = FALSE)
	if(QDELETED(src) || QDELETED(target))
		return

	if (islist(signal_type))
		var/static/list/known_failures = list()
		var/list/signal_type_list = signal_type
		var/message = "([target.type]) is registering [signal_type_list.Join(", ")] as a list, the older method. Change it to RegisterSignals."

		if (!(message in known_failures))
			known_failures[message] = TRUE
			stack_trace("[target] [message]")
		
		RegisterSignals(target, signal_type, proctype, override)
		return

	var/list/procs = (signal_procs ||= list())
	var/list/target_procs = (procs[target] ||= list())
	var/list/lookup = (target.comp_lookup ||= list())

	if(!override && target_procs[signal_type])
		log_signal("[signal_type] overridden. Use override = TRUE to suppress this warning.\nTarget: [target] ([target.type]) Proc: [proctype]")

	target_procs[signal_type] = proctype
	var/list/looked_up = lookup[signal_type]

	if(isnull(looked_up)) // Nothing has registered here yet
		lookup[signal_type] = src
	else if(looked_up == src) // We already registered here
		return
	else if(!length(looked_up)) // One other thing registered here
		lookup[signal_type] = list((looked_up) = TRUE, (src) = TRUE)
	else // Many other things have registered here
		looked_up[src] = TRUE
	
	signal_enabled = TRUE

/// Registers multiple signals to the same proc.
/datum/proc/RegisterSignals(datum/target, list/signal_types, proctype, override = FALSE)
	for (var/signal_type in signal_types)
		RegisterSignal(target, signal_type, proctype)

/datum/proc/UnregisterSignal(datum/target, sig_type_or_types)
	if(!target)
		return
	var/list/lookup = target.comp_lookup
	if(!signal_procs || !signal_procs[target] || !lookup)
		return
	if(!islist(sig_type_or_types))
		sig_type_or_types = list(sig_type_or_types)
	for(var/sig in sig_type_or_types)
		switch(length(lookup[sig]))
			if(2)
				lookup[sig] = (lookup[sig]-src)[1]
			if(1)
				stack_trace("[target] ([target.type]) somehow has single length list inside comp_lookup")
				if(src in lookup[sig])
					lookup -= sig
					if(!length(lookup))
						target.comp_lookup = null
						break
			if(0)
				lookup -= sig
				if(!length(lookup))
					target.comp_lookup = null
					break
			else
				lookup[sig] -= src

	signal_procs[target] -= sig_type_or_types
	if(!signal_procs[target].len)
		signal_procs -= target

/datum/component/proc/InheritComponent(datum/component/C, i_am_original)
	return

/datum/component/proc/CheckDupeComponent(datum/component/C, ...)
	return

/datum/component/proc/PreTransfer()
	return

/datum/component/proc/PostTransfer()
	return COMPONENT_INCOMPATIBLE //Do not support transfer by default as you must properly support it

/datum/component/proc/_GetInverseTypeList(our_type = type)
	//we can do this one simple trick
	var/current_type = parent_type
	. = list(our_type, current_type)
	//and since most components are root level + 1, this won't even have to run
	while (current_type != /datum/component)
		current_type = type2parent(current_type)
		. += current_type

/datum/proc/_SendSignal(sigtype, list/arguments)
	var/target = comp_lookup[sigtype]
	if(!length(target))
		var/datum/C = target
		if(!C.signal_enabled)
			return NONE
		var/proctype = C.signal_procs[src][sigtype]
		return NONE | CallAsync(C, proctype, arguments)
	. = NONE
	for(var/I in target)
		var/datum/C = I
		if(!C.signal_enabled)
			continue
		var/proctype = C.signal_procs[src][sigtype]
		. |= CallAsync(C, proctype, arguments)

// The type arg is casted so initial works, you shouldn't be passing a real instance into this
/datum/proc/GetComponent(datum/component/c_type)
	RETURN_TYPE(c_type)
	if(initial(c_type.dupe_mode) == COMPONENT_DUPE_ALLOWED)
		stack_trace("GetComponent was called to get a component of which multiple copies could be on an object. This can easily break and should be changed. Type: \[[c_type]\]")
	var/list/dc = datum_components
	if(!dc)
		return null
	. = dc[c_type]
	if(length(.))
		return .[1]

/datum/proc/GetExactComponent(datum/component/c_type)
	RETURN_TYPE(c_type)	
	if(initial(c_type.dupe_mode) == COMPONENT_DUPE_ALLOWED || initial(c_type.dupe_mode) == COMPONENT_DUPE_SELECTIVE)
		stack_trace("GetComponent was called to get a component of which multiple copies could be on an object. This can easily break and should be changed. Type: \[[c_type]\]")
	var/list/dc = datum_components
	if(!dc)
		return null
	var/datum/component/C = dc[c_type]
	if(C)
		if(length(C))
			C = C[1]
		if(C.type == c_type)
			return C
	return null

/datum/proc/GetComponents(c_type)
	var/list/dc = datum_components
	if(!dc)
		return null
	. = dc[c_type]
	if(!length(.))
		return list(.)

/**
 * Creates an instance of `new_type` in the datum and attaches to it as parent
 *
 * Sends the [COMSIG_COMPONENT_ADDED] signal to the datum
 *
 * Returns the component that was created. Or the old component in a dupe situation where [COMPONENT_DUPE_UNIQUE] was set
 *
 * If this tries to add a component to an incompatible type, the component will be deleted and the result will be `null`. This is very unperformant, try not to do it
 *
 * Properly handles duplicate situations based on the `dupe_mode` var
 */
/datum/proc/_AddComponent(list/raw_args)
	var/new_type = raw_args[1]
	var/datum/component/nt = new_type
	var/dm = initial(nt.dupe_mode)
	var/dt = initial(nt.dupe_type)

	var/datum/component/old_comp
	var/datum/component/new_comp

	if(ispath(nt))
		if(nt == /datum/component)
			CRASH("[nt] attempted instantiation!")
	else
		new_comp = nt
		nt = new_comp.type

	raw_args[1] = src

	if(dm != COMPONENT_DUPE_ALLOWED)
		if(!dt)
			old_comp = GetExactComponent(nt)
		else
			old_comp = GetComponent(dt)
		if(old_comp)
			switch(dm)
				if(COMPONENT_DUPE_UNIQUE)
					if(!new_comp)
						new_comp = new nt(raw_args)
					if(!QDELETED(new_comp))
						old_comp.InheritComponent(new_comp, TRUE)
						QDEL_NULL(new_comp)
				if(COMPONENT_DUPE_HIGHLANDER)
					if(!new_comp)
						new_comp = new nt(raw_args)
					if(!QDELETED(new_comp))
						new_comp.InheritComponent(old_comp, FALSE)
						QDEL_NULL(old_comp)
				if(COMPONENT_DUPE_UNIQUE_PASSARGS)
					if(!new_comp)
						var/list/arguments = raw_args.Copy(2)
						arguments.Insert(1, null, TRUE)
						old_comp.InheritComponent(arglist(arguments))
					else
						old_comp.InheritComponent(new_comp, TRUE)
				if(COMPONENT_DUPE_SELECTIVE)
					var/list/arguments = raw_args.Copy()
					arguments[1] = new_comp
					var/make_new_component = TRUE
					for(var/datum/component/C in GetComponents(new_type))
						if(C.CheckDupeComponent(arglist(arguments)))
							make_new_component = FALSE
							QDEL_NULL(new_comp)
							break
					if(!new_comp && make_new_component)
						new_comp = new nt(raw_args)
		else if(!new_comp)
			new_comp = new nt(raw_args) // There's a valid dupe mode but there's no old component, act like normal
	else if(!new_comp)
		new_comp = new nt(raw_args) // Dupes are allowed, act like normal

	if(!old_comp && !QDELETED(new_comp)) // Nothing related to duplicate components happened and the new component is healthy
		SEND_SIGNAL(src, COMSIG_COMPONENT_ADDED, new_comp)
		return new_comp
	return old_comp

/datum/proc/_LoadComponent(list/arguments)
	. = GetComponent(arguments[1])
	if(!.)
		return _AddComponent(arguments)

/datum/component/proc/RemoveComponent()
	if(!parent)
		return
	var/datum/old_parent = parent
	PreTransfer()
	_RemoveFromParent()
	parent = null
	SEND_SIGNAL(old_parent, COMSIG_COMPONENT_REMOVING, src)

/datum/proc/TakeComponent(datum/component/target)
	if(!target || target.parent == src)
		return
	if(target.parent)
		target.RemoveComponent()
	target.parent = src
	var/result = target.PostTransfer()
	switch(result)
		if(COMPONENT_INCOMPATIBLE)
			var/c_type = target.type
			qdel(target)
			CRASH("Incompatible [c_type] transfer attempt to a [type]!")

	if(target == AddComponent(target))
		target._JoinParent()

/datum/proc/TransferComponents(datum/target)
	var/list/dc = datum_components
	if(!dc)
		return
	var/comps = dc[/datum/component]
	if(islist(comps))
		for(var/datum/component/I in comps)
			if(I.can_transfer)
				target.TakeComponent(I)
	else
		var/datum/component/C = comps
		if(C.can_transfer)
			target.TakeComponent(comps)

/datum/component/ui_host()
	return parent
