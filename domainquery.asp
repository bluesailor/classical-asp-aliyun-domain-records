<%@ Language="VBScript" CodePage="65001" %>
<% Response.Charset = "UTF-8" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>阿里云域名查询工具</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        'primary': '#1e40af',
                        'primary-dark': '#1e3a8a',
                    }
                }
            }
        }
    </script>
</head>
<body class="bg-gradient-to-br from-blue-50 to-indigo-100 min-h-screen">
    <div class="container mx-auto px-4 py-8">
        <!-- Header -->
        <div class="text-center mb-8">
            <h1 class="text-4xl font-bold text-gray-800 mb-2">阿里云域名查询</h1>
            <p class="text-gray-600 text-lg">快速查询域名注册状态</p>
        </div>

        <!-- Main Content Card -->
        <div class="max-w-4xl mx-auto bg-white rounded-2xl shadow-xl overflow-hidden">
            <!-- Search Form -->
            <div class="p-8 border-b border-gray-200">
                <form id="domainForm" class="space-y-6">
                    <!-- Domain Input -->
                    <div class="flex flex-col md:flex-row gap-4">
                        <div class="flex-1">
                            <label for="domainInput" class="block text-sm font-medium text-gray-700 mb-2">
                                输入域名
                            </label>
                            <input 
                                type="text" 
                                id="domainInput" 
                                name="domain"
                                placeholder="例如：example"
                                class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-colors"
                                required
                            >
                        </div>
                        <div class="md:w-auto">
                            <label class="block text-sm font-medium text-gray-700 mb-2">&nbsp;</label>
                            <button 
                                type="submit" 
                                class="w-full md:w-auto px-8 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 focus:ring-4 focus:ring-blue-500 focus:ring-opacity-30 transition-colors"
                            >
                                <span class="flex items-center justify-center gap-2">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                                    </svg>
                                    查询
                                </span>
                            </button>
                        </div>
                    </div>

                    <!-- Extensions Selection -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-3">
                            选择后缀 <span class="text-gray-500">(可多选)</span>
                        </label>
                        <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-3">
                            <label class="flex items-center space-x-2 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 cursor-pointer transition-colors">
                                <input type="checkbox" name="ext" value=".com" checked class="rounded text-blue-600 focus:ring-blue-500">
                                <span class="text-sm font-medium">.com</span>
                            </label>
                            <label class="flex items-center space-x-2 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 cursor-pointer transition-colors">
                                <input type="checkbox" name="ext" value=".cn" class="rounded text-blue-600 focus:ring-blue-500">
                                <span class="text-sm font-medium">.cn</span>
                            </label>
                            <label class="flex items-center space-x-2 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 cursor-pointer transition-colors">
                                <input type="checkbox" name="ext" value=".net" class="rounded text-blue-600 focus:ring-blue-500">
                                <span class="text-sm font-medium">.net</span>
                            </label>
                            <label class="flex items-center space-x-2 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 cursor-pointer transition-colors">
                                <input type="checkbox" name="ext" value=".org" class="rounded text-blue-600 focus:ring-blue-500">
                                <span class="text-sm font-medium">.org</span>
                            </label>
                            <label class="flex items-center space-x-2 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 cursor-pointer transition-colors">
                                <input type="checkbox" name="ext" value=".com.cn" class="rounded text-blue-600 focus:ring-blue-500">
                                <span class="text-sm font-medium">.com.cn</span>
                            </label>
                            <label class="flex items-center space-x-2 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 cursor-pointer transition-colors">
                                <input type="checkbox" name="ext" value=".net.cn" class="rounded text-blue-600 focus:ring-blue-500">
                                <span class="text-sm font-medium">.net.cn</span>
                            </label>
                            <label class="flex items-center space-x-2 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 cursor-pointer transition-colors">
                                <input type="checkbox" name="ext" value=".info" class="rounded text-blue-600 focus:ring-blue-500">
                                <span class="text-sm font-medium">.info</span>
                            </label>
                            <label class="flex items-center space-x-2 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 cursor-pointer transition-colors">
                                <input type="checkbox" name="ext" value=".biz" class="rounded text-blue-600 focus:ring-blue-500">
                                <span class="text-sm font-medium">.biz</span>
                            </label>
                            <label class="flex items-center space-x-2 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 cursor-pointer transition-colors">
                                <input type="checkbox" name="ext" value=".top" class="rounded text-blue-600 focus:ring-blue-500">
                                <span class="text-sm font-medium">.top</span>
                            </label>
                            <label class="flex items-center space-x-2 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 cursor-pointer transition-colors">
                                <input type="checkbox" name="ext" value=".xyz" class="rounded text-blue-600 focus:ring-blue-500">
                                <span class="text-sm font-medium">.xyz</span>
                            </label>
                            <label class="flex items-center space-x-2 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 cursor-pointer transition-colors">
                                <input type="checkbox" name="ext" value=".club" class="rounded text-blue-600 focus:ring-blue-500">
                                <span class="text-sm font-medium">.club</span>
                            </label>
                            <label class="flex items-center space-x-2 p-3 bg-gray-50 rounded-lg hover:bg-gray-100 cursor-pointer transition-colors">
                                <input type="checkbox" name="ext" value=".shop" class="rounded text-blue-600 focus:ring-blue-500">
                                <span class="text-sm font-medium">.shop</span>
                            </label>
                        </div>
                    </div>
                </form>
            </div>

            <!-- Results Section -->
            <div id="resultsSection" class="p-8 hidden">
                <div class="flex items-center justify-between mb-6">
                    <h3 class="text-xl font-bold text-gray-800">查询结果</h3>
                    <div id="progressInfo" class="text-sm text-gray-600"></div>
                </div>
                <div id="resultsContainer" class="space-y-3"></div>
            </div>

            <!-- Loading Section -->
            <div id="loadingSection" class="p-8 text-center hidden">
                <div class="inline-flex items-center gap-3">
                    <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
                    <span class="text-gray-600">正在查询中...</span>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class="text-center mt-8 text-gray-500 text-sm">
            <p>Powered by Aliyun Domain API | 查询结果仅供参考</p>
        </div>
    </div>

    <script>
        document.getElementById('domainForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const domainInput = document.getElementById('domainInput').value.trim();
            const checkboxes = document.querySelectorAll('input[name="ext"]:checked');
            
            if (!domainInput) {
                alert('请输入域名');
                return;
            }
            
            if (checkboxes.length === 0) {
                alert('请至少选择一个域名后缀');
                return;
            }
            
            // 显示加载状态
            showLoading();
            
            // 收集选中的后缀
            const extensions = Array.from(checkboxes).map(cb => cb.value);
            
            // 开始查询
            queryDomains(domainInput, extensions);
        });

        function showLoading() {
            document.getElementById('loadingSection').classList.remove('hidden');
            document.getElementById('resultsSection').classList.add('hidden');
        }

        function showResults() {
            document.getElementById('loadingSection').classList.add('hidden');
            document.getElementById('resultsSection').classList.remove('hidden');
        }

        function queryDomains(domain, extensions) {
            const resultsContainer = document.getElementById('resultsContainer');
            const progressInfo = document.getElementById('progressInfo');
            
            resultsContainer.innerHTML = '';
            
            let completed = 0;
            const total = extensions.length;
            
            extensions.forEach((ext, index) => {
                const fullDomain = domain + ext;
                
                // 创建结果项
                const resultItem = createResultItem(fullDomain, 'loading');
                resultsContainer.appendChild(resultItem);
                
                // 发送查询请求
                setTimeout(() => {
                    fetch(`domainquery.asp?domainname=${encodeURIComponent(fullDomain)}`)
                        .then(response => response.text())
                        .then(data => {
                            completed++;
                            updateProgressInfo(completed, total);
                            
                            const status = parseResponse(data);
                            updateResultItem(resultItem, fullDomain, status, data);
                        })
                        .catch(error => {
                            completed++;
                            updateProgressInfo(completed, total);
                            updateResultItem(resultItem, fullDomain, 'error', error.message);
                        });
                }, index * 200); // 延迟查询避免过于频繁
            });
            
            showResults();
            updateProgressInfo(0, total);
        }

        function createResultItem(domain, status) {
            const div = document.createElement('div');
            div.className = 'flex items-center justify-between p-4 bg-gray-50 rounded-lg border-l-4 border-gray-300 transition-all';
            
            div.innerHTML = `
                <div class="flex items-center gap-3">
                    <div class="flex-shrink-0">
                        ${getStatusIcon(status)}
                    </div>
                    <div>
                        <div class="font-medium text-gray-900">${domain}</div>
                        <div class="text-sm text-gray-500 status-text">查询中...</div>
                    </div>
                </div>
                <div class="flex items-center gap-2">
                    ${getActionButton(domain, status)}
                </div>
            `;
            
            return div;
        }

        function updateResultItem(element, domain, status, response) {
            const statusText = element.querySelector('.status-text');
            const statusIcon = element.querySelector('.status-icon');
            const actionArea = element.querySelector('.flex.items-center.gap-2');
            
            // 更新样式
            element.className = `flex items-center justify-between p-4 rounded-lg border-l-4 transition-all ${getStatusClasses(status)}`;
            
            // 更新图标
            statusIcon.outerHTML = getStatusIcon(status);
            
            // 更新状态文本
            statusText.textContent = getStatusText(status, response);
            
            // 更新操作按钮
            actionArea.innerHTML = getActionButton(domain, status);
        }

        function parseResponse(response) {
            const trimmed = response.trim();
            if (trimmed === 'Y') return 'available';
            if (trimmed === 'N') return 'taken';
            if (trimmed.startsWith('ERROR:')) return 'error';
            return 'error';
        }

        function getStatusClasses(status) {
            switch (status) {
                case 'available':
                    return 'bg-green-50 border-green-400';
                case 'taken':
                    return 'bg-red-50 border-red-400';
                case 'error':
                    return 'bg-yellow-50 border-yellow-400';
                default:
                    return 'bg-gray-50 border-gray-300';
            }
        }

        function getStatusIcon(status) {
            switch (status) {
                case 'available':
                    return '<div class="status-icon w-3 h-3 bg-green-500 rounded-full"></div>';
                case 'taken':
                    return '<div class="status-icon w-3 h-3 bg-red-500 rounded-full"></div>';
                case 'error':
                    return '<div class="status-icon w-3 h-3 bg-yellow-500 rounded-full"></div>';
                case 'loading':
                    return '<div class="status-icon animate-spin rounded-full h-3 w-3 border-b-2 border-blue-600"></div>';
                default:
                    return '<div class="status-icon w-3 h-3 bg-gray-400 rounded-full"></div>';
            }
        }

        function getStatusText(status, response) {
            switch (status) {
                case 'available':
                    return '可以注册';
                case 'taken':
                    return '已被注册';
                case 'error':
                    return response.replace('ERROR:', '').trim();
                default:
                    return '查询中...';
            }
        }

        function getActionButton(domain, status) {
            switch (status) {
                case 'available':
                    return `
                        <button onclick="registerDomain('${domain}')" 
                                class="px-4 py-2 bg-green-600 text-white text-sm rounded-lg hover:bg-green-700 transition-colors">
                            立即注册
                        </button>
                    `;
                case 'taken':
                    return `
                        <button onclick="whoisQuery('${domain}')" 
                                class="px-4 py-2 bg-blue-600 text-white text-sm rounded-lg hover:bg-blue-700 transition-colors">
                            Whois查询
                        </button>
                    `;
                case 'error':
                    return `
                        <button onclick="retryQuery('${domain}')" 
                                class="px-4 py-2 bg-gray-600 text-white text-sm rounded-lg hover:bg-gray-700 transition-colors">
                            重试
                        </button>
                    `;
                default:
                    return '';
            }
        }

        function updateProgressInfo(completed, total) {
            const progressInfo = document.getElementById('progressInfo');
            progressInfo.textContent = `已完成 ${completed}/${total}`;
        }

        function registerDomain(domain) {
            // 这里可以跳转到域名注册页面
            alert(`准备注册域名: ${domain}`);
        }

        function whoisQuery(domain) {
            // 这里可以打开Whois查询页面
            window.open(`https://whois.aliyun.com/whois/domain/${domain}`, '_blank');
        }

        function retryQuery(domain) {
            // 重新查询单个域名
            const extensions = [domain.substring(domain.indexOf('.'))];
            const baseDomain = domain.substring(0, domain.indexOf('.'));
            queryDomains(baseDomain, extensions);
        }
    </script>
