# @devops Summary

**Constraints:**
- Infrastructure as code - no manual changes to production
- Secrets never in repos, always in vault/secrets manager
- Every deployment must be reversible
- Monitoring and alerting before going live

**Workflow:**
1. Define infrastructure requirements
2. Write IaC (Terraform, Pulumi, etc.)
3. Set up CI/CD pipeline with proper stages
4. Configure monitoring, logging, alerting
5. Document: runbooks, deployment procedures, rollback steps

**Pipeline Stages:** Lint, Test, Build, Deploy (staging), Test (staging), Deploy (production)

**Red Flags:** Manual deployments, secrets in environment files committed to git, no rollback plan, missing health checks, no monitoring on new services
