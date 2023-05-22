# KVS VIDEO UPLOAD TESTING

This repo contains code which enables the testing of KVS video uploading. It uses the Amazon Kinesis Video Streams Producer SDK Samples written in C++. It contains a Dockerfile to spin up a simple ubuntu docker container and install dependencies. This allows for the C++ samples to be run in insolation and without having an individual developer depend on a native environment.

## Docker container overview

- The docker container builds off ubuntu:18.04.

- It installs pre-requisites and builds cmake.

- It clones a GitHub [fork](https://github.com/kenneth-toxcon/amazon-kinesis-video-streams-producer-sdk-cpp.git) that contains modified KVS SDK samples. This forked repository includes a modified version of the `kvs_gstreamer_audio_video_sample.cpp` sample file. This file has been edited to add custom metadata MKV tags that mark the start and end of interval events.

After successfully building and starting the container, we can begin a new shell session. This step makes it easier to interact directly with the SDK samples. It also gives us a chance to check out and test the current implementations in a hands-on way.

## Docker commands

```
# from the aws-producer-sdk-sample folder
docker build -t aws-iot-dc-ubuntu:latest .

docker run -dit aws-iot-dc-ubuntu

```

## Run the video upload sample

Make sure to set up the docker env with permissions:

```
export AWS_ACCESS_KEY_ID=<key-id>
export AWS_SECRET_ACCESS_KEY=<secret>
export AWS_DEFAULT_REGION=<region>
```

Test Modified KVS SDK Sample:

```
cd amazon-kinesis-video-streams-producer-sdk-cpp/build

GST_DEBUG=1 ./kvs_gstreamer_audio_video_sample vcm_intervals -f /home/workdir/videos/person-bicycle-car-detection.mp4 -e notification
```

## Setting up the KVS Streams

### FIFO or Not

I have tested with both FIFO SNS and standard SNS and it does not appear that the FIFO queues work.

### Notification Configuration

The documentation on KVS notifications is bad (as of 2023-05-05). The following commands allow one to set up a KVS stream to forward notifications.

```
import boto3
kvs = boto3.client("kinesisvideo",region_name="us-west-2")
kvs.update_notification_configuration(
    StreamARN='<StreamARN>',
      NotificationConfiguration={
          'Status': 'ENABLED',
          'DestinationConfig': {
              'Uri': '<SNS-ARN>'
          }
      }
)
kvs.describe_notification_configuration(
    StreamARN="<StreamARN>"
)

```

### Permissions

_SNS permissions:_
When building the SNS make sure to allow permission to either the whole account to publish to it or the specific role/user whose credentials you

_KVS role permissions:_
The role used when launching the
