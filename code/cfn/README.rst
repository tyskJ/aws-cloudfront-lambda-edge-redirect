.. image:: ./doc/001samune.png

=====================================================================
デプロイ - CloudFormation -
=====================================================================

作業環境 - ローカル -
=====================================================================
* 64bit版 Windows 11 Pro
* Visual Studio Code 1.96.2 (Default Terminal: Git Bash)
* Git 2.47.1.windows.2
* AWS CLI 2.22.19.0 (profile登録&rainで利用する)
* Rain v1.20.2 windows/amd64

前提条件
=====================================================================
* *AdministratorAccess* がアタッチされているIAMユーザーのアクセスキーID/シークレットアクセスキーを作成していること
* 実作業は *cfn* フォルダ配下で実施すること
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
1. デプロイ用S3バケット作成(東京リージョン)
---------------------------------------------------------------------
.. code-block:: bash

  DATE=$(date '+%Y%m%d')
  aws s3 mb s3://cfn-$DATE-apne1 --profile admin

2. デプロイ用S3バケット作成(バージニア北部リージョン)
---------------------------------------------------------------------
.. code-block:: bash

  DATE=$(date '+%Y%m%d')
  aws s3 mb s3://cfn-$DATE-useast1 --region us-east-1 --profile admin

実作業 - ローカル -
=====================================================================
1. *virginiastack* デプロイ
---------------------------------------------------------------------
.. code-block:: bash

  rain deploy virginiastack.yaml VIRGINIASTACK \
  --s3-bucket cfn-$DATE-useast1 \
  --region us-east-1 --profile admin

* 以下プロンプトより入力

.. csv-table::

  "Parameter", "概要", "入力値"
  "HostedZoneId", "Route 53 Public Hosted Zoneに登録しているドメインのHosted zone ID", "ご自身が所有するパブリックホストゾーンID（CloudFront用証明書のCNAMEレコード登録先）"
  "Fqdn", "CloudFrontのAliasレコードを登録するときのFQDN", "CloudFront用証明書のドメイン名"

2. *tokyostack* デプロイ
---------------------------------------------------------------------
.. code-block:: bash

  rain deploy tokyostack.yaml TOKYOSTACK \
  --s3-bucket cfn-$DATE-apne1 \
  --config tokyo-parameter.yaml --profile admin

* 以下プロンプトより入力

.. csv-table::

  "Parameter", "概要", "入力値"
  "LatestAmiId", "AmazonLinux2023最新AMIID", "何も入力せずEnter"
  "HostedZoneIdForAlb", "Route 53 Public Hosted Zoneに登録しているドメインのHosted zone ID", "ご自身が所有するパブリックホストゾーンID（ALBのAliasレコード及び証明書CNAMEレコード登録先）"
  "FqdnForAlb", "ALBのAliasレコードを登録するときのFQDN", "ご自身で登録したいFQDN"
  "HostedZoneIdForCloudFront", "Route 53 Public Hosted Zoneに登録しているドメインのHosted zone ID", "ご自身が所有するパブリックホストゾーンID（CloudFrontのAliasレコード登録先）"
  "FqdnForCloudFront", "CloudFrontのAliasレコードを登録するときのFQDN", "ご自身で登録したいFQDN"
  "CertArnForCloudFront", "CloudFront用証明書ARN", "virginiastackデプロイ時に表示されたARN"
  "S3BucketName", "S3バケット名", "CloudFrontのオリジン用S3バケット名"

3. HTMLファイルアップロード
---------------------------------------------------------------------
* *index.html*, *error.html* をS3バケットにアップロード

.. code-block:: bash

  aws s3 cp index.html s3://デプロイしたS3バケット名 --profile admin
  aws s3 cp error.html s3://デプロイしたS3バケット名 --profile admin


後片付け - ローカル -
=====================================================================
1. デプロイしたS3バケットのオブジェクト削除
---------------------------------------------------------------------
* 中身を空にする必要があるため削除

.. code-block:: bash

  aws s3 rm --recursive s3://デプロイしたS3バケット名 --profile admin

2. *tokyostack* 削除
---------------------------------------------------------------------
.. code-block:: bash

  rain rm TOKYOSTACK --profile admin

.. note::

  * tokyostack削除後、 *DNS検証* で自動作成されたALB用証明書の *CNAMEレコード* は残る
  * そのため、不要なら手動で *CNAMEレコード* を削除すること

3. *virginiastack* 削除
---------------------------------------------------------------------
.. code-block:: bash

  rain rm VIRGINIASTACK --region us-east-1 --profile admin

.. note::

  * virginiastack削除後、 *DNS検証* で自動作成されたCloudFront用証明書の *CNAMEレコード* は残る
  * そのため、不要なら手動で *CNAMEレコード* を削除すること

4. デプロイ用S3バケット作成(東京リージョン)削除
---------------------------------------------------------------------
* 中身を空にしバケットを削除

.. code-block:: bash

  aws s3 rm --recursive s3://cfn-$DATE-apne1 --profile admin
  aws s3 rb s3://cfn-$DATE-apne1 --profile admin

5. デプロイ用S3バケット作成(バージニア北部リージョン)削除
---------------------------------------------------------------------
* 中身を空にしバケットを削除

.. code-block:: bash

  aws s3 rm --recursive s3://cfn-$DATE-useast1 --profile admin
  aws s3 rb s3://cfn-$DATE-useast1 --profile admin
