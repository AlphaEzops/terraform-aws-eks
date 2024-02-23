# Deploying Infrastructure with Terraform

This guide will walk you through the process of deploying infrastructure using Terraform, using the provided Taskfile. The Taskfile is a configuration file that defines tasks for common operations in your infrastructure deployment workflow.

### Prerequisites

Before you begin, ensure that you have the following prerequisites installed:

1. **Terraform**: Make sure you have Terraform installed on your system. You can download it from the official website: [Terraform Downloads](https://www.terraform.io/downloads.html).

2. **Task**: Task is a task runner tool used to define and run tasks from a Taskfile. You can install it by following the instructions on the GitHub repository: [Task GitHub Repository](https://github.com/go-task/task).

3. **AWS CLI and aws-vault**: You'll need the AWS CLI installed to work with AWS services, and aws-vault for securely managing AWS credentials. Install them following the official documentation: [Installing the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) and [aws-vault GitHub Repository](https://github.com/99designs/aws-vault).

### Taskfile Overview

The provided Taskfile contains a set of tasks that streamline the deployment process. Each task corresponds to a specific Terraform operation, such as initializing, planning, applying, and destroying infrastructure.

Here's an overview of the tasks defined in the Taskfile:

- **task env:set**: Sets environment variables interactively using user input.
- **task tf:auto**: Initiates Terraform's initialization, planning, and applying steps in sequence.
- **task tf:init**: Initializes the Terraform configuration and sets up the backend.
- **task tf:plan**: Generates a Terraform execution plan and saves it to a `.tfplan` file.
- **task tf:apply**: Applies the changes defined in the execution plan.
- **task tf:destroy**: Destroys the infrastructure created by Terraform.

### Using the Taskfile

Follow these steps to deploy infrastructure using the provided Taskfile:

1. **Clone Repository**: Clone the repository containing your Terraform configurations.
```bash
git clone https://github.com/ArthurMaverick/devops_project.git
```
2**Configure Terrafrom Backend**: Open the `main.tf` file in the `terraform` directory and configure the backend according to your deployment environment. For example, if you're deploying to AWS, you can use the following configuration:
```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket" # Replace with your bucket name
    key    = "terraform.tfstate"
    region = "us-east-1" # Replace with your region
  }
}
```

3. **Navigate to Directory**: Open a terminal and navigate to the directory containing the Taskfile (ROOT DIR of project) and your Terraform configurations.

4. **Configure Variables**: Set the environment (`ENV`) and region (`REGION`) variables in the Taskfile according to your deployment environment.
```bash
task env:set
```
5. **Initialize, Plan, Apply, or Destroy**: If you prefer to execute individual tasks, you can do so using the following commands:

      ```sh
      # Initialize - download providers and initialize backend
      task tf:init
      ```
      ```sh
      # Plan - generate execution plan and save to .tfplan file
      task tf:plan
      ```

      ```sh
      # Apply - apply changes defined in execution plan
      task tf:apply
      ```
   
      ```sh
      # Destroy - destroy infrastructure created by Terraform
      task tf:destroy
      ```
      ```sh
      # Run the "auto" task to initialize, plan, and apply changes
      # This will prompt you to confirm if you want to run the Terraform operations. Respond with `y` to proceed.
      task tf:auto
      ```

   This will prompt you to confirm if you want to run the Terraform operations. Respond with `y` to proceed.

### Conclusion

You have successfully deployed infrastructure using Terraform and the provided Taskfile. By utilizing the predefined tasks, you can streamline the deployment process and ensure consistency across different environments and regions.

Remember to review the Taskfile and adjust variables and paths to match your specific project structure and requirements.