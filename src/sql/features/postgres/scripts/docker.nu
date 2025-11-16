#!/usr/bin/env nu

export def start-docker [] {
  try {
    colima status out+err> /dev/null
  } catch {
    colima start
  }
}

export def stop-docker [] {
  if (
    colima status
    | complete
    | get exit_code
  ) == 0 {
    colima stop
  }
}
