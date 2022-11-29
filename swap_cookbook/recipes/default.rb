# file "/home/ubuntu/hello.txt" do
#     content "Hello, this is my first cookbook recipe\n"
#     action :create
# end

swap_file 'swap' do
    path            "/swapfile"
    persist         true
    size            1024
    swappiness      0
    timeout         600
    action          :create
end
