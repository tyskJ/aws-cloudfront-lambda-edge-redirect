/*
╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║ CloudFront Lambda@Edge redirect Stack - Cloud Development Kit network.ts                                                                           ║
╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
║ This construct creates an L1 Construct VPC and an L1 Construct Subnet.                                                                             ║
╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
*/

import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import { vpcInfo } from "../../parameter";
import { subnetInfo } from "../../parameter";
import { subnetKey } from "../../parameter";
import { naclInfo } from "../../parameter";
import { rtbInfo } from "../../parameter";
import { gwVpcEpInfo } from "../../parameter";
import { secgInfo } from "../../parameter";
import { inVpcEpInfo } from "../../parameter";
import * as ec2 from "aws-cdk-lib/aws-ec2";

export interface INetworkProps extends cdk.StackProps {
  pseudo: cdk.ScopedAws;
  vpc: vpcInfo;
  subnets: subnetInfo;
  nacl: naclInfo;
  rtbPub: rtbInfo;
  rtbPri: rtbInfo;
  s3GwEp: gwVpcEpInfo;
  sgEc2: secgInfo;
  sgAlb: secgInfo;
  sgEp: secgInfo;
  ssmEp: inVpcEpInfo;
  ssmMessagesEp: inVpcEpInfo;
  ec2MessagesEp: inVpcEpInfo;
}

export interface GwProps {
  igwId?: string;
  ngwId?: string;
}

export class Network extends Construct {
  public readonly vpc: ec2.CfnVPC;
  public readonly subnetObject: Record<subnetKey, ec2.CfnSubnet>;
  public readonly ec2Sg: ec2.CfnSecurityGroup;
  public readonly albSg: ec2.CfnSecurityGroup;

