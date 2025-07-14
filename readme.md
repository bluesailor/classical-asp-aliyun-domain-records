# aliyun-domain-api-asp

## 项目简介

本项目基于经典 ASP（VBScript）环境，封装了阿里云 DNS 解析（AliDNS）API，实现对域名解析记录的查询、添加、修改和删除功能。适用于在 IIS 上运行的老旧网站或管理平台。

## 仓库结构

```text
aliyun-domain-api/
├── ASP/
│   ├── config.asp       # 常量配置：AccessKeyId、AccessKeySecret（以及可选的API Endpoint）
│   ├── dns-api.asp      # 主入口，路由分发和请求响应
│   ├── records.asp      # 域名解析记录操作模块（增删改查）
│   └── sha1.asp         # HMAC-SHA1 签名实现及 Base64 编码
└── README.md            # 本说明文档
```

## 环境要求

* Windows Server + IIS，启用经典 ASP 支持
* IIS 对应用目录具有读取和执行权限
* 阿里云账号，拥有 DNS 产品的操作权限
* 编辑 `ASP/config.asp`，填入您的 AccessKeyId 和 AccessKeySecret 常量

## 配置说明

在 `ASP/config.asp` 中，设置如下常量：

```asp
<%
CONST ALIYUN_ACCESS_KEY_ID     = "YourAccessKeyId"
CONST ALIYUN_ACCESS_KEY_SECRET = "YourAccessKeySecret"
' 可选：若需自定义 Endpoint，可添加如下常量：
' CONST ALIYUN_DNS_ENDPOINT   = "https://alidns.aliyuncs.com/"
%>
```

* `ALIYUN_ACCESS_KEY_ID`：阿里云访问密钥 ID
* `ALIYUN_ACCESS_KEY_SECRET`：阿里云访问密钥 Secret
* `ALIYUN_DNS_ENDPOINT`：AliDNS API 接口地址，默认使用官方地址

## 模块说明

### config.asp

定义全局常量，供其他模块读取签名时使用。

### sha1.asp

提供 `HMACSHA1(message, key)` 函数，使用 `AccessKeySecret + "&"` 作为密钥，返回 Base64 编码签名。

### records.asp

封装了对阿里云 DNS API 的各项操作：

* `DescribeDomainRecords(domainName, pageNumber, pageSize)`
* `AddDomainRecord(domainName, RR, Type, Value, TTL, Priority)`
* `UpdateDomainRecord(recordId, RR, Type, Value, TTL, Priority)`
* `DeleteDomainRecord(recordId)`

### dns-api.asp

对外暴露统一的 HTTP 接口，通过 `action` 参数分发到 `records.asp` 方法，支持 GET/POST 调用，并返回 JSON 格式结果。

## 使用示例

1. 将整个 `aliyun-domain-api/ASP` 目录部署到 IIS 网站下，例如地址为 `/aliyun-domain-api/ASP/`
2. 在 IIS 中启用经典 ASP
3. 编辑 `config.asp`，填写您的 API Key
4. 发起 HTTP 请求：

   * 查询记录

     ```http
     GET /aliyun-domain-api/ASP/dns-api.asp?action=DescribeDomainRecords&DomainName=example.com
     ```

   * 添加记录

     ```http
     POST /aliyun-domain-api/ASP/dns-api.asp
     Content-Type: application/x-www-form-urlencoded

     action=AddDomainRecord&DomainName=example.com&RR=www&Type=A&Value=1.2.3.4&TTL=600
     ```

   * 修改记录

     ```http
     GET /aliyun-domain-api/ASP/dns-api.asp?action=UpdateDomainRecord&RecordId=123456&RR=api&Type=CNAME&Value=alias.example.com
     ```

   * 删除记录

     ```http
     GET /aliyun-domain-api/ASP/dns-api.asp?action=DeleteDomainRecord&RecordId=123456
     ```

## 签名原理

阿里云 API 要求对公共参数和业务参数按字母升序排序，连接为查询字符串后，以 `AccessKeySecret + "&"` 作为密钥，
使用 HMAC-SHA1 计算签名，再进行 Base64 编码，并 URL Encode 后作为 `Signature` 参数附加到请求中。

## 示例核心代码

```asp
<!--#include file="config.asp"-->
<!--#include file="sha1.asp"-->
<!--#include file="records.asp"-->
<%
Dim action, resp
action = Request("action")
Select Case action
  Case "DescribeDomainRecords"
    resp = DescribeDomainRecords(Request("DomainName"))
  Case "AddDomainRecord"
    resp = AddDomainRecord(Request("DomainName"), Request("RR"), Request("Type"), Request("Value"), Request("TTL"))
  Case "UpdateDomainRecord"
    resp = UpdateDomainRecord(Request("RecordId"), Request("RR"), Request("Type"), Request("Value"), Request("TTL"))
  Case "DeleteDomainRecord"
    resp = DeleteDomainRecord(Request("RecordId"))
  Case Else
    resp = "{ \"Message\": \"Invalid action\" }"
End Select
Response.ContentType = "application/json"
Response.Write resp
%>
```

## 许可证

本项目采用 MIT 许可证，详见 `LICENSE` 文件。
