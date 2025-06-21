// 4 creating 2 route tables and associating them with the vpc and internet gateway

resource "aws_route_table" "create_route_table" {
    count = 2
    vpc_id = aws_vpc.create_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.create_igw.id
    }

    tags = {
        Name = "public-RT-table-${count.index + 1}"
    }
}


