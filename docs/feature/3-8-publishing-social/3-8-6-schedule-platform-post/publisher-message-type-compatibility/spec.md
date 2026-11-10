# Publisher message type compatibility

## Objective and acceptance criteria

Accept the existing Business publish-job JSON contract when its AMQP `__TypeId__`
is `com.brandhub.business.dto.message.PublishJobMessage`. Deserialize to Publisher's
local `PublishJobMessage`, without loading a Business service class.

Continue accepting Publisher's own type header and messages without a type header.
Preserve all job fields and retry serialization. Unknown untrusted class names must
remain rejected rather than allowing arbitrary Java classes.

## Scope

Only Publisher's AMQP converter and regression checks. No changes to JSON payload,
queue names, adapters, callbacks, Task completion rules, database or UI. No automatic
replay of DLQ messages and no calls to social APIs during verification.

## Errors and UI

Malformed JSON and unsupported type headers remain conversion failures. No UI,
i18n or theme changes apply. Existing pending/failed posts are not repaired here.
