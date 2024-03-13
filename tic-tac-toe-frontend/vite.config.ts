import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  server: {
    port: 8080,
    proxy: {
        '/api': {
            target: 'http://localhost:8081',
            changeOrigin: true,
            rewrite: (path) => path.replace(/^\/api/, '')
        }
    },
    strictPort: true,
    host: true,
    origin: "http://0.0.0.0:8080",
  },
  base: "/",
  plugins: [react()],
  preview: {
    port: 8080,
    strictPort: true,
  },
})