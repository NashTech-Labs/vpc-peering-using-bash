#!/bin/bash

# Golbal Variables
REQUESTER_VPC_ID=<Requester VPC ID>
ACCEPTOR_OWNER_ID=<Acceptor Owner ID>
ACCEPTOR_VPC_ID=<Acceptor VPC ID>
ACCEPTOR_REGION=<Acceptor Region>


function updateRouteTable()
{
    # Describe VPC peering request
    awsDescribeResponse=$(aws ec2 describe-vpc-peering-connections \
        --vpc-peering-connection-ids "$VpcPeeringConnectionId" \
        --output json)
    
    peeringStatus=$(echo -e $awsDescribeResponse | \
        jq '.VpcPeeringConnections[].Status.Code' | \
        tr -d '"')
    
    # Getting Acceptor CIDR
    acceptorCidr=$(aws ec2 describe-vpc-peering-connections \
        --query 'VpcPeeringConnections[?VpcPeeringConnectionId==`'$VpcPeeringConnectionId'`].AccepterVpcInfo.CidrBlock' \
        --output text)
    
    
    # Get list of route tables for requester
    associatedRouteTable=$(aws ec2 describe-route-tables \
        --filters "Name=vpc-id,Values=$REQUESTER_VPC_ID" \
        --query 'RouteTables[*].Associations[*].RouteTableId' \
        --output text)
    
    # Save respone to temp.txt
    echo $associatedRouteTable | tr ' ' '\n'>temp.txt
    
    # Add peering route to all subnet route tables
    echo "Updating Routes in Route Table..."
    while read routeTableId
    do
        awsCreateRTResponse=$(aws ec2 create-route --route-table-id $routeTableId \
            --destination-cidr-block $acceptorCidr \
            --vpc-peering-connection-id $VpcPeeringConnectionId)
    done < temp.txt
    
    # Clean temp file
    rm temp.txt
    sleep 2
    echo "Routes Added."
}

awsDescribeResponse=$(aws ec2 describe-vpc-peering-connections \
    --filters "Name=status-code,Values=pending-acceptance,active" \
    "Name=requester-vpc-info.vpc-id,Values=$REQUESTER_VPC_ID"  \
    --output json)

echo $awsDescribeResponse

peeringStatus=$(echo -e $awsDescribeResponse | \
    jq '.VpcPeeringConnections[].Status.Code' | \
    tr -d '"')

# Get VPC Connection Id
VpcPeeringConnectionId=$(echo -e "$awsDescribeResponse" | \
    jq '.VpcPeeringConnections[].VpcPeeringConnectionId' | \
    tr -d '"')

echo $VpcPeeringConnectionId

# Accepting peering request
if [ "$peeringStatus" == "pending-acceptance" ]
then
    awsAcceptResponse=$(aws ec2 accept-vpc-peering-connection \
        --vpc-peering-connection-id $VpcPeeringConnectionId)
    echo "Peering connection with  id="$VpcPeeringConnectionId" is Active."
    updateRouteTable
elif [ "$peeringStatus" == "active" ]
then
    echo "Peering connection with id="$VpcPeeringConnectionId" is already Active."
    exit code 1
fi
