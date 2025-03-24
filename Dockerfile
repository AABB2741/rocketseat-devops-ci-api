FROM node:20-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

WORKDIR /usr/src/app
COPY . .

# ----------

FROM base AS build

RUN pnpm install --frozen-lockfile
RUN pnpm build
RUN pnpm prune --prod

# ----------

FROM base AS deploy

RUN pnpm install -g @nestjs/cli
COPY --from=build /usr/src/app/node_modules /usr/src/app/node_modules
COPY --from=build /usr/src/app/dist /usr/src/app/dist
EXPOSE 3000
CMD [ "pnpm", "start" ]
