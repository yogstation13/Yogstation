import socket, urllib.parse, json

class ObjectNotFoundFail:
	pass
class VariableNotFoundFail:
	pass
	
def empty_func(*args, **kwargs): pass

def serialize(value):
	vtype = None

	if type(value) is int or type(value) is float:
		vtype = "number"
		value = str(value)
	elif type(value) is ByondObject:
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
	
	def connect(self):
		self.server_instance, addr = self.socket.accept()
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
		self.server_instance.sendall(data.encode())
		
	def recv(self):
		return self.server_instance.recv(4096).decode()
		
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
	
	def __getattr__(self, name):
		if name == "clients":
			return self.GLOB.clients
			
		name = "/proc/"+name
		data = int(self.communicate("CHECK_GLOBAL_CALL", name))
		if data == 0:
			self.warn("No global proc with name {} exists!".format(name))
			return empty_func
		elif data == 1:
			func = ByondFunction(None, name, self, True)
			self.__dict__[name] = func
			return func
	
	def qdel(self, thing):
		if type(thing) is ByondObject:
			thing.delete()
			
	def warn(self, message):
		self.send_instruction("WARN", message)
		
	def obj_from_ref(self, ref):
		return ByondObject(ref, self)
		
	def new(self, typepath):
		newobj = self.communicate("NEW_OBJECT", typepath)
		if type(newobj) is ObjectNotFoundFail:
			self.warn("Could not create object with path {}".format(typepath))
		return newobj

class ByondObject:
	def __init__(self, ref, inst):
		self.ref = ref
		self.server = inst
	
	def __getattr__(self, name):
		data = self.server.communicate("GET_VAR", self.ref, name)
		if type(data) is ObjectNotFoundFail:
			self.warn("WARNING: OBJECT NOT FOUND")
			return
		if type(data) is VariableNotFoundFail: #no such variable, might be a call though
			result = int(self.server.communicate("CHECK_CALL", self.ref, name))
			if result == 0: #object does not exist
				self.warn("ERROR: Object does not exist!")
			if result == 1: #no such call
				self.warn("ERROR: This object does not have a proc named {}".format(name))
			if result == 2: #eyy
				func = ByondFunction(self.ref, name, self.server)
				self.__dict__[name] = func #Save for later since functions won't change unlike variables
				return func
		return data

	def __setattr__(self, name, value):
		if name in self.__dict__ or name in ["ref", "server"]:
			self.__dict__[name] = value
			return
			
		value = serialize(value)
		self.server.communicate("SET_VAR", self.ref, name, value)
	
	def delete(self):
		self.server.communicate("DELETE", self.ref)

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
			return self.server.communicate("CALL_GLOBAL", self.name, "\x03".join(final_args))
		else:
			return self.server.communicate("CALL_PROC", self.ref, self.name, "\x03".join(final_args))