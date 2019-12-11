#!/usr/bin/env bash

# rd_kafka_conf_set_open_cb is blacklisted because it is not compiled on
# Windows due to its usage of the Unix-only `mode_t` type. With a bit of
# elbow grease we could include it if not targeting Windows, but it doesn't
# seem worthwhile at the moment.

bindgen \
    --no-doc-comments \
    --no-layout-tests \
    --rustified-enum ".*" \
    --whitelist-function "rd_kafka.*" \
    --whitelist-type "rd_kafka.*" \
    --whitelist-var "rd_kafka.*|RD_KAFKA_.*" \
    --no-recursive-whitelist \
    --blacklist-function "rd_kafka_conf_set_open_cb" \
    --raw-line "use num_enum::TryFromPrimitive;" \
    --raw-line "type FILE = libc::FILE;" \
    --raw-line "type sockaddr = libc::sockaddr;" \
    librdkafka/src/rdkafka.h -o src/bindings.rs

# Derive TryFromPrimitive for rd_kafka_resp_err_t.
perl -i -p0e 's/#\[derive\((.*)\)\]\npub enum rd_kafka_resp_err_t/#\[derive($1, TryFromPrimitive)\]\npub enum rd_kafka_resp_err_t/s' src/bindings.rs
