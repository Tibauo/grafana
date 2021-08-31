# Grafana

## Grafana

## Dockerfile
```
## En se basanet sur CentOS 7
FROM centos:7
## Les proxy set
ENV https_proxy=http://10.127.163.100:8888
ENV http_proxy=http://10.127.163.100:8888
ENV no_proxy="*.ad.testbd.dcn"
## On copy les repo autorisés par le proxy
COPY CentOS.repo /etc/yum.repos.d/CentOS-Base.repo
## On install de quoi debbuger
RUN yum update -y \
  && yum install -y vim nc wget
## On récupère grafana puis un plugin et on le place dans l'endroit souhaitez
RUN wget https://dl.grafana.com/oss/release/grafana-7.2.0.linux-amd64.tar.gz \
 && tar xzvf grafana-7.2.0.linux-amd64.tar.gz \
 && mv grafana-7.2.0 /opt/ \
 && opt/grafana-7.2.0/bin/grafana-cli plugins install grafana-piechart-panel \
 && cp -R /var/lib/grafana/ /opt/grafana-7.2.0/data/

ENTRYPOINT /opt/grafana-7.2.0/bin/grafana-server -config /opt/grafana-7.2.0/conf/defaults.ini  -homepath /opt/grafana-7.2.0/```
```

## Construire le container

```
Sending build context to Docker daemon  165.4kB
Step 1/8 : FROM centos:7
 ---> 7e6257c9f8d8
Step 2/8 : ENV https_proxy=http://10.127.163.100:8888
 ---> Using cache
 ---> 2c2df8492553
Step 3/8 : ENV http_proxy=http://10.127.163.100:8888
 ---> Using cache
 ---> dc23574e3b29
Step 4/8 : ENV no_proxy="*.ad.testbd.dcn"
 ---> Using cache
 ---> 92018393abd8
Step 5/8 : COPY CentOS.repo /etc/yum.repos.d/CentOS-Base.repo
 ---> Using cache
 ---> 133d3de08d53
Step 6/8 : RUN yum update -y   && yum install -y vim nc wget
 ---> Using cache
 ---> 537b9531828f
Step 7/8 : RUN wget https://dl.grafana.com/oss/release/grafana-7.2.0.linux-amd64.tar.gz  && tar xzvf grafana-7.2.0.linux-amd64.tar.gz  && mv grafana-7.2.0 /opt/  && opt/grafana-7.2.0/bin/grafana-cli plugins install grafana-piechart-panel  && cp -R /var/lib/grafana/ /opt/grafana-7.2.0/data/
 ---> Using cache
 ---> 78407a1c0fd6
Step 8/8 : ENTRYPOINT unset http_proxy; unset https_proxy; /opt/grafana-7.2.0/bin/grafana-server -config /opt/grafana-7.2.0/conf/defaults.ini  -homepath /opt/grafana-7.2.0/
 ---> Running in e515294f14df
Removing intermediate container e515294f14df
 ---> aeec8f39cca1
Successfully built aeec8f39cca1
Successfully tagged grafana:latest
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
