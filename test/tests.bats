@test "checking process: template (master enabled by default)" {
  run docker exec template /bin/bash -c "ps aux | grep -v grep | grep '/usr/lib/template'"
  [ "$status" -eq 0 ]
}


@test "checking process: template (master disabled by DISABLE_TEMPLATE)" {
  run docker exec template_no_template /bin/bash -c "ps aux | grep -v grep | grep '/usr/lib/template'"
  [ "$status" -eq 1 ]
}

@test "checking database: postgres (default)" {
  run docker exec template_default /bin/bash -c "su - template -c \"/usr/bin/template --list | grep template\""
  [ "$status" -eq 0 ]
}

