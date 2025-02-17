// MySandbox.tsx
import { defineComponent, readonly } from 'vue';
import { Sandbox, sandboxProps } from 'vitepress-plugin-sandpack';


/**
 * extends from Sandbox.
 * Compared to VUE single file, it is simple and straightforward.
 */
export default defineComponent({
  name: 'MySandbox',
  props: sandboxProps,
  setup(props, { slots }) {
    return () => (
      <Sandbox
        {...props}
        
        options={{
          showLineNumbers: true,
          infiniteLoopProtection: false,
          externalResources: ["https://github.com/lodinukal/cart/releases/download/v0.1.4/cart.wasm"]
        }}
        customSetup={{
          deps: {
            'cart-luau': 'latest',
          },
        }}
      >
        { slots?.default ? slots.default() : null }
      </Sandbox>
    );
  },
});