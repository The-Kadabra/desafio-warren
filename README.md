#  Infra Challenge - Warren

Este projeto tem como objetivo implementar Infraestrutura como código para provisionamento de recursos na AWS utilizando Terraform e GitHub Actions (CI/CD). O projeto cria e gerencia múltiplos ambientes (dev, stg, prod) com VPC, subnets, EC2, balanceador de carga (ALB), endpoints SSM, IAM/SSM para acesso seguro e automação de bootstrap de serviços (Nginx, Prometheus, Grafana, Node Exporter).

O objetivo é fornecer uma infraestrutura automatizada, replicável e auditável, garantindo boas práticas de segurança, observabilidade e escalabilidade.

## Infra-Project

```


├── .github
│   └── workflows
│       └── ci-terraform.yaml      # Pipeline CI/CD para Terraform no GitHub Actions
│
├── bootstrap                      # Bootstraps de infraestrutura base por ambiente
│   ├── dev
│   │   └── bootstrap-dev.yaml
│   ├── prod
│   │   └── bootstrap-prod.yaml
│   └── stg
│       └── bootstrap-stg.yaml
│
├── infra
│   └── environment                # Configurações específicas por ambiente
│       ├── dev
│       │   ├── backend.hcl        # Configuração de backend remoto (S3/DynamoDB)
│       │   └── env.tfvars         # Variáveis de ambiente para DEV
│       ├── prod
│       │   ├── backend.hcl        # Configuração de backend remoto (S3/DynamoDB)
│       │   └── env.tfvars         # Variáveis de ambiente para PROD
│       └── stg
│           ├── backend.hcl        # Configuração de backend remoto (S3/DynamoDB)
│           └── env.tfvars         # Variáveis de ambiente para STG
│
├── script
│   └── user_data.sh               # Script de inicialização (Nginx, Prometheus, Grafana e NodeExport)
│
├── .gitignore                     # Ignora arquivos desnecessários no Git
├── data.tf                        # Data sources (ex: AMIs, VPCs, etc.)
├── Desafio.md                     # Descrição do desafio/projeto
├── env.tf                         # Definição de variáveis globais de ambiente
├── key_pair.tf                    # Configuração de chaves SSH (Key Pair)
├── load_balancer.tf               # Recurso de Load Balancer + Target Groups
├── main.tf                        # Arquivo principal, orquestra os módulos
├── outputs.tf                     # Saídas do Terraform
├── provider.tf                    # Configuração do provider AWS
├── README.md                      # Documentação principal do projeto
└── ssm.tf                         # Recursos relacionados ao AWS SSM (Session Manager)
```
