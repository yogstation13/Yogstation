export function promise_queue<A extends unknown[], R>(target : (...args : A) => Promise<R>, max_concurrent = 30) {
	let _num_remaining = max_concurrent;
	let _waiting : [A, (val : R) => void, (val : A) => void][] = [];

	return function invoke(...args : A) : Promise<R> {
		if(_num_remaining > 0) {
			_num_remaining--;
			let promise = target(...args);
			promise.finally(() => {
				_num_remaining++;
				let next = _waiting.shift()
				if(next) invoke(...next[0]).then(next[1], next[2]);
			});
			return promise;
		}
		return new Promise((resolve, reject) => {
			_waiting.push([args, resolve, reject]);
		});
	}
}

export function queued_invoke<T>(max_concurrent : number) : (func : () => Promise<T>) => Promise<T> {
	return promise_queue((func : () => Promise<T>) => {
		return func();
	});
}
