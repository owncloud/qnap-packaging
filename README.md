## ownCloud X QPKG for QNAP

Packaging of owncloud X to QPKG format for QNAP


### Notes to code signing
- Signing happens only on our internal Drone CI.
- The CI expects `windows_cert` and `windows_cert_password` to be available. That's the same code signing certificate like the Desktop Client uses.
