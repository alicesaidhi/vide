// .vitepress/theme/index.js
import DefaultTheme from 'vitepress/theme'
import { Sandbox } from 'vitepress-plugin-sandpack'
import './vars.css'
import './index.css'

import LuauSandbox from './luau.tsx';
import 'vitepress-plugin-sandpack/dist/style.css'

export default {
	extends: DefaultTheme,
	enhanceApp(ctx) {
		DefaultTheme.enhanceApp(ctx),
		ctx.app.component('Sandbox', Sandbox);
		ctx.app.component("LuauSandbox", LuauSandbox)
	}
}
