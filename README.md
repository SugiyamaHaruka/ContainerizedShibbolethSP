# ContainerizedShibbolethSP

## Shibboleth SPのコンテナの構築準備

  0. 前提条件：このリポジトリをクローンする。

  1. 作成するSPのドメインを決定する。
  DockerfileのSPDomianと書かれている部分を置き換える。
  具体的な置き換え方はDockerfileの例の部分を参照すること。

  2. 利用するIdPのMetadataを取得する。
  取得したMetadataの中身をIdpMetadata.xmlにコピー&ペーストする。
  コピー&ペーストでは問題が発生しやすいため注意すること。

  3. DockfileのIdPEntityIDと書かれている部分をIdPのEntityIDに置き換える。
  具体的な置き換え方はDockerfileの例の部分を参照すること。
  また、文字の置き換えに利用しているsedコマンドでは/が特殊文字として認識されるため、\を利用して通常の文字として扱うようにする。

## Shibboleth SPのコンテナをローカルで構築する

  1. ローカルで動かすために、windows10の場合、C:\Windows\System32\drivers\etc\hostsの書き換えを行う。
  「End of section」と書かれている行の直前の編集を行う
  SPのドメイン名前がtest.comであった場合、以下のように編集を行う。
  ```
  #TestContainerizedShibbolethSP
  127.0.0.1 test.com

  # End of section
  ```

  2. Dockerfileをビルドして、イメージの作成を行う。
  Dockerfileのある場所で、以下のコマンドを実行する。
  オプションの意味は卒業論文に記してあるため、省略する。
  containershibはコンテナ名前、1.0はタグである。
  自分でビルドする際にこの二つは自由に決めてよい。
  .はDockerfileのあるディレクトリを指定している。
  ```
  % docker build -t containershib:1.0 .
  ``` 
  3. イメージを実行し、Dockerコンテナの構築を行う。
  イメージが作成されているかどうかは、
  作成されたイメージの一覧を表示する以下のコマンドを利用する。
  ```
  % docker images

  REPOSITORY                                 TAG              IMAGE ID       CREATED             SIZE
  containershib                               1.0              fa66b79914e1   About an hour ago   713MB
  ```
  イメージを実行し、コンテナを構築するには以下のコマンドを利用する。

  ```
  % docker run  -d -p 80:80 -p 443:443 --privileged containershib:1.0 /sbin/init

  5cfffa66949bbc000b7863f82e12e5f2ab1be01d6e7e88803c231254ec7deb36
  ```
  オプションの意味は卒業論文に記してあるため、省略する。
  5cfffa66949bbc000b7863f82e12e5f2ab1be01d6e7e88803c231254ec7deb36は構築されたコンテナのハッシュ値である。
  これを利用することで、構築されたコンテナを指定することも可能となる。

## IdPにShibboleth SPを登録する方法

  1. Shibboleth SPのMetadataを取得する。
  現段階まで進んでいれば、SPのドメイン名がtest.comの場合
  https://test.com/Shibboleth.sso/Metadata
  へブラウザでアクセスすることでSPのMetadataが取得できる。

  2. IdPへSPの情報を登録する。
  IdPによっても、SPのMetadataを要求するものや、
  Google Cloud IdentityのようにSPのACSのURLのSPのEntityIDのみで良いというものもある。
  ACSのURLやEntityIDはMetadataの中に書かれているため、それを参照し登録を行うとよい。

## 実際の動作

  SPのドメインがtest.comの場合、
  https://test.com/secure/testphpinfo.php
  と入力する 

  IdPでの認証に移動し、認証後以下のように画面が表示されれば成功である。
![image](https://user-images.githubusercontent.com/52463373/151764085-5f8170ac-f4bd-4698-ad8c-dd61412edb04.png)

## 注意事項

  以上の方法で作成したコンテナは、
  最低限IdPと連携するためのものである。
  実際に利用する場合には卒業論文に記されているように、
  証明書の取得、ドメインとIPアドレスのDNSへの登録、
  IdPからSPへ受け渡す情報の選択が必要である。

