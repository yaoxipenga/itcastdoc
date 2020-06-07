# 

# 过滤插件(filter)

参考: https://www.elastic.co/guide/en/logstash/current/filter-plugins.html

Filter：过滤，将日志格式化。

有丰富的过滤插件：

- Grok正则捕获
- date时间处理
- JSON编解码
- 数据修改Mutate
- geoip等。

 

所有的过滤器插件都支持以下配置选项：

| **Setting**    | **Input type** | **Required** | **Default** | **Description**                                              |
| -------------- | -------------- | ------------ | ----------- | ------------------------------------------------------------ |
| add_field      | hash           | No           | {}          | 如果过滤成功，添加任何field到这个事件。例如：add_field => [   "foo_%{somefield}", "Hello world, from %{host}" ]，如果这个事件有一个字段somefiled，它的值是hello，那么我们会增加一个字段foo_hello，字段值则用%{host}代替。 |
| add_tag        | array          | No           | []          | 过滤成功会增加一个任意的标签到事件例如：add_tag => [ "foo_%{somefield}" ] |
| enable_metric  | boolean        | No           | true        |                                                              |
| id             | string         | No           |             |                                                              |
| periodic_flush | boolean        | No           | false       | 定期调用过滤器刷新方法                                       |
| remove_field   | array          | No           | []          | 过滤成功从该事件中移除任意filed。例：remove_field => [   "foo_%{somefield}" ] |
| remove_tag     | array          | No           | []          | 过滤成功从该事件中移除任意标签，例如：remove_tag => [ "foo_%{somefield}" ] |



## json(关注)

- JSON解析过滤器，接收一个JSON的字段，将其展开为Logstash事件中的实际数据结构。

**示例: 将原信息转成一个大字段，key-value做成大字段中的小字段**

~~~powershell
# cat /etc/logstash/conf.d/jsontest.conf
input {
  stdin {
  }
}

filter {
  json {
    source => "message"
    target => "content"
  }
}

output {
  stdout {
  
  }
}


对标准输入的内容进行json格式输出
把输出内容定向到target指定的content

[root@vm3 bin]# ./logstash --path.settings /etc/logstash -r -f /etc/logstash/conf.d/jsontest.conf
~~~

~~~powershell
输入测试数据

{"ip":"10.1.1.1","hostname":"vm3.cluster.com"}

输出测试数据

{
       "content" => {
        "hostname" => "vm3.cluster.com",
              "ip" => "10.1.1.1"
    },
    "@timestamp" => 2019-07-02T11:57:36.398Z,
      "@version" => "1",
          "host" => "vm3.cluster.com",
       "message" => "{\"ip\":\"10.1.1.1\",\"hostname\":\"vm3.cluster.com\"}"
}
~~~

**示例: 直接将原信息转成各个字段**

~~~powershell
# cat /etc/logstash/conf.d/jsontest.conf
input {
  stdin {
  }
}

filter {
  json {
    source => "message"
  }
}

output {
  stdout {
  
  }
}



[root@vm3 bin]# ./logstash --path.settings /etc/logstash -r -f /etc/logstash/conf.d/jsontest.conf
~~~

~~~powershell

输入测试数据

{"ip":"10.1.1.1","hostname":"vm3.cluster.com"}

输出测试数据


{
          "port" => 39442,
      "@version" => "1",
    "@timestamp" => 2019-09-19T09:07:03.800Z,
      "hostname" => "vm3.cluster.com",
          "host" => "vm4.cluster.com",
            "ip" => "10.1.1.1",
       "message" => "{\"ip\":\"10.1.1.1\",\"hostname\":\"vm3.cluster.com\"}"
}

~~~





## kv

- 自动解析为key=value。
- 也可以任意字符串分割数据。
- field_split  一串字符，指定分隔符分析键值对

~~~powershell
URL查询字符串拆分参数示例
# cat /etc/logstash/conf.d/kvtest.conf
input {
        stdin {
        }
}

filter {
  kv {
     field_split => "&?"
  }
}

output {
        stdout {

        }
}

文件中的列以&或?进行分隔

