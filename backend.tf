terraform {
  backend "consul" {
    scheme = "http"
    path   = "terraform/remote-state/all-mzr.tfstate"
  }
}
