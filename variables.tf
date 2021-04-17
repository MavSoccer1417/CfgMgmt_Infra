variable "ingressrules" {
  type    = list(number)
  default = [80, 8080, 443, 22]
}
