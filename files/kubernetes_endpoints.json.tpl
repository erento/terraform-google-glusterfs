{
    "kind": "Endpoints",
    "apiVersion": "v1",
    "metadata": {
      "name": "${kubernetes_endpoint_name}"
    },
    "subsets": [
      ${endpoints}
    ]
}