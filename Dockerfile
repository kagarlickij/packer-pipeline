FROM centos:7

RUN yum update -y && \
    yum install wget -y

RUN wget -O- https://opscode.com/chef/install.sh | bash
