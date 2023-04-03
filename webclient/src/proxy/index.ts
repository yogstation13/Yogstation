import express, { response, text } from 'express';
import {readFileSync, existsSync} from 'node:fs';
import {IncomingMessage, Agent } from 'node:http';
import {Socket, connect, NetConnectOpts} from 'node:net';
import {promisify} from 'node:util';
import {randomBytes} from 'node:crypto';
import {fileURLToPath} from 'url';
import { ByondProxyConfig } from './config_types';
import {Issuer, generators} from 'openid-client';
import WebSocket from 'ws';
import { WebSocketServer } from 'ws';
import fetch from 'node-fetch';
import {Response as FetchResponse} from 'node-fetch';
import { sendTopic } from 'http2byond';
import { matches } from 'ip-matching';
import { queued_invoke } from './promise_queue';

let config : Readonly<ByondProxyConfig> = await (async () => {
	let config_paths = [
		fileURLToPath(new URL('../config.json', import.meta.url)),
		fileURLToPath(new URL('../../config/webclient-proxy.json', import.meta.url)),
		fileURLToPath(new URL('../config.example.json', import.meta.url)),
	];

	let config : ByondProxyConfig|undefined;
	for(let path of config_paths) {
		if(existsSync(path)) {
			config = JSON.parse(readFileSync(path, "utf8")) as ByondProxyConfig;
			break;
		}
	}
	if(!config) throw new Error("Couldn't find config file!");

	if(config.trusted_proxies) {
		let list = [];
		for(let proxy of config.trusted_proxies) {
			if(proxy.startsWith("http")) {
				let res = await fetch(proxy);
				if(!res.ok) throw new Error("failed to fetch " + proxy);
				list.push(...(await res.text()).split("\n"));
			} else {
				list.push(proxy);
			}
		}
	}

	return config;
})();

function proxy_matches(host : string) {
	host = host.trim();
	if(!config.trusted_proxies) return false;
	for(let proxy of config.trusted_proxies) {
		if(matches(host, proxy)) return true;
	}
	return false;
}

function origin_host(origin : string) {
	return new URL(origin).host;
}

if(config.webclient_origin == config.browse_origin) {
	console.warn("WARNING - webclient_origin and browse_origin are both " + config.webclient_origin);
	console.warn("Please put those on separate origins to prevent against potential browse() vulnerabilities");
}

let openid_client = (async () => {
	let info = config.openid_info;
	if(!info) return undefined;
	let issuer = await Issuer.discover(info.origin);
	let client = new issuer.Client(Object.assign(info.client_data, {
		redirect_uris: [`${config.webclient_origin}/`],
		response_types: ['code']
	}));
	return client;
})();

interface UserInfo {key : string; gender : string}

const LOGIN_EXPIRY = 24*60*60*1000;
const COOKIE_WS_TOKEN = "byondwcp-ws";
const COOKIE_HTTP_TOKEN = "byondwcp-http";
const COOKIE_CODE_VERIFIER = "byondwcp-cv";
const ws_tokens = new Map<string, UserInfo>();
const http_tokens = new Map<string, UserInfo>();
const wss = new WebSocketServer({noServer: true});
const wss_header_map = new WeakMap<IncomingMessage, string[]>();
wss.on('headers', (headers, req) => {
	let toinsert = wss_header_map.get(req);
	if(toinsert) {
		headers.splice(1, 0, ...toinsert);
		wss_header_map.delete(req);
	}
});

const browserfill = `<script>${readFileSync(fileURLToPath(new URL('./res/browserfill.js', import.meta.url)),"utf8")}</script>`;

const browse_domains = new Map<string, Map<string, string>>();

function html_encode(str : string) {
	return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/'/g, "&#39;").replace(/"/g, "&quot;");
}

