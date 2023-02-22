/*
	File: Interpreter (Internal)
*/
/*
	Class: n_Interpreter
*/
/*
	Macros: Status Macros
	RETURNING  - Indicates that the current function is returning a value.
	BREAKING   - Indicates that the current loop is being terminated.
	CONTINUING - Indicates that the rest of the current iteration of a loop is being skipped.
	RESET_STATUS - Indicates that we are entering a new function and the allowed_status var should be cleared
*/
#define RETURNING  1
#define BREAKING   2
#define CONTINUING 4
#define RESET_STATUS 8

/*
	Macros: Maximums
	MAX_STATEMENTS fuckin'... holds the maximum statements. I'unno, dude, I'm not the guy who made NTSL, I don't do fuckin verbose-ass comments line this.
	Figure it out yourself, fuckface.
*/
#define MAX_STATEMENTS 900 // maximum amount of statements that can be called in one execution. this is to prevent massive crashes and exploitation
#define MAX_ITERATIONS 100 // max number of uninterrupted loops possible
#define MAX_RECURSION 10 // max recursions without returning anything (or completing the code block)
#define MAX_STRINGLEN 1024
#define MAX_LISTLEN 256

/n_Interpreter
	var
		scope
			globalScope
		node
			BlockDefinition/program
			statement/FunctionDefinition/curFunction
		stack
			functions	= new()

		datum/container // associated container for interpeter
/*
	Var: status
	A variable indicating that the rest of the current block should be skipped. This may be set to any combination of <Status Macros>.
*/
		status=0
		returnVal

		cur_statements=0    // current amount of statements called
		alertadmins=0		// set to 1 if the admins shouldn't be notified of anymore issues
		cur_recursion=0	   	// current amount of recursion
/*
	Var: persist
	If 0, global variables will be reset after Run() finishes.
*/
		persist=1
		paused=0

/*
	Constructor: New
	Calls <Load()> with the given parameters.
*/
	New(node/BlockDefinition/GlobalBlock/program=null)
		.=..()
		if(program)Load(program)

	proc
/*
	Proc: Trim
	Trims strings and vectors down to an acceptable size, to prevent runaway memory usage
*/
		Trim(value)
			if(istext(value) && (length(value) > MAX_STRINGLEN))
				value = copytext(value, 1, MAX_STRINGLEN+1)
			else if(islist(value) && (length(value) > MAX_LISTLEN))
				var/list/L = value
				value = L.Copy(1, MAX_LISTLEN+1)
			return value

/*
	Set ourselves to Garbage Collect
*/
		GC()
			container = null

/*
	Proc: RaiseError
	Raises a runtime error.
*/
		RaiseError(runtimeError/e, scope/scope, token/token)
			e.scope = scope
			if(istype(token))
				e.token = token
			else if(istype(token, /node))
				var/node/N = token
				e.token = N.token
			src.HandleError(e)

		CreateGlobalScope()
			var/scope/S = new(program, null)
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

/*
	Proc: AlertAdmins
	Alerts the admins of a script that is bad.
*/
		AlertAdmins()
			if(container && !alertadmins)
				if(istype(container, /datum/TCS_Compiler))
					var/datum/TCS_Compiler/Compiler = container
					var/obj/machinery/telecomms/server/Holder = Compiler.Holder
					var/message = "Potential crash-inducing NTSL script detected at telecommunications server [Compiler.Holder] ([Holder.x], [Holder.y], [Holder.z])."

					alertadmins = 1
					message_admins(message, 1)
