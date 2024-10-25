/*
 * Macros: Status Macros
 */
///Indicates that the current function is returning a value.
#define RETURNING (1<<0)
///Indicates that the current loop is being terminated.
#define BREAKING (1<<2)
///Indicates that the rest of the current iteration of a loop is being skipped.
#define CONTINUING (1<<3)
///Indicates that we are entering a new function and the allowed_status var should be cleared
#define RESET_STATUS (1<<4)

/*
 * Macros: Maximums
 * MAX_STATEMENTS fuckin'... holds the maximum statements. I'unno, dude, I'm not the guy who made NTSL,
 * I don't do fuckin verbose-ass comments line this.
 * Figure it out yourself, fuckface.
 *
 * very helpful comment ^ ty
 */
///Maximum amount of statements that can be called in one execution. this is to prevent massive crashes and exploitation
#define MAX_STATEMENTS 900
///Max number of uninterrupted loops possible
#define MAX_ITERATIONS 100
///<ax recursions without returning anything (or completing the code block)
#define MAX_RECURSION 10
#define MAX_STRINGLEN 1024
#define MAX_LISTLEN 256

/**
 * n_Interpreter
 * Procedures allowing for interaction with the script that is being run by the interpreter object.
 */
/datum/n_Interpreter
	var/datum/scope/globalScope
	var/datum/node/BlockDefinition/program
	var/datum/node/statement/FunctionDefinition/curFunction
	var/datum/stack/functions = new()
	var/datum/TCS_Compiler/container // associated container for interpeter

	///Boolean indicating that the rest of the current block should be skipped. This may be set to any combination of <Status Macros>.
	var/status = FALSE
	var/returnVal

	/// current amount of statements called
	var/cur_statements = FALSE
	//Boolean on wheteher admins should be notified of anymore issues.
	var/alertadmins = FALSE
	///Current amount of recursion
	var/cur_recursion = 0
	///Boolean that will reset global variables after Run() finishes.
	var/persist = TRUE
	var/paused = FALSE

/datum/n_Interpreter/New(datum/node/BlockDefinition/GlobalBlock/program)
	. = ..()
	if(program)
		Load(program)

/**
 * Load
 * Loads a 'compiled' script into Memory.
 * program - A <GlobalBlock> object which represents the script's global scope.
 *
 * Parameters:
 * program - A <GlobalBlock> object which represents the script's global scope.
 */
/datum/n_Interpreter/proc/Load(datum/node/BlockDefinition/GlobalBlock/program)
	ASSERT(program)
	src.program = program
	CreateGlobalScope()
	alertadmins = FALSE

///Trims strings and vectors down to an acceptable size, to prevent runaway memory usage
/datum/n_Interpreter/proc/Trim(value)
	if(istext(value) && (length(value) > MAX_STRINGLEN))
		value = copytext(value, 1, MAX_STRINGLEN + 1)
	else if(islist(value) && (length(value) > MAX_LISTLEN))
		var/list/L = value
		value = L.Copy(1, MAX_LISTLEN + 1)
	return value

///Sets ourselves to Garbage Collect.
/datum/n_Interpreter/proc/garbage_collect()
	container = null

///Raises a Runtime error.
/datum/n_Interpreter/proc/RaiseError(datum/runtimeError/e, datum/scope/scope, datum/token/token)
	e.scope = scope
	if(istype(token))
		e.token = token
	else if(istype(token, /datum/node))
		var/datum/node/N = token
		e.token = N.token
	HandleError(e)

/datum/n_Interpreter/proc/CreateGlobalScope()
	var/datum/scope/S = new(program, null)
	globalScope = S
	for(var/functype in subtypesof(/datum/n_function/default))
		var/datum/n_function/default/god_damn_it_byond = functype
		if(!istype(src, initial(god_damn_it_byond.interp_type)))
			continue
		var/datum/n_function/default/func = new functype()
		globalScope.init_var(func.name, func)
		for(var/alias in func.aliases)
			globalScope.init_var(alias, func)
	return S

///Alerts the admins of a script that is bad.
/datum/n_Interpreter/proc/AlertAdmins()
	if(!container || alertadmins)
		return
	if(!istype(container, /datum/TCS_Compiler))
		return
	var/datum/TCS_Compiler/Compiler = container
	var/obj/machinery/telecomms/server/Holder = Compiler.Holder
	var/message = "Potential crash-inducing NTSL script detected at telecommunications server [Compiler.Holder] ([Holder.x], [Holder.y], [Holder.z])."
	alertadmins = TRUE
	message_admins(message)

