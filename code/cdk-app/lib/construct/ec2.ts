/*
╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║ CloudFront Lambda@Edge redirect Stack - Cloud Development Kit ec2.ts                                                                               ║
╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
║ This construct creates an L1 Construct KeyPair, Instance Profile, EC2 Instance.                                                                    ║
╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
*/
import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as iam from "aws-cdk-lib/aws-iam";
import { subnetKey } from "../../parameter";
import { keypairInfo } from "../../parameter";
import { ec2Info } from "../../parameter";
import * as fs from "fs";
import * as path from "path";

export interface Ec2Props extends cdk.StackProps {
  pseudo: cdk.ScopedAws;
  ec2Role: iam.Role;
  ec2Sg: ec2.CfnSecurityGroup;
  subnets: Record<subnetKey, ec2.CfnSubnet>;
  keyPair: keypairInfo;
  ec2: ec2Info;
}

export class Ec2 extends Construct {
  public readonly ec2Instance: ec2.CfnInstance;

  constructor(scope: Construct, id: string, props: Ec2Props) {
    super(scope, id);

    // Key Pair
    const keyPair = new ec2.CfnKeyPair(this, props.keyPair.id, {
      keyName: props.keyPair.keyName,
      keyType: props.keyPair.keyType,
      keyFormat: props.keyPair.keyFormat,
    });
    if (props.keyPair.removalPolicy) {
      keyPair.applyRemovalPolicy(cdk.RemovalPolicy.DESTROY);
    }
    for (const tag of props.keyPair.tags) {
      cdk.Tags.of(keyPair).add(tag.key, tag.value);
    }
    new cdk.CfnOutput(this, "Get" + keyPair.keyName + "Command", {
      value: `aws ssm get-parameter --name "/ec2/keypair/${keyPair.attrKeyPairId}:1" --region ${props.pseudo.region} --with-decryption --query Parameter.Value --output text --profile admin > keypair.pem && chmod 400 keypair.pem`,
    });

    // Instance Profile
    const instanceProfile = new iam.CfnInstanceProfile(
      this,
      "instanceprofile",
      {
        roles: [props.ec2Role.roleName],
        instanceProfileName: props.ec2Role.roleName,
      }
    );

    // EC2 Instance
    const script = fs.readFileSync(
      path.join(`${__dirname}`, "../assets/userdata.sh"),
      "utf8"
    );
    const userData = ec2.UserData.forLinux({ shebang: "#!/bin/bash" });
    userData.addCommands(...script.split("\n"));
    this.ec2Instance = new ec2.CfnInstance(this, props.ec2.id, {
      instanceType: props.ec2.instanceType,
      keyName: keyPair.keyName,
      iamInstanceProfile: instanceProfile.ref,
      imageId: ec2.MachineImage.latestAmazonLinux2023().getImage(this).imageId,
      disableApiTermination: props.ec2.apiTerm,
      subnetId: props.subnets[props.ec2.subnetKey].attrSubnetId,
      securityGroupIds: [props.ec2Sg.attrGroupId],
      ebsOptimized: props.ec2.ebsOpt,
      userData: cdk.Fn.base64(userData.render()),
      blockDeviceMappings: [
        {
          deviceName: props.ec2.deviceName,
          ebs: {
            deleteOnTermination: true,
            volumeSize: props.ec2.volSize,
            volumeType: ec2.EbsDeviceVolumeType.GP3,
            encrypted: true,
          },
        },
      ],
    });
    for (const tag of props.ec2.tags) {
      cdk.Tags.of(this.ec2Instance).add(tag.key, tag.value);
    }
  }
}
