---
layout: layout-ja
title: インストール
---
# インストール

Dockerコンテナを使う方法と、RubyGemsからインストールする方法があります。

- [Dockerコンテナを使う](#docker)
- [RubyGemsからインストール](#rubygems)

## Dockerコンテナを使う

DockerHubにある[ongaeshi/honyomi](https://hub.docker.com/r/ongaeshi/honyomi/) を使います。GroongaやPopplerといった外部ツールも一緒にインストールしてくれるのでおすすめです。

### コンテナのインストールと実行

`my-honyomi`という名前でコンテナを実行します。(名前は好きなもので)

{% highlight bash %}
$ docker run --name my-honyomi -it -p 9295:9295 ongaeshi/honyomi
Thin web server (v1.6.3 codename Protein Powder)
Maximum connections set to 1024
Listening on 0.0.0.0:9295, CTRL+C to stop
# Container stops at the Ctrl-C
{% endhighlight %}

バックグラウンドで実行します。

{% highlight bash %}
$ docker run --name my-honyomi -d -it -p 9295:9295 ongaeshi/honyomi
{% endhighlight %}

コンテナの起動、停止、削除。

{% highlight bash %}
$ docker start my-honyomi
$ docker stop my-honyomi
$ docker rm my-honyomi      # Need stop
{% endhighlight %}

起動したコンテナでシェルを立ち上げます。

{% highlight bash %}
$ docker exec -it my-honyomi /bin/bash
{% endhighlight %}

### バックアップ

Honyomiデータベースをコンテナでtar.gzしてからホストにコピーします。

{% highlight bash %}
$ docker exec my-honyomi tar czvf /backup.tar.gz /root/.honyomi
$ docker cp my-honyomi:/backup.tar.gz ~/tmp/
{% endhighlight %}

ホストの`/path/to/honyomi`をHonyomiデータベースとしてコンテナを実行します。
注意: ホストOSがLinuxじゃないと動きません (See [Mount a host directory as a data volume](https://docs.docker.com/userguide/dockervolumes/#mount-a-host-directory-as-a-data-volume))

{% highlight bash %}
$ docker run --name my-honyomi -d -it -p 9295:9295 -v /path/to/honyomi:/root/.honyomi/ ongaeshi/honyomi
{% endhighlight %}


### honyomi gem の更新

コンテナを再生成せずにhonyomi gemを最新にします。

Honyomiデータベースを破棄せずに最新のHonyomiに更新したいときう使ってください。前述の`-v`を使ってホストの領域をHonyomiデータベースとして使っている場合はコンテナを破棄→再生成の方がよいです。

{% highlight bash %}
$ docker exec my-honyomi gem install honyomi
$ docker restart my-honyomi
{% endhighlight %}

## RubyGemsからインストール

{% highlight bash %}
$ gem install honyomi
{% endhighlight %}

Rroongaのインストールに失敗するときは以下を参考にしてください。

- [File: install — rroonga - ラングバ](http://ranguba.org/rroonga/ja/file.install.html)

外部ツールとしてpdftotext, pdftoppmのインストールが必要です。poppler, xpdf などをインストールしてください。

- pdftotext - For honyomi add
- pdftoppm - For honyomi image

### RubyGems経由でサーバーにインストールしたい

- [ongaeshi/honyomi-web](https://github.com/ongaeshi/honyomi-web)

