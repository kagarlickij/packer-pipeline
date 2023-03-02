# Chef
docker run -it --mount src="$(pwd)",target=/drop,type=bind chef/chefworkstation:latest /bin/bash  
cd /drop  
chef-solo -c solo.rb -j swap.json  

# Packer
packer init .  
packer validate -var 'source_ami=ami-0f53f393debb4c3c0' -var 'version=local' .  
packer build -var 'source_ami=ami-0f53f393debb4c3c0' -var 'version=local' .  
