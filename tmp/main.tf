locals {
  colors = ["blue", "green", "red"]
}

resource "local_file" "count_loop" {
  count    = length(local.colors)
  content  = local.colors[count.index]
  filename = "${path.module}/${local.colors[count.index]}.count"
}
