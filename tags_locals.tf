locals {
  common_tags = {
    ApplicationName  = var.application_name
    BillToDepartment = var.bill_to_department
    Project          = var.project
    Entity           = var.entity
    GeoRegion        = var.geo_region
    Tier = var.stage == "prd" ? "PROD" : (var.stage == "dev" ? "DEV" :
      (var.stage == "tst" ? "TEST" :
        (var.stage == "qa" ? "QA" :
          (var.stage == "sbox" ? "SANDBOX" :
    (var.stage == "dr" ? "DR" : "Unassigned")))))

    CostCenter = var.cost_center
    DeployedBy = var.deployed_by
  }
}

#Tier tag needs to be calculated based on stage, but stage is lowercase 3 letter code
#and Tier has to be one of Unassigned PROD DEV TEST QA SANDBOX DR
