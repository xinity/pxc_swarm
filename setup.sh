#!/bin/bash

#Deploy RancherOS Virtual Machines and switch to latest Docker Engine available
for i in pxcm1 pxcw1 pxcw2 pxcw3;
    do docker-machine create -d virtualbox $i;
done

# initialize Swarm Manager and tokens
docker-machine ssh pxcm1 "docker swarm init \
        --listen-addr $(docker-machine ip pxcm1) \
            --advertise-addr $(docker-machine ip pxcm1)"

export worker_token=$(docker-machine ssh pxcm1 "docker swarm \
    join-token worker -q")

export manager_token=$(docker-machine ssh pxcm1 "docker swarm \
    join-token manager -q")

# initialize Swarm Workers and add them to the cluster

docker-machine ssh pxcw1 "docker swarm join \
        --token=${worker_token} \
            --listen-addr $(docker-machine ip pxcw1) \
                --advertise-addr $(docker-machine ip pxcw1) \
                    $(docker-machine ip pxcm1)"

docker-machine ssh pxcw2 "docker swarm join \
        --token=${worker_token} \
            --listen-addr $(docker-machine ip pxcw2) \
                --advertise-addr $(docker-machine ip pxcw2) \
                    $(docker-machine ip pxcm1)"

docker-machine ssh pxcw3 "docker swarm join \
        --token=${worker_token} \
            --listen-addr $(docker-machine ip pxcw3) \
                --advertise-addr $(docker-machine ip pxcw3) \
                    $(docker-machine ip pxcm1)"

