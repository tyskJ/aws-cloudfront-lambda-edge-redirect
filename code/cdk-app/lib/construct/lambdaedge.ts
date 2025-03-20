/*
╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║ CloudFront Lambda@Edge redirect Stack - Cloud Development Kit lambdaedge.ts                                                                        ║
╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
║ This construct creates an L2 Construct Lambda@Edge.                                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
*/
import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as iam from "aws-cdk-lib/aws-iam";
import * as cloudfront from "aws-cdk-lib/aws-cloudfront";
import * as lambda from "aws-cdk-lib/aws-lambda";
import * as path from "path";

export interface ILambdaEdgeProps extends cdk.StackProps {
  roleInfo: iam.Role;
}

export class LambdaEdge extends Construct {
  public readonly lambdaEdge: cloudfront.experimental.EdgeFunction;

  constructor(scope: Construct, id: string, props: ILambdaEdgeProps) {
    super(scope, id);

    this.lambdaEdge = new cloudfront.experimental.EdgeFunction(this, "EdgeFn", {
      runtime: lambda.Runtime.PYTHON_3_13,
      handler: "redirect.lambda_handler",
      code: lambda.Code.fromAsset(path.join(`${__dirname}`, "../assets")),
      description: "Lambda@Edge Function for Redirect.",
      functionName: "lambda-redirect",
      role: props.roleInfo,
    });

    // RemovalPolicy
    const cfnEdgeFn = this.lambdaEdge.node.defaultChild as lambda.CfnFunction;
    cfnEdgeFn.applyRemovalPolicy(cdk.RemovalPolicy.RETAIN);
  }
}
