<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>域名解析管理</title>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- jQuery -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <!-- SweetAlert2 -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/sweetalert2/11.10.1/sweetalert2.all.min.js"></script>
    
    <style>
        /* 自定义滚动条 */
        ::-webkit-scrollbar {
            width: 6px;
            height: 6px;
        }
        ::-webkit-scrollbar-track {
            background: #f1f1f1;
        }
        ::-webkit-scrollbar-thumb {
            background: #888;
            border-radius: 3px;
        }
        ::-webkit-scrollbar-thumb:hover {
            background: #555;
        }
        
        /* 加载动画 */
        .loader {
            border: 3px solid #f3f3f3;
            border-top: 3px solid #3b82f6;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        /* 表格悬停效果 */
        .record-row:hover {
            background-color: #f9fafb;
        }
        
        /* 记录值显示优化 */
        .record-value {
            max-width: 400px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            cursor: pointer;
            position: relative;
        }
        
        .record-value:hover {
            overflow: visible;
            white-space: normal;
            word-break: break-all;
            z-index: 10;
        }
        
        /* 主机记录显示优化 */
        .record-rr {
            max-width: 200px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            cursor: pointer;
        }
        
        .record-rr:hover {
            overflow: visible;
            white-space: normal;
            word-break: break-all;
            z-index: 10;
            background-color: #f3f4f6;
            padding: 4px 8px;
            border-radius: 4px;
            position: relative;
        }
        
        /* 模态框动画 */
        .modal-enter {
            animation: modalEnter 0.3s ease-out;
        }
        
        @keyframes modalEnter {
            from {
                opacity: 0;
                transform: scale(0.9);
            }
            to {
                opacity: 1;
                transform: scale(1);
            }
        }
        
        /* 域名输入框动画 */
        .domain-input-container {
            animation: fadeIn 0.5s ease-out;
        }
        
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body class="bg-gray-50">
    <!-- 域名输入界面 -->
    <div id="domainInputSection" class="min-h-screen flex items-center justify-center px-4">
        <div class="domain-input-container max-w-md w-full">
            <div class="bg-white rounded-lg shadow-lg p-8">
                <div class="text-center mb-8">
                    <i class="fas fa-globe text-6xl text-blue-600 mb-4"></i>
                    <h1 class="text-3xl font-bold text-gray-900">域名解析管理</h1>
                    <p class="text-gray-600 mt-2">请输入要管理的域名</p>
                </div>
                
                <form id="domainForm" class="space-y-4">
                    <div>
                        <label for="domainInput" class="block text-sm font-medium text-gray-700 mb-2">域名</label>
                        <input type="text" 
                               id="domainInput" 
                               placeholder="例如：example.com" 
                               class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent text-lg"
                               required>
                        <p class="text-xs text-gray-500 mt-2">请输入不带 http:// 或 https:// 的域名</p>
                    </div>
                    
                    <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-lg transition duration-200 flex items-center justify-center">
                        <i class="fas fa-sign-in-alt mr-2"></i>
                        进入管理
                    </button>
                </form>
                
                <!-- 最近管理的域名 -->
                <div id="recentDomains" class="mt-6 pt-6 border-t border-gray-200 hidden">
                    <h3 class="text-sm font-medium text-gray-700 mb-3">最近管理的域名</h3>
                    <div id="recentDomainsList" class="space-y-2"></div>
                </div>
            </div>
        </div>
    </div>

    <!-- 域名管理界面 -->
    <div id="managementSection" class="hidden">
        <!-- 头部 -->
        <header class="bg-white shadow-sm border-b">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex justify-between items-center py-4">
                    <div class="flex items-center space-x-4">
                        <h1 class="text-2xl font-bold text-gray-900">
                            <i class="fas fa-globe text-blue-600 mr-2"></i>
                            域名解析管理
                        </h1>
                        <span id="currentDomain" class="bg-blue-100 text-blue-800 text-sm font-medium px-3 py-1 rounded-full"></span>
                    </div>
                    <div class="flex items-center space-x-4">
                        <button onclick="showAddModal()" class="bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition duration-200 flex items-center">
                            <i class="fas fa-plus mr-2"></i>
                            添加记录
                        </button>
                        <button onclick="changeDomain()" class="bg-gray-600 hover:bg-gray-700 text-white font-medium py-2 px-4 rounded-lg transition duration-200 flex items-center">
                            <i class="fas fa-exchange-alt mr-2"></i>
                            切换域名
                        </button>
                    </div>
                </div>
            </div>
        </header>

        <!-- 主内容区 -->
        <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <!-- 搜索和过滤 -->
            <div class="bg-white rounded-lg shadow p-4 mb-6">
                <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                    <div class="flex-1 max-w-md">
                        <div class="relative">
                            <input type="text" id="searchInput" placeholder="搜索主机记录或记录值..." 
                                   class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                            <i class="fas fa-search absolute left-3 top-3 text-gray-400"></i>
                        </div>
                    </div>
                    
                    <div class="flex items-center space-x-4">
                        <select id="typeFilter" class="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                            <option value="">所有类型</option>
                            <option value="A">A记录</option>
                            <option value="AAAA">AAAA记录</option>
                            <option value="CNAME">CNAME记录</option>
                            <option value="MX">MX记录</option>
                            <option value="TXT">TXT记录</option>
                            <option value="NS">NS记录</option>
                        </select>
                        
                        <button onclick="refreshRecords()" class="px-4 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-lg transition duration-200">
                            <i class="fas fa-sync-alt mr-2"></i>
                            刷新
                        </button>
                    </div>
                </div>
            </div>

            <!-- 记录列表 -->
            <div class="bg-white rounded-lg shadow overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="min-w-full">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">主机记录</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">类型</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">记录值</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">TTL</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">状态</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">备注</th>
                                <th class="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">操作</th>
                            </tr>
                        </thead>
                        <tbody id="recordsTableBody" class="bg-white divide-y divide-gray-200">
                            <!-- 记录将通过JavaScript动态加载 -->
                        </tbody>
                    </table>
                </div>
                
                <!-- 加载状态 -->
                <div id="loadingState" class="hidden p-8 text-center">
                    <div class="loader mx-auto mb-4"></div>
                    <p class="text-gray-500">正在加载解析记录...</p>
                </div>
                
                <!-- 空状态 -->
                <div id="emptyState" class="hidden p-8 text-center">
                    <i class="fas fa-inbox text-4xl text-gray-300 mb-4"></i>
                    <p class="text-gray-500">暂无解析记录</p>
                </div>
            </div>
            
            <div class="mt-4">
                <button onclick="quickAddAliyunMail()" class="bg-green-600 hover:bg-green-700 text-white font-medium py-2 px-4 rounded-lg transition duration-200 flex items-center">
                    <i class="fas fa-envelope mr-2"></i>
                    一键配置阿里云邮箱
                </button>
            </div>

            <!-- 解析记录说明 -->
            <div class="mt-8 bg-blue-50 rounded-lg p-6">
                <h3 class="text-lg font-semibold text-gray-900 mb-4">
                    <i class="fas fa-info-circle text-blue-600 mr-2"></i>
                    解析记录类型说明
                </h3>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 text-sm">
                    <div class="bg-white rounded-lg p-4">
                        <h4 class="font-semibold text-blue-600 mb-2">A记录</h4>
                        <p class="text-gray-600">将域名指向一个IPv4地址，如：192.168.1.1</p>
                        <p class="text-xs text-gray-500 mt-1">常用于网站、邮件服务器等</p>
                    </div>
                    <div class="bg-white rounded-lg p-4">
                        <h4 class="font-semibold text-blue-600 mb-2">AAAA记录</h4>
                        <p class="text-gray-600">将域名指向一个IPv6地址</p>
                        <p class="text-xs text-gray-500 mt-1">用于IPv6网络环境</p>
                    </div>
                    <div class="bg-white rounded-lg p-4">
                        <h4 class="font-semibold text-blue-600 mb-2">CNAME记录</h4>
                        <p class="text-gray-600">将域名指向另一个域名</p>
                        <p class="text-xs text-gray-500 mt-1">常用于CDN加速、域名别名</p>
                    </div>
                    <div class="bg-white rounded-lg p-4">
                        <h4 class="font-semibold text-blue-600 mb-2">MX记录</h4>
                        <p class="text-gray-600">指定邮件服务器地址</p>
                        <p class="text-xs text-gray-500 mt-1">用于接收邮件，需设置优先级</p>
                    </div>
                    <div class="bg-white rounded-lg p-4">
                        <h4 class="font-semibold text-blue-600 mb-2">TXT记录</h4>
                        <p class="text-gray-600">文本记录，可包含任意文本</p>
                        <p class="text-xs text-gray-500 mt-1">常用于域名验证、SPF记录等</p>
                    </div>
                    <div class="bg-white rounded-lg p-4">
                        <h4 class="font-semibold text-blue-600 mb-2">NS记录</h4>
                        <p class="text-gray-600">指定域名的DNS服务器</p>
                        <p class="text-xs text-gray-500 mt-1">一般由域名注册商自动设置</p>
                    </div>
                </div>
                <div class="mt-4 p-4 bg-yellow-50 rounded-lg border border-yellow-200">
                    <p class="text-sm text-yellow-800">
                        <i class="fas fa-lightbulb mr-2"></i>
                        <strong>提示：</strong>主机记录中 "@" 表示直接解析主域名，"*" 表示泛解析（匹配所有子域名）
                    </p>
                </div>
                
                <!-- 阿里云邮箱配置说明 -->
                <div class="mt-4 p-4 bg-green-50 rounded-lg border border-green-200">
                    <h4 class="text-sm font-semibold text-green-800 mb-2">
                        <i class="fas fa-envelope mr-2"></i>
                        阿里云企业邮箱快速配置
                    </h4>
                    <p class="text-sm text-green-700">
                        使用"一键配置阿里云邮箱"功能可以自动添加以下记录：
                    </p>
                    <ul class="text-xs text-green-600 mt-2 space-y-1">
                        <li>• 3条MX记录（邮件路由）</li>
                        <li>• 4条CNAME记录（IMAP/POP3/SMTP/Webmail）</li>
                        <li>• 1条TXT记录（SPF反垃圾邮件）</li>
                    </ul>
                </div>
            </div>
        </main>
    </div>

    <!-- 添加/编辑记录模态框 -->
    <div id="recordModal" class="hidden fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
        <div class="relative top-20 mx-auto p-5 border w-full max-w-md shadow-lg rounded-lg bg-white modal-enter">
            <div class="mt-3">
                <h3 class="text-lg font-semibold text-gray-900 mb-4" id="modalTitle">添加解析记录</h3>
                
                <form id="recordForm">
                    <input type="hidden" id="recordId">
                    
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">记录类型</label>
                        <select id="recordType" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                            <option value="A">A - 将域名指向IPv4地址</option>
                            <option value="AAAA">AAAA - 将域名指向IPv6地址</option>
                            <option value="CNAME">CNAME - 将域名指向另一个域名</option>
                            <option value="MX">MX - 邮件交换记录</option>
                            <option value="TXT">TXT - 文本记录</option>
                            <option value="NS">NS - 域名服务器记录</option>
                        </select>
                    </div>
                    
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">主机记录</label>
                        <input type="text" id="recordRR" placeholder="如：www、@、*" 
                               class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                        <p class="text-xs text-gray-500 mt-1">@ 表示直接解析主域名</p>
                    </div>
                    
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">记录值</label>
                        <input type="text" id="recordValue" placeholder="如：IP地址或域名" 
                               class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                    </div>
                    
                    <div class="mb-4" id="mxPriorityDiv" style="display:none;">
                        <label class="block text-sm font-medium text-gray-700 mb-2">MX优先级</label>
                        <input type="number" id="recordPriority" value="10" min="1" max="50"
                               class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                    </div>
                    
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">TTL (秒)</label>
                        <select id="recordTTL" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                            <option value="600">10分钟</option>
                            <option value="1800">30分钟</option>
                            <option value="3600">1小时</option>
                            <option value="43200">12小时</option>
                            <option value="86400">1天</option>
                        </select>
                    </div>
                    
                    <div class="mb-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">备注</label>
                        <input type="text" id="recordRemark" placeholder="选填" 
                               class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                    </div>
                    
                    <div class="flex justify-end space-x-3 mt-6">
                        <button type="button" onclick="closeModal()" 
                                class="px-4 py-2 bg-gray-200 hover:bg-gray-300 text-gray-800 rounded-lg transition duration-200">
                            取消
                        </button>
                        <button type="submit" 
                                class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition duration-200">
                            <i class="fas fa-save mr-2"></i>
                            保存
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        // 配置
        const API_BASE = 'dns-api.asp';
        let CURRENT_DOMAIN = '';
        
        // 全局变量
        let allRecords = [];
        let currentRecords = [];
        
        // 页面加载完成后初始化
        $(document).ready(function() {
            // 检查URL参数
            const urlParams = new URLSearchParams(window.location.search);
            const domainParam = urlParams.get('domain');
            
            if (domainParam) {
                // 如果有域名参数，直接进入管理界面
                initializeDomain(domainParam);
            } else {
                // 显示域名输入界面
                showDomainInput();
            }
            
            // 绑定域名表单提交事件
            $('#domainForm').on('submit', function(e) {
                e.preventDefault();
                const domain = $('#domainInput').val().trim();
                if (domain) {
                    // 更新URL
                    window.history.pushState({}, '', `?domain=${encodeURIComponent(domain)}`);
                    initializeDomain(domain);
                }
            });
            
            // 绑定搜索事件
            $('#searchInput').on('input', filterRecords);
            $('#typeFilter').on('change', filterRecords);
            
            // 绑定表单提交事件
            $('#recordForm').on('submit', function(e) {
                e.preventDefault();
                saveRecord();
            });
            
            // 记录类型改变时显示/隐藏MX优先级
            $('#recordType').on('change', function() {
                if ($(this).val() === 'MX') {
                    $('#mxPriorityDiv').show();
                } else {
                    $('#mxPriorityDiv').hide();
                }
            });
            
            // 初始化记录值的显示优化
            initRecordValueDisplay();
        });
        
        // 显示域名输入界面
        function showDomainInput() {
            $('#domainInputSection').removeClass('hidden');
            $('#managementSection').addClass('hidden');
            
            // 加载最近管理的域名
            loadRecentDomains();
        }
        
        // 初始化域名
        function initializeDomain(domain) {
            CURRENT_DOMAIN = domain;
            $('#currentDomain').text(domain);
            $('#domainInputSection').addClass('hidden');
            $('#managementSection').removeClass('hidden');
            
            // 保存到最近域名
            saveRecentDomain(domain);
            
            // 加载记录
            loadRecords();
        }
        
        // 切换域名
        function changeDomain() {
            // 清除URL参数
            window.history.pushState({}, '', window.location.pathname);
            
            // 重置数据
            allRecords = [];
            currentRecords = [];
            $('#recordsTableBody').empty();
            
            // 显示域名输入界面
            showDomainInput();
        }
        
        // 保存最近管理的域名
        function saveRecentDomain(domain) {
            let recentDomains = JSON.parse(localStorage.getItem('recentDomains') || '[]');
            
            // 移除重复项
            recentDomains = recentDomains.filter(d => d !== domain);
            
            // 添加到开头
            recentDomains.unshift(domain);
            
            // 只保留最近5个
            recentDomains = recentDomains.slice(0, 5);
            
            localStorage.setItem('recentDomains', JSON.stringify(recentDomains));
        }
        
        // 加载最近管理的域名
        function loadRecentDomains() {
            const recentDomains = JSON.parse(localStorage.getItem('recentDomains') || '[]');
            
            if (recentDomains.length > 0) {
                $('#recentDomains').removeClass('hidden');
                const listHtml = recentDomains.map(domain => `
                    <button onclick="selectRecentDomain('${domain}')" 
                            class="w-full text-left px-3 py-2 text-sm text-gray-700 hover:bg-gray-100 rounded-lg transition duration-200">
                        <i class="fas fa-history text-gray-400 mr-2"></i>
                        ${domain}
                    </button>
                `).join('');
                $('#recentDomainsList').html(listHtml);
            } else {
                $('#recentDomains').addClass('hidden');
            }
        }
        
        // 选择最近的域名
        function selectRecentDomain(domain) {
            $('#domainInput').val(domain);
            $('#domainForm').submit();
        }
        
        // 加载解析记录
        function loadRecords() {
            $('#loadingState').removeClass('hidden');
            $('#recordsTableBody').empty();
            $('#emptyState').addClass('hidden');
            
            // 实际API调用
            $.ajax({
                url: API_BASE,
                method: 'POST',
                data: { 
                    action: 'records',
                    domain: CURRENT_DOMAIN 
                },
                dataType: 'json',
                success: function(response) {
                    console.log('API Response:', response); // 调试输出
                    
                    if (response.success === false) {
                        $('#loadingState').addClass('hidden');
                        Swal.fire('错误', response.message || '加载解析记录失败', 'error');
                        return;
                    }
                    
                    // 处理记录数据
                    if (response.records && Array.isArray(response.records)) {
                        allRecords = response.records;
                    } else if (response.DomainRecords && response.DomainRecords.Record) {
                        // 处理阿里云API原始格式
                        allRecords = response.DomainRecords.Record;
                    } else if (Array.isArray(response)) {
                        // 如果直接返回数组
                        allRecords = response;
                    } else {
                        console.error('Unexpected response format:', response);
                        allRecords = [];
                    }
                    
                    currentRecords = [...allRecords];
                    displayRecords();
                    $('#loadingState').addClass('hidden');
                },
                error: function(xhr, status, error) {
                    $('#loadingState').addClass('hidden');
                    console.error('API Error:', xhr.responseText);
                    
                    // 尝试解析错误信息
                    let errorMessage = '加载解析记录失败';
                    try {
                        const errorResponse = JSON.parse(xhr.responseText);
                        if (errorResponse.message) {
                            errorMessage = errorResponse.message;
                        }
                    } catch (e) {
                        errorMessage = error || '网络错误';
                    }
                    
                    Swal.fire('错误', errorMessage, 'error');
                }
            });
        }
        
        // 显示记录
        function displayRecords() {
            const tbody = $('#recordsTableBody');
            tbody.empty();
            
            if (currentRecords.length === 0) {
                $('#emptyState').removeClass('hidden');
                return;
            }
            
            $('#emptyState').addClass('hidden');
            
            currentRecords.forEach(record => {
                const statusBadge = record.Status === 'ENABLE' 
                    ? '<span class="px-2 py-1 text-xs font-medium bg-green-100 text-green-800 rounded-full">启用</span>'
                    : '<span class="px-2 py-1 text-xs font-medium bg-yellow-100 text-yellow-800 rounded-full">暂停</span>';
                
                const row = `
                    <tr class="record-row">
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            <div class="record-rr font-medium" title="${escapeHtml(record.RR)}">
                                ${escapeHtml(record.RR)}
                            </div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                            <span class="px-2 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded">${record.Type}</span>
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-500">
                            <div class="record-value-wrapper">
                                <div class="record-value font-mono" title="${escapeHtml(record.Value)}">
                                    ${escapeHtml(record.Value)}
                                </div>
                                ${record.Priority ? `<span class="text-xs text-gray-400 ml-2">(优先级: ${record.Priority})</span>` : ''}
                            </div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${formatTTL(record.TTL)}</td>
                        <td class="px-6 py-4 whitespace-nowrap">${statusBadge}</td>
                        <td class="px-6 py-4 text-sm text-gray-500">${record.Remark || '-'}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-center text-sm font-medium">
                            <button onclick="editRecord('${record.RecordId}')" class="text-blue-600 hover:text-blue-900 mr-3" title="编辑">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button onclick="toggleStatus('${record.RecordId}')" class="text-yellow-600 hover:text-yellow-900 mr-3" title="${record.Status === 'ENABLE' ? '暂停' : '启用'}">
                                <i class="fas fa-${record.Status === 'ENABLE' ? 'pause' : 'play'}"></i>
                            </button>
                            <button onclick="deleteRecord('${record.RecordId}')" class="text-red-600 hover:text-red-900" title="删除">
                                <i class="fas fa-trash"></i>
                            </button>
                        </td>
                    </tr>
                `;
                tbody.append(row);
            });
        }
        
        // HTML转义函数
        function escapeHtml(text) {
            const map = {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#039;'
            };
            return text.replace(/[&<>"']/g, m => map[m]);
        }
        
        // 格式化TTL
        function formatTTL(seconds) {
            if (seconds >= 86400) return Math.floor(seconds / 86400) + '天';
            if (seconds >= 3600) return Math.floor(seconds / 3600) + '小时';
            if (seconds >= 60) return Math.floor(seconds / 60) + '分钟';
            return seconds + '秒';
        }
        
        // 过滤记录
        function filterRecords() {
            const searchTerm = $('#searchInput').val().toLowerCase();
            const typeFilter = $('#typeFilter').val();
            
            currentRecords = allRecords.filter(record => {
                const matchSearch = !searchTerm || 
                    record.RR.toLowerCase().includes(searchTerm) || 
                    record.Value.toLowerCase().includes(searchTerm);
                const matchType = !typeFilter || record.Type === typeFilter;
                
                return matchSearch && matchType;
            });
            
            displayRecords();
        }
        
        // 刷新记录
        function refreshRecords() {
            loadRecords();
            Swal.fire({
                icon: 'success',
                title: '刷新成功',
                toast: true,
                position: 'top-end',
                showConfirmButton: false,
                timer: 2000
            });
        }
        
        // 显示添加模态框
        function showAddModal() {
            $('#modalTitle').text('添加解析记录');
            $('#recordForm')[0].reset();
            $('#recordId').val('');
            $('#recordModal').removeClass('hidden');
        }
        
        // 编辑记录
        function editRecord(recordId) {
            const record = allRecords.find(r => r.RecordId === recordId);
            if (!record) return;
            
            $('#modalTitle').text('编辑解析记录');
            $('#recordId').val(record.RecordId);
            $('#recordType').val(record.Type);
            $('#recordRR').val(record.RR);
            $('#recordValue').val(record.Value);
            $('#recordTTL').val(record.TTL);
            $('#recordRemark').val(record.Remark || '');
            
            if (record.Type === 'MX') {
                $('#mxPriorityDiv').show();
                $('#recordPriority').val(record.Priority || 10);
            }
            
            $('#recordModal').removeClass('hidden');
        }
        
        // 关闭模态框
        function closeModal() {
            $('#recordModal').addClass('hidden');
            $('#recordForm')[0].reset();
        }
        
        // 保存记录
        function saveRecord() {
            const recordId = $('#recordId').val();
            const formData = {
                action: recordId ? 'update' : 'add',
                domain: CURRENT_DOMAIN,
                recordId: recordId,
                Type: $('#recordType').val(),
                RR: $('#recordRR').val(),
                Value: $('#recordValue').val(),
                TTL: $('#recordTTL').val(),
                Remark: $('#recordRemark').val()
            };
            
            if (formData.Type === 'MX') {
                formData.Priority = $('#recordPriority').val();
            }
            
            // 显示加载状态
            Swal.fire({
                title: '处理中...',
                allowOutsideClick: false,
                didOpen: () => {
                    Swal.showLoading();
                }
            });
            
            // API调用
            $.ajax({
                url: API_BASE,
                method: 'POST',
                data: formData,
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        Swal.fire({
                            icon: 'success',
                            title: recordId ? '修改成功' : '添加成功',
                            toast: true,
                            position: 'top-end',
                            showConfirmButton: false,
                            timer: 2000
                        });
                        closeModal();
                        loadRecords();
                    } else {
                        Swal.fire('错误', response.message || '操作失败', 'error');
                    }
                },
                error: function(xhr, status, error) {
                    Swal.fire('错误', '操作失败：' + error, 'error');
                }
            });
        }
        
        // 切换状态
        function toggleStatus(recordId) {
            const record = allRecords.find(r => r.RecordId === recordId);
            if (!record) return;
            
            const action = record.Status === 'ENABLE' ? '暂停' : '启用';
            
            Swal.fire({
                title: `确认${action}？`,
                text: `确定要${action}这条解析记录吗？`,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: `确定${action}`,
                cancelButtonText: '取消'
            }).then((result) => {
                if (result.isConfirmed) {
                    // 显示加载状态
                    Swal.fire({
                        title: '处理中...',
                        allowOutsideClick: false,
                        didOpen: () => {
                            Swal.showLoading();
                        }
                    });
                    
                    // API调用
                    $.ajax({
                        url: API_BASE,
                        method: 'POST',
                        data: { 
                            action: 'toggle-status',
                            domain: CURRENT_DOMAIN,
                            recordId: recordId 
                        },
                        dataType: 'json',
                        success: function(response) {
                            if (response.success) {
                                loadRecords();
                                Swal.fire({
                                    icon: 'success',
                                    title: `${action}成功`,
                                    toast: true,
                                    position: 'top-end',
                                    showConfirmButton: false,
                                    timer: 2000
                                });
                            } else {
                                Swal.fire('错误', response.message || '操作失败', 'error');
                            }
                        },
                        error: function(xhr, status, error) {
                            Swal.fire('错误', '操作失败：' + error, 'error');
                        }
                    });
                }
            });
        }
        
        // 删除记录
        function deleteRecord(recordId) {
            Swal.fire({
                title: '确认删除？',
                text: '删除后将无法恢复，确定要删除这条解析记录吗？',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: '确定删除',
                cancelButtonText: '取消'
            }).then((result) => {
                if (result.isConfirmed) {
                    // 显示加载状态
                    Swal.fire({
                        title: '删除中...',
                        allowOutsideClick: false,
                        didOpen: () => {
                            Swal.showLoading();
                        }
                    });
                    
                    // API调用
                    $.ajax({
                        url: API_BASE,
                        method: 'POST',
                        data: { 
                            action: 'delete',
                            domain: CURRENT_DOMAIN,
                            recordId: recordId 
                        },
                        dataType: 'json',
                        success: function(response) {
                            if (response.success) {
                                loadRecords();
                                Swal.fire({
                                    icon: 'success',
                                    title: '删除成功',
                                    toast: true,
                                    position: 'top-end',
                                    showConfirmButton: false,
                                    timer: 2000
                                });
                            } else {
                                Swal.fire('错误', response.message || '删除失败', 'error');
                            }
                        },
                        error: function(xhr, status, error) {
                            Swal.fire('错误', '删除失败：' + error, 'error');
                        }
                    });
                }
            });
        }
        
        // 初始化记录值显示优化
        function initRecordValueDisplay() {
            // 为长记录值添加点击展开功能
            $(document).on('click', '.record-value', function(e) {
                e.stopPropagation();
                const $this = $(this);
                const fullValue = $this.attr('title');
                
                if ($this.css('text-overflow') === 'ellipsis') {
                    // 显示完整内容
                    $this.css({
                        'white-space': 'normal',
                        'word-break': 'break-all',
                        'overflow': 'visible',
                        'background-color': '#f3f4f6',
                        'padding': '8px',
                        'border-radius': '4px',
                        'position': 'relative',
                        'z-index': '10'
                    });
                } else {
                    // 恢复省略显示
                    $this.css({
                        'white-space': 'nowrap',
                        'word-break': 'normal',
                        'overflow': 'hidden',
                        'background-color': 'transparent',
                        'padding': '0',
                        'position': 'static',
                        'z-index': 'auto'
                    });
                }
            });
            
            // 为长主机记录添加点击展开功能
            $(document).on('click', '.record-rr', function(e) {
                e.stopPropagation();
                const $this = $(this);
                
                if ($this.css('text-overflow') === 'ellipsis') {
                    // 显示完整内容
                    $this.css({
                        'white-space': 'normal',
                        'word-break': 'break-all',
                        'overflow': 'visible',
                        'max-width': 'none'
                    });
                } else {
                    // 恢复省略显示
                    $this.css({
                        'white-space': 'nowrap',
                        'word-break': 'normal',
                        'overflow': 'hidden',
                        'max-width': '200px'
                    });
                }
            });
            
            // 点击其他地方时恢复
            $(document).on('click', function(e) {
                if (!$(e.target).hasClass('record-value') && !$(e.target).hasClass('record-rr')) {
                    $('.record-value').css({
                        'white-space': 'nowrap',
                        'word-break': 'normal',
                        'overflow': 'hidden',
                        'background-color': 'transparent',
                        'padding': '0',
                        'position': 'static',
                        'z-index': 'auto'
                    });
                    
                    $('.record-rr').css({
                        'white-space': 'nowrap',
                        'word-break': 'normal',
                        'overflow': 'hidden',
                        'max-width': '200px'
                    });
                }
            });
        }
        
        // 一键配置阿里云邮箱
        function quickAddAliyunMail() {
            // 阿里云企业邮箱所需的解析记录
            const mailRecords = [
                { RR: '@', Type: 'MX', Value: 'mx1.qiye.aliyun.com', Priority: 5, TTL: 600, Remark: '阿里云企业邮箱MX记录1' },
                { RR: '@', Type: 'MX', Value: 'mx2.qiye.aliyun.com', Priority: 10, TTL: 600, Remark: '阿里云企业邮箱MX记录2' },
                { RR: '@', Type: 'MX', Value: 'mx3.qiye.aliyun.com', Priority: 15, TTL: 600, Remark: '阿里云企业邮箱MX记录3' },
                { RR: 'imap', Type: 'CNAME', Value: 'imap.qiye.aliyun.com', TTL: 600, Remark: 'IMAP服务' },
                { RR: 'pop3', Type: 'CNAME', Value: 'pop.qiye.aliyun.com', TTL: 600, Remark: 'POP3服务' },
                { RR: 'smtp', Type: 'CNAME', Value: 'smtp.qiye.aliyun.com', TTL: 600, Remark: 'SMTP服务' },
                { RR: 'mail', Type: 'CNAME', Value: 'qiye.aliyun.com', TTL: 600, Remark: 'Webmail访问' },
                { RR: '@', Type: 'TXT', Value: 'v=spf1 include:spf.qiye.aliyun.com -all', TTL: 600, Remark: 'SPF记录' }
            ];
            
            Swal.fire({
                title: '配置阿里云企业邮箱',
                html: `
                    <div class="text-left">
                        <p class="mb-4">即将为域名 <strong>${CURRENT_DOMAIN}</strong> 添加以下解析记录：</p>
                        <div class="bg-gray-50 rounded-lg p-4 max-h-60 overflow-y-auto">
                            <table class="w-full text-sm">
                                <thead>
                                    <tr class="text-gray-600">
                                        <th class="text-left pb-2">主机记录</th>
                                        <th class="text-left pb-2">类型</th>
                                        <th class="text-left pb-2">记录值</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    ${mailRecords.map(r => `
                                        <tr class="border-t">
                                            <td class="py-1">${r.RR}</td>
                                            <td class="py-1">${r.Type}</td>
                                            <td class="py-1 text-gray-600">${r.Value}</td>
                                        </tr>
                                    `).join('')}
                                </tbody>
                            </table>
                        </div>
                        <div class="mt-4 p-3 bg-yellow-50 rounded-lg">
                            <p class="text-sm text-yellow-800">
                                <i class="fas fa-exclamation-triangle mr-2"></i>
                                <strong>注意：</strong>如果已存在相同的主机记录，可能会导致冲突。建议先检查现有记录。
                            </p>
                        </div>
                    </div>
                `,
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#10b981',
                cancelButtonColor: '#6b7280',
                confirmButtonText: '确认添加',
                cancelButtonText: '取消',
                width: '600px'
            }).then((result) => {
                if (result.isConfirmed) {
                    addMailRecords(mailRecords);
                }
            });
        }
        
        // 批量添加邮箱记录
        async function addMailRecords(records) {
            let successCount = 0;
            let failedRecords = [];
            
            // 显示进度
            Swal.fire({
                title: '正在添加解析记录...',
                html: `<div class="progress-info">
                    <div class="mb-4">进度: <span id="progress">0</span> / ${records.length}</div>
                    <div class="w-full bg-gray-200 rounded-full h-2.5">
                        <div id="progressBar" class="bg-blue-600 h-2.5 rounded-full" style="width: 0%"></div>
                    </div>
                </div>`,
                allowOutsideClick: false,
                showConfirmButton: false,
                didOpen: () => {
                    Swal.showLoading();
                }
            });
            
            // 逐个添加记录
            for (let i = 0; i < records.length; i++) {
                const record = records[i];
                
                try {
                    await $.ajax({
                        url: API_BASE,
                        method: 'POST',
                        data: {
                            action: 'add',
                            domain: CURRENT_DOMAIN,
                            Type: record.Type,
                            RR: record.RR,
                            Value: record.Value,
                            TTL: record.TTL,
                            Priority: record.Priority,
                            Remark: record.Remark
                        },
                        dataType: 'json'
                    });
                    
                    successCount++;
                } catch (error) {
                    failedRecords.push({
                        record: record,
                        error: error.responseJSON ? error.responseJSON.message : '添加失败'
                    });
                }
                
                // 更新进度
                const progress = i + 1;
                const percentage = Math.round((progress / records.length) * 100);
                $('#progress').text(progress);
                $('#progressBar').css('width', percentage + '%');
                
                // 添加延迟，避免请求过快
                await new Promise(resolve => setTimeout(resolve, 500));
            }
            
            // 显示结果
            if (failedRecords.length === 0) {
                Swal.fire({
                    icon: 'success',
                    title: '配置完成！',
                    html: `
                        <p>成功添加了所有 ${successCount} 条邮箱解析记录。</p>
                        <p class="mt-2 text-sm text-gray-600">邮箱解析生效可能需要几分钟时间。</p>
                    `,
                    confirmButtonColor: '#10b981'
                });
                loadRecords();
            } else {
                Swal.fire({
                    icon: 'warning',
                    title: '部分记录添加失败',
                    html: `
                        <div class="text-left">
                            <p>成功添加: ${successCount} 条</p>
                            <p>失败: ${failedRecords.length} 条</p>
                            <div class="mt-3">
                                <p class="font-semibold mb-2">失败记录：</p>
                                <div class="bg-red-50 rounded p-3 text-sm max-h-40 overflow-y-auto">
                                    ${failedRecords.map(f => `
                                        <div class="mb-2">
                                            <span class="font-medium">${f.record.RR} ${f.record.Type}</span>: 
                                            <span class="text-red-600">${f.error}</span>
                                        </div>
                                    `).join('')}
                                </div>
                            </div>
                        </div>
                    `,
                    confirmButtonColor: '#ef4444',
                    width: '600px'
                });
                loadRecords();
            }
        }
    </script>
</body>
</html>