# Chef
docker run -it --mount src="$(pwd)",target=/drop,type=bind chef/chefworkstation:latest /bin/bash  
cd /drop  
chef-solo -c solo.rb -j swap.json  

# Packer
packer init .  
packer validate -var 'source_ami=ami-0f53f393debb4c3c0' -var 'version=local' .  
packer build -var 'source_ami=ami-0f53f393debb4c3c0' -var 'version=local' .  

TODO:
1. Test main build with new AMI
1. Test PR build
1. Try Instance role instead of AWS creds in env var
1. Get version from text file
1. Check if AMI name exists before start build
1. Remove hardcoded vals from test task
1. Prettify stages
1. Dedicated pipeline for PR build (use feature branch)
