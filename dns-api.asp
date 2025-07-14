<%@ Language="VBScript" CodePage="65001" %>
<% Response.Charset = "UTF-8" %>
<% Response.ContentType = "application/json" %>
<!--#include virtual="config.asp"-->
<!--#include virtual="sha1.asp"-->
<%
' DNS解析记录管理API
' 支持的操作：records, add, update, delete, toggle-status

' 调试模式（生产环境请设为False）
Dim DEBUG_MODE
DEBUG_MODE = False

' 获取请求动作
Dim action
action = Request("action")
If action = "" Then action = "records"

' 获取调试参数
If Request("debug") = "1" Then DEBUG_MODE = True

' 获取域名参数
Dim domainName
domainName = Request("domain")
If domainName = "" Then domainName = "yikai.cn" ' 默认域名

' 设置CORS头（如果需要跨域访问）
Response.AddHeader "Access-Control-Allow-Origin", "*"
Response.AddHeader "Access-Control-Allow-Methods", "GET, POST, OPTIONS"
Response.AddHeader "Access-Control-Allow-Headers", "Content-Type"

' 处理OPTIONS请求（CORS预检）
If Request.ServerVariables("REQUEST_METHOD") = "OPTIONS" Then
    Response.End
End If

' 根据动作执行相应操作
Select Case LCase(action)
    Case "records"
        GetDomainRecords domainName
    Case "add"
        AddDomainRecord
    Case "update"
        UpdateDomainRecord
    Case "delete"
        DeleteDomainRecord
    Case "toggle-status"
        ToggleRecordStatus
    Case Else
        ResponseError "无效的操作"
End Select

' ========== API函数 ==========

