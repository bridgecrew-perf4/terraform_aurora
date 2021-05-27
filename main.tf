resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "dev-vpc"
    }
}
#Public Subnet
resource "aws_subnet" "public-a" {
    vpc_id              = "${aws_vpc.vpc.id}"
    cidr_block          = "10.0.1.0/24"
    availability_zone   = "us-east-2a"
    tags = {
        Name = "pub-a"
    }
}
#Private Subnet
resource "aws_subnet" "private-a" {
    vpc_id              = "${aws_vpc.vpc.id}"
    cidr_block          = "10.0.2.0/24"
    availability_zone   = "us-east-2a"
    tags = {
        Name = "priv-a"
    }
}
resource "aws_eip" "ngw" {
    vpc = true
}
resource "aws_internet_gateway" "igw" {
    vpc_id  = "${aws_vpc.vpc.id}"
    tags = {
        Name = "igw"
    }
}
resource "aws_nat_gateway" "ngw" {
    allocation_id   = "${aws_eip.ngw.id}"
    subnet_id       = "${aws_subnet.public-a.id}"
    tags = {
        Name = "ngw"
    }
}
# Public用ルートテーブル
resource "aws_route_table" "public-a" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        gateway_id = "${aws_internet_gateway.igw.id}"
        cidr_block = "0.0.0.0/0"
    }
    tags = {
        Name = "rtb-pub"
    }
}
resource "aws_route_table_association" "public-a" {
    subnet_id       = "${aws_subnet.public-a.id}"
    route_table_id  = "${aws_route_table.public-a.id}"
}
# Private用ルートテーブル
resource "aws_route_table" "private-a" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        gateway_id = "${aws_internet_gateway.igw.id}"
        cidr_block = "0.0.0.0/0"
    }
    tags = {
        Name = "rtb-priv"
    }
}
resource "aws_route_table_association" "private-a" {
    subnet_id       = aws_subnet.public-a.id
    route_table_id  = aws_route_table.public-a.id
}
resource "aws_rds_cluster" "default" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.03.2"
  availability_zones      = ["us-west-2a", "us-west-2b", "us-west-2c"]
  database_name           = "mydb"
  master_username         = "foo"
  master_password         = "bar"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
}
