FROM centos:centos7
#centos7

#mod_sslのインストール
#apacheのインストール
#wgetのインストール
#phpのインストール
RUN yum -y update \
&& yum -y install httpd \
&& yum -y install mod_ssl \
&& yum -y install wget \
&& yum -y install php


#時刻の同期(日本の場合)
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#shibboleth用リポジトリのインストールと
#shibbolethのインストール(今回はPGP鍵の確認を行っていないため注意)
RUN wget --no-check-certificate 'https://shibboleth.net/cgi-bin/sp_repo.cgi?platform=CentOS_7' \
&& cp sp_repo.cgi\?platform=* /etc/yum.repos.d/shibboleth.repo \
&& yum -y install shibboleth

#/etc/httpd/conf.d/ssl.confの編集
#必須　SPDomainを自分が利用するSPのドメインと置き換える
#例　SPのドメインがtest.comの場合
#例　RUN sed -i -e "s/www.example.com/test.com/" /etc/httpd/conf.d/ssl.conf
RUN sed -i -e "s/www.example.com/SPDomain/" /etc/httpd/conf.d/ssl.conf


#IdPのMetadataの設置
COPY IdPMetadata/IdPMetadata.xml /etc/shibboleth/

#shibboelthの設定ファイル
#必須：SPDomainを自分が利用するSPのドメインと置き換える
#SPのEntityIDの指定をしている
#例　SPのドメインがtest.comの場合
#例　RUN sed -i -e "s/sp.example.org\/shibboleth/test.com\/shibboleth-sp/" /etc/shibboleth/shibboleth2.xml
RUN sed -i -e "s/sp.example.org\/shibboleth/SPDomain\/shibboleth-sp/" /etc/shibboleth/shibboleth2.xml


#必須：IdPEntityIDを自分が利用するIdPのEntityIDと置き換える
#IdPのEntityIDを指定している
#例　IdPのEntityIDがhttps://accounts.google.com/o/saml2?idpid=C049gg42eの場合
#例　RUN sed -i -e "s/https:\/\/idp.example.org\/idp\/shibboleth/https:\/\/accounts.google.com\/o\/saml2?idpid=C049gg42e/" /etc/shibboleth/shibboleth2.xml
RUN sed -i -e "s/https:\/\/idp.example.org\/idp\/shibboleth/IdPEntityID/" /etc/shibboleth/shibboleth2.xml

#すでに設置されているIdPのMetadataを指定している
RUN sed -i -e '/<\/ApplicationDefaults>/i \ \ \ \ \ \ \ \ <MetadataProvider type="XML" validate="true" path="IdPMetadata.xml"\/>' /etc/shibboleth/shibboleth2.xml
RUN cat /etc/shibboleth/shibboleth2.xml

#SPに配置するリソースのコピー
RUN mkdir /var/www/html/secure
COPY app/testphpinfo.php /var/www/html/secure

#shibdとhttpdの起動
RUN systemctl enable httpd \
&& systemctl enable shibd

#80番（http）と443番（https）の開放
EXPOSE 80 443