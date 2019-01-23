#!/usr/bin/env bash
set -e
set -o pipefail

BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${BUILD_DIR}/ci/common/common.sh"
source "${BUILD_DIR}/ci/common/dependencies.sh"

WORK_DIR=${WORK_DIR:-${BUILD_DIR}/build}
MIRROR_USER=${MIRROR_USER:-neovim}
MIRROR_BRANCH=${MIRROR_BRANCH:-master}

sync_git_mirror() {
  local repo="${1}"
  local branch="${2:-${MIRROR_BRANCH}}"
  local upstream_url="${3}"
  local repo_dir="${WORK_DIR}/${repo}"

  echo "Cloning into ${repo_dir} from: ${upstream_url}"
  rm -rf "${repo_dir}"
  git clone "${upstream_url}" "${repo_dir}"

  echo "Pushing to: ${MIRROR_USER}/${repo}"
  MIRROR_SUBTREE="/" \
  MIRROR_DIR="${repo_dir}" \
  MIRROR_REPO="${MIRROR_USER}/${repo}" \
  MIRROR_BRANCH="${branch}" \
    commit_subtree MIRROR
}

sync_bzr_mirror() {
  local repo="${1}"
  local upstream_url="http://bazaar.leonerd.org.uk/c/${repo}"
  local repo_dir="${WORK_DIR}/${repo}"

  echo "Cloning upstream repo ${upstream_url} into ${repo_dir}"
  rm -rf "${repo_dir}"
  git clone "bzr::${upstream_url}" "${repo_dir}"

  echo "Pushing to: ${MIRROR_USER}/${repo}"
  MIRROR_SUBTREE="/" \
  MIRROR_DIR="${repo_dir}" \
  MIRROR_REPO="${MIRROR_USER}/${repo}" \
    commit_subtree MIRROR
}

sync_bzr_mirror libvterm
sync_bzr_mirror libtermkey
sync_git_mirror unibilium master https://github.com/mauke/unibilium/
sync_git_mirror libuv master https://github.com/libuv/libuv/
