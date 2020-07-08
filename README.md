# Cloudformation plus bash to create ami with docker

## Instructions
1. Install the aws cli.
2. Creat an aws account. 
3. Creat a group and a user to get an access key id and a secret access key
4. Create an s3 bucket.
5. Fill out the vars.env with the gathered information.
6. Run buildBaseAmi.sh

To delete:
1. Run deleteBaseAmi.sh

# TODO in the future
1. Add cloudformation to create the s3 bucket. Edit the build and delete scripts to bring it up and tear it down.
2. Cloudformation to create the group, user, and required policies that can be run manually before running the build script. Don't know how much of this is possible.