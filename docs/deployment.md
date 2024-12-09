# 部署指南

## 概述

本文档说明如何将 DanceMonkey 应用部署到 Azure 云平台。

## 前置要求

### 本地环境
- Python 3.9+
- Azure CLI
- Git

### Azure 订阅
- 有效的 Azure 订阅
- 订阅中具有 Owner 或 Contributor 权限

## 部署步骤

### 1. 准备工作

1. 克隆代码库：
   ```bash
   git clone <repository-url>
   cd DanceMonkey
   ```

2. 登录 Azure：
   ```bash
   az login
   ```

### 2. 部署基础设施

1. 部署 Azure 资源：
   ```bash
   cd infra
   az deployment sub create \
     --location <region> \
     --template-file main.bicep
   ```

2. 验证部署：
   ```bash
   az resource list --resource-group <resource-group-name>
   ```

## 资源配置

### App Service
- SKU: B1
- 实例数: 1
- Python 版本: 3.9

### Storage Account
- SKU: Standard_LRS
- 访问层: Hot
- 容器:
  - videos: 视频存储
  - results: 结果存储

### Application Insights
- 保留期: 90天
- 采样率: 100%

## 监控配置

### Application Insights
1. 性能监控
   - API响应时间
   - 内存使用率
   - CPU使用率

2. 错误监控
   - 异常记录
   - HTTP错误

## 故障排除

### 常见问题

1. 部署失败
   ```bash
   # 检查部署日志
   az deployment operation list
   
   # 清理资源重新部署
   az group delete --name <resource-group-name>
   ```

2. 应用启动问题
   ```bash
   # 检查应用日志
   az webapp log tail
   ```

## 维护指南

### 日常维护
1. 更新依赖：
   ```bash
   pip install -r requirements.txt --upgrade
   ```

2. 检查日志：
   ```bash
   az webapp log download
   ```

### 应急响应
1. 性能问题
   - 检查 Application Insights
   - 调整应用服务计划

2. 服务中断
   - 检查错误日志
   - 回滚到上一个版本
``` 