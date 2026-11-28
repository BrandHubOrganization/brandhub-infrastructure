# =========================================================
# GitHub Actions OIDC Identity Provider
# =========================================================

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.github_oidc_thumbprints

  lifecycle {
    prevent_destroy = true
  }
}
