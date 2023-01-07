export function despam_promise<A extends unknown[], R>(target : (...args : A) => Promise<R>) {
	let _resolves : Array<(val : R) => void> = [];
	let _rejects : Array<(err : any) => void> = [];
	let _next_call : A|undefined;
	let _busy = false;

	async function _flush() : Promise<void> {
		if(_busy) return;
		_busy = true;
		while(_next_call) {
			let call = _next_call;
			_next_call = undefined;
			let resolves = _resolves;
			_resolves = [];
			let rejects = _rejects;
			_rejects = [];
			try { 
				let val = await target(...call);
				for(let resolve of resolves) {
					resolve(val);
				}
			} catch(e) {
				for(let reject of rejects) {
					reject(e);
				}
			}
		}
		_busy = false;
	}

	return function invoke(...args : A) : Promise<R> {
		return new Promise(async (resolve, reject) => {
			_next_call = args;
			_resolves.push(resolve);
			_rejects.push(reject);
			_flush();
		});
	}
}
