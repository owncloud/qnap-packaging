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
        ],
        "depends_on": [],
        "trigger": {
            "ref": [
                "refs/pull/**",
                "refs/tags/**",
            ],
        },
    }
