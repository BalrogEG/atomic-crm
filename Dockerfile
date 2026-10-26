FROM node:24-alpine AS build
WORKDIR /app
ENV HUSKY=0 CI=true PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
COPY package.json package-lock.json .npmrc ./
RUN npm ci --no-audit --no-fund
COPY . .
# Demo build = FakeRest in-memory data provider: no Supabase, no keys.
# rollup-plugin-visualizer tries to open a browser unless disabled.
RUN sed -i 's/open: process.env.NODE_ENV !== "CI"/open: false/' vite.demo.config.ts && \
    npx vite build --config vite.demo.config.ts

FROM node:24-alpine
RUN npm install -g serve@14.2.4
COPY --from=build /app/dist /srv/app
USER node
EXPOSE 3000
CMD ["serve", "-s", "/srv/app", "-l", "3000"]
