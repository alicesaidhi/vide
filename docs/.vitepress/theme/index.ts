// .vitepress/theme/index.js
import DefaultTheme from 'vitepress/theme'
<<<<<<< HEAD
import layout from './layout.vue'
import { enhanceAppWithTabs } from 'vitepress-plugin-tabs/client'
=======
import { Sandbox } from 'vitepress-plugin-sandpack'
>>>>>>> 649db41 (add sandpack to documentation)
import './vars.css'
import './index.css'

import LuauSandbox from './luau.tsx';
import 'vitepress-plugin-sandpack/dist/style.css'

export default {
	extends: DefaultTheme,
<<<<<<< HEAD
	enhanceApp({ app }) {
		enhanceAppWithTabs(app)
	},
	Layout: layout
=======
	enhanceApp(ctx) {
		DefaultTheme.enhanceApp(ctx),
		ctx.app.component('Sandbox', Sandbox);
		ctx.app.component("LuauSandbox", LuauSandbox)
	}
>>>>>>> 649db41 (add sandpack to documentation)
}
