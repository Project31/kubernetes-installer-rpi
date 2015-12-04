#!/bin/bash
#   Copyright 2015 Skippbox
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

cd pause
docker run -v $PWD:/tmp/pause -w /tmp/pause hypriot/rpi-golang go build --ldflags '-extldflags "-static" -s' pause.go
docker build -t gcr.io/google_containers/pause:0.8.0 .

cd ../
curl -fsSL -o hyperkube https://github.com/project31/kubernetes-arm/raw/master/hyperkube
curl -fsSL -o kubelet https://github.com/project31/kubernetes-arm/raw/master/kubelet

chmod +x hyperkube
mkdir images
mv hyperkube ./images
cp Dockerfile.hyperkube ./images
cd images
docker build -f Dockerfile.hyperkube -t hyperkube .

cd ..
cp kubelet.service /etc/systemd/system/kubelet.service
mkdir -p /etc/kubernetes/manifests
cp kube-proxy.yaml /etc/kubernetes/manifests/kube-proxy.yaml
mv kubelet /usr/bin/kubelet
chmod +x /usr/bin/kubelet

systemctl daemon-reload
systemctl start kubelet

curl -fsSL -o kubectl https://storage.googleapis.com/kubernetes-release/release/v1.0.3/bin/linux/arm/kubectl
chmod +x kubectl
mv kubectl /usr/bin/kubectl





