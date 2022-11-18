#!/bin/bash

# Global variables
REQUESTER_VPC_ID='vpc-0eb87ba7da509ddad'
ACCEPTOR_OWNER_ID='391180499744'
ACCEPTOR_VPC_ID='vpc-02413614c5554d9d3'
ACCEPTOR_REGION='ap-south-1'

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