import socket, json, threading

class ObjectNotFoundFail:
	pass
class VariableNotFoundFail:
	pass
class IssaProc:
	pass
	
class SecurityException(Exception): pass
def security_exception(*args, **kwargs): raise SecurityException("Attempt to call unsafe function")
	
def empty_func(*args, **kwargs): pass

def serialize(value):
	vtype = None

	if type(value) is int or type(value) is float:
		vtype = "number"
		value = str(value)
	elif type(value) is ByondObject or type(value) is CachedByondObject:
		vtype = "object"
		value = value.ref
	elif type(value) is list:
		vtype = "list"
		value = json.dumps(value)
	elif value is None:
		vtype = "null"
		value = "null"
	elif type(value) is str:
		vtype = "text"
		
	return vtype+"\x02"+value

def deserialize(data, server):
	if data == "ERROR: OBJECT NOT FOUND":
		return ObjectNotFoundFail()
	elif data == "ERROR: NO SUCH VAR":
		return VariableNotFoundFail()
	elif data == "IT'S A PROC!":
		return IssaProc()
		
	if not "\x02" in data: #integers only if the data is not serialized
		return int(data)

	dtype, value = data.split("\x02")
	if dtype == "text":
		return value
	elif dtype == "number":
		return float(value)
	elif dtype == "list":
		pot_dict = json.loads(value)
		if type(pot_dict) is dict:
			if all(v is None for v in pot_dict.values()):
				keylist = []
				for key in list(pot_dict.keys()):
					if key.startswith("[") and key.endswith("]") and ("0x" in key or "mob_" in key):
						keylist.append(ByondObject(key, server))
					else:
						keylist.append(key)
				return keylist
		return pot_dict
	elif dtype == "object":
		return ByondObject(value, server)
	elif dtype == "null":
		return None
	return value

class BYOND:
	def __init__(self):
		self.socket = socket.socket()
		self.socket.bind(("127.0.0.1", 5678))
		self.socket.listen(1)
		
		self.server_instance = None
		self.world = None
		self.GLOB = None
		self.cached = CachedByondObject(self)
		
		self.connected = False
	
	def connect(self):
		self.connected = False
		self.server_instance, addr = self.socket.accept()
		self.connected = True
		self.heartbeat()
		print("Server connected from {}".format(str(addr)))
		print("Waiting for subsystem to start...")
		self.send_instruction("GET_WORLD")
		self.world = self.recv_object()
		self.send_instruction("GET_GLOB")
		self.GLOB = self.recv_object()
		self.send_instruction("GET_SELF")
		self.subsystem = self.recv_object()
		print("Subsystem started!")
		
	def send(self, data):
		data += "\n"
		self.server_instance.sendall(data.encode())
		
	def recv(self):
		data = self.server_instance.recv(2**15)
		if not data:
			raise ConnectionResetError()
		return data.decode()
		
	def recv_object(self):
		ref = self.recv()
		return ByondObject(ref, self)
		
	def wait(self):
		self.recv()
		
	def send_instruction(self, instr, *args):
		fargs = ""
		for arg in args:
			fargs += arg+"\x01"
		self.send(instr + "\x01" + fargs)
		
	def communicate(self, *args):
		self.send_instruction(*args)
		return deserialize(self.recv(), self)
	
	def fake_getattr(self, name):
		if name == "clients":
			return self.GLOB.clients
			
		if name == "subsystem" and not self.connected:
			return None
		elif self.connected:
			return self.subsystem
			
		name = "/proc/"+name
		data = int(self.communicate("CHECK_GLOBAL_CALL", name))
		if data == 0:
			self.warn("No global proc with name {} exists!".format(name))
			return empty_func
		elif data == 1:
			func = ByondFunction(None, name, self, True)
			self.__dict__[name] = func
			return func
			
	def warn(self, message):
		self.send_instruction("WARN", message)
		
	def obj_from_ref(self, ref):
		return ByondObject(ref, self)
		
	def new(self, typepath):
		newobj = self.communicate("NEW_OBJECT", typepath, "RETURN")
		if type(newobj) is ObjectNotFoundFail:
			self.warn("Could not create object with path {}".format(typepath))
		return newobj
		
	def new_cache(self, typepath):
		self.send_instruction("NEW_OBJECT", typepath, "NORETURN")
		
	def heartbeat(self):
		if not self.connected:
			return
		self.send("HEARTBEAT")
		threading.Timer(4.0, self.heartbeat).start()

	def gottagofast(self):
		self.warn("Going into rapid fire mode.")
		self.subsystem.rapid_fire = 1

	def slowyoroll(self):
		self.subsystem.rapid_fire = 0
	
	def wrap(self):
		return ServerWrapper(self)
		
class ServerWrapper:
	def __init__(self, server):
		self.__server__ = server
		
		self.safe_fields = [
			"warn",
			"obj_from_ref",
			"new",
			"new_cache",
			"gottagofast",
			"slowyoroll",
			"GLOB",
			"world",
			"cached"
		]
		
	def __getattribute__(self, name):
		if "__" in name: return None
		serb = object.__getattribute__(self, "__server__")
		if name in object.__getattribute__(self, "safe_fields"):
			return getattr(serb, name)
		else:
			return serb.fake_getattr(name)
		

class ByondObject:
	def __init__(self, ref, inst):
		self.ref = ref
		self.server = inst
	
	def __getattr__(self, name):
		data = self.server.communicate("GET_VAR", self.ref, name)
		if type(data) is ObjectNotFoundFail:
			self.server.warn("WARNING: OBJECT NOT FOUND")
			return
		if type(data) is IssaProc:
			func = ByondFunction(self.ref, name, self.server)
			self.__dict__[name] = func #Save for later since functions won't change unlike variables
			return func
		return data

	def __setattr__(self, name, value):
		if name in self.__dict__ or name in ["ref", "server"]:
			self.__dict__[name] = value
			return
			
		value = serialize(value)
		self.server.send_instruction("SET_VAR", self.ref, name, value)
	
	def delete(self):
		self.server.communicate("DELETE", self.ref)

class CachedByondObject(ByondObject):
	def __init__(self, inst):
		self.ref = "CACHED"
		self.server = inst

	def __getattr__(self, name):
		data = self.server.communicate("GET_VAR", self.ref, name)
		if type(data) is ObjectNotFoundFail:
			self.warn("WARNING: OBJECT NOT FOUND")
			return
		if type(data) is IssaProc:
			return ByondFunction(self.ref, name, self.server)
		return data

class ByondFunction:
	def __init__(self, ref, name, inst, glob=False):
		self.ref = ref
		self.name = name
		self.server = inst
		self.glob = glob
		
	def __call__(self, *args):
		final_args = []
		for arg in args:
			final_args.append(serialize(arg))
		if self.glob:
			return self.server.communicate("CALL_GLOBAL", self.name, "\x03".join(final_args), "RETURN")
		else:
			return self.server.communicate("CALL_PROC", self.ref, self.name, "\x03".join(final_args), "RETURN")
			
	def noreturn(self, *args):
		final_args = []
		for arg in args:
			final_args.append(serialize(arg))
		if self.glob:
			return self.server.send_instruction("CALL_GLOBAL", self.name, "\x03".join(final_args), "NORETURN")
		else:
			return self.server.send_instruction("CALL_PROC", self.ref, self.name, "\x03".join(final_args), "NORETURN")