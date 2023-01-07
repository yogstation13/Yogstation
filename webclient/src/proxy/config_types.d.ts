import { ClientMetadata } from "openid-client";

export interface ByondProxyConfig {
	webclient_origin : string;
	browse_origin : string;

	listen_port : number;
	comms_key? : string;

	byond_addr : string;
	// Address for mmproxy
	byond_proxy_addr? : string;

	// A list of trusted proxy IPs to allow X-Forwarded-For from
	// Can also be URLs to lists of trusted proxy IPs such as the cloudflare one
	// (such as https://www.cloudflare.com/ips-v4 and https://www.cloudflare.com/ips-v6)
	trusted_proxies? : string[];
	// An alternative to the above: use the cloudflare cf-connected-ip header
	// Note that this trusts the header from anyone so make sure non-cloudflare can't connect
	// can't use at the same time as the above
	use_cf_connected_ip? : boolean;
	
	openid_info? : {
		// This will probably be bab.yogstation.net
		origin: string,
		// basically put a {client_data: string, client_id: string} here
		client_data : ClientMetadata
	}
}