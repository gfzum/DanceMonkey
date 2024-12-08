# 部署指南

## 概述

本文档详细说明了如何部署DanceMonkey应用到Azure云平台。系统采用前后端分离架构，分别部署到不同的服务上。

## 前置要求

### 必需工具
- Node.js 18+（前端开发）
- Python 3.12+（后端开发）
- Azure CLI
- Azure Developer CLI (azd)
- Git

### Azure订阅要求
- 有效的Azure订阅
- 订阅中具有Owner或Contributor权限
- 足够的配额用于创建所需资源

## 部署步骤

### 1. 准备工作

1. 克隆代码库：
   ```bash
   git clone <repository-url>
   cd DanceMonkey
   ```

2. 登录Azure：
   ```bash
   # 登录Azure
   az login

   # 登录Azure Developer CLI
   azd auth login
   ```

3. 设置环境变量：
   ```bash
   cp .env.example .env
   # 编辑.env文件，配置必要的环境变量
   ```

### 2. 前端部署

1. 构建前端应用：
   ```bash
   cd frontend
   npm install
   npm run build
   ```

2. 部署到Azure Static Web Apps：
   ```bash
   az staticwebapp create --name <app-name> --resource-group <resource-group> --source .
   ```

### 3. 后端部署

1. 构建后端应用：
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

2. 部署基础设施和应用：
   ```bash
   azd up
   ```

3. 验证部署：
   ```bash
   azd test
   ```

## 资源配置

### Static Web Apps（前端）
- SKU: Standard
- 自定义域名配置
- GitHub Actions集成
- 路由规则配置

### App Service（后端）
- SKU: P1v2
- 实例数: 2
- 自动扩展配置:
  - 最小实例: 2
  - 最大实例: 10
  - CPU阈值: 70%

### PostgreSQL
- SKU: GP_Gen5_2
- 存储: 128 GB
- 备份保留: 7天
- 地理冗余: 启用

### Storage Account
- SKU: Standard_LRS
- 访问层: Hot
- 容器:
  - videos: 原始视频
  - processed: 处理后的视频
  - exports: 导出文件

### Application Insights
- 保留期: 90天
- 采样率: 100%
- 工作区: 新建

## 环境变量

### 前端环境变量
```
VITE_API_URL=<backend-api-url>
VITE_STORAGE_URL=<storage-account-url>
VITE_APP_INSIGHTS_KEY=<appinsights-key>
```

### 后端环境变量
```
AZURE_STORAGE_CONNECTION_STRING=<storage-connection-string>
AZURE_POSTGRESQL_CONNECTION_STRING=<postgresql-connection-string>
APPLICATIONINSIGHTS_CONNECTION_STRING=<appinsights-connection-string>
AZURE_TENANT_ID=<tenant-id>
AZURE_CLIENT_ID=<client-id>
AZURE_CLIENT_SECRET=<client-secret>
```

## 监控配置

### Application Insights
1. 前端监控
   - 页面加载性能
   - 用户行为分析
   - 错误追踪
   - 资源使用情况

2. 后端监控
   - API响应时间
   - 依赖项延迟
   - 异常率
   - 资源使用情况

3. 告警配置
   - 响应时间 > 1s
   - 错误率 > 1%
   - 存储使用率 > 80%

## 安全配置

### 网络安全
1. 前端安全
   - HTTPS强制
   - CSP配置
   - CORS策略

2. 后端安全
   - 防火墙规则
   - API认证
   - 数据加密

3. 访问控制
   - Azure AD认证
   - RBAC策略
   - 密钥管理

## CI/CD配置

### GitHub Actions
```yaml
name: Deploy to Azure

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  deploy-frontend:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '18'
    
    - name: Install Dependencies
      run: |
        cd frontend
        npm install
    
    - name: Build
      run: |
        cd frontend
        npm run build
    
    - name: Deploy to Static Web Apps
      uses: Azure/static-web-apps-deploy@v1
      with:
        azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
        repo_token: ${{ secrets.GITHUB_TOKEN }}
        action: "upload"
        app_location: "frontend/dist"
        api_location: ""
        output_location: ""

  deploy-backend:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Python
      uses: actions/setup-python@v2
      with:
        python-version: '3.12'
    
    - name: Setup Azure CLI
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    - name: Install azd
      run: |
        curl -fsSL https://aka.ms/install-azd.sh | bash
    
    - name: Deploy Backend
      run: |
        cd backend
        azd up --no-prompt
```

## 故障排除

### 常见问题

1. 前端部署失败
   ```bash
   # 检查构建输出
   npm run build
   
   # 检查Static Web Apps日志
   az staticwebapp logs show
   ```

2. 后端部署失败
   ```bash
   # 检查部署日志
   azd logs
   
   # 清理资源重新部署
   azd down
   azd up
   ```

3. 连接问题
   ```bash
   # 检查网络连接
   az network watcher test-connection
   
   # 验证防火墙规则
   az postgres server firewall-rule list
   ```

## 维护指南

### 日常维护
1. 前端维护
   - 更新依赖包
   - 优化构建配置
   - 监控性能指标

2. 后端维护
   - 安装安全补丁
   - 更新依赖包
   - 数据库维护

3. 容量规划
   - 监控资源使用
   - 调整规模
   - 优化成本

### 应急响应
1. 性能问题
   - 检查监控指标
   - 识别瓶颈
   - 扩展资源

2. 服务中断
   - 检查日志
   - 执行回滚
   - 启动故障转移

3. 安全事件
   - 隔离受影响系统
   - 评估影响范围
   - 实施补救措施

## 升级流程

### 1. 准备工作
- 审查变更内容
- 更新文档
- 准备回滚计划

### 2. 测试环境
- 部署新版本
- 运行测试套件
- 验证功能

### 3. 生产环境
- 执行备份
- 部署更新
- 验证服务
- 监控性能
``` 