#/bin/bash

alias t=talosctl
# alias docker=podman

t image default
docker run -d -p 5000:5000 --restart always --name registry-airgapped docker.io/library/registry:2
for image in `t image default` ; do docker pull $image ; done
for image in `t image default` ; do docker tag $image `echo $image | sed -E 's#^[^/]+/#127.0.0.1:5000/#'` ; done
for image in `t image default` ; do docker push `echo $image | sed -E 's#^[^/]+/#127.0.0.1:5000/#'` ; done