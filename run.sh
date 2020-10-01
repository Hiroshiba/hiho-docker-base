set -eu

target=${1:-'*'}
build_option=${2:-''}

target_files=$(ls Dockerfile_$target | awk '{ print length, $0 }' | sort -n -s | cut -d" " -f2-)

for dockerfile in $target_files; do
  tag=${dockerfile/Dockerfile_/}
  docker build -f $dockerfile -t hiroshiba/hiho-docker-base:$tag $build_option .
  docker push hiroshiba/hiho-docker-base:$tag
done

if [ "$target" = '*' ]; then
  dockerfile=$(echo "$target_files" | head -n1)
  tag=${dockerfile/Dockerfile_/}
  docker tag hiroshiba/hiho-docker-base:$tag hiroshiba/hiho-docker-base:latest
  docker push hiroshiba/hiho-docker-base:latest
fi
