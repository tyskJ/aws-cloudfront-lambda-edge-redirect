# フォルダ構成

- フォルダ構成は以下の通り

```
.
`-- tf
    |-- envs
    |   |-- backend.tf                          tfstateファイル管理設定ファイル
    |   |-- data.tf                             外部データソース定義ファイル
    |   |-- locals.tf                           ローカル変数定義ファイル
    |   |-- main.tf                             リソース定義ファイル
    |   |-- output.tf                           リソース戻り値定義ファイル
    |   |-- provider.tf                         プロバイダー設定ファイル
    |   |-- variable.tf                         変数定義ファイル
    |   `-- version.tf                          プロバイダー＆Terraformバージョン管理ファイル
    `-- modules
        |-- acm                                 ACMモジュール
        |   |-- data.tf                           外部データソース定義ファイル
        |   |-- main.tf                           リソース定義ファイル
        |   |-- output.tf                         リソース戻り値定義ファイル
        |   |-- variable.tf                       変数定義ファイル
        |   `-- version.tf                        プロバイダーバージョン管理ファイル
        |-- cloudfront_s3                       CloudFront&S3モジュール
        |   |-- html                              CloudFrontデフォルトルートオブジェクト&エラーページ用HTMLファイル
        |   |   |-- error.html
        |   |   `-- index.html
        |   |-- json                              バケットポリシーJSONファイル
        |   |   `-- bucket-policy.json
        |   |-- data.tf                           外部データソース定義ファイル
        |   |-- main.tf                           リソース定義ファイル
        |   |-- output.tf                         リソース戻り値定義ファイル
        |   `-- variable.tf                       変数定義ファイル
        |-- lambda
        |   |-- data.tf                           外部データソース定義ファイル
        |   |-- json
        |   |   |-- lambda-logs-policy.json       Lambda用IAMポリシー
        |   |   `-- lambda-trust-policy.json      Lambda用信頼ポリシー
        |   |-- main.tf                           リソース定義ファイル
        |   |-- output.tf                         リソース戻り値定義ファイル
        |   |-- variable.tf                       変数定義ファイル
        |   `-- version.tf                        プロバイダーバージョン管理ファイル
        `-- web                                 WEBモジュール
            |-- assets
            |   `-- userdata.sh                   UserDataスクリプト
            |-- data.tf                           外部データソース定義ファイル
            |-- json
            |   `-- ec2-trust-policy.json         EC2用信頼ポリシー
            |-- main.tf                           リソース定義ファイル
            |-- output.tf                         リソース戻り値定義ファイル
            `-- variable.tf                       変数定義ファイル
```
