# SS13Script
...is a set of python scripts and a DLL, which allows calling procs and accessing variables in SS13 using python. The Rust library is based on /tg/station's [rust-g](https://github.com/tgstation/rust-g), using the `byond_fn!` macro to be precise.

It is intended to be used in cases where varedit and SDQL don't quite cut it, such as automatically calling functions every x seconds, setting variables based on conditions, etc.

#### How it works:
The DLL is a bridge between the script server and the External Scripting subsystem. Instructions are received from the script server and queued in the library. The subsystem polls ~20 times a second and executes received instructions, then serializes and returns the results by directly sending them to the server via the DLL.

#### Verbs:
- `External Script - Edit` - Pops up a window where you can edit the script. You'll want to paste from a text editor instead of editing the script directly, it's very tedious.
- `External Script - Run` - Runs the script.
- `External Script - Stop` - Stops the currently running script. It might take a couple seconds to actually do it.

#### Scripting:
The script must be named `external_script.py`. It must contain the following function: `def main(server):` which will be executed first. `server` is how you interact with, well, the server. It has the following functions:
- `new(path_string)` - Creates a new object and returns it.
- `new_cache(path_string)` - Creates a new object and does not return it. No error checking so double check your paths.
- `warn(msg_string)` - Sends a message to admins.
- `obj_from_ref(ref_string)` - Creates a BYOND object from a ref, for example `[0x00a1278b]`. You can view the address of an object by using varedit, it will be in the title bar.
- `gottagofast()` and `slowyoroll()` - Turn on and off rapid subsystem fire mode.
- If you call a function not listed here, the server will attempt to find a global proc with that name instead. So, for example, you can call `to_chat` by doing `server.to_chat(server.world, "Hello, world!")`

The `server` object has the following fields:
- `world` - The world object.
- `GLOB` - The globals controller, useful for getting all clients, all humans etc.
- `cached` - Holds the last object created using `new()` or `new_cache()`

To ignore the return value of a function, instead of calling it directly, use `object.function.noreturn()`. This is important for caching.

You may not import any modules other than `time` and `random`. Ask your local headcoder for more. Also, for the love of god, put a `time.sleep(0.1)` here and there. If you send instructions too fast you'll queue up a trillion of them and you won't be able to fix it short of stopping the entire subsystem.
#### Caching and rapid fire:
Communicating between BYOND and Python is SLOW. The script needs to wait until the subsystem polls for an instruction (50ms when there's no lag), and returns the result. To alleviate that, we can create objects, set variables and call functions without waiting for the result, by using `new_cache()` and `noreturn()`.
These functions send the appropriate instruction and return immediately. This allows us
to execute the script much faster, as we don't need to wait for the subsystem to acknowledge and process it. For example, you can immediately send the instructions to spawn a new human and gib it, by using `server.cached`:
```python
server.new_cache("/mob/living/carbon/human")
server.cached.gib.noreturn()
```
Variables are automatically set without waiting for result.

In addition to caching, you can also enable rapid fire mode by calling `server.gottagofast()`. This will cause the subystem to constantly run as long as there are instructions queued. It will suck up CPU and probably cause a stack overflow if it runs for too long, so try not to use rapid fire in long loops. You can leave by calling `server.slowyoroll()`. The subsystem will also return to normal after the script finishes execution.

Here's an example of a normal vs caching script:
```python
#Normal script
def main(server):
	mobs = server.GLOB.carbon_list #Try to save chained variable accesses like this
	for mob in mobs:
		gun = server.new("/obj/item/gun/energy/pulse/pistol/m1911")
		gun.name = "Freedom Station Instrument"
		mob.put_in_hands(gun)
```

```python
#Caching script
def main(server):
	mobs = server.GLOB.carbon_list
	for mob in mobs:
		server.new_cache("/obj/item/gun/energy/pulse/pistol/m1911")
		server.cached.name = "Freedom Station Instrument"
		mob.put_in_hands.noreturn(server.cached)
```
|   Script style  |Time to equip 1 mob|
|:---------------:|:-----------------:|
|Normal, slow fire|      0.1999s      |
|Cached, slow fire|      0.1964s      |
|Normal, fast fire|      0.1503s      |
|Cached, fast fire|      0.0502s      |
As you can see, caching and fast fire makes our script 4 times faster.

#### Example:
```python
#Making a guy flash random colors
#No rapid fire - we have an infinite loop
import time, random
def main(server):
    mob = server.obj_from_ref("[0x31337072]") #Replace with ref to your favorite player
    last_color = mob.color
    while True:
        time.sleep(0.2)
        new_color = random.choice(["red","green","blue","yellow","purple"])
        while last_color == new_color:
            new_color = random.choice(["red","green","blue","yellow","purple"])
        last_color = new_color
        mob.color = new_color
```