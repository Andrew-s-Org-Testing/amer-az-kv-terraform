module "kv_amer_label" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a"
  delimiter = "-"

  namespace   = "avt"                        #organization #always same
  stage       = var.stage                    #environment #variablej
  environment = var.geo_region               #region #variable
  tenant      = var.service_area             #variable
  name        = "${var.application_name}-kv" #name-service-azure-resource-type
  attributes  = var.additional_suffixes      #index, if we want #not needed for now

  label_order     = ["namespace", "environment", "stage", "tenant", "name", "attributes"]
  id_length_limit = 24

  tags = local.common_tags
}