let despam_map = new Map<string, (cb : () => Promise<any>) => Promise<any>>();
function despammedInvoke<T>(request : IncomingMessage, socket : Socket, func : () => Promise<T>) : Promise<T> {
	let addr = getProxyAddress(request, socket);
	addr = config.byond_proxy_addr ? (addr ?? "?") : "self";
	let despam = despam_map.get(addr);
	if(!despam) {
		despam = queued_invoke(30);
		despam_map.set(addr, despam);
	}
	return despam(func);
}

function getProxyAddress(request : IncomingMessage, socket : Socket) {
	let address = socket.remoteAddress;
	if(address?.toLowerCase().startsWith("::ffff:")) {
		address = address.substring(7);
	}
	
	if(config.use_cf_connected_ip) {
		address = (""+request.headers["cf-connected-ip"]) ?? address;
	} else {
		let proxy_header = request.headers["x-forwarded-for"];
		if(proxy_header instanceof Array) proxy_header = proxy_header.join(", ");
		let proxies = proxy_header?.split(",");
		while(proxies && proxies.length) {
			if(address && proxy_matches(address)) {
				address = proxies.pop();
			} else {
				console.log("Untrusted proxy " + address + " trying to be " + proxies.join(", "));
				break;
			}
		}
	}

	return address;
}

function getProxyAgent(request : IncomingMessage, socket : Socket, url? : string) {
	if(url && !url?.startsWith(`http://${config.byond_addr}`)) return undefined;
	let [byond_host, byond_port] = config.byond_addr.split(":");
	let address = getProxyAddress(request, socket);

	let agent : Agent|undefined;
	if(config.byond_proxy_addr) {
		let addr = config.byond_proxy_addr;
		agent = new Agent();
		// @ts-ignore
		agent.createConnection = (options : NetConnectOpts, callback : (err, stream) => void) => {
			let [dstaddr, dstport] = addr.split(":");
			let socket = connect(+dstport, dstaddr);
			let port = 32768 + Math.floor(Math.random() * 28232);
			socket.write(`PROXY TCP4 ${address} 255.255.255.255 ${port} ${byond_port}\r\n`);
			return socket;
		}
	}
	return agent;
}

