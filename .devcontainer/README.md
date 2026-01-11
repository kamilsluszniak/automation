# DevContainer Setup

This devcontainer works with both Docker and Podman.

## Prerequisites

- Docker or Podman installed
- If using Podman, ensure the socket is running: `systemctl --user start podman.socket`

## Using with Podman

Since Cursor expects Docker, you need to create a Docker-compatible socket. **Run this whenever you get a "permission denied" error:**

```bash
./.devcontainer/setup-podman-socket.sh
```

This creates a symlink from `/var/run/docker.sock` to Podman's socket, allowing Cursor to use Podman transparently.

**Note:** The symlink may get replaced if Docker or another service tries to create the socket. Just run the setup script again if you see permission errors.

Then:
1. Open the project in Cursor/VS Code
2. When prompted, select "Reopen in Container"
3. It should now work with Podman!

## Starting Services

Once in the devcontainer, you can start the API and worker:

### Start API Server
```bash
./.devcontainer/start-api.sh
```

### Start Worker
```bash
./.devcontainer/start-worker.sh
```

Or manually:
```bash
# API
bundle exec rails s -b 0.0.0.0 -p 3000

# Worker
bundle exec rake sneakers:run
```

## Services

The devcontainer includes:
- PostgreSQL (port 3317)
- RabbitMQ (port 5672)
- Redis (port 6379)
- InfluxDB (port 8086)

All services are automatically started when the devcontainer is created.
