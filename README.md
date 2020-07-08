# Create AWS AMI with Docker installed and running
Uses cloudformation and aws cli v2.

## Instructions to build the ami:
1. Install the aws cli.
2. Create an aws account. 
3. Create a group and a user to get an access key id and a secret access key
4. Fill out the vars.env with the gathered information.
5. Run buildBaseAmi.sh

## Instruction to delete the ami:
1. Run deleteBaseAmi.sh

### TODO in the future:
- Specify policies and permissions for the group the user is in should have for this to work.
- Cloudformation to create the group, user, and required policies that can be run manually before running the build script. Don't know how much of this is possible.
- Make the created s3 bucket private on creation
- Maybe move this whole thing into a docker image that you can just run that to build this. Would make the only requirement be docker instead of aws cli. Might be overkill.