FROM centos:7
RUN yum install -y httpd
CMD echo Hello host && sleep infinity
