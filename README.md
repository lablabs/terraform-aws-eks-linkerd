# AWS EKS Linkerd Terraform module

[<img src="https://lablabs.io/static/ll-logo.png" width=350px>](https://lablabs.io/)

We help companies build, run, deploy and scale software and infrastructure by embracing the right technologies and principles. Check out our website at https://lablabs.io/

---

[![Terraform validate](https://github.com/lablabs/terraform-aws-eks-linkerd/actions/workflows/validate.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-linkerd/actions/workflows/validate.yaml)
[![pre-commit](https://github.com/lablabs/terraform-aws-linkerd/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-linkerd/actions/workflows/pre-commit.yml)

## Description

A Terraform module to deploy the [linkerd2](https://linkerd.io) on Amazon EKS cluster.

## Related Projects

Check out other [terraform kubernetes addons](https://github.com/orgs/lablabs/repositories?q=terraform-aws-eks&type=public&language=&sort=).

## Deployment methods

### Helm
Deploy Helm chart via Helm resource (default method, set `enabled = true`)

> **Note**
>
> There is a static wait time between crds and control plane helm release which in a rare conditions might not be a bulletproof solution. Feel free to increase the wait time by setting `crds_helm_wait_for_crds_duration` variable to suits your needs.

### Argo Kubernetes
Deploy Helm chart as ArgoCD Application via Kubernetes manifest resource (set `enabled = true` and `argo_enabled = true`)

> **Note**
>
> We are leveraging `kubernetes_manifest` `wait` mechanism to observer ArgoCD `Application` status with these defaults, see `argo.tf:158`. Feel free to override these using `crds_argo_kubernetes_manifest_wait_fields` variable to suits your needs.

> **Warning**
>
> When deploying with ArgoCD application, Kubernetes terraform provider requires access to Kubernetes cluster API during plan time. This introduces potential issue when you want to deploy the cluster with this addon at the same time, during the same Terraform run.
>
> To overcome this issue, the module deploys the ArgoCD application object using the Helm provider, which does not require API access during plan. If you want to deploy the application using this workaround, you can set the `argo_helm_enabled` variable to `true`.

### Argo Helm
Deploy Helm chart as ArgoCD Application via Helm resource (set `enabled = true`, `argo_enabled = true` and `argo_helm_enabled = true`)

> **Note**
>
> There is a retry policy set on the control plane ArgoCD `Application`, see `argo.tf:89` to retry the installation of the control plane until crds are available which in a rare conditions might not be a bulletproof solution. Feel free to override these using `control_plane_argo_spec` variable to suits your needs.

## Examples

See [Basic example](examples/basic/README.md) for further information.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.19.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.6.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.11.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.8.0 |
| <a name="requirement_utils"></a> [utils](#requirement\_utils) | >= 0.17.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.control_plane](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.control_plane_argo_application](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.crds](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.crds_argo_application](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_manifest.control_plane_argo_application](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.crds_argo_application](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [time_sleep.wait_for_crds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [utils_deep_merge_yaml.control_plane_argo_helm_values](https://registry.terraform.io/providers/cloudposse/utils/latest/docs/data-sources/deep_merge_yaml) | data source |
| [utils_deep_merge_yaml.control_plane_values](https://registry.terraform.io/providers/cloudposse/utils/latest/docs/data-sources/deep_merge_yaml) | data source |
| [utils_deep_merge_yaml.crds_argo_helm_values](https://registry.terraform.io/providers/cloudposse/utils/latest/docs/data-sources/deep_merge_yaml) | data source |
| [utils_deep_merge_yaml.crds_values](https://registry.terraform.io/providers/cloudposse/utils/latest/docs/data-sources/deep_merge_yaml) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argo_apiversion"></a> [argo\_apiversion](#input\_argo\_apiversion) | ArgoCD Appliction apiVersion | `string` | `"argoproj.io/v1alpha1"` | no |
| <a name="input_argo_destination_server"></a> [argo\_destination\_server](#input\_argo\_destination\_server) | Destination server for ArgoCD Application | `string` | `"https://kubernetes.default.svc"` | no |
| <a name="input_argo_enabled"></a> [argo\_enabled](#input\_argo\_enabled) | If set to true, the module will be deployed as ArgoCD application, otherwise it will be deployed as a Helm release | `bool` | `false` | no |
| <a name="input_argo_helm_enabled"></a> [argo\_helm\_enabled](#input\_argo\_helm\_enabled) | If set to true, the ArgoCD Application manifest will be deployed using Kubernetes provider as a Helm release. Otherwise it'll be deployed as a Kubernetes manifest. See Readme for more info | `bool` | `false` | no |
| <a name="input_argo_info"></a> [argo\_info](#input\_argo\_info) | ArgoCD info manifest parameter | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | <pre>[<br>  {<br>    "name": "terraform",<br>    "value": "true"<br>  }<br>]</pre> | no |
| <a name="input_argo_namespace"></a> [argo\_namespace](#input\_argo\_namespace) | Namespace to deploy ArgoCD application CRD to | `string` | `"argo"` | no |
| <a name="input_argo_project"></a> [argo\_project](#input\_argo\_project) | ArgoCD Application project | `string` | `"default"` | no |
| <a name="input_control_plane_argo_helm_values"></a> [control\_plane\_argo\_helm\_values](#input\_control\_plane\_argo\_helm\_values) | Value overrides to use when deploying argo application object with helm | `string` | `""` | no |
| <a name="input_control_plane_argo_kubernetes_manifest_computed_fields"></a> [control\_plane\_argo\_kubernetes\_manifest\_computed\_fields](#input\_control\_plane\_argo\_kubernetes\_manifest\_computed\_fields) | List of paths of fields to be handled as "computed". The user-configured value for the field will be overridden by any different value returned by the API after apply. | `list(string)` | <pre>[<br>  "metadata.labels",<br>  "metadata.annotations"<br>]</pre> | no |
| <a name="input_control_plane_argo_kubernetes_manifest_field_manager_force_conflicts"></a> [control\_plane\_argo\_kubernetes\_manifest\_field\_manager\_force\_conflicts](#input\_control\_plane\_argo\_kubernetes\_manifest\_field\_manager\_force\_conflicts) | Forcibly override any field manager conflicts when applying the kubernetes manifest resource | `bool` | `false` | no |
| <a name="input_control_plane_argo_kubernetes_manifest_field_manager_name"></a> [control\_plane\_argo\_kubernetes\_manifest\_field\_manager\_name](#input\_control\_plane\_argo\_kubernetes\_manifest\_field\_manager\_name) | The name of the field manager to use when applying the kubernetes manifest resource. Defaults to Terraform | `string` | `"Terraform"` | no |
| <a name="input_control_plane_argo_kubernetes_manifest_wait_fields"></a> [control\_plane\_argo\_kubernetes\_manifest\_wait\_fields](#input\_control\_plane\_argo\_kubernetes\_manifest\_wait\_fields) | A map of fields and a corresponding regular expression with a pattern to wait for. The provider will wait until the field matches the regular expression. Use * for any value. | `map(string)` | `{}` | no |
| <a name="input_control_plane_argo_metadata"></a> [control\_plane\_argo\_metadata](#input\_control\_plane\_argo\_metadata) | ArgoCD Application metadata configuration. Override or create additional metadata parameters | `any` | <pre>{<br>  "finalizers": [<br>    "resources-finalizer.argocd.argoproj.io"<br>  ]<br>}</pre> | no |
| <a name="input_control_plane_argo_spec"></a> [control\_plane\_argo\_spec](#input\_control\_plane\_argo\_spec) | ArgoCD Application spec configuration. Override or create additional spec parameters | `any` | `{}` | no |
| <a name="input_control_plane_argo_sync_policy"></a> [control\_plane\_argo\_sync\_policy](#input\_control\_plane\_argo\_sync\_policy) | ArgoCD syncPolicy manifest parameter | `any` | `{}` | no |
| <a name="input_control_plane_helm_atomic"></a> [control\_plane\_helm\_atomic](#input\_control\_plane\_helm\_atomic) | If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used | `bool` | `false` | no |
| <a name="input_control_plane_helm_chart_name"></a> [control\_plane\_helm\_chart\_name](#input\_control\_plane\_helm\_chart\_name) | Helm chart name to be installed | `string` | `"linkerd-control-plane"` | no |
| <a name="input_control_plane_helm_chart_version"></a> [control\_plane\_helm\_chart\_version](#input\_control\_plane\_helm\_chart\_version) | Version of the Helm chart | `string` | `"1.9.4"` | no |
| <a name="input_control_plane_helm_cleanup_on_fail"></a> [control\_plane\_helm\_cleanup\_on\_fail](#input\_control\_plane\_helm\_cleanup\_on\_fail) | Allow deletion of new resources created in this helm upgrade when upgrade fails | `bool` | `false` | no |
| <a name="input_control_plane_helm_dependency_update"></a> [control\_plane\_helm\_dependency\_update](#input\_control\_plane\_helm\_dependency\_update) | Runs helm dependency update before installing the chart | `bool` | `false` | no |
| <a name="input_control_plane_helm_description"></a> [control\_plane\_helm\_description](#input\_control\_plane\_helm\_description) | Set helm release description attribute (visible in the history) | `string` | `""` | no |
| <a name="input_control_plane_helm_devel"></a> [control\_plane\_helm\_devel](#input\_control\_plane\_helm\_devel) | Use helm chart development versions, too. Equivalent to version '>0.0.0-0'. If version is set, this is ignored | `bool` | `false` | no |
| <a name="input_control_plane_helm_disable_openapi_validation"></a> [control\_plane\_helm\_disable\_openapi\_validation](#input\_control\_plane\_helm\_disable\_openapi\_validation) | If set, the installation process will not validate rendered helm templates against the Kubernetes OpenAPI Schema | `bool` | `false` | no |
| <a name="input_control_plane_helm_disable_webhooks"></a> [control\_plane\_helm\_disable\_webhooks](#input\_control\_plane\_helm\_disable\_webhooks) | Prevent helm chart hooks from running | `bool` | `false` | no |
| <a name="input_control_plane_helm_force_update"></a> [control\_plane\_helm\_force\_update](#input\_control\_plane\_helm\_force\_update) | Force helm resource update through delete/recreate if needed | `bool` | `false` | no |
| <a name="input_control_plane_helm_keyring"></a> [control\_plane\_helm\_keyring](#input\_control\_plane\_helm\_keyring) | Location of public keys used for verification. Used only if helm\_package\_verify is true | `string` | `"~/.gnupg/pubring.gpg"` | no |
| <a name="input_control_plane_helm_lint"></a> [control\_plane\_helm\_lint](#input\_control\_plane\_helm\_lint) | Run the helm chart linter during the plan | `bool` | `false` | no |
| <a name="input_control_plane_helm_package_verify"></a> [control\_plane\_helm\_package\_verify](#input\_control\_plane\_helm\_package\_verify) | Verify the package before installing it. Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart | `bool` | `false` | no |
| <a name="input_control_plane_helm_postrender"></a> [control\_plane\_helm\_postrender](#input\_control\_plane\_helm\_postrender) | Value block with a path to a binary file to run after helm renders the manifest which can alter the manifest contents | `map(any)` | `{}` | no |
| <a name="input_control_plane_helm_recreate_pods"></a> [control\_plane\_helm\_recreate\_pods](#input\_control\_plane\_helm\_recreate\_pods) | Perform pods restart during helm upgrade/rollback | `bool` | `false` | no |
| <a name="input_control_plane_helm_release_max_history"></a> [control\_plane\_helm\_release\_max\_history](#input\_control\_plane\_helm\_release\_max\_history) | Maximum number of release versions stored per release | `number` | `0` | no |
| <a name="input_control_plane_helm_release_name"></a> [control\_plane\_helm\_release\_name](#input\_control\_plane\_helm\_release\_name) | Helm release name | `string` | `"linkerd-control-plane"` | no |
| <a name="input_control_plane_helm_render_subchart_notes"></a> [control\_plane\_helm\_render\_subchart\_notes](#input\_control\_plane\_helm\_render\_subchart\_notes) | If set, render helm subchart notes along with the parent | `bool` | `true` | no |
| <a name="input_control_plane_helm_replace"></a> [control\_plane\_helm\_replace](#input\_control\_plane\_helm\_replace) | Re-use the given name of helm release, only if that name is a deleted release which remains in the history. This is unsafe in production | `bool` | `false` | no |
| <a name="input_control_plane_helm_reset_values"></a> [control\_plane\_helm\_reset\_values](#input\_control\_plane\_helm\_reset\_values) | When upgrading, reset the values to the ones built into the helm chart | `bool` | `false` | no |
| <a name="input_control_plane_helm_reuse_values"></a> [control\_plane\_helm\_reuse\_values](#input\_control\_plane\_helm\_reuse\_values) | When upgrading, reuse the last helm release's values and merge in any overrides. If 'helm\_reset\_values' is specified, this is ignored | `bool` | `false` | no |
| <a name="input_control_plane_helm_set_sensitive"></a> [control\_plane\_helm\_set\_sensitive](#input\_control\_plane\_helm\_set\_sensitive) | Value block with custom sensitive values to be merged with the values yaml that won't be exposed in the plan's diff | `map(any)` | `{}` | no |
| <a name="input_control_plane_helm_skip_crds"></a> [control\_plane\_helm\_skip\_crds](#input\_control\_plane\_helm\_skip\_crds) | If set, no CRDs will be installed before helm release | `bool` | `false` | no |
| <a name="input_control_plane_helm_timeout"></a> [control\_plane\_helm\_timeout](#input\_control\_plane\_helm\_timeout) | Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks) | `number` | `300` | no |
| <a name="input_control_plane_helm_wait"></a> [control\_plane\_helm\_wait](#input\_control\_plane\_helm\_wait) | Will wait until all helm release resources are in a ready state before marking the release as successful. It will wait for as long as timeout | `bool` | `false` | no |
| <a name="input_control_plane_helm_wait_for_jobs"></a> [control\_plane\_helm\_wait\_for\_jobs](#input\_control\_plane\_helm\_wait\_for\_jobs) | If wait is enabled, will wait until all helm Jobs have been completed before marking the release as successful. It will wait for as long as timeout | `bool` | `false` | no |
| <a name="input_control_plane_settings"></a> [control\_plane\_settings](#input\_control\_plane\_settings) | Additional helm sets which will be passed to the Helm chart values, see https://artifacthub.io/packages/helm/linkerd2/linkerd2 | `map(any)` | `{}` | no |
| <a name="input_control_plane_values"></a> [control\_plane\_values](#input\_control\_plane\_values) | Additional yaml encoded values which will be passed to the Helm chart, see https://artifacthub.io/packages/helm/linkerd2/linkerd2 | `string` | `""` | no |
| <a name="input_crds_argo_helm_values"></a> [crds\_argo\_helm\_values](#input\_crds\_argo\_helm\_values) | Value overrides to use when deploying argo application object with helm | `string` | `""` | no |
| <a name="input_crds_argo_kubernetes_manifest_computed_fields"></a> [crds\_argo\_kubernetes\_manifest\_computed\_fields](#input\_crds\_argo\_kubernetes\_manifest\_computed\_fields) | List of paths of fields to be handled as "computed". The user-configured value for the field will be overridden by any different value returned by the API after apply. | `list(string)` | <pre>[<br>  "metadata.labels",<br>  "metadata.annotations"<br>]</pre> | no |
| <a name="input_crds_argo_kubernetes_manifest_field_manager_force_conflicts"></a> [crds\_argo\_kubernetes\_manifest\_field\_manager\_force\_conflicts](#input\_crds\_argo\_kubernetes\_manifest\_field\_manager\_force\_conflicts) | Forcibly override any field manager conflicts when applying the kubernetes manifest resource | `bool` | `false` | no |
| <a name="input_crds_argo_kubernetes_manifest_field_manager_name"></a> [crds\_argo\_kubernetes\_manifest\_field\_manager\_name](#input\_crds\_argo\_kubernetes\_manifest\_field\_manager\_name) | The name of the field manager to use when applying the kubernetes manifest resource. Defaults to Terraform | `string` | `"Terraform"` | no |
| <a name="input_crds_argo_kubernetes_manifest_wait_fields"></a> [crds\_argo\_kubernetes\_manifest\_wait\_fields](#input\_crds\_argo\_kubernetes\_manifest\_wait\_fields) | A map of fields and a corresponding regular expression with a pattern to wait for. The provider will wait until the field matches the regular expression. Use * for any value. | `map(string)` | `{}` | no |
| <a name="input_crds_argo_metadata"></a> [crds\_argo\_metadata](#input\_crds\_argo\_metadata) | ArgoCD Application metadata configuration. Override or create additional metadata parameters | `any` | <pre>{<br>  "finalizers": [<br>    "resources-finalizer.argocd.argoproj.io"<br>  ]<br>}</pre> | no |
| <a name="input_crds_argo_spec"></a> [crds\_argo\_spec](#input\_crds\_argo\_spec) | ArgoCD Application spec configuration. Override or create additional spec parameters | `any` | `{}` | no |
| <a name="input_crds_argo_sync_policy"></a> [crds\_argo\_sync\_policy](#input\_crds\_argo\_sync\_policy) | ArgoCD syncPolicy manifest parameter | `any` | `{}` | no |
| <a name="input_crds_helm_atomic"></a> [crds\_helm\_atomic](#input\_crds\_helm\_atomic) | If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used | `bool` | `false` | no |
| <a name="input_crds_helm_chart_name"></a> [crds\_helm\_chart\_name](#input\_crds\_helm\_chart\_name) | Helm chart name to be installed | `string` | `"linkerd-crds"` | no |
| <a name="input_crds_helm_chart_version"></a> [crds\_helm\_chart\_version](#input\_crds\_helm\_chart\_version) | Version of the Helm chart | `string` | `"1.4.0"` | no |
| <a name="input_crds_helm_cleanup_on_fail"></a> [crds\_helm\_cleanup\_on\_fail](#input\_crds\_helm\_cleanup\_on\_fail) | Allow deletion of new resources created in this helm upgrade when upgrade fails | `bool` | `false` | no |
| <a name="input_crds_helm_dependency_update"></a> [crds\_helm\_dependency\_update](#input\_crds\_helm\_dependency\_update) | Runs helm dependency update before installing the chart | `bool` | `false` | no |
| <a name="input_crds_helm_description"></a> [crds\_helm\_description](#input\_crds\_helm\_description) | Set helm release description attribute (visible in the history) | `string` | `""` | no |
| <a name="input_crds_helm_devel"></a> [crds\_helm\_devel](#input\_crds\_helm\_devel) | Use helm chart development versions, too. Equivalent to version '>0.0.0-0'. If version is set, this is ignored | `bool` | `false` | no |
| <a name="input_crds_helm_disable_openapi_validation"></a> [crds\_helm\_disable\_openapi\_validation](#input\_crds\_helm\_disable\_openapi\_validation) | If set, the installation process will not validate rendered helm templates against the Kubernetes OpenAPI Schema | `bool` | `false` | no |
| <a name="input_crds_helm_disable_webhooks"></a> [crds\_helm\_disable\_webhooks](#input\_crds\_helm\_disable\_webhooks) | Prevent helm chart hooks from running | `bool` | `false` | no |
| <a name="input_crds_helm_force_update"></a> [crds\_helm\_force\_update](#input\_crds\_helm\_force\_update) | Force helm resource update through delete/recreate if needed | `bool` | `false` | no |
| <a name="input_crds_helm_keyring"></a> [crds\_helm\_keyring](#input\_crds\_helm\_keyring) | Location of public keys used for verification. Used only if helm\_package\_verify is true | `string` | `"~/.gnupg/pubring.gpg"` | no |
| <a name="input_crds_helm_lint"></a> [crds\_helm\_lint](#input\_crds\_helm\_lint) | Run the helm chart linter during the plan | `bool` | `false` | no |
| <a name="input_crds_helm_package_verify"></a> [crds\_helm\_package\_verify](#input\_crds\_helm\_package\_verify) | Verify the package before installing it. Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart | `bool` | `false` | no |
| <a name="input_crds_helm_postrender"></a> [crds\_helm\_postrender](#input\_crds\_helm\_postrender) | Value block with a path to a binary file to run after helm renders the manifest which can alter the manifest contents | `map(any)` | `{}` | no |
| <a name="input_crds_helm_recreate_pods"></a> [crds\_helm\_recreate\_pods](#input\_crds\_helm\_recreate\_pods) | Perform pods restart during helm upgrade/rollback | `bool` | `false` | no |
| <a name="input_crds_helm_release_max_history"></a> [crds\_helm\_release\_max\_history](#input\_crds\_helm\_release\_max\_history) | Maximum number of release versions stored per release | `number` | `0` | no |
| <a name="input_crds_helm_release_name"></a> [crds\_helm\_release\_name](#input\_crds\_helm\_release\_name) | Helm release name | `string` | `"linkerd-crds"` | no |
| <a name="input_crds_helm_render_subchart_notes"></a> [crds\_helm\_render\_subchart\_notes](#input\_crds\_helm\_render\_subchart\_notes) | If set, render helm subchart notes along with the parent | `bool` | `true` | no |
| <a name="input_crds_helm_replace"></a> [crds\_helm\_replace](#input\_crds\_helm\_replace) | Re-use the given name of helm release, only if that name is a deleted release which remains in the history. This is unsafe in production | `bool` | `false` | no |
| <a name="input_crds_helm_reset_values"></a> [crds\_helm\_reset\_values](#input\_crds\_helm\_reset\_values) | When upgrading, reset the values to the ones built into the helm chart | `bool` | `false` | no |
| <a name="input_crds_helm_reuse_values"></a> [crds\_helm\_reuse\_values](#input\_crds\_helm\_reuse\_values) | When upgrading, reuse the last helm release's values and merge in any overrides. If 'helm\_reset\_values' is specified, this is ignored | `bool` | `false` | no |
| <a name="input_crds_helm_set_sensitive"></a> [crds\_helm\_set\_sensitive](#input\_crds\_helm\_set\_sensitive) | Value block with custom sensitive values to be merged with the values yaml that won't be exposed in the plan's diff | `map(any)` | `{}` | no |
| <a name="input_crds_helm_skip_crds"></a> [crds\_helm\_skip\_crds](#input\_crds\_helm\_skip\_crds) | If set, no CRDs will be installed before helm release | `bool` | `false` | no |
| <a name="input_crds_helm_timeout"></a> [crds\_helm\_timeout](#input\_crds\_helm\_timeout) | Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks) | `number` | `300` | no |
| <a name="input_crds_helm_wait"></a> [crds\_helm\_wait](#input\_crds\_helm\_wait) | Will wait until all helm release resources are in a ready state before marking the release as successful. It will wait for as long as timeout | `bool` | `false` | no |
| <a name="input_crds_helm_wait_for_crds_duration"></a> [crds\_helm\_wait\_for\_crds\_duration](#input\_crds\_helm\_wait\_for\_crds\_duration) | Time duration to delay control plane helm release creation after crds helm release. For example, `30s` for 30 seconds or `5m` for 5 minutes. Updating this value by itself will not trigger a delay. | `string` | `"30s"` | no |
| <a name="input_crds_helm_wait_for_jobs"></a> [crds\_helm\_wait\_for\_jobs](#input\_crds\_helm\_wait\_for\_jobs) | If wait is enabled, will wait until all helm Jobs have been completed before marking the release as successful. It will wait for as long as timeout | `bool` | `false` | no |
| <a name="input_crds_settings"></a> [crds\_settings](#input\_crds\_settings) | Additional helm sets which will be passed to the Helm chart values, see https://artifacthub.io/packages/helm/linkerd2/linkerd2 | `map(any)` | `{}` | no |
| <a name="input_crds_values"></a> [crds\_values](#input\_crds\_values) | Additional yaml encoded values which will be passed to the Helm chart, see https://artifacthub.io/packages/helm/linkerd2/linkerd2 | `string` | `""` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Variable indicating whether deployment is enabled | `bool` | `true` | no |
| <a name="input_helm_create_namespace"></a> [helm\_create\_namespace](#input\_helm\_create\_namespace) | Create the namespace if it does not yet exist | `bool` | `true` | no |
| <a name="input_helm_repo_ca_file"></a> [helm\_repo\_ca\_file](#input\_helm\_repo\_ca\_file) | Helm repositories cert file | `string` | `""` | no |
| <a name="input_helm_repo_cert_file"></a> [helm\_repo\_cert\_file](#input\_helm\_repo\_cert\_file) | Helm repositories cert file | `string` | `""` | no |
| <a name="input_helm_repo_key_file"></a> [helm\_repo\_key\_file](#input\_helm\_repo\_key\_file) | Helm repositories cert key file | `string` | `""` | no |
| <a name="input_helm_repo_password"></a> [helm\_repo\_password](#input\_helm\_repo\_password) | Password for HTTP basic authentication against the helm repository | `string` | `""` | no |
| <a name="input_helm_repo_url"></a> [helm\_repo\_url](#input\_helm\_repo\_url) | Helm repository | `string` | `"https://helm.linkerd.io/stable"` | no |
| <a name="input_helm_repo_username"></a> [helm\_repo\_username](#input\_helm\_repo\_username) | Username for HTTP basic authentication against the helm repository | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The K8s namespace in which the linkerd service account has been created | `string` | `"linkerd"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_control_plane_helm_release_application_metadata"></a> [control\_plane\_helm\_release\_application\_metadata](#output\_control\_plane\_helm\_release\_application\_metadata) | Argo application helm release attributes |
| <a name="output_control_plane_helm_release_metadata"></a> [control\_plane\_helm\_release\_metadata](#output\_control\_plane\_helm\_release\_metadata) | Helm release attributes |
| <a name="output_control_plane_kubernetes_application_attributes"></a> [control\_plane\_kubernetes\_application\_attributes](#output\_control\_plane\_kubernetes\_application\_attributes) | Argo kubernetes manifest attributes |
| <a name="output_crds_helm_release_application_metadata"></a> [crds\_helm\_release\_application\_metadata](#output\_crds\_helm\_release\_application\_metadata) | Argo application helm release attributes |
| <a name="output_crds_helm_release_metadata"></a> [crds\_helm\_release\_metadata](#output\_crds\_helm\_release\_metadata) | Helm release attributes |
| <a name="output_crds_kubernetes_application_attributes"></a> [crds\_kubernetes\_application\_attributes](#output\_crds\_kubernetes\_application\_attributes) | Argo kubernetes manifest attributes |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing and reporting issues

Feel free to create an issue in this repository if you have questions, suggestions or feature requests.

### Validation, linters and pull-requests

We want to provide high quality code and modules. For this reason we are using
several [pre-commit hooks](.pre-commit-config.yaml) and
[GitHub Actions workflows](.github/workflows/). A pull-request to the
main branch will trigger these validations and lints automatically. Please
check your code before you will create pull-requests. See
[pre-commit documentation](https://pre-commit.com/) and
[GitHub Actions documentation](https://docs.github.com/en/actions) for further
details.


## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