async function upgrade_request(request : IncomingMessage, socket : Socket, head : Buffer) {
	try {
		let cookies = request.headers.cookie?.split("; ") ?? [];
		if(request.headers.host != origin_host(config.webclient_origin)) {
			console.log("Rejecting- bad host " + request.headers.host);
			socket.write('HTTP/1.1 403 Forbidden\r\n\r\n');
			socket.destroy();
			return;
		}
		if(request.headers.origin != config.webclient_origin) {
			console.log("Rejecting- bad origin " + request.headers.origin);
			socket.write('HTTP/1.1 403 Forbidden\r\n\r\n');
			socket.destroy();
			return;
		}
		let return_headers : string[] = [];
		let user_info : UserInfo|undefined;
		for(let cookie of cookies) {
			let [key, value] = cookie.split("=");
			if(!key || !value) continue;
			if(key == COOKIE_WS_TOKEN) {
				user_info = ws_tokens.get(value);
				ws_tokens.delete(value);
				return_headers.push(`Set-Cookie: ${COOKIE_WS_TOKEN}=`);
			}
		}
		if(!config.openid_info && !user_info) {
			user_info = {
				key: "Guest",
				gender: "neuter"
			};
		}
		if(!user_info) {
			socket.write('HTTP/1.1 403 Forbidden\r\n\r\n');
			socket.destroy();
			return;
		}
		if(return_headers.length) {
			wss_header_map.set(request, return_headers);
		}
		let login_token = `wcp:${(await promisify(randomBytes)(32)).toString("hex")}`;
		let user_info_str = `${encodeURIComponent(user_info.key)};gender=${user_info.gender}`;
		let [byond_host, byond_port] = config.byond_addr.split(":");
		await sendTopic({ // Tell webclient_patches to expect us
			host: byond_host,
			port: +byond_port,
			topic: `key=${encodeURIComponent(config.comms_key??"")};webclient_login_token=${login_token};webclient_login_info=${encodeURIComponent(user_info_str)}`
		});
		let byond_connection = await new Promise<WebSocket>((resolve, reject) => {
			let ws = new WebSocket('ws://' + config.byond_addr, {agent: getProxyAgent(request, socket)});
			ws.binaryType = "nodebuffer";
			ws.on('open', () => resolve(ws));
			ws.on('error', (err) => reject(err));
		});
		// Send the browser fill string - we can't trust the client to do this
		byond_connection.send(Buffer.concat([Buffer.from([0,1,0,0]), Buffer.from(browserfill, 'utf8'), Buffer.from([0])]));
		let messages : Buffer[] = [];
		let interim_handler = (data: Buffer, isBinary:boolean) => {
			if(!isBinary) return;
			messages.push(data);
		};
		let domain_string : string;
		do {
			domain_string = (await promisify(randomBytes)(16)).toString("base64url");
		} while(browse_domains.has(domain_string));
		byond_connection.on('message', interim_handler);
		wss.handleUpgrade(request, socket, head, (client : WebSocket) => {
			let domain_map = new Map<string, string>();
			browse_domains.set(domain_string, domain_map);
			client.binaryType = "nodebuffer";
			client.on('message', (data:Buffer, isBinary) => {
				if(!isBinary) return;
				let msgtype = data.readUint16BE(0);
				if(msgtype == 1) {
					return; // Do not relay the browser-fill string
				} else if(msgtype == 26) {
					// Replace the key string with our own thing
					byond_connection.send(Buffer.concat([Buffer.from([0, 26]), Buffer.from(login_token, 'utf8'), Buffer.from([0])]));
					return;
				}
				byond_connection.send(data);
			});
			let final_handler;
			byond_connection.removeListener('message', interim_handler);
			byond_connection.on('message', final_handler = (data : Buffer, isBinary:boolean) => {
				if(!isBinary) return;
				let msgtype = data.readUint16BE(0);
				if(msgtype == 243) {
					let textlen = 0;
					let end = 2;
					textlen = data.readUInt16LE(end); end += 2;
					if(textlen == 0xFFFF) {
						textlen = data.readUInt32LE(end); end += 4;
					}
					let browse_url = data.subarray(end, end+textlen).toString("utf8");
					end += textlen;
					let suffix = data.subarray(end);
					
					let new_path : string;
					do {
						new_path = `browse-${Math.floor(Math.random()*1000000000)}`;
					} while(domain_map.has(new_path));
					domain_map.set(new_path, `http://${config.byond_addr}/${browse_url}`);
					setTimeout(() => {
						domain_map.delete(new_path);
					}, 30000);
					let new_browse_url = `${config.browse_origin}/browse/${domain_string}/${new_path}`;
					let encoded = Buffer.from(new_browse_url);
					client.send(Buffer.concat([
						Buffer.from([0,243,encoded.length&0xFF,(encoded.length>>8) & 0xFF]),
						encoded,
						suffix
					]));
					return;
				} else if(msgtype == 39) {
					let end = 2;
					let msgstart = end;
					while(end < data.length && data[end]) end++;
					let msg = data.subarray(msgstart, end).toString("utf8");
					end++;
					if(msg.endsWith("<br/>\n")) {
						msg = msg.substring(0, msg.length - 6);
					}
					if(end < data.length) {
						let ctrlstart = end;
						while(end < data.length && data[end]) end++;
						let ctrl = data.subarray(ctrlstart, end).toString("utf8");
						if(ctrl == "byond-wcp:browse_rsc") {
							let eq_index = msg.indexOf("=");
							if(eq_index < 0) return;
							let resource = msg.substring(0, eq_index);
							let targetpath = msg.substring(eq_index+1);
							domain_map.set(targetpath, `http://${config.byond_addr}/${resource}`);
							return;
						}
					}
				}
				client.send(data);
			});
			for(let message of messages) {
				final_handler(message, true);
			}
			byond_connection.on('close', () => {browse_domains.delete(domain_string); client.close()});
			client.on('close', () => {browse_domains.delete(domain_string); byond_connection.close()});
			messages.length = 0;
		});
	} catch(e) {
		try {
			console.error(e);
			socket.write('HTTP/1.1 500 Internal Server Error\r\n\r\n');
		} finally {
			socket.destroy();
		}
	}
}

