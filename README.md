# DanceMonkey - AI舞蹈编排助手

DanceMonkey是一个基于Azure云服务的AI舞蹈编排助手，能够智能分析舞蹈视频并生成专业的编舞方案。该系统采用现代化的云原生架构，使用Python FastAPI构建后端服务，React构建前端界面，并充分利用Azure云服务实现AI模型的部署和推理。

## 功能特点

- **视频分析**：上传舞蹈视频，自动分析舞蹈动作
- **智能编舞**：基于AI模型生成专业编舞建议
- **实时反馈**：提供处理进度的实时状态更新
- **结果导出**：支持多种格式的编舞方案导出
- **可视化界面**：直观的Web界面，支持视频预览和结果展示

## 技术架构

### 核心组件

- **前端**：
  - React + TypeScript
  - Vite 构建工具
  - TailwindCSS 样式框架
  - React Query 数据管理
  
- **后端**：
  - Python FastAPI应用
  - PostgreSQL数据库
  - Azure Blob Storage
  - Azure Machine Learning
  - Application Insights

### 系统架构图

```
用户 -> React前端 -> FastAPI后端 -> 存储服务（视频文件）
                               -> AI服务（动作分析）
                               -> 数据库（结果存储）
```

## 项目结构

```
.
├── .github/                # GitHub Actions配置
│   └── workflows/         # CI/CD工作流
├── docs/                  # 项目文档
│   ├── architecture.md    # 架构文档
│   ├── api.md            # API文档
│   └── deployment.md     # 部署指南
├── frontend/              # 前端代码
│   ├── src/              # 源代码
│   │   ├── components/   # React组件
│   │   ├── pages/       # 页面组件
│   │   ├── hooks/       # 自定义Hooks
│   │   ├── services/    # API服务
│   │   ├── utils/       # 工具函数
│   │   ├── types/       # TypeScript类型
│   │   └── styles/      # 样式文件
│   ├── public/          # 静态资源
│   ├── tests/           # 前端测试
│   ├── vite.config.ts   # Vite配置
│   ├── tailwind.config.js # Tailwind配置
│   └── package.json     # 前端依赖
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
├── package.json        # 项目依赖
└── README.md          # 项目说明文档
```

## 开发流程

### 1. 环境准备

#### 前置要求
- Node.js 18+
- Python 3.12+
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

2. 安装前端依赖：
   ```bash
   cd frontend
   npm install
   ```

3. 安装后端依赖：
   ```bash
   cd backend
   python -m venv .venv
   source .venv/bin/activate  # Windows: .venv\Scripts\activate
   pip install -r requirements.txt
   pip install -r requirements-dev.txt
   ```

4. 设置环境变量：
   ```bash
   cp .env.example .env
   # 编辑.env文件，配置必要的环境变量
   ```

### 2. 本地开发

1. 启动前端开发服务器：
   ```bash
   cd frontend
   npm run dev
   ```

2. 启动后端服务器：
   ```bash
   cd backend
   uvicorn app.main:app --reload --port=8000
   ```

3. 访问应用：
   - 前端界面: http://localhost:5173
   - API文档: http://localhost:8000/docs
   - ReDoc: http://localhost:8000/redoc

### 3. 测试

1. 运行前端测试：
   ```bash
   cd frontend
   npm test
   ```

2. 运行后端测试：
   ```bash
   cd backend
   pytest
   ```

3. 代码质量检查：
   ```bash
   # 前端
   cd frontend
   npm run lint
   npm run format
   
   # 后端
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
- [技术架构](docs/architecture.md)
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
