use std assert

use ../../../generic/scripts/domain.nu parse-git-origin

let expected_domain = "github.com"
let expected_owner = "tymbalodeon"
let expected_repo = "environments"

#[test]
def test-git [] {
  let origin = "git@github.com:tymbalodeon/environments.git"
  let actual_origin = (parse-git-origin $origin)

  assert equal ($actual_origin | get domain) $expected_domain
  assert equal ($actual_origin | get owner) $expected_owner
  assert equal ($actual_origin | get repo) $expected_repo

}

#[test]
def test-http [] {
  let origin = "http://github.com:tymbalodeon/environments.git"
  let actual_origin = (parse-git-origin $origin)

  assert equal ($actual_origin | get domain) $expected_domain
  assert equal ($actual_origin | get owner) $expected_owner
  assert equal ($actual_origin | get repo) $expected_repo
}

#[test]
def test-https [] {
  let origin = "https://github.com:tymbalodeon/environments.git"
  let actual_origin = (parse-git-origin $origin)

  assert equal ($actual_origin | get domain) $expected_domain
  assert equal ($actual_origin | get owner) $expected_owner
  assert equal ($actual_origin | get repo) $expected_repo
}

#[test]
def test-ssh [] {
  let origin = "ssh://git@github.com/tymbalodeon/environments.git"
  let actual_origin = (parse-git-origin $origin)

  assert equal ($actual_origin | get domain) $expected_domain
  assert equal ($actual_origin | get owner) $expected_owner
  assert equal ($actual_origin | get repo) $expected_repo
}

#[test]
def test-invalid [] {
  let invalid_origin = "github.com/tymbalodeon/environments"
  let actual_invalid_origin = (parse-git-origin --quiet $invalid_origin)

  assert equal ($actual_invalid_origin | get domain) null
  assert equal ($actual_invalid_origin | get owner) null
  assert equal ($actual_invalid_origin | get repo) null
}
