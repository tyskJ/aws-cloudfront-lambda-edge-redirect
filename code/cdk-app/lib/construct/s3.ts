/*
╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║ CloudFront Lambda@Edge redirect Stack - Cloud Development Kit s3.ts                                                                                ║
╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
║ This construct creates an L2 Construct S3 Bucket.                                                                                                  ║
╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
*/
import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as s3 from "aws-cdk-lib/aws-s3";
import * as s3_deployment from "aws-cdk-lib/aws-s3-deployment";
import { bucketInfo } from "../../parameter";
import * as path from "path";

export interface IS3Props extends cdk.StackProps {
  bucket: bucketInfo;
}

export class S3Bucket extends Construct {
  public readonly bucket: s3.Bucket;

  constructor(scope: Construct, id: string, props: IS3Props) {
    super(scope, id);

    // S3 Bucket
    this.bucket = new s3.Bucket(this, props.bucket.id, {
      bucketName: props.bucket.bucketName,
      autoDeleteObjects: props.bucket.autoDeleteObjects,
      bucketKeyEnabled: props.bucket.bucketKeyEnabled,
      encryption: s3.BucketEncryption.S3_MANAGED,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      blockPublicAccess: new s3.BlockPublicAccess({
        blockPublicAcls: props.bucket.blockPublicAccess.blockPublicAcls,
        ignorePublicAcls: props.bucket.blockPublicAccess.ignorePublicAcls,
        blockPublicPolicy: props.bucket.blockPublicAccess.blockPublicPolicy,
        restrictPublicBuckets:
          props.bucket.blockPublicAccess.restrictPublicBuckets,
      }),
    });

    // Object Uploads
    new s3_deployment.BucketDeployment(this, "UpdateHtml", {
      destinationBucket: this.bucket,
      sources: [
        s3_deployment.Source.asset(path.join(`${__dirname}`, "../html")),
      ],
    });
  }
}
