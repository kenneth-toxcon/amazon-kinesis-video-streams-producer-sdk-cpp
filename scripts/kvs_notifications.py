import boto3

kvs = boto3.client("kinesisvideo")

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