aws cloudwatch put-metric-alarm \  # creating an alarm using cloud watch
  --alarm-name "HighCPU" \  # Name of the CloudWatch alarm
  --metric-name CPUUtilization \  # The metric to monitor (CPU usage in this case)
  --namespace AWS/EC2 \  # The namespace the metric belongs to (EC2 metrics)
  --statistic Average \  # Use the average value of the metric for evaluation
  --period 300 \  # The evaluation period in seconds (300s = 5 minutes)
  --threshold 70 \  # The threshold value that triggers the alarm (70% CPU)
  --comparison-operator GreaterThanThreshold \  # Alarm triggers when value is > threshold
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \  # Apply the alarm to a specific EC2 instance
  --evaluation-periods 2 \  # Number of consecutive periods the condition must be met
  --alarm-actions arn:aws:sns:region:account-id:your-sns-topic \  # ARN of the SNS topic to notify when alarm is triggered
  --region your-region  # The AWS region where the EC2 instance and alarm reside

# contact me for more: christianhonore2003gmail.com
# phone: +237699357180
