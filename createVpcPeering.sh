#!/bin/bash

# Global variables
REQUESTER_VPC_ID=<Requester VPC ID>
ACCEPTOR_OWNER_ID=<Acceptor Owner ID>
ACCEPTOR_VPC_ID=<Acceptor VPC ID>
ACCEPTOR_REGION=<Acceptor Region>

# To create a VPC peering connection
echo "Creating VPC-Peering Connection..."

awsResponse=$(aws ec2 create-vpc-peering-connection \
            --vpc-id $ACCEPTOR_VPC_ID \
            --peer-owner-id $ACCEPTOR_OWNER_ID\
            --peer-vpc-id $REQUESTER_VPC_ID \
            --peer-region $ACCEPTOR_REGION \
            --output json)


# Get VPC Connection Id 
VpcPeeringConnectionId=$(echo -e "$awsResponse" | \
                        jq '.VpcPeeringConnection.VpcPeeringConnectionId' | \
                        tr -d '"')

echo "Peering Connection Created.\n"
echo "VPC Peering Connection Id: $VpcPeeringConnectionId"