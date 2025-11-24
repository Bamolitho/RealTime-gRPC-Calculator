# RealTime gRPC Calculator

Ce projet démontre comment utiliser **gRPC**, **gRPC-Web**, **Python**, **JavaScript** et **Envoy** pour créer une calculatrice capable de :

- exécuter des opérations arithmétiques via gRPC (Unary RPC),
- envoyer des résultats en continu via Server-Streaming,
- être utilisée depuis un client Python **ou** un client Web.

La stack complète s'exécute avec **Docker Compose**.

------

## 1. Structure du projet

```basic
RealTime-gRPC-Calculator/
├── client-python
│   ├── client.py
│   ├── Dockerfile
│   └── requirements.txt
├── client-web
│   ├── app.js
│   ├── calculator_grpc_web_pb.js
│   ├── calculator_pb.js
│   ├── Dockerfile
│   └── index.html
├── docker-compose.yml
├── envoy
│   ├── Dockerfile
│   └── envoy.yaml
├── install_protoc_grpc_web.sh
├── Makefile
├── proto
│   └── calculator.proto
├── README.md
└── server
    ├── calculator_pb2_grpc.py
    ├── calculator_pb2.py
    ├── Dockerfile
    ├── requirements.txt
    └── server.py
```

------

## 2. Prérequis

### Option A — Utiliser Docker uniquement 

Aucun outil particulier n’est requis : Docker suffit.

### Option B — Générer les fichiers manuellement

Il te faut :

- protoc
- grpc_tools (Python)
- protoc-gen-js
- protoc-gen-grpc-web
- protoc-gen-grpc-python (inclus dans grpc_tools)

Si tu veux installer les outils manquants :

```bash
chmod +x install_protoc_grpc_web.sh
./install_protoc_grpc_web.sh
```

------

## 3. Génération du code gRPC

Le Makefile fournit toutes les commandes nécessaires.

### Générer tous les fichiers (Python + Web)

```shell
make proto
```

### Vérifier l’arborescence

```bash
make tree
```

------

## 4. Lancer le projet complet

Tout se lance grâce à Docker Compose :

```bash
docker compose up --build
```

Cela démarre :

- **server** → gRPC Python
- **envoy** → conversion gRPC-Web
- **client-web** (serveur web léger)
- **client-python** (optionnel)

------

## 5. Utilisation des clients

### 5.1 Client Python

Dans un second terminal :

```bash
docker compose exec client-python python client.py
```

Il affiche :

- les résultats Add/Sub/Mul/Div
- les valeurs reçues par streaming

------

### 5.2 Client Web

Ouvre ton navigateur sur :

```http
http://localhost:8080
```

Tu y trouveras :

- un formulaire pour exécuter les opérations
- une démo de streaming temps réel via gRPC-Web

------

## 6. Nettoyage

```bash
make clean
docker compose down -v
```

------

## 7. Regénérer les plugins / réparer l’environnement

Si jamais gRPC-Web est mal installé :

```bash
./install_protoc_grpc_web.sh
```

Si tu veux régénérer le code proprement :

```bash
make clean
make proto
```

------

# 8. Points importants

- Envoy est obligatoire pour le client Web : les navigateurs **ne parlent pas gRPC natif**.
- Le serveur Python expose du gRPC pur, Envoy traduit pour le Web.
- Le streaming fonctionne en temps réel sur les deux clients.

------

