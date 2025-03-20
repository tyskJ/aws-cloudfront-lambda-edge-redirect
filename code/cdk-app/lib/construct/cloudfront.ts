/*
╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║ CloudFront Lambda@Edge redirect Stack - Cloud Development Kit cloudfront.ts                                                                        ║
╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
║ This construct creates an L2 Construct CloudFront Distribution and Alias RecordSet.                                                                ║
╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
*/
import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as cloudfront from "aws-cdk-lib/aws-cloudfront";
import * as cloudfront_origins from "aws-cdk-lib/aws-cloudfront-origins";
import * as s3 from "aws-cdk-lib/aws-s3";
import * as acm from "aws-cdk-lib/aws-certificatemanager";
import * as route53 from "aws-cdk-lib/aws-route53";
import * as route53_targets from "aws-cdk-lib/aws-route53-targets";

export interface ICloudFrontProps extends cdk.StackProps {
  bucket: s3.Bucket;
  cfFqdn: string;
  hosted_zone_id: string;
  zone_apnex_name: string;
  albFqdn: string;
  cfCert: acm.Certificate;
  edgeFunction: cloudfront.experimental.EdgeFunction;
}

export class CloudFront extends Construct {
  constructor(scope: Construct, id: string, props: ICloudFrontProps) {
    super(scope, id);

    // OAC
    const oac = new cloudfront.S3OriginAccessControl(this, "OAC", {
      originAccessControlName: "cf-oac-s3",
      description: "OAC for S3 bucket",
      signing: cloudfront.Signing.SIGV4_NO_OVERRIDE,
    });

    // s3Origin
    const s3Origin = cloudfront_origins.S3BucketOrigin.withOriginAccessControl(
      props.bucket,
      {
        originAccessControl: oac,
        originId: props.bucket.bucketName,
      }
    );

    // distribution
    const ditribution = new cloudfront.Distribution(this, "Distri", {
      enabled: true,
      defaultRootObject: "index.html",
      certificate: acm.Certificate.fromCertificateArn(
        this,
        "ImportCert",
        props.cfCert.certificateArn
      ),
      defaultBehavior: {
        origin: s3Origin,
        viewerProtocolPolicy: cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
        edgeLambdas: [
          {
            eventType: cloudfront.LambdaEdgeEventType.VIEWER_REQUEST,
            functionVersion: props.edgeFunction.currentVersion,
          },
        ],
      },
      errorResponses: [
        {
          httpStatus: 404,
          ttl: cdk.Duration.seconds(10),
          responseHttpStatus: 200,
          responsePagePath: "/error.html",
        },
      ],
      domainNames: [props.cfFqdn],
    });

    // import hosted zone
    const hosted_zone = route53.HostedZone.fromHostedZoneAttributes(
      this,
      "Zone" + props.zone_apnex_name,
      { hostedZoneId: props.hosted_zone_id, zoneName: props.zone_apnex_name }
    );

    // Alias Record
    new route53.ARecord(this, "CfAliasRecord", {
      zone: hosted_zone,
      recordName: props.cfFqdn,
      target: route53.RecordTarget.fromAlias(
        new route53_targets.CloudFrontTarget(ditribution)
      ),
    });
  }
}
