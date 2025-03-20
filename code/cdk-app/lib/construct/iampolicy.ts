/*
╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║ CloudFront Lambda@Edge redirect Stack - Cloud Development Kit iampolicy.ts                                                                         ║
╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
║ This construct creates an L2 Construct IAM Policy.                                                                                                 ║
╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
*/
import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as iam from "aws-cdk-lib/aws-iam";
import { iamPolicyInfo } from "../../parameter";
import * as fs from "fs";
import * as path from "path";

export interface IPolicyProps extends cdk.StackProps {
  pseudo: cdk.ScopedAws;
  policyInfo: iamPolicyInfo;
}

export class IamPolicy extends Construct {
  public readonly iamPolicy: iam.ManagedPolicy;

  constructor(scope: Construct, id: string, props: IPolicyProps) {
    super(scope, id);

    // FilePath
    const filePath = path.join(
      `${__dirname}`,
      "../json/",
      props.policyInfo.jsonFileName
    );

    // JsonData
    let jsonData = fs.readFileSync(filePath, "utf8");

    // JsonPolicy
    if (props.policyInfo.partitionFlag) {
      jsonData = jsonData.replace(/{Partition}/g, props.pseudo.partition);
    }
    if (props.policyInfo.regionFlag) {
      jsonData = jsonData.replace(/{Region}/g, props.pseudo.region);
    }
    if (props.policyInfo.accountFlag) {
      jsonData = jsonData.replace(/{AccountId}/g, props.pseudo.accountId);
    }
    const jsonPolicy = JSON.parse(jsonData);

    // Create IAM Policy
    this.iamPolicy = new iam.ManagedPolicy(this, props.policyInfo.id, {
      managedPolicyName: props.policyInfo.policyName,
      description: props.policyInfo.description,
      document: iam.PolicyDocument.fromJson(jsonPolicy),
    });
  }
}
