package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestEC2Module(t *testing.T){
	t.Parallel()

	// We lower-case it because S3 bucket names must be lowercase.
	// uniqueID := strings.ToLower(random.UniqueId())
	// bucketName := fmt.Sprintf("goldenbrain-test-%s", uniqueID) //goldenbrain-test-shbjljraa62trt

	terraformOptions := &terraform.Options{
		TerraformDir: "../../modules/ec2",
		Vars: map[string]any{
			"instance_type": "t2.micro",
		},
		MaxRetries: 2,
		TimeBetweenRetries: 5 * time.Second,
	}

	defer terraform.Destroy(t, terraformOptions) // terrafrom destroy

	terraform.InitAndApply(t, terraformOptions) //terraform init, terraform apply

	InstanceID1 := terraform.Output(t, terraformOptions, "instance_1_id") // terraform output bucket_name
	InstanceID2 := terraform.Output(t, terraformOptions, "instance_2_id") // terraform output bucket_name

	assert.NotEmpty(t, InstanceID1)
	assert.NotEmpty(t, InstanceID2)
}