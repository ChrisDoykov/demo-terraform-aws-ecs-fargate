# Ingest some build time arguments with default values
# ARG NPM_TOKEN # If needed
ARG SERVICE_NAME='unknown-app'

FROM --platform=linux/amd64 node:18-alpine AS deps
# ARG NPM_TOKEN
# ENV NPM_TOKEN=$NPM_TOKEN
WORKDIR '/src'
RUN apk add --no-cache libc6-compat
COPY . .
RUN yarn install

FROM --platform=linux/amd64 node:18-alpine AS builder

WORKDIR /src
COPY --from=deps /src ./
# If needed you can add build instructions here like running `yarn build`, etc.

FROM --platform=linux/amd64 node:18-alpine AS runner
WORKDIR /src

ARG SERVICE_NAME

ENV NODE_ENV production
ENV SERVICE_NAME=$SERVICE_NAME

RUN addgroup --system --gid 1001 appgroup
RUN adduser --system --uid 1001 appuser

# As a best practice we only need to copy the necessary files, not everything
COPY --from=builder /src ./

USER appuser

EXPOSE 3000

ENV PORT 3000

CMD ["yarn", "start"]