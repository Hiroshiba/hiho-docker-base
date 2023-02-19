set -eux -o pipefail
shopt -s inherit_errexit

name=$1
if [ -z "$name" ]; then
  echo "エラー: 名前が指定されていません"
  exit 1
fi

dockerfile=$(find . -name "${name}-*.Dockerfile" | head -n 1)
if [ -z "$dockerfile" ]; then
  echo "エラー: ${name}-*.Dockerfileが見つかりません"
  exit 1
fi

tag=${dockerfile/.Dockerfile/}
tag=${tag#./}
echo $tag
