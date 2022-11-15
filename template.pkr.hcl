packer {
  required_plugins {
    amazon = {
      version = ">= 1.1.5"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "test-packer-linux-aws-2"
  instance_type = "t2.micro"
  region        = "us-east-2"
  source_ami    = "ami-090f3f18d176e29f7"
  ssh_username = "ubuntu"
}

build {
  name = "test-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "cd /",
      "sudo dd if=/dev/zero of=/swapfile count=4096 bs=1MiB",
      "sudo chmod 600 /swapfile",
      "sudo mkswap /swapfile",
      "sudo swapon /swapfile",
      "echo '/swapfile   swap    swap    sw  0   0' | sudo tee -a /etc/fstab",
    ]
  }
}
