/obj/item/projectile/magic/variables
	name = "bolt of utter chaos"
	icon_state = "pulse1_bl"

/obj/item/projectile/magic/variables/on_hit(target)
	. = ..()
	var/atom/unsafe_cast_hey = target
	var/how_hard = rand(5, 50)
	for(var/honk=1 to how_hard)
		try
			var/proc_or_var = pick("proc", "proc_with_args", "global_proc_on_me", "swapvars", "randomizevar")
			switch(proc_or_var)
				if("proc")
					var/victim_proc = pick(typesof("[unsafe_cast_hey.type]/proc"))
					var/list/split_name = splittext("[victim_proc]", "/")
					call(unsafe_cast_hey, split_name[split_name.len-1])()
				if("proc_with_args")
					var/victim_proc = pick(typesof("[unsafe_cast_hey.type]/proc"))
					var/list/split_name = splittext("[victim_proc]", "/")
					var/amt_of_args = rand(1, 10)
					var/list/ayy_lmao = list()
					for(var/i=1 to amt_of_args)
						ayy_lmao += unsafe_cast_hey.vars[pick(unsafe_cast_hey.vars)]
					call(unsafe_cast_hey, split_name[split_name.len-1])(arglist(ayy_lmao))
				if("global_proc_on_me")
					call("[pick(typesof("/proc"))]")(unsafe_cast_hey)
				if("swapvars")
					var/first_var = pick(unsafe_cast_hey.vars)
					var/second_var = pick(unsafe_cast_hey.vars)
					var/temp = unsafe_cast_hey.vars[first_var]
					unsafe_cast_hey.vars[first_var] = unsafe_cast_hey.vars[second_var]
					unsafe_cast_hey.vars[second_var] = temp
				if("randomizevar")
					var/how = pick("random_number", "random_mob", "risk_crashing_the_server", "just_fuck_my_shit_up")
					switch(how)
						if("random_number")
							unsafe_cast_hey.vars[pick(unsafe_cast_hey.vars)] = rand(-9999999999, 9999999999)
						if("random_mob")
							unsafe_cast_hey.vars[pick(unsafe_cast_hey.vars)] = pick(GLOB.mob_list)
						if("risk_crashing_the_server")
							unsafe_cast_hey.vars[pick(unsafe_cast_hey.vars)] = GLOB.vars[pick(GLOB.vars)]
						if("just_fuck_my_shit_up")
							var/amt_of_args = rand(1, 10)
							var/list/ayy_lmao = list()
							for(var/i=1 to amt_of_args)
								ayy_lmao += unsafe_cast_hey.vars[pick(unsafe_cast_hey.vars)]
							unsafe_cast_hey.vars[pick(unsafe_cast_hey.vars)] = call("[pick(typesof("/proc"))]")(arglist(ayy_lmao))
		catch(var/exception/e)
			try
				unsafe_cast_hey.vars[pick(unsafe_cast_hey.vars)] = e
			catch()
				unsafe_cast_hey.vars[pick(unsafe_cast_hey.vars)] = 0