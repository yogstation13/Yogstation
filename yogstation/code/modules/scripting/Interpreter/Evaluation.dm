
/proc/isobject(x)
	return (istype(x, /datum) || istype(x, /list) || istype(x, /savefile) || istype(x, /client) || (x==world))

/n_Interpreter
	proc
		Eval(node/expression/exp, scope/scope)
			if(istype(exp, /node/expression/FunctionCall))
				. = RunFunction(exp, scope)
			else if(istype(exp, /node/expression/operator))
				. = EvalOperator(exp, scope)
			else if(istype(exp, /node/expression/value/literal))
				var/node/expression/value/literal/lit=exp
				. = lit.value
			else if(istype(exp, /node/expression/value/reference))
				var/node/expression/value/reference/ref=exp
				. = ref.value
			else if(istype(exp, /node/expression/value/variable))
				var/node/expression/value/variable/v=exp
				. = scope.get_var(v.id.id_name)
			else if(istype(exp, /node/expression/member/dot))
				var/node/expression/member/dot/D = exp
				var/object = D.temp_object || Eval(D.object, scope)
				D.temp_object = null
				. = get_property(object, D.id.id_name, scope)
			else if(istype(exp, /node/expression/member/brackets))
				var/node/expression/member/brackets/B = exp
				var/object = B.temp_object || Eval(B.object, scope)
				B.temp_object = null
				var/index = B.temp_index || Eval(B.index, scope)
				. = get_index(object, index, scope)
			else if(istype(exp, /node/expression))
				RaiseError(new/runtimeError/UnknownInstruction(exp))
			else
				. = exp

			return Trim(.)

		EvalOperator(node/expression/operator/exp, scope/scope)
			if(istype(exp, /node/expression/operator/binary/Assign))
				var/node/expression/operator/binary/Assign/ass=exp
				var/member_obj
				var/member_idx
				if(istype(ass.exp, /node/expression/value/variable))
					var/node/expression/value/variable/var_exp = ass.exp
					if(!scope.get_scope(var_exp.id.id_name))
						scope.init_var(var_exp.id.id_name, null)
				else if(istype(ass.exp, /node/expression/member))
					var/node/expression/member/M = ass.exp
					member_obj = Eval(M.object, scope)
					if(istype(M, /node/expression/member/brackets))
						var/node/expression/member/brackets/B = M
						member_idx = Eval(B.index, scope)
				var/out_value
				var/in_value
				if(ass.type != /node/expression/operator/binary/Assign)
					if(istype(ass.exp, /node/expression/member))
						var/node/expression/member/M = ass.exp
						M.temp_object = member_obj
						if(istype(M, /node/expression/member/brackets))
							var/node/expression/member/brackets/B = M
							B.temp_index = member_idx
					in_value = Eval(ass.exp, scope)
					if(islist(in_value))
						out_value = in_value
						switch(ass.type)
							if(/node/expression/operator/binary/Assign/BitwiseAnd)
								in_value &= Eval(ass.exp2, scope)
							if(/node/expression/operator/binary/Assign/BitwiseOr)
								in_value |= Eval(ass.exp2, scope)
							if(/node/expression/operator/binary/Assign/BitwiseXor)
								in_value ^= Eval(ass.exp2, scope)
							if(/node/expression/operator/binary/Assign/Add)
								in_value += Eval(ass.exp2, scope)
							if(/node/expression/operator/binary/Assign/Subtract)
								in_value -= Eval(ass.exp2, scope)
							else
								out_value = null
				if(!out_value)
					switch(ass.type)
						if(/node/expression/operator/binary/Assign)
							out_value = Eval(ass.exp2, scope)
						if(/node/expression/operator/binary/Assign/BitwiseAnd)
							out_value = BitwiseAnd(in_value, Eval(ass.exp2, scope))
						if(/node/expression/operator/binary/Assign/BitwiseOr)
							out_value = BitwiseOr(in_value, Eval(ass.exp2, scope))
						if(/node/expression/operator/binary/Assign/BitwiseXor)
							out_value = BitwiseXor(in_value, Eval(ass.exp2, scope))
						if(/node/expression/operator/binary/Assign/Add)
							out_value = Add(in_value, Eval(ass.exp2, scope))
						if(/node/expression/operator/binary/Assign/Subtract)
							out_value = Subtract(in_value, Eval(ass.exp2, scope))
						if(/node/expression/operator/binary/Assign/Multiply)
							out_value = Multiply(in_value, Eval(ass.exp2, scope))
						if(/node/expression/operator/binary/Assign/Divide)
							out_value = Divide(in_value, Eval(ass.exp2, scope))
						if(/node/expression/operator/binary/Assign/Power)
							out_value = Power(in_value, Eval(ass.exp2, scope))
						if(/node/expression/operator/binary/Assign/Modulo)
							out_value = Modulo(in_value, Eval(ass.exp2, scope))
						else
							RaiseError(new/runtimeError/UnknownInstruction(ass))
					// write it to the var
					if(istype(ass.exp, /node/expression/value/variable))
						var/node/expression/value/variable/var_exp = ass.exp
						scope.set_var(var_exp.id.id_name, out_value)
					else if(istype(ass.exp, /node/expression/member/dot))
						var/node/expression/member/dot/dot_exp = ass.exp
						set_property(member_obj, dot_exp.id.id_name, out_value, scope)
					else if(istype(ass.exp, /node/expression/member/brackets))
						set_index(member_obj, member_idx, out_value, scope)
					else
						RaiseError(new/runtimeError/InvalidAssignment())
				return out_value
			else if(istype(exp, /node/expression/operator/binary))
				var/node/expression/operator/binary/bin=exp
				switch(bin.type)
					if(/node/expression/operator/binary/Equal)
						return Equal(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					if(/node/expression/operator/binary/NotEqual)
						return NotEqual(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					if(/node/expression/operator/binary/Greater)
						return Greater(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					if(/node/expression/operator/binary/Less)
						return Less(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					if(/node/expression/operator/binary/GreaterOrEqual)
						return GreaterOrEqual(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					if(/node/expression/operator/binary/LessOrEqual)
						return LessOrEqual(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					if(/node/expression/operator/binary/LogicalAnd)
						return LogicalAnd(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					if(/node/expression/operator/binary/LogicalOr)
						return LogicalOr(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					if(/node/expression/operator/binary/LogicalXor)
						return LogicalXor(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					if(/node/expression/operator/binary/BitwiseAnd)
						return BitwiseAnd(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					if(/node/expression/operator/binary/BitwiseOr)
						return BitwiseOr(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					if(/node/expression/operator/binary/BitwiseXor)
						return BitwiseXor(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					if(/node/expression/operator/binary/Add)
						return Add(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					if(/node/expression/operator/binary/Subtract)
						return Subtract(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					if(/node/expression/operator/binary/Multiply)
						return Multiply(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					if(/node/expression/operator/binary/Divide)
						return Divide(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					if(/node/expression/operator/binary/Power)
						return Power(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					if(/node/expression/operator/binary/Modulo)
						return Modulo(Eval(bin.exp, scope), Eval(bin.exp2, scope))
					else
						RaiseError(new/runtimeError/UnknownInstruction(bin))
			else
				switch(exp.type)
					if(/node/expression/operator/unary/Minus)
						return Minus(Eval(exp.exp, scope))
					if(/node/expression/operator/unary/LogicalNot)
						return LogicalNot(Eval(exp.exp, scope))
					if(/node/expression/operator/unary/BitwiseNot)
						return BitwiseNot(Eval(exp.exp, scope))
					if(/node/expression/operator/unary/group)
						return Eval(exp.exp, scope)
					else
						RaiseError(new/runtimeError/UnknownInstruction(exp))


	//Binary//
		//Comparison operators
		Equal(a, b) 				return a==b
		NotEqual(a, b)			return a!=b //LogicalNot(Equal(a, b))
		Greater(a, b)				return a>b
		Less(a, b)					return a<b
		GreaterOrEqual(a, b)return a>=b
		LessOrEqual(a, b)		return a<=b
		//Logical Operators
		LogicalAnd(a, b)		return a&&b
		LogicalOr(a, b)			return a||b
		LogicalXor(a, b)		return (a||b) && !(a&&b)
		//Bitwise Operators
		BitwiseAnd(a, b)		return a&b
		BitwiseOr(a, b)			return a|b
		BitwiseXor(a, b)		return a^b
		//Arithmetic Operators
		Add(a, b)
			if(istext(a)&&!istext(b))
				b="[b]"
			else if(istext(b)&&!istext(a)&&!islist(a))
				a="[a]"
			if(isnull(a) || isnull(b))
				RaiseError(new/runtimeError/TypeMismatch("+", a, b))
				return null
			return a+b
		Subtract(a, b)
			if(isnull(a) || isnull(b))
				RaiseError(new/runtimeError/TypeMismatch("-", a, b))
				return null
			return a-b
		Divide(a, b)
			if(isnull(a) || isnull(b))
				RaiseError(new/runtimeError/TypeMismatch("/", a, b))
				return null
			if(b)
				return a/b
			// If $b is 0 or Null or whatever, then the above if statement fails,
			// and we got a divison by zero.
			RaiseError(new/runtimeError/DivisionByZero())
			//ReleaseSingularity()
			return null
		Multiply(a, b)
			if(isnull(a) || isnull(b))
				RaiseError(new/runtimeError/TypeMismatch("*", a, b))
				return null
			return a*b
		Modulo(a, b)
			if(isnull(a) || isnull(b))
				RaiseError(new/runtimeError/TypeMismatch("%", a, b))
				return null
			return a%b
		Power(a, b)
			if(isnull(a) || isnull(b))
				RaiseError(new/runtimeError/TypeMismatch("**", a, b))
				return null
			return a**b

	//Unary//
		Minus(a)						return -a
		LogicalNot(a)				return !a
		BitwiseNot(a)				return ~a
