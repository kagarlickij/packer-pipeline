remote_file '/tmp/awscli-exe-linux-x86_64.zip' do
    source "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
end

archive_file 'awscli-exe-linux-x86_64.zip' do
    path '/tmp/awscli-exe-linux-x86_64.zip'
    destination '/tmp/awscli-exe-linux-x86_64'
end

execute 'aws/install' do
    command '/tmp/awscli-exe-linux-x86_64/aws/install'
end
