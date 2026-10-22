# Plan

1. Add an explicit Business type-ID to local DTO mapping in Publisher's
   `RabbitMQConfig.jsonMessageConverter`; retain the headerless default.
2. Trust only Publisher's DTO package instead of all packages. Do not add a
   dependency on Business or modify its producer.
3. Extend the already tracked `PublishJobConsumerTest` with converter regression
   checks; do not add new test files under src.
4. Run tests without starting a service, consuming a real queue or publishing.
5. Ask the user to restart Publisher after verification. DLQ replay requires a
   separate explicit decision after checking for duplicate publication.
