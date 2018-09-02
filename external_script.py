import random, time
def main(server):
	print("Running external script...")
	#Add your code here...
	start_time = time.time()
	mobs = server.GLOB.carbon_list
	for mob in mobs:
		gun = server.new("/obj/item/gun/energy/pulse/pistol/m1911")
		gun.name = "Freedom Station Instrument"
		mob.put_in_hands(gun)
	elapsed = round(time.time() - start_time)
	per_mob = elapsed/len(mobs)
	per_instr = per_mob/4
	print("Elapsed time: "+str(elapsed)+"s")
	print(str(per_mob)+"s per mob")
	print(str(per_instr)+"s per instruction")
	