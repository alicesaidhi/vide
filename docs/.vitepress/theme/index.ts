// .vitepress/theme/index.js
import DefaultTheme from 'vitepress/theme'
import layout from './layout.vue'
import './vars.css'
import './index.css'

import LuauSandbox from './luau.tsx';
import 'vitepress-plugin-sandpack/dist/style.css'
import { enhanceAppWithTabs } from 'vitepress-plugin-tabs/client'

export default {
	extends: DefaultTheme,
	enhanceApp(ctx) {
		enhanceAppWithTabs(ctx.app)
		DefaultTheme.enhanceApp(ctx),
		ctx.app.component("LuauSandbox", LuauSandbox)
	}
}
