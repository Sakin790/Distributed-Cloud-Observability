# ==========================================
# ১. সার্ভার ৬ (Monitoring/Central Node)
# ==========================================
resource "aws_instance" "monitoring_node" {
  ami                    = var.ami_id
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  key_name               = "YOUR_KEY_PAIR_NAME" # আপনার কি-পেয়ারের নাম দিন

  # ৬ নম্বর সার্ভারের Systemd ব্যাশ স্ক্রিপ্ট কল করা হলো
  user_data = file("${path.module}/scripts/server_6_monitoring.sh")

  tags = {
    Name = "Monitoring-Central-Node"
  }
}

# ==========================================
# ২. সার্ভার ১ থেকে ৫ (Application Nodes)
# ==========================================
resource "aws_instance" "app_nodes" {
  count                  = 5
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = "YOUR_KEY_PAIR_NAME" # আপনার কি-পেয়ারের নাম দিন

  # ৬ নম্বর সার্ভার তৈরি হওয়া নিশ্চিত করতে 'depends_on' ব্যবহার করা হলো
  depends_on = [aws_instance.monitoring_node]

  # ইনস্ট্যান্স বুট হওয়ার সময় ওটিইএল কালেক্টর ডাউনলোড, ইন্সটল এবং টেমপ্লেট কনফিগারেশন রান করবে
  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -e
              sudo apt-get update -y
              sudo apt-get install -y wget curl

              # OTel Collector ইনস্টল
              OTEL_VER="0.95.0"
              wget https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v$${OTEL_VER}/otelcol_v$${OTEL_VER}_linux_amd64.deb
              sudo dpkg -i otelcol_v$${OTEL_VER}_linux_amd64.deb

              sudo mkdir -p /etc/otelcol

              # ডায়নামিক কনফিগারেশন ফাইল তৈরি করা হচ্ছে, যেখানে প্যারেন্ট সার্ভারের প্রাইভেট আইপি ইনজেক্ট হচ্ছে
              cat << 'CONFIG_EOF' > /etc/otelcol/config.yaml
              ${templatefile("${path.module}/templates/otel-config.yaml.tftpl", { monitoring_private_ip = aws_instance.monitoring_node.private_ip })}
              CONFIG_EOF

              sudo chown -R otelcol:otelcol /etc/otelcol
              sudo systemctl daemon-reload
              sudo systemctl enable otelcol
              sudo systemctl restart otelcol
              EOF
  )

  tags = {
    Name = "App-Node-${count.index + 1}"
  }
}