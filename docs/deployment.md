# 部署指南

## 概述

本文档详细说明了如何部署DanceMonkey应用到Azure云平台。

## 前置要求

### 本地开发环境
- Python 3.9+（后端开发）
- PostgreSQL（本地开发）
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

### 2. 后端部署

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
1. 后端监控
   - API响应时间
   - 依赖项延迟
   - 异常率
   - 资源使用情况

2. 告警配置
   - 响应时间 > 1s
   - 错误率 > 1%
   - 存储使用率 > 80%

## 安全配置

### 网络安全
1. 后端安全
   - 防火墙规则
   - API认证
   - 数据加密

2. 访问控制
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
  deploy-backend:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Python
      uses: actions/setup-python@v2
      with:
        python-version: '3.9'
    
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

1. 后端部署失败
   ```bash
   # 检查部署日志
   azd logs
   
   # 清理资源重新部署
   azd down
   azd up
   ```

2. 连接问题
   ```bash
   # 检查网络连接
   az network watcher test-connection
   
   # 验证防火墙规则
   az postgres server firewall-rule list
   ```

## 维护指南

### 日常维护
1. 后端维护
   - 安装安全补丁
   - 更新依赖包
   - 数据库维护

2. 容量规划
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