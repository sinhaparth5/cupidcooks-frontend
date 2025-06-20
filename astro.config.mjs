// @ts-check
import { defineConfig } from 'astro/config';

import node from '@astrojs/node';

// https://astro.build/config
export default defineConfig({
  output: 'server',
  adapter: node({
    mode: 'standalone'
  }),
  vite: {
    css: {
      preprocessorOptions: {
        scss: {
          includePaths: ['./src/styles'],
          outputStyle: 'compressed',
        },
      },
      minify: true,
      transform: {
        minify: true,
      },
    },
    build: {
      cssMinify: true,
    }
  }
});