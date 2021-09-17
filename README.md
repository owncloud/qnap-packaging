## ownCloud X QPKG for QNAP

Packaging of owncloud X to QPKG format for QNAP


### Build setup

[GitHub owncloud/qnap-packaging](https://github.com/owncloud/qnap-packaging) is the main repository where the work is done.
Therefore drone.owncloud.com runs on PRs in order to see if everything is fine. Also Renovate will care for Docker image updates. Since the public drone hasn't access to our code signing certificate, it will not sign the build output. Despite this the artifacts are uploaded to GitHub releases.

[Gitea qnap/qnap-packaging](https://gitea.owncloud.services/qnap/qnap-packaging) a mirror of [GitHub owncloud/qnap-packaging](https://github.com/owncloud/qnap-packaging). It will pick up changes from time to time. Since it doesn't pick up PRs from GitHub, only tags / releases will trigger drone.owncloud.services. This internal drone also has access to our code signing certificate, so it will sign the build output and upload them to GitHub releases. If you want to speed up the release of the signed QPKG you'll probably want to login to Gitea and hit the "manual sync" button. You'll instantly will see a new CI pipeline building the signed QPKG.

The code signing certificate and password are provided the `windows_cert` and `windows_cert_password` secrets. `windows_cert` contains the same code signing certificate as the ownCloud Desktop Client uses, except that the content of `windows_cert` is coreutils base64 encoded and not powershell base64 encoded. `windows_cert_password` is the plaintext password for the certificate.
