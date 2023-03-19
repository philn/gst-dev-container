# Installation

As this image has been pushed to my dockerhub, you can download it:

```sh
$ toolbox create -c gst-dev-f38 --image docker.io/philn2/gst-dev:f38
```

# Local build

If you prefer to build it yourself:

```sh
$ podman build -t gst-dev:f38 .
$ toolbox create -c gst-dev-f38 --image localhost/gst-dev:f38
```
