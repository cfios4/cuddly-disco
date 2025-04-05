#!/bin/bash
# set -x
# rm *yaml talosconfig patches/*yaml

export CLUSTER_NAME="t3s"
export CLUSTER_CP_RANGE=$(echo 192.168.45.{51..53})
export CLUSTER_W_RANGE=$(echo 192.168.45.{54..56})
export T_VIP=192.168.45.$(( ${CLUSTER_W_RANGE##*.} + 1 )) # yikes but this is just +1 of the last worker
export S_VIP=192.168.45.$(( ${CLUSTER_W_RANGE##*.} + 2 )) # T for talos, S for service
export AIRGAP="false"
export REGISTRY=192.168.45.140
export INSTALL_DEV="/dev/mmcblk0"
export ADDITIONAL_DISK="/dev/nvme0n1"
export ADD_DISK_MP="/var/mnt/appdata"

# Simple check if using Turing Pi + RK1s and perform specific tasks for them
if [ "$INSTALL_DEV" = "/dev/mmcblk0" ] ; then
        for node in 1 2 3 4 ; do 
                tpi --host tpi.lan --user root --password turing flash --local --image-path /mnt/sdcard/metal-arm64.raw -n $node
        done

        until tpi --host tpi.lan --user root --password turing power on ; do 
                sleep 2
        done
fi

for m in `find manifests/ -type f -name "*.yaml.tmpl" ; do
        envsubst < $m > $(dirname $m)/$(basename $m .tmpl)
done

for p in patches/tmpl/* ; do 
        envsubst < $p > patches/$(basename $p)
done

if [ "$AIRGAP" = "true" ] ; then
        talosctl gen config --config-patch-control-plane @patches/control-patch.yaml --config-patch-worker @patches/worker-patch.yaml --config-patch @patches/airgap.yaml --force $CLUSTER_NAME https://$T_VIP:6443
else
        talosctl gen config --config-patch-control-plane @patches/control-patch.yaml --config-patch-worker @patches/worker-patch.yaml --force $CLUSTER_NAME https://$T_VIP:6443
fi

until ping -c 1 -W 1 rk1-1.lan > /dev/null 2>&1 ; do
        echo "Waiting for Node 1..."
        sleep 2
done

echo "Node 1 online. Assuming Cluster is also."

for node in $CLUSTER_CP_RANGE ; do
        until talosctl apply -f controlplane.yaml -n $node -e $T_VIP -i ; do
                echo "Applying control planes..."
                sleep 2
        done
done

for node in $CLUSTER_W_RANGE ; do
        until talosctl apply -f worker.yaml -n 192.168.45.54 -e $T_VIP -i ; do
                echo "Applying worker..."
                sleep 2
        done
done

until talosctl bootstrap -n 192.168.45.51 -e 192.168.45.51 > /dev/null 2>&1 ; do
        sleep 2
done

export TALOSCONFIG=`pwd`/talosconfig
talosctl config endpoint $T_VIP
until talosctl kubeconfig -n 192.168.45.51 -f && kubectl get nodes ; do
        sleep 2
done

#<!-- talosctl dashboard -n ${TALOS_NODES[@]} -->
#<!-- talosctl reset -n ${TALOS_NODES[@]} #-->