# API文档

## 概述

DanceMonkey API采用RESTful设计，提供了一系列端点用于视频上传、处理和结果获取。所有API端点都以`/api/v1`为前缀，支持跨域请求（CORS）。

## 基础信息

- 基础URL: 
  - 开发环境: `http://localhost:8000`
  - 生产环境: `https://api.dancemonkey.azurewebsites.net`
- API版本: v1
- 响应格式: JSON
- CORS配置: 允许前端域名访问

## 认证

### 会话认证
API使用基于Cookie的会话认证：

1. 登录：
```http
POST /api/auth/login
Content-Type: application/json

{
    "username": "your_username",
    "password": "your_password"
}
```

2. 登出：
```http
POST /api/auth/logout
```

所有API请求会自动使用会话Cookie进行认证，无需额外配置。

## CORS配置

### 允许的源
```python
CORS_ORIGINS = [
    "http://localhost:5173",  # 开发环境
    "https://dancemonkey.azurewebsites.net"  # 生产环境
]
```

### CORS设置
```python
CORS_SETTINGS = {
    "allow_origins": CORS_ORIGINS,
    "allow_credentials": True,
    "allow_methods": ["*"],
    "allow_headers": ["*"]
}
```

## API端点

### 视频管理

#### 上传视频
```http
POST /api/v1/videos
Content-Type: multipart/form-data

{
    "file": <video-file>,
    "title": "string",
    "description": "string"
}
```

**响应**
```json
{
    "task_id": "string",
    "video_id": "string",
    "status": "pending",
    "created_at": "string"
}
```

#### 获取视频信息
```http
GET /api/v1/videos/{video_id}
```

**响应**
```json
{
    "id": "string",
    "title": "string",
    "description": "string",
    "status": "string",
    "created_at": "string",
    "updated_at": "string",
    "duration": "number",
    "file_size": "number",
    "url": "string"
}
```

### 任务管理

#### 获取任务状态
```http
GET /api/v1/tasks/{task_id}
```

**响应**
```json
{
    "task_id": "string",
    "status": "string",
    "progress": "number",
    "message": "string",
    "created_at": "string",
    "updated_at": "string"
}
```

#### 取消任务
```http
POST /api/v1/tasks/{task_id}/cancel
```

**响应**
```json
{
    "task_id": "string",
    "status": "cancelled",
    "message": "string"
}
```

### 分析结果

#### 获取分析结果
```http
GET /api/v1/results/{task_id}
```

**响应**
```json
{
    "task_id": "string",
    "video_id": "string",
    "analysis": {
        "movements": [
            {
                "timestamp": "number",
                "duration": "number",
                "type": "string",
                "confidence": "number",
                "description": "string"
            }
        ],
        "suggestions": [
            {
                "type": "string",
                "description": "string",
                "confidence": "number"
            }
        ]
    },
    "created_at": "string"
}
```

#### 导出结果
```http
POST /api/v1/results/{task_id}/export
Content-Type: application/json

{
    "format": "string"  // "pdf" | "json" | "csv"
}
```

**响应**
```json
{
    "export_id": "string",
    "status": "processing",
    "download_url": "string"
}
```

## 状态码

| 状态码 | 描述 |
|--------|------|
| 200 | 成功 |
| 201 | 创建成功 |
| 400 | 请求错误 |
| 401 | 未认证 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 409 | 资源冲突 |
| 429 | 请求过多 |
| 500 | 服务器错误 |

## 错误响应

所有错误响应都遵循以下格式：
```json
{
    "error": {
        "code": "string",
        "message": "string",
        "details": {}
    }
}
```

## 数据模型

### Video
```json
{
    "id": "string",
    "title": "string",
    "description": "string",
    "status": "string",
    "created_at": "string",
    "updated_at": "string",
    "duration": "number",
    "file_size": "number",
    "url": "string"
}
```

### Task
```json
{
    "id": "string",
    "video_id": "string",
    "status": "string",
    "progress": "number",
    "message": "string",
    "created_at": "string",
    "updated_at": "string"
}
```

### Analysis
```json
{
    "movements": [
        {
            "timestamp": "number",
            "duration": "number",
            "type": "string",
            "confidence": "number",
            "description": "string"
        }
    ],
    "suggestions": [
        {
            "type": "string",
            "description": "string",
            "confidence": "number"
        }
    ]
}
```

## 限制

- 视频文件大小：最大500MB
- 支持的视频格式：MP4, MOV, AVI
- API请求速率：
  - 认证用户：100次/分钟
  - 未认证用户：10次/分钟
- 并发任务数：每用户最多5个

## WebSocket API

### 任务状态订阅
```
WebSocket: ws://api.example.com/ws/tasks/{task_id}
```

**消息格式**
```json
{
    "type": "status_update",
    "data": {
        "task_id": "string",
        "status": "string",
        "progress": "number",
        "message": "string",
        "timestamp": "string"
    }
}
```

## 前端集成

### API客户端配置
```typescript
import axios from 'axios';

const api = axios.create({
  baseURL: process.env.VITE_API_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json'
  }
});

// 请求拦截器
api.interceptors.request.use(config => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// 响应拦截器
api.interceptors.response.use(
  response => response.data,
  error => {
    if (error.response?.status === 401) {
      // 处理认证错误
    }
    return Promise.reject(error);
  }
);
```

### WebSocket客户端配置
```typescript
class TaskWebSocket {
  private ws: WebSocket;
  private taskId: string;

  constructor(taskId: string) {
    this.taskId = taskId;
    this.ws = new WebSocket(`${process.env.VITE_WS_URL}/ws/tasks/${taskId}`);
    
    this.ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      // 处理状态更新
    };
  }

  disconnect() {
    this.ws.close();
  }
}
```

## 版本控制

- 当前版本：v1
- URL前缀：`/api/v1`
- 版本更新策略：
  - 主版本号：不兼容的API更改
  - 次版本号：向后兼容的功能性新增
  - 修订号：向后兼容的问题修复
``` 