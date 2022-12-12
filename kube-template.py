from kubernetes import client, config
import boto3
import time
import sys
AWS_REGION = "us-east-1"
EC2_RESOURCE = boto3.resource('ec2', region_name=AWS_REGION)

config.load_kube_config('/home/infracloud/acquia/acquia_kubeconfig_dev')

appsv1 = client.AppsV1Api()
corev1 = client.CoreV1Api()
cr = client.CustomObjectsApi()


def get_ides():
    for i in appsv1.list_namespaced_deployment(namespace='remote-ides', label_selector='running=true').items:
        print(i.metadata.name)


def get_pv_name(ide):
    for i in corev1.list_namespaced_persistent_volume_claim(namespace='remote-ides', label_selector="app="+ide).items:
        return i.spec.volume_name


def get_volume_ids(pv_name):
    for i in corev1.list_persistent_volume().items:
        if i.metadata.name == pv_name:
            return i.spec.aws_elastic_block_store.volume_id


def take_snapshot(volume_id):
    snapshot = EC2_RESOURCE.create_snapshot(
        Description='Test Snapshot Python',
        VolumeId=volume_id,
        TagSpecifications=[
            {
                'ResourceType': 'snapshot',
                'Tags': [
                    {
                        'Key': "ec2:ResourceTag/ebs.csi.aws.com/cluster",
                        'Value': "true"
                    },
                    {
                        "Key": "kubernetes.io/cluster/cloud-ide-dev",
                        "Value": "owned"
                    }
                ]
            },
        ]
    )

    print("Snapshot in Progress...")
    print("Current State:" + snapshot.state)
    snapshot.load()
    while not snapshot.state == 'completed':
        print(snapshot.progress + "...")
        time.sleep(60)
        snapshot.load()
    print("Current State:" + snapshot.state)
    return snapshot.id


def create_vsc(ide_name, snapshot_id):
    snaphotcontent_body = {
        "apiVersion": "snapshot.storage.k8s.io/v1",
        "kind": "VolumeSnapshotContent",
        "metadata": {"name": "vsc-" + ide_name},
        "spec": {
            "volumeSnapshotClassName": "csi-aws-vsc",
            "source": {"snapshotHandle": snapshot_id},
            "volumeSnapshotRef": {"kind": "VolumeSnapshot", "name": "vs-"+ide_name, "namespace": "remote-ides"},
            "driver": "ebs.csi.aws.com",
            "deletionPolicy": "Delete"
        }
    }

    cr.create_cluster_custom_object(
        group="snapshot.storage.k8s.io",
        version="v1",
        plural="volumesnapshotcontents",
        body=snaphotcontent_body
    )
    print("VSC Ready to Use:" + cr.get_cluster_custom_object('snapshot.storage.k8s.io',
          'v1', 'volumesnapshotcontents', "vsc-"+ide_name)['status']['readyToUse'])


def create_vs(ide_name):
    snaphot_body = {
        "apiVersion": "snapshot.storage.k8s.io/v1",
        "kind": "VolumeSnapshot",
        "metadata": {"name": "vs-" + ide_name},
        "spec": {
            "volumeSnapshotClassName": "csi-aws-vsc",
            "source": {"volumeSnapshotContentName": "vsc-"+ide_name}
        }
    }

    cr.create_namespaced_custom_object(
        group="snapshot.storage.k8s.io",
        version="v1",
        namespace="remote-ides",
        plural="volumesnapshots",
        body=snaphot_body,
    )
    print("VS Ready to USe:"+cr.get_namespaced_custom_object('snapshot.storage.k8s.io',
          'v1', 'remote-ides', 'volumesnapshots', "vs-"+ide_name)['status']['readyToUse'])


def delete_pvc(ide_name):
    corev1.delete_namespaced_persistent_volume_claim(
        ide_name, namespace='remote-ides',)


def create_pvc(ide_name):
    persistent_volume_claim = client.V1PersistentVolumeClaim(
        api_version="v1",
        kind="PersistentVolumeClaim",
        metadata=client.V1ObjectMeta(
            name=ide_name
        ),
        spec=client.V1PersistentVolumeClaimSpec(
            access_modes=["ReadWriteOnce"],
            resources=client.V1ResourceRequirements(
                requests={'storage': '60Gi'}
            ),
            storage_class_name="ebs-csi-gp3-sc",
            data_source=client.V1TypedLocalObjectReference(
                api_group="snapshot.storage.k8s.io",
                kind="VolumeSnapshot",
                name="vs-"+ide_name
            )
        )
    )
    corev1.create_namespaced_persistent_volume_claim(
        namespace='remote-ides', body=persistent_volume_claim)
    print("PVC Created at" + corev1.read_namespaced_persistent_volume_claim(
        name=ide_name, namespace='remote-ides').metadata.creation_timestamp)


def main():
    if len(sys.argv) <= 1:
        print("Pass the IDE as an argument")
    else:
        ide_name = sys.argv[1]
        print("In-tree to CSI Migration started for IDE" + ide_name)
        pv_name = get_pv_name(ide_name)
        print("PV Name: "+pv_name)
        volume_id = get_volume_ids(pv_name)
        print("AWS Volume Id: "+volume_id)
        snapshot_id = take_snapshot(volume_id)
        print("Created AWS Snapshot Id: "+snapshot_id)
        create_vsc(ide_name, snapshot_id)
        create_vs(ide_name)
        delete_pvc(ide_name)
        time.sleep(60)
        create_pvc(ide_name)


if __name__ == "__main__":
    main()
