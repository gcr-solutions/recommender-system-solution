# 1 Create argocd application
argocd app create gcr-recommender-system --repo https://github.com/gcr-solutions/recommender-system-solution.git --path manifests --dest-namespace \
rs-beta --dest-server https://kubernetes.default.svc --kustomize-image gcr.io/heptio-images/ks-guestbook-demo:0.1
