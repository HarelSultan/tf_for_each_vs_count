locals {
  colors = ["brown","blue", "yellow", "green", "red"]
}

resource "local_file" "for_each_loop" {
  for_each = toset(local.colors)
  content  = each.value
  filename = "${path.module}/${each.value}.count"
}
