# DanceMonkey - AI舞蹈编排助手

DanceMonkey是一个基于Azure云服务的AI舞蹈编排助手，能够智能分析舞蹈视频并生成专业的编舞方案。该系统采用现代化的云原生架构，使用Python FastAPI构建后端服务，并充分利用Azure云服务实现AI模型的部署和推理。

## 功能特点

- **视频分析**：上传舞蹈视频，自动分析舞蹈动作
- **智能编舞**：基于AI模型生成专业编舞建议
- **实时反馈**：提供处理进度的实时状态更新
- **结果导出**：支持多种格式的编舞方案导出

## 系统架构

### 核心组件

1. **后端服务**
   - FastAPI应用：
     - 异步处理能力
     - OpenAPI文档自动生成
     - 依赖注入系统
     - 内置验证功能
   - 异步任务处理：
     - 后台任务管理
     - 状态追踪
     - 进度报告
     - 错误处理

2. **数据存储**
   - PostgreSQL Flexible Server：
     - 用户数据
     - 视频元数据
     - 处理任务状态
     - 分析结果数据
   - Azure Blob Storage：
     - 原始视频文件
     - 处理后的视频
     - 导出的编舞方案

3. **AI服务**
   - Azure Machine Learning：企业级完整流程，部署配置麻烦
   - ACI：自己创建容器，执行模型推理脚本，后端调用
   - 直接集成到 web 应用里：需要开资源多的 GPU 服务器
   - AI Studio：简单快速

4. **监控和安全**
   - Application Insights：
     - API性能监控
     - 错误追踪
     - 资源使用监控

## 项目结构

```
.
├── .github/                # GitHub Actions配置
│   └── workflows/         # CI/CD工作流
├── docs/                  # 项目文档
├── frontend/              # 前端代码（待开发）
├── backend/              # 后端代码
│   ├── app/             # 主应用代码
│   ├── tests/          # 后端测试
│   └── requirements.txt # Python 依赖
├── infra/               # 基础设施代码
│   ├── core/           # 核心基础设施模块
│   │   ├── ai/        # AzureML配置
│   │   ├── storage/   # Blob存储配置
│   │   ├── monitor/   # Application Insights配置
│   │   ├── host/      # App Service配置
│   │   └── database/  # PostgreSQL配置
│   └── main.bicep      # 主要基础设施定义
├── .gitignore          # Git忽略配置
├── azure.yaml          # Azure 部署配置
└── README.md          # 项目说明文档
```

## 开发流程

### 1. 环境准备

#### 前置要求
- Python 3.9+
- Azure订阅
- Azure CLI
- Azure Developer CLI (azd)

#### 本地开发环境设置

1. 克隆代码库：
   ```bash
   git clone <repository-url>
   cd DanceMonkey
   ```

2. 安装后端依赖：
   ```bash
   cd backend
   python -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

### 2. 本地开发

1. 启动后端服务器：
   ```bash
   cd backend
   uvicorn app.main:app --reload --port 8000
   ```

2. 访问API文档：
   - API文档: http://localhost:8000/docs
   - ReDoc: http://localhost:8000/redoc

### 3. 测试

运行后端测试：
```bash
cd backend
source .venv/bin/activate
pytest tests/
```

### 4. 部署

1. 登录Azure：
   ```bash
   azd auth login
   ```

2. 部署应用：
   ```bash
   # 部署所有资源
   azd up

   # 只是更新代码，没有更新资源
   azd deploy api
   ```

3. 重启应用：
```bash
az webapp restart \
--name $APP_SERVICE_NAME \
--resource-group $RESOURCE_GROUP_NAME
```


## CI/CD

项目使用 GitHub Actions 进行持续集成和部署：

1. **测试阶段**：
   - 运行单元测试
   - Python 3.9 环境
   - 自动运行所有测试用例

2. **部署阶段**（暂未启用）：
   - 使用 Azure Developer CLI (azd)
   - 自动部署到 Azure
   - 环境变量和密钥管理

## API 端点

1. **健康检查**
   ```
   GET /health
   Response: {"status": "ok"}
   ```

2. **根路径**
   ```
   GET /
   Response: {"status": "healthy", "service": "dance-monkey-api"}
   ```

## 许可证

[MIT License](LICENSE)
