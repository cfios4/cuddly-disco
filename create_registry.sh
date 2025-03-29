#/bin/bash

alias t=talosctl
# alias docker=podman

# create local registry
docker run -d -p 5000:5000 --restart always --name registry-airgapped docker.io/library/registry:2
# mirror talos images
for image in `t image default` ; do
    docker pull $image
    docker tag $image `echo $image | sed -E 's#^[^/]+/#localhost:5000/#'`
    docker push `echo $image | sed -E 's#^[^/]+/#localhost:5000/#'`
done
# mirror images used in manifests/
for image in `grep "image: " manifests/* | awk -F 'image: ' '{print $2}'` ; do 
    docker pull $image 
    docker tag $image `echo $image | sed -E 's#^[^/]+/#localhost:5000/#'` 
    docker push `echo $image | sed -E 's#^[^/]+/#localhost:5000/#'`
done