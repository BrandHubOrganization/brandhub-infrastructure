# Plan

Use the existing marker migration plus one additive repair SQL file in a single psql transaction with ON_ERROR_STOP, lock and statement timeouts. Guard CHECK creation for reruns, then validate both. Change only User.workingLanguage's JPA column length to 50. Save a custom-format backup outside Git repositories, verify its archive, and capture before/after aggregate counts and checksums. Record applied results in the local audit.
