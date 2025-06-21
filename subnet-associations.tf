// 5 subnet associations

// associate the 2 subnets with 2 route tables

resource "aws_route_table_association" "create_route_table_association" {
    count = length(var.gives_cidr_to_subnets)

    subnet_id      = aws_subnet.create_subnet[count.index].id
    route_table_id = aws_route_table.create_route_table[count.index].id  // Assuming both subnets use the first route table

}



