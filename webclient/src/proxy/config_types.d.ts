import { ClientMetadata } from "openid-client";

export interface ByondProxyConfig {
	webclient_origin : string;
	browse_origin : string;

	listen_port : number;
	comms_key? : string;

	byond_addr : string;
	// Address for mmproxy
	byond_proxy_addr? : string;
	
	openid_info? : {
		// This will probably be bab.yogstation.net
		origin: string,
		// basically put a {client_data: string, client_id: string} here
		client_data : ClientMetadata
	}
}