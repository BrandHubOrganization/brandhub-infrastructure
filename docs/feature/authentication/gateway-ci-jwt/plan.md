# Plan

Register jwt.public-key through DynamicPropertySource in
BrandHubGatewayApplicationTests, loading keys/public.pem from the test classpath.
Other integration tests already supply their own key. No workflow secrets needed.
Mock only the Redis blacklist lookup in MonitoringRouteTest, retaining real JWT
signature checks and HTTP routing. Update the stale logging order assertion.
Flip a decoded signature byte and re-encode in the tampering regression test.
