#!/bin/bash
# Push images to the docker hub

# Exit on error
set -ev

if [ "${TRAVIS_PULL_REQUEST}" == "false" ]
then
  echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
  # Branch check
  if [ "${TRAVIS_BRANCH}" == "master" ]
  then
    # For the master branch we tag with the octoprint version
    IMAGE=$(docker-compose config | yq -r .services.octoprint.image)
    TAG=$(docker run --rm "${IMAGE}" /opt/octoprint/OctoPrint/venv/bin/octoprint --version | awk '/version/ && NF==3 {print $NF}')
  else
    # Otherwhise we just take the branch name
    TAG="${TRAVIS_BRANCH}"
  fi

  # Architecture
  if [ "${OP_MACHINE_NAME}" = "raspberry-pi" ]
  then
    ARCH=arm32v6
  else
    ARCH=arm32v7
  fi

  # Process all images
  IMAGES=$(docker-compose config | yq -r '.services | .[].image')
  for IMAGE in ${IMAGES}
  do
    # Note that we can't publish a manifest dur to https://github.com/moby/moby/issues/34875
    # as arm32v6 would always be selected
    # for now we promote arm32v7; arm32v6 need to be explicitely selected
    echo "Pushing ${IMAGE} to the docker hub. Arch=${ARCH} Tag=${TAG}"
    docker tag "${IMAGE}" "${IMAGE}:${ARCH}-${TAG}"
    docker push "${IMAGE}:${ARCH}-${TAG}"
    if [ "${TRAVIS_BRANCH}" == "master" ]
    then
      # For the master branch, mark the image as latest
      echo "Pushing ${IMAGE} to the docker hub. Arch=${ARCH} Tag=latest"
      docker tag "${IMAGE}" "${IMAGE}:${ARCH}-latest"
      docker push "${IMAGE}:${ARCH}-latest"
      if [ "${ARCH}" = "arm32v7" ]
      then
	# Promote arm32v7 as default
        echo "Promoting arm32v7 ${IMAGE}"
        docker push "${IMAGE}"
      fi
    fi
  done
fi