let app = express();

app.use("/browse/:userHash", async (req, res, next) => {
	try {
		if(req.header('host') != origin_host(config.browse_origin)) {
			res.status(404);
			res.end("Not Found");
			return;
		}
		if(req.header('sec-fetch-dest') == 'serviceworker') {
			res.status(400);
			res.end("It is forbidden to use browse() resources as serviceworkers.");
			return;
		}
		let domain = browse_domains.get(req.params.userHash);
		if(!domain) {
			res.status(404);
			res.end("Not Found");
			return;
		}
		let path = req.url;
		if(path.startsWith("/")) path = path.substring(1);
		path = path.split("?")[0];
		let url = domain.get(path);
		if(!url) {
			res.status(404);
			res.end("Not Found");
			return;
		}
		let theUrl = url;
		let fetch_res = await despammedInvoke(req, req.socket, () => retryFetch(theUrl, undefined, getProxyAgent(req, req.socket, url)));
		if(fetch_res.redirected && domain.get(path) == url) {
			domain.set(path, url = fetch_res.url); // don't follow the redirect next time.
		}
		res.setHeader('Content-Security-Policy', "base-uri 'self';")
		res.setHeader('cache-control', 'no-cache');
		for(let header of ['content-disposition', 'content-type', 'last-modified']) {
			let val = fetch_res.headers.get(header);
			if(!val) continue;
			res.setHeader(header, val);
		}
		res.status(fetch_res.status);
		res.end(new Uint8Array(await fetch_res.arrayBuffer()));
	} catch(e) {
		console.error(e);
		res.status(500);
		res.end();
		return;
	}
});

app.use("/cache/", async (req, res, next) => {
	try {
		if(req.header('host') != origin_host(config.webclient_origin)) {
			res.status(404);
			res.end("Not Found");
			return;
		}
		if(req.header('sec-fetch-dest') == 'serviceworker') {
			res.status(400);
			res.end("It is forbidden to use cache entries as serviceworkers.");
			return;
		}
		let path = req.url;
		if(path.startsWith("/")) path = path.substring(1);
		path = path.split("?")[0];
		let target_url = `http://${config.byond_addr}/cache/${path}`;
		let fetch_res = await despammedInvoke(req, req.socket, () => retryFetch(target_url, undefined, getProxyAgent(req, req.socket)));
		for(let header of ['cache-control', 'content-disposition', 'content-length', 'content-type', 'last-modified']) {
			let val = fetch_res.headers.get(header);
			if(!val) continue;
			res.setHeader(header, val);
		}
		res.status(fetch_res.status);
		res.end(new Uint8Array(await fetch_res.arrayBuffer()));
	} catch(e) {
		console.error(e);
		res.status(500);
		res.end();
		return;
	}
});

function parse_cookies(cookies : string|undefined) {
	return new Map((cookies ?? "").split("; ").map(a => a.split("=") as [string,string]));
}

