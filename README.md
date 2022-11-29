# Chef
docker run -it --mount src="$(pwd)",target=/drop,type=bind chef/chefworkstation:latest /bin/bash  
cd /drop  
chef-solo -c solo.rb -j swap.json  

# Packer
packer init .  
packer validate -var 'source_ami=ami-0cc841fc27393aabc' -var 'version=local' .  
packer build -var 'source_ami=ami-0cc841fc27393aabc' -var 'version=local' .  
