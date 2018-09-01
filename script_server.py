import byond, importlib, time, sys, socket

class Sentinel(Exception): pass

class SetTrace(object):
	def __init__(self, func):
		self.func = func

	def __enter__(self):
		sys.settrace(self.func)
		return self

	def __exit__(self, ext_type, exc_value, traceback):
		sys.settrace(None)
		return isinstance(exc_value, Sentinel)
		
server = None
next_check = 0

def monitor(frame, event, arg):
	global next_check
	global server
	if event == "line":
		if frame.f_code.co_filename.endswith("external_script.py") and time.time() > next_check:
			next_check = time.time() + 1
			if server.subsystem.emergency_brake:
				print("Interrupted, stopping script...")
				server.subsystem.emergency_brake = 0
				raise Sentinel()
	return monitor

external_script = importlib.import_module("external_script")

server = byond.BYOND()
print("Waiting for server...")
server.connect()
print("Ready")
while True:
	importlib.invalidate_caches()
	external_script = importlib.reload(external_script)
	try:
		if server.recv() != "Let's go!": continue
		print("Received signal...")
		with SetTrace(monitor):
			external_script.main(server)
		print("Finished")
	except (ConnectionAbortedError, ConnectionResetError):
		print("WARNING: LOST CONNECTION")
		server.connect()