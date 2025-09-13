#  Infra Challenge - Warren

Este projeto tem como objetivo implementar Infraestrutura como código para provisionamento de recursos na AWS utilizando Terraform e GitHub Actions (CI/CD). O projeto cria e gerencia múltiplos ambientes (dev, stg, prod) com VPC, subnets, EC2, balanceador de carga (ALB), endpoints SSM, IAM/SSM para acesso seguro e automação de bootstrap de serviços (Nginx, Prometheus, Grafana, Node Exporter).

O objetivo é fornecer uma infraestrutura automatizada, replicável e auditável, garantindo boas práticas de segurança, observabilidade e escalabilidade.

## Infra-Code-Project

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
## Arquitetura

![APIGTW](imagens/Arquitetura.png) 

### Apresentando os recursos mais importantes
- ``Application load balancer`` -> Estamos usando o ALB com intert-facing para ser a nossa camada de borda e ponto de conexão direta com o usuário.

- ``Redes`` ->  A parte de network temos 3 estruturas chaves \
    1- ) ``Subnet publica`` -> Recursos criados nela possui comunica direta da internet através do ``Internet Gateway``. \
    2- ) ``Subnet privada`` -> Recursos criado nela não recebem solicitações de requisição da internet, porém contém acesso a internet através do ``Nat Gateway``. \
    3- ) ``Route Table`` -> Temos basicamente 2 regras chaves. A primeira é a que garante a comunicação entre as subnets ``Publica<->Privada`` e a Segunda a regra que encaminha as request ``0.0.0.0/0`` para seus pontos de acesso a internet. \

- ``EC2`` -> Com o shape t3.medium estamos rodando os aplicativos ``Nginx``, ``Grafana``, ``Prometheus`` e ``Node_Exporte``. O responsavel por gerar essa configuração é o user_data que está sendo passado no terraform.

## CI/CD

### Veja os detalhes da pipeline
- ``Github Actions`` -> Usando o pipeline do Github através da comunicação do ``OIDC`` (O OpenID Connect - protocolo de autenticação OAuth 2.0) temos uma esteira que atualmente está separada por ambiente e pode ser verificada aqui [CICD](/.github/workflows/ci-terraform.yaml).

- ``Steps da esteira`` -> [Terraform Plan](https://productionresultssa6.blob.core.windows.net/actions-results/5314539f-faa2-4488-9147-2b4f142fdb38/workflow-job-run-9de157cc-626a-552c-9bdc-9649b6050f88/logs/job/job-logs.txt?rsct=text%2Fplain&se=2025-09-13T18%3A02%3A31Z&sig=yi1Tzv2yiAlOCDTDL9dUsC46r1slsxATe0dgPDPUU5Q%3D&ske=2025-09-14T05%3A07%3A33Z&skoid=ca7593d4-ee42-46cd-af88-8b886a2f84eb&sks=b&skt=2025-09-13T17%3A07%3A33Z&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skv=2025-05-05&sp=r&spr=https&sr=b&st=2025-09-13T17%3A52%3A26Z&sv=2025-05-05
) e [Terraform Apply](https://productionresultssa6.blob.core.windows.net/actions-results/5314539f-faa2-4488-9147-2b4f142fdb38/workflow-job-run-a52e9bf4-b438-587c-87be-40942ae9d9e0/logs/job/job-logs.txt?rsct=text%2Fplain&se=2025-09-13T18%3A02%3A20Z&sig=85aqMpBjImlF2Ep4mNEeckeXA3XWrnZ4J3EPo1CyUVY%3D&ske=2025-09-14T05%3A00%3A48Z&skoid=ca7593d4-ee42-46cd-af88-8b886a2f84eb&sks=b&skt=2025-09-13T17%3A00%3A48Z&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skv=2025-05-05&sp=r&spr=https&sr=b&st=2025-09-13T17%3A52%3A15Z&sv=2025-05-05). Além dos logs é possível ver a tela do ``github.com/actions`` 
![APIGTW](imagens/plan_cicd.png)
![APIGTW](imagens/apply_cicd.png)

## Nginx
Essa é a Pagina de Welcome do Nginx customizada e direcionando para links das ferramentas que a EC2 está sustentando.
![APIGTW](imagens/nginx.png)

## Observabilidade
Prometheus coleta e armazena métricas do Node Exporter, que expõe dados de performance do servidor.
O Grafana se conecta ao Prometheus para visualizar essas métricas em dashboards interativos.

### Medindo e Garantindo.
- ``Grafana`` -> Veja o Dashboard que foi feito atráves da coleta de métricas e logs
![APIGTW](imagens/grafana.png)

## Terraform
### Workspace por Environment
- ``TFVARS`` - No Terraform, os arquivos ``.tfvars`` guardam os valores das variáveis de cada ambiente. Eles permitem manter um único código base, mas separar configurações de ``dev, stg e prod``, tornando o projeto mais limpo, reutilizável e fácil de gerenciar.

## Links do Projeto
[Nginx](http://desafio-warren-dev-alb-740799946.us-east-1.elb.amazonaws.com/)

[Node Export](http://desafio-warren-dev-alb-740799946.us-east-1.elb.amazonaws.com:9090/graph)

[Grafana](http://desafio-warren-dev-alb-740799946.us-east-1.elb.amazonaws.com:3000/)


## Referências

https://github.com/terraform-aws-modules/terraform-aws-ec2-instance \
https://github.com/terraform-aws-modules/terraform-aws-vpc \
https://github.com/terraform-aws-modules/terraform-aws-key-pair 


### Contato
IN: https://www.linkedin.com/in/gabriel-henrique-pires-5039a3168/ \
Youtube: https://www.youtube.com/@Gabriel_Pires_Tech  \
E-mail: gabriel.pires.ti@gmail.com


