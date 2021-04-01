def main(ctx):
    return build(ctx)

def build(ctx):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "build",
        "steps": [
            {
                "name": "docker-images",
                "image": "alpine:latest",
                "pull": "always",
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
                    "make build-qpkg-only",
                ],
            },
            {
                "name": "list",
                "image": "alpine:latest",
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
                "refs/heads/main",
                "refs/pull/**",
                "refs/tags/**",
            ],
        },
    }
