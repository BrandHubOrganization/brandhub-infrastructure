# Private repository storage

Local checks: `terraform init -backend=false`, `terraform fmt -check`, `terraform validate`. These commands do not deploy. Review a separately authorized plan before apply; existing buckets need import rather than recreation. Bucket destruction is protected.

Set `REPOSITORY_SYSTEM_S3_KMS_KEY_ID` to the output key ARN and use runtime IAM credentials. PUT clients must send all uploadHeaders returned by upload-session. COPY and server-side PUT use the same key. Existing unencrypted objects require a separately verified migration; default encryption does not reencrypt old objects.

Trust boundary: explicit S3/KMS denies restrict direct data access by principals outside the runtime allowlist. They do not stop an administrator who can change bucket/key policies, assume runtime roles, deploy code to that role, or read application credentials. Separate those administrative capabilities and audit changes. Presigned links are bearer credentials and can remain usable until their short expiry after access is revoked; never log their query strings.

The stack intentionally does not enable S3 physical versioning: application history uses separate object keys, and purge accounting requires deletion to free physical bytes. If enabling S3 versioning later, implement permanent object-version cleanup first.

Reference: https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingKMSEncryption.html
