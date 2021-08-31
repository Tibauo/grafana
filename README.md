# Grafana

## Grafana

## Dockerfile
```
FROM centos:7
ENV https_proxy=http://10.127.163.100:8888
ENV http_proxy=http://10.127.163.100:8888
ENV no_proxy="*.ad.testbd.dcn"
COPY CentOS.repo /etc/yum.repos.d/CentOS-Base.repo
RUN yum update -y \
  && yum install -y vim nc wget unzip
RUN wget https://dl.grafana.com/oss/release/grafana-8.1.2.linux-amd64.tar.gz \
 && tar xzvf grafana-8.1.2.linux-amd64.tar.gz \
 && mv grafana-8.1.2 /opt/
COPY grafana-piechart-panel-1.6.2.zip /opt/grafana-8.1.2/data/plugins/
RUN cd /opt/grafana-8.1.2/data/plugins/ \
 && unzip grafana-piechart-panel-1.6.2.zip
# && opt/grafana-8.1.2/bin/grafana-cli plugins install grafana-piechart-panel \
# && cp -R /var/lib/grafana/ /opt/grafana-8.1.2/data/
```

## Construire le container

```
Step 1/7 : FROM centos:7
 ---> 8652b9f0cb4c
Step 2/7 : COPY CentOS.repo /etc/yum.repos.d/CentOS-Base.repo
 ---> Using cache
 ---> eba47dedad3a
Step 3/7 : RUN yum update -y   && yum install -y vim nc wget unzip
 ---> Using cache
 ---> 94cbc4736ec8
Step 4/7 : RUN wget https://dl.grafana.com/oss/release/grafana-8.1.2.linux-amd64.tar.gz  && tar xzvf grafana-8.1.2.linux-amd64.tar.gz  && mv grafana-8.1.2 /opt/
 ---> Using cache
 ---> 08c84f2e8235
Step 5/7 : COPY grafana-piechart-panel-1.6.2.zip /opt/grafana-8.1.2/data/plugins/
 ---> Using cache
 ---> 837324f7a4b2
Step 6/7 : RUN cd /opt/grafana-8.1.2/data/plugins/  && unzip grafana-piechart-panel-1.6.2.zip
 ---> Using cache
 ---> 0a6d1ee3a437
Step 7/7 : ENTRYPOINT unset http_proxy; unset https_proxy; /opt/grafana-8.1.2/bin/grafana-server -config /opt/grafana-8.1.2/conf/defaults.ini  -homepath /opt/grafana-8.1.2/
 ---> Using cache
 ---> 34f741d60596
Successfully built 34f741d60596
Successfully tagged grafana:8.1.2
```

## Demarrer le container
```
tdiprima@ansible:grafana [0] $ sudo docker run -p 3000:3000 -d --name grafana grafana
ebd4e93ddd54b09c62ded153b473b09f268c5395deaca0dc0cc81b81d897cd15
```
## Detruire le container
```
tdiprima@ansible:grafana [1] $ sudo docker rm grafana -f
grafana
```

## Create DataSource
```
$ curl -H "Accept: application/json" -H "Content-Type: application/json" -u admin:admin -X POST http://localhost:3000/api/datasources -d '{"name":"InfluxDB","type":"influxdb","url":"http://ansible:8086","database":"mydb","isDefault":true,"basicAuth":true,"access":"proxy"}'
```

## Api Management

### Backup Dashboard

Dashboard list
```
$ curl -H "Accept: application/json" -H "Content-Type: application/json" -u admin:admin -X GET http://localhost:3000/api/search?folderIds=0&query=&starred=false
[{"id":1,"uid":"1NNKfrpGk","title":"Resume PODS","uri":"db/resume-pods","url":"/d/1NNKfrpGk/resume-pods","slug":"","type":"dash-db","tags":[],"isStarred":false}]
```
  
  
Show dashboard  
```
$ curl -H "Accept: application/json" -H "Content-Type: application/json" -u admin:admin -X GET http://localhost:3000/api/dashboards/uid/1NNKfrpGk
```

Pour récupérer juste la partie graphique (pour l'intégrer à un futur dashboard) nous utiliserons jq (yum/dnf install -y jq). Il suffit re récupérer la sections pannels à intégrer dans un nouveau dashboard

```
curl -H "Accept: application/json" -H "Content-Type: application/json" -u admin:admin -X GET http://localhost:3000/api/dashboards/uid/TbWIL9tGk | jq .dashboard.panels
```


### Restore Dashboard
```
curl -H "Accept: application/json" -H "Content-Type: application/json" -u admin:admin -X POST http://localhost:3000/api/dashboards/db -d @mondashboard.json
```

et mon dashboard et un fichier json contenant :
```
tdiprima@ansible:~/graf-influx/grafana$ cat mondashboard.json
{
  "dashboard": {
    "id": null,
    "uid": null,
    "title": "Production Overview",
    "tags": [ "templated" ],
    "timezone": "browser",
    "panels": [
      {
        "aliasColors": {
          "plateforme.nb_test_failed": "#C4162A",
          "plateforme.nb_test_success": "#37872D"
        },
        "breakPoint": "50%",
        "cacheTimeout": null,
        "combine": {
          "label": "Others",
          "threshold": 0
        },
        "datasource": null,
        "fieldConfig": {
          "defaults": {
            "custom": {}
          },
          "overrides": []
        },
        "fontSize": "80%",
        "format": "short",
        "gridPos": {
          "h": 9,
          "w": 12,
          "x": 0,
          "y": 0
        },
        "id": 2,
        "interval": null,
        "legend": {
          "show": true,
          "values": true
        },
        "legendType": "Under graph",
        "links": [],
        "nullPointMode": "connected",
        "pieType": "pie",
        "pluginVersion": "7.2.0",
        "strokeWidth": 1,
        "targets": [
          {
            "groupBy": [],
            "measurement": "plateforme",
            "orderByTime": "ASC",
            "policy": "default",
            "refId": "A",
            "resultFormat": "time_series",
            "select": [
              [
                {
                  "params": [
                    "nb_test_failed"
                  ],
                  "type": "field"
                }
              ],
              [
                {
                  "params": [
                    "nb_test_success"
                  ],
                  "type": "field"
                }
              ]
            ],
            "tags": []
          }
        ],
        "timeFrom": null,
        "timeShift": null,
        "title": "Panel Title",
        "type": "grafana-piechart-panel",
        "valueName": "current"
      }
    ],
    "schemaVersion": 16,
    "version": 0,
    "refresh": "25s"
  },
  "folderId": 0,
  "overwrite": false
}
```

Le dashboard que j'ai crée et présent dans ce repo : dashboard_initial.json
```
tdiprima@ansible:~/graf-influx/grafana$ curl -H "Accept: application/json" -H "Content-Type: application/json" -u admin:admin -X POST http://localhost:3000/api/dashboards/db -d @dashboard_initial.json
{"id":3,"slug":"resume-pods","status":"success","uid":"TbWIL9tGk","url":"/d/TbWIL9tGk/resume-pods","version":4}
```