  constructor(scope: Construct, id: string, props: INetworkProps) {
    super(scope, id);

    // VPC
    this.vpc = new ec2.CfnVPC(this, props.vpc.id, {
      cidrBlock: props.vpc.cidrBlock,
      enableDnsHostnames: props.vpc.dnsHost,
      enableDnsSupport: props.vpc.dnsSupport,
    });
    for (const tag of props.vpc.tags) {
      cdk.Tags.of(this.vpc).add(tag.key, tag.value);
    }

    // Subnets
    this.subnetObject = this.createSubnet(
      this,
      props.pseudo,
      this.vpc,
      props.subnets
    );

    // nacl
    this.createNacl(this, this.vpc, this.subnetObject, props.nacl);

    // Internet Gateway
    const igw = new ec2.CfnInternetGateway(this, "igw", {
      tags: [
        {
          key: "Name",
          value: "igw",
        },
      ],
    });
    const igwassoc = new ec2.CfnVPCGatewayAttachment(this, "igw-attach", {
      vpcId: this.vpc.attrVpcId,
      internetGatewayId: igw.attrInternetGatewayId,
    });

    // Route Table
    const publicRtb = this.createRouteTable(
      this,
      this.vpc,
      props.rtbPub,
      this.subnetObject,
      { igwId: igw.attrInternetGatewayId }
    );
    publicRtb.addDependency(igwassoc);
    const privateRtb = this.createRouteTable(
      this,
      this.vpc,
      props.rtbPri,
      this.subnetObject,
      {}
    );

    // S3 Gateway Endpoint
    const s3Vpce = new ec2.CfnVPCEndpoint(this, props.s3GwEp.id, {
      vpcId: this.vpc.attrVpcId,
      serviceName: `com.amazonaws.${props.pseudo.region}.${props.s3GwEp.service}`,
      routeTableIds: [privateRtb.attrRouteTableId],
    });

    // Security Group
    this.ec2Sg = this.createSecurityGroup(this, this.vpc, props.sgEc2);
    this.albSg = this.createSecurityGroup(this, this.vpc, props.sgAlb);
    const epSg = this.createSecurityGroup(this, this.vpc, props.sgEp);

    // Security Group Ingress
    new ec2.CfnSecurityGroupIngress(this, "httpsInSgAlb", {
      groupId: this.albSg.attrGroupId,
      ipProtocol: "tcp",
      cidrIp: "0.0.0.0/0",
      description: "HTTPS From Unrestricted",
      fromPort: 443,
      toPort: 443,
    });
    new ec2.CfnSecurityGroupIngress(this, "httpsInSgEp", {
      groupId: epSg.attrGroupId,
      ipProtocol: "tcp",
      sourceSecurityGroupId: this.ec2Sg.attrGroupId,
      description: "HTTPS From EC2 SG",
      fromPort: 443,
      toPort: 443,
    });
    new ec2.CfnSecurityGroupIngress(this, "httpInSgEc2", {
      groupId: this.ec2Sg.attrGroupId,
      ipProtocol: "tcp",
      sourceSecurityGroupId: this.albSg.attrGroupId,
      description: "HTTP From ALB SG",
      fromPort: 80,
      toPort: 80,
    });

    // Interface Endpoint
    this.createInterfaceEndpoint(
      this,
      props.pseudo,
      this.vpc,
      this.subnetObject,
      [epSg.attrGroupId],
      props.ssmEp
    );
    this.createInterfaceEndpoint(
      this,
      props.pseudo,
      this.vpc,
      this.subnetObject,
      [epSg.attrGroupId],
      props.ssmMessagesEp
    );
    this.createInterfaceEndpoint(
      this,
      props.pseudo,
      this.vpc,
      this.subnetObject,
      [epSg.attrGroupId],
      props.ec2MessagesEp
    );
  }
  /*
  ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Method (private)                                                                                                                                 ║
  ╠═══════════════════════════╤═══════════════════════════════════╤══════════════════════════════════════════════════════════════════════════════════╣
  ║ createSubnet              │ Record<subnetKey, ec2.CfnSubnet>  │ Method to create Subnet for L1 constructs.                                       ║
  ║ createNacl                │ void                              │ Method to create Nacl for L1 constructs.                                         ║
  ║ createRouteTable          │ ec2.CfnRouteTable                 │ Method to create RouteTable for L1 constructs.                                   ║
  ║ createSecurityGroup       │ ec2.CfnSecurityGroup              │ Method to create SecurityGroup for L1 constructs.                                ║
  ║ createInterfaceEndpoint   │ ec2.CfnVPCEndpoint                │ Method to create Interface Endpoint for L1 constructs.                           ║
  ╚═══════════════════════════╧═══════════════════════════════════╧══════════════════════════════════════════════════════════════════════════════════╝
  */
  private createSubnet(
    scope: Construct,
    pseudo: cdk.ScopedAws,
    vpc: ec2.CfnVPC,
    subnets: subnetInfo
  ): Record<subnetKey, ec2.CfnSubnet> {
    const subnetsObject = {} as Record<subnetKey, ec2.CfnSubnet>;
    for (const subnetDef of subnets) {
      const subnet = new ec2.CfnSubnet(scope, subnetDef.id, {
        vpcId: vpc.attrVpcId,
        cidrBlock: subnetDef.cidrBlock,
        availabilityZone: `${pseudo.region}${subnetDef.availabilityZone}`,
        mapPublicIpOnLaunch: subnetDef.mapPublicIpOnLaunch,
      });
      for (const tag of subnetDef.tags) {
        cdk.Tags.of(subnet).add(tag.key, tag.value);
      }
      subnetsObject[subnetDef.key] = subnet;
    }
    return subnetsObject;
  }

