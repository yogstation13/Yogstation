import rimraf from "rimraf";
import typescript from '@rollup/plugin-typescript';
import htmlPlugin from "./lib/html.js";
import nodeResolve from "@rollup/plugin-node-resolve";
import pnpResolve from "rollup-plugin-pnp-resolve";
import postcss from 'rollup-plugin-postcss';
import terser from "@rollup/plugin-terser";
import {readFileSync} from "fs";
import commonjs from "@rollup/plugin-commonjs";
import json from "@rollup/plugin-json";

rimraf.sync("dist");

/**
 * @type {import('rollup').RollupOptions}
 */
const config = [
	{
		input: "src/client/browserfill.ts",
		output: {
			dir: "dist/res",
			entryFileNames: "[name].js",
			format: "iife",
		},
		plugins: [
			typescript(),
			terser()
		]
	},
	{
		input:
		{
			main: "src/client/index.ts"
		},
		output: {
			dir: "dist/res",
			chunkFileNames: "[name]-[hash].js",
			entryFileNames: "[name]-[hash].js",
			format: "iife"
		},
		plugins: [
			typescript(),
			pnpResolve(),
			nodeResolve(),
			postcss(),
			//OMT(),
			htmlPlugin(),
			terser(),
			{
				name: 'files-plugin',
				buildStart() {
					this.addWatchFile('CNAME');
				},
				async generateBundle(options, bundle) {
					this.emitFile({
						fileName: 'favicon.ico',
						type: 'asset',
						source: readFileSync('favicon.ico')
					});
				}
			}
		]
	},{
		input:
		{
			proxy: "src/proxy/index.ts"
		},
		output: {
			dir: "dist",
			chunkFileNames: "[name]-[hash].js",
			entryFileNames: "[name].js",
			format: "esm"
		},
		plugins: [
			typescript(),
			json(),
			pnpResolve(),
			nodeResolve(),
			commonjs()
		],
		external: ["express", "openid-client", "ws","node-fetch", "ip-matching"]
	}
];
export default config;