' 获取域名解析记录列表
Sub GetDomainRecords(domain)
    On Error Resume Next
    Dim params, requestUrl, response
    
    ' 创建API参数
    Set params = CreateApiParams("DescribeDomainRecords")
    If params Is Nothing Then
        ResponseError "参数创建失败"
        Exit Sub
    End If
    
    ' 添加查询参数
    params.Add "DomainName", domain
    params.Add "PageSize", "500"
    params.Add "PageNumber", "1"
    
    ' 计算签名并发送请求
    Dim signature
    signature = ComputeSignature(params, ALIYUN_ACCESS_KEY_SECRET)
    params.Add "Signature", signature
    
    requestUrl = BuildDNSRequestUrl(params)
    response = SendApiRequest(requestUrl)
    
    ' 解析并返回JSON
    If InStr(response, """Code""") > 0 And InStr(response, """Success"":false") > 0 Then
        Dim errorMsg
        errorMsg = ExtractJsonValue(response, "Message")
        ResponseError errorMsg
    Else
        ' 转换为前端需要的格式
        Dim formattedResponse
        formattedResponse = FormatRecordsResponse(response)
        Response.Write formattedResponse
    End If
    
    On Error GoTo 0
End Sub

' 添加解析记录
Sub AddDomainRecord()
    On Error Resume Next
    Dim params, requestUrl, response
    
    ' 获取表单参数 - 同时支持Form和QueryString
    Dim recordType, rr, value, ttl, priority, remark
    recordType = Request("Type")
    rr = Request("RR")
    value = Request("Value")
    ttl = Request("TTL")
    priority = Request("Priority")
    remark = Request("Remark")
    domainName = Request("domain")
    
    ' 参数验证
    If recordType = "" Or rr = "" Or value = "" Then
        ResponseError "必填参数缺失: Type=" & recordType & ", RR=" & rr & ", Value=" & value
        Exit Sub
    End If
    
    ' 创建API参数
    Set params = CreateApiParams("AddDomainRecord")
    If params Is Nothing Then
        ResponseError "参数创建失败"
        Exit Sub
    End If
    
    ' 添加记录参数
    params.Add "DomainName", domainName
    params.Add "RR", rr
    params.Add "Type", recordType
    params.Add "Value", value
    If ttl <> "" Then params.Add "TTL", ttl Else params.Add "TTL", "600"
    
    ' MX记录需要优先级
    If recordType = "MX" And priority <> "" Then
        params.Add "Priority", priority
    End If
    
    ' 调试输出
    'Response.Write "Debug: DomainName=" & domainName & ", RR=" & rr & ", Type=" & recordType & ", Value=" & value & "<br>"
    
    ' 计算签名并发送请求
    Dim signature
    signature = ComputeSignature(params, ALIYUN_ACCESS_KEY_SECRET)
    params.Add "Signature", signature
    
    requestUrl = BuildDNSRequestUrl(params)
    response = SendApiRequest(requestUrl)
    
    ' 处理响应
    If InStr(response, """RecordId""") > 0 Then
        ResponseSuccess "添加成功", response
    Else
        Dim errorMsg, errorCode
        errorMsg = ExtractJsonValue(response, "Message")
        errorCode = ExtractJsonValue(response, "Code")
        If errorCode = "SignatureDoesNotMatch" Then
            ' 签名错误，返回更详细的信息
            ResponseError "签名验证失败: " & errorMsg
        Else
            ResponseError errorMsg
        End If
    End If
    
    On Error GoTo 0
End Sub

' 更新解析记录
Sub UpdateDomainRecord()
    On Error Resume Next
    Dim params, requestUrl, response
    
    ' 获取表单参数
    Dim recordId, recordType, rr, value, ttl, priority
    recordId = Request.Form("recordId")
    recordType = Request.Form("Type")
    rr = Request.Form("RR")
    value = Request.Form("Value")
    ttl = Request.Form("TTL")
    priority = Request.Form("Priority")
    
    ' 参数验证
    If recordId = "" Or recordType = "" Or rr = "" Or value = "" Then
        ResponseError "必填参数缺失"
        Exit Sub
    End If
    
    ' 创建API参数
    Set params = CreateApiParams("UpdateDomainRecord")
    If params Is Nothing Then
        ResponseError "参数创建失败"
        Exit Sub
    End If
    
    ' 添加更新参数
    params.Add "RecordId", recordId
    params.Add "RR", rr
    params.Add "Type", recordType
    params.Add "Value", value
    If ttl <> "" Then params.Add "TTL", ttl
    
    ' MX记录需要优先级
    If recordType = "MX" And priority <> "" Then
        params.Add "Priority", priority
    End If
    
    ' 计算签名并发送请求
    Dim signature
    signature = ComputeSignature(params, ALIYUN_ACCESS_KEY_SECRET)
    params.Add "Signature", signature
    
    requestUrl = BuildDNSRequestUrl(params)
    response = SendApiRequest(requestUrl)
    
    ' 处理响应
    If InStr(response, """RecordId""") > 0 Then
        ResponseSuccess "更新成功", response
    Else
        Dim errorMsg
        errorMsg = ExtractJsonValue(response, "Message")
        ResponseError errorMsg
    End If
    
    On Error GoTo 0
End Sub

' 删除解析记录
Sub DeleteDomainRecord()
    On Error Resume Next
    Dim params, requestUrl, response
    
    ' 获取记录ID
    Dim recordId
    recordId = Request.Form("recordId")
    
    If recordId = "" Then
        ResponseError "记录ID不能为空"
        Exit Sub
    End If
    
    ' 创建API参数
    Set params = CreateApiParams("DeleteDomainRecord")
    If params Is Nothing Then
        ResponseError "参数创建失败"
        Exit Sub
    End If
    
    ' 添加删除参数
    params.Add "RecordId", recordId
    
    ' 计算签名并发送请求
    Dim signature
    signature = ComputeSignature(params, ALIYUN_ACCESS_KEY_SECRET)
    params.Add "Signature", signature
    
    requestUrl = BuildDNSRequestUrl(params)
    response = SendApiRequest(requestUrl)
    
    ' 处理响应
    If InStr(response, """RecordId""") > 0 Or InStr(response, """RequestId""") > 0 Then
        ResponseSuccess "删除成功", response
    Else
        Dim errorMsg
        errorMsg = ExtractJsonValue(response, "Message")
        ResponseError errorMsg
    End If
    
    On Error GoTo 0
End Sub

' 切换记录状态（启用/暂停）
Sub ToggleRecordStatus()
    On Error Resume Next
    Dim params, requestUrl, response
    
    ' 获取记录ID
    Dim recordId
    recordId = Request.Form("recordId")
    
    If recordId = "" Then
        ResponseError "记录ID不能为空"
        Exit Sub
    End If
    
    ' 首先获取当前记录状态
    Dim currentStatus
    currentStatus = GetRecordStatus(recordId)
    
    If currentStatus = "" Then
        ResponseError "无法获取记录状态"
        Exit Sub
    End If
    
    ' 确定新状态
    Dim newStatus
    If currentStatus = "Enable" Or currentStatus = "ENABLE" Then
        newStatus = "Disable"
    Else
        newStatus = "Enable"
    End If
    
    ' 创建API参数
    Set params = CreateApiParams("SetDomainRecordStatus")
    If params Is Nothing Then
        ResponseError "参数创建失败"
        Exit Sub
    End If
    
    ' 添加状态参数
    params.Add "RecordId", recordId
    params.Add "Status", newStatus
    
    ' 计算签名并发送请求
    Dim signature
    signature = ComputeSignature(params, ALIYUN_ACCESS_KEY_SECRET)
    params.Add "Signature", signature
    
    requestUrl = BuildDNSRequestUrl(params)
    response = SendApiRequest(requestUrl)
    
    ' 处理响应
    If InStr(response, """RecordId""") > 0 Or InStr(response, """RequestId""") > 0 Then
        ResponseSuccess "状态切换成功", response
    Else
        Dim errorMsg
        errorMsg = ExtractJsonValue(response, "Message")
        ResponseError errorMsg
    End If
    
    On Error GoTo 0
End Sub

' ========== 辅助函数 ==========

' 创建基础API参数
Function CreateApiParams(action)
    On Error Resume Next
    Dim params
    
    Set params = Server.CreateObject("Scripting.Dictionary")
    If Err.Number <> 0 Then
        Set CreateApiParams = Nothing
        Exit Function
    End If
    
    ' 添加基础参数
    params.Add "Format", "JSON"
    params.Add "Version", "2015-01-09"  ' DNS API版本
    params.Add "AccessKeyId", ALIYUN_ACCESS_KEY_ID
    params.Add "SignatureMethod", "HMAC-SHA1"
    params.Add "Timestamp", GetUTCTime()
    params.Add "SignatureVersion", "1.0"
    params.Add "SignatureNonce", GenerateNonce()
    params.Add "Action", action
    
    Set CreateApiParams = params
    On Error GoTo 0
End Function

' 构建DNS API请求URL
Function BuildDNSRequestUrl(params)
    Dim queryString
    queryString = BuildQueryString(params)
    If queryString = "" Then
        BuildDNSRequestUrl = ""
        Exit Function
    End If
    BuildDNSRequestUrl = "https://dns.aliyuncs.com/?" & queryString
End Function

' 格式化记录列表响应
Function FormatRecordsResponse(jsonResponse)
    On Error Resume Next
    Dim output
    output = "{"
    
    ' 提取总数
    Dim totalCount
    totalCount = ExtractJsonValue(jsonResponse, "TotalCount")
    If totalCount = "" Then totalCount = "0"
    output = output & """totalCount"":" & totalCount & ","
    
    ' 提取记录数组
    Dim recordsStart, recordsEnd
    recordsStart = InStr(jsonResponse, """DomainRecords""")
    If recordsStart > 0 Then
        recordsStart = InStr(recordsStart, jsonResponse, """Record""")
        If recordsStart > 0 Then
            recordsStart = InStr(recordsStart, jsonResponse, "[")
            recordsEnd = InStr(recordsStart, jsonResponse, "]")
            
            If recordsStart > 0 And recordsEnd > recordsStart Then
                Dim recordsData
                recordsData = Mid(jsonResponse, recordsStart, recordsEnd - recordsStart + 1)
                output = output & """records"":" & recordsData
            Else
                output = output & """records"":[]"
            End If
        Else
            output = output & """records"":[]"
        End If
    Else
        output = output & """records"":[]"
    End If
    
    output = output & "}"
    FormatRecordsResponse = output
    On Error GoTo 0
End Function

' 获取记录状态
Function GetRecordStatus(recordId)
    ' 这里简化处理，实际应该调用DescribeDomainRecordInfo API
    GetRecordStatus = "Enable"
End Function

' 响应成功
Sub ResponseSuccess(message, data)
    Response.Write "{"
    Response.Write """success"":true,"
    Response.Write """message"":""" & message & """"
    If data <> "" Then
        Response.Write ",""data"":" & data
    End If
    Response.Write "}"
End Sub

' 响应错误
Sub ResponseError(message)
    Response.Write "{"
    Response.Write """success"":false,"
    Response.Write """message"":""" & message & """"
    Response.Write "}"
End Sub

' 发送API请求
Function SendApiRequest(requestUrl)
    On Error Resume Next
    Dim objXMLHTTP
    Set objXMLHTTP = Server.CreateObject("MSXML2.XMLHTTP")
    
    If Err.Number <> 0 Then
        SendApiRequest = "{""error"":""创建HTTP对象失败""}"
        Exit Function
    End If
    
    objXMLHTTP.Open "GET", requestUrl, False
    objXMLHTTP.Send
    
    If Err.Number <> 0 Then
        SendApiRequest = "{""error"":""发送请求失败""}"
    Else
        SendApiRequest = objXMLHTTP.responseText
    End If
    
    Set objXMLHTTP = Nothing
    On Error GoTo 0
End Function

' 生成UTC时间戳（ISO8601格式）
Function GetUTCTime()
    Dim dt, yyyy, mm, dd, hh, nn, ss
    
    ' 获取UTC时间（假设服务器在UTC+8时区）
    dt = DateAdd("h", -8, Now())
    
    ' 格式化各部分
    yyyy = Year(dt)
    mm = Right("0" & Month(dt), 2)
    dd = Right("0" & Day(dt), 2)
    hh = Right("0" & Hour(dt), 2)
    nn = Right("0" & Minute(dt), 2)
    ss = Right("0" & Second(dt), 2)
    
    ' 返回ISO8601格式
    GetUTCTime = yyyy & "-" & mm & "-" & dd & "T" & hh & ":" & nn & ":" & ss & "Z"
End Function

' 生成随机数（UUID格式）
Function GenerateNonce()
    Dim objTypeLib, guid
    On Error Resume Next
    
    Set objTypeLib = Server.CreateObject("Scriptlet.TypeLib")
    If Err.Number = 0 Then
        guid = objTypeLib.Guid
        guid = Replace(guid, "{", "")
        guid = Replace(guid, "}", "")
        guid = Replace(guid, "-", "")
        GenerateNonce = Left(guid, 32)
    Else
        ' 备用方法
        Randomize
        GenerateNonce = Year(Now) & Month(Now) & Day(Now) & _
                       Hour(Now) & Minute(Now) & Second(Now) & _
                       Int(Rnd * 1000000)
    End If
    
    Set objTypeLib = Nothing
    On Error GoTo 0
End Function

' 计算签名
Function ComputeSignature(params, Secret)
    On Error Resume Next
    
    Dim sortedKeys, key
    sortedKeys = SortDictionaryKeys(params)
    
    Dim canonicalizedQueryString
    canonicalizedQueryString = ""
    For Each key In sortedKeys
        If key <> "Signature" Then
            If canonicalizedQueryString <> "" Then
                canonicalizedQueryString = canonicalizedQueryString & "&"
            End If
            canonicalizedQueryString = canonicalizedQueryString & _
                PercentEncode(key) & "=" & PercentEncode(params(key))
        End If
    Next
    
    Dim stringToSign
    stringToSign = "GET&%2F&" & PercentEncode(canonicalizedQueryString)
    
    ' 调试输出
    If DEBUG_MODE Then
        Response.Write "<!-- Debug Info -->" & vbCrLf
        Response.Write "<!-- Canonicalized Query String: " & canonicalizedQueryString & " -->" & vbCrLf
        Response.Write "<!-- String to Sign: " & stringToSign & " -->" & vbCrLf
    End If
    
    ComputeSignature = HMACSHA1(Secret & "&", stringToSign)
    
    On Error GoTo 0
End Function

' URL编码
Function PercentEncode(str)
    Dim i, char, ascii, encoded
    encoded = ""
    
    For i = 1 To Len(str)
        char = Mid(str, i, 1)
        ascii = Asc(char)
        
        If (ascii >= 65 And ascii <= 90) Or _
           (ascii >= 97 And ascii <= 122) Or _
           (ascii >= 48 And ascii <= 57) Or _
           char = "-" Or char = "_" Or char = "." Or char = "~" Then
            encoded = encoded & char
        Else
            encoded = encoded & "%" & Right("0" & Hex(ascii), 2)
        End If
    Next
    
    PercentEncode = encoded
End Function

' 参数排序（严格按字母顺序）
Function SortDictionaryKeys(dict)
    Dim keys(), i, j, temp, k
    ReDim keys(dict.Count - 1)
    i = 0
    For Each k In dict.Keys
        keys(i) = k
        i = i + 1
    Next
    
    ' 使用冒泡排序，严格按字母顺序（区分大小写）
    For i = 0 To UBound(keys) - 1
        For j = i + 1 To UBound(keys)
            ' 使用二进制比较模式，区分大小写
            If StrComp(keys(i), keys(j), vbBinaryCompare) > 0 Then
                temp = keys(i)
                keys(i) = keys(j)
                keys(j) = temp
            End If
        Next
    Next
    
    SortDictionaryKeys = keys
End Function

' 构建查询字符串
Function BuildQueryString(params)
    Dim key, queryString, sortedKeys
    sortedKeys = SortDictionaryKeys(params)
    
    queryString = ""
    For Each key In sortedKeys
        If queryString <> "" Then
            queryString = queryString & "&"
        End If
        queryString = queryString & key & "=" & Server.URLEncode(params(key))
    Next
    
    BuildQueryString = queryString
End Function

' 从JSON提取值
Function ExtractJsonValue(json, key)
    On Error Resume Next
    Dim pos, startPos, endPos
    
    pos = InStr(json, """" & key & """")
    If pos > 0 Then
        startPos = InStr(pos, json, ":")
        If startPos > 0 Then
            If Mid(json, startPos + 1, 1) = """" Then
                startPos = startPos + 1
                endPos = InStr(startPos + 1, json, """")
                If endPos > startPos Then
                    ExtractJsonValue = Mid(json, startPos + 1, endPos - startPos - 1)
                    Exit Function
                End If
            Else
                startPos = startPos + 1
                endPos = InStr(startPos, json, ",")
                If endPos = 0 Then endPos = InStr(startPos, json, "}")
                If endPos > startPos Then
                    ExtractJsonValue = Trim(Mid(json, startPos, endPos - startPos))
                    Exit Function
                End If
            End If
        End If
    End If
    
    ExtractJsonValue = ""
    On Error GoTo 0
End Function
%>