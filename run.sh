set -eu

target=${1:-'*'}

for dockerfile in Dockerfile_$target; do
  tag=${dockerfile/Dockerfile_/}
  docker build -f $dockerfile -t hiroshiba/hiho-docker-base:$tag .
  docker push "hiroshiba/hiho-docker-base:$tag"
done
