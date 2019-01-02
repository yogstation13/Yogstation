/obj/item/projectile/magic/variables
	name = "bolt of utter chaos"
	icon_state = "pulse1_bl"

GLOBAL_LIST_INIT(exceptionally_fun_vars_and_procs, list("Destroy", "ckey", "holder", "reload_admins", "load_admins", "restart", "Reboot", "standard_reboot", "cinematic", "Cinematic", "create_ban", "unban", "edit_ban", "end_round", "toggle_nuke", "panicbunker", "RemoveBan", "random_string", "load_admin_ranks", "load_mentors", "ClearTempbans", "ClearAllBans", "CreateBans", "ending_helper", "force_ending", "check_finished", "station_was_nuked", "cult_ending_helper", "KillEveryoneOnZLevel"))
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
					var/name = split_name[split_name.len]
					if(name in GLOB.exceptionally_fun_vars_and_procs)
						continue
					call(unsafe_cast_hey, name)()
				if("proc_with_args")
					var/victim_proc = pick(typesof("[unsafe_cast_hey.type]/proc"))
					var/list/split_name = splittext("[victim_proc]", "/")
					var/name = split_name[split_name.len]
					if(name in GLOB.exceptionally_fun_vars_and_procs)
						continue
					var/amt_of_args = rand(1, 10)
					var/list/ayy_lmao = list()
					for(var/i=1 to amt_of_args)
						ayy_lmao += unsafe_cast_hey.vars[pick(unsafe_cast_hey.vars)]
					call(unsafe_cast_hey, name)(arglist(ayy_lmao))
				if("global_proc_on_me")
					var/gproc = "[pick(typesof("/proc"))]"
					var/list/split_name = splittext("[gproc]", "/")
					var/name = split_name[split_name.len]
					if(name in GLOB.exceptionally_fun_vars_and_procs)
						continue
					call(gproc)(unsafe_cast_hey)
				if("swapvars")
					var/first_var = pick(unsafe_cast_hey.vars)
					var/second_var = pick(unsafe_cast_hey.vars)
					if((first_var in GLOB.exceptionally_fun_vars_and_procs) || (second_var in GLOB.exceptionally_fun_vars_and_procs))
						return
					var/temp = unsafe_cast_hey.vars[first_var]
					unsafe_cast_hey.vars[first_var] = unsafe_cast_hey.vars[second_var]
					unsafe_cast_hey.vars[second_var] = temp
				if("randomizevar")
					var/victim_var = pick(unsafe_cast_hey.vars)
					if(victim_var in GLOB.exceptionally_fun_vars_and_procs)
						continue
					var/how = pick("random_number", "random_mob", "risk_crashing_the_server", "just_fuck_my_shit_up")
					switch(how)
						if("random_number")
							unsafe_cast_hey.vars[victim_var] = rand(-9999999999, 9999999999)
						if("random_mob")
							unsafe_cast_hey.vars[victim_var] = pick(GLOB.mob_list)
						if("risk_crashing_the_server")
							unsafe_cast_hey.vars[victim_var] = GLOB.vars[pick(GLOB.vars)]
						if("just_fuck_my_shit_up")
							var/amt_of_args = rand(1, 10)
							var/list/ayy_lmao = list()
							for(var/i=1 to amt_of_args)
								ayy_lmao += unsafe_cast_hey.vars[pick(unsafe_cast_hey.vars)]
							var/gproc = "[pick(typesof("/proc"))]"
							var/list/split_name = splittext("[gproc]", "/")
							var/name = split_name[split_name.len]
							if(name in GLOB.exceptionally_fun_vars_and_procs)
								continue
							unsafe_cast_hey.vars[victim_var] = call(gproc)(arglist(ayy_lmao))
		catch(var/exception/e)
			var/victim_var = pick(unsafe_cast_hey.vars)
			if(victim_var in GLOB.exceptionally_fun_vars_and_procs)
				continue
			try
				unsafe_cast_hey.vars[victim_var] = e
			catch()
				unsafe_cast_hey.vars[victim_var] = 0
