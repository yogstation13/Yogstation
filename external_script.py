def main(server):
	import time
	server.gottagofast()
	mobs = server.GLOB.carbon_list
	start_time = time.time()
	times = []
	for mob in mobs:#
		server.new_cache("/obj/item/gun/energy/pulse/pistol/m1911")
		server.cached.name = "Freedom Station Instrument"
		mob.put_in_hands.noreturn(server.cached)
		times.append(time.time()-start_time)
		start_time = time.time()
	avg = sum(times)/len(times)
	server.warn("Average time per mob: "+str(round(avg, 4)))
