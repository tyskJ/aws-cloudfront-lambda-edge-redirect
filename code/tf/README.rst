.. image:: ./doc/001samune.png

=====================================================================
デプロイ - Terraform -
=====================================================================

作業環境 - ローカル -
=====================================================================
* 64bit版 Windows 11 Pro
* Visual Studio Code 1.96.2 (Default Terminal: Git Bash)
* Git 2.47.1.windows.2
* tenv v4.1.0
* Terraform v1.10.3

フォルダ構成
=====================================================================
* `こちら <./folder.md>`_ を参照

前提条件
=====================================================================
* *AdministratorAccess* がアタッチされているIAMユーザーのアクセスキーID/シークレットアクセスキーを作成していること
* 実作業は *envs* フォルダ配下の各環境フォルダで実施すること
* 以下コマンドを実行し、*admin* プロファイルを作成していること (デフォルトリージョンは *ap-northeast-1* )

.. code-block:: bash

  aws configure --profile admin

事前作業(1)
=====================================================================
1. 各種モジュールインストール
---------------------------------------------------------------------
* `GitHub <https://github.com/tyskJ/common-environment-setup>`_ を参照

事前作業(2)
=====================================================================
1. *tfstate* 用S3バケット作成
---------------------------------------------------------------------
.. code-block:: bash

  aws s3 mb s3://tf-20250318 --profile admin

.. note::

  * バケット名は全世界で一意である必要があるため、作成に失敗した場合は任意の名前に変更
  * 変更した場合は、「 *envs/backend.tf* 」ファイル内のバケット名も修正

2. リダイレクト先ホスト名修正
---------------------------------------------------------------------
* *src* フォルダにあるコード内のリダイレクト先FQDNを修正

.. code-block:: python

  if request_path == '/test1/':
      redirect_url = 'https://リダイレクト先FQDN/test1/'
  elif request_path == '/test2/':
      redirect_url = 'https://リダイレクト先FQDN/test2/'

実作業 - ローカル -
=====================================================================
1. *Terraform* 初期化
---------------------------------------------------------------------
.. code-block:: bash

  terraform init

2. 事前確認
---------------------------------------------------------------------
* ご自身の環境に併せて変数の値を修正し実行

.. code-block:: bash

  terraform plan \
  -var "alb_cert_issue_domain_name=ALB用に発行する証明書のドメイン名" \
  -var "alb_hostzone_id=ALB用Aliasレコードを登録するパブリックホストゾーンのゾーンID" \
  -var "alb_fqdn=ALB用AliasレコードのFQDN" \
  -var "bucket_name=バケット名" \
  -var "cloudfront_cert_issue_domain_name=CloudFront用に発行する証明書のドメイン名" \
  -var "cloudfront_hostzone_id=CloudFront用Aliasレコードを登録するパブリックホストゾーンのゾーンID" \
  -var "cloudfront_fqdn=CloudFront用AliasレコードのFQDN"

3. デプロイ
---------------------------------------------------------------------
* ご自身の環境に併せて変数の値を修正し実行

.. code-block:: bash

  terraform apply --auto-approve \
  -var "alb_cert_issue_domain_name=ALB用に発行する証明書のドメイン名" \
  -var "alb_hostzone_id=ALB用Aliasレコードを登録するパブリックホストゾーンのゾーンID" \
  -var "alb_fqdn=ALB用AliasレコードのFQDN" \
  -var "bucket_name=バケット名" \
  -var "cloudfront_cert_issue_domain_name=CloudFront用に発行する証明書のドメイン名" \
  -var "cloudfront_hostzone_id=CloudFront用Aliasレコードを登録するパブリックホストゾーンのゾーンID" \
  -var "cloudfront_fqdn=CloudFront用AliasレコードのFQDN"

後片付け - ローカル -
=====================================================================
1. Lambda@EdgeをTerraform管理下から外す
---------------------------------------------------------------------
* Lambda@Edge関数は、レプリカがリージョン別エッジキャッシュに作成されます。
* そのレプリカが残っている限り関数は削除できません。
* レプリカは、ディストリビューションの関連付けが解除されてから数分~数時間後に削除されます。
* そのため、一度管理外とし、その他リソース削除後、時間を空けて手動削除してください。

.. code-block:: bash

  terraform state rm aws_lambda_function.lambda_function

2. 環境削除
---------------------------------------------------------------------
* ご自身の環境に併せて変数の値を修正し実行

.. code-block:: bash

  terraform destroy --auto-approve \
  -var "alb_cert_issue_domain_name=ALB用に発行する証明書のドメイン名" \
  -var "alb_hostzone_id=ALB用Aliasレコードを登録するパブリックホストゾーンのゾーンID" \
  -var "alb_fqdn=ALB用AliasレコードのFQDN" \
  -var "bucket_name=バケット名" \
  -var "cloudfront_cert_issue_domain_name=CloudFront用に発行する証明書のドメイン名" \
  -var "cloudfront_hostzone_id=CloudFront用Aliasレコードを登録するパブリックホストゾーンのゾーンID" \
  -var "cloudfront_fqdn=CloudFront用AliasレコードのFQDN"

3. *tfstate* 用S3バケット削除
---------------------------------------------------------------------
.. code-block:: bash

  aws s3 rm s3://tf-20250318 --recursive --profile admin
  aws s3 rb s3://tf-20250318 --profile admin

.. note::

  * *事前作業(2)* で作成したバケット名に合わせること

4. Lambda@Edge用ロググループ削除
---------------------------------------------------------------------
* */aws/lambda/us-east-1.関数名* のロググループが作成されます。
* Lambda@Edgeはバージニア北部リージョンに作成しましたが、実際は呼び出し元の最寄りリージョン別エッジキャッシュで実行されます。
* そのため、読み出し元の最寄りリージョンにロググループが作成されますので、併せて削除しておきましょう。
