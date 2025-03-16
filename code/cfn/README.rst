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
1. *tokyostack* デプロイ
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
  "S3BucketName", "S3バケット名", "CloudFrontのオリジン用S3バケット名"


2. HTMLファイルアップロード
---------------------------------------------------------------------
* *index.html*, *error.html* をS3バケットにアップロード

.. code-block:: bash

  aws s3 cp index.html s3://デプロイしたS3バケット名 --profile admin
  aws s3 cp error.html s3://デプロイしたS3バケット名 --profile admin

3. Python3の文字エンコーディング設定を *UTF-8* に変更
---------------------------------------------------------------------
.. code-block:: bash

  PYTHONUTF8=1
  export PYTHONUTF8

4. リダイレクト先ホスト名修正
---------------------------------------------------------------------
* コード内のリダイレクト先FQDNを修正

.. code-block:: python
  if request_path == '/test1/':
      redirect_url = 'https://リダイレクト先FQDN/test1/'
  else if request_path == '/test2/':
      redirect_url = 'https://リダイレクト先FQDN/test2/'


5. アーティファクト(Lambda関数コード)をS3にアップロード
---------------------------------------------------------------------
.. code-block:: bash

  aws cloudformation package \
  --template-file virginiastack.yaml \
  --s3-bucket cfn-$DATE-useast1 \
  --output-template-file virginiastack-out.yaml --profile admin

6. *virginiastack* デプロイ
---------------------------------------------------------------------
.. code-block:: bash

  rain deploy virginiastack-out.yaml VIRGINIASTACK \
  --s3-bucket cfn-$DATE-useast1 \
  --region us-east-1 --profile admin

* 以下プロンプトより入力

.. csv-table::

  "Parameter", "概要", "入力値"
  "HostedZoneIdForCloudFront", "Route 53 Public Hosted Zoneに登録しているドメインのHosted zone ID", "ご自身が所有するパブリックホストゾーンID（CloudFrontのAliasレコード登録先）"
  "FqdnForCloudFront", "CloudFrontのAliasレコードを登録するときのFQDN", "ご自身で登録したいFQDN"
  "BucketName", "CloudFrontのオリジン用S3バケット名", "デプロイしたS3バケット名"
  "BucketArn", "CloudFrontのオリジン用S3バケットARN", "デプロイしたS3バケットARN"
  "BucketRegionalDomainName", "CloudFrontのオリジン用S3バケットリージョナルドメイン名", "デプロイしたS3バケットリージョナルドメイン名"

後片付け - ローカル -
=====================================================================
1. デプロイしたS3バケットのオブジェクト削除
---------------------------------------------------------------------
* 中身を空にする必要があるため削除

.. code-block:: bash

  aws s3 rm --recursive s3://デプロイしたS3バケット名 --profile admin

2. *virginiastack* 削除
---------------------------------------------------------------------
.. code-block:: bash

  rain rm VIRGINIASTACK --region us-east-1 --profile admin

.. note::

  * virginiastack削除後、 *DNS検証* で自動作成されたCloudFront用証明書の *CNAMEレコード* は残る
  * そのため、不要なら手動で *CNAMEレコード* を削除すること

3. *tokyostack* 削除
---------------------------------------------------------------------
.. code-block:: bash

  rain rm TOKYOSTACK --profile admin

.. note::

  * tokyostack削除後、 *DNS検証* で自動作成されたALB用証明書の *CNAMEレコード* は残る
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
