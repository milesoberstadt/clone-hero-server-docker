# clone-hero-server 🎸 🥁 🐳

Docker image for Clone Hero dedicated server software. Available on [Docker Hub](https://hub.docker.com/r/corysanin/clone-hero-server).

```$ docker run --rm -p 14242:14242 corysanin/clone-hero-server:latest```

The Docker image exposes port 14242 for network communication by default. This can be configured in `settings.ini`

`settings.ini` is stored in `/usr/src/config`. So if you want to modify it, create a `config` directory and use:

```$ docker run --rm -p 14242:14242 -v $(pwd)/config:/usr/src/config corysanin/clone-hero-server:latest```