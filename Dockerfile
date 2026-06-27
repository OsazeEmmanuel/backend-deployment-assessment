# ---------- Builder Stage ----------
FROM golang:1.25-bookworm AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -o muchtodo ./cmd/api

# ---------- Runtime Stage ----------
FROM alpine:latest

RUN apk add --no-cache ca-certificates wget

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /app/muchtodo .

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
CMD wget --spider -q http://localhost:8080/health || exit 1

USER appuser

ENTRYPOINT ["./muchtodo"]
