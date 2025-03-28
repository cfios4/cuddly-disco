#!/bin/bash
# set -x
# rm *yaml talosconfig patches/*yaml

export CLUSTER_NAME="t3s"
export VIP=192.168.45.59
export REGISTRY=192.168.45.140
export INSTALL_DEV="/dev/mmcblk0"
export ADDITIONAL_DISK="/dev/nvme0n1"
export ADD_DISK_MP="/var/mnt/appdata"

for node in 1 2 3 4 ; do tpi --host tpi.lan --user root --password turing flash --local --image-path /mnt/sdcard/metal-arm64.raw -n $node ; done
until tpi --host tpi.lan --user root --password turing power on ; do sleep 2 ; done

for p in patches/tmpl/* ; do envsubst < $p > patches/$(basename $p) ; done
talosctl gen config --config-patch-control-plane @patches/control-patch.yaml --config-patch-worker @patches/worker-patch.yaml --force $CLUSTER_NAME https://$VIP:6443
# talosctl gen config --config-patch-control-plane @patches/control-patch.yaml --config-patch-worker @patches/worker-patch.yaml --config-patch @patches/airgap.yaml --force $CLUSTER_NAME https://$VIP:6443

until ping -c 1 -W 1 rk1-1.lan > /dev/null 2>&1 ; do
        echo "Waiting for Node 1..."
        sleep 2
done

for node in 192.168.45.{51..53} ; do
        until talosctl apply -f controlplane.yaml -n $node -e $VIP -i ; do
                echo "Applying control planes..."
                sleep 2
        done

        until talosctl apply -f worker.yaml -n 192.168.45.54 -e $VIP -i ; do
                echo "Applying worker..."
                sleep 2
        done
done

until talosctl bootstrap -n 192.168.45.51 -e 192.168.45.51 ; do
        sleep 2
done

export TALOSCONFIG=`pwd`/talosconfig
talosctl config endpoint $VIP
until talosctl kubeconfig -n 192.168.45.51 -f && kubectl get nodes ; do
        sleep 2
done

#<!-- talosctl dashboard -n ${TALOS_NODES[@]} -->
#<!-- talosctl reset -n ${TALOS_NODES[@]} #-->