</body>
</html>

<%
' 如果是查询请求，处理域名查询逻辑
If Request("domainname") <> "" Then
    Response.Clear
    Response.ContentType = "text/plain; charset=utf-8"
    
    On Error Resume Next
    %>
    <!--#include virtual="config.asp"-->
    <!--#include virtual="sha1.asp"-->
    <%
    
    ' 获取参数
    Function SafeRequest(paramName)
        Dim value
        value = Request(paramName)
        If IsNull(value) Then
            SafeRequest = ""
        Else
            SafeRequest = Trim(Replace(Replace(value, "'", ""), """", ""))
        End If
    End Function

    ' 获取域名参数
    Dim domainName
    domainName = SafeRequest("domainname")

    If domainName = "" Then
        Response.Write "ERROR: 域名不能为空"
        Response.End
    End If

    ' 基本域名格式验证
    If InStr(domainName, ".") = 0 Then
        Response.Write "ERROR: 域名格式不正确"
        Response.End
    End If

    ' 调用阿里云域名查询
    Dim result, errorMsg
    result = QueryDomainAvailability(domainName, errorMsg)

    ' 返回结果
    Select Case result
        Case "1"
            Response.Write "Y"  ' 可注册
        Case "2"
            Response.Write "N"  ' 已注册
        Case Else
            Response.Write "ERROR: " & errorMsg
    End Select

    ' 查询域名可用性函数
    Function QueryDomainAvailability(domain, ByRef errMsg)
        On Error Resume Next
        
        ' 验证API配置
        If ALIYUN_ACCESS_KEY_ID = "KEY_ID" Or ALIYUN_ACCESS_KEY_SECRET = "KEY_SECRET" Then
            errMsg = "请先配置阿里云API密钥"
            QueryDomainAvailability = "-1"
            Exit Function
        End If
        
        ' 创建API参数
        Dim params
        Set params = CreateApiParams("CheckDomain")
        If params Is Nothing Then
            errMsg = "参数创建失败"
            QueryDomainAvailability = "-1"
            Exit Function
        End If
        
        ' 添加域名查询参数
        params.Add "DomainName", domain
        
        ' 计算签名
        Dim signature
        signature = ComputeSignature(params, ALIYUN_ACCESS_KEY_SECRET)
        If signature = "" Then
            errMsg = "签名计算失败"
            QueryDomainAvailability = "-1"
            Exit Function
        End If
        
        params.Add "Signature", signature
        
        ' 构建请求URL
        Dim requestUrl
        requestUrl = BuildDomainRequestUrl(params)
        
        ' 发送API请求
        Dim response
        response = SendApiRequest(requestUrl)
        
        If Err.Number <> 0 Then
            errMsg = "网络请求失败: " & Err.Description
            QueryDomainAvailability = "-1"
            Exit Function
        End If
        
        ' 解析响应
        QueryDomainAvailability = ParseDomainResponse(response, errMsg)
        
        On Error GoTo 0
    End Function

    ' 创建基础API参数
    Function CreateApiParams(action)
        On Error Resume Next
        
        Set CreateApiParams = Server.CreateObject("Scripting.Dictionary")
        If Err.Number <> 0 Then
            Set CreateApiParams = Nothing
            Exit Function
        End If
        
        ' 添加基础参数
        CreateApiParams.Add "Format", "JSON"
        CreateApiParams.Add "Version", "2018-01-29"  ' 域名API版本
        CreateApiParams.Add "AccessKeyId", ALIYUN_ACCESS_KEY_ID
        CreateApiParams.Add "SignatureMethod", "HMAC-SHA1"
        CreateApiParams.Add "Timestamp", GetUTCTime()
        CreateApiParams.Add "SignatureVersion", "1.0"
        CreateApiParams.Add "SignatureNonce", GenerateNonce()
        CreateApiParams.Add "Action", action
        
        On Error GoTo 0
    End Function

    ' 构建域名API请求URL
    Function BuildDomainRequestUrl(params)
        Dim queryString
        queryString = BuildQueryString(params)
        If queryString = "" Then
            BuildDomainRequestUrl = ""
        Else
            BuildDomainRequestUrl = "https://domain.aliyuncs.com/?" & queryString
        End If
    End Function

    ' 解析域名查询响应
    Function ParseDomainResponse(jsonResponse, ByRef errMsg)
        On Error Resume Next
        
        ' 检查是否有错误
        If InStr(jsonResponse, """Code""") > 0 And InStr(jsonResponse, """Message""") > 0 Then
            Dim errorCode, errorMessage
            errorCode = ExtractJsonValue(jsonResponse, "Code")
            errorMessage = ExtractJsonValue(jsonResponse, "Message")
            
            If errorCode <> "" Then
                errMsg = "API错误(" & errorCode & "): " & errorMessage
                ParseDomainResponse = "-1"
                Exit Function
            End If
        End If
        
        ' 提取域名可用性状态
        Dim avail
        avail = ExtractJsonValue(jsonResponse, "Avail")
        
        If avail = "" Then
            ' 尝试其他可能的字段名
            avail = ExtractJsonValue(jsonResponse, "Available")
            If avail = "" Then
                avail = ExtractJsonValue(jsonResponse, "Status")
            End If
        End If
        
        ' 解析状态
        Select Case LCase(avail)
            Case "true", "1", "available", "ok"
                ParseDomainResponse = "1"  ' 可注册
                errMsg = "域名可注册"
            Case "false", "0", "unavailable", "registered"
                ParseDomainResponse = "2"  ' 已注册
                errMsg = "域名已被注册"
            Case Else
                ParseDomainResponse = "-1"
                errMsg = "无法确定域名状态: " & jsonResponse
        End Select
        
        On Error GoTo 0
    End Function

    ' 发送API请求
    Function SendApiRequest(requestUrl)
        On Error Resume Next
        
        Dim xmlhttp
        Set xmlhttp = Server.CreateObject("MSXML2.ServerXMLHTTP.6.0")
        If xmlhttp Is Nothing Then
            Set xmlhttp = Server.CreateObject("MSXML2.ServerXMLHTTP")
        End If
        If xmlhttp Is Nothing Then
            Set xmlhttp = Server.CreateObject("Microsoft.XMLHTTP")
        End If
        
        If xmlhttp Is Nothing Then
            SendApiRequest = "{""error"":""创建HTTP对象失败""}"
            Exit Function
        End If
        
        ' 设置超时
        xmlhttp.setTimeouts 10000, 10000, 30000, 30000
        
        ' 发送GET请求
        xmlhttp.Open "GET", requestUrl, False
        xmlhttp.setRequestHeader "User-Agent", "Aliyun Domain Query Tool"
        xmlhttp.Send
        
        If Err.Number <> 0 Then
            SendApiRequest = "{""error"":""发送请求失败: " & Err.Description & """}"
        ElseIf xmlhttp.Status = 200 Then
            SendApiRequest = xmlhttp.responseText
        Else
            SendApiRequest = "{""error"":""HTTP错误: " & xmlhttp.Status & """}"
        End If
        
        Set xmlhttp = Nothing
        On Error GoTo 0
    End Function

    ' 计算API签名
    Function ComputeSignature(params, secretKey)
        On Error Resume Next
        
        ' 获取排序后的参数键
        Dim sortedKeys
        sortedKeys = SortDictionaryKeys(params)
        
        ' 构建规范化查询字符串
        Dim canonicalizedQueryString, key
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
        
        ' 构建待签名字符串
        Dim stringToSign
        stringToSign = "GET&%2F&" & PercentEncode(canonicalizedQueryString)
        
        ' 计算HMAC-SHA1签名
        ComputeSignature = HMACSHA1(secretKey & "&", stringToSign)
        
        On Error GoTo 0
    End Function

    ' HMAC-SHA1计算
    Function HMACSHA1(key, message)
        On Error Resume Next
        
        If key = "" Or message = "" Then
            HMACSHA1 = ""
            Exit Function
        End If
        
        ' 调用JavaScript实现的HMAC-SHA1
        HMACSHA1 = b64_hmac_sha1(key, message)
        
        If Err.Number <> 0 Then
            HMACSHA1 = ""
            Err.Clear
        End If
        
        On Error GoTo 0
    End Function

    ' URL百分号编码
    Function PercentEncode(str)
        Dim i, char, ascii, encoded
        encoded = ""
        
        For i = 1 To Len(str)
            char = Mid(str, i, 1)
            ascii = Asc(char)
            
            ' RFC 3986 unreserved characters
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

    ' 字典键排序
    Function SortDictionaryKeys(dict)
        Dim keys(), i, j, temp, k
        ReDim keys(dict.Count - 1)
        
        ' 获取所有键
        i = 0
        For Each k In dict.Keys
            keys(i) = k
            i = i + 1
        Next
        
        ' 冒泡排序（按字母顺序）
        For i = 0 To UBound(keys) - 1
            For j = i + 1 To UBound(keys)
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

    ' 生成UTC时间戳
    Function GetUTCTime()
        Dim dt, yyyy, mm, dd, hh, nn, ss
        
        ' 获取UTC时间（根据服务器时区调整）
        dt = DateAdd("h", -8, Now())  ' 假设服务器在UTC+8
        
        yyyy = Year(dt)
        mm = Right("0" & Month(dt), 2)
        dd = Right("0" & Day(dt), 2)
        hh = Right("0" & Hour(dt), 2)
        nn = Right("0" & Minute(dt), 2)
        ss = Right("0" & Second(dt), 2)
        
        GetUTCTime = yyyy & "-" & mm & "-" & dd & "T" & hh & ":" & nn & ":" & ss & "Z"
    End Function

    ' 生成随机数
    Function GenerateNonce()
        Dim objTypeLib, guid
        On Error Resume Next
        
        Set objTypeLib = Server.CreateObject("Scriptlet.TypeLib")
        If Err.Number = 0 Then
            guid = objTypeLib.Guid
            guid = Replace(Replace(Replace(guid, "{", ""), "}", ""), "-", "")
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

    ' 从JSON提取值
    Function ExtractJsonValue(json, key)
        On Error Resume Next
        Dim pos, startPos, endPos
        
        pos = InStr(json, """" & key & """")
        If pos > 0 Then
            startPos = InStr(pos, json, ":")
            If startPos > 0 Then
                ' 跳过空格
                startPos = startPos + 1
                Do While Mid(json, startPos, 1) = " "
                    startPos = startPos + 1
                Loop
                
                If Mid(json, startPos, 1) = """" Then
                    ' 字符串值
                    startPos = startPos + 1
                    endPos = InStr(startPos, json, """")
                    If endPos > startPos Then
                        ExtractJsonValue = Mid(json, startPos, endPos - startPos)
                        Exit Function
                    End If
                Else
                    ' 数值或布尔值
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

    ' 错误检查
    If Err.Number <> 0 Then
        Response.Write "ERROR: 系统错误 - " & Err.Description
    End If
    
    Response.End
End If
%>