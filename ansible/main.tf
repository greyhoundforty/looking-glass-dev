resource "local_file" "ansible-inventory" {
  content = templatefile("${path.module}/templates/inventory.tmpl",
    {
      instances = var.instances
    }
  )
  filename = "${path.module}/${var.workspace}-inventory"
}