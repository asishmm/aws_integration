#!/usr/local/bin/perl
#
#Script to create amazon ec2 instance and get its ipaddress. We will be using Paws to spawn instances and get its IP address
#
use strict;
use warnings;
use Paws;
use Paws::EC2::CreateSecurityGroup;
use JSON;

# create aws instance
my $ec2 = Paws->service('EC2');
my $instance = $ec2->AllocateHosts(AvailabilityZone => 'us-east-1a' , InstanceType => 't2.micro', Quantity => 1);
# get ip address
my $ip_address = $instance->DescribeAddresses('public-ip');

#get instance id
my $ec2_id = $instance->DescribeAddress('instance-id');

# security group section
my $sec_group_name = 'sdkTestApp';
my $create_sg = $ec2->CreateSecurityGroup(Description => 'security group for flask-nginx-webapp' , GroupName => 'security_grp_name', Vpcld => $ec2_id);
my $group_id = $create_cg->DescribeSecurityGroups(GroupNames => [ $group_name ]);
my $result;
$result = $ec2->AuthorizeSecurityGroupIngress(GroupId => $group_id,IpProtocol => 'tcp',ToPort => 80, FromPort => 80,CidrIp => '0.0.0.0/0');
$result = $ec2->AuthorizeSecurityGroupIngress(GroupId => $group_id,IpPermissions => [ {IpProtocol => 'tcp',ToPort => 8080,FromPort => 8080,IpRanges => [ { CidrIp => '0.0.0.0/0' } ], }, {IpProtocol => 'tcp',ToPort => 443,FromPort => 443,IpRanges => [ { CidrIp => '0.0.0.0/0' } ], } ] );


#output ip address and instance-id to json file. Writing to data_bags which can be used in chef

my %output = ( 'id' => ec2_ip, 'public_ip' => $ip_address, 'instance_id' => $ec2_id ); 
my $json = encode_json \%output;
open my $fh, ">", "/tmp/ec2_ip.json";
print <$fh> $json;
close $fh;