///Runs each statement in a block of code.
/datum/n_Interpreter/proc/RunBlock(datum/node/BlockDefinition/Block, datum/scope/scope = globalScope)
	if(cur_statements >= MAX_STATEMENTS)
		return
	for(var/datum/node/S in Block.statements)
		while(paused)
			sleep(1 SECONDS)

		cur_statements++
		if(cur_statements >= MAX_STATEMENTS)
			RaiseError(new /datum/runtimeError/MaxCPU(MAX_STATEMENTS), scope, S)
			AlertAdmins()
			break

		if(istype(S, /datum/node/expression))
			. = Eval(S, scope)
		else if(istype(S, /datum/node/statement/VariableDeclaration))
			//VariableDeclaration nodes are used to forcibly declare a local variable so that one in a higher scope isn't used by default.
			var/datum/node/statement/VariableDeclaration/dec = S
			scope.init_var(dec.var_name.id_name, src, S)
		else if(istype(S, /datum/node/statement/FunctionDefinition))
			var/datum/node/statement/FunctionDefinition/dec = S
			scope.init_var(dec.func_name, new /datum/n_function/defined(dec, scope, src), src, S)
		else if(istype(S, /datum/node/statement/WhileLoop))
			. = RunWhile(S, scope)
		else if(istype(S, /datum/node/statement/ForLoop))
			. = RunFor(S, scope)
		else if(istype(S, /datum/node/statement/IfStatement))
			. = RunIf(S, scope)
		else if(istype(S, /datum/node/statement/ReturnStatement))
			if(!(scope.allowed_status & RETURNING))
				RaiseError(new /datum/runtimeError/UnexpectedReturn(), scope, S)
				continue
			scope.status |= RETURNING
			. = (scope.return_val = Eval(S:value, scope))
			break
		else if(istype(S, /datum/node/statement/BreakStatement))
			if(!(scope.allowed_status & BREAKING))
				//RaiseError(new /datum/runtimeError/UnexpectedReturn())
				continue
			scope.status |= BREAKING
			break
		else if(istype(S, /datum/node/statement/ContinueStatement))
			if(!(scope.allowed_status & CONTINUING))
				//RaiseError(new /datum/runtimeError/UnexpectedReturn())
				continue
			scope.status |= CONTINUING
			break
		else
			RaiseError(new /datum/runtimeError/UnknownInstruction(S), scope, S)
		if(scope.status)
			break

///Runs a function block or a proc with the arguments specified in the script.
/datum/n_Interpreter/proc/RunFunction(datum/node/expression/FunctionCall/stmt, datum/scope/scope)
	var/datum/n_function/func
	var/this_obj
	if(istype(stmt.function, /datum/node/expression/member))
		var/datum/node/expression/member/M = stmt.function
		this_obj = M.temp_object = Eval(M.object, scope)
		func = Eval(M, scope)
	else
		func = Eval(stmt.function, scope)
	if(!istype(func))
		RaiseError(new /datum/runtimeError/UndefinedFunction("[stmt.function.ToString()]"), scope, stmt)
		return
	var/list/params = list()
	for(var/datum/node/expression/P in stmt.parameters)
		params += list(Eval(P, scope))

	try
		return func.execute(this_obj, params, scope, src, stmt)
	catch(var/exception/E)
		RaiseError(new /datum/runtimeError/Internal(E), scope, stmt)

///Checks a condition and runs either the if block or else block.
/datum/n_Interpreter/proc/RunIf(datum/node/statement/IfStatement/stmt, datum/scope/scope)
	if(!stmt.skip)
		scope = scope.push(stmt.block)
		if(Eval(stmt.cond, scope))
			. = RunBlock(stmt.block, scope)
			// Loop through the if else chain and tell them to be skipped.
			var/datum/node/statement/IfStatement/i = stmt.else_if
			var/fail_safe = 800
			while(i && fail_safe)
				fail_safe -= 1
				i.skip = 1
				i = i.else_if

		else if(stmt.else_block)
			. = RunBlock(stmt.else_block, scope)
		scope = scope.pop()
	// We don't need to skip you anymore.
	stmt.skip = FALSE

///Runs a while loop.
/datum/n_Interpreter/proc/RunWhile(datum/node/statement/WhileLoop/stmt, datum/scope/scope)
	var/i = 1
	scope = scope.push(stmt.block, allowed_status = CONTINUING | BREAKING)
	while(Eval(stmt.cond, scope) && Iterate(stmt.block, scope, i++))
		continue
	scope = scope.pop(RETURNING)

/datum/n_Interpreter/proc/RunFor(datum/node/statement/ForLoop/stmt, datum/scope/scope)
	var/i = 1
	scope = scope.push(stmt.block)
	Eval(stmt.init, scope)
	while(Eval(stmt.test, scope))
		if(Iterate(stmt.block, scope, i++))
			Eval(stmt.increment, scope)
		else
			break
	scope = scope.pop(RETURNING)

///Runs a single iteration of a loop. Returns a value indicating whether or not to continue looping.
/datum/n_Interpreter/proc/Iterate(datum/node/BlockDefinition/block, datum/scope/scope, count)
	RunBlock(block, scope)
	if(MAX_ITERATIONS > 0 && count >= MAX_ITERATIONS)
		RaiseError(new /datum/runtimeError/IterationLimitReached(), scope, block)
		return FALSE
	if(status & (BREAKING | RETURNING))
		return FALSE
	status &= ~CONTINUING
	return TRUE

#undef MAX_STATEMENTS
#undef MAX_ITERATIONS
#undef MAX_RECURSION
#undef MAX_STRINGLEN
#undef MAX_LISTLEN
