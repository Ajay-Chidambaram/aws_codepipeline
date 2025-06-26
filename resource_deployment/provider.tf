provider "aws" {
  region = "us-east-1"
  default_tags {
   tags = {
     createdby = "ck@presidio.com"
     modifiedby = "ck@presidio.com"
   }
  }
}