app.get("/logout", (req, res) => {
	if(req.header('host') != origin_host(config.webclient_origin)) {
		res.status(404);
		res.end("Not Found");
		return;
	}
	let cookies = parse_cookies(req.header("cookie"));
	let user_info = http_tokens.get(cookies.get(COOKIE_HTTP_TOKEN)!);
	if(user_info) {
		res.clearCookie(COOKIE_HTTP_TOKEN);
		http_tokens.delete(COOKIE_HTTP_TOKEN);
		res.status(200);
		res.end("You have been logged out");
	} else {
		res.status(403);
		res.end();
	}
});
app.get("/play", async (req, res) => {
	try {
		if(req.header('host') != origin_host(config.webclient_origin)) {
			res.status(404);
			res.end("Not Found");
			return;
		}
		let cookies = parse_cookies(req.header("cookie"));
		let user_info = http_tokens.get(cookies.get(COOKIE_HTTP_TOKEN)!);
		if(user_info) {
			const WS_TOKEN_EXPIRY = 10*60*1000;
			let ws_token = (await promisify(randomBytes)(32)).toString("base64url");
			ws_tokens.set(ws_token, user_info);
			setTimeout(() => ws_tokens.delete(ws_token), LOGIN_EXPIRY);
			res.cookie(COOKIE_WS_TOKEN, ws_token, {
				httpOnly: true, maxAge: WS_TOKEN_EXPIRY, sameSite: true, secure: config.webclient_origin.startsWith("https://")
			});
			res.redirect(302, config.webclient_origin + "/");
			res.end();
		} else {
			res.status(403);
			res.end();
		}
	} catch(e) {
		console.error(e);
		res.status(500);
		res.end();
	}
});
app.use("/res", express.static(fileURLToPath(new URL('./res', import.meta.url))));
app.get("/", async (req, res, next) => {
	try {
		if(req.header('host') != origin_host(config.webclient_origin)) {
			next();
			return;
		}
		let cookies = parse_cookies(req.header("cookie"));
		if(ws_tokens.has(cookies.get(COOKIE_WS_TOKEN)!) || !config.openid_info) {
			res.sendFile(fileURLToPath(new URL('./res/index.html', import.meta.url)), err => {
				if(err) next(err);
			});
			return;
		}
		let user_info = http_tokens.get(cookies.get(COOKIE_HTTP_TOKEN)!);
		if(!user_info) {
			let client = await openid_client;
			console.log(req.query);
			if("code" in req.query) {
				if(!client) {
					res.status(404);
					res.end();
					return;
				}
				const tokenSet = await client.callback(`${config.webclient_origin}/`, client.callbackParams(req));
				let claims = tokenSet.claims();
				let http_token = (await promisify(randomBytes)(32)).toString("base64url");
				http_tokens.set(http_token, user_info = {
					key: claims.ckey as string ?? "Guest", // Misnomer: this is key, not ckey. God damn it alex.
					gender: claims.gender ?? "neuter"
				});
				setTimeout(() => http_tokens.delete(http_token), LOGIN_EXPIRY);
				res.cookie(COOKIE_HTTP_TOKEN, http_token, {
					httpOnly: true, maxAge: LOGIN_EXPIRY, sameSite: true, secure: config.webclient_origin.startsWith("https://")
				});
			} else {
				if(!client) {
					res.status(500);
					res.end();
					return;
				}
				let url = client?.authorizationUrl({
					scope: 'openid'
				});
				res.redirect(302, url);
				res.end();
				return;
			}
		}
		if(!user_info) {
			res.status(403);
			res.end();
			return;
		}
		let html = `<html><head></head>`
		+ `<body style="display: flex;flex-direction: column;justify-content: center;align-items: center;height: 100%;margin: 0px;background: #131313;color: #ccc;">`
		+ `<h1>Logged in as ${html_encode(user_info.key)}</h1>`
		+ `<h2><a href="/logout">Log out</a></h2>`
		+ `<h2><a href="/play">Play</a></h2>`
		+ `</body></html>`;
		res.status(200);
		res.end(html);
		return;
	} catch(e) {
		console.error(e);
		res.status(500);
		res.end();
		return;
	}
});

async function retryFetch(url : string, retries = 5, agent? : Agent) : Promise<FetchResponse> {
	try {
		return await fetch(url, {agent});
	} catch(e) {
		if(!retries) throw e;
		else {
			console.error(e);
			await new Promise(resolve => setTimeout(resolve, 1000));
			return await retryFetch(url, retries-1, agent);
		}
	}
}

app.listen(config.listen_port).on('upgrade', upgrade_request);