  private createNacl(
    scope: Construct,
    vpc: ec2.CfnVPC,
    subnets: Record<subnetKey, ec2.CfnSubnet>,
    nacls: naclInfo
  ): void {
    const nacl = new ec2.CfnNetworkAcl(scope, nacls.id, {
      vpcId: vpc.attrVpcId,
    });
    for (const tag of nacls.tags) {
      cdk.Tags.of(nacl).add(tag.key, tag.value);
    }
    for (const rules of nacls.rules) {
      switch (rules.protocol) {
        case -1:
          new ec2.CfnNetworkAclEntry(scope, rules.id, {
            networkAclId: nacl.attrId,
            protocol: rules.protocol,
            ruleAction: rules.ruleAction,
            ruleNumber: rules.ruleNumber,
            cidrBlock: rules.cidrBlock,
            egress: rules.egress,
          });
          break;
        case 6:
        case 17:
          if (rules.portRange === undefined) {
            throw new Error("Port Range is required");
          }
          new ec2.CfnNetworkAclEntry(scope, rules.id, {
            networkAclId: nacl.attrId,
            protocol: rules.protocol,
            ruleAction: rules.ruleAction,
            ruleNumber: rules.ruleNumber,
            cidrBlock: rules.cidrBlock,
            egress: rules.egress,
            portRange: {
              from: rules.portRange.fromPort,
              to: rules.portRange.toPort,
            },
          });
          break;
        case 1:
          if (rules.icmp === undefined) {
            throw new Error("ICMP Range is required");
          }
          new ec2.CfnNetworkAclEntry(scope, rules.id, {
            networkAclId: nacl.attrId,
            protocol: rules.protocol,
            ruleAction: rules.ruleAction,
            ruleNumber: rules.ruleNumber,
            cidrBlock: rules.cidrBlock,
            egress: rules.egress,
            icmp: {
              code: rules.icmp.code,
              type: rules.icmp.type,
            },
          });
          break;
        default:
          const _: never = rules.protocol;
          throw new Error("Invalid Protocol");
      }
    }
    for (const association of nacls.assocSubnets) {
      new ec2.CfnSubnetNetworkAclAssociation(scope, association.id, {
        subnetId: subnets[association.key].attrSubnetId,
        networkAclId: nacl.attrId,
      });
    }
  }

  private createRouteTable(
    scope: Construct,
    vpc: ec2.CfnVPC,
    rtbs: rtbInfo,
    subnets: Record<subnetKey, ec2.CfnSubnet>,
    gwId: GwProps
  ): ec2.CfnRouteTable {
    const routeTable = new ec2.CfnRouteTable(scope, rtbs.id, {
      vpcId: vpc.attrVpcId,
    });
    for (const tag of rtbs.tags) {
      cdk.Tags.of(routeTable).add(tag.key, tag.value);
    }
    if (rtbs.routes) {
      for (const route of rtbs.routes) {
        switch (route.type) {
          case "igw":
            for (const dest of route.destinations) {
              const route = new ec2.CfnRoute(scope, dest.id, {
                routeTableId: routeTable.attrRouteTableId,
                destinationCidrBlock: dest.value,
                gatewayId: gwId.igwId,
              });
            }
            break;
          default:
            throw new Error("Invalid Route Type");
        }
      }
    }
    for (const assocSub of rtbs.assocSubnets) {
      new ec2.CfnSubnetRouteTableAssociation(scope, assocSub.id, {
        routeTableId: routeTable.attrRouteTableId,
        subnetId: subnets[assocSub.key].attrSubnetId,
      });
    }
    return routeTable;
  }

  private createSecurityGroup(
    scope: Construct,
    vpc: ec2.CfnVPC,
    sgs: secgInfo
  ): ec2.CfnSecurityGroup {
    const sg = new ec2.CfnSecurityGroup(scope, sgs.id, {
      vpcId: vpc.attrVpcId,
      groupDescription: sgs.description,
      groupName: sgs.sgName,
    });
    for (const tag of sgs.tags) {
      cdk.Tags.of(sg).add(tag.key, tag.value);
    }
    return sg;
  }

  private createInterfaceEndpoint(
    scope: Construct,
    pseudo: cdk.ScopedAws,
    vpc: ec2.CfnVPC,
    subnets: Record<subnetKey, ec2.CfnSubnet>,
    sgids: string[],
    ep: inVpcEpInfo
  ) {
    const subnetids: string[] = [];
    ep.mapSubnets.forEach((id) => {
      subnetids.push(subnets[id].attrSubnetId);
    });
    const endpoint = new ec2.CfnVPCEndpoint(scope, ep.id, {
      vpcId: vpc.attrVpcId,
      privateDnsEnabled: ep.privateDnsEnable,
      securityGroupIds: sgids,
      subnetIds: subnetids,
      vpcEndpointType: ep.endPointType,
      serviceName: `com.amazonaws.${pseudo.region}.${ep.serviceName}`,
    });
    for (const tag of ep.tags) {
      cdk.Tags.of(endpoint).add(tag.key, tag.value);
    }
  }
}
