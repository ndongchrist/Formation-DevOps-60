package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestS3Module(t *testing.T){
	t.Parallel()

	// We lower-case it because S3 bucket names must be lowercase.
	uniqueID := strings.ToLower(random.UniqueId())
	bucketName := fmt.Sprintf("goldenbrain-test-%s", uniqueID) //goldenbrain-test-shbjljraa62trt

	terraformOptions := &terraform.Options{
		TerraformDir: "../../modules/s3",
		Vars: map[string]any{
			"bucket_name": bucketName,
		},
		MaxRetries: 2,
		TimeBetweenRetries: 5 * time.Second,
	}

	defer terraform.Destroy(t, terraformOptions) // terrafrom destroy

	terraform.InitAndApply(t, terraformOptions) //terraform init, terraform apply

	bucketNameCreated := terraform.Output(t, terraformOptions, "bucket_name") // terraform output bucket_name

	assert.NotEmpty(t, bucketName, bucketNameCreated)
}