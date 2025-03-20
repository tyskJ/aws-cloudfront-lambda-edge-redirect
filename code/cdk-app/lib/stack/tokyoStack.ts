import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import { IParameter } from "../../parameter";
import * as acm from "aws-cdk-lib/aws-certificatemanager";
import * as cloudfront from "aws-cdk-lib/aws-cloudfront";
import { CloudFront } from "../construct/cloudfront";
import { Network } from "../construct/network";
import { Acm } from "../construct/acm";
import { IamRole } from "../construct/iamrole";
import { Ec2 } from "../construct/ec2";
import { Alb } from "../construct/alb";
import { S3Bucket } from "../construct/s3";

export interface ITokyoStackProps extends IParameter {
  cfCert: acm.Certificate;
  function: cloudfront.experimental.EdgeFunction;
}

export class TokyoStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: ITokyoStackProps) {
    super(scope, id, props);

    // Pseudo Parameters
    const pseudo = new cdk.ScopedAws(this);

    // Network Construct
    const nw = new Network(this, "Network", {
      pseudo: pseudo,
      vpc: props.vpc,
      subnets: props.subnets,
      nacl: props.nacl,
      rtbPub: props.rtbPub,
      rtbPri: props.rtbPri,
      s3GwEp: props.s3GwEp,
      sgEc2: props.sgEc2,
      sgAlb: props.sgAlb,
      sgEp: props.sgEp,
      ssmEp: props.ssmEp,
      ssmMessagesEp: props.ssmMessagesEp,
      ec2MessagesEp: props.ec2MessagesEp,
    });

    // ACM (ap-northeast-1)
    const apne1Acm = new Acm(this, "Apne1Acm", {
      hosted_zone_id: this.node.tryGetContext("hosted_zone_id_for_alb"),
      zone_apnex_name: this.node.tryGetContext("zone_apnex_name_for_alb"),
      issue_domain_name: this.node.tryGetContext("issue_domain_name_for_alb"),
    });

    // IAM Role
    const ec2Role = new IamRole(this, "Ec2Role", {
      roleInfo: props.ec2Role,
    });

    // EC2
    const ec2 = new Ec2(this, "Ec2", {
      pseudo: pseudo,
      ec2Role: ec2Role.iamRole,
      ec2Sg: nw.ec2Sg,
      subnets: nw.subnetObject,
      keyPair: props.keyPair,
      ec2: props.ec2,
    });
    ec2.node.addDependency(nw);

    // ALB & Route 53 Record
    const alb = new Alb(this, "Alb", {
      targetGrp: props.targetGrp,
      ec2Instance: ec2.ec2Instance,
      vpc: nw.vpc,
      albSg: nw.albSg,
      subnets: nw.subnetObject,
      alb: props.alb,
      albCert: apne1Acm.certificate,
      albHostedZoneId: this.node.tryGetContext("hosted_zone_id_for_alb"),
      albFqdn: this.node.tryGetContext("fqdn_for_alb"),
    });

    // S3 Bucket
    const s3 = new S3Bucket(this, "S3Bucket", {
      bucket: props.bucket,
    });

    // CloudFront
    const cf = new CloudFront(this, "CfDist", {
      bucket: s3.bucket,
      cfFqdn: this.node.tryGetContext("fqdn_for_cf"),
      hosted_zone_id: this.node.tryGetContext("hosted_zone_id_for_cf"),
      zone_apnex_name: this.node.tryGetContext("zone_apnex_name_for_cf"),
      albFqdn: this.node.tryGetContext("fqdn_for_alb"),
      cfCert: props.cfCert,
      edgeFunction: props.function,
    });
  }
}
