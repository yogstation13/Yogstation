import byond, importlib, time, sys, socket, shutil, dis
from collections.abc import Mapping

from byond import SecurityException, security_exception

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

server = byond.BYOND()
wrapped_server = server.wrap()

unsafe_builtins = [
	"globals",
	"locals",
	"breakpoint",
	"compile",
	"delattr",
	"dir",
	"eval",
	"exec",
	"format",
	"getattr",
	"hasattr",
	"input",
	"memoryview",
	"object",
	"open",
	"property",
	"setattr",
	"type",
	"vars",
	"__import__"
]

safe_builtins = {}

whitelisted_modules = ["time", "random"]

def safe_import(name, *args, **kwargs):
	if name in whitelisted_modules:
		return __import__(name, *args, **kwargs)
	raise SecurityException("Attempt to load disallowed module: "+repr(name))

for func in dir(__builtins__):
	if func not in unsafe_builtins:
		safe_builtins[func] = getattr(__builtins__, func)
	else:
		safe_builtins[func] = security_exception
		
safe_builtins["__import__"] = safe_import

def monitor(frame, event, arg):
	global next_check
	global server
	
	if frame.f_code.co_filename.endswith("external_script.py") and event == "line":
		frame.f_globals["__builtins__"] = safe_builtins
		if time.time() > next_check:
			next_check = time.time() + 2
			if server.fake_getattr("subsystem") is not None and server.subsystem.emergency_brake:
				server.warn("Interrupted, stopping script...")
				server.subsystem.emergency_brake = 0
				raise Sentinel()
	return monitor

import_fail = ""
external_script = None
try:
	with SetTrace(monitor):
		external_script = importlib.import_module("external_script")
except Exception as e:
	import_fail = str(e)

while True:
	print("Waiting for server...")
	server.connect()
	print("Ready")
	if import_fail:
		server.warn(import_fail)
		server.warn("Fix the errors and run the script.")
		import_fail = ""
	while True:
		try:
			if server.recv() != "Let's go!": continue
			print("Received signal...")
			with open("external_script.py", "r+") as f:
				data = f.read()
				if "__" in data:
					raise SecurityException("Stop toying with python's internals")
				data = data.strip()
				f.seek(0)
				f.truncate()
				f.write(data) #Stop the script from having 10 thousand newlines at the end because of byond
			with SetTrace(monitor):
				importlib.invalidate_caches()
				if not external_script:
					external_script = importlib.import_module("external_script")
				else:
					external_script = importlib.reload(external_script)
			with SetTrace(monitor):
				external_script.main(wrapped_server)
		except (ConnectionAbortedError, ConnectionResetError):
			print("Server disconnected!")
			break
		except SecurityException as e:
			server.warn("SECURITY EXCEPTION: " + str(e))
		#except Exception as e:
		#	server.warn(str(e))
		print("Finished running script")
		server.slowyoroll()