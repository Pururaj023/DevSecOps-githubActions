# DevSecOps CI/CD Pipeline
![CI/CD Pipeline Architecture](./cicd.png)
A comprehensive DevSecOps CI/CD pipeline implemented using GitHub Actions that integrates security scanning, code quality analysis, automated deployment, and infrastructure as code for a Django application.

## 🚀 Pipeline Overview

This pipeline implements a complete DevSecOps workflow with the following stages:

### CI Pipeline (DevSecOps CI)
1. **Build & Test** - Docker image creation and application testing
2. **Security Scanning** - Vulnerability assessment using Trivy
3. **Code Quality** - Static code analysis with SonarCloud
4. **Notification** - Email alerts for pipeline status

### CD Pipeline (Deployment)
1. **Docker Hub Push** - Build and push Docker images to registry
2. **Infrastructure Provisioning** - Deploy EC2 infrastructure using Terraform
3. **Application Deployment** - Deploy containerized Django app to EC2

## 🏗️ Complete Pipeline Architecture

```mermaid
graph TD
    A[Git Push/Manual Trigger] --> B[CI: Build & Test]
    B --> C[CI: Security Scan]
    C --> D[CI: Code Quality]
    D --> E[CI: Notification]
    E --> F{CI Success?}
    
    F -->|Yes| G[CD: Push to Docker Hub]
    F -->|No| Z[Pipeline Fails]
    
    G --> H[CD: Terraform Init]
    H --> I[CD: Provision EC2]
    I --> J[CD: Extract EC2 IP]
    J --> K[CD: Wait for Instance]
    K --> L[CD: SSH Deploy]
    L --> M[Application Live]
    
    B --> B1[Checkout Code]
    B1 --> B2[Build Docker Image]
    B2 --> B3[Run Container]
    B3 --> B4[Test Application]
    
    C --> C1[Trivy Vulnerability Scan]
    C1 --> C2[Check Critical/High CVEs]
    
    D --> D1[SonarCloud Analysis]
    D1 --> D2[Code Quality Gates]
    
    G --> G1[Docker Build]
    G1 --> G2[Docker Tag]
    G2 --> G3[Docker Push]
    
    I --> I1[Terraform Apply]
    I1 --> I2[Create VPC/Security Groups]
    I2 --> I3[Launch EC2 Instance]
    
    L --> L1[Pull Docker Image]
    L1 --> L2[Stop Old Container]
    L2 --> L3[Run New Container]
```

## 📋 CI Pipeline Stages

### Stage 1: Build Docker Image
- **Purpose**: Build and test the Django application
- **Actions**:
  - Checkout repository code
  - Build Docker image from `./mynotes` directory
  - Run container on port 80
  - Perform basic application health check

