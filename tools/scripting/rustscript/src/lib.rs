#[macro_use]
mod byond;
#[macro_use]
extern crate lazy_static;
#[macro_use]
extern crate log;

extern crate simplelog;
use simplelog::*;

extern crate encoding;
use encoding::all::ASCII;
use encoding::{EncoderTrap, Encoding};

use std::fs::File;

use std::io::prelude::*;
use std::io::BufReader;
use std::io::Write;

use std::sync::mpsc::{channel, Receiver, Sender};

use std::net::SocketAddr;

static mut SCRIPT_SERVER: Option<std::net::TcpStream> = None;
static INIT: std::sync::Once = std::sync::Once::new();
lazy_static! {
	static ref INSTRUCTION_CHANNEL: std::sync::Mutex<(Sender<String>, Receiver<String>)> =
		std::sync::Mutex::new(channel());
}

byond_fn! { initialize() {
	INIT.call_once(|| {
		let _ = WriteLogger::init(LevelFilter::Debug, Config::default(), File::create("exscript.log").unwrap());
		debug!("Initializing...");
	});
	let ip: SocketAddr = "127.0.0.1:5678".parse().expect("This is not an address");
	match std::net::TcpStream::connect_timeout(&ip, std::time::Duration::from_secs(5)) {
		Ok(c) => {
			debug!("Connected to script server...");
			SCRIPT_SERVER = Some(c);
			},
		Err(_e) => {
			debug!("Could not connect to script server, aborting!");
			return Some("ERROR");
		},
	}
	match SCRIPT_SERVER.as_ref().unwrap().set_read_timeout(Some(std::time::Duration::from_secs(5))) {
		Ok(()) => (),
		Err(e) => debug!("Failed to set timeout: {}", e),
	}
	std::thread::spawn(|| {
		debug!("Starting new receiving thread");
		for line in BufReader::new(SCRIPT_SERVER.as_ref().unwrap()).lines() {
			match line {
				Ok(l) => {
					if l == "HEARTBEAT" { continue };
					debug!("Received data: {}", l);
					match INSTRUCTION_CHANNEL.lock().and_then(|c| { Ok(c.0.send(l)) }) {
						Ok(_) => (),
						Err(e) => {
							debug!("Failed to queue data: {}", e);
							break;
						}
					}
				}
				Err(e) => {
					debug!("Disconnected: {}", e);
					break;
				}
			}
		}
		debug!("Exiting receiving thread");
	});
	debug!("Initialized!");
	Some("OK")
} }

byond_fn! { get_instruction() {
	let data = INSTRUCTION_CHANNEL.lock().unwrap().1.try_recv();
	match data {
		Ok(s) => {
			debug!("Passing instruction to DM side");
			Some(s)
		},
		Err(_e) => Some(String::new())
	}
} }

byond_fn! { return_data(data) {
	debug!("Received data from DM side: {}", data);
	SCRIPT_SERVER.as_ref().unwrap().write_all(&ASCII.encode(&data.to_string(), EncoderTrap::Strict).unwrap()).expect("socket write failed");
	Some("")
} }

byond_fn! { destroy() {
	debug!("Shutting down...");
	let c = SCRIPT_SERVER.as_ref().unwrap();
	match c.shutdown(std::net::Shutdown::Both) {
		Ok(()) => (),
		Err(e) => debug!("Shutdown failed, shit might break: {}", e),
	}
	std::mem::drop(c);
	Some("")
} }
