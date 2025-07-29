locals {
  # User data script for webserver setup
  webserver_user_data = var.role == "webserver" ? templatefile("${path.module}/templates/webserver.tftpl", {
    webserver_type = var.webserver_type
    http_port      = var.http_port
  }) : ""

  # User data script for CloudWatch agent
  cloudwatch_user_data = var.enable_cw_logs ? templatefile("${path.module}/templates/cloudwatch.tftpl", {}) : ""

  # Combined user data script (plain text)
  user_data_script = join("\n", compact([
    local.webserver_user_data,
    local.cloudwatch_user_data
  ]))
}
