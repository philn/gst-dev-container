# Installation

As this image has been pushed to my dockerhub, you can download it:

```sh
$ toolbox create -c gst-dev --image docker.io/philn2/gst-dev:latest
```

# Local build

If you prefer to build it yourself:

```sh
$ podman build -t gst-dev:latest .
$ toolbox create -c gst-dev --image localhost/gst-dev:latest
```