/*
	Proc: RunBlock
	Runs each statement in a block of code.
*/
		RunBlock(node/BlockDefinition/Block, scope/scope = globalScope)

			if(cur_statements < MAX_STATEMENTS)
				for(var/node/S in Block.statements)
					while(paused) sleep(1 SECONDS)

					cur_statements++
					if(cur_statements >= MAX_STATEMENTS)
						RaiseError(new/runtimeError/MaxCPU(MAX_STATEMENTS), scope, S)
						AlertAdmins()
						break

					if(istype(S, /node/expression))
						. = Eval(S, scope)
					else if(istype(S, /node/statement/VariableDeclaration))
						//VariableDeclaration nodes are used to forcibly declare a local variable so that one in a higher scope isn't used by default.
						var/node/statement/VariableDeclaration/dec=S
						scope.init_var(dec.var_name.id_name, src, S)
					else if(istype(S, /node/statement/FunctionDefinition))
						var/node/statement/FunctionDefinition/dec=S
						scope.init_var(dec.func_name, new /datum/n_function/defined(dec, scope, src), src, S)
					else if(istype(S, /node/statement/WhileLoop))
						. = RunWhile(S, scope)
					else if(istype(S, /node/statement/ForLoop))
						. = RunFor(S, scope)
					else if(istype(S, /node/statement/IfStatement))
						. = RunIf(S, scope)
					else if(istype(S, /node/statement/ReturnStatement))
						if(!(scope.allowed_status & RETURNING))
							RaiseError(new/runtimeError/UnexpectedReturn(), scope, S)
							continue
						scope.status |= RETURNING
						. = (scope.return_val=Eval(S:value, scope))
						break
					else if(istype(S, /node/statement/BreakStatement))
						if(!(scope.allowed_status & BREAKING))
							//RaiseError(new/runtimeError/UnexpectedReturn())
							continue
						scope.status |= BREAKING
						break
					else if(istype(S, /node/statement/ContinueStatement))
						if(!(scope.allowed_status & CONTINUING))
							//RaiseError(new/runtimeError/UnexpectedReturn())
							continue
						scope.status |= CONTINUING
						break
					else
						RaiseError(new/runtimeError/UnknownInstruction(S), scope, S)
					if(scope.status)
						break

/*
	Proc: RunFunction
	Runs a function block or a proc with the arguments specified in the script.
*/
		RunFunction(node/expression/FunctionCall/stmt, scope/scope)
			var/datum/n_function/func
			var/this_obj
			if(istype(stmt.function, /node/expression/member))
				var/node/expression/member/M = stmt.function
				this_obj = M.temp_object = Eval(M.object, scope)
				func = Eval(M, scope)
			else
				func = Eval(stmt.function, scope)
			if(!istype(func))
				RaiseError(new/runtimeError/UndefinedFunction("[stmt.function.ToString()]"), scope, stmt)
				return
			var/list/params = list()
			for(var/node/expression/P in stmt.parameters)
				params+=list(Eval(P, scope))

			try
				return func.execute(this_obj, params, scope, src, stmt)
			catch(var/exception/E)
				RaiseError(new /runtimeError/Internal(E), scope, stmt)

/*
	Proc: RunIf
	Checks a condition and runs either the if block or else block.
*/
		RunIf(node/statement/IfStatement/stmt, scope/scope)
			if(!stmt.skip)
				scope = scope.push(stmt.block)
				if(Eval(stmt.cond, scope))
					. = RunBlock(stmt.block, scope)
					// Loop through the if else chain and tell them to be skipped.
					var/node/statement/IfStatement/i = stmt.else_if
					var/fail_safe = 800
					while(i && fail_safe)
						fail_safe -= 1
						i.skip = 1
						i = i.else_if

				else if(stmt.else_block)
					. = RunBlock(stmt.else_block, scope)
				scope = scope.pop()
			// We don't need to skip you anymore.
			stmt.skip = 0

/*
	Proc: RunWhile
	Runs a while loop.
*/
		RunWhile(node/statement/WhileLoop/stmt, scope/scope)
			var/i=1
			scope = scope.push(stmt.block, allowed_status = CONTINUING | BREAKING)
			while(Eval(stmt.cond, scope) && Iterate(stmt.block, scope, i++))
				continue
			scope = scope.pop(RETURNING)

		RunFor(node/statement/ForLoop/stmt, scope/scope)
			var/i=1
			scope = scope.push(stmt.block)
			Eval(stmt.init, scope)
			while(Eval(stmt.test, scope))
				if(Iterate(stmt.block, scope, i++))
					Eval(stmt.increment, scope)
				else
					break
			scope = scope.pop(RETURNING)

/*
	Proc:Iterate
	Runs a single iteration of a loop. Returns a value indicating whether or not to continue looping.
*/
		Iterate(node/BlockDefinition/block, scope/scope, count)
			RunBlock(block, scope)
			if(MAX_ITERATIONS > 0 && count >= MAX_ITERATIONS)
				RaiseError(new/runtimeError/IterationLimitReached(), scope, block)
				return 0
			if(status & (BREAKING|RETURNING))
				return 0
			status &= ~CONTINUING
			return 1

#undef MAX_STATEMENTS
#undef MAX_ITERATIONS
#undef MAX_RECURSION
#undef MAX_STRINGLEN
#undef MAX_LISTLEN
