#!/usr/bin/env nu

export def start-docker [] {
  # FIXME: it's possible for the try block to be OK, but the status is not good.
  # figure out how to ACTUALLY catch this
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
