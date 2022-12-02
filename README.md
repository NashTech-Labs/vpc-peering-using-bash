# vpc-peering-using-bash

This repository contains scripts to perform VPC peering between two VPCs. Both VPCs can be in same region, differentregion and different account.

-------------

**Files:** 
```
      1. requesterVpcPeering.sh
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