执行
[root@vm3 bin]# ./logstash --path.settings /etc/logstash -r -f /etc/logstash/conf.d/kvtest.conf
~~~



~~~powershell
输入数据
address=www.abc.com?pid=123&user=abc

输出数据
{
           "user" => "abc",
    "@timestamp" => 2019-07-02T12:05:23.143Z,
          "host" => "vm3.cluster.com",
      "@version" => "1",
       "message" => "address=www.abc.com?pid=123&abc=user",
       "address" => "www.abc.com",
           "pid" => "123"
}
~~~



~~~powershell
使用正则也可以匹配

[root@vm3 bin]# cat /etc/logstash/conf.d/kvtest.conf
input {
        stdin {
        }
}

filter {
  kv {
     field_split_pattern => ":+"
  }
}

output {
        stdout {

        }
}
~~~



## grok(关注)

- grok是将非结构化数据解析为结构化
- 这个工具非常适于系统日志，mysql日志，其他Web服务器日志以及通常人类无法编写任何日志的格式。
- 默认情况下，Logstash附带约120个模式。也可以添加自己的模式（patterns_dir）
- 模式后面对应正则表达式
- 查看模式地址：<https://github.com/logstash-plugins/logstash-patterns-core/tree/master/patterns>
- 包含字段如下

| **Setting**         | **Input type** | **Required** | **Default**       | **Description**                                    |
| ------------------- | -------------- | ------------ | ----------------- | -------------------------------------------------- |
| break_on_match      | boolean        | No           | true              |                                                    |
| keep_empty_captures |                | No           | false             | 如果true将空保留为事件字段                         |
| match               | hash           | No           | {}                | 一个hash匹配字段=>值                               |
| named_captures_only | boolean        | No           | true              | 如果true，只存储                                   |
| overwrite           | array          | No           | []                | 覆盖已存在的字段的值                               |
| pattern_definitions |                | No           | {}                |                                                    |
| patterns_dir        | array          | No           | []                | 自定义模式                                         |
| patterns_files_glob | string         | No           | *                 | Glob模式，用于匹配patterns_dir指定目录中的模式文件 |
| tag_on_failure      | array          | No           | _grokparsefailure | tags没有匹配成功时，将值附加到字段                 |
| tag_on_timeout      | string         | No           | _groktimeout      | 如果Grok正则表达式超时，则应用标记                 |
| timeout_millis      | number         |              | 30000             | 正则表达式超时时间                                 |



**grok模式语法**

格式：%{SYNTAX:SEMANTIC}

- SYNTAX  模式名称

- SEMANTIC 匹配文本的标识符

例如：%{NUMBER:duration}  %{IP:client}



~~~powershell
# vim /etc/logstash/conf.d/groktest.conf
input {
        stdin {
        }
}


filter {
  grok {
    match => {
       "message" => "%{IP:client} %{WORD:method} %{URIPATHPARAM:request} %{NUMBER:bytes} %{NUMBER:duration}"
    }
  }
}


output {
        stdout {

        }
}


虚构http请求日志抽出有用的字段
55.3.244.1 GET /index.html 15824 0.043


输出结果
{
        "client" => "55.3.244.1",
      "duration" => "0.043",
       "message" => "55.3.244.1 GET /index.html 15824 0.043",
        "method" => "GET",
         "bytes" => "15824",
      "@version" => "1",
    "@timestamp" => 2019-07-03T12:24:47.596Z,
          "host" => "vm3.cluster.com",
       "request" => "/index.html"
}

~~~



**自定义模式**

>如果默认模式中没有匹配的，可以自己写正则表达式。

~~~powershell
# vim /opt/patterns
ID [0-9]{3,5}

配置文件中应包含如下内容
filter {
  grok {
    patterns_dir =>"/opt/patterns"
    match => {
      "message" => "%{IP:client} %{WORD:method} %{URIPATHPARAM:request} %{NUMBER:bytes} %{NUMBER:duration} %{ID:id}"              
    }
  }
}


完整文件内容
[root@vm3 ~]# cat /etc/logstash/conf.d/groktest.conf
input {
        stdin {
        }
}

