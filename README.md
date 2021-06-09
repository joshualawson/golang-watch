# Golang Watch

Docker image for building, running and debugging go code.
This image simply builds and runs your go code with the ability to debug it remotely with delve, it also has a file watcher
which will rebuild your project code if any *.go files are changed.

## Usage

Delve remote needs to be exposed via port `40000`

An environment variable is availabe to cause your project to run as soon as the container spins up or you can have it wait
for a connection from delve. By default the binary is executed automatically. To disable this set `RUN_ON_START` to false.

You must mount your go code to `/src` in the docker container

```shell
$ docker run -v /my/gocode/location:/src -p 40000:40000 -e RUN_ON_START=false --name=golang joshualawson/golang
```