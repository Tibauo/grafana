FROM centos:7
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

ENTRYPOINT /opt/grafana-8.1.2/bin/grafana-server -config /opt/grafana-8.1.2/conf/defaults.ini  -homepath /opt/grafana-8.1.2/
