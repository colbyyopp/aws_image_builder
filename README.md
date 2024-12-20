## Description
This codebase utilizes the EC2 Image Builder resource in AWS to create custom AMIs

## Roles
Iam role - image builder  - needed to access the ec2 instance building the image
Policy attachments - SSM & image builder policies for the role
Instance profile - references the role to provide permissions to the instance - needed in imagebuilder_infrastructure_configuration

## Image Builder
Component - installations for the image - user_data
Recipe - AMI, EBS
Infrastruture - where the instance building the image will be created
Pipeline - how and when image should be created - automated creation based on schedule or events - version management - can test and auto deploy images
Image - builds an image immediately

Note: removing the aws_imagebuilder_image block will destroy the created image in AWS

## VPC
Subnet - for the instance - needed in imagebuilder_infrastructure_configuration
Route table - for IGW
IGW - needed to communicate to internet for package installations
SG - inbound for SSM/outbound to internet for installations - needed in imagebuilder_infrastructure_configuration