### Stage 2: Trivy Security Scan
- **Purpose**: Identify security vulnerabilities in the Docker image
- **Scanner**: [Aqua Security Trivy](https://github.com/aquasecurity/trivy)
- **Scope**: OS packages and application libraries
- **Severity Levels**: Critical and High vulnerabilities
- **Action**: Pipeline fails if critical/high vulnerabilities are found

### Stage 3: SonarQube Analysis
- **Purpose**: Static code analysis and quality assessment
- **Platform**: SonarCloud
- **Analysis**: Code smells, bugs, security hotspots, coverage
- **Requirements**: Node.js 18 for analysis

### Stage 4: Notification
- **Purpose**: Automated email notifications
- **Triggers**: Success or failure of pipeline
- **Method**: SMTP via Gmail
- **Recipients**: Development team

## 📋 CD Pipeline Stages

### Stage 1: Push Docker Image to Docker Hub
- **Purpose**: Build and publish production-ready Docker images
- **Actions**:
  - Checkout repository code
  - Authenticate with Docker Hub
  - Build Docker image with application code
  - Tag image with `latest` tag
  - Push to Docker Hub registry
- **Trigger**: Can be triggered manually or after successful CI pipeline

### Stage 2: Deploy Infrastructure with Terraform
- **Purpose**: Provision AWS infrastructure for application deployment
- **Infrastructure Components**:
  - EC2 instance for application hosting
  - VPC and networking configuration
  - Security groups for SSH and HTTP access
  - Elastic IP for consistent addressing
- **Actions**:
  - Initialize Terraform with S3 backend
  - Apply infrastructure configuration
  - Extract EC2 public IP address
  - Wait for instance to be ready
- **IaC Tool**: Terraform v1.5.6

### Stage 3: Deploy Application to EC2
- **Purpose**: Deploy containerized Django application
- **Deployment Method**: SSH-based deployment using appleboy/ssh-action
- **Actions**:
  - Connect to EC2 instance via SSH
  - Authenticate with Docker Hub
  - Pull latest Docker image
  - Stop and remove old container
  - Start new container with updated image
  - Map port 80 (host) to port 8000 (container)
  - Configure auto-restart policy
- **Zero-Downtime**: Brief service interruption during container swap

## 🛠️ Prerequisites

### Repository Setup
- Django application in `./mynotes` directory
- Dockerfile configured for the application
- Terraform configuration in `./terraform` directory
- SonarCloud project configured

### Required Secrets

Configure the following secrets in your GitHub repository:

#### CI Pipeline Secrets
| Secret Name | Description | Example |
|------------|-------------|---------|
| `SONAR_TOKEN` | SonarCloud authentication token | `sqp_...` |
| `MAIL_USERNAME` | Gmail username for notifications | `your-email@gmail.com` |
| `EMAIL_PASSWORD` | Gmail app password | `your-app-password` |

#### CD Pipeline Secrets
| Secret Name | Description | Example |
|------------|-------------|---------|
| `DOCKER_HUB_USERNAME` | Docker Hub username | `yourusername` |
| `DOCKER_HUB_ACCESS_TOKEN` | Docker Hub access token | `dckr_pat_...` |
| `AWS_ACCESS_KEY_ID` | AWS IAM access key | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM secret key | `wJalrXUtn...` |
| `AWS_REGION` | AWS deployment region | `us-east-1` |
| `EC2_SSH_KEY` | Private SSH key for EC2 access | `-----BEGIN RSA PRIVATE KEY-----...` |

### GitHub Token
The pipeline uses the built-in `GITHUB_TOKEN` for SonarCloud integration.

## 🚀 Usage

### Manual Trigger

#### CI Pipeline
1. Navigate to **Actions** tab in your GitHub repository
2. Select **DevSecOps CI Pipeline**
3. Click **Run workflow**
4. Choose the branch and click **Run workflow**

#### CD Pipeline
1. Navigate to **Actions** tab
2. Select **Push Docker Image to Docker Hub and Deploy to EC2**
3. Click **Run workflow**
4. Choose the branch and click **Run workflow**

### Automatic Trigger Setup

#### CI Pipeline - Automatic on Push
```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:
```

#### CD Pipeline - Trigger After CI Success
```yaml
on:
  workflow_run:
    workflows: ["DevSecOps CI Pipeline"]
    types:
      - completed
  workflow_dispatch:
```

## 📊 Security Features

### Vulnerability Scanning
- **Tool**: Trivy by Aqua Security
- **Coverage**: OS and library vulnerabilities
- **Action**: Fails pipeline on Critical/High severity findings
- **Output**: Detailed vulnerability table
- **Integration**: Scans Docker images before deployment

### Code Quality Gates
- **Platform**: SonarCloud
- **Metrics**: Code coverage, duplications, maintainability
- **Security**: Security hotspots and vulnerability detection
- **Integration**: PR analysis and quality gate enforcement

### Infrastructure Security
- **IAM**: Uses AWS IAM credentials with least privilege
- **Network**: Security groups restrict access to SSH (port 22) and HTTP (port 80)
- **Secrets**: All sensitive data stored in GitHub Secrets
- **SSH**: Key-based authentication for EC2 access

## 🏗️ Infrastructure as Code

### Terraform Configuration
The pipeline uses Terraform to manage AWS infrastructure:

**Required Terraform Files:**
```
terraform/
├── main.tf           # Main infrastructure definition
├── variables.tf      # Input variables
├── outputs.tf        # Output values (must include ec2_public_ip)
├── backend.tf        # S3 backend configuration
└── terraform.tfvars  # Variable values (if needed)
```

**Critical Output Required:**
```hcl
output "ec2_public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "Public IP address of the EC2 instance"
}
```

### AWS Resources Created
- **EC2 Instance**: Application server (e.g., t2.micro)
- **Security Group**: Firewall rules for SSH and HTTP
- **VPC/Subnet**: Network infrastructure (if not using default)
- **Elastic IP**: Optional static IP address

## 📧 Notification System

The CI pipeline includes comprehensive email notifications:

### Success Notifications
- Sent when all stages complete successfully
- Includes workflow completion confirmation
- Links to GitHub Actions for detailed logs

### Failure Notifications
- Triggered on any stage failure
- Immediate alert to development team
- Includes failure details and troubleshooting links

## 🔧 Configuration

### Project Structure
```
project-root/
├── mynotes/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── manage.py
│   └── [Django application files]
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── backend.tf
├── .github/
│   └── workflows/
│       ├── devsecops-ci-pipeline.yml
│       └── devsecops-cd-pipeline.yml
├── sonar-project.properties
└── README.md
```

### Dockerfile Requirements
Your Dockerfile should:
- Expose the application port (typically 8000 for Django)
- Use a production-ready WSGI server (e.g., Gunicorn)
- Include health check endpoint
- Follow Docker best practices for security

Example:
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "myproject.wsgi:application"]
```

### SonarCloud Configuration
Create a `sonar-project.properties` file in your repository root:

```properties
sonar.projectKey=your-project-key
sonar.organization=your-organization
sonar.sources=.
sonar.exclusions=**/node_modules/**,**/venv/**,**/migrations/**
sonar.python.version=3.11
```

## 🛡️ Security Best Practices

1. **Secret Management**: All sensitive data stored in GitHub Secrets
2. **Vulnerability Scanning**: Automated security assessment before deployment
3. **Code Quality**: Continuous code quality monitoring
4. **Fail-Fast**: Pipeline fails immediately on security issues
5. **Infrastructure Security**: Security groups, IAM roles, and encrypted connections
6. **Container Security**: Images scanned before pushing to registry
7. **SSH Security**: Key-based authentication, no password access
8. **Notifications**: Real-time alerts for security and quality issues

## 📈 Monitoring & Reporting

### Pipeline Status
- GitHub Actions dashboard provides real-time pipeline status
- Email notifications ensure immediate awareness of issues
- SonarCloud dashboard for code quality trends
- Docker Hub for image version tracking

### Security Reports
- Trivy generates detailed vulnerability reports
- SonarCloud provides security hotspot analysis
- Historical trend analysis available through both platforms

### Deployment Monitoring
- EC2 instance health checks
- Application logs accessible via SSH
- Container status monitoring with Docker
- AWS CloudWatch for infrastructure metrics

## 🔍 Troubleshooting

### Common Issues

#### CI Pipeline Issues
**Issue**: Trivy scan fails with critical vulnerabilities
- **Solution**: Update base image and dependencies in Dockerfile
- **Prevention**: Regular dependency updates and security patching

**Issue**: SonarCloud analysis fails
- **Solution**: Verify `SONAR_TOKEN` is valid and has correct permissions
- **Check**: Ensure `sonar-project.properties` is properly configured

#### CD Pipeline Issues

**Issue**: Terraform fails with credential errors
- **Solution**: Verify AWS credentials in GitHub Secrets
- **Check**: Ensure IAM user has necessary permissions (EC2, VPC, S3)
- **Note**: Credentials must be set at job level or in each step's `env`

**Issue**: SSH connection to EC2 fails
- **Solution**: Verify security group allows SSH from GitHub Actions IPs
- **Check**: Ensure `EC2_SSH_KEY` matches the key pair used for EC2
- **Wait**: Instance may need time to boot; pipeline includes 30s wait

**Issue**: Docker container fails to start on EC2
- **Solution**: SSH into EC2 and check Docker logs: `docker logs django-app`
- **Check**: Verify port mapping and ensure application starts correctly
- **Debug**: Ensure EC2 instance has Docker installed and running

**Issue**: EC2 IP not captured correctly
- **Solution**: Verify Terraform output name matches: `ec2_public_ip`
- **Check**: Ensure `terraform_wrapper: false` is set in setup-terraform step
- **Debug**: Add debug step to print Terraform outputs

### Debugging Commands

SSH into EC2 instance:
```bash
ssh -i path/to/key.pem ec2-user@<EC2_IP>
```

Check container status:
```bash
docker ps -a
docker logs django-app
```

View Terraform state:
```bash
cd terraform
terraform show
terraform output
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Make your changes
4. Ensure all pipeline stages pass locally
5. Test infrastructure changes in a separate AWS account
6. Submit a pull request with detailed description

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For issues and questions:
- Create an issue in this repository
- Check GitHub Actions logs for detailed error messages
- Review SonarCloud reports for code quality issues
- Verify Trivy scan results for security vulnerabilities
- Check AWS Console for infrastructure issues
- Review Docker Hub for image build problems

## 🔍 Additional Resources

### CI/CD & DevSecOps
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [DevSecOps Best Practices](https://owasp.org/www-project-devsecops-guideline/)

### Security Tools
- [Trivy Scanner](https://github.com/aquasecurity/trivy)
- [SonarCloud Documentation](https://sonarcloud.io/documentation)

### Infrastructure & Deployment
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker Documentation](https://docs.docker.com/)
- [AWS EC2 User Guide](https://docs.aws.amazon.com/ec2/)

### Deployment Tools
- [appleboy/ssh-action](https://github.com/appleboy/ssh-action)
- [Docker Hub Documentation](https://docs.docker.com/docker-hub/)

---

**Pipeline Status Badges**

Add these to the top of your README for real-time status:

```markdown
![CI Pipeline](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/devsecops-ci-pipeline.yml/badge.svg)
![CD Pipeline](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/devsecops-cd-pipeline.yml/badge.svg)
```