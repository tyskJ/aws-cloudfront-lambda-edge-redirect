import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import { IParameter } from "../../parameter";
import * as acm from "aws-cdk-lib/aws-certificatemanager";
import * as cloudfront from "aws-cdk-lib/aws-cloudfront";
import { Acm } from "../construct/acm";
import { IamPolicy } from "../construct/iampolicy";
import { IamRole } from "../construct/iamrole";
import { LambdaEdge } from "../construct/lambdaedge";

export interface IVirginiaStackProps extends IParameter {}

export class VirginiaStack extends cdk.Stack {
  public readonly CfCertificate: acm.Certificate;
  public readonly lambdaFn: cloudfront.experimental.EdgeFunction;

  constructor(scope: Construct, id: string, props: IVirginiaStackProps) {
    super(scope, id, props);

    // Pseudo Parameters
    const pseudo = new cdk.ScopedAws(this);

    // ACM
    const useast1Acm = new Acm(this, "UsEast1Acm", {
      hosted_zone_id: this.node.tryGetContext("hosted_zone_id_for_cf"),
      zone_apnex_name: this.node.tryGetContext("zone_apnex_name_for_cf"),
      issue_domain_name: this.node.tryGetContext("issue_domain_name_for_cf"),
    });
    this.CfCertificate = useast1Acm.certificate;

    // IAM Policy
    const logsPolicy = new IamPolicy(this, "LogsPolicy", {
      pseudo: pseudo,
      policyInfo: props.logsPolicy,
    });

    // IAM Role
    const lambdaRole = new IamRole(this, "LambdaRole", {
      roleInfo: props.lambdaRole,
      managedPolicy: [logsPolicy.iamPolicy],
    });

    // Lambda@Edge
    // tokyoStackで作成してもバージニア北部に作成してくれる
    // ただし別スタックとして作成してしまうため、同一リージョンとなるvirginiaStackで作成する
    const fn = new LambdaEdge(this, "Lambda", {
      roleInfo: lambdaRole.iamRole,
    });
    this.lambdaFn = fn.lambdaEdge;
  }
}
