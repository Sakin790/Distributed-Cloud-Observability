
resource "aws_vpc" "monitoring_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { 
    Name = "Monitoring-VPC" 
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.monitoring_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { 
    Name = "Monitoring-Subnet" 
  }
}

resource "aws_internet_gw" "gw" {
  vpc_id = aws_vpc.monitoring_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.monitoring_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gw.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# ==========================================
# সিকিউরিটি গ্রুপ: প্যারেন্ট সার্ভার (সার্ভার ৬)
# ==========================================
resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring_server_sg"
  description = "Allow secure access to parent monitoring node"
  vpc_id      = aws_vpc.monitoring_vpc.id

  # SSH অ্যাক্সেস (শুধুমাত্র আপনার নিজের আইপি থেকে)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Grafana UI (পোর্ট ৩০০০ - ড্যাশবোর্ড দেখার জন্য)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # Prometheus UI (পোর্ট ৯০৯০ - মেট্রিক চেক করার জন্য)
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # OTLP gRPC Receiver (পোর্ট ৪৩১৭ - চাইল্ড সার্ভার থেকে ডেটা রিসিভ করতে)
  ingress {
    from_port   = 4317
    to_port     = 4317
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"] # শুধুমাত্র ভিভিসি সাবনেট অ্যালাউড
  }

  # OTLP HTTP Receiver (পোর্ট ৪৩১৮ - এইচটিটিপি ডেটা রিসিভ করতে)
  ingress {
    from_port   = 4318
    to_port     = 4318
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  # Prometheus Exporter Port (পোর্ট ৮৮৮৯ - ওটিইএল থেকে প্রমিথিউসে ডেটা টানার জন্য লোকালহোস্ট কমিউনিকেশন)
  ingress {
    from_port   = 8889
    to_port     = 8889
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  # ইন্টারনেট কানেক্টিভিটি (প্যাকেজ ডাউনলোড ও আপডেটের জন্য)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==========================================
# সিকিউরিটি গ্রুপ: চাইল্ড সার্ভার (সার্ভার ১-৫)
# ==========================================
resource "aws_security_group" "app_sg" {
  name        = "app_servers_sg"
  description = "Security group for child application nodes"
  vpc_id      = aws_vpc.monitoring_vpc.id

  # SSH অ্যাক্সেস (শুধুমাত্র আপনার নিজের আইপি থেকে)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # আউটবাউন্ড ট্রাফিক: প্যারেন্ট সার্ভারে OTLP ডেটা পুশ করার জন্য পোর্ট ৪৩১৭ ও ৪৩১৮ ওপেন
  egress {
    from_port   = 4317
    to_port     = 4318
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"] # প্যারেন্ট সার্ভারের প্রাইভেট সাবনেট
  }

  # ইন্টারনেট কানেক্টিভিটি (সফটওয়্যার ডাউনলোড ও আপডেটের জন্য)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}