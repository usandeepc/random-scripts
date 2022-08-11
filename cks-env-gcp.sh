gcloud compute instances create cks-master \
    --provisioning-model=SPOT \
    --image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20220701 \
    --machine-type=e2-medium \
    --instance-termination-action=DELETE --boot-disk-size=30GB --zone=asia-south1-c

gcloud compute ssh cks-master

curl https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/cluster-setup/latest/install_master.sh | sudo bash


gcloud compute instances create cks-worker-1 \
    --provisioning-model=SPOT \
    --image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20220701 \
    --machine-type=e2-medium \
    --instance-termination-action=DELETE --boot-disk-size=30GB --zone=asia-south1-c

gcloud compute ssh cks-worker-1

curl -s https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/cluster-setup/latest/install_worker.sh | sudo bash


gcloud compute instances create cks-worker-2 \
    --provisioning-model=SPOT \
    --image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20220701 \
    --machine-type=e2-medium \
    --instance-termination-action=DELETE --boot-disk-size=30GB --zone=asia-south1-c


gcloud compute ssh cks-worker-2

curl -s https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/cluster-setup/latest/install_worker.sh | sudo bash

gcloud compute instances delete cks-master
gcloud compute instances delete cks-worker-1
gcloud compute instances delete cks-worker-2
