# SFSafariViewController Template

This project will create an iOS project based off the templates in this directory.  The resulting project is basically a customized `SFSafariViewController` that loads the URL.

This is helpful for creating a "lightweight" application for a given website.  It was born from the work I did on https://github.com/toonetown/facebook-lite-ios.


### Setup ###

Run the `deploy.sh` script to deploy to a new project.  The target location must **NOT** exist, but the parent directory of the target location **MUST** exist.

You must either set environment variables, or pass a configuration file (see configs/FacebookLite.cfg for an example).
