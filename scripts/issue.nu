#!/usr/bin/env nu

use domain.nu
use environment.nu get-project-root

def get-service [service?: string] {
  if ($service | is-empty) {
    domain
  } else {
    $service
  }
}

# Close issue
def "main close" [
  issue_number: number # The id of the issue to view
  --service: string # Which service to use (see `list-services`)
] {
  let service = (get-service $service)

  match $service {
    "github" => (gh issue close $issue_number)
    "gitlab" => (glab issue close $issue_number)
    _ => (nb do $issue_number)
  }
}

def get-project-prefix [] {
  [(get-project-root | path basename) "--"]
  | str join
}

# Create issue
def "main create" [
  --service: string # Which service to use (see `list-services`)
] {
  let service = (get-service $service)

  match $service {
    "github" => (gh issue create --editor)
    "gitlab" => (glab issue create)
    _ => {
      let title = (input "Enter title: ")

      nb todo add --title $"(get-project-prefix)($title)"
    }
  }
}

# Create/open issue and development branch
def "main develop" [
  issue_number: number # The id of the issue to view
  --service: string # Which service to use (see `list-services`)
] {
  let service = (get-service $service)

  match $service {
    "github" => (gh issue develop --checkout $issue_number)

    "gitlab" => (
      print "Feature not implemented for GitLab."

      exit 1
    )
  }
}

# List available services
def "main list-services" [] {
  print ([github gitlab nb] | str join "\n")
}

# View issues
def main [
  issue_number?: number # The id of the issue to view
  --service: string # Which service to use (see `list-services`)
  --web # Open the remote repository website in the browser
] {
  let service = (get-service $service)

  match $service {
    "github" => {
      if ($issue_number | is-empty) {
        if $web {
          gh issue list --web
        } else {
          gh issue list
        }
      } else if $web {
        gh issue view $issue_number --web
      } else {
        gh issue view $issue_number
      }
    }

    "gitlab" => {
      if ($issue_number | is-empty) {
        if $web {
          print "`--web` not implemented for GitLab's `issue list`."
        }

        glab issue list
      } else if $web {
        glab issue view $issue_number --web
      } else {
        glab issue view $issue_number
      }
    }

    _ => {
      let repo_issues = (
        nb todo (get-project-prefix)
      )

      if ($issue_number | is-empty) {
        $repo_issues
      } else if ($repo_issues | find $issue_number | is-not-empty) {
        nb todo $issue_number
      }
    }
  }
}
