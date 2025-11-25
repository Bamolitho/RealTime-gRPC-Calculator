# RealTime gRPC Calculator

Calculatrice temps réel utilisant gRPC avec support Python et Web (gRPC-Web).

## Architecture



┌──────────┐             ┌───────┐        ┌───────┐
│   Client     	 │  gRPC   │   Server    │         │   Client        │
│   Python  	  ├───► │   Python    │◄─┤   Web (JS)     │
└──────────┘             └───────┘       └───────┘
                                        gRPC-Web
                                             │
                                      ┌──────┴──────┐
                                      │    Envoy    │
                                      │    Proxy    │
                                      └─────────────┘

## Prérequis

- Docker & Docker Compose
- Python 3.8+
- Node.js & npm
- Protocol Buffers compiler (`protoc`)
- Make

## Installation Rapide

### 1. Cloner le projet

```bash
cd ~/Téléchargements
git clone <repository-url>
cd RealTime-gRPC-Calculator
```



### 2. Installer les dépendances

```bash
# Installer protoc-gen-grpc-web (automatique)
chmod +x install_protoc_grpc_web.sh
./install_protoc_grpc_web.sh

# Vérifier l'installation
protoc-gen-grpc-web --version  # Doit afficher: 1.5.0
```

### 3. Générer les fichiers Protocol Buffers

```bash
make proto
```

**Fichiers générés :**
- `server/calculator_pb2.py` : Messages Python
- `server/calculator_pb2_grpc.py` : Service gRPC Python
- `client-web/calculator_pb.js` : Messages JavaScript
- `client-web/calculator_grpc_web_pb.js` : Service gRPC-Web

## Utilisation

### Démarrer les services

```bash
# Construire les images Docker
make build

# Démarrer tous les services
make up

# Vérifier les logs
make logs
```

### Services disponibles

| Service | Port | URL |
|---------|------|-----|
| Serveur gRPC | 50051 | `localhost:50051` |
| Client Web | 8080 | http://localhost:8080 |
| Envoy Proxy | 8081 | `localhost:8081` |

### Tester avec le client Python

```bash
# Entrer dans le conteneur
docker exec -it realtime-grpc-calculator-client-python-1 bash

# Exécuter le client
python client.py
```

**Exemple de sortie :**
```
Addition: 10 + 5 = 15.0
Soustraction: 10 - 5 = 5.0
Multiplication: 10 * 5 = 50.0
Division: 10 / 5 = 2.0

Stream: base=10, operation=add, operand=2
Step 1: 12.0
Step 2: 14.0
Step 3: 16.0
```

### Tester avec le client Web

1. Ouvrir http://localhost:8080 dans votre navigateur
2. Entrer deux nombres
3. Cliquer sur une opération (Add, Subtract, Multiply, Divide)
4. Le résultat s'affiche instantanément

## API gRPC

### Service Calculator

**Opérations Unary (requête-réponse) :**

```protobuf
rpc Add (Numbers) returns (Result);
rpc Subtract (Numbers) returns (Result);
rpc Multiply (Numbers) returns (Result);
rpc Divide (Numbers) returns (Result);
```

**Opération Streaming (serveur envoie plusieurs résultats) :**

```protobuf
rpc StreamCalculations (StreamRequest) returns (stream Result);
```

### Messages

```protobuf
message Numbers {
  double num1 = 1;
  double num2 = 2;
}

message StreamRequest {
  double base = 1;        // Valeur de départ
  int32 count = 2;        // Nombre de résultats
  string operation = 3;   // "add", "sub", "mul", "div"
  double operand = 4;     // Valeur appliquée à chaque étape
}

message Result {
  double value = 1;       // Résultat
  string operation = 2;   // Nom de l'opération
  int32 step = 3;         // Numéro de l'itération
}
```

## Commandes Make

```bash
make proto        # Générer les fichiers .proto
make build        # Construire les images Docker
make up           # Démarrer les services
make down         # Arrêter les services
make logs         # Afficher les logs
make clean        # Nettoyer les conteneurs et images
make tree         # Afficher l'arborescence du projet
```

## Structure du Projet

```
.
├── client-python/           # Client Python gRPC
│   ├── client.py
│   ├── Dockerfile
│   └── requirements.txt
├── client-web/              # Client Web (gRPC-Web)
│   ├── app.js
│   ├── index.html
│   ├── calculator_pb.js     # Généré
│   └── calculator_grpc_web_pb.js  # Généré
├── server/                  # Serveur gRPC Python
│   ├── server.py
│   ├── calculator_pb2.py    # Généré
│   ├── calculator_pb2_grpc.py  # Généré
│   ├── Dockerfile
│   └── requirements.txt
├── envoy/                   # Proxy Envoy pour gRPC-Web
│   ├── envoy.yaml
│   └── Dockerfile
├── proto/                   # Définitions Protocol Buffers
│   └── calculator.proto
├── docker-compose.yml
├── Makefile
└── install_protoc_grpc_web.sh
```

## Dépannage

### Erreur: protoc-gen-grpc-web not found

```bash
./install_protoc_grpc_web.sh
```

### Erreur: Permission denied (npm)

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

### Port déjà utilisé

```bash
# Arrêter les services
make down

# Vérifier les ports
sudo lsof -i :50051
sudo lsof -i :8080
sudo lsof -i :8081

# Nettoyer complètement
make clean
```

### Regénérer les fichiers proto

```bash
# Nettoyer les anciens fichiers
rm -f server/calculator_pb2*.py
rm -f client-web/calculator_*.js

# Regénérer
make proto
```

## Développement

### Modifier le service gRPC

1. Éditer `proto/calculator.proto`
2. Regénérer les fichiers : `make proto`
3. Mettre à jour `server/server.py`
4. Reconstruire : `make build && make up`

### Ajouter une nouvelle opération

**Dans `proto/calculator.proto` :**

```protobuf
rpc Power (Numbers) returns (Result);
```

**Dans `server/server.py` :**

```python
def Power(self, request, context):
    result = request.num1 ** request.num2
    return calculator_pb2.Result(value=result, operation="power")
```

**Regénérer et redémarrer :**

```bash
make proto
make build
make up
```

## Tests

### Test manuel complet

```bash
# Démarrer les services
make up

# Terminal 1: Logs du serveur
docker logs -f realtime-grpc-calculator-server-1

# Terminal 2: Client Python
docker exec -it realtime-grpc-calculator-client-python-1 python client.py

# Terminal 3: Client Web
# Ouvrir http://localhost:8080
```

### Vérifier les services

```bash
# Vérifier que tous les conteneurs sont actifs
docker ps

# Tester le serveur gRPC
grpcurl -plaintext localhost:50051 list

# Tester Envoy
curl -I http://localhost:8081
```

## Technologies Utilisées

- **gRPC** : Framework RPC haute performance
- **Protocol Buffers** : Sérialisation de données
- **gRPC-Web** : gRPC pour navigateurs web
- **Envoy Proxy** : Proxy HTTP/2 pour gRPC-Web
- **Python** : Serveur et client
- **JavaScript** : Client web
- **Docker** : Conteneurisation

## Ressources

- [gRPC Documentation](https://grpc.io/docs/)
- [gRPC-Web](https://github.com/grpc/grpc-web)
- [Protocol Buffers](https://developers.google.com/protocol-buffers)
- [Envoy Proxy](https://www.envoyproxy.io/)

