#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
TAG="${GITHUB_REF_NAME}"
VERSION="${TAG:1}"
PREFIX="rules_scala-${VERSION}"
ARCHIVE="rules_scala-$TAG.tar.gz"
git archive --format=tar --prefix=${PREFIX}/ ${TAG} | gzip > $ARCHIVE
SHA=$(shasum -a 256 $ARCHIVE | awk '{print $1}')

cat << EOF
## Using Bzlmod

Paste this snippet into your \`MODULE.bazel\` file:

\`\`\`starlark
# Set \`repo_name = "io_bazel_rules_scala"\` if you still need it.
bazel_dep(name = "rules_scala", version = "${VERSION}")
\`\`\`

## Using WORKSPACE

Paste this snippet into your \`WORKSPACE\` file:

\`\`\`starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_scala",  # Can be "io_bazel_rules_scala" if you still need it.
    sha256 = "${SHA}",
    strip_prefix = "${PREFIX}",
    url = "https://github.com/bazelbuild/rules_scala/releases/download/${TAG}/${ARCHIVE}",
)
\`\`\`

See https://github.com/bazelbuild/rules_scala#getting-started for full setup instructions.
EOF
