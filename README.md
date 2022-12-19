# vpc-peering-using-bash

This repository contains scripts to perform VPC peering between two VPCs. Both VPCs can be in same region, different region and different account. This script also updates the route table of both VPCs. 

The acceptorVpcPeering.sh is the script used to accepting peering request and update the route table on acceptor side. To run acceptor first we need to have a request for VPC peering which can be created with requesterVpcPeering.sh script

-------------

**Files:** 
```
      1. requesterVpcPeering.sh
      2. acceptorVpcPeering.sh
```

## How to run the above scripts

1. First configure the aws credentials on whatever machine you want to run the script by running the below command.

    ```
    aws configure
    ```

2. Now, from the current directory run the following command according to your need. Please update variables like `REQUESTER_VPC_ID`, `ACCEPTOR_OWNER_ID`, `ACCEPTOR_VPC_ID`, `ACCEPTOR_REGION` before use.

    To provide execution permission:
    ```
    sudo chmod +x requesterVpcPeering.sh
    ```

    To run the script:
    ```
    ./requesterVpcPeering.sh
    ```
3. To run acceptorVpcPeering.sh script, first run requesterVpcPeering.sh script. Please update variables like `REQUESTER_VPC_ID`, `ACCEPTOR_OWNER_ID`, `ACCEPTOR_VPC_ID`, `ACCEPTOR_REGION` before use.

    To provide execution permission:
    ```
    sudo chmod +x acceptorVpcPeering.sh
    ```

    To run the script:
    ```
    ./acceptorVpcPeering.sh
    ```