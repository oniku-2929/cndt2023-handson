# 個人の動作確認用のリポジトリです

fork 元:https://github.com/cloudnativedaysjp/cndt2023-handson

- Makefile,setup/関連のファイルを追加(script,tf 関連定義)
- 要 AWS アカウント、IAM 権限など
- 環境構築: make (chapter00_setup 相当の作業が Terraform 経由で行われる)
- その他の setup 用スクリプトは setup/scripts 以下

# Co-located Hands-on Event by CNDT2023 Committee

『一日で学ぶクラウドネイティブ技術実践ハンズオン』by CloudNative Days Tokyo 2023 実行委員会のドキュメントです。

このハンズオンでは、Prometheus・Grafana・OpenTelemetry・Argo CD・Argo Rollouts・Istio・Cilium・Hubble といったよく利用されるクラウドネイティブな OSS について触れることができるハンズオンです。
これらの OSS についての第一歩を学び、これから先の学習のきっかけにしてください。

## Chapter

準備用 chapter1 ＋全 10chapter から構成されています。

- [chapter00_setup](./chapter00_setup/)◊
- [chapter01_cluster-create](./chapter01_cluster-create/)
- [chapter02_prometheus](./chapter02_prometheus/)
- [chapter03_grafana](./chapter03_grafana/)
- [chapter04_opentelemetry](./chapter04_opentelemetry/)
- [chapter05_argocd](./chapter05_argocd/)
- [chapter06_istio](./chapter06_istio/)
- [chapter07_cilium](./chapter07_cilium/)
- [chapter08_argo-rollouts](./chapter08_argo-rollouts/)
- [chapter09_istio-ambientmesh](./chapter09_istio-ambientmesh/)
- [chapter10_hubble](./chapter10_hubble/)

### 進め方

まずは、chapter00, chapter01 を実施して handson を進めるための環境を構築してください。<br>
その後は、順番に chapter を進めることはもちろん、下記フローチャートのように、気になる技術に焦点を当てた chapter を進めることもできます。

```mermaid
flowchart TD
    setup[chapter00_setup]
    cluster[chapter01_cluster-create]
    prom[chapter02_prometheus]
    grafana[chapter03_grafana]
    otel[chapter04_opentelemetry]
    argocd[chapter05_argocd]
    istio[chapter06_istio]
    cilium[chapter07_cilium]
    argorollouts[chapter08_argo-rollouts]
    istioambient[chapter09_istio-ambientmesh]
    hubble[chapter10_hubble]

    setup-->cluster

    cluster-->prom
    cluster-->argocd

    prom-->grafana
    prom-->argorollouts
    prom-->istio
    argocd-->prom

    grafana-->otel
    grafana-->cilium

    cilium-->hubble

    istio-->istioambient
```

## 免責事項

本ドキュメントに掲載された内容によって生じた損害等の一切の責任を負いかねます。
また、本ドキュメントのコンテンツや情報において、可能な限り正確な情報を掲載するよう努めていますが、情報が古くなったりすることもあります。必ずしも正確性を保証するものではありません。あらかじめご了承ください。
