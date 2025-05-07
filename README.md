# Mongo DB Demo Projekt

Das Projekt lässt sich einfach mit  `docker-compose up -d` starten.

Dann ist die app auf http://localhost:3000 erreichbar und zeigt euch alle Filme in der Datenbank an.
Mit der URL http://localhost:3000/movies/add?title=Pulp%20Fiction lassen sich Filme hinzufügen.

## Projekt Setup

Die MongoDB wurde mit einem Replicaset konfiguriert, daher benötigt das Projekt einen "Hack" um die replicaSets erst dann zu initialisieren wenn auch die Container gestartet wurden. Dazu gibt es den 'mongo-init' container, dieser führt das init-replica.sh aus (und ist abhängig auf die 3 mongodb container), in dem script wartet er bis der mongo-1 container nicht nur gestartet ist, sondern auch bis der mongodb service erreichbar ist. Dann werden die replicaset konfiguriert.