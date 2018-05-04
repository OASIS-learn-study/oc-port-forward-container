# Container to oc port-forward with OpenShift

## Usage

    docker build . -t oc-port-forward-container

    docker run --rm -e "OC_LOGIN=..." -e "OC_PORT_FORWARD_POD_NAME_PREFIX=..." -p 25565:25564 oc-port-forward-container

    docker run --rm -it oc-port-forward-container bash


## Implementation

We run `oc port-forward` inside this container.  It listens (only) on interface	`localhost` (`127.0.0.1` / `[::1]`).
We also use `socat` in this container to forward port 25564 on the container's interface `eth0` (which is `EXPOSE`d)
to the port 25565 on interface `localhost` (`127.0.0.1` / `[::1]`) of the container.

We then `-p` map port 25565 on the host to port 25564 of the container - which internally gets forwarded to port 25565.

Makes sense? ;-)


## Background and why it does not "just" work...

* oc port-forward only binds to 127.0.0.1 (and [::1]) instead of all interfaces, so you cannot connect (only from within container as localhost, which renders it useless)
** https://github.com/kubernetes/kubernetes/issues/43962
** https://bugzilla.redhat.com/show_bug.cgi?id=1461477 (that's actually the opposite problem?)
* frequently (7' ?) disconnects due to _E0504 21:17:15.946179      29 portforward.go:178] lost connection to pod_
** https://bugzilla.redhat.com/show_bug.cgi?id=1382730 ?
** https://github.com/kubernetes/kubernetes/issues/19231
* used to have concurrency issues, but apparently fixed now?
** https://github.com/openshift/origin/issues/4287

Alternatives?

* iptables based port forward inside the container ... requires `--privileged` (`--cap-add=NET_ADMIN`), and that's No Go
** `# iptables -t nat -A PREROUTING -p tcp -i eth0 --dst 127.0.0.1 --dport 25565 -j REDIRECT --to-ports 25565` ???
*** `iptables v1.4.21: can't initialize iptables table `nat': Permission denied (you must be root)`
*** `Perhaps iptables or your kernel needs to be upgraded.`
* WebSocket instead SPDY: https://github.com/kubernetes/kubernetes/pull/33684
** supported in Java client: https://github.com/kubernetes-client/java/pull/91
