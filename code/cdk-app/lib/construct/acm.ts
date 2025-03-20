/*
╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║ CloudFront Lambda@Edge redirect Stack - Cloud Development Kit network.ts                                                                           ║
╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
║ This construct creates an L2 Construct Public Certificate and Validation.                                                                          ║
╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
*/
import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as acm from "aws-cdk-lib/aws-certificatemanager";
import * as route53 from "aws-cdk-lib/aws-route53";

export interface IAcmProps extends cdk.StackProps {
  hosted_zone_id: string;
  zone_apnex_name: string;
  issue_domain_name: string;
}

export class Acm extends Construct {
  public readonly hosted_zone: route53.IHostedZone;
  public readonly certificate: acm.Certificate;

  constructor(scope: Construct, id: string, props: IAcmProps) {
    super(scope, id);

    // import hosted zone
    this.hosted_zone = route53.HostedZone.fromHostedZoneAttributes(
      this,
      "Zone" + props.zone_apnex_name,
      { hostedZoneId: props.hosted_zone_id, zoneName: props.zone_apnex_name }
    );

    // issue certificate and validation
    this.certificate = new acm.Certificate(
      this,
      "Cert" + props.issue_domain_name,
      {
        domainName: props.issue_domain_name,
        validation: acm.CertificateValidation.fromDns(this.hosted_zone),
      }
    );
  }
}
