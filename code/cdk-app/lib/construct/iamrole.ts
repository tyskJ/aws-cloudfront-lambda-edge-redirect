/*
╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║ CloudFront Lambda@Edge redirect Stack - Cloud Development Kit iamrole.ts                                                                           ║
╠════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣
║ This construct creates an L2 Construct IAM Role.                                                                                                   ║
╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
*/
import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as iam from "aws-cdk-lib/aws-iam";
import { iamRoleInfo } from "../../parameter";

export interface IRoleProps extends cdk.StackProps {
  roleInfo: iamRoleInfo;
  managedPolicy?: iam.ManagedPolicy[];
}

export class IamRole extends Construct {
  public readonly iamRole: iam.Role;

  constructor(scope: Construct, id: string, props: IRoleProps) {
    super(scope, id);

    // Role
    if (props.managedPolicy) {
      this.iamRole = this.createIamRole(
        this,
        props.roleInfo,
        props.managedPolicy
      );
    } else {
      this.iamRole = this.createIamRole(this, props.roleInfo);
    }
  }
  /*
  ╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Method (private)                                                                                               ║
  ╠═══════════════════════════╤═════════════════════════╤══════════════════════════════════════════════════════════╣
  ║ createIamRole             │ iam.Role                │ Method to create IAM Role for L2 constructs.             ║
  ╚═══════════════════════════╧═════════════════════════╧══════════════════════════════════════════════════════════╝
  */
  private createIamRole(
    scope: Construct,
    roleInfo: iamRoleInfo,
    managedPolicy?: iam.ManagedPolicy[]
  ): iam.Role {
    const assumedBy = Array.isArray(roleInfo.assumed)
      ? new iam.CompositePrincipal(
          ...roleInfo.assumed.map(
            (service) => new iam.ServicePrincipal(service)
          )
        )
      : new iam.ServicePrincipal(roleInfo.assumed);
    const iamRole = new iam.Role(scope, roleInfo.id, {
      roleName: roleInfo.roleName,
      description: roleInfo.description,
      assumedBy: assumedBy,
    });
    if (roleInfo.awsManagedPolicyAdd && roleInfo.awsManagedPolicyName) {
      for (const amp of roleInfo.awsManagedPolicyName) {
        iamRole.addManagedPolicy(
          iam.ManagedPolicy.fromAwsManagedPolicyName(amp.policyName)
        );
      }
    }
    if (roleInfo.customManagedPolicyAdd && managedPolicy) {
      for (const cmp of managedPolicy) {
        iamRole.addManagedPolicy(cmp);
      }
    }
    for (const tag of roleInfo.tags) {
      cdk.Tags.of(iamRole).add(tag.key, tag.value);
    }
    return iamRole;
  }
}