filter {
  grok {
    patterns_dir =>"/opt/patterns"
    match => {
      "message" => "%{IP:client} %{WORD:method} %{URIPATHPARAM:request} %{NUMBER:bytes} %{NUMBER:duration} %{ID:id}"
    }
  }
}

output {
        stdout {
        }
}

#执行
[root@vm3 bin]# ./logstash --path.settings /etc/logstash -r -f /etc/logstash/conf.d/groktest.conf

输入测试数据
55.3.244.1 GET /index.html 15824 0.043 6666

输出测试数据
{
        "client" => "55.3.244.1",
          "host" => "vm3.cluster.com",
       "request" => "/index.html",
    "@timestamp" => 2019-07-02T12:34:11.906Z,
         "bytes" => "15824",
        "method" => "GET",
       "message" => "55.3.244.1 GET /index.html 15824 0.043 15BF7F3ABB",
      "@version" => "1",
            "id" => "666",
      "duration" => "0.043"
}
~~~





## geoip(关注)

- 开源IP地址库
- https://dev.maxmind.com/geoip/geoip2/geolite2/

~~~powershell
下载IP地址库
[root@vm3 ~]# wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz

[root@vm3 ~]# tar xf GeoLite2-City.tar.gz

[root@vm3 ~]# cp GeoLite2-City_20190625/GeoLite2-City.mmdb /opt
~~~



~~~powershell
# cat /etc/logstash/conf.d/geoiptest.conf                          
input {
        stdin {
        }
}

filter {
  grok {
    match => {
      "message" => "%{IP:client} %{WORD:method} %{URIPATHPARAM:request} %{NUMBER:bytes} %{NUMBER:duration}"
    }
  }
  geoip {
      source => "client"
      database => "/opt/GeoLite2-City.mmdb"
  }
}


output {
        stdout {

        }
}



执行
[root@vm3 bin]# ./logstash --path.settings /etc/logstash -r -f /etc/logstash/conf.d/geoiptest.conf


输入测试数据

202.106.0.20 GET /index.html 123 0.331

输出结果

{
        "method" => "GET",
        "client" => "202.106.0.20",
         "bytes" => "123",
       "request" => "/index.html",
         "geoip" => {
         "country_code2" => "CN",
          "country_name" => "China",
           "region_code" => "BJ",
             "longitude" => 116.3883,
              "latitude" => 39.9289,
              "timezone" => "Asia/Shanghai",
              "location" => {
            "lon" => 116.3883,
            "lat" => 39.9289
        },
         "country_code3" => "CN",
                    "ip" => "202.106.0.20",
        "continent_code" => "AS",
           "region_name" => "Beijing"
    },
      "duration" => "0.331",
          "host" => "vm3.cluster.com",
       "message" => "202.106.0.20 GET /index.html 123 0.331",
    "@timestamp" => 2019-07-02T12:15:29.384Z,
      "@version" => "1"
}


~~~





~~~powershell
[root@vm3 bin]# cat /etc/logstash/conf.d/geoiptest2.conf
input {
        stdin {
        }
}

filter {
  grok {
    match => {
      "message" => "%{IP:client} %{WORD:method} %{URIPATHPARAM:request} %{NUMBER:bytes} %{NUMBER:duration}"

    }
  }
  geoip {
      source => "client"
      database => "/opt/GeoLite2-City.mmdb"
      target => "geoip"
      fields => ["city_name", "country_code2", "country_name","region_name"]
  }
}


output {
        stdout {
                codec => rubydebug
        }
}



执行
[root@vm3 bin]# ./logstash --path.settings /etc/logstash -r -f /etc/logstash/conf.d/geoiptest2.conf


输入测试数据

110.226.4.6 GET /home.html 518 0.247

输出结果

{
          "host" => "vm3.cluster.com",
      "duration" => "0.247",
       "request" => "/home.html",
      "@version" => "1",
        "client" => "110.226.4.6",
       "message" => "110.226.4.6 GET /home.html 518 0.247",
        "method" => "GET",
         "bytes" => "518",
    "@timestamp" => 2019-07-02T12:22:22.458Z,
         "geoip" => {
         "country_name" => "India",
        "country_code2" => "IN"
    }
}

~~~







