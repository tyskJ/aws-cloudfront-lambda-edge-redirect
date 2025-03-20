#!/usr/bin/env node
import * as cdk from "aws-cdk-lib";
import { devParameter } from "../parameter";
import { VirginiaStack } from "../lib/stack/virginiaStack";
import { TokyoStack } from "../lib/stack/tokyoStack";

const app = new cdk.App();

// Virginia Stack
const virginia = new VirginiaStack(app, "VirginiaStack", {
  env: { region: "us-east-1" },
  crossRegionReferences: true,
  ...devParameter,
  description: "Virginia Region Stack.",
});
cdk.Tags.of(virginia).add("Env", "Virginia");

// Tokyo Stack
const tokyo = new TokyoStack(app, "TokyoStack", {
  env: { region: "ap-northeast-1" },
  crossRegionReferences: true,
  ...devParameter,
  cfCert: virginia.CfCertificate,
  function: virginia.lambdaFn,
  description: "Tokyo Region Stack.",
});
cdk.Tags.of(tokyo).add("Env", devParameter.EnvName);
