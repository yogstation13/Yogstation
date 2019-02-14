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
			..()
			container = null

/*
	Proc: RaiseError
	Raises a runtime error.
*/
		RaiseError(runtimeError/e)
			e.stack=functions.Copy()
			e.stack.Push(curFunction)
			src.HandleError(e)

		CreateGlobalScope()
			var/scope/S = new(program, null)
			globalScope = S
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
					while(paused) sleep(10)

					cur_statements++
					if(cur_statements >= MAX_STATEMENTS)
						RaiseError(new/runtimeError/MaxCPU(MAX_STATEMENTS))
						AlertAdmins()
						break

					if(istype(S, /node/expression))
						. =Eval(S, scope)
					if(istype(S, /node/statement/VariableDeclaration))
						//VariableDeclaration nodes are used to forcibly declare a local variable so that one in a higher scope isn't used by default.
						var/node/statement/VariableDeclaration/dec=S
						scope.init_var(dec.var_name.id_name)
					else if(istype(S, /node/statement/FunctionDefinition))
						//do nothing
					else if(istype(S, /node/statement/WhileLoop))
						. = RunWhile(S, scope)
					else if(istype(S, /node/statement/ForLoop))
						. = RunFor(S, scope)
					else if(istype(S, /node/statement/IfStatement))
						. = RunIf(S, scope)
					else if(istype(S, /node/statement/ReturnStatement))
						if(!scope.allowed_status & RETURNING)
							RaiseError(new/runtimeError/UnexpectedReturn())
							continue
						scope.status |= RETURNING
						. = (returnVal=Eval(S:value, scope))
						break
					else if(istype(S, /node/statement/BreakStatement))
						if(!scope.allowed_status & BREAKING)
							//RaiseError(new/runtimeError/UnexpectedReturn())
							continue
						scope.status |= BREAKING
						break
					else if(istype(S, /node/statement/ContinueStatement))
						if(!scope.allowed_status & CONTINUING)
							//RaiseError(new/runtimeError/UnexpectedReturn())
							continue
						scope.status |= CONTINUING
						break
					else
						RaiseError(new/runtimeError/UnknownInstruction())
					if(scope.status)
						break

/*
	Proc: RunFunction
	Runs a function block or a proc with the arguments specified in the script.
*/
		RunFunction(node/statement/FunctionCall/stmt, scope/scope)
			//Note that anywhere /node/statement/FunctionCall/stmt is used so may /node/expression/FunctionCall

			// If recursion gets too high (max 50 nested functions) throw an error
			if(scope.recursion >= MAX_RECURSION)
				AlertAdmins()
				RaiseError(new/runtimeError/RecursionLimitReached())
				return 0

			var/node/statement/FunctionDefinition/def
			if(!stmt.object)							//A scope's function is being called, stmt.object is null
				def = scope.get_function(stmt.func_name)
			else if(istype(stmt.object))				//A method of an object exposed as a variable is being called, stmt.object is a /node/identifier
				var/O = scope.get_var(stmt.object.id_name)	//Gets a reference to the object which is the target of the function call.
				if(!O) return							//Error already thrown in GetVariable()
				def = Eval(O, scope)

			if(!def) return

			cur_recursion++ // add recursion
			if(istype(def))
				if(curFunction) functions.Push(curFunction)
				scope = scope.push(def.block, globalScope, RESET_STATUS | RETURNING)
				for(var/i=1 to def.parameters.len)
					var/val
					if(stmt.parameters.len>=i)
						val = stmt.parameters[i]
					//else
					//	unspecified param
					scope.init_var(def.parameters[i], Eval(val, scope))
				curFunction=stmt
				RunBlock(def.block, scope)
				//Handle return value
				. = scope.return_val
				scope = scope.pop(0) // keep nothing
				curFunction=functions.Pop()
				cur_recursion--
			else
				cur_recursion--
				var/list/params=new
				for(var/node/expression/P in stmt.parameters)
					params+=list(Eval(P, scope))
				if(isobject(def))	//def is an object which is the target of a function call
					if( !hascall(def, stmt.func_name) )
						RaiseError(new/runtimeError/UndefinedFunction("[stmt.object.id_name].[stmt.func_name]"))
						return
					return call(def, stmt.func_name)(arglist(params))
				else										//def is a path to a global proc
					return call(def)(arglist(params))
			//else
			//	RaiseError(new/runtimeError/UnknownInstruction())

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
				RaiseError(new/runtimeError/IterationLimitReached())
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
