# DanceMonkey - AI舞蹈编排助手

DanceMonkey是一个基于Azure云服务的AI舞蹈编排助手，能够智能分析舞蹈视频并生成专业的编舞方案。该系统采用现代化的云原生架构，使用Python FastAPI构建后端服务，并充分利用Azure云服务实现AI模型的部署和推理。

## 功能特点

- **视频分析**：上传舞蹈视频，自动分析舞蹈动作
- **智能编舞**：基于AI模型生成专业编舞建议
- **实时反馈**：提供处理进度的实时状态更新
- **结果导出**：支持多种格式的编舞方案导出

## 系统架构

### 核心组件

1. **前端应用**
   - 状态：待开发
   - 功能规划：
     - 视频上传和预览
     - 处理进度展示
     - 结果可视化
     - 实时状态更新

2. **后端服务**
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

3. **数据存储**
   - PostgreSQL数据库：
     - 用户数据
     - 视频元数据
     - 处理任务状态
     - 分析结果数据
   - Azure Blob Storage：
     - 原始视频文件
     - 处理后的视频
     - 导出的编舞方案

4. **AI服务**
   - Azure Machine Learning：
     - 舞蹈动作识别
     - 动作序列分析
     - 编舞生成
   - 部署模式：
     - 在线推理端点
     - 批量处理作业

5. **监控服务**
   - Application Insights：
     - API性能监控
     - 错误追踪
     - 资源使用监控
     - 自动告警

### 系统限制

- 视频文件大小：最大500MB
- 处理时间：单个视频最长30分钟
- API响应时间：< 200ms（95%请求）
- 系统可用性：99.9%

### 安全架构

- 身份认证：简单的用户名密码认证
- 会话管理：基于 FastAPI 的会话中间件
- 数据安全：HTTPS 传输加密

## 项目结构

```
.
├── .github/                # GitHub Actions配置
│   └── workflows/         # CI/CD工作流
├── docs/                  # 项目文档
│   ├── api.md            # API文档
│   └── deployment.md     # 部署指南
├── frontend/              # 前端代码（待开发）
├── backend/              # 后端代码
│   ├── app/             # 主应用代码
│   │   ├── api/        # API相关代码
│   │   │   ├── endpoints/
│   │   │   └── deps.py
│   │   ├── core/      # 核心功能
│   │   │   ├── config.py
│   │   │   └── security.py
│   │   ├── models/    # 数据模型
│   │   │   ├── video.py
│   │   │   └── dance.py
│   │   └── services/  # 业务服务
│   │       ├── storage.py
│   │       ├── ml.py
│   │       └── processing.py
│   ├── tests/          # 后端测试
│   ├── alembic/        # 数据库迁移
│   ├── gunicorn.conf.py # Gunicorn配置
│   └── entrypoint.sh   # 启动脚本
├── infra/               # 基础设施代码
│   ├── core/           # 核心基础设施模块
│   │   ├── ai/        # AzureML配置
│   │   ├── storage/   # Blob存储配置
│   │   ├── monitor/   # Application Insights配置
│   │   ├── host/      # App Service配置
│   │   ├── database/  # PostgreSQL配置
│   │   └── security/  # 角色和权限配置
│   └── main.bicep      # 主要基础设施定义
├── .gitignore          # Git忽略配置
├── .env.example        # 环境变量示例
└── README.md          # 项目说明文档
```

## 开发流程

### 1. 环境准备

#### 前置要求
- Python 3.9+
- Azure订阅
- Azure CLI
- Azure Developer CLI (azd)
- PostgreSQL（本地开发）

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
   source .venv/bin/activate  # Windows: .venv\Scripts\activate
   pip install -r requirements.txt
   pip install -r requirements-dev.txt
   ```

3. 设置环境变量：
   ```bash
   cp .env.example .env
   # 编辑.env文件，配置必要的环境变量
   ```

### 2. 本地开发

1. 启动后端服务器：
   ```bash
   cd backend
   uvicorn app.main:app --reload --port=8000
   ```

2. 访问API文档：
   - API文档: http://localhost:8000/docs
   - ReDoc: http://localhost:8000/redoc

### 3. 测试

1. 运行后端测试：
   ```bash
   cd backend
   pytest
   ```

2. 代码质量检查：
   ```bash
   cd backend
   black .
   isort .
   flake8
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
   ```

## 文档

详细文档请参考：
- [API文档](docs/api.md)
- [部署指南](docs/deployment.md)

## 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: add amazing feature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建Pull Request

## 许可证

[MIT License](LICENSE)
