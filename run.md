# Como executar o projeto



## 1-) Setup da sua conta AWS.

Execute o  [.yaml](bootstrap/dev/bootstrap-dev.yaml) de acordo com o ambiente que se pretende rodar. Neste cesário estamos com a hipotese de ser 1 conta AWS para cada ambiente.

Ao executar este YAML, os seguintes recursoss serão criadosem sua conta AWS:
- ``Bucket S3`` 
- ``DynamoDB Table``
- ``IAM Role OIDC``

Comando aws cloudformation: \
Requisitos: AWS CLI + Python 3.8. \
``aws Coudformation create-stack   --stack-name terraform-backend-dev   --template-body file://bootstrap/dev/bootstrap-dev.yaml   --region us-east-1   --capabilities CAPABILITY_NAMED_
IAM
`` 
## 2-) Rodando localmente o projeto


Caso esteja executando localmente os comandos são: \
Requisitos: Terraform + Conta AWS + Permissões (pode ser um user ou uma role). \
``git clone git@github.com:The-Kadabra/desafio-warren.git`` \
``terraform init -backend-config=infra/environment/dev/backend.hcl`` \
``terraform plan -var-file=infra/environment/dev/env.tfvars`` \
``terraform apply -auto-approve -var-file=infra/environment/dev/env.tfvars`` 

## 3-) Rodando via GITHUB
Neste cénario basta fazer uma cópia do meu repositorio para o seu repositorio pessoal e executar o pipeline em ``https://github.com/<user>/<project_name>/actions``. O nome do Workflow é ``terraform-deploy``.