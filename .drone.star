def main(ctx):
    return build(ctx)

def build(ctx):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "build",
        "steps": [
            {
                "name": "prepare-signing",
                "image": "owncloudci/alpine",
                "commands": [
                    "bash signing-preparation.sh",
                ],
                "environment": {
                    "CODE_SIGNING_CERT_PW": {
                        "from_secret": "windows_cert_password",
                    },
                    "CODE_SIGNING_CERT": {
                        "from_secret": "windows_cert",
                    },
                },
            },
            {
                "name": "docker-images",
                "image": "owncloudci/alpine",
                "commands": [
                    "apk add make skopeo",
                    "make docker-images",
                ],
            },
            {
                "name": "build-qpkg-only",
                "image": "owncloudci/qnap-qpkg-builder:latest",
                "pull": "always",
                "commands": [
                    "patch /usr/share/qdk2/QDK/bin/qbuild fix_offline_signing.diff",
                    "make build-qpkg-only",
                ],
            },
            {
                "name": "rename-unsigned",
                "image": "owncloudci/alpine",
                "commands": [
                    "bash rename-unsigned.sh",
                ],
            },
            {
                "name": "list",
                "image": "owncloudci/alpine",
                "pull": "always",
                "commands": [
                    "ls -lah build",
                ],
            },
            {
                "name": "release",
                "image": "plugins/github-release:1",
                "pull": "always",
                "settings": {
                    "api_key": {
                        "from_secret": "github_token",
                    },
                    "files": [
                        "build/*",
                    ],
                    "title": ctx.build.ref.replace("refs/tags/", ""),
                    "overwrite": True,
                    "prerelease": len(ctx.build.ref.split("-")) > 1,
                },
                "when": {
                    "ref": [
                        "refs/tags/**",
                    ],
                },
            },
        ],
        "depends_on": [],
        "trigger": {
            "ref": [
                "refs/heads/master",
                "refs/pull/**",
                "refs/tags/**",
            ],
        },
    }
