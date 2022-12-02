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
echo VpcPeeringConnectionId

# Tagging
aws ec2 create-tags \
		--resources "$VpcPeeringConnectionId" \
		--tags Key=Name,Value="Script-Peering-Test"

echo "Peering Connection Created.\n"
echo "VPC Peering Connection Id: $VpcPeeringConnectionId"

# Check if VPC Connection request is accepted or not.
while  [ "$peeringStatus" != "active" ]
do
    echo "Peering connection is not Active, Please accept "$VpcPeeringConnectionId" connection request."
    sleep 10
    awsDescribeResponse=$(aws ec2 describe-vpc-peering-connections \
                    --vpc-peering-connection-ids "$VpcPeeringConnectionId" \
                    --output json)
    
    peeringStatus=$(echo -e $awsDescribeResponse | \
            jq '.VpcPeeringConnections[].Status.Code' | \
            tr -d '"')  
done

# Check peering status
if [ "$peeringStatus" == "active" ]
then
    echo "Peering connection with  "$VpcPeeringConnectionId" is Active."
fi

sleep 5

# Getting Requester CIDR
requesterCidr=$(aws ec2 describe-vpc-peering-connections \
              --query 'VpcPeeringConnections[?VpcPeeringConnectionId==`'$VpcPeeringConnectionId'`].RequesterVpcInfo.CidrBlock' \
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
                         --destination-cidr-block $requesterCidr \
                         --vpc-peering-connection-id $VpcPeeringConnectionId)
done < temp.txt

# Clean temp file
rm temp.txt
sleep 2
echo "Routes Added."
